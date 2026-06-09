variable "name_prefix" {
  description = "Prefix used for Secrets Manager names"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "production"
}
