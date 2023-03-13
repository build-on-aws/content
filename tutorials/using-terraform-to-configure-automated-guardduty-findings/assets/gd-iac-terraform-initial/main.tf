/* Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
   SPDX-License-Identifier: MIT-0 */

# --- root/main.tf ---

# CREATES VPC
module "vpc" {
  source      = "./modules/vpc"
  cidr_block  = "10.0.0.0/24"
  tenancy     = "default"
  subnet_cidr = "10.0.0.0/26"
  vpc_name    = "GuardDuty-Example"
}

## Gets the latest AMI resource and is used in the creation of the compute instances below:
data "aws_ami" "latest_amazonlinux2_ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-gp2"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}


# # CREATES COMPUTE INSTANCES
module "compute" {
  source         = "./modules/compute"
  ami_id         = data.aws_ami.latest_amazonlinux2_ami.id
  subnet_id      = module.vpc.subnet_id
  // forensic_sg_id = module.vpc.forensic_sg_id
  initial_sg_id   = module.vpc.initial_sg_id
  access_key     = module.iam_user.access_key
  secret_key     = module.iam_user.secret_key
}


# # CREATES IAM_USER
module "iam_user" {
  source = "./modules/iam_user"
}