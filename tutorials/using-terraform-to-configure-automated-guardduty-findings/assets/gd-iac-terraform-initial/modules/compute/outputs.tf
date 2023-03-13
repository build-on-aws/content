# /* Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0 */

# --- modules/compute/outputs.tf ---

output "malicious_ip_id" {
  value       = aws_eip.malicious_ip.id
  description = "Output of elastic ip id created - to place the EC2 instance(s) or VPC endpoints."
}

output "malicious_ip" {
  value       = aws_eip.malicious_ip.public_ip
  description = "Output of elastic ip created - to place the EC2 instance(s) or VPC endpoints."
}

output "compromised_instance_id" {
  value       = aws_instance.compromised_instance.id
  description = "Output of elastic ip id created - to place the EC2 instance(s) or VPC endpoints."
}