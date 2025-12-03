variable "environment" { type = string }
variable "tags" { type = map(string) }
variable "artifact_bucket_name" { type = string }
variable "codedeploy_app_name" { type = string }
variable "deployment_group_name" { type = string }
variable "asg_name" { type = string }     # name of your existing ASG resource (blue)
variable "tg_blue_arn" { type = string }  # blue target group arn
variable "tg_green_arn" { type = string } # green target group arn
variable "listener_arn" { type = string } # ALB listener ARN
variable "terminate_wait_minutes" {
  type    = number
  default = 5
}

