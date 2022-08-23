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

## Get Started by Securing Your AWS Account.

1. Secure the root user
2. Assigning Security Contacts
3. Locking Down Unused Regions
4. SSO for console and CLI
5. IAM roles / groups to limit access'
6. Regular key / password rotation

### Root User

When you create an AWS account you start with what is known as the root user.  This is the first AWS user that exists inside your AWS account.  AWS recommends that you do not use this account for day-to-day operations.  However, you should still follow [recommended practices](https://docs.aws.amazon.com/accounts/latest/reference/best-practices-root-user.html) to secure this account.  This involves locking away your root user access keys, using a strong password, and enabling AWS multi-factor authentication.  In addition to locking down the root user you will then want to [create an IAM user](https://aws.amazon.com/premiumsupport/knowledge-center/create-new-iam-user/) in your account.  This account can be assigned admin rights and should then be used for all administrative tasks.

### Security Contacts

Next you should assign alternate security contacts to your account. The alternate security contact will receive security-related notifications, including notifications from the AWS Abuse Team. You can learn more about the importance of setting this contact information early in your account setup in the blog post:[Update the alternate security contact across your AWS accounts for timely security notifications](https://aws.amazon.com/blogs/security/update-the-alternate-security-contact-across-your-aws-accounts-for-timely-security-notifications/).  

### Region Control

Once you have your security contacts specified you should consider the regions where your workloads should run, and the regions where they should not.  You can then lock down the unused regions to ensure no workloads can be run from these regions. While this could be related to cost optimization, it also lends itself to security.  How so?  By locking down the regions in which you do not expect to see workloads you will not need to monitor these regions as you would with regions you actively use.

### CLI and Console Access

At this point you have secured the root user, created an one or more IAM users, assigned security contacts, and locked down the regions in which workloads can run.  Next let's consider how users will interact with AWS resources.  There are two primary methods of interaction, the AWS CLI and the AWS Console.  It's recommended to setup Single Sign-on for the AWS CLI and AWS Console.  See the article, [Configuring the AWS CLI to use AWS IAM Identity Center (successor to AWS Single Sign-On)](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-sso.html) for details on how to set up AWS Single Sign-on, now known as AWS IAM Identity Center.

### IAM Roles

The next step in securing your account is to setup IAM roles and groups to control access.  Rather than control individual user access it's best to create a role or a group and assign users to the group.  They will inherit the permissions of that group.  This offers a more scaleable way of providing access control to mamy users.

### Key Rotation

And finally, each user account has a password associated with it as well as access-keys for programatic access.  You should rotate these keys regulary.  Presciptive guidance is availabe to help you [Automatically rotate IAM user access keys at scale with AWS Organizations and AWS Secrets Manager](https://docs.aws.amazon.com/prescriptive-guidance/latest/patterns/automatically-rotate-iam-user-access-keys-at-scale-with-aws-organizations-and-aws-secrets-manager.html)

Following these practices from the onset will help to provide secure access to your AWS resources.  Next we will discuss how to secure the infrastructure you build on AWS.


## Securing the Infrastructure You Build

1. VPC Security
2. Security Groups
3. Network Firewall
4. DDoS Mitigation

### VPC Security

As you build out your cloud infrastructure you'll begin by creating a [Virtual Private Cloud](https://docs.aws.amazon.com/vpc/latest/userguide/what-is-amazon-vpc.html) (VPC).  This is a virtual network that you define (a default exists as well) that allows you to then launch resources.  A VPC resembles a traditional network.  It has a CIDR range assigned to it and within the VPC you create subnets.  Your subnets can be used to provide isolation.  Subnets can be public or private.  Public subnets have a route to an Internet gateway.  Private subnets have a routing table as well but do not have a route to an Internet gateway  At the subnet level, a network access control list (ACL) allows or denies specific inbound or outbound traffic. You can use the default network ACL for your VPC, or you can create a custom network ACL for your VPC.  Network ACLs are numbered lists, processed in top-down order, and are not stateful.  This means that you will need an inbound and outbound network ACL to allow bi-directional traffic.  

### Security Groups

As you deploy resources into your VPC you can associate Security Groups with them.  A Security Group controls the traffic that is allowed to reach and leave the resources that it is associated with.  Security Group rules are similar to Network ACLs.  When creating them you match on port, protocol, and addresses. In many cases Network ACLs will be configured to match on the same ports, protocols, and addresses of a Security Group.  This will add another layer of protection to the resource.  Security Groups are stateful.  You can look at them much in the same way as a Stateful Firewall.  When you create an entry to allow a specific type of traffic, you do not need to create a rule to match the return traffic.  Being stateful, the return traffic will be allowed.

### AWS Network Firewall and DDoS Protection

To add an additional layer of infrastructure security you can deploy the AWS Network Firewall.  The AWS Network Firewall is a managed service that deploys protection for your Amazon VPC.  The AWS Network Firewall provides more fine-grained protection than Security Groups. This is done through the congfiguration of custom [Suricata Rules](https://suricata.readthedocs.io/en/suricata-6.0.0/rules/). For example, you can configure the [AWS Network Firewall to protect against Malware attacks](https://aws.amazon.com/blogs/security/how-to-deploy-aws-network-firewall-to-help-protect-your-network-from-malware/).  Taking this a step further you can deploy another managed service, AWS Shield Advanced to protect against DDoS threats.




5. Secure Management Connectivity

## Securing the Resources You Create

1. EC2
2. Databases
3. Serverless
4. Inventory and Configuration

### EC2 Security

As you create resources in AWS you must take care to follow recommended security practices for the type of resource you are working with.  For EC2 instances security begins by [controlling network access](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/infrastructure-security.html#control-network-traffic) to your instances, for example, through configuring your VPC and security groups. This has already been discussed above.  

Another aspect of instance security is that of managing the credentials used to connect to your instances.  This starts with the IAM user permissions you assign, but extends to the group assigned.  This provides a level of security for the user working with the EC2 instance, but not for the instance itself.  You should also configure [IAM roles](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/iam-roles-for-amazon-ec2.html) that are attached to the instance and permissions associated with those roles.

Also, ensure the guest operating system and software deployed to the [guest operating system is up-to-date with any operating system updates and security patches](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/update-management.html).

Find more details on [Security in Amazon EC2 here.](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-security.html)

### Database Security

Another resource type that deserves security consideration is your databases.  AWS offers 15 purpose-built databases, including relational, key-value, document, in-memory, graph, time-series, and ledger databases.  Each of these databases have unique charactersitics, however with each of them the areas to be aware of include:

- Authentication
- Minimum permissions
- Rotation of credentials
- Access Control

Be sure to check the database specific [documentation](https://docs.aws.amazon.com/) for current best practices.

### Serverless Security

For serverless security you should be familiar with AWS Lambda, Amazon API Gateway, Amazon DynamoDB, Amazon SQS, as well as Identity and Access Management.  With Serverless security, AWS takes a greater responsability as compared to the shared responsability model.  As a customer you would be responsible for the data, applications, and IAM, as well as data encryption and integrity authentication, and monitoring and logging.  You can see this in the image below.

![](/security/images/srm-lambda.png)

While many techniques are similar regarding serverless security, they will vary slightly.  Even so, you must continue to use authentication and authorization mechanisms.  No doubt you will continue to provide [data encryption and integrity](https://docs.aws.amazon.com/lambda/latest/dg/security-dataprotection.html).  

### Inventory and Configuration

Your security strategy should also include [monitoring, logging, and configuration management](https://docs.aws.amazon.com/serverlessrepo/latest/devguide/security-logging-monitoring.html).  And you will still need to provide DoS and Infrastructure Protection to some degree which can be done with AWS Sheild and AWS Sheild Advanced.


## Securing your data


1. S3
2. KMS
3. VPN

### S3 Security

The next essential for cloud security is the protection of data.  In AWS data is stored in S3.  S3 have several controls to protect the data.  The article, [Top 10 security best practices for securing data in Amazon S3](https://aws.amazon.com/blogs/security/top-10-security-best-practices-for-securing-data-in-amazon-s3/) covers the most fundamental techniques.  These techniques include blocking public S3 buckets at the organization level, using bucket policies to verify all access granted is restricted and specific, encryption, and protection.  

### KMS

For Encryption you can make use of [Server-side encryption with Amazon S3-managed encryption keys (SSE-S3)](https://docs.aws.amazon.com/AmazonS3/latest/userguide/UsingServerSideEncryption.html), Server-side encryption with customer master keys (CMKs) stored in AWS KMS ([SSE-KMS](https://docs.aws.amazon.com/kms/latest/developerguide/services-s3.html)) or Client-side encryption. 

### VPN

When your data is not at rest you can use [Client or Site-tosite VPN](https://aws.amazon.com/vpn/) to protect the data in transit.


## Monitoring your environment

1. AWS CloudTrail
2. Amazon CloudWatch
3. VPC Flow Logs
4. Amazon GuardDuty

### AWS VPC Flow Logs and Amazon CloudWatch

After covering the essentials of cloud security in the above areas it's beneficial to close out our list of essentials by discussing how you can monitor your environment.  AWS offers several managed services to assist in this regard, along with self-service options.  For example, you can [use VPC Flow Logs to log and view network traffic flows](https://aws.amazon.com/blogs/aws/vpc-flow-logs-log-and-view-network-traffic-flows/), or you can make use of Amazon CloudWatch to [analyze AWS WAF Logs](https://aws.amazon.com/blogs/mt/analyzing-aws-waf-logs-in-amazon-cloudwatch-logs/) or even to [create alarms for EC2 instances](https://aws.amazon.com/blogs/mt/use-tags-to-create-and-maintain-amazon-cloudwatch-alarms-for-amazon-ec2-instances-part-1/).  

### AWS CloudTrail

Aditionally, [AWS CloudTrail](https://aws.amazon.com/cloudtrai) monitors and records account activity across your AWS infrastructure, giving you control over storage, analysis, and remediation actions. This is essential for creating an administrative audit trail, identifying security incidents, and for troubleshooting operational issues.

### Amazon GuardDuty

Finally, Amazon GuardDuty can be used to provide threat detection, and even to take it a step further by causing the published findings to initiate auto-remediation actions within your AWS Environment.

By addressing each of these operational areas you will be well on your way to providing essential security features to your cloud environment.




