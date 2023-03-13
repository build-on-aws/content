/* Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
   SPDX-License-Identifier: MIT-0 */

# Outputs that will dsiplay to the terminal window.

# --- root/outputs.tf ---

output "vpc_id" {
  value       = module.vpc.vpc_id
  description = "Output of VPC id created."
}

output "initial_sg_id" {
  value       = module.vpc.initial_sg_id
  description = "Output of initial sg id created."
}
