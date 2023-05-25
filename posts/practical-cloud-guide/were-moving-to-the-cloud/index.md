---
title: "We're Moving to the Cloud"
description: "Introduction to the Practical Cloud Guide, a series of articles and tutorials to help IT Administrators and Pros successfully transition to the cloud."
tags:
  - "IT Pros"
  - "migration"
authorGithubAlias: "spara" 
authorName: "Sophia Parafina"
date: "2023-31-05"
---

It’s Monday morning, you’ve heard the rumors and now it’s official:

> “As my first act as the CTO, I am pleased to announce that we are moving our IT operations to the cloud. We are undertaking digital transformation to reduce cost, enable IT resource availability to staff anywhere in the world, create opportunities for faster digital innovation, and bring limitless opportunities from a business growth perspective. Our team is well-equipped to handle this transition and I am confident that it will bring many benefits to our organization. I look forward to seeing the results.”

You’re a Senior System/Network/Database Administrator or a Systems Analyst or IT Director managing your company’s on premise IT resources. You’ve experimented with the cloud on your own time or taken an online course to get a certification, but you don’t have hands-on experience building cloud infrastructure or migrating applications to the cloud.

*The Practical Cloud Guide for IT Professionals* is a hands-on learning journey to cloud engineering. The guide demonstrates how to migrate infrastructure and applications with step-by-step instructions for perfoming common infrastructure, networking, and administration tasks in the cloud. These tasks are:

1. Deploying a web application from start to finish, including building the infrastructure to host the application securely.
2. Creating and migrating a relational data base to the cloud and connecting it to an application.
3. Provision user access to cloud services and resources by creating an organization and adding users with the proper role and access credentials
4. Provision storage for users and deploying different types of cloud storage, i.e., object storage for logs, block storage for the database, and file storage.
5. Migrate an application to containers with a lift-and-shift approach.
6. Deploy a hybrid environment with both on-premise cloud resources and on-premise applications connected to cloud resources.

## The road map

Introductions to cloud infrastructure often dive into the many components needed to deploy an application. The *Practical Guide* takes a different approach and begins with completing common tasks with managed services that reduce the cloud engineering learning curve. The next section uses the same tasks to dive deep into cloud infrastructure and cover compute, networking, storage, databases, monitoring, and security. The last section of the Guide explains how to automate building and maintaining infrastructure. In addition, the Guide covers  Continuous Integration and Continuous Delivery/Deployment and Infrastructure as Code.

Performing these tasks facilitates the transition from on-premise enterprise environments to the cloud by developing the skills for deploying and maintaining applications in the cloud.

1. Appropriate machine sizing and scaling.
2. Server configuration, deployment, and maintenance.
3. Building networking that supports internal and external networking for ingress, egress, and resource sharing.
4. Network security.
5. Application security.
6. Organization and user management.
7. Application deployment, maintenance, performance monitoring, and logging.
8. Database creation and data migration.
9. Application migration and deployment to containers.
10. Hybrid environments that combine on-premise and cloud resources.

## IT Pro cloud journey

The learning journey is divided into three stages. Progressive success is key for engaging and encouraging IT Pros to continue their cloud journey. Early successes result in continued engagement and are building blocks for more complex tasks. Onboarding should provide an environment that removes barriers to success such as complex configurations and introduction of complex topics early on. 

When onboarding is complete, the IT Pro journey moves to learning the infrastructure concepts and how to implement them in AWS. They will build the infrastructure to complete the five tasks. This is accomplished in a stepwise progression which creates the environment to deploy applications, manage users, provision storage, create a database, and migrate an application to containers.

The final part of the journey introduces Infrastructure as Code and shows how to build and maintain infrastructure using Cloud Formation and CDK.

*Stage 1: Run in the Cloud*
AWS Lightsail is the gateway to AWS. IT Pros can focus on accomplishing all five tasks with ready to run services and resources. IT Pros will learn about AWS resources and the concepts behind them without having to build infrastructure by onboarding with AWS Lightsail.

This part of the IT Pro journey completes the five tasks, i.e., building to run applications and services that they would do in an on premise enterprise environment.

*Stage 2: Build in the Cloud*
This stage of the IT Pro journey teaches how to build and maintain infrastructure within the context of the five tasks. Before they can complete the task, the IT pro must build the supporting cloud infrastructure. 

- Identity and Access Management - This section shows how to securely manage identities and access to AWS services and resources. It includes integration with Active Directory.
- Provisioning Storage - This section discusses the different types of cloud storage, their usage, and how to create storage resources. 
- Building a Virtual Private Cloud (VPC) and Networking - This section shows how to build a Virtual Private Cloud for deploying applications and creating resources. It includes defining networking for ingress and egress and public and private subnets
- Security - This section shows how to implement security through IAM policies, firewalls, and other mechanisms to secure the VPC. 
- Deploying Applications in the Cloud -This section shows how to deploy and configure applications in the VPC.
- Creating and Migrating Databases -This section shows how to create and configure relational databases and migrate data from on-premise instances to cloud databases.
- Migrating Applications to Containers -This section shows how to migrate an application to containers and deploy it in AWS Elastic Container Service.
- Hybrids (On-Premise and Cloud) - This section discusses hybrid environments and how to implement them.

*Stage 3: Keep it Running*
This section introduces Infrastructure as Code. It takes the previous steps and shows how to automate the build and configuration process for infrastructure and how to deploy applications use Cloud Formation and CDK.

## What’s next

To start your journey, we’ll start with deploying web applications in Windows Server 2022 and Linux. These tutorials demonstrate how to create a cloud instance of a server. In addition, you will configure server networking and software and deploy applications using a script to automate the process.  Start your journey<add link to first tutorial>.

