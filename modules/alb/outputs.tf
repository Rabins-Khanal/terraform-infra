output "alb_arn" { value = aws_lb.this.arn }
output "listener_arn" { value = aws_lb_listener.http.arn }
output "tg_blue_arn" { value = aws_lb_target_group.blue.arn }
output "tg_green_arn" { value = aws_lb_target_group.green.arn }
output "dns_name" { value = aws_lb.this.dns_name }
