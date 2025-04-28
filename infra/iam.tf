resource "aws_iam_role" "ecs_task_role" {
  name = "${var.name}-ecs-task-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "ecs_task_role_policy" {
  name = "ecs-task-role-policy"
  role = aws_iam_role.ecs_task_role.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "ecs:*",
        "ecr:*",
        "ssm:*",
        "secretsmanager:*",
      ]
      Resource = "*"
    }]
  })
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name = "${var.name}-ecs-task-exec-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Principal = {
          Service = ["ecs-tasks.amazonaws.com", "ecs.amazonaws.com"]
        }
        Effect = "Allow"
        Sid    = ""
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs-task-execution-role-policy-attachment" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy" "ecs_task_execution_role_policy" {
  name = "ecs-task-execution-role-policy"
  role = aws_iam_role.ecs_task_execution_role.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "ecs:*",
        "secretsmanager:*",
        "ssm:*",
        "logs:*",
        "ecr:*",
      ]
      Resource = "*"
    }]
  })
}

data "aws_iam_policy_document" "ecs_auto_scale_role" {
  version = "2012-10-17"
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["application-autoscaling.amazonaws.com"]
    }
  }
}

# ECS auto scale role
resource "aws_iam_role" "ecs_auto_scale_role" {
  name               = "${var.name}-ecs-auto-scale-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_auto_scale_role.json
}

# ECS auto scale role policy attachment
resource "aws_iam_role_policy_attachment" "ecs_auto_scale_role" {
  role       = aws_iam_role.ecs_auto_scale_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceAutoscaleRole"
}

resource "aws_iam_role_policy" "ecs_auto_scale_custom_policy" {
  name = "${var.name}-ecs-auto-scale-custom-policy"
  role = aws_iam_role.ecs_auto_scale_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      
      {
        Effect = "Allow"
        
        Action = [
          "application-autoscaling:RegisterScalableTarget",
          "application-autoscaling:DeregisterScalableTarget",
          "application-autoscaling:PutScalingPolicy",
          "application-autoscaling:DeleteScalingPolicy",
          "application-autoscaling:DescribeScalableTargets",
          "application-autoscaling:DescribeScalingPolicies",
          "cloudwatch:PutMetricAlarm",
          "cloudwatch:DescribeAlarms",
          "cloudwatch:DeleteAlarms",
          "ecs:UpdateService",
          "iam:PassRole",
          "sns:*"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"] # Current thumbprint
}

resource "aws_iam_role" "github_actions_role" {
  name = "${var.name}-github-actions-role"

  # This is the only part that needs careful updating
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Federated = aws_iam_openid_connect_provider.github.arn
      }
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
        }
        StringLike = {
          "token.actions.githubusercontent.com:sub" = "repo:lovelord88/Terra-Infra-project:*"
        }
      }
    }]
  })
}
resource "aws_iam_policy" "github-actions" {
  name        = "transactly-github-actions"
  description = "Github action IAM policy"
  
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = ["*"],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "sts:AssumeRole",
          "sts:TagSession",
          "sts:AssumeRoleWithWebIdentity",
          "sts:GetCallerIdentity"
        ],
        Resource = "*"
      }
    ]
  })
}

# 1. Create OIDC provider (if doesn't exist)
resource "aws_iam_openid_connect_provider" "github" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"] # July 2024 thumbprint
}

# 2. IAM Role with corrected trust policy
resource "aws_iam_role" "github_actions" {
  name               = "github-actions-role"
  description        = "Role for GitHub Actions OIDC access"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Federated = aws_iam_openid_connect_provider.github.arn
      },
      Action = "sts:AssumeRoleWithWebIdentity",
      Condition = {
        StringEquals = {
          "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
        },
        StringLike = {
          "token.actions.githubusercontent.com:sub" = "repo:lovelord88/Terra-Infra-project:*"
        }
      }
    }]
  })
}

# 3. Attach basic permissions (start with these)
resource "aws_iam_role_policy_attachment" "github_actions" {
  role       = aws_iam_role.github_actions.name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess" # Start minimal
}

# # OIDC provider for GitHub Actions
# resource "aws_iam_openid_connect_provider" "github" {
#   url = "https://token.actions.githubusercontent.com"

#   client_id_list  = ["sts.amazonaws.com"]
#   thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]
# }

# # Role GitHub Actions can assume
# resource "aws_iam_role" "github-actions-role" {
#   name = "${var.name}-github-actions-role"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [{
#       Effect = "Allow"
#       Principal = {
#         Federated = "aws_iam_openid_connect_provider.github.arn"
#       }
#       Action = "sts:AssumeRoleWithWebIdentity"
#       Condition = {
#         StringLike = {
#           "token.actions.githubusercontent.com:sub" : [
#             "repo:lovelord88/Terra-Infra-project*",
#             "repo:lovelord88/Terra-Infra-project:*"
#           ]
#         }
#       }
#     }]
#   })
# }

# Attach necessary permissions — adjust as needed
resource "aws_iam_role_policy_attachment" "github_actions_policy" {
  role       = aws_iam_role.github_actions.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}
