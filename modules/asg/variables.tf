variable "environment" { type = string }
variable "vpc_id" { type = string }
variable "private_subnet_ids" { type = list(string) }
variable "ami_id" { type = string }
variable "alb_sg_id" { type = string }
variable "tg_blue_arn" { type = string }
variable "tags" { type = map(string) }
variable "user_data_file" {
  description = "Path to userdata.sh for EC2 instances"
  type        = string
}

variable "ec2_instance_profile" {
  type = string
}
