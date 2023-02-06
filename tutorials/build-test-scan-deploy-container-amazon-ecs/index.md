---
title: "Build, test, scan, and deploy your container"
description: "A walk-through of how to build, test, scan, and deploy your container."
tags:
    - cdk
    - codecatalyst
    - ci-cd
    - tutorial
    - aws
authorGithubAlias: cobusbernard
authorName: Cobus Bernard
date: 2023-02-10
---

Terraform is awesome to manage all your infrastructure, but when you have more than one developer trying to make changes to the infrastructure, things can get messy very quickly if there isn't a mechanism ([CI/CD pipeline](https://www.buildon.aws/concepts/devops-essentials/#continuous-integration-and-continuous-delivery)) in place to manage it. Without one, making changes to any infrastructure requires coordination and communication, and the challenge quickly scales the more people that are involved with making these changes. Imagine having to run around shouting *"Hey Bob! Hey Jane! You done yet with that DB change? I need to add a new container build job!"*. As Jeff Bezos said:

> ***"Good intentions never work, you need good mechanisms to make anything happen."***

This tutorial will show you how to set up a CI/CD pipeline using Amazon [CodeCatalyst](https://codecatalyst.aws) and [Terraform](https://www.terraform.io/). The pipeline will utilize pull requests to submit, test, and review any changes requested to the infrastructure. We will cover the following topics in this tutorial:

- Using S3 as a backend for Terraform [state files](https://developer.hashicorp.com/terraform/language/state), with [DynamoDB for locking](https://developer.hashicorp.com/terraform/language/settings/backends/s3#dynamodb-table-permissions), and encrypting the state file at rest with KMS
- CodeCatalyst to run our CI/CD pipelines to create and update all your infrastructure

| Attributes             |                                                                 |
|------------------------|-----------------------------------------------------------------|
| ✅ AWS experience      | 100 - Beginner                                              |
| ⏱ Time to complete     | 30 minutes                                                      |
| 💰 Cost to complete    | Free tier eligible                                               |
| 🧩 Prerequisites       | - [AWS Account](https://portal.aws.amazon.com/billing/signup#/start/email)<br>- [CodeCatalyst Account](https://codecatalyst.aws)<br>- [Terraform](https://terraform.io/) 1.3.7+<br>- (Optional) [GitHub](https://github.com) account|
| ⏰ Last Updated        | 2023-01-31                                                      |

## Table of Contents

| ToC |
|-----|
