---
layout: blog.11ty.js
title: Picturesocial - How to deploy a Kubernetes cluster on AWS using Terraform
description: Everybody talks about Kubernetes and this episode will help you understand how it works and why should I care about Kubernetes in the first place.
tags:
  - containers
  - kubernetes
  - eks
  - picturesocial
authorGithubAlias: jyapurv
authorName: Jose Yapur
date: 2022-07-11
---
# Picturesocial - How to deploy a Kubernetes cluster on AWS using Terraform

In our last post [Ep2-Picturesocial - What’s Kubernetes and Why should I care?](picturesocial/ep2-whats-kubernetes-and-why-should-care.md) we learned about Kubernetes and why are we using it in Picturesocial. In this post we are going to learn about infrastructure as a code and specifically how to deploy an Amazon EKS using Terraform. 

I have been working on IT projects for years and something recurrent in my experience has been how Developers work together with Sysadmins, specially when the application push changes to the infrastructure and the way things are done traditionally. The application has to be adapted to the infrastructure or the infrastructure has to be adapted to the application? What happen if those infrastructure changes means that you can’t rollback easily?

In the past, we designed applications knowing that in most of the cases the infrastructure was static, that we had to deal with the constraints as something axiomatic and immovable. As we went forward into our path to the cloud, that paradigm started to break with the possibility to have theoretically all the compute we needed at the power of our hands almost immediately. That shift helped create a new set of solutions designed for those new capabilities, one of them was Infrastructure as Code (IaC)

### **But what’s Infrastructure as Code?**

When I was at school I liked to write stories for Dungeons and Dragons where the main character had to make choices that were selected by the reader, and depending on the choice, you go through a very specific set of scenarios that can potentially be a very long and complex story or the end. If you made a choice, it wont be possible to return into a point in the past and you were forced to go further. This how things happen with infrastructure, you start with assumptions that make you choose, most of the changes are irreversible unless you know for real everything that happened from the beginning. That also means that keeping versioning of the infrastructure configuration in conjunction with the application would be possible but very difficult and that’s where Infrastructure as Code come to action.

Infrastructure as Code let you define your infrastructure and configuration as developers create code, and is composed by configuration files. Those configuration files are interpreted and transformed in infrastructure and configuration on your hybrid or public cloud environment. IaC let you keep versioning of every change for rollout and rollback and you can even create tests to understand what those changes means before applying it. 

For Picturesocial I decided to use Hashicorp Terraform, for our Infrastructure as Code definition, because I have been using it for years and I feel sure that I can scale my architecture and infrastructure without spending much time learning a new tool. But also there are other great tools out there like AWS Cloud Development Kit, AWS CloudFormation, Pulumi, Ansible, Chef, Puppet, etc. That can also help you, the best option is the one that make you feel comfortable and productive.

### **What’s Hashicorp Terraform?**

Terraform is an IaC tool created by Hashicorp that help you define a complete infrastructure in a way that you can version and reuse. It uses Hashicorp Configuration Language (HCL) for its structure. All Terraform configuration files must be saved with `.tf `extension, some of the basic definitions are:

* **Providers**: This is where you tell Terraform that you are using a specific cloud provider [[providers](https://registry.terraform.io/browse/providers)], for example if you want to deploy infrastructure to AWS, you can define the provider like the example below. Just note that the version of the provider is optional, if you don’t specify it it will use the latest as default. 

```
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.20.0"
    }
  }
}
```

* **Resources**: This is where you actually define the infrastructure. You use the resources as pieces of infrastructure like: instances, networks, storage, etc. A resource needs two declarative parameters: 1/ resource type and 2/ resource id. For example bellow we are defining an AWS Instance with an specific AMI and an instance type t2.micro.

```
resource "aws_instance" "web" {
  ami           = "ami-a1b2c3d4"
  instance_type = "t2.micro"
}
```

* **Variables**: 
    * Input: This are the variables that you use to ask the users for information before applying any change. This kind of variables are parameters that you have to specify on the Terraform CLI.

```
variable "project_code" {
  type = string
}

variable "availability_zone" {
  type    = list(string)
  default = ["us-east-1a"]
}
```

    * Output: This are variables that will return information from execution. Like final repository name, cluster id, etc.

```
`output "ec2_ip" { value = aws_instance.server.private_ip }`
```

    * Locals: This are variables that you set on your script and work as constants that you can reference at any part of the script. The example below will create a common tag that will concat the values of variables `project_code` and `environment`.

```
locals {
  project_code = "pso"
  environment  = "dev"
}
common_tags = {
  project_name = "pe-${local.project_code}-${local.environment}01"
}
```

* **Modules**: We use modules to group different resources that are used together, that way instead of having huge terraform templates with lots of resources, we can standardize scenarios into one single object, like: Every Amazon EKS Cluster needs a VPC with 6 subnets, 2 Elastic Load Balancers, 2 Worker Groups with at least 3 EC2 instances each, etc. Instead of creating all those resources per cluster, we can create one module and reuse it for simplification.

```
module "aws-vpc" {
  source = "./mods/aws-vpc"
  base_cidr_block = "11.0.0.0/16"
}
```

I like to think of Terraform as a 4 step IaC tool (even when you have more options), we are going to use 4 basic commands that will apply for all our projects, those steps needs to be apply in the following order:

1. `terraform init
    `Use this command to initialize your terraform project, you only have to run this command once per project.
2. `terraform plan
    `This command is to test what’s going to be created, updated or deleted on your Cloud environment before making any actual change, look at this as a testing command.
3. `terraform apply
    `This command will force you to execute a terraform plan first and then you have to explicitly confirm your actions to execute the final changes.
4. `terraform destroy
    `When you no longer need your environment you can destroy it completely. This is wonderful for Certification Environments that are only needed when a new release is coming.


Now that we know the basics of IaC and Terraform, we are going to deploy an Amazon EKS Cluster from scratch!

### Pre-requisites

* An AWS Account https://aws.amazon.com/free/
* If you are using Linux or MacOS you can continue to the next bullet point, if you are using Microsoft Windows I suggest you to use WSL2 https://docs.microsoft.com/en-us/windows/wsl/install
* Install Git https://github.com/git-guides/install-git
* Install Terraform https://learn.hashicorp.com/tutorials/terraform/install-cli
* Install AWS CLI 2 https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html

Or

* If this is your first time working with AWS CLI or you need a refresh on how to set up your credentials, I suggest you to follow this step-by-step of how to configure your local environment https://aws.amazon.com/es/getting-started/guides/setup-environment/ in this same link you can also follow steps to configure Cloud9, that will be very helpful if you don’t want to install everything from scratch.

### **Walk-through**

In this walk-through we are going to create an Amazon EKS Cluster on the us-east-1 region using 3 availability zones, our own VPC, a worker group with 3 t2.small instances and security rules to prevent unrestricted access to our worker group. 
I created a repository on Github https://github.com/aws-samples/picture-social-sample with all the code needed to follow this walkthrough, make sure you select branch “ep3”.

* First, we are going to clone our base repo so we have all the terraform files that we are going to use to create this Amazon EKS Cluster.

```
git clone https://github.com/aws-samples/picture-social-sample --branch ep3
```

* Once cloned let's go to the newly created directory, we are going to make sure that we are always inside this directory for the rest of this walk-through so the following commands run smoothly.

```
cd picture-social-sample
```

* Now that we cloned the repo we are going to explore the files on our branch. We are going to start with config.tf. This file will contain the basic configuration for our Terraform project like, default AWS Region, and the name of the cluster that is compound by picturesocial and a random 3 digit number. We can reference any of this values in every part of the project as we are going to see in the other files.

```
variable "region" {
  default     = "us-east-1"
  description = "Region of AWS"
}

provider "aws" {
  region = var.region
}

data "aws_availability_zones" "available" {}

locals {
  cluster_name = "picturesocial-${random_integer.suffix.result}"
}

resource "random_integer" "suffix" {
  min = 100
  max = 999
}
```

* The file vpc.tf is where we set our network and the availability zones that we are going to use. Don’t panic if you don’t know what’s a VPC and take a look to this link https://docs.aws.amazon.com/vpc/latest/userguide/vpc-getting-started.html 

```
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.2.0"

  name                 = "picturesocial-vpc"
  cidr                 = "10.0.0.0/16"
  azs                  = data.aws_availability_zones.available.names
  private_subnets      = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets       = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
  }

  public_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                      = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"             = "1"
  }
}
```

* Now that we set the VPC, we are going to set the Security Groups. The Security Groups will allow or deny traffic to the EC2 instances of the Amazon EKS Cluster, here we are allowing traffic to the port 22 from selected network segments named cidr_blocks.

```

resource "aws_security_group" "worker_group_mgmt_one" {
  name_prefix = "worker_group_mgmt_one"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = [
      "10.0.0.0/8",
    ]
  }
}

resource "aws_security_group" "worker_group_mgmt_two" {
  name_prefix = "worker_group_mgmt_two"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = [
      "192.168.0.0/16",
    ]
  }
}

resource "aws_security_group" "all_worker_mgmt" {
  name_prefix = "all_worker_management"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = [
      "10.0.0.0/8",
      "172.16.0.0/12",
      "192.168.0.0/16",
    ]
  }
}
```

* The file eks-cluster.tf use a public AWS Module that we can use to simplify the creation of an Amazon EKS Cluster, we are going to set the cluster name referencing the variable that we set on our config.tf file, we choose our Kubernetes version and then we also reference our VPC and Subnets, defined on the vpc.tf file.

```
module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "17.24.0"
  cluster_name    = local.cluster_name
  cluster_version = "1.20"
  subnets         = module.vpc.private_subnets

  vpc_id = module.vpc.vpc_id

  workers_group_defaults = {
    root_volume_type = "gp2"
  }

  worker_groups = [
    {
      name                          = "group-1"
      instance_type                 = "t2.small"
      additional_security_group_ids = [aws_security_group.worker_group_mgmt_one.id]
      asg_desired_capacity          = 3
    },
  ]
}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}
```

* And finally we are going to check the outputs on the outputs.tf file. This is the file that will produce the Kubernetes Config file or kubeconfig, this is the file needed by Kubectl or the Kubernetes REST API to know who are you, if you have access and if they can trust in you. And this is one of the most important pieces to get access to the Amazon EKS Cluster.

```
output "cluster_id" {
  value       = module.eks.cluster_id
}

output "cluster_endpoint" {
  value       = module.eks.cluster_endpoint
}

output "cluster_security_group_id" {
  value       = module.eks.cluster_security_group_id
}

output "kubectl_config" {
  value       = module.eks.kubeconfig
}

output "config_map_aws_auth" {
  value       = module.eks.config_map_aws_auth
}

output "region" {
  value       = var.region
}

output "cluster_name" {
  value       = local.cluster_name
}
```

* Now let’s make sure that we have Terraform correctly installed, by running the command below on your favorite terminal. If everything is fine we should get the version and we are going to need at least Terraform 1.1.7.

```
terraform —version
```

* Let’s start initializing our project by running the following command:

```
terraform init
```

* The command above will download all the public modules and the files needed by the AWS Terraform provider. If you get a message containing this “`Terraform has been successfully initialized!" `then you are all set, otherwise you will get the exact error, maybe a typo or something out of place that you need to fix. 
* Now we are going to test our configuration:

```
terraform plan
```

* The command above will return a summary of all the things that will be added, changed or destroyed. This will give us a very good idea of how is everything working before proceed.

```
Terraform used the selected providers to generate the following execution plan. Resource
actions are indicated with the following symbols:
  + create
 <= read (data resources)

Terraform will perform the following actions:

  # data.aws_eks_cluster.cluster will be read during apply
  # (config refers to values not yet known)
 <= data "aws_eks_cluster" "cluster"  {
      + arn                       = (known after apply)
      + certificate_authority     = (known after apply)
      + created_at                = (known after apply)
      + enabled_cluster_log_types = (known after apply)
      + endpoint                  = (known after apply)
      + id                        = (known after apply)
      + identity                  = (known after apply)
      + kubernetes_network_config = (known after apply)
      + name                      = (known after apply)
      + platform_version          = (known after apply)
      + role_arn                  = (known after apply)
      + status                    = (known after apply)
      + tags                      = (known after apply)
      + version                   = (known after apply)
      + vpc_config                = (known after apply)
    }

  #,
 .
 .
 .
**Plan: 50 to add, 0 to change, 0 to destroy.
**
Changes to Outputs:
  + cluster_endpoint          = (known after apply)
  + cluster_id                = (known after apply)
  + cluster_name              = (known after apply)
  + cluster_security_group_id = (known after apply)
  + config_map_aws_auth       = [
      + {
          + binary_data = null
          + data        = (known after apply)
          + id          = (known after apply)
          + metadata    = [
              + {
                  + annotations      = null
                  + generate_name    = null
                  + generation       = (known after apply)
                  + labels           = {
                      + "app.kubernetes.io/managed-by" = "Terraform"
                      + "terraform.io/module"          = "terraform-aws-modules.eks.aws"
                    }
                  + name             = "aws-auth"
                  + namespace        = "kube-system"
                  + resource_version = (known after apply)
                  + uid              = (known after apply)
                },
            ]
        },
    ]
  + kubectl_config            = (known after apply)
  + region                    = "us-east-1"

───────────────────────────────────────────────────────────────────────────────────────────────

Note: You didn't use the -out option to save this plan, so Terraform can't guarantee to take
exactly these actions if you run "terraform apply"
```

* Now that we are sure about what our project does, we are going to apply the changes by running the command bellow. You will be asked to confirm the changes by typing “yes”.

```
terraform apply
```

* If you get a timeout when applying changes just try again, it may be the chosen instance type allocation time or a connection error from your terminal.
* This process is going to take around 15-20 minutes, but depending on your own configuration it can be significantly more or less, please be mind that your terminal needs to be accessible and connected to the internet until the command finish running. Once is done you are going to get the following message: 
    `Apply complete! Resources: 50 added, 0 changed, 0 destroyed.`
* We are going to extract all the outputs that we configured on the outputs.tf, those are also part of the confirmation message that you get bellow the “Apply complete!", those variables will be used to construct our kubeconfig file. To extract those values we are going to use the following command:

```
aws eks --region $(terraform output -raw region) update-kubeconfig --name $(terraform output -raw cluster_name)
```

* We are all set! Now let’s confirm that the cluster is created

```
aws eks list-clusters
```

* If everything worked as expected you will get a similar output:

```
{"clusters": ["picturesocial-129"]}
```

* If you have experience with Kubernetes and you already have a workload to test, feel free to start playing. But if you don’t know how to deploy an application I suggest you to delete all this infrastructure and redeploy it when the next episode arrive :) You can do it by running this command:

```
terraform destroy
```

Wow! This was long for a blog post, but you made it! You can reuse this template to create your own clusters and even to create your own modules in the future. The next episode will be about how to deploy an application to Kubernetes and I believe is one of the most satisfactory parts of this series because is when you see your application finally running in Kubernetes and taking advantage of capabilities as self-healing, auto scaling, load balancing, etc. Also, if you want to learn more about Terraform modules for Amazon EKS, I suggest you to jump to the Amazon EKS Blueprints for Terraform that contains lots of great modules, available to use for your production ready Kubernetes deployment. https://aws-ia.github.io/terraform-aws-eks-blueprints/

I hope you learned reading this post and I look forward to learn together on the next one.
