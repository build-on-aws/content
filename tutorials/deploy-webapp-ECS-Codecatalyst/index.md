---
title: "Deploy a Container Web App on Amazon ECS using CodeCatalyst"
description: "Learn to build and deploy a container-based web application using Amazon Elastic Container Service and Amazon CodeCatalyst"
tags:
    - ecs
    - cdk
    - codecatalyst
    - ci-cd
    - tutorial
    - aws
authorGithubAlias: kowsalyajaganathan
authorName: Kowsalya Jaganathan
date: 2023-05-01
---

In this guide, you will learn how to deploy a containerized application on Amazon Elastic Container Service (Amazon ECS) using Amazon CodeCatalyst.

Amazon ECS is a fully managed container orchestration service that helps you easily deploy, manage, and scale containerized applications. It integrates with the rest of the AWS platform to provide a secure and easy-to-use solution for running container workloads in the cloud and now on your infrastructure with Amazon ECS Anywhere.

Amazon CodeCatalyst is an integrated DevOps service which you can leverage to plan, collaborate on code, build, test, and deploy applications with continuous integration and continuous delivery (CI/CD) tools. With all of these stages and aspects of an application’s lifecycle in one tool, you can deliver software quickly and confidently.
## What you will learn
In addition to learning about Amazon ECS and its various components, you will:

- Create the infrastructure to run your container with Amazon ECS
- Deploy a containerized application to Amazon ECS using Amazon CodeCatalyst



## Sections
<!-- Update with the appropriate values -->
| Info                | Level                                  |
| ------------------- | -------------------------------------- |
| ✅ AWS Level        | Beginner                               |
| ⏱ Time to complete  | 15-20 minutes                             |
| 💰 Cost to complete | Less than $0.02 USD if completed in under an hour.     |
| 🧩 Prerequisites    | - [AWS Account](https://portal.aws.amazon.com/billing/signup#/start/email) with administrator-level access*<br>- [CodeCatalyst Account](https://codecatalyst.aws) <br> [*]Accounts created within the past 24 hours might not yet have access to the services required for this tutorial.
| 💻 Code Sample         | Code sample used in tutorial on [GitHub](<link if you have a code sample associated with the post, otherwise delete this line>)                             |
| 📢 Feedback            | <a href="https://pulse.buildon.aws/survey/DEM0H5VW" target="_blank">Any feedback, issues, or just a</a> 👍 / 👎 ?    |
| ⏰ Last Updated     | YYYY-MM-DD <as mentioned above>                             |
 
| ToC |
|-----|
<!-- Use the above to auto-generate the table of content. Only build out a manual one if there are too many (sub) sections. -->
## Prerequisites

Before starting this tutorial, you will need the following:

 - An AWS Account (if you don't yet have one, you can create one and [set up your environment here](https://aws.amazon.com/getting-started/guides/setup-environment/)).
 - CDK installed: Visit the Get Started with AWS CDK guide to learn more.
 - The example project code downloaded to extract the SampleApp.
 - Docker installed and running.
 - CodeCatalyst Account and Space setup with Space administrator role assigned to you ( if you don't have a CodeCatalyst setup already, you can follow the [Amazon CodeCatlyst setting up guide](https://docs.aws.amazon.com/codecatalyst/latest/userguide/setting-up-topnode.html)).
---
## UNDERSTANDING ECS

The focus of this module is to introduce you to the concepts of Amazon ECS. We will cover the components of Amazon ECS (cluster, task definition, service), what orchestration is, and how to choose which type of compute to use to run your containers. If you are already familiar with Amazon ECS, you can skip ahead to [Module2]().

<!-- Recommended to use present tense. e.g. "First off, let's build a simple application."  -->

<!-- Sample Image link with required images/xx.xxx folder structure -->
![This is the alt text for the image](images/where-this-image-is-stored.png)
<!-- Alt text should provide a description of the pertinent details of the image, not just what it is, e.g. "Image of AWS Console" -->

<!-- Sample Image link with a title below it, using required images/xx.xxx folder structure -->
![This is the alt text for the image](images/where-this-image-is-stored.png "My image title below")

<!-- Code Blocks -->
Remember to include the language type used when creating code blocks. ` ```javascript `.
For example,

```javascript
this is javascript code
```

If you want to share a code sample file with reader, then you have two options:
- paste the contents with code blocks like mentioned above
- provide link to the file. Use the raw file content option on GitHub (without the token parameter, if repo is private while drafting). It should look like:   
    `https://raw.githubusercontent.com/ORGANIZATION/REPO-NAME/main/FOLDER/FILENAME.EXTENSION`
    Example:
     _You can also copy-paste contents of this file from [here](https://raw.githubusercontent.com/build-on-aws/aws-elastic-beanstalk-cdk-pipelines/main/lib/eb-appln-stack.ts)._

## CREATE INFRASTRUCTURE

From here onwards, split the tutorial into logical sections with a descriptive title. Focus titles on the core action steps in each section.

<!-- Recommended to use present tense. e.g. "First off, let's build a simple application."  -->

<!-- Sample Image link with required images/xx.xxx folder structure -->
![This is the alt text for the image](images/where-this-image-is-stored.png)
<!-- Alt text should provide a description of the pertinent details of the image, not just what it is, e.g. "Image of AWS Console" -->

<!-- Sample Image link with a title below it, using required images/xx.xxx folder structure -->
![This is the alt text for the image](images/where-this-image-is-stored.png "My image title below")

<!-- Code Blocks -->
Remember to include the language type used when creating code blocks. ` ```javascript `.
For example,

```javascript
this is javascript code
```

If you want to share a code sample file with reader, then you have two options:
- paste the contents with code blocks like mentioned above
- provide link to the file. Use the raw file content option on GitHub (without the token parameter, if repo is private while drafting). It should look like:   
    `https://raw.githubusercontent.com/ORGANIZATION/REPO-NAME/main/FOLDER/FILENAME.EXTENSION`
    Example:
     _You can also copy-paste contents of this file from [here](https://raw.githubusercontent.com/build-on-aws/aws-elastic-beanstalk-cdk-pipelines/main/lib/eb-appln-stack.ts)._

## DEPLOY APPLICATION

In this module, you will create an Amazon CodeCatalyst project from the scratch and then create code repository & workflow to deploy the Sample application to the Amazon ECS cluster setup in previous module .

### Create an Amazon CodeCatalyst Project
To create a CodeCatalyst project, you need to have the CodeCatalyst account and space setup. If you don't have a CodeCatalyst setup already, you can follow the [Amazon CodeCatlyst setting up guide](https://docs.aws.amazon.com/codecatalyst/latest/userguide/setting-up-topnode.html))



## Clean up

Provide steps to clean up everything provisioned in this tutorial. 

## Conclusion

<!-- Recommended to use past tense. e.g. "And that's it! We just built and deployed that thing together!"  -->

Provide a conclusion paragraph that reiterates what has been accomplished in this tutorial (e.g. turning on versioning), and what its value is for the reader (e.g. protecting against loss of work). If it makes sense, tie this back to the problem you described in the introduction, showing how it could be solved in a real-world situation. 

Identify natural next steps for curious readers, and suggest two or three useful articles based on those next steps.

Also end with this line to ask for feedback:
If you enjoyed this tutorial, found any issues, or have feedback us, <a href="https://pulse.buildon.aws/survey/DEM0H5VW" target="_blank">please send it our way!</a>

