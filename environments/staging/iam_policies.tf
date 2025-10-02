# iam_policies.tf
# IAM policies for GitHub Actions OIDC role - Enterprise Infrastructure Management

# Terraform Enterprise Policy for GitHub Actions
resource "aws_iam_policy" "github_actions_terraform" {
  name        = "GitHubActions-TerraformEnterprisePolicy"
  description = "Enterprise-scoped permissions for GitHub Actions to manage Attrahere infrastructure via Terraform"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "VPCandNetworking"
        Effect = "Allow"
        Action = [
          "ec2:CreateVpc",
          "ec2:DeleteVpc",
          "ec2:ModifyVpcAttribute",
          "ec2:DescribeVpcs",
          "ec2:CreateSubnet",
          "ec2:DeleteSubnet", 
          "ec2:DescribeSubnets",
          "ec2:ModifySubnetAttribute",
          "ec2:CreateInternetGateway",
          "ec2:DeleteInternetGateway",
          "ec2:AttachInternetGateway",
          "ec2:DetachInternetGateway",
          "ec2:DescribeInternetGateways",
          "ec2:CreateNatGateway",
          "ec2:DeleteNatGateway",
          "ec2:DescribeNatGateways",
          "ec2:CreateRouteTable",
          "ec2:DeleteRouteTable",
          "ec2:DescribeRouteTables",
          "ec2:CreateRoute",
          "ec2:DeleteRoute",
          "ec2:AssociateRouteTable",
          "ec2:DisassociateRouteTable",
          "ec2:CreateSecurityGroup",
          "ec2:DeleteSecurityGroup",
          "ec2:DescribeSecurityGroups",
          "ec2:AuthorizeSecurityGroupIngress",
          "ec2:AuthorizeSecurityGroupEgress",
          "ec2:RevokeSecurityGroupIngress",
          "ec2:RevokeSecurityGroupEgress",
          "ec2:AllocateAddress",
          "ec2:ReleaseAddress",
          "ec2:DescribeAddresses",
          "ec2:CreateTags",
          "ec2:DeleteTags",
          "ec2:DescribeTags"
        ]
        Resource = "*"
        Condition = {
          StringEquals = {
            "aws:RequestedRegion" = "eu-central-1"
          }
        }
      },
      {
        Sid    = "IAMManagement"
        Effect = "Allow"
        Action = [
          "iam:CreateRole",
          "iam:DeleteRole",
          "iam:GetRole",
          "iam:UpdateRole",
          "iam:ListRoles",
          "iam:CreatePolicy",
          "iam:DeletePolicy",
          "iam:GetPolicy",
          "iam:ListPolicies",
          "iam:AttachRolePolicy",
          "iam:DetachRolePolicy",
          "iam:PutRolePolicy",
          "iam:DeleteRolePolicy",
          "iam:GetRolePolicy",
          "iam:ListRolePolicies",
          "iam:ListAttachedRolePolicies",
          "iam:TagRole",
          "iam:UntagRole"
        ]
        Resource = [
          "arn:aws:iam::482352877352:role/attrahere-*",
          "arn:aws:iam::482352877352:policy/attrahere-*"
        ]
      },
      {
        Sid    = "SecretsManager"
        Effect = "Allow"
        Action = [
          "secretsmanager:CreateSecret",
          "secretsmanager:DeleteSecret",
          "secretsmanager:UpdateSecret",
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret",
          "secretsmanager:ListSecrets",
          "secretsmanager:TagResource",
          "secretsmanager:UntagResource"
        ]
        Resource = [
          "arn:aws:secretsmanager:eu-central-1:482352877352:secret:staging/attrahere/*",
          "arn:aws:secretsmanager:eu-central-1:482352877352:secret:production/attrahere/*"
        ]
      },
      {
        Sid    = "KMSManagement"
        Effect = "Allow"
        Action = [
          "kms:CreateKey",
          "kms:DeleteKey",
          "kms:DescribeKey",
          "kms:ListKeys",
          "kms:CreateAlias",
          "kms:DeleteAlias",
          "kms:ListAliases",
          "kms:TagResource",
          "kms:UntagResource",
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:GenerateDataKey"
        ]
        Resource = "*"
        Condition = {
          StringEquals = {
            "aws:RequestedRegion" = "eu-central-1"
          }
          StringLike = {
            "kms:AliasName" = [
              "alias/attrahere-*"
            ]
          }
        }
      },
      {
        Sid    = "CloudWatchLogs"
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:DeleteLogGroup",
          "logs:DescribeLogGroups",
          "logs:TagResource",
          "logs:UntagResource",
          "logs:CreateLogStream",
          "logs:DeleteLogStream",
          "logs:DescribeLogStreams"
        ]
        Resource = [
          "arn:aws:logs:eu-central-1:482352877352:log-group:/ecs/attrahere-*",
          "arn:aws:logs:eu-central-1:482352877352:log-group:/ecs/attrahere-*:*"
        ]
      },
      {
        Sid    = "SNSManagement"
        Effect = "Allow"
        Action = [
          "sns:CreateTopic",
          "sns:DeleteTopic",
          "sns:GetTopicAttributes",
          "sns:ListTopics",
          "sns:Subscribe",
          "sns:Unsubscribe",
          "sns:TagResource",
          "sns:UntagResource"
        ]
        Resource = [
          "arn:aws:sns:eu-central-1:482352877352:attrahere-*"
        ]
      },
      {
        Sid    = "RDSManagement"
        Effect = "Allow"
        Action = [
          "rds:CreateDBInstance",
          "rds:DeleteDBInstance",
          "rds:ModifyDBInstance",
          "rds:DescribeDBInstances",
          "rds:CreateDBSubnetGroup",
          "rds:DeleteDBSubnetGroup",
          "rds:DescribeDBSubnetGroups",
          "rds:AddTagsToResource",
          "rds:RemoveTagsFromResource",
          "rds:ListTagsForResource"
        ]
        Resource = [
          "arn:aws:rds:eu-central-1:482352877352:db:attrahere-*",
          "arn:aws:rds:eu-central-1:482352877352:subgrp:attrahere-*"
        ]
      },
      {
        Sid    = "CloudWatchDashboards"
        Effect = "Allow"
        Action = [
          "cloudwatch:PutDashboard",
          "cloudwatch:DeleteDashboards",
          "cloudwatch:GetDashboard",
          "cloudwatch:ListDashboards",
          "cloudwatch:PutMetricAlarm",
          "cloudwatch:DeleteAlarms",
          "cloudwatch:DescribeAlarms"
        ]
        Resource = [
          "arn:aws:cloudwatch:eu-central-1:482352877352:dashboard/attrahere-*",
          "arn:aws:cloudwatch:eu-central-1:482352877352:alarm:attrahere-*"
        ]
      }
    ]
  })

  tags = {
    Name        = "GitHubActions-TerraformEnterprisePolicy"
    Environment = "all"
    Component   = "iam-policy"
    ManagedBy   = "terraform"
    Purpose     = "enterprise-infrastructure-management"
  }
}

# Attach the policy to the existing OIDC role
resource "aws_iam_role_policy_attachment" "terraform_policy_attachment" {
  role       = "GitHubActions-AttrahereStaging"
  policy_arn = aws_iam_policy.github_actions_terraform.arn
}