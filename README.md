# Conduit DevOps Project

## Architecture
[add diagram here]

## Tech Stack
- Frontend: React
- Backend: Node.js + Express + Prisma
- Database: PostgreSQL
- Reverse Proxy: Nginx + SSL
- Containerization: Docker + Docker Compose
- CI/CD: GitHub Actions
- Infrastructure: Terraform
- Cloud: AWS (EC2, ECR, Secrets Manager, S3)

## CI/CD Pipeline
- CI runs on every push and PR
- CD triggers only when CI passes on main
- Images pushed to ECR
- Auto deployed to EC2

## Infrastructure
- EC2 t3.micro
- S3 remote backend for Terraform state
- DynamoDB state locking
- ECR lifecycle policies (keep last 5 images)
- AWS Secrets Manager for runtime secrets

## Local Development
git clone https://github.com/YOURUSERNAME/conduit-devops.git
cd conduit-devops
cp .env.example .env
docker compose up -d

## Live Demo
https://16.171.67.94.nip.io
