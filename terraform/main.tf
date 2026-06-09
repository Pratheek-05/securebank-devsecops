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

# ── ECR ──────────────────────────────────────────────────
resource "aws_ecr_repository" "securebank" {
  name                 = var.ecr_repository_name
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "AES256"
  }

  tags = {
    Name        = var.ecr_repository_name
    Environment = var.environment
  }
}

resource "aws_ecr_lifecycle_policy" "securebank" {
  repository = aws_ecr_repository.securebank.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Expire untagged images after 30 days"
        selection = {
          tagStatus   = "untagged"
          countType   = "sinceImagePushed"
          countUnit   = "days"
          countNumber = 30
        }
        action = {
          type = "expire"
        }
      },
      {
        rulePriority = 2
        description  = "Keep only the last 50 tagged images"
        selection = {
          tagStatus   = "tagged"
          tagPrefixList = ["sha-"]
          countType   = "imageCountMoreThan"
          countNumber = 50
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}
