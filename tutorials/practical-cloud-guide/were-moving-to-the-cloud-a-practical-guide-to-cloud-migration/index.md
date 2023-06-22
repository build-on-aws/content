---
title: "We're Moving to the Cloud: A Practical Guide to Cloud Migration"
description: "Introduction to the Practical Cloud Guide, a series of articles and tutorials to help IT Administrators and Pros successfully transition to the cloud."
tags:
  - it-pros
  - migration
showInHomeFeed: true
authorGithubAlias: "spara" 
authorName: "Sophia Parafina"
date: 2023-06-21
---

This is an 5-part series about Cloud Migration:

| SeriesToC |
|-----------|

It’s Monday morning, you’ve heard the rumors and now it’s official:

> “As my first act as the CTO, I am pleased to announce that we are moving our IT operations to the cloud. Our team is well-equipped to handle this transition and I am confident that it will bring many benefits to our organization. I look forward to seeing the results.”

![Surprised sysadmin looking at their laptop while sitting in front of a rack of servers](./images/sysadmin_monday_surprise.jpeg)

You’re a Senior System/Network/Database Administrator or a Systems Analyst or IT Director managing your company’s on premise IT resources. You’ve experimented with the cloud on your own time or taken an online course to get a certification, but you don’t have hands-on experience building cloud infrastructure or migrating applications to the cloud.

Luckily, you have *The Practical Cloud Guide for IT Professionals*: a hands-on learning journey to cloud engineering. This guide will demonstrate how to migrate infrastructure and applications with step-by-step instructions for performing common infrastructure, networking, and administration tasks in the cloud. Let's get started!

## The Road Map to the Cloud

Introductions to cloud infrastructure often dive into the many components needed to deploy an application. We're going to take a different approach with the *Practical Guide*, beginning by completing common tasks with managed services to reduce the cloud engineering learning curve. This first post will give you an overview of what's to come -- a step-by-step guide for migrating infra and apps to the cloud.

The learning journey is divided into three stages.

### Stage 1: Run in the Cloud

The first stage is designed to rapidly onboard IT Pros to the cloud. The goal is to show how to apply your skills to the cloud using fully managed services while introducing the building blocks for more complex tasks. AWS Lightsail is the gateway to AWS. IT Pros can focus on accomplishing all five tasks with ready-to-run services and resources. IT Pros will learn about AWS resources and the concepts behind them without having to build infrastructure by onboarding with AWS Lightsail.

### Stage 2: Build in the Cloud

This stage of the IT Pro journey teaches how to build and maintain infrastructure. You will build the infrastructure to implement common IT administration tasks in the cloud. This stage uses hands-on tutorials to build cloud infrastructure to deploy applications, manage users, provision storage, create a database, and migrate an application to containers.

### Stage 3: Keep it Running

The final part of the journey introduces Infrastructure as Code and shows how to build and maintain infrastructure using Cloud Formation and CDK. You will use the previous steps to automate the build and configuration process for infrastructure and deploy applications use Cloud Formation and CDK.

## What You Will Learn

The Practical Guide to Cloud Migration addresses these topics:

- Identity and Access Management (IAM) to securely manage identities and access to AWS services and resources.
- Provisioning different types of cloud storage, their usage, and how to create storage resources.
- Building a Virtual Private Cloud (VPC) for deploying applications and creating resources. It includes defining networking for ingress and egress and public and private subnets
- Implementing security security through IAM policies, firewalls, and other mechanisms to secure the VPC.
- Deploying and configuring applications in a VPC.
- Creating and migrating databases from on-premise instances to cloud databases.
- Migrating applications to containers and deploy them in AWS Elastic Container Service (ECS).
- Implementing hybrid (On-Premise and Cloud) hybrid environments.

## What’s Next

To start your journey, we’ll start with deploying web applications in Windows Server 2022 and Linux. These tutorials demonstrate how to create a cloud instance of a server. In addition, you will configure server networking and software and deploy applications using a script to automate the process.  Start your journey with the first tutorial (coming soon) on [Deploy an ASP.NET Core Application on Windows Server with AWS Lightsail](/tutorials/practical-cloud-guide/deploy-an-asp-net-core-application-on-windows-server-with-aws-lightsail/).
