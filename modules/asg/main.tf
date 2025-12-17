##########################
# Security Group for ASG
##########################
resource "aws_security_group" "asg_sg" {
  name        = "asg-sg-${var.environment}"
  description = "Allow ALB to EC2"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [var.alb_sg_id]
  }

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [var.alb_sg_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "asg-sg-${var.environment}"
  })
}

##########################
# Local tags
##########################
locals {
  common_tags = {
    Environment = var.environment
    Purpose     = "Prod"
    Owner       = "rabins.khanal@genesesolution.com"
    Project     = "Terraform RnD"
    Schedule    = "NP-office"
  }
}

##########################
# Launch Templates
##########################
resource "aws_launch_template" "blue" {
  name_prefix   = "lt-blue-${var.environment}"
  image_id      = var.ami_id
  instance_type = "t2.micro"
  key_name      = "asg-blue"
  iam_instance_profile {
    name = var.ec2_instance_profile
  }

  user_data = base64encode(file(var.user_data_file))

  network_interfaces {
    security_groups = [aws_security_group.asg_sg.id]
  }

  # Tags for instances launched from this template
  tag_specifications {
    resource_type = "instance"
    tags          = local.common_tags
  }

  # Tags for the launch template resource itself
  tags = merge(local.common_tags, {
    Name = "lt-blue-${var.environment}"
  })

  lifecycle {
    create_before_destroy = true
  }
}


##########################
# Auto Scaling Groups
#########################
resource "aws_autoscaling_group" "blue" {
  name                = "asg-blue-${var.environment}"
  max_size            = 3
  min_size            = 1
  desired_capacity    = 2
  vpc_zone_identifier = var.private_subnet_ids

  health_check_type = "EC2"

  launch_template {
    id      = aws_launch_template.blue.id
    version = aws_launch_template.blue.latest_version
  }
  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
      instance_warmup        = 60
    }
  }

  lifecycle {
    create_before_destroy = true
  }

  tag {
    key                 = "Name"
    value               = "blue-ec2-${var.environment}"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_attachment" "blue_asg_tg" {
  autoscaling_group_name = aws_autoscaling_group.blue.name
  lb_target_group_arn    = var.tg_blue_arn
}

