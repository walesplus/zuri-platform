
terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# -------------------------
# VPC
# -------------------------

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name    = "${var.project_name}-vpc"
    Project = var.project_name
  }
}

# -------------------------
# Public Subnet
# -------------------------

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidr
  map_public_ip_on_launch = false

  tags = {
    Name    = "${var.project_name}-public-subnet"
    Project = var.project_name
  }
}

# -------------------------
# Internet Gateway
# -------------------------

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name    = "${var.project_name}-igw"
    Project = var.project_name
  }
}

# -------------------------
# Public Route Table
# -------------------------

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name    = "${var.project_name}-public-rt"
    Project = var.project_name
  }
}

# -------------------------
# Route Table Association
# -------------------------

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# -------------------------
# Security Group
# -------------------------
# Temporary capstone exception: outbound internet access is required
# for Amazon Linux package updates and Docker/Git installation.
# Risk: all outbound protocols and destinations remain permitted.
# Remediation: use controlled outbound HTTPS and approved endpoints.
# Review before 2026-11-30.
#trivy:ignore:AWS-0104:exp:2026-11-30
resource "aws_security_group" "zuri_sg" {
  name        = "${var.project_name}-sg"
  description = "Security group for the Zuri application"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ssh_allowed_cidr]
  }

  ingress {
    description = "Frontend"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = [var.ssh_allowed_cidr]
  }

  ingress {
    description = "Backend API"
    from_port   = 5001
    to_port     = 5001
    protocol    = "tcp"
    cidr_blocks = [var.ssh_allowed_cidr]
  }

  egress {
    description = "Allow outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "${var.project_name}-sg"
    Project = var.project_name
  }
}

# -------------------------
# Amazon Linux AMI
# -------------------------

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# -------------------------
# EC2 Key Pair
# -------------------------

resource "aws_key_pair" "zuri_key" {
  key_name   = "${var.project_name}-key"
  public_key = file("${path.module}/zuri-ec2-key.pub")

  tags = {
    Name    = "${var.project_name}-key"
    Project = var.project_name
  }
}

# -------------------------
# EC2 Instance
# -------------------------

resource "aws_instance" "zuri_server" {
  lifecycle {
    prevent_destroy = true

    ignore_changes = [
      ami,
      associate_public_ip_address
    ]
  }

  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.zuri_sg.id]
  associate_public_ip_address = true
  key_name                    = aws_key_pair.zuri_key.key_name

  root_block_device {
    encrypted   = true
    volume_type = "gp3"
  }

  metadata_options {
    http_tokens = "required"
  }

  user_data = file("${path.module}/user-data.sh")

  tags = {
    Name    = "${var.project_name}-server"
    Project = var.project_name
  }
}
