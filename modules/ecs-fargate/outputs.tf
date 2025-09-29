# modules/ecs-fargate/outputs.tf

output "cluster_id" {
  description = "ID of the ECS cluster"
  value       = aws_ecs_cluster.attrahere.id
}

output "cluster_arn" {
  description = "ARN of the ECS cluster"
  value       = aws_ecs_cluster.attrahere.arn
}

output "service_id" {
  description = "ID of the ECS service"
  value       = aws_ecs_service.attrahere_platform.id
}

output "service_name" {
  description = "Name of the ECS service"
  value       = aws_ecs_service.attrahere_platform.name
}

output "task_definition_arn" {
  description = "ARN of the task definition"
  value       = aws_ecs_task_definition.attrahere_platform.arn
}

output "security_group_id" {
  description = "ID of the ECS tasks security group"
  value       = aws_security_group.ecs_tasks.id
}

output "log_group_name" {
  description = "Name of the CloudWatch log group"
  value       = aws_cloudwatch_log_group.ecs_logs.name
}