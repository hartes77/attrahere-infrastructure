# modules/ecr/variables.tf

variable "repository_name" {
  description = "Name of the ECR repository"
  type        = string
  default     = "attrahere-platform"

  validation {
    condition     = can(regex("^[a-z0-9-_/]+$", var.repository_name))
    error_message = "Repository name must contain only lowercase letters, numbers, hyphens, underscores, and forward slashes."
  }
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