# /* Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
#  SPDX-License-Identifier: MIT-0 */

# --- modules/compute/variables.tf ---

 variable "ami_id" {}

 variable "instance_type" {
   default     = "t3.micro"
   description = "Name of type of EC2 instance(s) created."
 }

 variable "subnet_id" {}

 variable "initial_sg_id" {}

 variable "access_key" {}

 variable "secret_key" {}


