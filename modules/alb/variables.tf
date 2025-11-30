variable "environment" { type = string }
variable "vpc_id" { type = string }
variable "public_subnet_ids" { type = list(string) }
variable "tags" { type = map(string) }
variable "deploy_green" {
  description = "Whether to deploy the green environment"
  type        = bool
}

variable "green_weight" {
  description = "Percentage of traffic to route to the green target group (0-100)"
  type        = number
  default     = 0
}