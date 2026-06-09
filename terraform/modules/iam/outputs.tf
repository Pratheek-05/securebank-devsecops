output "cluster_role_arn" {
  value       = aws_iam_role.eks_cluster.arn
  description = "ARN of the EKS cluster IAM role"
}

output "cluster_role_name" {
  value       = aws_iam_role.eks_cluster.name
  description = "Name of the EKS cluster IAM role"
}

output "node_role_arn" {
  value       = aws_iam_role.eks_node.arn
  description = "ARN of the EKS node IAM role"
}

output "node_role_name" {
  value       = aws_iam_role.eks_node.name
  description = "Name of the EKS node IAM role"
}
