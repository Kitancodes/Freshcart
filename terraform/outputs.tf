output "load_balancer_dns" {
  description = "Public DNS name of the FreshCart Application Load Balancer."
  value       = aws_lb.app.dns_name
}

output "load_balancer_zone_id" {
  description = "Route 53 hosted zone ID of the ALB."
  value       = aws_lb.app.zone_id
}

output "backend_instance_id" {
  description = "ID of the private Checkout API EC2 instance."
  value       = aws_instance.backend.id
}

output "vpc_id" {
  description = "ID of the FreshCart VPC."
  value       = module.network.vpc_id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets."
  value       = module.network.public_subnet_ids
}

output "private_subnet_ids" {
  description = "IDs of the private subnets."
  value       = module.network.private_subnet_ids
}