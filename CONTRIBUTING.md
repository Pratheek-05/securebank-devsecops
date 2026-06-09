# Contributing to SecureBank

Thank you for contributing to SecureBank! Please follow these guidelines.

## Branch Naming

Use descriptive branch names with prefixes:

- `feature/` — New features (e.g., `feature/add-auth-endpoint`)
- `fix/` — Bug fixes (e.g., `fix/health-check-timeout`)
- `infra/` — Infrastructure changes (e.g., `infra/add-waf`)
- `docs/` — Documentation updates (e.g., `docs/update-setup-guide`)

## Pull Request Process

1. Create a feature branch from `main`
2. Make your changes with clear, atomic commits
3. Ensure all CI checks pass (tests, security scans, Terraform validate)
4. Request a code review from at least one team member
5. Squash merge into `main`

## Commit Conventions

Use [Conventional Commits](https://www.conventionalcommits.org/):

```
feat: add /healthz endpoint
fix: correct IAM policy ARN format
infra: add private subnets for EKS workers
docs: update README with setup instructions
security: add Falco rule for shell detection
```

## Code Standards

### Python
- Follow PEP 8 style guidelines
- Add type hints where practical
- Include docstrings for public functions
- Pin dependency versions in `requirements.txt`

### Terraform
- Use consistent naming: `${var.name_prefix}-<resource>`
- Add descriptions to all variables and outputs
- Include validation blocks where appropriate
- Tag all resources with `Name` and `Environment`

### Helm
- Parameterize everything in `values.yaml`
- Use template helpers for names and labels
- Include security contexts on all pods and containers

## Security

- Never commit secrets, credentials, or API keys
- Use AWS Secrets Manager for sensitive configuration
- All container images must pass Trivy CRITICAL/HIGH scans
- Follow the principle of least privilege for IAM roles
