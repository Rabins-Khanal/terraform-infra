##########################################
# modules/codedeploy/main.tf
##########################################

# S3 Bucket for Artifact Storage
resource "aws_s3_bucket" "artifacts" {
  bucket = var.artifact_bucket_name
  tags   = var.tags
}

resource "aws_s3_bucket_versioning" "artifacts_versioning" {
  bucket = aws_s3_bucket.artifacts.id

  versioning_configuration {
    status = "Enabled"
  }
}

############################################################
# IAM Roles
############################################################

# CodeDeploy Service Role
data "aws_iam_policy_document" "codedeploy_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["codedeploy.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "codedeploy_service" {
  name               = "codedeploy-service-role-${var.environment}"
  assume_role_policy = data.aws_iam_policy_document.codedeploy_assume.json
  tags               = var.tags
}

resource "aws_iam_role_policy_attachment" "codedeploy_service_attach" {
  role       = aws_iam_role.codedeploy_service.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSCodeDeployRole"
}

# EC2 IAM Role (needed for CodeDeploy Agent)
data "aws_iam_policy_document" "ec2_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ec2_instance" {
  name               = "ec2-codedeploy-role-${var.environment}"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume.json
  tags               = var.tags
}

resource "aws_iam_role_policy_attachment" "ec2_s3_read" {
  role       = aws_iam_role.ec2_instance.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}

resource "aws_iam_role_policy_attachment" "ec2_cloudwatch" {
  role       = aws_iam_role.ec2_instance.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_role_policy_attachment" "ec2_codedeploy_agent" {
  role       = aws_iam_role.ec2_instance.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforAWSCodeDeploy"
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2-codedeploy-profile-${var.environment}"
  role = aws_iam_role.ec2_instance.name
}

############################################################
# CodeDeploy Application
############################################################

resource "aws_codedeploy_app" "app" {
  name             = var.codedeploy_app_name
  compute_platform = "Server"
  tags             = var.tags
}

############################################################
# Deployment Group — BLUE / GREEN
############################################################

resource "aws_codedeploy_deployment_group" "dg" {
  app_name              = aws_codedeploy_app.app.name
  deployment_group_name = var.deployment_group_name
  service_role_arn      = aws_iam_role.codedeploy_service.arn

  deployment_style {
    deployment_type   = "BLUE_GREEN"
    deployment_option = "WITH_TRAFFIC_CONTROL"
  }

  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE"]
  }

  blue_green_deployment_config {
    deployment_ready_option {
      action_on_timeout = "CONTINUE_DEPLOYMENT"
    }

    terminate_blue_instances_on_deployment_success {
      action                           = "TERMINATE"
      termination_wait_time_in_minutes = var.terminate_wait_minutes
    }
  }

  # ASG NAME — must be name, NOT ARN
  autoscaling_groups = [var.asg_blue_name]

  # Target Groups MUST USE NAME — not ARN
  load_balancer_info {
    target_group_pair_info {
      target_group {
        name = var.tg_blue_name
      }
      target_group {
        name = var.tg_green_name
      }

      # listener MUST be ARN
      prod_traffic_route {
        listener_arns = [var.listener_arn]
      }
    }
  }

  tags = var.tags

  depends_on = [
    module.asg,
    module.alb
  ]
}

