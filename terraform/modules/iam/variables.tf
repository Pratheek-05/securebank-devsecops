variable "name_prefix" {
  description = "Prefix used for IAM role names"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "production"
}
