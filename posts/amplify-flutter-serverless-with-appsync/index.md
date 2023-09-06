---
title: "Building a Amplify Flutter for Web using a Serverless CDK Backend in Typescript with AppSync Merged APIs"
description: "In this post you will learn how to build a simple website using Flutter that interacts with a serverless backend powered by AppSyncs Merged APIs. the project will be deployed using CDK and comes with a CodeCatalyst workflow"
tags:
    - amplify
    - codecatalyst
    - appsync
    - serverless
    - flutter
authorGithubAlias: lock128
authorName: Johannes "Lockhead" Koch
githubUserLabel: AWS-Hero
date: 2023-09-15
seoDescription: Build a Flutter Web application with an AppSync backend, powerd by AWS Amplify
---

In this article you are going learn how to build a simple Flutter Web application that uses the Amplify SDK to talk to a serverless, AWS backend. The sample project uses Cognito for Authentication and AppSync for the API. On AppSync, you will make use of the "Merged APIs" feature which will enable you to quickly scale out this project if your project becomes "the next big hype" on the net. The deployment happens through CodeCatalyst workflows using AWS CDK.

| ToC |
|-----|

## High-Level architecture
![The high level architecture of the project](images/high_level_architecture.png "The high level architecture of the project")
In the sample project we will use a few AWS services:
Our web-page (build in Flutter) will be hosted on Amazon S3 behind Cloudfront. Cognito will be used for Authentication. AppSync will be our API endpoint and we'll connect to DynamoDB as a database. A few API endpoints will have Lambda functions.
## Used technologies in this project
Technology wise we are using Flutter for our Front-End code, TypeScript for code on the backend. Also our infrastrcture as code is written in TypeScript.
### What is Flutter? Why Flutter?
[Flutter](https://flutter.dev) is a trending cross-platform development toolkit and altough it is mainly sponsored by Google there is a vibrant open source community. Flutter allows you to develop a user interface once and then package it for different platforms like Android, iOS, the Web or even Linux and Windows. The source code you write is being translated into natively readable code for the target platform which makes Flutter faster then other cross platform development tools.

### Using AWS AppSync - what are Merged APIs?
[AppSync Merged APIs](https://docs.aws.amazon.com/appsync/latest/devguide/merged-api.html) have been announced in 2023 and empower development teams to split up responsibilities between different teams as APIs for specific endpoints can be development independently from each other. 

### Writing infrastructure as code using AWS CDK

## Setting up the serverless backend
### Persistance layer & authentication

### APIs - the AppSync setup and Schema
![Merged APIs architecture](images/merged_apis_architecture.png "Merged APIs architecture")
## Setting up your Flutter project using Amplify SDK
![UI architecture](images/ui_architecture.png "UI architecture")
### Connecting to Cognito

### Accessing the AppSync API

## Mixing it all together: Our CI/CD pipeline in CodeCatalyst
![An example, simple CI/CD pieline](images/cicd_workflow.png "An example, simple CI/CD pipeline")
### Developer Experience and a minimal Continuous Integration pipeline

### Continuous Deployment and promotion using CodeCatalyst workflows

## A community driven example project


## What you learned and what you should take away from this article


### Other links & guides

- [The AWS Commmunity Builders Speakers Directory](https://speakers.awscommunitybuilders.org/)
- [AppSync Merged APIs](https://docs.aws.amazon.com/appsync/latest/devguide/merged-api.html)
- [Amplify Flutter SDK](https://docs.amplify.aws/start/q/integration/flutter/)
- [Amazon CodeCatalyst](https://codecatalyst.aws/explorer)
- [CodeCatalyst Workflows](https://docs.aws.amazon.com/codecatalyst/latest/userguide/flows.html)
- [AWS CDK](https://aws.amazon.com/cdk/)
- [A write up from Matt Morgan - the AWS Community Builders Speakers Directory project](https://dev.to/aws-builders/presenting-aws-speakers-directory-an-ai-hackathon-project-19je)
- [Amplify SDK for Flutter - Developer experience and challenges in a hackathon](https://dev.to/aws-builders/amplify-sdk-for-flutter-developer-experience-and-challenges-in-a-hackathon-2e15)
- [A real project with CodeCatalyst - Our hackathon gave us a good insight into what works and what doesn't](https://dev.to/aws-builders/a-real-project-with-codecatalyst-our-hackathon-gave-us-a-good-insight-into-what-works-and-what-doesnt-1e79)
- [AppSync Merged API – Our real project experience as part of our hackathon](https://dev.to/aws-builders/appsync-merged-api-our-real-project-experience-as-part-of-our-hackathon-2m96)
- [AWS Speakers Directory: Adding AI Functionality](https://dev.to/aws-builders/community-speakers-directory-adding-ai-functionality-3427)