output "vpc_id" {
  value       = aws_vpc.main.id
  description = "ID of the SecureBank VPC"
}

output "public_subnet_ids" {
  value       = aws_subnet.public[*].id
  description = "Public subnet IDs (load balancers, NAT gateway)"
}

output "private_subnet_ids" {
  value       = aws_subnet.private[*].id
  description = "Private subnet IDs (EKS worker nodes)"
}

output "nat_gateway_ip" {
  value       = aws_eip.nat.public_ip
  description = "NAT Gateway public IP"
}
