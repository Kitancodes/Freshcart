variable "aws_region" {
  description = "AWS region where FreshCart infrastructure will be deployed."
  type        = string
  default     = "us-east-1, us-east-1a/b"
}

variable "environment" {
  description = "Environment name."
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Project name used for resource naming."
  type        = string
  default     = "freshcart"
}

variable "vpc_cidr" {
  description = "CIDR block for the FreshCart VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for the two public subnets."
  type        = list(string)

  default = [
    "10.0.1.0/24",
    "10.0.2.0/24"
  ]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for the two private subnets."
  type        = list(string)

  default = [
    "10.0.3.0/24",
    "10.0.4.0/24"
  ]
}

variable "availability_zones" {
  description = "Availability zones used by the public and private subnets."
  type        = list(string)

  default = [
    "us-east-1a",
    "us-east-1b"
  ]
}

variable "instance_type" {
  description = "EC2 instance type for the Checkout API backend."
  type        = string
  default     = "t3.micro"
}

variable "ami_id" {
  description = "AMI ID used for the backend EC2 instance."
  type        = string
}

variable "container_image" {
  description = "Docker image used by the Checkout API backend."
  type        = string
}

variable "container_port" {
  description = "Port exposed by the Checkout API container."
  type        = number
  default     = 3000
}

variable "health_check_path" {
  description = "Health endpoint used by the ALB target group."
  type        = string
  default     = "/healthz"
}

variable "key_name" {
  description = "Optional EC2 key pair name."
  type        = string
  default     = null
}