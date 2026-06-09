variable "aws_region" {
  description = "AWS region for SecureBank infrastructure"
  type        = string
  default     = "us-east-1"
}

variable "name_prefix" {
  description = "Prefix used for SecureBank resources"
  type        = string
  default     = "securebank"
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "production"

  validation {
    condition     = contains(["development", "staging", "production"], var.environment)
    error_message = "Environment must be one of: development, staging, production."
  }
}

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
  default     = "securebank-cluster"
}

variable "ecr_repository_name" {
  description = "Amazon ECR repository name"
  type        = string
  default     = "securebank"
}

variable "vpc_cidr" {
  description = "CIDR block for the SecureBank VPC"
  type        = string
  default     = "10.0.0.0/16"

  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "vpc_cidr must be a valid CIDR block."
  }
}

variable "public_subnet_cidrs" {
  description = "Public subnets for load balancers and NAT gateway"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "Private subnets for EKS worker nodes"
  type        = list(string)
  default     = ["10.0.10.0/24", "10.0.11.0/24"]
}

variable "public_access_cidrs" {
  description = "CIDR blocks allowed to access the EKS public API endpoint. Set to your office/VPN IP for security."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "node_desired_capacity" {
  description = "Desired number of EKS worker nodes"
  type        = number
  default     = 2

  validation {
    condition     = var.node_desired_capacity >= 1
    error_message = "node_desired_capacity must be at least 1."
  }
}

variable "node_max_size" {
  description = "Maximum number of EKS worker nodes"
  type        = number
  default     = 4
}

variable "node_min_size" {
  description = "Minimum number of EKS worker nodes"
  type        = number
  default     = 2
}
