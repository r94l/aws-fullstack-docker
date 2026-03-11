#!/bin/bash

# Log all output for debugging
exec > /var/log/userdata.log 2>&1

echo "Starting userdata script..."

# Update system packages
apt-get update -y
apt-get upgrade -y

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh

# Add ubuntu user to docker group
usermod -aG docker ubuntu
newgrp docker

# Install Docker Compose plugin
apt-get install docker-compose-plugin -y

# Install AWS CLI
apt-get install awscli -y

# Install Python3
apt-get install python3 -y

# Add swap space (safety net for t3.micro)
fallocate -l 1G /swapfile
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
echo '/swapfile none swap sw 0 0' >> /etc/fstab

# Create project directory
mkdir -p /home/ubuntu/conduit-devops
chown ubuntu:ubuntu /home/ubuntu/conduit-devops

echo "Userdata script completed successfully"