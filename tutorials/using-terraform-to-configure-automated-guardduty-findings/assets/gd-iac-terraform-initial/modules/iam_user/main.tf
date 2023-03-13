# /* Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0 */

# --- modules/iam_user/main.tf ---

data "aws_caller_identity" "current" {}

resource "aws_iam_user" "compromised_user" {
  name = "CompromisedUser"
}

resource "aws_iam_access_key" "compromised_user_key" {
  user = aws_iam_user.compromised_user.name
}

resource "aws_iam_user_policy" "compromised_user_policy" {
  name = "compromised_user_policy"
  user = aws_iam_user.compromised_user.name

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "ssm:GetParameter",
        "ssm:GetParameters",
        "ssm:DescribeParameters"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:ssm:us-east-1:${data.aws_caller_identity.current.account_id}:*"
    }
  ]
}
EOF
}
