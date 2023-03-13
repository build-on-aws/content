# /* Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0 */

 # --- modules/iam_user/outputs.tf ---
 
 output "access_key" {
  value       = aws_iam_access_key.compromised_user_key.id
  description = "Compromised User access key"
}

output "secret_key" {
  value       = aws_iam_access_key.compromised_user_key.secret
  description = "Compromised User access key"
}

