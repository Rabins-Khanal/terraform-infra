variable "environment" { default = "prod" }
variable "ami_id" { default = "ami-02b8269d5e85954ef" }

variable "db_username" { default = "admin" }
variable "db_password" { default = "Password123!" }

variable "deploy_green" {
  type        = bool
  default     = false
  description = "Whether to deploy the green environment"
}
