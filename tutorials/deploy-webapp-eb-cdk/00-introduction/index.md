# Introduction
Follow step-by-step instructions to build and deploy your first web application using AWS Elastic Beanstalk

**AWS experience** Beginner

**Time to complete** 30 - 35 minutes

**Cost to complete** [Free Tier](https://aws.amazon.com/free/?e=gs2020&p=build-a-web-app-intro) eligible

**Requires**
* AWS account with administrator-level access*
* Recommended browser: The latest version of Chrome or Firefox
 [*]Accounts created within the past 24 hours might not yet have access to the services required for this tutorial.

**Code** [Download the example project for this guide here]()

**Last updated** March 24, 2023


## Overview
In this guide, you will learn how to deploy a non-containerized application in the cloud. You will create a simple Node.js web application, and then you will use a service called AWS Elastic Beanstalk to deploy the application to the AWS Cloud. 

Elastic Beanstalk is an easy-to-use service for deploying and scaling web applications and services developed with Java, .NET, PHP, Node.js, Python, Ruby, Go, and Docker on familiar servers such as Apache, Nginx, Passenger, and IIS. You can simply upload your code and Elastic Beanstalk automatically handles the deployment, from capacity provisioning, load balancing, auto-scaling, to application health monitoring. At the same time, you retain full control over the AWS resources powering your application and can access the underlying resources at any time.

## What you will accomplish
In this guide, you will:

* Deploy a non-containerized application to the cloud
* Package a Node.js app to be deployed using Elastic Beanstalk
* Create all the infrastructure needed for Elastic Beanstalk using CDK 
* Setup CI/CD Pipeline for the application and the infrastructure using CDK Pipelines
* Update a non-containerized deployment

## Prerequisites
Before starting this guide, you will need:

* An AWS account: If you don't already have an account, follow the [Setting Up Your AWS Environment](https://aws.amazon.com/getting-started/guides/setup-environment/) guide for a quick overview.
* CDK installed: Visit our [Get Started with AWS CDK](https://aws.amazon.com/getting-started/guides/setup-cdk/) guide to learn more.
* A GitHub account : Visit [GitHub.com](https://github.com/) and follow the prompts to create your  account.
 
## Modules
This tutorial is divided into the following short modules. You must complete each module before moving to the next one.
* [Develop a web application using Node.js](/tutorials/deploy-webapp-eb-cdk/01-build-a-web-application/) (10 minutes): In this module, you create a simple web application with a Node.js backend and run it locally.
* [Create a CDK application](/tutorials/deploy-webapp-eb-cdk/02-create-infrastructure/) (15 minutes): In this module, you create a CDK application that will create all the necessary infrastructure for deploying your web app to the cloud.
* [Deploying the application to the cloud](/tutorials/deploy-webapp-eb-cdk/03-deploy-web-application/) (15 minutes): In this module, you learn how to deploy your application to the cloud, and what to do when you want to modify it and redeploy it.
* [Clean up](/tutorials/deploy-webapp-eb-cdk/04-clean-up-resources/): In this last part of the guide, you learn how to clean up resources that are no longer needed.

