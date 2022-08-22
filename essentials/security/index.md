---
layout: blog.11ty.js
title: AWS Security Essentials
description: An essential guide to securing your cloud environment on AWS.
tags:
authorGithubAlias: 8carroll
authorName: Brandon Carroll
date: 2021-08-10
---

## Introduction

## What is cloud security?

What is cloud security?  Much like the traditional security you find in on-premises networks, cloud security involves the practice of building secure, high-performing, resilient, and efficient infrastructure for your applications. Cloud security involves the implementation of controls designed to prevent attack as well as controls to detect, respond, and remediate should the need be.  Cloud Security can involve a mix of Network and Infrastructure security, Host and Endpoint Security, Data Protection and Encryption, Identity Management, Application Security, and Logging, Monitoring and Threat Detection.  Cloud Security is not a single thing, but rather a practice that makes use of tools and techniques to protect an organizations data, resources, and processes.

## What is Shared Responsibility?
Security and Compliance is a shared responsibility between AWS and the customer. By following this shared model, customers can reduce the operational burden as AWS assumes responsability for operating, managing, and controlling the components "of the cloud."  This leaves customers to do what they do best, and implement their services assuming responsability of securing those services "in the cloud."
Read more about the [Shared Responsibility Model](_https://aws.amazon.com/compliance/shared-responsibility-model/_) here.

## Getting Started With a Secure Account.

1. Secure the root user
2. Assigning Security Contacts
3. Locking Down Unused Regions
4. SSO for console and CLI
5. IAM roles / groups to limit access'
6. Regular key / password rotation

When you create an AWS account you start with what is known as the root user.  This is the first AWS user that exists inside your AWS account.  AWS recommends that you do not use this account for day-to-day operations.  However, you should still follow [recommended practices](https://docs.aws.amazon.com/accounts/latest/reference/best-practices-root-user.html) to secure this account.  This involves locking away your root user access keys, using a strong password, and enabling AWS multi-factor authentication.  In addition to locking down the root user you will then want to [create an IAM user](https://aws.amazon.com/premiumsupport/knowledge-center/create-new-iam-user/) in your account.  This account can be assigned admin rights and should then be used for all administrative tasks.

Next you should assign alternate security contacts to your account. The alternate security contact will receive security-related notifications, including notifications from the AWS Abuse Team. You can learn more about the importance of setting this contact information early in your account setup in the blog post:[Update the alternate security contact across your AWS accounts for timely security notifications](https://aws.amazon.com/blogs/security/update-the-alternate-security-contact-across-your-aws-accounts-for-timely-security-notifications/).  

Once you have your security contacts specified you should consider the regions where your workloads should run, and the regions where they should not.  You can then lock down the unused regions to ensure no workloads can be run from these regions. While this could be related to cost optimization, it also lends itself to security.  How so?  By locking down the regions in which you do not expect to see workloads you will not need to monitor these regions as you would with regions you actively use.

At this point you have secured the root user, created an one or more IAM users, assigned security contacts, and locked down the regions in which workloads can run.  Next let's consider how users will interact with AWS resources.  There are two primary methods of interaction, the AWS CLI and the AWS Console.  It's recommended to setup Single Sign-on for the AWS CLI and AWS Console.  See the article, [Configuring the AWS CLI to use AWS IAM Identity Center (successor to AWS Single Sign-On)](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-sso.html) for details on how to set up AWS Single Sign-on, now known as AWS IAM Identity Center.

The next step in securing your account is to setup IAM roles and groups to control access.  Rather than control individual user access it's best to create a role or a group and assign users to the group.  They will inherit the permissions of that group.  This offers a more scaleable way of providing access control to mamy users.

And finally, each user account has a password associated with it as well as access-keys for programatic access.  You should rotate these keys regulary.  Presciptive guidance is availabe to help you [Automatically rotate IAM user access keys at scale with AWS Organizations and AWS Secrets Manager](https://docs.aws.amazon.com/prescriptive-guidance/latest/patterns/automatically-rotate-iam-user-access-keys-at-scale-with-aws-organizations-and-aws-secrets-manager.html)

Following these practices from the onset will help to provide secure access to your AWS resources.  Next we will discuss how to secure the infrastructure you build on AWS.


## Securing the Infrastructure You Build

1. VPC Security
2. Security Groups
3. Network Firewall
4. Secure Management Connectivity
5. DDoS Mitigation
6. 

## Securing the Resources You Create

1. EC2
2. Databases
3. Serverless
4. Inventory and Configuration
5. 

## Securing your data

1. S3
2. KMS
3. VPN

## Monitoring your environment

1. AWS CloudTrail
2. Amazon CloudWatch
3. VPC Flow Logs
4. Amazon GuardDuty

