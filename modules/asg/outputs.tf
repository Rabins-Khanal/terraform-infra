output "asg_blue_id" { value = aws_autoscaling_group.blue.id }
output "asg_blue_name" {
  description = "The name of the Blue Auto Scaling Group"
  value       = aws_autoscaling_group.blue.name
}
output "asg_green_name" {
  description = "The name of the Green Auto Scaling Group"
  value       = aws_autoscaling_group.green.name
}
output "asg_green_id" {
  value = var.deploy_green ? aws_autoscaling_group.green[0].id : ""
}
output "asg_sg_id" { value = aws_security_group.asg_sg.id }
