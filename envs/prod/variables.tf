variable "environment" { default = "prod" }
variable "ami_id" { default = "ami-0e7a3a0a1317785f1" }

variable "db_username" { default = "admin" }
variable "db_password" { default = "Password123!" }

variable "deploy_green" {
  type        = bool
  default     = false
  description = "Whether to deploy the green environment"
}
