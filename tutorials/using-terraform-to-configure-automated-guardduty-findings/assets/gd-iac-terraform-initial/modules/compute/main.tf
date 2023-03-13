# /* Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0 */

# --- modules/compute/main.tf ---

# CREATE Compromised EC2 Instance
resource "aws_instance" "compromised_instance" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [var.initial_sg_id]
  user_data              = <<-EOF
  #!/bin/bash -ex
  exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1
  sleep 5m
  echo BEGIN
  echo "* * * * * ping -c 6 -i 10 ${aws_eip.malicious_ip.public_ip}" | tee -a /var/spool/cron/ec2-user
  
  EOF

  tags = {
    Name = "GuardDuty-Example: Compromised Instance"
  }
}

# CREATE Malicious EC2 Instance
resource "aws_instance" "malicious_instance" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [var.initial_sg_id]
  user_data              = <<-EOF
  #!/bin/bash -ex
 
  EOF

  tags = {
    Name = "GuardDuty-Example: Malicious Instance"
  }
}

# CREATE ELASTIC IP
resource "aws_eip" "malicious_ip" {
  instance = aws_instance.malicious_instance.id
  vpc      = true
}
