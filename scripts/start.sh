#!/bin/bash

# Exit immediately if any command fails
set -e
echo "  Fetching secrets from AWS Secrets Manager..."

# Fetch secrets from AWS Secrets Manager
SECRETS=$(aws secretsmanager get-secret-value \
  --secret-id conduit/production \
  --region eu-north-1 \
  --query SecretString \
  --output text)

# Parse and export each secret as environment variable
export POSTGRES_USER=$(echo $SECRETS | python3 -c "import sys,json; print(json.load(sys.stdin)['POSTGRES_USER'])")
export POSTGRES_PASSWORD=$(echo $SECRETS | python3 -c "import sys,json; print(json.load(sys.stdin)['POSTGRES_PASSWORD'])")
export POSTGRES_DB=$(echo $SECRETS | python3 -c "import sys,json; print(json.load(sys.stdin)['POSTGRES_DB'])")
export JWT_SECRET=$(echo $SECRETS | python3 -c "import sys,json; print(json.load(sys.stdin)['JWT_SECRET'])")

echo " Secrets loaded successfully"

echo "  Logging into AWS ECR..."

# Login to ECR
aws ecr get-login-password --region ${AWS_REGION} | \
  docker login --username AWS --password-stdin ${ECR_REGISTRY}

echo " ECR login successful"

echo "  Pulling latest images from ECR..."

# Pull latest images
docker compose pull

echo " Images pulled successfully"

echo "  Starting containers..."

# Start containers
docker compose up -d --remove-orphans

echo " Containers started successfully"

echo "  Cleaning up old images..."

# Remove dangling images to free up disk space
docker image prune -f

echo " Cleanup complete"

echo "  Checking container health..."

# Wait for containers to be healthy
sleep 10

docker compose ps

echo " Deployment complete!"