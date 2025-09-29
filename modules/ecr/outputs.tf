# modules/ecr/outputs.tf

output "repository_url" {
  description = "URL of the ECR repository"
  value       = aws_ecr_repository.attrahere_platform.repository_url
}

output "repository_arn" {
  description = "ARN of the ECR repository"
  value       = aws_ecr_repository.attrahere_platform.arn
}

output "repository_name" {
  description = "Name of the ECR repository"
  value       = aws_ecr_repository.attrahere_platform.name
}

output "registry_id" {
  description = "Registry ID of the ECR repository"
  value       = aws_ecr_repository.attrahere_platform.registry_id
}