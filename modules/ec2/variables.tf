variable "ami_id" {
  type        = string
  description = "AMI ID for the EC2 instance"
}

variable "environment" { type = string }
variable "vpc_id" { type = string }
variable "public_subnet_id" { type = string }
variable "tags" { type = map(string) }

