output "cluster_name" {
  value       = aws_eks_cluster.securebank.name
  description = "Name of the EKS cluster"
}

output "cluster_endpoint" {
  value       = aws_eks_cluster.securebank.endpoint
  description = "Endpoint of the EKS cluster"
}

output "cluster_certificate_authority" {
  value       = aws_eks_cluster.securebank.certificate_authority[0].data
  description = "Base64-encoded certificate authority data for the cluster"
  sensitive   = true
}

output "cluster_security_group_id" {
  value       = aws_eks_cluster.securebank.vpc_config[0].cluster_security_group_id
  description = "Security group ID attached to the EKS cluster"
}

output "node_group_name" {
  value       = aws_eks_node_group.securebank.node_group_name
  description = "EKS managed node group name"
}
