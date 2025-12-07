output "asg_blue_id" { value = aws_autoscaling_group.blue.id }
output "asg_blue_name" {
  description = "The name of the Blue Auto Scaling Group"
  value       = aws_autoscaling_group.blue.name
}
output "asg_sg_id" { value = aws_security_group.asg_sg.id }
