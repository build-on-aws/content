---
title: "Point-to-Point Messaging with Amazon SQS"
description: Learn step-by-step how to asynchronously send a message between two AWS Lambda functions using Amazon SQS.
tags:
  - tutorials
  - aws
  - architecture-patterns
  - application-integration
  - microservices
  - serverless
  - sqs
  - lambda
  - cdk
  - typescript
authorGithubAlias: DennisTraub
authorName: Dennis Traub
date: 2023-07-24
---

## Prerequisites

Before starting this tutorial, you will need the following:

- AWS Account: If you don't have one, you can [sign up for free](https://aws.amazon.com/getting-started/guides/setup-environment/?sc_channel=el&sc_campaign=appswave&sc_geo=mult&sc_country=mult&sc_outcome=acq). The AWS Free Tier gives you plenty of resources to play around with, including AWS Lambda and Amazon SQS, which is what we will be using.
- The AWS Cloud Development Kit (AWS CDK): [How to setup and bootstrap the AWS CDK](https://aws.amazon.com/getting-started/guides/setup-cdk/?sc_channel=el&sc_campaign=appswave&sc_geo=mult&sc_country=mult&sc_outcome=acq)

| Attributes| |
| ---- | ---- |
| ✅ AWS Level | Intermediate - 200 |
| ⏱ Time to complete | 30 minutes |
| 💰 Cost to complete | Free when cleaning up after the tutorial (instructions below) |
| 🧩 Prerequisites | - [AWS Account](https://aws.amazon.com/getting-started/guides/setup-environment/?sc_channel=el&sc_campaign=appswave&sc_geo=mult&sc_country=mult&sc_outcome=acq)<br />- [AWS Cloud Development Kit](https://aws.amazon.com/getting-started/guides/setup-cdk/) |
| 💻 Code Repository | The code for this tutorial is available on [GitHub](https://github.com/build-on-aws/point-to-point-messaging-with-amazon-sqs) |
| 📢 Feedback            | <a href="https://pulse.buildon.aws/survey/DEM0H5VW" target="_blank">Any feedback, issues, or just a quick star rating?</a>    |
| ⏰ Last Updated     | 2023-07-24                             |

| ToC |
|-----|

## Introduction

The point-to-point messaging pattern is commonly used communication model in modern web and cloud architectures. It is designed to enable asynchronous interactions between different components, e.g. serverless functions or microservices, allowing them to exchange messages without requiring an immediate response.

In this pattern, the component that sends the message is called the *producer*, while the component that receives and processes the message is called the *consumer*. The producer and consumer can be located on the same system or in different systems, making it a flexible and scalable approach for communication.

Similar to how emails are delivered to individual recipients, messages are sent from the producer to a specific consumer. This allows for efficient and reliable communication, even in complex distributed systems. It is commonly used in scenarios where the producer knows exactly which consumer needs to receive the message, but it is not necessary for the producer to get an immediate response.

The point-to-point messaging pattern effectively facilitates communication and coordination between components, improving the overall performance, reliability, and scalability of modern web and cloud architectures.

In this step-by-step tutorial, we will implement this pattern using two AWS Lambda functions and an Amazon SQS queue

In this step-by-step tutorial, we will implement a simple example using two AWS Lambda functions and an Amazon SQS queue.

You will build the example using TypeSript and the AWS Cloud Development Kit (AWS CDK).

The example will consist of three components:
- A *producer* that can send messages to the consumer
- A *consumer* that can receive messages from the producer
- A *message queue* establishing the communication channel between the producer and the consumer

![](images/diagram-point-to-point.png) **TODO: Add Image**

In addition to implementing this pattern, we will also higlight the power of the AWS Cloud Development Kit (CDK) to define the entire infrastructure as code. If you want to learn more about the AWS CDK, have a look at the [AWS CDK Developer Guide](https://docs.aws.amazon.com/cdk/v2/guide/home.html?sc_channel=el&sc_campaign=appswave&sc_geo=mult&sc_country=mult&sc_outcome=acq).

By the end of this tutorial, you will have gained a solid understanding of the individual components of queue-based point-to-point messaging, successfully implemented asynchronous sommunication between two Lambda functions using SQS, and acquired some hands-on experience building infrastructure as code with CDK.

But before we start coding, let's have a quick look at the pros and cons of the asynchronous point-to-point messaging pattern. 

## Pros and Cons of the Asynchronous Point-to-Point Messaging Pattern

### Pros
- **Loose coupling:** The asynchronous point-to-point messaging pattern promotes loose coupling between applications, allowing them to communicate independently without having to be tightly integrated. This flexibility makes it easier to scale and modify individual components without impacting the entire system.
- **Scalability:** This pattern allows for efficient horizontal scaling, as multiple consumer applications can be added to handle the workload asynchronously. This enables the system to handle high volumes of messages and concurrent requests more effectively.
- **Reliability:** In asynchronous messaging, if a message fails to be delivered or processed, it can be retried or sent to an error queue for later processing, enhancing the reliability of the system.
- **Fault tolerance:** Asynchronous messaging provides fault tolerance by decoupling the producers and consumers of messages. If one application or component fails, messages can be stored for future processing once the system is back online, ensuring that no data is lost.

### Cons
- Complexity: Implementing the asynchronous point-to-point messaging pattern can be more complex compared to other integration patterns, requiring additional message handling logic.
- Message dependencies and deduplication: Managing dependencies between messages and ensuring proper message deduplication can be challenging in an asynchronous messaging system. It requires careful design and implementation to handle potential issues such as message order, message duplicates, and message processing dependencies.
- Increased latency: Asynchronous messaging introduces a delay between sending a message and receiving a response, as the processing of messages may take longer. This delay can impact real-time interactions and might not be suitable for applications requiring immediate feedback.

When making architectural decisions, it is important to consider these trade-offs and choose the communication pattern that aligns best with your specific requirements and constraints. Many modern applications rely on multiple integration patterns, including asynchronous point-to-point messaging, as well as synchronous request-response, and event-based communication.

But now, let's start the tutorial and learn how to implement this pattern using AWS Lambda and Amazon SQS.

**A note on resource costs when coding along:** This tutorial uses only a minimal amount of resources, all of which are included in the [Free Tier provided by AWS](https://aws.amazon.com/free?sc_channel=el&sc_campaign=appswave&sc_geo=mult&sc_country=mult&sc_outcome=acq) for the first 12 months after creation of each account:

- A few kilobytes of code will be stored in Amazon S3, which provides 5 GB of free storage.
- We will call SQS a couple of times, which provides 1 million free requests per month.
- We will invocate two functions on AWS Lambda, which also provides 1 million free invocations per month.

So if you follow the step-by-step guide, you'll definitely stay within the free trier. I've also added a section to the end that helps you remove all the resources created during this tutorial.

## Prerequisites

We'll assume you already have an [AWS Account](https://aws.amazon.com/free), the [AWS CLI installed and set up](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html), and the [AWS CDK installed](https://aws.amazon.com/getting-started/guides/setup-cdk/module-two/).

This tutorial requires at least version 2 of the AWS CLI and AWS CDK. You can tell the version of both by running the following commands in a shell prompt (indicated by the $ prefix):

```bash
$ aws --version
aws-cli/2.xx.xx ...

$ cdk --version
2.xx.xx ...
```

If the CLI and CDK are installed, you should see the respective versions of your installations. If it isn't, you'll get an error telling you that the command can't be found.

## Step 1 - Create and Deploy the CDK App

### Initialize the CDK app

First, you'll have to take care of some initial setup: You'll need to auto-generate some code that establishes a CDK project.

From the command line create an empty directory where you'd like to store your code:

```bash
$ mkdir point-to-point-example
$ cd point-to-point-example
```

Inside this directory, run the following command.:

```bash
$ cdk init app --language typescript
```

This will create few directories and some configuration files containing CDK-specific options and application-specific settings.

Now is a good time to open the project in your favorite IDE and have a look at the following two files:

- `lib\point-to-point-example-stack.ts` is where your CDK application’s main stack is defined. This is the file we’ll be spending most of our time in.
- `bin\point-to-point-example.ts` is the entrypoint of the CDK application. It will load the stack defined in `lib\point-to-point-example-stack.ts`. In this tutorial we won’t need to look at this file anymore.

### The main stack

Open up `lib\point-to-point-example-stack.ts`. This is where we will define the infratsructure needed for our application:

```typescript
import * as cdk from 'aws-cdk-lib';
import { Construct } from 'constructs';
// import * as sqs from 'aws-cdk-lib/aws-sqs';

export class PointToPointExampleStack extends cdk.Stack {
  constructor(scope: Construct, id: string, props?: cdk.StackProps) {
    super(scope, id, props);

    // The code that defines your stack goes here
    // ...
  }
}
```

As you can see, our app was created with an empty CDK stack (`PointToPointExampleStack`).

### Bootstrapping an environment

The first time you deploy an AWS CDK app into an environment (account/region), you need to bootstrap your AWS accountwith a **CDKToolkit** stack. This stack includes resources that are used by the CDK. For example, the stack includes an S3 bucket that is used to store templates and assets during the deployment process.

You can use the `cdk bootstrap` command to install the bootstrap stack into an environment:

```bash
$ cdk bootstrap
```

This will take some time and will be completed once you see the following output on your command line:

```bash
✅  Environment aws://[account_id]/[region] bootstrapped.
```

### Let's deploy

Change into the `point-to-point-example` directory, if you haven't already, and run the following command to deploy the CDK app:

```bash
$ cdk deploy
```

This will take some time and will be completed once you see something similar to the following output on your command line:

```bash
...

✅  SqsTutorialStack

✨  Deployment time: 11.96s

Stack ARN:
arn:aws:cloudformation:[region]:[account_id]:stack/SqsTutorialStack/...

✨  Total time: 16.13s
```

![Screenshot of the Point to Point example stack in AWS CloudFormation](images/screen-stack.png)

##  Step 2 - Creating and Deploy the SQS queue

**TODO below**

Now that your environment is set up, you can start creating the first resource for your app: An Amazon SQS queue.

Open the file lib\point-to-point-example-stack.ts. 

You can see that the CDK template has already added a few import statements, including `aws-cdk-lib/aws-sqs` in a comment. This is convenient, as we don't have to add it manually anymore.

Remove the comment symbols `//` in front of the `import` line so that the first three lines of the file look like this:

```typescript
import * as cdk from 'aws-cdk-lib';
import { Construct } from 'constructs';
import * as sqs from 'aws-cdk-lib/aws-sqs';
```

Now remove the comments below the statement `super(scope, id, props)` and replace them with the following code:

```typescript
const queue = new sqs.Queue(this, 'Queue', {
  queueName: 'MyQueue',
});
```

Save the file and deploy the application using the following command:

```bash
$ cdk deploy
```

This will create an SQS queue, which is our first real AWS resource, and can take a minute or so to complete.

Once the deployment has finished, navigate to your [list of SQS queues](https://console.aws.amazon.com/sqs/v2/home#/queues) in the AWS Management Console and find the queue named  **SqsTutorialStack-Queue...**:

![](images/screen-queue.png)

## Lambda

```typescript
import * as lambda from 'aws-cdk-lib/aws-lambda';
```

```bash
mkdir lambda-src
mkdir lambda-src/producer
touch lambda-src/producer/send_message_to_sqs.js
```

![](images/screen-confirm-changes.png)

```typescript
import * as iam from 'aws-cdk-lib/aws-iam';
```
