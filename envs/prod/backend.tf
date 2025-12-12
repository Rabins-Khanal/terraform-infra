terraform {
  backend "s3" {
    bucket  = "terraformrnd-dev-state"
    key     = "terraform/prod/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}

