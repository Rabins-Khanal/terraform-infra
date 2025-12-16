variable "environment" { type = string }
variable "tags" { type = map(string) }

variable "artifact_bucket_name" { type = string }
variable "codedeploy_app_name" { type = string }

#variable "deployment_group_name" { type = string }
variable "asg_blue_name" { type = string }
variable "listener_arn" { type = string }
variable "tg_blue_name" { type = string }

variable "terminate_wait_minutes" {
  type    = number
  default = 5
}
