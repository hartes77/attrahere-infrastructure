# environments/staging/outputs.tf

output "vpc_id" {
  description = "The ID of the staging VPC"
  value       = module.vpc.vpc_id
}

output "private_subnets" {
  description = "List of IDs of private subnets in the staging VPC"
  value       = module.vpc.private_subnets
}

output "public_subnets" {
  description = "List of IDs of public subnets in the staging VPC"
  value       = module.vpc.public_subnets
}