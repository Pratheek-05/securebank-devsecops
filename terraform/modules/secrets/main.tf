resource "aws_secretsmanager_secret" "securebank_app" {
  name        = "${var.name_prefix}-app-secret"
  description = "SecureBank application secret managed in AWS Secrets Manager"

  tags = {
    Name        = "${var.name_prefix}-app-secret"
    Environment = var.environment
  }
}
