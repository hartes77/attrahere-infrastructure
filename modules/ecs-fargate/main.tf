# modules/ecs-fargate/main.tf
# ECS Fargate service for Attrahere Platform

# ECS Cluster
resource "aws_ecs_cluster" "attrahere" {
  name = var.cluster_name

  configuration {
    execute_command_configuration {
      logging = "OVERRIDE"
      log_configuration {
        cloud_watch_log_group_name = aws_cloudwatch_log_group.ecs_logs.name
      }
    }
  }

  tags = merge(var.common_tags, {
    Name        = var.cluster_name
    Environment = var.environment
    Component   = "ecs-cluster"
  })
}

# CloudWatch Log Group
resource "aws_cloudwatch_log_group" "ecs_logs" {
  name              = "/ecs/${var.cluster_name}"
  retention_in_days = 30

  tags = merge(var.common_tags, {
    Name        = "/ecs/${var.cluster_name}"
    Environment = var.environment
    Component   = "logging"
  })
}

# ECS Task Definition
resource "aws_ecs_task_definition" "attrahere_platform" {
  family                   = var.task_family
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.task_cpu
  memory                   = var.task_memory
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn
  task_role_arn           = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([
    {
      name  = "attrahere-platform"
      image = var.container_image
      
      portMappings = [
        {
          containerPort = 8000
          protocol      = "tcp"
        }
      ]
      
      environment = [
        {
          name  = "ENVIRONMENT"
          value = var.environment
        }
      ]
      
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.ecs_logs.name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "ecs"
        }
      }
      
      healthCheck = {
        command     = ["CMD-SHELL", "curl -f http://localhost:8000/health || exit 1"]
        interval    = 30
        timeout     = 5
        retries     = 3
        startPeriod = 60
      }
      
      essential = true
    }
  ])

  tags = merge(var.common_tags, {
    Name        = var.task_family
    Environment = var.environment
    Component   = "ecs-task"
  })
}

# Security Group for ECS Tasks
resource "aws_security_group" "ecs_tasks" {
  name_prefix = "${var.cluster_name}-ecs-tasks"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
    description = "Allow HTTP traffic from VPC"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = merge(var.common_tags, {
    Name        = "${var.cluster_name}-ecs-tasks"
    Environment = var.environment
    Component   = "security-group"
  })
}

# ECS Service
resource "aws_ecs_service" "attrahere_platform" {
  name            = var.service_name
  cluster         = aws_ecs_cluster.attrahere.id
  task_definition = aws_ecs_task_definition.attrahere_platform.arn
  desired_count   = var.desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [aws_security_group.ecs_tasks.id]
    assign_public_ip = false
  }

  enable_execute_command = true

  tags = merge(var.common_tags, {
    Name        = var.service_name
    Environment = var.environment
    Component   = "ecs-service"
  })
}