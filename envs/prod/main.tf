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

module "alb" {
  source            = "../../modules/alb"
  environment       = var.environment
  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
  deploy_green      = var.deploy_green
  tags              = local.tags
}

module "asg" {
  source             = "../../modules/asg"
  environment        = var.environment
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
  ami_id             = var.ami_id
  alb_sg_id          = module.alb.alb_sg_id
  tg_blue_arn        = module.alb.tg_blue_arn
  tg_green_arn       = module.alb.tg_green_arn
  deploy_green       = var.deploy_green
  user_data_file     = "../../modules/ec2/userdata.sh"
  tags               = local.tags
}

locals {
  tags = {
    Environment = var.environment
    purpose     = "Prod"
    Owner       = "rabins.khanal@genesesolution.com"
    Project     = "Terraform RnD"
    Schedule    = "NP-office"
  }
}
