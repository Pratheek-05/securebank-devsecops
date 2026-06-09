output "secret_arn" {
  value       = aws_secretsmanager_secret.securebank_app.arn
  description = "ARN of the SecureBank Secrets Manager secret"
}

output "secret_name" {
  value       = aws_secretsmanager_secret.securebank_app.name
  description = "Name of the SecureBank Secrets Manager secret"
}
