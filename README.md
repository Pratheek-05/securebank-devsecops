# SecureBank DevSecOps Platform

[![CI/CD](https://github.com/Pratheek-05/securebank-devsecops/actions/workflows/ci-cd.yml/badge.svg)](https://github.com/Pratheek-05/securebank-devsecops/actions/workflows/ci-cd.yml)

SecureBank is a cloud-native DevSecOps reference platform demonstrating enterprise security automation, infrastructure as code, continuous delivery, and runtime observability on AWS.

## Architecture

```
Developer → GitHub → GitHub Actions CI/CD Pipeline
                         │
                    ┌─────┴──────┐
                    │  Security  │
                    │   Scans    │
                    ├────────────┤
                    │ • Semgrep  │ (SAST)
                    │ • Trivy FS │ (Dependency scan)
                    └─────┬──────┘
                          │
                    ┌─────┴──────┐
                    │  Docker    │
                    │  Build &   │
                    │  Scan      │
                    ├────────────┤
                    │ • Trivy    │ (Container scan)
                    │ • ECR Push │
                    └─────┬──────┘
                          │
                    ┌─────┴──────┐
                    │ Terraform  │
                    │ Plan/Apply │
                    └─────┬──────┘
                          │
              ┌───────────┴───────────┐
              │      AWS EKS          │
              │  ┌─────────────────┐  │
              │  │  ArgoCD (GitOps)│  │
              │  └───────┬─────────┘  │
              │          │            │
              │  ┌───────┴─────────┐  │
              │  │  Helm Release   │  │
              │  │  (SecureBank)   │  │
              │  └───────┬─────────┘  │
              │          │            │
              │  ┌───────┴─────────┐  │
              │  │  Monitoring     │  │
              │  │  Prometheus     │  │
              │  │  Grafana        │  │
              │  └─────────────────┘  │
              │                       │
              │  ┌─────────────────┐  │
              │  │  Runtime Sec    │  │
              │  │  Falco + Wazuh  │  │
              │  └─────────────────┘  │
              └───────────────────────┘
```

## Tech Stack

| Category | Tool | Purpose |
|----------|------|---------|
| Cloud | AWS (EKS, ECR, Secrets Manager) | Infrastructure platform |
| IaC | Terraform | Infrastructure provisioning |
| Container | Docker | Application packaging |
| Application | Python Flask | Microservice framework |
| CI/CD | GitHub Actions | Pipeline automation |
| GitOps | ArgoCD | Continuous delivery |
| Packaging | Helm | Kubernetes deployment |
| Monitoring | Prometheus + Grafana | Metrics and dashboards |
| SAST | Semgrep | Static code analysis |
| Container Scanning | Trivy | Vulnerability scanning |
| Runtime Security | Falco + Wazuh | Threat detection and IDS |

## Prerequisites

- **AWS CLI** v2 — configured with appropriate credentials
- **Terraform** >= 1.5.0
- **kubectl** — matching your EKS Kubernetes version
- **Helm** >= 3.0
- **Docker** — for local builds
- **Python** >= 3.12 — for local development

## Repository Layout

```
├── application/           Flask microservice, Dockerfile, tests
├── terraform/             IaC for AWS (VPC, EKS, IAM, ECR, Secrets)
│   └── modules/           Reusable Terraform modules
│       ├── network/       VPC, subnets, NAT gateway, route tables
│       ├── eks/           EKS cluster and managed node group
│       ├── iam/           IAM roles and policy attachments
│       └── secrets/       AWS Secrets Manager
├── helm/securebank/       Helm chart for Kubernetes deployment
│   └── templates/         Deployment, Service, HPA, PDB, NetworkPolicy
├── argocd/                GitOps application definitions
├── monitoring/            Prometheus, Grafana, and alerting config
├── security/              Semgrep rules, Falco rules, Trivy scripts
└── .github/workflows/     CI/CD pipeline definitions
```

## Getting Started

### 1. Configure AWS

```bash
# Set up AWS credentials (use SSO or IAM role)
aws configure

# Create Terraform state backend resources
aws s3api create-bucket \
  --bucket securebank-terraform-state-<ACCOUNT_ID> \
  --region us-east-1

aws dynamodb create-table \
  --table-name securebank-terraform-locks \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST
```

### 2. Deploy Infrastructure

```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your values

terraform init
terraform plan
terraform apply
```

### 3. Configure kubectl

```bash
aws eks update-kubeconfig --name securebank-cluster --region us-east-1
```

### 4. Deploy ArgoCD

```bash
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl apply -f argocd/
```

### 5. Verify Deployment

```bash
kubectl get pods -n securebank
kubectl get svc -n securebank
```

## Local Development

```bash
cd application
python -m venv .venv
source .venv/bin/activate  # or .venv\Scripts\activate on Windows
pip install -r requirements.txt
python app.py

# Run tests
pip install pytest
python -m pytest tests/ -v
```

## CI/CD Pipeline

The pipeline runs automatically on push/PR to `main`:

1. **Unit Tests** — Python pytest suite
2. **Semgrep** — Static application security testing
3. **Trivy Filesystem** — Dependency vulnerability scanning (SARIF → GitHub Security)
4. **Docker Build & Scan** — Container image build + Trivy scan
5. **Terraform Plan** — Infrastructure change preview
6. **Terraform Apply** — Infrastructure deployment (main branch, manual approval)

### Required GitHub Secrets

| Secret | Description |
|--------|-------------|
| `AWS_ROLE_ARN` | IAM role ARN for GitHub Actions to assume via OIDC |

## Security

- **SAST**: Semgrep scans for hardcoded secrets, command injection, debug mode, and SQL injection
- **Container Scanning**: Trivy scans filesystem and Docker images for CRITICAL/HIGH vulnerabilities
- **Runtime**: Falco monitors for shell spawning, unexpected network access, and sensitive file reads
- **Network**: Kubernetes NetworkPolicy restricts pod traffic to port 5000 ingress and DNS/HTTPS egress
- **Container Hardening**: Non-root user, read-only filesystem, all capabilities dropped
- **Infrastructure**: Private subnets for worker nodes, NAT gateway for outbound, encrypted ECR

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## License

This project is licensed under the MIT License — see [LICENSE](LICENSE) for details.
