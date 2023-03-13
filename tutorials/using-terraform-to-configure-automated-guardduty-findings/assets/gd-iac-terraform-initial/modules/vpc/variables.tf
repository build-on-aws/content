/* Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
 SPDX-License-Identifier: MIT-0 */
 
 # --- modules/vpc/variables.tf ---

 variable "cidr_block" {
   description = "CIDR block of VPC."
 }

 variable "tenancy" {
   default     = "default"
   description = "VPC Tenancy"
 }

  variable "vpc_name" {
   type        = string
   description = "Name of the VPC where the EC2 instance(s) are created."
 }

variable "subnet_cidr" {
   description = "Subnet block where the EC2 instance(s) are created."
 }
