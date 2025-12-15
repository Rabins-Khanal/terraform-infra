output "deployment_group_name" {
  value = aws_codedeploy_deployment_group.this.deployment_group_name
}

output "codedeploy_app_name" {
  value = aws_codedeploy_app.app.name
}

output "artifact_bucket" {
  value = aws_s3_bucket.artifacts.id
}

output "ec2_instance_profile" {
  value = aws_iam_instance_profile.ec2_profile.name
}
