output "vpc_id" {
  description = "ID of the Zuri VPC"
  value       = aws_vpc.main.id
}

output "public_subnet_id" {
  description = "ID of the public subnet"
  value       = aws_subnet.public.id
}

output "internet_gateway_id" {
  description = "ID of the Internet Gateway"
  value       = aws_internet_gateway.main.id
}
output "ec2_instance_id" {
  description = "ID of the Zuri EC2 instance"
  value       = aws_instance.zuri_server.id
}

output "ec2_public_ip" {
  description = "Public IP address of the Zuri EC2 instance"
  value       = aws_instance.zuri_server.public_ip
}

output "ec2_public_dns" {
  description = "Public DNS name of the Zuri EC2 instance"
  value       = aws_instance.zuri_server.public_dns
}