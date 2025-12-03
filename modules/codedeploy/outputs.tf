output "artifact_bucket" { value = aws_s3_bucket.artifacts.id }
output "codedeploy_app_name" { value = aws_codedeploy_app.app.name }
output "codedeploy_deployment_group" { value = aws_codedeploy_deployment_group.dg.deployment_group_name }
output "ec2_instance_profile" { value = aws_iam_instance_profile.ec2_profile.name }
