---
title: "AWS Security Essentials"
description: "An essential guide to securing your cloud environment on AWS."
tags:
    - security
    - essentials
    - aws
authorGithubAlias: 8carroll
authorName: Brandon Carroll
date: 2021-08-10
---

## Introduction

Securing your account and cloud resources can be a daunting task. Security practices must be constantly reassessed and adjusted as bad actors continue to evolve their techniques. This guide provides you with essential tasks that you can perform from day one of your cloud journey. The following practices are considered essential to an organization's security posture, but are by no means definitive or a guarantee of protection. Apply these practices as one part of your ongoing due diligence around cloud security. For each of the following areas, we provide additional links that dive deeper into each topic.

### What is cloud security?

What is cloud security? Much like the traditional security you find in on-premises networks, cloud security involves the practice of building secure, high-performing, resilient, and efficient infrastructure for your applications. Cloud security involves the implementation of controls designed to prevent unauthorized access as well as controls to detect, respond, and remediate should the need be. Cloud security can involve a mix of network and infrastructure security, host and endpoint security, data protection and encryption, identity management, application security, and logging, monitoring, and threat detection. Cloud security is not a single thing, but rather a practice that uses tools and techniques to protect an organization's data, resources, and processes.

## What is the Shared Responsibility Model?

Security and compliance is a shared responsibility between AWS and the customer. By following this shared model, customers can reduce the operational burden as AWS assumes responsibility for operating, managing, and controlling the components "of the cloud." This leaves customers to focus on building their applications and implementing their services, while assuming responsibility of securing those services "in the cloud."
Read more about the [Shared Responsibility Model](https://aws.amazon.com/compliance/shared-responsibility-model/).

![Diagram of the Shared Responsibility Model showing which areas AWS is responsible for (security "of" the cloud), compared to the areas the customer is responsible for (security "in" the cloud)](./images/srm.png "AWS Share Responsibility Model")

## Get started by securing your AWS account

When you first [create a new AWS account](https://aws.amazon.com/getting-started/guides/setup-environment/module-one/), there are a number of recommended steps to follow to manage and access it securely.

### Root user

When you create an AWS account, you start with what is known as the root user. This is the first AWS user that exists inside your AWS account. AWS recommends that you do not use this account for day-to-day operations as it has full access and control of the account, and should follow the [recommended best practices](https://docs.aws.amazon.com/accounts/latest/reference/best-practices-root-user.html) to secure the root user. This involves locking away your root user access keys, using a strong password, enabling AWS multi-factor authentication, and [creating an IAM user](https://aws.amazon.com/getting-started/guides/setup-environment/module-two/) to access your account. This account can be assigned admin privileges and should be used for all administrative tasks going forward.

### Security contacts

Next, you should assign alternate security contacts to your account. The alternate security contact will receive security-related notifications, including notifications from the AWS Trust & Safety team. You can learn more about the importance of setting this contact information early in your account setup in the blog post [Update the alternate security contact across your AWS accounts for timely security notifications](https://aws.amazon.com/blogs/security/update-the-alternate-security-contact-across-your-aws-accounts-for-timely-security-notifications/).

### Region control

Once you have confirmed your security contacts, you should consider the [AWS Regions](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Concepts.RegionsAndAvailabilityZones.html) where your workloads should run, and the Regions where they should not. You can then [lock down the unused Regions](https://docs.aws.amazon.com/general/latest/gr/rande-manage.html) to ensure no workloads can be run from those Regions. While this helps with cost optimization, it also lends itself to security. How so? By locking down the Regions in which you do not expect to run workloads, you can focus your monitoring efforts on the Regions you actively use.

### AWS CLI and console access

At this point, you have secured the root user, created an one or more IAM users, assigned security contacts, and locked down the Regions in which workloads can run. Next, let's consider how users will interact with AWS resources. There are two primary methods of interaction: the AWS CLI and the AWS Management Console. It's recommended to set up single sign-on for the AWS CLI and the console. See the article [Configuring the AWS CLI to use AWS IAM Identity Center (successor to AWS Single Sign-On)](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-sso.html) for details on how to centrally manage access with [AWS IAM Identity Center](https://aws.amazon.com/iam/identity-center/).

### IAM groups

The next step in securing your account is to set up [AWS IAM user groups](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_groups.html) to control access. Rather than control individual users' access by setting policies directly on the user, it is best to create a group, assign the required permissions to it, and then assign users to the group. The users will inherit the permissions of that group. This offers a more scalable way of providing access control to many users. IAM and IAM groups are important to understand because they span across multiple services. IAM is one service that interacts to some degree with all AWS services, so be sure to spend time getting familiar with IAM.

Following these practices from the onset will help to provide secure access to your AWS resources. Next we will discuss how to secure the infrastructure you build on AWS.

## Securing the infrastructure you build

The infrastructure you build is often overlooked as it's part of the underlying architecture and not something that's customer facing. However, if the infrastructure fails, the services you provide your customers fail. For this reason, it's imperative that the infrastructure is [secured](https://aws.amazon.com/products/security/) from day one.

### Amazon VPC security

As you build out your cloud infrastructure, you will begin by creating an [Amazon Virtual Private Cloud](https://docs.aws.amazon.com/vpc/latest/userguide/what-is-amazon-vpc.html) (Amazon VPC). This is a virtual network that you define (a default one is created in each Region when you create your account) that allows you to launch resources. A VPC resembles a traditional network as it has a [CIDR](https://en.wikipedia.org/wiki/Classless_Inter-Domain_Routing) IP address range assigned to it, and is subdivided by [creating subnets](https://docs.aws.amazon.com/vpc/latest/userguide/configure-subnets.html). Your subnets can be used to provide isolation for different sets of resources. Subnets can either be public or private. [Public subnets](https://docs.aws.amazon.com/vpc/latest/userguide/VPC_Scenario1.html) have a route to an [Internet Gateway](https://docs.aws.amazon.com/vpc/latest/userguide/VPC_Internet_Gateway.html), have access to the internet through this gateway, and can be reached from the internet if the relevant access controls allow it. [Private subnets](https://docs.aws.amazon.com/vpc/latest/userguide/VPC_Scenario2.html) have a routing table as well, but do not have a route to an Internet Gateway, so by default cannot reach the internet, and cannot be reached from the internet. To enable resources in a private subnet to access the internet, a [NAT gateway](https://docs.aws.amazon.com/vpc/latest/userguide/vpc-nat-gateway.html) is needed. At the subnet level, a network access control list ([ACL](https://docs.aws.amazon.com/AmazonS3/latest/userguide/acl-overview.html)) [allows or denies](https://docs.aws.amazon.com/vpc/latest/userguide/vpc-network-acls.html) specific inbound or outbound traffic. You can use the default network ACL for your VPC, or you can create a custom network ACL for your VPC. Network ACLs are numbered lists, processed in top-down order, and are stateless. This means that you will need an inbound and outbound network ACL rule to allow bidirectional traffic.

### Security groups

As you deploy EC2 resources into your VPC, you will associate a [security group](https://docs.aws.amazon.com/vpc/latest/userguide/VPC_SecurityGroups.html) with them. A security group controls the inbound and outbound traffic that can reach the EC2 resources. Security groups are similar to a firewall, but instead of using just a list or range of IP addresses, they can point to something called a resource reference. A resource reference is a named group that maintains an updated list of IP addresses assigned to each resource in the group. As an example, if you create an autoscaling group to spin up Amazon EC2 instances, each instance is assigned a new IP when it starts up. By adding a security group to these instances, you can grant access to your database server's security group via the EC2 instances' security group ID, and any new EC2 instance launched will have access to the database without needing to add its IP address to the allowed list. 

Security group rules are similar to network ACLs because when you create them, you match on port, protocol, and addresses, but they are stateful—you can think of them as being similar to a stateful firewall. When you create an entry to allow a specific type of traffic, you do not need to create a rule to match the return traffic; being stateful, the return traffic will be allowed. To better understand how security groups and ACLs interact, [this comparison is useful](https://docs.aws.amazon.com/vpc/latest/userguide/VPC_Security.html#VPC_Security_Comparison).

### AWS Network Firewall and DDoS protection

To add an additional layer of infrastructure security, you can deploy the [AWS Network Firewall](https://aws.amazon.com/network-firewall/). The Network Firewall is a managed service that deploys protection for your Amazon VPC. It provides more fine-grained protection than security groups, because it can incorporate context from traffic flows, like tracking connections and protocol identification, to enforce policies such as preventing your VPCs from accessing domains using an unauthorized protocol. This is done through the configuration of custom [Suricata Rules](https://suricata.readthedocs.io/en/suricata-6.0.0/rules/). For example, you can configure the [Network Firewall to protect against malware attacks](https://aws.amazon.com/blogs/security/how-to-deploy-aws-network-firewall-to-help-protect-your-network-from-malware/). Taking this a step further, you can deploy another managed service, [AWS Shield Advanced](https://aws.amazon.com/shield/), to protect against DDoS threats.

## Securing the resources you create

As you create resources in the AWS Cloud, you must consider how to secure them based on current best practices. This is true if you deploy an EC2 instance, a database, or serverless resources. In this section, we will provide some essential steps to secure the resources you create.

### Amazon EC2 security

As you create resources in AWS, you should take care to follow recommended security best practices for the type of resource you are working with. For EC2 instances, security begins by [controlling network access](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/infrastructure-security.html#control-network-traffic) to your instances, for example, through configuring your VPC and security groups—see the [Amazon VPC security](#amazon-vpc-security) section.

Another aspect of instance security is management of the credentials used to connect to your instances. This starts with the IAM user permissions you assign, but extends to the group assigned. This provides a level of security for the user working with the EC2 instance, but not for the instance itself. You should also configure [IAM roles](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/iam-roles-for-amazon-ec2.html) that are attached to the instance and permissions associated with those roles. To access an EC2 instance, instead of opening up the port for [SSH](https://en.wikipedia.org/wiki/Secure_Shell), or setting up a [bastion/jump jost](https://aws.amazon.com/blogs/mt/replacing-a-bastion-host-with-amazon-ec2-systems-manager/), you should use [EC2 Instance Connect](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-instance-connect-methods.html).

You should ensure that the guest operating system and software deployed to the instance is [up to date with any operating system updates and security patches](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/update-management.html). For more details, visit [Security in Amazon EC2](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-security.html).

### Database security

Securing your database is an important aspect of your security approach. As mentioned in the [Amazon VPC security](#amazon-vpc-security) section, it is recommended to deploy databases to a private subnet to prevent access from external parties over the internet. AWS offers 15 purpose-built databases. Each is secured differently, but all share the following in common.

### Authentication

To access a database, some form of authentication is required. This can take the form of a user name and password, which should be [rotated on a regular basis](https://aws.amazon.com/blogs/security/rotate-amazon-rds-database-credentials-automatically-with-aws-secrets-manager/). You can alternatively make use of [Amazon RDS Proxy](https://aws.amazon.com/rds/proxy/) to leverage IAM roles to manage access to the database for you. Some of the database services, like [Amazon DynamoDB](https://aws.amazon.com/dynamodb/), use [IAM roles](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/authentication-and-access-control.html) to provide access, so you do not need to manage any credentials yourself.

### Console-based SSH access

SSH is one of the most common methods of managing your EC2 instances and Amazon EC2 Instance Connect allows you to use SSH to connect to your EC2 instances using one-time SSH keys directly in the console. The following articles provides a walk-through of how to [enable Amazon EC2 Instance Connect](https://aws.amazon.com/blogs/security/use-ec2-instance-connect-to-provide-secure-ssh-access-to-ec2-instances-with-private-ip-addresses/) and explains the typical use case.  You can also generate SSH keys when you create your EC2 instance, download them locally, and use them to connect to your instance. However, this means you must protect those keys, ensure they are stored somewhere that you will not lose access to, and can only connect to your instance from a machine that has those keys downloaded. EC2 Instance Connect provides the same SSH access, securely, from the console, across machines, in a simple-to-use manner.

### Minimum permissions

Restricting access to your database only to services and infrastructure that require access is a recommended best practice. This can be done by [setting up security groups](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Overview.RDSSecurityGroups.html) for your RDS instances, [Amazon Neptune](https://aws.amazon.com/neptune/) [databases](https://docs.aws.amazon.com/neptune/latest/userguide/get-started-security.html), or for [Amazon Redshift](https://aws.amazon.com/redshift/) [clusters](https://docs.aws.amazon.com/redshift/latest/dg/r_Database_objects.html).

### Backing up and testing restores

Backing up your data and running frequent restores to confirm the backups are working correctly should be a priority. With [AWS Backup](https://aws.amazon.com/backup/), you can easily configure and manage backups for specific AWS services, including Amazon RDS, DynamoDB, Neptune, and more.

### Serverless security

For serverless security, you should be familiar with [AWS Lambda](https://aws.amazon.com/lambda/), [Amazon API Gateway](https://aws.amazon.com/api-gateway/), Amazon DynamoDB, [Amazon SQS](https://aws.amazon.com/sqs/), as well as [IAM](https://aws.amazon.com/iam/). With serverless security, AWS takes a greater responsibility as compared to the Shared Responsibility Model, but there is still a customer responsibility to be aware of. In a serverless environment, AWS manages the infrastructure, compute, execution environment, and runtime language. The customer is responsible for the customer function code and libraries, resource configuration, and identity and access management, as shown in the following image.

![Shared responsibility model for serverless](images/srm-lambda.png)

In the following sections, we provide details about security practices that are the customer's responsibility. For additional details, see [Security in AWS Lambda](https://docs.aws.amazon.com/lambda/latest/dg/lambda-security.html).

#### Customer function code and libraries

AWS Lambda provides runtimes that run your function code in an Amazon Linux–based execution environment. However, if you use additional libraries with your function, you're responsible for updating the libraries. Ensuring your libraries are up to date can help to maintain your security posture.

#### Resource configuration

AWS Lambda integrates with several AWS resources such as Amazon DynamoDB, Amazon EventBridge, and Amazon Simple Notification Service (Amazon SNS). Following the recommended security practices for each service you use as part of your function will help strengthen your security posture. The documentation for each service provides additional guidance.

#### Identity and Access Managemenment

Execution of Lambda functions may require specific IAM permissions and roles. More details can be found in the [Permissions](https://docs.aws.amazon.com/lambda/latest/dg/lambda-intro-execution-role.html) section of the AWS Lambda Developer Guide.

#### Inventory and configuration

Your security strategy should also include [monitoring, logging, and configuration management](https://docs.aws.amazon.com/serverlessrepo/latest/devguide/security-logging-monitoring.html). For example, many organizations enable accounting of their devices using the TACACS+ protocol, RADIUS, or Active Directory logs. This helps to ensure that an audit trail is created for all administrative activity. Within the AWS Cloud, this can be done with AWS CloudTrail. CloudTrail enables auditing, security monitoring, and operational troubleshooting by tracking user activity and API usage. The AWS Serverless Application Repository, which makes it easy for developers and enterprises to quickly find, deploy, and publish serverless applications in the AWS Cloud, is integrated with AWS CloudTrail. For additional details, see the [AWS Serverless Application Repository Developer Guide](https://docs.aws.amazon.com/serverlessrepo/latest/devguide/security-logging-monitoring.html).

You will still need to provide DoS and infrastructure protection to some degree for your serverless environments, which can be done with AWS Shield and AWS Shield Advanced. Monitoring and detecting threats is discussed more in the ["Monitoring your environment"](#monitoring-your-environment)section.

## Securing your data

Customers store a great deal of data in the AWS Cloud. This data contains information that is critical to the operation of an organization. It includes customer data, intellectual property, orders linked directly to revenue, and more. In this section, we share essentials on how to configure data that is stored on AWS as well as data that is transferred over the network to and from AWS.

### Amazon S3 security

On AWS, data is stored in Amazon S3, which has several controls to protect data. The article [Top 10 security best practices for securing data in Amazon S3](https://aws.amazon.com/blogs/security/top-10-security-best-practices-for-securing-data-in-amazon-s3/) covers the most fundamental techniques. These include blocking public S3 buckets at the organization level, using bucket policies to verify all access granted is restricted and specific, and encrypting and protecting data.

### Encrypting data at rest

For encryption, AWS Key Management Service (AWS KMS) allows you to create and control keys used to encrypt or digitally sign your data. If you want to encrypt your data on AWS, you have a few options. The first is to use [server-side encryption with Amazon S3-managed encryption keys (SSE-S3)](https://docs.aws.amazon.com/AmazonS3/latest/userguide/UsingServerSideEncryption.html). Using this method, the encryption happens after the data is sent to AWS using keys that are managed by AWS.

The second option is to encrypt the data once it's in AWS, but rather than using keys that are created and managed by AWS, you can perform server-side encryption with customer master keys (CMKs) that are stored in AWS KMS ([SSE-KMS](https://docs.aws.amazon.com/kms/latest/developerguide/services-s3.html).

The third option for storing encrypted data on AWS is to use client-side encryption. With this approach, the data is encrypted prior to being transferred to AWS.

An example of how both client-side encryption and server-side encryption benefits customers can be seen in the following image.

![Client-side encryption](images/client-server-side-enc.png)

### Virtual private networks (VPNs)

VPNs can encompass several technologies. The idea behind a VPN is that your data in transit maintains its integrity and can be securely exchanged between two parties. AWS offers multiple technologies that help to keep your data-in-transit secure. One of those is [AWS PrivateLink](https://www.youtube.com/watch?v=_mHLkFeTuFo), which provides encrypted, private connectivity between VPCs, AWS services, and your on-premises networks. This is done without exposing your traffic to the public internet. This too could be considered a virtual private network.

However, in most cases, a discussion of VPN revolves around the use of data encryption. Depending on the circumstances, you may need to provide encryption between a client and your AWS cloud resources. This situation would require [AWS Client VPN](https://aws.amazon.com/vpn/client-vpn/). On the other hand, you might be passing data between your data center or branch office and your AWS resources. You can accomplish this using IPsec tunnels between your on-premises resources and your our Amazon VPCs or AWS Transit Gateway. This secure connectivity is known as [Site-to-Site VPN](https://aws.amazon.com/vpn/site-to-site-vpn/).

Lastly, managing your cloud resources using the AWS Management Console also offers encrypted data-in-transit. While you would not normally refer to connectivity with the console as a VPN, your session uses TLS (Transport Layer Security) encryption. Thus, your configurations are kept confidential as you build your secure architecture. TLS is also used with the AWS API.

## Monitoring your environment

With each of the above aspects secured, it's essential that you monitor what's happening in your environment. This will help to identify threats and offer the ability to proactively mitigate them.

### Visibility into traffic flows

AWS offers several managed services to assist in monitoring of your environment, along with self-service options. For example, you can use [VPC Flow Logs to log and view network traffic flows](https://aws.amazon.com/blogs/aws/vpc-flow-logs-log-and-view-network-traffic-flows/), or you can use Amazon CloudWatch to [analyze AWS WAF Logs](https://aws.amazon.com/blogs/mt/analyzing-aws-waf-logs-in-amazon-cloudwatch-logs/) or even to [create alarms for EC2 instances](https://aws.amazon.com/blogs/mt/use-tags-to-create-and-maintain-amazon-cloudwatch-alarms-for-amazon-ec2-instances-part-1/). You can learn more about Amazon CloudWatch in [this workshop](https://catalog.us-east-1.prod.workshops.aws/workshops/a8e9c6a6-0ba9-48a7-a90d-378a440ab8ba/en-US).

### Visibility into account activity

Additionally, [AWS CloudTrail](https://aws.amazon.com/cloudtrail) monitors and records account activity across your AWS infrastructure, giving you control over storage, analysis, and remediation actions. This is essential for creating an administrative audit trail, identifying security incidents, and for troubleshooting operational issues.

### Detecting threats

Finally, [Amazon GuardDuty](https://aws.amazon.com/guardduty/) can be used for threat detection, and even to take it a step further by causing the published findings to initiate auto-remediation actions within your AWS environment.

By addressing each of these operational areas, you will be well on your way to establishing essential security features for your cloud environment.
