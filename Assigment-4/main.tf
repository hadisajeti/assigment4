provider "aws" {
  region = "eu-central-1" 
}

terraform {
  backend "s3" {
    bucket = "terraform-state-hadis"
    key    = "terraform.tfstate"
    region = "us-east-1"

    encrypt = true
  }
}

module "vpc" {
  source = "./modules/vpc"
}

module "bastion" {
  source = "./modules/bastion"
  public_subnet_id = module.vpc.public_subnet_id
}

module "rds" {
  source = "./modules/rds"
  bastion_sg_id = module.bastion.bastion_sg_id
  private_subnet_id = module.vpc.private_subnet_id
}

module "autoscale" {
  source = "./modules/autoscale"
  desired_capacity = 1
  max_size = 5
  min_size = 1
  subnet_id = module.vpc.public_subnet_id
  image_id = "ami-09024b009ae9e7adf"
  instance_type = "t2.micro"
}

variable "db_master_password" {
  description = "The master password for the RDS cluster."
  type = string
}