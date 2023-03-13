/* Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
 SPDX-License-Identifier: MIT-0 */
 
# --- modules/vpc/main.tf ---

# AVAILABILITY ZONE
 data "aws_availability_zones" "available" {
   state = "available"
 }

# VPC
 resource "aws_vpc" "vpc" {
   cidr_block           = var.cidr_block
   instance_tenancy     = var.tenancy
   enable_dns_support   = true
   enable_dns_hostnames = true

   tags = {
     Name = var.vpc_name
   }
 }




 # INITIAL SECURITY GROUP
 resource "aws_security_group" "initial_sg" {
   vpc_id = aws_vpc.vpc.id
   name   = "${var.vpc_name}-InitialSecurityGroup"

   ingress {
     protocol    = "icmp"
     self        = true
     from_port   = -1
     to_port     = -1
     cidr_blocks = ["10.0.0.0/24"]
   }

   egress {
     from_port   = 0
     to_port     = 0
     protocol    = "-1"
     cidr_blocks = ["0.0.0.0/0"]
   }

   tags = {
     Name = "${var.vpc_name}-InitialSecurityGroup"
   }
 }


# NACL
 resource "aws_network_acl" "guardDuty_nacl" {
   vpc_id     = aws_vpc.vpc.id
   subnet_ids = [aws_subnet.public_subnet.id]

   egress {
     protocol   = "-1"
     rule_no    = 100
     action     = "allow"
     cidr_block = "0.0.0.0/0"
     from_port  = 0
     to_port    = 0
   }

   ingress {
     protocol   = "-1"
     rule_no    = 100
     action     = "allow"
     cidr_block = "0.0.0.0/0"
     from_port  = 0
     to_port    = 0
   }

   tags = {
     Name = "${var.vpc_name}-NACL"
   }
 }

# SUBNETS
# Create n Public Subnet
 resource "aws_subnet" "public_subnet" {
   vpc_id                  = aws_vpc.vpc.id
   cidr_block              = var.subnet_cidr
   availability_zone       = data.aws_availability_zones.available.names[0]
   map_public_ip_on_launch = true

   tags = {
     Name = "${var.vpc_name}-public-subnet"
   }
 }

# INTERNET GATEWAY
 # Access to public internet
 resource "aws_internet_gateway" "igw" {
   vpc_id = aws_vpc.vpc.id

   tags = {
     Name = "${var.vpc_name}-igw"
   }
 }

# ROUTE TABLES
 # Any subnet that is created will be added to this table
 resource "aws_route_table" "public_rt" {
   vpc_id = aws_vpc.vpc.id

   route {
     cidr_block = "0.0.0.0/0"
     gateway_id = aws_internet_gateway.igw.id
   }

   tags = {
     Name = "${var.vpc_name}-public-rt"
   }
 }

# ROUTE TABLE ASSOCIATION
 resource "aws_route_table_association" "subnet_association" {
   subnet_id      = aws_subnet.public_subnet.id
   route_table_id = aws_route_table.public_rt.id
 }

