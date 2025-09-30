# modules/ecs-fargate/variables.tf

variable "cluster_name" {
  description = "Name of the ECS cluster"
  type        = string
  default     = "attrahere-cluster"
}

variable "task_family" {
  description = "Family name for the ECS task definition"
  type        = string
  default     = "attrahere-platform"
}

variable "service_name" {
  description = "Name of the ECS service"
  type        = string
  default     = "attrahere-platform-service"
}

variable "container_image" {
  description = "Docker image URI for the container"
  type        = string
}

variable "task_cpu" {
  description = "CPU units for the task (1024 = 1 vCPU)"
  type        = number
  default     = 512

  validation {
    condition     = contains([256, 512, 1024, 2048, 4096], var.task_cpu)
    error_message = "Task CPU must be one of: 256, 512, 1024, 2048, 4096."
  }
}

variable "task_memory" {
  description = "Memory for the task in MB"
  type        = number
  default     = 1024

  validation {
    condition = var.task_memory >= 512 && var.task_memory <= 8192
    error_message = "Task memory must be between 512 and 8192 MB."
  }
}

variable "desired_count" {
  description = "Desired number of tasks to run"
  type        = number
  default     = 1

  validation {
    condition     = var.desired_count >= 0 && var.desired_count <= 10
    error_message = "Desired count must be between 0 and 10."
  }
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block of the VPC"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for ECS tasks"
  type        = list(string)
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "environment" {
  description = "Environment name (staging, production, etc.)"
  type        = string

  validation {
    condition     = contains(["staging", "production", "development"], var.environment)
    error_message = "Environment must be one of: staging, production, development."
  }
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "database_secret_arn" {
  description = "ARN of the RDS master user secret in AWS Secrets Manager"
  type        = string
}