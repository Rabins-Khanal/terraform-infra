variable "ami_id" {
  type        = string
  description = "AMI ID for the EC2 instance"
}
variable "key_name" {
  description = "Key pair for EC2 instance"
  type        = string
}
variable "environment" { type = string }
variable "vpc_id" { type = string }
variable "public_subnet_ids" { type = list(string) }
variable "tags" { type = map(string) }

