variable "aws_region" {
  description = "AWS region used for the Zuri infrastructure"
  type        = string
  default     = "ca-central-1"
}

variable "vpc_cidr" {
  description = "CIDR block for the Zuri VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "project_name" {
  description = "Name used to identify Zuri resources"
  type        = string
  default     = "zuri-capstone"
}
variable "ssh_allowed_cidr" {
  description = "Trusted public IP address allowed to connect via SSH"
  type        = string
  default     = "127.0.0.1/32"
}
