variable "environment" { default = "prod" }
variable "ami_id" { default = "ami-09a7289256f9ab2c7" }

variable "db_username" { default = "admin" }
variable "db_password" { default = "Password123!" }

variable "deploy_green" {
  type        = bool
  default     = true
  description = "Whether to deploy the green environment"
}
