output "cluster_name" {
  description = "EKS cluster name"
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "EKS cluster endpoint"
  value       = module.eks.cluster_endpoint
}

output "cluster_certificate_authority" {
  description = "EKS cluster CA certificate (base64)"
  value       = module.eks.cluster_certificate_authority
  sensitive   = true
}

output "cluster_role_arn" {
  description = "ARN of the EKS cluster IAM role"
  value       = module.iam.cluster_role_arn
}

output "node_role_arn" {
  description = "ARN of the EKS node IAM role"
  value       = module.iam.node_role_arn
}

output "ecr_repository_url" {
  description = "Amazon ECR repository URL"
  value       = aws_ecr_repository.securebank.repository_url
}

output "secret_arn" {
  description = "ARN of the SecureBank Secrets Manager secret"
  value       = module.secrets.secret_arn
}

output "vpc_id" {
  description = "VPC ID"
  value       = module.network.vpc_id
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = module.network.public_subnet_ids
}

output "private_subnet_ids" {
  description = "Private subnet IDs"
  value       = module.network.private_subnet_ids
}

output "nat_gateway_ip" {
  description = "NAT gateway public IP"
  value       = module.network.nat_gateway_ip
}
