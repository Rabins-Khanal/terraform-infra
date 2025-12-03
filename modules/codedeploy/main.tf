##########################################
# modules/codedeploy/main.tf
##########################################

# ---------------------
# S3 bucket for app artifacts
# ---------------------
resource "aws_s3_bucket" "artifacts" {
  bucket = var.artifact_bucket_name
  acl    = "private"

  resource "aws_s3_bucket_versioning" "artifacts_versioning" {
    bucket = aws_s3_bucket.artifacts.id
    versioning_configuration {
      status = "Enabled"
    }
  }


  tags = var.tags
}

# ---------------------
# IAM Role: CodeDeploy Service Role
# ---------------------
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
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSCodeDeployRoleForEC2"
}

# ---------------------
# IAM Role: EC2 Instance Role (for CodeDeploy agent)
# ---------------------
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

# Attach managed policies for S3 access, CloudWatch, and CodeDeploy agent
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

# Instance profile for ASG instances
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2-codedeploy-profile-${var.environment}"
  role = aws_iam_role.ec2_instance.name
}

# ---------------------
# CodeDeploy Application
# ---------------------
resource "aws_codedeploy_app" "app" {
  name             = var.codedeploy_app_name
  compute_platform = "Server"
  tags             = var.tags
}

# ---------------------
# CodeDeploy Deployment Group (Blue/Green)
# ---------------------
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

  # The ASG that will be cloned for green deployment
  autoscaling_groups = [var.asg_name]

  # Load balancer target groups and listener
  load_balancer_info {
    target_group_pair_info {
      target_groups {
        name = var.tg_blue_arn
      }
      target_groups {
        name = var.tg_green_arn
      }
      prod_traffic_route {
        listener_arns = [var.listener_arn]
      }
    }
  }

  tags = var.tags
}


