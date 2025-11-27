provider "aws" {
  region = "ap-south-1"
}

module "vpc" {
  source               = "../../modules/vpc"
  environment          = var.environment
  vpc_cidr             = "10.0.0.0/16"
  public_subnet1_cidr  = "10.0.1.0/24"
  public_subnet2_cidr  = "10.0.2.0/24"
  private_subnet1_cidr = "10.0.3.0/24"
  private_subnet2_cidr = "10.0.4.0/24"
  tags                 = local.tags
}

module "ec2" {
  source            = "../../modules/ec2"
  environment       = var.environment
  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
  tags              = local.tags
  key_name          = "terraformrnd-keypair-${var.environment}"
  ami_id            = var.ami_id
}

module "rds" {
  source             = "../../modules/rds"
  environment        = var.environment
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
  ec2_sg_id          = module.ec2.ec2_sg_id
  db_username        = var.db_username
  db_password        = var.db_password
  tags               = local.tags
}

locals {
  tags = {
    Environment = var.environment
    purpose     = "Test"
    Owner       = "rabins.khanal@genesesolution.com"
    Project     = "Terraform R and D"
    Schedule    = "NP-office"
  }

}

