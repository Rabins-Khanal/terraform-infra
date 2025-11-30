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

resource "aws_launch_template" "blue" {
  name_prefix   = "lt-blue-${var.environment}"
  image_id      = var.ami_id
  instance_type = "t2.micro"

  user_data = file("../../ec2/userdata.sh")

  network_interfaces {
    security_groups = [aws_security_group.asg_sg.id]
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_launch_template" "green" {
  name_prefix   = "lt-green-${var.environment}"
  image_id      = var.ami_id
  instance_type = "t2.micro"

  user_data = file("../../ec2/userdata.sh")

  network_interfaces {
    security_groups = [aws_security_group.asg_sg.id]
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "blue" {
  name                = "asg-blue-${var.environment}"
  max_size            = 3
  min_size            = 1
  desired_capacity    = 2
  vpc_zone_identifier = var.private_subnet_ids

  health_check_type = "EC2"

  launch_template {
    id      = aws_launch_template.blue.id
    version = "$Latest"
  }

  target_group_arns = [var.tg_blue_arn]

  lifecycle {
    create_before_destroy = true
  }

  tag {
    key                 = "Name"
    value               = "blue-ec2-${var.environment}"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_group" "green" {
  name                = "asg-green-${var.environment}"
  max_size            = 3
  min_size            = 1
  desired_capacity    = 2
  vpc_zone_identifier = var.private_subnet_ids

  health_check_type = "EC2"

  launch_template {
    id      = aws_launch_template.green.id
    version = "$Latest"
  }

  target_group_arns = [var.tg_green_arn]

  lifecycle {
    create_before_destroy = true
  }

  tag {
    key                 = "Name"
    value               = "green-ec2-${var.environment}"
    propagate_at_launch = true
  }
}
