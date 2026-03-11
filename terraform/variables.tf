variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "eu-north-1"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "ami_id" {
  type        = string
}

variable "key_pair_name" {
  description = "Name of the AWS key pair"
  type        = string
}

variable "project_name" {
  description = "Project name used for tagging resources"
  type        = string
  default     = "conduit"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "production"
}

variable "vpc_id" {
  description = "Existing VPC ID"
  type        = string
}

variable "subnet_id" {
  description = "Existing public subnet ID"
  type        = string
}