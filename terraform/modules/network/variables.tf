variable "name_prefix" {
  description = "Prefix to identify SecureBank resources"
  type        = string
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
  description = "EKS cluster name, used for subnet tagging"
  type        = string
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
  description = "Public subnets for the SecureBank cluster (load balancers)"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "Private subnets for the SecureBank EKS worker nodes"
  type        = list(string)
  default     = ["10.0.10.0/24", "10.0.11.0/24"]
}
