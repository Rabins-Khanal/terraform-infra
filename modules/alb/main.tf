resource "aws_lb" "this" {
  name               = "alb-${var.environment}"
  load_balancer_type = "application"
  internal           = false
  security_groups    = [var.alb_sg_id]
  subnets            = var.public_subnet_ids

  tags = merge(var.tags, {
    Name = "alb-${var.environment}"
  })
}

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

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.this.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    forward {
      target_group {
        arn    = aws_lb_target_group.blue.arn
        weight = 1
      }
      target_group {
        arn    = aws_lb_target_group.green.arn
        weight = 1
      }
    }
  }
}
