---
title: "Streamline AWS Deployments with GitLab CI and Terraform"
description: "A Step-By-Step Guide for deploying code using CI/CD"
tags:
    - DevOps
    - Terraform
    - CICD
    - IaC
    - Git
authorGithubAlias: kaizadwadia
authorName: Kaizad Wadia
date: 2023-12-20
---

Deploying infrastructure to AWS manually can be time-consuming and prone to errors. In this post, we'll go over how to set up a CI/CD pipeline for automated AWS deployments using GitLab and Terraform.

## Overview

First, we'll write a Terraform script to deploy AWS resources and a matching .gitlab-ci.yml file to execute the script on commit.

We'll configure the necessary permissions in AWS IAM to allow GitLab to create infrastructure. We'll create an S3 bucket and DynamoDB table to store remote Terraform state or use GitLab's built-in state management.

Finally, we'll test the pipeline by deploying sample infrastructure.

By following this guide, you'll learn infrastructure-as-code best practices for GitLab and Terraform and have an automated deployment pipeline to AWS ready for your infrastructure repos. Let's get started on setting up smooth AWS deployments with GitLab and Terraform.

### Prerequisites

You need an AWS account and a GitLab account (can be done with a free trial GitLab account). Note that the steps in this tutorial will be different if you choose to use a self-managed GitLab account. This difference is mainly applicable to [the first step](#configure-an-identity-provider-in-iam).

| Attributes                |                                   |
| ------------------- | -------------------------------------- |
| ✅ AWS Level        | Intermediate - 200                         |
| ⏱ Time to complete  | 45 minutes                             |
| 💰 Cost to complete | $0.01      |
| 🧩 Prerequisites    | [AWS Account](https://aws.amazon.com/resources/create-account/) and [GitLab Account](https://gitlab.com/-/trial_registrations/new?glm_source=about.gitlab.com/&glm_content=default-saas-trial)|
| 📢 Feedback            | <a href="https://pulse.buildon.aws/survey/DEM0H5VW" target="_blank">Any feedback, issues, or just a</a> 👍 / 👎    |
| ⏰ Last Updated     | 2023-12-20                             |

## Walkthrough

### Build the Repository

In [GitLab](https://gitlab.com), create a new repository to store our Terraform script by clicking on "New project" on the top right side of the page. Then click on "Create blank project"

### Configure an Identity Provider in IAM

We will now configure GitLab as an identity provider for IAM. This allows IAM to recognize GitLab as a trusted entity that we can assign permissions via an IAM Role.

To do this, navigate to IAM in the AWS Management Console, and then click on "Identity Providers" on the sidebar under "Access Management". After that, click on the button saying "Add provider" on the top right-hand side. Once there, enter the information like displayed in the below image.

![Adding IdP](images/addingidp.png)

Make sure that the option for OpenID Connect is selected on the top, this is because OpenID Connect allows you to configure trust relationships with third party accounts including but not limited to GitLab. Also ensure that the provider URL is GitLab's root URL, `https://gitlab.com` as well as the Audience. The provier URL is the URL from which the OpenID configuration is obtained. You can view it yourself by navigating to [`gitlab.com/.well-known/openid-configuration`](gitlab.com/.well-known/openid-configuration). *Note that if you are using a self-managed instance of GitLab (that is publicly available on the internet) you would need to use the root URL of that instance instead of gitlab.com. In this case, check that your instance supports OpenID connect by navigating to the OpenID configuration URL using your instance's root domain.*

Once you have completely filled out the information, you can click on "Get thumbprint" to retreive the thumbprint from the URL you supplied. [This page](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_providers_create_oidc_verify-thumbprint.html) in the documentation describes how this thumbprint is obtained. Then click on "Add provider". We have now configured GitLab as an Identity Provider in our AWS Account.

### Create an IAM Role for GitLab CI

To create an IAM Role that our CI/CD pipeline can assume to make deployments click on "Roles" under "Access Management" in the IAM page and then click on the "Create role" button on the top right of the page. In the first step, configuring the trusted entity means providing access to our identity provider we created before. For this, select on "Web identity", which should allow you to select "gitlab.com" as the identity provider from the dropdown menu and "https://gitlab.com" as the audience, similar to the below image.

![Trusted Entities Creation](images/iamrole1.png)

Once that is done, clicking "next" should allow us to select IAM policies which determine what permissions GitLab should have. For the purposes of this tutorial, we will provide full access only to three services: S3, DynamoDB and SQS by attaching the following policies:

* AmazonS3FullAccess
* AmazonDynamoDBFullAccess
* AmazonSQSFullAccess

Once we have selected the appropriate policies, we can move on to the next step, which allows us to give the role a name and description. The role name should be "GitLabRole" and the description of the role is "An IAM Role to give GitLab CI access to deploy to AWS". We can now scroll down to the bottom and click on "Create role".

Once the role is created, navigate to it in the console under "Roles" by searching for the role name and clicking on it. Once the role is on the page, select the "Trust relationships" tab and click on "Edit trust policy" on the right side.

### Option 1: Creating an S3 Bucket and DynamoDB Table to Manage Terraform State

### Option 2: Using GitLab-Managed Terraform State

### Writing the Instructions for the CI/CD Pipeline

### Deploying the Script

## Clean-up

To clean-up your AWS account, remember to delete the following:

* f

## Conclusion

And that's it! We've set up an automated AWS deployment pipeline using GitLab and Terraform best practices. Now anytime you push changes to your infrastructure code, GitLab CI will trigger Terraform to deploy those changes to AWS.

In this post we covered configuring IAM permissions and roles for GitLab, creating S3 and DynamoDB resources to store remote state, writing a Terraform script to deploy infrastructure, setting up a .gitlab-ci.yml pipeline to execute on commits, and testing our automated deployments.

By following these steps, you can take the manual work and errors out of deploying to AWS. Your infrastructure becomes code that can be treated like any other application code.

As you expand your infrastructure, be sure to continue using security best practices like least privilege IAM roles. And leverage GitLab's power with features like the Terraform template library.

Now whenever inspiration strikes, you can implement and deploy new AWS infrastructure automatically in a fraction of the time. You're ready to use GitLab and Terraform to streamline your cloud deployments!
