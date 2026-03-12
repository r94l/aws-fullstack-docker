# 🚀 Production-Grade Container Deployment on AWS — Without Kubernetes

> **Proving that not every production workload needs Kubernetes.**
> This project demonstrates how startups and growing teams can run secure, scalable, fully automated containerized applications on AWS using Docker Compose cutting infrastructure costs while maintaining production-grade DevOps standards

[![CI Pipeline](https://img.shields.io/github/actions/workflow/status/r94l/aws-fullstack-devops/ci.yml?branch=main&label=CI&logo=github-actions&logoColor=white)](https://github.com/r94l/aws-fullstack-devops/actions)
[![CD Pipeline](https://img.shields.io/github/actions/workflow/status/r94l/aws-fullstack-devops/cd.yml?branch=main&label=CD&logo=github-actions&logoColor=white)](https://github.com/r94l/aws-fullstack-devops/actions)
[![Terraform](https://img.shields.io/badge/IaC-Terraform-7B42BC?logo=terraform&logoColor=white)](https://www.terraform.io/)
[![AWS](https://img.shields.io/badge/Cloud-AWS-FF9900?logo=amazonaws&logoColor=white)](https://aws.amazon.com/)
[![Docker](https://img.shields.io/badge/Runtime-Docker-2496ED?logo=docker&logoColor=white)](https://www.docker.com/)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

---

## 📌 The Philosophy Behind This Project

The cloud-native community often defaults to Kubernetes for any containerized workload. While Kubernetes is a powerful orchestration platform, it introduces significant operational complexity, cost and a steep learning curve. Challenges that are unnecessary for many real-world workloads.

**This project makes the case that:**

- A well-architected Docker Compose setup running on a single EC2 instance can serve most early-stage and mid-size applications reliably
- Production-grade DevOps practices (CI/CD, IaC, secrets management, health checks, zero-downtime deployments) are not exclusive to Kubernetes
- Infrastructure spend can be significantly reduced without compromising on security, automation, or reliability
- The architecture is deliberately designed to be **Kubernetes-ready** when the time comes, the same container images, the same CI/CD pipeline, the same secrets patterns all transfer directly

> **When you are ready to scale** — swap Docker Compose for a managed Kubernetes service (EKS, GKE, AKS), attach your existing ECR images and migrate your secrets to match. The hard work is already done.

---

## 🏗️ Architecture Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                        Developer Workflow                       │
│                                                                 │
│   feature/* branch                                              │
│        │                                                        │
│        ▼                                                        │
│   Pull Request ──► CI Pipeline (GitHub-hosted runner)           │
│        │               ├── Lint & Test Backend                  │
│        │               ├── Lint & Test Frontend                 │
│        │               └── Build & Validate Docker Images       │
│        │                                                        │
│   Merge to main                                                 │
│        │                                                        │
│        ▼                                                        │
│   CD Pipeline ──► Build Images ──► Push to ECR                  │
│        │                                                        │
│        └──► SSH into EC2 ──► Pull Images ──► docker compose up  │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│                        AWS Infrastructure                       │
│                                                                 │
│   Route 53 / nip.io (DNS)                                       │
│        │                                                        │
│        ▼                                                        │
│   EC2 t3.micro (Ubuntu 24.04)                                   │
│   ┌─────────────────────────────────────────────────────┐       │
│   │  Docker Compose Orchestration                       │       │
│   │                                                     │       │  
│   │  ┌──────────┐    ┌──────────┐    ┌──────────┐       │       │
│   │  │  Nginx   │───►│ Frontend │    │  Backend │       │       │
│   │  │ :80/:443 │    │  React   │    │ Node.js  │       │       │
│   │  │  Proxy   │───►│  :80     │    │  :3000   │       │       │
│   │  └──────────┘    └──────────┘    └────┬─────┘       │       │
│   │                                       │             │       │
│   │                                  ┌────▼─────┐       │       │
│   │                                  │PostgreSQL│       │       │
│   │                                  │  :5432   │       │       │
│   │                                  └──────────┘       │       │
│   └─────────────────────────────────────────────────────┘       │
│                                                                 │
│   ┌──────────────┐  ┌──────────────┐  ┌──────────────┐          │
│   │     ECR      │  │   Secrets    │  │  S3 + DynamoD│          │
│   │  (Images)    │  │   Manager    │  │ (Terraform   │          │
│   │              │  │  (Secrets)   │  │   State)     │          │
│   └──────────────┘  └──────────────┘  └──────────────┘          │
└─────────────────────────────────────────────────────────────────┘
```

---

## 🛠️ Tech Stack

| Category | Technology | Purpose |
|---|---|---|
| **Application** | React, Node.js, PostgreSQL | Full stack three-tier web application |
| **Containerisation** | Docker, Docker Compose | Container runtime and orchestration |
| **Reverse Proxy** | Nginx | SSL termination, traffic routing |
| **SSL** | Let's Encrypt (Certbot) | Free HTTPS certificates |
| **CI/CD** | GitHub Actions | Automated testing and deployment |
| **Container Registry** | AWS ECR | Private Docker image storage |
| **Infrastructure** | Terraform | Infrastructure as Code |
| **Remote State** | AWS S3 + DynamoDB | Terraform state storage and locking |
| **Secrets** | AWS Secrets Manager | Runtime secrets management |
| **Compute** | AWS EC2 (t3.micro) | Application hosting |
| **DNS** | nip.io / Route 53 | Domain resolution |
| **OS** | Ubuntu 24.04 LTS | Host operating system |

---

## 📁 Project Structure

```
aws-fullstack-devops/
├── .github/
│   └── workflows/
│       ├── ci.yml                 # CI — runs on every push and PR
│       └── cd.yml                 # CD — runs on merge to main only
│
├── backend/
│   ├── Dockerfile                 # 4-stage multi-stage build
│   ├── src/
│   │   └── prisma/
│   │       └── schema.prisma      # Database schema
│   └── (Node.js + Prisma source)
│
├── frontend/
│   ├── Dockerfile                 # 4-stage multi-stage build
│   ├── nginx.conf                 # React SPA routing config
│   └── (React source)
│
├── nginx/
│   └── nginx.conf                 # Main reverse proxy config
│
├── terraform/
│   ├── backend.tf                 # S3 remote state configuration
│   ├── main.tf                    # EC2, IAM, security groups
│   ├── variables.tf               # Input variable definitions
│   ├── outputs.tf                 # EC2 IP, SSH command, domain
│   └── userdata.sh                # EC2 bootstrap script
│
├── scripts/
│   └── start.sh                   # Secrets fetch + deployment script
│
├── docker-compose.yml             # Production orchestration
├── .env.example                   # Environment variable documentation
└── .gitignore
```

---

## 🔐 Security and Secrets Management

This project follows a **zero secrets on disk** approach. No `.env` files exist on the production server.

### Secrets Architecture

```
┌─────────────────────────────────────────────────────────┐
│                   Secrets by Location                   │
│                                                         │
│  GitHub Secrets          AWS Secrets Manager            │
│  ─────────────           ─────────────────────          │
│  AWS_ACCESS_KEY_ID       POSTGRES_USER                  │
│  AWS_SECRET_ACCESS_KEY   POSTGRES_PASSWORD              │
│  AWS_REGION              POSTGRES_DB                    │
│  ECR_REGISTRY            JWT_SECRET                     │
│  ECR_REPOSITORY_*                                       │
│  EC2_HOST                                               │
│  EC2_USER                                               │
│  EC2_SSH_KEY                                            │
│                                                         │
│  Used by: GitHub Actions  Used by: EC2 at runtime       │
│  during CI/CD pipeline    via IAM role (no credentials) │
└─────────────────────────────────────────────────────────┘
```

### Key Security Practices

- **IAM Least Privilege** — GitHub Actions IAM user has only ECR push permissions. EC2 IAM role has only ECR pull and Secrets Manager read permissions
- **No hardcoded credentials** — EC2 fetches secrets at runtime via IAM role, no AWS credentials stored on the server
- **Non-root containers** — all containers run as dedicated non-root users
- **Encrypted storage** — EC2 root volume encrypted at rest (gp3)
- **Private container registry** — images stored in private ECR, not Docker Hub
- **Security group restrictions** — SSH access restricted, only ports 80 and 443 open publicly

---

## 🐳 Docker Best Practices

Every Dockerfile in this project implements the following production standards:

### 4-Stage Multi-Stage Build Pattern

```dockerfile
# Stage 1: Base — common OS, workdir, package files
FROM node:18-slim AS base

# Stage 2: Deps — production dependencies only
FROM base AS deps
RUN npm ci --only=production

# Stage 3: Builder — all dependencies + compile/build
FROM base AS builder
RUN npm ci
RUN npm run build

# Stage 4: Production — lean final image
FROM node:18-slim AS production
COPY --from=deps /app/node_modules ./node_modules
COPY --from=builder /app/dist ./dist
```

| Practice | Implementation | Benefit |
|---|---|---|
| Multi-stage builds | 4-stage pattern | Final image ~120MB vs ~1.2GB naive |
| Non-root user | `groupadd` + `useradd` | Limits blast radius of container compromise |
| Pinned base images | `node:18-slim` | Reproducible, no surprise breaking changes |
| Layer caching | `COPY package*.json` before source | Dependency reinstall only when package.json changes |
| `npm ci` over `npm install` | Strict lockfile install | Deterministic, reproducible builds |
| Health checks | TCP port check | Docker knows container readiness, not just running status |
| Minimal base image | `node:18-slim`, `nginx:alpine` | Smaller attack surface, faster pulls |
| Production deps only | `--only=production` in deps stage | Dev tools never reach production image |

---

## ⚙️ CI/CD Pipeline

### Branching Strategy

```
feature/* ──► develop ──► main
                           │
                           └──► CD triggers deployment
```

### CI Pipeline (Every Push + Every PR)

```yaml
Jobs:
  test-backend    ─► Node.js tests with real PostgreSQL container
  test-frontend   ─► React tests
  build-images    ─► Docker build validation (no push)
                     └── runs only if tests pass
```

### CD Pipeline (Merge to Main Only)

```yaml
Trigger: CI Pipeline must complete successfully first

Jobs:
  build-and-push  ─► Build images ──► Push to ECR (tagged with git SHA)
  deploy          ─► SSH into EC2
                     └── git reset --hard origin/main
                     └── fetch secrets from AWS Secrets Manager
                     └── docker compose pull
                     └── docker compose up -d --remove-orphans
                     └── docker image prune (disk cleanup)
```

### Image Tagging Strategy

```
Every deployment produces two tags:
  - :abc1234   ← short git SHA (immutable, traceable)
  - :latest    ← always points to most recent build
```

### ECR Lifecycle Policy

Automatically retains only the last 5 images per repository, preventing storage cost accumulation.

---

## 🏛️ Infrastructure as Code

All AWS infrastructure is managed via Terraform with no manual console configuration.

### Resources Managed by Terraform

| Resource | Purpose |
|---|---|
| `aws_instance` | EC2 t3.micro with Ubuntu 24.04 |
| `aws_security_group` | Firewall rules (ports 22, 80, 443) |
| `aws_iam_role` | EC2 instance role |
| `aws_iam_role_policy_attachment` | ECR read + Secrets Manager permissions |
| `aws_iam_instance_profile` | Attaches role to EC2 |
| `aws_ecr_lifecycle_policy` | Auto-cleanup of old images |

### Remote State

```
State file:    s3://conduit-terraform-state-ACCOUNT_ID/production/terraform.tfstate
State locking: DynamoDB table conduit-terraform-locks
Encryption:    AES-256 server-side encryption
Versioning:    Enabled (full history of state changes)
```

### Deploy Infrastructure

```bash
cd terraform
terraform init
terraform validate
terraform fmt
terraform plan
terraform apply
```

### Destroy Everything

```bash
terraform destroy
# All AWS resources terminated, zero ongoing cost
```

---

## 🚀 Getting Started

### Prerequisites

| Tool | Version | Purpose |
|---|---|---|
| Docker | 24.x+ | Container runtime |
| Docker Compose | v2+ | Local orchestration |
| Terraform | 1.6+ | Infrastructure provisioning |
| AWS CLI | v2 | AWS authentication |
| Git | any | Version control |

### Local Development

```bash
# Clone the repository
git clone https://github.com/r94l/aws-fullstack-docker.git
cd aws-fullstack-docker

# Copy environment template
cp .env.example .env
# Fill in your local values in .env

# Start all services locally
docker compose up -d

# View logs
docker compose logs -f

# Stop all services
docker compose down
```

### Deploy to AWS

```bash
# Step 1 — Configure AWS credentials
aws configure

# Step 2 — Create S3 bucket and DynamoDB table for Terraform state
# (see terraform/backend.tf for bucket name)

# Step 3 — Create ECR repositories
# conduit-frontend
# conduit-backend

# Step 4 — Store secrets in AWS Secrets Manager
# Secret name: conduit/production
# Keys: POSTGRES_USER, POSTGRES_PASSWORD, POSTGRES_DB, JWT_SECRET

# Step 5 — Add GitHub Secrets
# AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, AWS_REGION
# ECR_REGISTRY, ECR_REPOSITORY_FRONTEND, ECR_REPOSITORY_BACKEND
# EC2_HOST, EC2_USER, EC2_SSH_KEY

# Step 6 — Provision infrastructure
cd terraform
terraform init && terraform apply

# Step 7 — Clone repo on EC2 (one time only)
ssh -i keypair.pem ubuntu@YOUR_EC2_IP
git clone https://github.com/r94l/aws-fullstack-docker.git /home/ubuntu/aws-fullstack-docker

# Step 8 — Push to main to trigger first deployment
git push origin main
```

---

## 🌍 DNS and SSL

### Current Setup (Demo Environment)

```
DNS:  nip.io (free, zero configuration wildcard DNS)
SSL:  Let's Encrypt via Certbot (free, auto-renewing)
URL:  https://YOUR_EC2_IP.nip.io
```

### Production Upgrade Path

When moving to a production environment with real users:

```
1. Register a domain in AWS Route 53
   e.g. myapp.com (~$12/year)

2. Create an A record in Route 53:
   myapp.com → EC2 Elastic IP

3. Replace Let's Encrypt with AWS Certificate Manager:
   - Free SSL certificates managed by AWS
   - Auto-renewing, no Certbot needed
   - Integrates with ALB and CloudFront

4. Optionally add an Application Load Balancer:
   Route 53 → ALB → EC2
   Enables future multi-instance scaling
```

### SSL Certificate Renewal

```bash
# Certificates auto-renew via cron
sudo crontab -l
# 0 12 * * * /usr/bin/certbot renew --quiet && docker restart conduit_nginx
```

---

## 📊 Cost Analysis

### This Project (Demo)

| Service | Usage | Monthly Cost |
|---|---|---|
| EC2 t3.micro | 750 hrs/month (free tier) | $0.00 |
| ECR Storage | ~300MB (free tier 500MB) | $0.00 |
| S3 State Storage | <1MB (free tier 5GB) | $0.00 |
| DynamoDB | Minimal (free tier) | $0.00 |
| Secrets Manager | 4 secrets | ~$0.16 |
| Data Transfer | Minimal | $0.00 |
| **Total** | | **~$0.16/month** |

### vs. Kubernetes (EKS)

| Setup | Monthly Cost | Complexity |
|---|---|---|
| This project (EC2 + Docker Compose) | ~$0–$10 | Low |
| EKS minimum (1 cluster + 2 nodes) | ~$150–$300 | High |
| EKS production (HA, multi-AZ) | ~$500–$1000+ | Very High |

> **For early-stage products, side projects, and startups not yet at scale — Docker Compose on EC2 is not a compromise. It is the right tool for the job.**

---

## 🔮 Production Upgrade Path

This project is deliberately architected for future growth. Here is the upgrade path when scale demands it:

```
Current (Docker Compose)          Future (Kubernetes)
─────────────────────────         ──────────────────────────
EC2 t3.micro                 ──►  EKS cluster (managed K8s)
docker-compose.yml           ──►  Kubernetes manifests / Helm
ECR images (unchanged)       ──►  Same ECR images (no rebuild)
AWS Secrets Manager          ──►  External Secrets Operator
GitHub Actions CI/CD         ──►  Same pipelines + kubectl
Nginx reverse proxy          ──►  Nginx Ingress Controller
Let's Encrypt                ──►  AWS Certificate Manager
Single instance              ──►  Multi-node, multi-AZ
```

The container images, secrets patterns, CI/CD pipelines and ECR repositories all remain unchanged. The migration is an infrastructure concern only.

---

## ✅ DevOps Best Practices Implemented

### Containerisation
- [x] Multi-stage Docker builds (4-stage pattern)
- [x] Non-root container users
- [x] Pinned base image versions
- [x] Docker layer caching optimisation
- [x] Container health checks
- [x] Resource limits (CPU and memory) on all containers
- [x] Named volumes for data persistence
- [x] Custom bridge network (container isolation)
- [x] Restart policies (`unless-stopped`)

### CI/CD
- [x] CI runs on every push and pull request
- [x] CD triggers only after CI passes on main
- [x] Branch protection rules enforced
- [x] Docker layer caching in GitHub Actions (faster builds)
- [x] Image tagged with git SHA (full traceability)
- [x] `git reset --hard` on deploy (prevents config drift)
- [x] Automated disk cleanup post-deployment

### Infrastructure
- [x] 100% infrastructure defined as Terraform code
- [x] Remote state in S3 with versioning enabled
- [x] DynamoDB state locking (prevents concurrent applies)
- [x] IAM least privilege (separate roles for CI and runtime)
- [x] EC2 volume encryption at rest
- [x] ECR lifecycle policies (cost control)
- [x] EC2 swap space (stability on t3.micro)
- [x] Userdata bootstrap script

### Security
- [x] Zero secrets on disk (AWS Secrets Manager + GitHub Secrets)
- [x] IAM role-based access (no credentials on EC2)
- [x] Private container registry (ECR)
- [x] HTTPS enforced (Let's Encrypt)
- [x] HTTP to HTTPS redirect
- [x] Security group with minimal open ports
- [x] Non-root container processes

### Observability
- [x] Container health checks with configurable thresholds
- [x] AWS CloudWatch log groups per service
- [x] Structured deployment logs in CI/CD output
- [x] `docker ps` status check post-deployment

---

## 🗺️ Architecture Decision Records

### Why Docker Compose over Kubernetes?

Kubernetes is the right choice when you need:
- Hundreds of microservices
- Multi-region deployments
- Autoscaling based on custom metrics
- Rolling updates across dozens of replicas

For applications that do not yet have these requirements, Kubernetes adds:
- A managed control plane cost (~$75/month on EKS just for the cluster)
- Node group costs (minimum 2-3 nodes recommended)
- Operational overhead (upgrades, node management, networking)
- A steep learning curve for the entire team

Docker Compose on a well-sized EC2 instance handles thousands of concurrent users reliably. Startups like Instagram, GitHub, and Shopify ran on single servers far longer than most engineers realise.

### Why AWS Secrets Manager over .env files?

- Secrets never touch disk on the production server
- IAM role-based access means no credential rotation needed
- Full audit trail of secret access
- Centralised rotation when credentials need to change
- Scales directly to Kubernetes via External Secrets Operator

### Why ECR over Docker Hub?

- Private by default — images never accidentally public
- IAM-integrated authentication (no separate credentials)
- Same AWS region as EC2 (faster pulls, no egress charges)
- Lifecycle policies prevent unbounded storage costs
- Vulnerability scanning on push

### Why Terraform over manual console setup?

- Every infrastructure decision is documented in code
- Reproducible in any AWS account or region in minutes
- State file provides drift detection
- `terraform destroy` guarantees complete cleanup (no forgotten resources)
- Reviewable via pull requests like application code

---

## 🔧 Troubleshooting

### Containers not starting

```bash
# Check container status
docker ps -a

# View logs for specific service
docker logs conduit_backend --tail 50
docker logs conduit_frontend --tail 50
docker logs conduit_db --tail 50
docker logs conduit_nginx --tail 50

# Check health check details
docker inspect conduit_backend | grep -A 15 '"Healthcheck"'
```

### Secrets not loading

```bash
# Verify IAM role can access Secrets Manager
aws secretsmanager get-secret-value \
  --secret-id conduit/production \
  --region us-east-1 \
  --query SecretString \
  --output text
```

### Deployment not picking up latest code

```bash
# Force sync with GitHub
git fetch origin
git reset --hard origin/main
```

### Disk space issues

```bash
# Check disk usage
df -h

# Clean up unused Docker resources
docker system prune -a -f --filter "until=24h"
```

### SSL certificate renewal

```bash
sudo certbot renew --dry-run
docker restart conduit_nginx
```

---

## 🧹 Cleanup

```bash
# Destroy all AWS infrastructure
cd terraform
terraform destroy

# Confirm all resources are terminated
# EC2 instance, security group, IAM role, ECR lifecycle policies
# S3 bucket and DynamoDB table must be manually deleted
# (Terraform protects these to prevent accidental state loss)
```

---

## 📈 Future Enhancements

- [ ] **Watchtower** — automatic container updates when new images are pushed
- [ ] **Prometheus + Grafana** — metrics and dashboards
- [ ] **Alerting** — CloudWatch alarms for CPU, memory, and health check failures
- [ ] **Multi-AZ** — add a second EC2 with a load balancer for high availability
- [ ] **RDS** — migrate PostgreSQL to managed AWS RDS for automated backups and failover
- [ ] **CDN** — CloudFront in front of the frontend for global performance
- [ ] **Custom Domain** — Route 53 domain with AWS Certificate Manager SSL
- [ ] **Kubernetes migration** — EKS with the same ECR images when scale demands it

---

## 📚 References

- [The Twelve-Factor App](https://12factor.net/) — methodology this project follows
- [Docker Multi-Stage Builds](https://docs.docker.com/build/building/multi-stage/)
- [AWS Secrets Manager Best Practices](https://docs.aws.amazon.com/secretsmanager/latest/userguide/best-practices.html)
- [Terraform S3 Backend](https://developer.hashicorp.com/terraform/language/settings/backends/s3)
- [GitHub Actions Security Hardening](https://docs.github.com/en/actions/security-guides/security-hardening-for-github-actions)

---

## 👤 Author

Built by **[Raheem Shonubi]** — DevOps and Cloud Engineer

[![LinkedIn](https://img.shields.io/badge/LinkedIn-Connect-0077B5?logo=linkedin)](https://linkedin.com/in/abdulraheem-shonubi)
[![GitHub](https://img.shields.io/badge/GitHub-Follow-181717?logo=github)](https://github.com/r94l)

---

## 📄 License

This project is licensed under the MIT License. See [LICENSE](LICENSE) for details.

---

<div align="center">

**⭐ If this project helped you, consider giving it a star**

*Demonstrating that production-grade DevOps does not require over-engineered infrastructure*

</div>
