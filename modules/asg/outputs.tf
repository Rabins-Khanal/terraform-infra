output "asg_blue_id" { value = aws_autoscaling_group.blue.id }
output "asg_green_id" { value = aws_autoscaling_group.green.id }
output "asg_sg_id" { value = aws_security_group.asg_sg.id }
