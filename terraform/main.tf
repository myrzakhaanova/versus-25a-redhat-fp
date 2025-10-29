############################################
# Terraform / Provider
############################################
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  required_version = ">= 1.6.0"

  backend "s3" {
    bucket       = "versus-s3-app"
    key          = "terraform.tfstate"
    region       = "us-east-1"
    use_lockfile = true
  }
}

provider "aws" {
  region = var.aws_region
}

module "app_sg" {
  source = "./child-module/sg"

  project = var.project
  vpc_id  = var.vpc_id
}

#Module for Frontend ALB + ASG  

module "app_alb_asg_frontend" {
  source = "./child-module/alb-asg"

  project              = var.project
  service              = "frontend"
  vpc_id               = var.vpc_id
  public_subnet_ids    = var.public_subnet_ids
  private_subnet_ids   = var.private_subnet_ids
  health_check_matcher = "200-399"
  health_check_path    = "/"
  domain_name          = var.frontend_domain_name

  instance_type             = var.instance_type
  ssh_key_name              = var.ssh_key_name
  aws_instance_profile_name = module.app_sg.aws_instance_profile_name

  ec2_sg_ids = [module.app_sg.ec2_sg_id]
  alb_sg_ids = [module.app_sg.alb_sg_id]

  asg_min     = var.asg_min
  asg_desired = var.asg_desired
  asg_max     = var.asg_max

  enable_instance_refresh = true
}

# Module for Backend ALB + ASG
module "app_alb_asg_backend" {
  source = "./child-module/alb-asg"

  project              = var.project
  service              = "backend"
  vpc_id               = var.vpc_id
  public_subnet_ids    = var.public_subnet_ids
  private_subnet_ids   = var.private_subnet_ids
  health_check_matcher = "200-399"
  health_check_path    = "/api/"
  domain_name          = var.backend_domain_name
  
  instance_type             = var.instance_type
  ssh_key_name              = var.ssh_key_name
  aws_instance_profile_name = module.app_sg.aws_instance_profile_name

  ec2_sg_ids = [module.app_sg.ec2_sg_id, var.backend_sg_id]
  alb_sg_ids = [module.app_sg.alb_sg_id]

  asg_min     = var.asg_min
  asg_desired = var.asg_desired
  asg_max     = var.asg_max

  enable_instance_refresh = true
}

