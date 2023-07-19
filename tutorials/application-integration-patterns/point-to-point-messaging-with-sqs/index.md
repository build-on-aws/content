---
title: "Point-to-Point Messaging with Amazon SQS"
description: Learn step-by-step how to asynchronously send a message between two AWS Lambda functions using Amazon SQS.
tags:
  - tutorials
  - aws
  - architectural-patterns
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

## What We Will Build

In this step-by-step tutorial, we will implement this pattern using two AWS Lambda functions and an Amazon SQS queue

In this step-by-step tutorial, we will implement a simple example using two AWS Lambda functions and an Amazon SQS queue.

You will build the example using TypeSript and the AWS Cloud Development Kit (AWS CDK).

The example will consist of three components:
- A *producer* that can send messages to the consumer
- A *consumer* that can receive messages from the producer
- A *message queue* establishing the communication channel between the producer and the consumer

![Diagram showing the producer function that sends messages to the message queue, which in turn triggers the consumer function](images/diagram.png)

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

We'll assume you already have an [AWS Account](https://aws.amazon.com/free?sc_channel=el&sc_campaign=appswave&sc_geo=mult&sc_country=mult&sc_outcome=acq), the [AWS CLI installed and set up](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html?sc_channel=el&sc_campaign=appswave&sc_geo=mult&sc_country=mult&sc_outcome=acq), and the [AWS CDK installed](https://aws.amazon.com/getting-started/guides/setup-cdk/module-two/?sc_channel=el&sc_campaign=appswave&sc_geo=mult&sc_country=mult&sc_outcome=acq).

This tutorial requires at least version 2 of the AWS CLI and AWS CDK. You can tell the version of both by running the following commands in a shell prompt (indicated by the $ prefix):

```bash
$ aws --version
aws-cli/2.xx.xx ...

$ cdk --version
2.xx.xx ...
```

If the CLI and CDK are installed, you should see the respective versions of your installations. If it isn't, you'll get an error telling you that the command can't be found.

## Step 1 - Create the CDK App

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

### Bootstrap an environment

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

##  Step 2 - Create the SQS queue

**TODO below**

Now that your environment is set up, you can start creating the first resource for your app: An Amazon SQS queue.

Open the file lib\point-to-point-example-stack.ts. 

Depending on the template version, CDK may already have added a few import statements, including `aws-cdk-lib/aws-sqs` in a comment. If this is the case, remove the comment symbols `//` in front of `import * as sqs from 'aws-cdk-lib/aws-sqs'`, otherwise add it yourself, so that the first three lines of the file look like this:

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

![Screenshot of the list of SQS queues in the AWS Management Console, including the queue that we have just created](images/screen-queue.png)


---
## Step 3 - Create the Producer Function and Connect it to the Queue

### 3.1 - Write the Producer Function Source Code

We'll use JavaScript for the Lambda function and store the source code in an assets folder inside the CDK application. This way, CDK can automatically package, upload, and deploy the function source to AWS.

Make sure you are in the project directory and create the following sub-directories, as well as the file itself:

```bash
mkdir lambda-src
mkdir lambda-src/producer
touch lambda-src/producer/send_message_to_sqs.js
```

The directory structure of your project should now look like this:

```
point-to-point-example/
├── bin/
│   └── point-to-point-example.ts
├── lambda-src/
│   └── producer/
│       └── send_message_to_sqs.js
├── lib/
│   └── point-to-point-example-stack.ts
└── ...
```

Open `lambda-src/producer/send_message_to_sqs.js` in your editor and add the following piece of code:

```javascript
const sqs = require("@aws-sdk/client-sqs");

const client = new sqs.SQSClient();

exports.handler = async (event, context) => {

  const body = { 
    message: 'Hello World from ' + context.functionName 
  };

const command = new sqs.SendMessageCommand({
    MessageBody: JSON.stringify(body),
    QueueUrl: process.env.SQSQueueUrl
  });
  
  const result = await client.send(command);
  return result;
}
```

The function starts by importing the `@aws-sdk/client-sqs` module, which provides the necessary tools for working with SQS, and using it to create an SQS client.

The handler itself creates a `SendMessageCommand` object, including the actual message, and the URL of the queue, which it reads from an environment variable. We'll cover how to set this variable in a later step.

Lastly, the function sends the message using the SQS client, and returns the result of the call.

### 3.2 - Add the Producer Function to the CDK Stack

To create the actual Lambda function in AWS, you need to add it to the stack. To do this, open `lib/point-to-point-example-stack.ts`.

First, add another import statement:

```typescript
import * as lambda from 'aws-cdk-lib/aws-lambda';
```

Then add the following snippet inside the constructor, underneath `const queue = ...`:

```typescript
const producerFunction = new lambda.Function(this, 'Producer', {
  functionName: 'Producer',
  runtime: lambda.Runtime.NODEJS_18_X,
  code: lambda.Code.fromAsset('lambda-src/producer'),
  handler: 'send_message_to_sqs.handler',
  environment: {
    SQSQueueUrl: queue.queueUrl,
  }
});
```

This will create a Lambda function that uses the Node.js runtime, packages and uploads everything inside the `lambda-src/producer` directory we've created above, and configures the function to use the handler function inside `send_message_to_sqs.js`.

Additionally, it sets the environment variable `SQSQueueUrl` to the actual URL of the SQS queue, so that it can be accessed using `process.env.SQSQueueUrl` from within the function.

### 3.3 - Grant Permissions to the Producer Function

Every Lambda function requires a few fundamental IAM permissions, that CDK will deploy by default when creating the function. 

However, it also needs permission to send messages to the queue, which we can add by simply calling the queue's `grantSendMessage` method. Add the following line below your `producerFunction`:

```typescript
queue.grantSendMessages(producerFunction);
```

### 3.4 - Deploy the Producer Function

To deploy the function along with its source code, run the following command in the project directory:

```bash
$ cdk deploy
```

This will prepare the deployment of all new or changed resources, including the new IAM permissions required by the function. 

It is important to note that, if any changes to your stack require the creation or modification of IAM permissions, CDK will prompt you to double-check for security reasons.

![Screenshot showing the confirmation dialog to deploy AWS IAM changes](images/screen-confirm-changes.png)

Type `y` to confirm, and CDK will deploy the new Lambda function along with its IAM Role.

### 3.5 - Test the Lambda Function

Once the function has been deployed, navigate to the Functions list in the [AWS Lambda Dashboard](https://console.aws.amazon.com/lambda).

The function name is the one we defined in the stack: **Producer**. 

Click on it to open its details, and scroll down to the **Code source** section.

The folder in the file explorer on the left contains a file called `send_message_to_sqs.js`.

Double-click on on the file name to open its source and you can see that it's an exact copy of the file we created in our assets folder.

![Screenshot of the producer function source code in the AWS Management Console](images/screen-producer-source.png)

Now let's configure a test event.

To do this, click on the **Test** button. If you haven't configured a test event yet, this wil open the test configuration screen. Enter an **Event name**, e.g. "test-event", and click on **Save**.

Once the test event has been configured, click on **Test** again, which will now directly invoke the Lambda function.

This also creates an **Execution results** tab, including the test event name, the response, and some additional information.

Have a look at the **Response**, which should contain the JSON object returned by the Lambda function, which is exactly what SQS returned as a response to `client.send()` with our message:

```json
{
  "$metadata": {
    "httpStatusCode": 200,
    "requestId": "cb033b2a-1234-5678-9012-66188359d280",
    "attempts": 1,
    "totalRetryDelay": 0
  },
  "MD5OfMessageBody": "b5357af0c1c816b2d41275537cc0d1af",
  "MessageId": "4a76e538-1234-5678-9012-749f0f4b9294"
}
```

Let's go and have a look at our SQS queue to see if we can find the message:

Navigate to the [SQS Dashboard](console.aws.amazon.com/sqs/v2/home) in your AWS account and click on **MyQueue** to open the queue details. 

Now click on the **Send and receive messages** button, and on the next page scroll down to the **Receive messages** section, and click on **Poll for messages**.

This should show all messages that are currently in flight, including the one that your producer function has sent:

![Screenshot of the message that is currently available in the SQS queue](images/screen-message-in-flight.png)

Now click on the message ID to open the message. It should contain the following body:

```json
{"message":"Hello World from Producer"}
```

Congratulations! You've successfully deployed and tested the first Lambda function, which sends messages to the SQS queue.

In the next step, we will build and deploy the consumer function and configure it to automatically be invoked, whenever a new message arrives in the queue.

## Step 4 - Create the Consumer Function and Connect it to the Queue

**TODO**
---

##  Clean-up

Feel free to continue experimenting with the app. Once you're done, you can remove everything that has been deployed by executing:

```bash
$ cdk destroy
```

After a confirmation step, this will delete all resources that have been created as part of the stack. 

The only remaining resource will be the Lambda functions' source code, which has been uploaded to an assets bucket in Amazon S3. 

If you want, you can delete this directly in the [S3 Dashboard](https://s3.console.aws.amazon.com/s3/buckets) of the AWS Management Console:

Look for an S3 bucket called `cdk-XXXXXXXXX-assets-YOUR_ACCOUNT_ID-YOUR_REGION`. This is the bucket that was created when you bootstrapped the account with AWS CDK.

You can delete everything inside the bucket by selecting the radio button next to its name, and clicking on **Empty**:

![Screenshot showing how to empty the asset bucket in S3](images/screen-empty-asset-bucket.png)

This will open a confirmation dialog. Double-check to make sure it is the asset bucket, type _permanently delete_ into the text box, and click on **Empty**.

Now you can also delete the bucket. However, I recommend keeping the bucket for further experiments with AWS CDK. Don't worry about costs, empty S3 buckets are free of charge.

## Conclusion

The asynchronous point-to-point messaging pattern is a widely used communication model in modern web and cloud architectures, and I hope that by following this tutorial, you were able to gain a clear understanding of how you can implement this pattern using Amazon SQS and AWS Lambda.

If you want to learn more, check out these additional resources:

- The [Amazon Simple Queue Service (SQS) Developer Guide](https://docs.aws.amazon.com/AWSSimpleQueueService/latest/SQSDeveloperGuide/welcome.html?sc_channel=el&sc_campaign=appswave&sc_geo=mult&sc_country=mult&sc_outcome=acq)
- All articles tagged [architectural-patterns](https://community.aws/tags/architectural-patterns?sc_channel=el&sc_campaign=appswave&sc_geo=mult&sc_country=mult&sc_outcome=acq)
- More [tutorials](https://community.aws/tags/tutorials?sc_channel=el&sc_campaign=appswave&sc_geo=mult&sc_country=mult&sc_outcome=acq) on community.aws
- More [SQS messaging examples on ServerlessLand](https://serverlessland.com/search?search=sqs?sc_channel=el&sc_campaign=appswave&sc_geo=mult&sc_country=mult&sc_outcome=acq)

## The Complete Source Code

Here is the final source code for the CDK stack defined in `point-to-point-example/lib/point-to-point-example-stack.ts`:


```typescript
import { Construct } from 'constructs';
import { SqsEventSource } from 'aws-cdk-lib/aws-lambda-event-sources';
import * as cdk from 'aws-cdk-lib';
import * as sqs from 'aws-cdk-lib/aws-sqs';
import * as lambda from 'aws-cdk-lib/aws-lambda';

export class PointToPointExampleStack extends cdk.Stack {
  constructor(scope: Construct, id: string, props?: cdk.StackProps) {
    super(scope, id, props);

    // Create the message queue
    const queue = new sqs.Queue(this, 'Queue', {
      queueName: 'MyQueue',
      visibilityTimeout: cdk.Duration.seconds(300),
    });

    // Create the producer function that will send messages
    const producerFunction = new lambda.Function(this, 'Producer', {
      functionName: 'Producer',
      runtime: lambda.Runtime.NODEJS_18_X,
      code: lambda.Code.fromAsset('lambda-src/producer'),
      handler: 'send_message_to_sqs.handler',
      environment: {
        SQSQueueUrl: queue.queueUrl,
      }
    });

    // Grant the producer function permission to send messages
    queue.grantSendMessages(producerFunction);

    // Create the consumer function that will receive messages
    const consumerFunction = new lambda.Function(this, 'Consumer', {
      functionName: 'Consumer',
      runtime: lambda.Runtime.NODEJS_18_X,
      code: lambda.Code.fromAsset('lambda-src/consumer'),
      handler: 'receive_message_from_sqs.handler'
    });

    // Grant the consumer function permission to receive messages
    queue.grantConsumeMessages(consumerFunction);

    // Add the SQS queue as an event source so that it invokes
    // the consumer function whenever there is a new message
    consumerFunction.addEventSource(new SqsEventSource(queue));

  }
}
```

Here's the source code for the producer function located in `point-to-point-example/lambda-src/producer/send_message_to_sqs.js`:

```javascript
const sqs = require("@aws-sdk/client-sqs");

// Create an Amazon SQS service client object.
const client = new sqs.SQSClient();

exports.handler = async (event, context) => {

  // Wrap the message into an object
  const body = { 
    message: 'Hello World from ' + context.functionName 
  };

  // Create a SendMessageCommand with the wrapped message
  // and the URL of the target queue
  const command = new sqs.SendMessageCommand({
    MessageBody: JSON.stringify(body),
    QueueUrl: process.env.SQSQueueUrl
  });
  
  // Send the message and return the result
  const result = await client.send(command);
  return result;
}
```

And here's the source code for the consumer function located in `point-to-point-example/lambda-src/consumer/receive_message_from_sqs.js`:

```javascript
exports.handler = async (event) => {
  // Retrieve the message from the event and log it to the console
  message = event.Records[0].body
  console.log(message);
}
```

### GitHub Repository

This example is also available as a [GitHub repository](https://github.com/build-on-aws/point-to-point-messaging-with-amazon-sqs). To clone it, simply execute:

```bash
$ git clone https://github.com/build-on-aws/point-to-point-messaging-with-amazon-sqs.git
```
