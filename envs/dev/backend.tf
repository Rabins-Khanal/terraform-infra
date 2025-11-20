terraform {
  backend "s3" {
    bucket       = "terraformrnd-dev-state"
    key          = "terraform/dev/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}

