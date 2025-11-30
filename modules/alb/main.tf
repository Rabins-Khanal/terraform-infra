##########################
# ALB Security Group
##########################
resource "aws_security_group" "alb_sg" {
  name        = "alb-sg-${var.environment}"
  description = "Allow HTTP access to ALB"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "alb-sg-${var.environment}"
  })
}

##########################
# Application Load Balancer
##########################
resource "aws_lb" "this" {
  name               = "alb-${var.environment}"
  load_balancer_type = "application"
  internal           = false
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = var.public_subnet_ids

  tags = merge(var.tags, {
    Name = "alb-${var.environment}"
  })
}

##########################
# Target Groups
##########################
resource "aws_lb_target_group" "blue" {
  name        = "tg-blue-${var.environment}"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "instance"

  health_check {
    path                = "/"
    port                = "80"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    interval            = 10
  }

  tags = merge(var.tags, {
    Name = "tg-blue-${var.environment}"
  })
}

resource "aws_lb_target_group" "green" {
  count       = var.deploy_green ? 1 : 0
  name        = "tg-green-${var.environment}"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "instance"

  health_check {
    path                = "/"
    port                = "80"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    interval            = 10
  }

  tags = merge(var.tags, {
    Name = "tg-green-${var.environment}"
  })
}


##########################
# Listener
##########################
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.this.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "forward"
    forward {
      target_group {
        arn    = aws_lb_target_group.blue.arn
        weight = 100
      }
      target_group {
        arn    = var.deploy_green ? aws_lb_target_group.green[0].arn : null
        weight = var.deploy_green ? 0 : 0
      }
    }
  }
}
