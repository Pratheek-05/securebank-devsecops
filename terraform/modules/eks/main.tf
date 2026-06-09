# ── EKS Cluster ──────────────────────────────────────────
resource "aws_eks_cluster" "securebank" {
  name     = var.cluster_name
  role_arn = var.cluster_role_arn
  version  = var.kubernetes_version

  vpc_config {
    subnet_ids              = concat(var.public_subnet_ids, var.private_subnet_ids)
    endpoint_private_access = true
    endpoint_public_access  = var.enable_public_access
    public_access_cidrs     = var.public_access_cidrs
    security_group_ids      = var.security_group_ids
  }

  # Control plane logging
  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  tags = {
    Name        = "${var.name_prefix}-eks-cluster"
    Environment = var.environment
  }
}

# ── EKS Managed Node Group ──────────────────────────────
resource "aws_eks_node_group" "securebank" {
  cluster_name    = aws_eks_cluster.securebank.name
  node_group_name = "${var.name_prefix}-worker-group"
  node_role_arn   = var.node_role_arn
  subnet_ids      = var.private_subnet_ids # Workers in private subnets

  scaling_config {
    desired_size = var.desired_capacity
    max_size     = var.max_size
    min_size     = var.min_size
  }

  instance_types = var.instance_types
  capacity_type  = var.capacity_type
  disk_size      = var.disk_size

  update_config {
    max_unavailable = 1
  }

  tags = {
    Name        = "${var.name_prefix}-worker-group"
    Environment = var.environment
  }

  depends_on = [aws_eks_cluster.securebank]
}
