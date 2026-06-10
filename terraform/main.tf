terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = var.name_prefix
      Environment = var.environment
      ManagedBy   = "terraform"
    }
  }
}

# ── Networking ───────────────────────────────────────────
module "network" {
  source = "./modules/network"

  name_prefix          = var.name_prefix
  environment          = var.environment
  cluster_name         = var.cluster_name
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
}

# ── IAM ──────────────────────────────────────────────────
module "iam" {
  source = "./modules/iam"

  name_prefix = var.name_prefix
  environment = var.environment
}

# ── EKS ──────────────────────────────────────────────────
module "eks" {
  source = "./modules/eks"

  name_prefix        = var.name_prefix
  environment        = var.environment
  cluster_name       = var.cluster_name
  cluster_role_arn   = module.iam.cluster_role_arn
  node_role_arn      = module.iam.node_role_arn
  public_subnet_ids  = module.network.public_subnet_ids
  private_subnet_ids = module.network.private_subnet_ids
  desired_capacity   = var.node_desired_capacity
  max_size           = var.node_max_size
  min_size           = var.node_min_size
  public_access_cidrs = var.public_access_cidrs
}

# ── Secrets ──────────────────────────────────────────────
module "secrets" {
  source = "./modules/secrets"

  name_prefix = var.name_prefix
  environment = var.environment
}

# ── ECR (managed by CI pipeline, referenced here) ───────
data "aws_ecr_repository" "securebank" {
  name = var.ecr_repository_name
}
