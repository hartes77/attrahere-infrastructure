# modules/ecs-fargate/cloudwatch.tf
# CloudWatch Alarms for ECS service monitoring and CrashLoop detection

# CloudWatch Alarm for Service Running Tasks Count
resource "aws_cloudwatch_metric_alarm" "ecs_service_running_tasks" {
  alarm_name          = "${var.service_name}-running-tasks-low"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "RunningTaskCount"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Average"
  threshold           = "1"
  alarm_description   = "This metric monitors ECS service running tasks count"
  alarm_actions       = [aws_sns_topic.ecs_alerts.arn]
  ok_actions          = [aws_sns_topic.ecs_alerts.arn]
  treat_missing_data  = "breaching"

  dimensions = {
    ServiceName = aws_ecs_service.attrahere_platform.name
    ClusterName = aws_ecs_cluster.attrahere.name
  }

  tags = merge(var.common_tags, {
    Name        = "${var.service_name}-running-tasks-alarm"
    Environment = var.environment
    Component   = "monitoring"
  })
}

# CloudWatch Alarm for Task Stop Reasons (CrashLoop Detection)
resource "aws_cloudwatch_metric_alarm" "ecs_task_stopped_reason" {
  alarm_name          = "${var.service_name}-task-failures-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "TasksStoppedReason"
  namespace           = "AWS/ECS"
  period              = "300"
  statistic           = "Sum"
  threshold           = "3"
  alarm_description   = "This metric monitors ECS task failures (CrashLoop detection)"
  alarm_actions       = [aws_sns_topic.ecs_alerts.arn]
  treat_missing_data  = "notBreaching"

  dimensions = {
    ServiceName = aws_ecs_service.attrahere_platform.name
    ClusterName = aws_ecs_cluster.attrahere.name
    StopReason  = "TaskFailedToStart"
  }

  tags = merge(var.common_tags, {
    Name        = "${var.service_name}-task-failures-alarm"
    Environment = var.environment
    Component   = "monitoring"
  })
}

# CloudWatch Alarm for CPU Utilization
resource "aws_cloudwatch_metric_alarm" "ecs_cpu_utilization" {
  alarm_name          = "${var.service_name}-cpu-utilization-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "300"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "This metric monitors ECS service CPU utilization"
  alarm_actions       = [aws_sns_topic.ecs_alerts.arn]

  dimensions = {
    ServiceName = aws_ecs_service.attrahere_platform.name
    ClusterName = aws_ecs_cluster.attrahere.name
  }

  tags = merge(var.common_tags, {
    Name        = "${var.service_name}-cpu-alarm"
    Environment = var.environment
    Component   = "monitoring"
  })
}

# CloudWatch Alarm for Memory Utilization
resource "aws_cloudwatch_metric_alarm" "ecs_memory_utilization" {
  alarm_name          = "${var.service_name}-memory-utilization-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  period              = "300"
  statistic           = "Average"
  threshold           = "85"
  alarm_description   = "This metric monitors ECS service memory utilization"
  alarm_actions       = [aws_sns_topic.ecs_alerts.arn]

  dimensions = {
    ServiceName = aws_ecs_service.attrahere_platform.name
    ClusterName = aws_ecs_cluster.attrahere.name
  }

  tags = merge(var.common_tags, {
    Name        = "${var.service_name}-memory-alarm"
    Environment = var.environment
    Component   = "monitoring"
  })
}

# SNS Topic for ECS Alerts
resource "aws_sns_topic" "ecs_alerts" {
  name = "${var.service_name}-alerts"

  tags = merge(var.common_tags, {
    Name        = "${var.service_name}-alerts"
    Environment = var.environment
    Component   = "notifications"
  })
}

# SNS Topic Subscription (Email)
resource "aws_sns_topic_subscription" "ecs_alerts_email" {
  count     = length(var.alert_email_endpoints)
  topic_arn = aws_sns_topic.ecs_alerts.arn
  protocol  = "email"
  endpoint  = var.alert_email_endpoints[count.index]
}

# CloudWatch Dashboard for ECS Monitoring
resource "aws_cloudwatch_dashboard" "ecs_dashboard" {
  dashboard_name = "${var.service_name}-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6

        properties = {
          metrics = [
            ["AWS/ECS", "RunningTaskCount", "ServiceName", aws_ecs_service.attrahere_platform.name, "ClusterName", aws_ecs_cluster.attrahere.name],
            ["AWS/ECS", "PendingTaskCount", "ServiceName", aws_ecs_service.attrahere_platform.name, "ClusterName", aws_ecs_cluster.attrahere.name],
            ["AWS/ECS", "DesiredCount", "ServiceName", aws_ecs_service.attrahere_platform.name, "ClusterName", aws_ecs_cluster.attrahere.name]
          ]
          view    = "timeSeries"
          stacked = false
          region  = var.aws_region
          title   = "ECS Service Task Counts"
          period  = 300
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 6
        width  = 12
        height = 6

        properties = {
          metrics = [
            ["AWS/ECS", "CPUUtilization", "ServiceName", aws_ecs_service.attrahere_platform.name, "ClusterName", aws_ecs_cluster.attrahere.name],
            ["AWS/ECS", "MemoryUtilization", "ServiceName", aws_ecs_service.attrahere_platform.name, "ClusterName", aws_ecs_cluster.attrahere.name]
          ]
          view    = "timeSeries"
          stacked = false
          region  = var.aws_region
          title   = "ECS Service Resource Utilization"
          period  = 300
        }
      }
    ]
  })
}