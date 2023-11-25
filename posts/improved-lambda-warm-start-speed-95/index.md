---
title: "We Improved Our Lambda Warm Start Speed by 95%! Here’s How"
description: "Two solutions architects break down the optimization process with a fun question: just how fast can a common Lambda function go?"
tags:
  - aws
  - lambda
  - optimization
authorGithubAlias:
  - lucamezzalira
  - mattddiamond
authorName:
  - Luca Mezzalira
  - Matt Diamond
date: 2023-11-26
---

![a team does maintenance work on a race car](/images/headerimage.jpeg)

[AWS Lambda](https://docs.aws.amazon.com/lambda/?sc_channel=el&sc_campaign=reinvent&sc_geo=mult&sc_country=mult&sc_outcome=acq&sc_content=improved-lambda-warm-start-speed-95) is a fantastic compute choice, providing a wide variety of runtimes, a pay-for-use model, and native integration with AWS services — a great starting point for a modern microservices architecture. While there are many benefits to using Lambdas, a few challenges face developers using them, and one of those is cold starts.

While cold starts have been mitigated by the Lambda service in recent years, they still introduce latency and unpredictability, which can pose challenges in particular for applications with consistent response time requirements. Moreover, managing external resources like databases or third-party services can further complicate Lambda development.

This is where performance tuning, effective architecture design, and the implementation of best practices and tools come into play — allowing you to fully leverage the capabilities of AWS Lambda. In this post we will focus on on performance tuning and how to improve the transactions-per-second of your Lambda.

## The Challenge

We set out to optimize a very common pattern: a Lambda triggered by API Gateway that retrieves data from an Amazon Aurora RDS Relational Database. Our fictitious app retrieves a list of Professional American Football (NFL) stadiums in the United States from an Aurora RDS Database and returns them as a JSON object. Lambda is a great choice for our app as each request is short (under 10ms) and can quickly scale up to respond to hand high transactions per second. 

![the architecture of a simple application](/images/image_1.png)

Our goal: to see exactly how much we can improve the performance of our Lambda through different optimization techniques. Seems fairly straightforward, right? Well... it may be more complicated than you’d think.

As you’ll see, we learned there’s a lot of nuanced decisions made in the journey toward optimization. Everything from which database client is chosen to the memory configuration of the Lambda can have significant impact on Lambda performance.

## Testing the Application

Any good experiment needs a method for testing the results. Here’s how we approached testing our application.

First, we have two versions of the application: the first version is a simple app before any optimizations have been implemented; the second version of the application we optimized over time by identifying enhancements and measuring the performance gains for each one. You can find the code examples on our [AWS Sample github repository](https://github.com/aws-samples/optimizations-for-lambda-functions). Below is the diagram for the pre-optimized version.

As we tested performance, we hoped to identify the optimal configuration for a GET request to a Lambda and retrieve data from an [Aurora Database](https://docs.aws.amazon.com/rds/?sc_channel=el&sc_campaign=reinvent&sc_geo=mult&sc_country=mult&sc_outcome=acq&sc_content=improved-lambda-warm-start-speed-95). To simulate users and requests, Artillery was used to send data to API Gateway, and then to Lambda. Artillery lets a developer test their application in a defined way using a YAML configuration file. We configured our tests to be 60 seconds long, in one of two configurations. The first test starts at 50 RPS and runs for a minute. You can see the configuration of Artillery below:

![the configuration of Artillery](/images/image_2.png)

Here’s a quick breakdown of the process we used for measuring and improving performance.

First, we leveraged AWS Powertools, which is a library that allows Serverless developers to quickly implement best practices and improve developer velocity. Powertools includes methods and libraries for quickly implementing consistent logging, metrics, and traces inside your codebase. For instance, with X-Ray you have a companion for your distributed traces. Traces allows you to understand an end-to-end event as it goes from resource to resource by segment. One of the benefits of using X-Ray is to capture the individual performance by segment and log if there was a cold start. Here’s an example of one of these logs below. Notice below the column labeled “coldStarts” for each invocation of the Lambda with a value of “1”. 

Second, by instrumenting the the application, we were able to identify the segments of code that weren’t performing well and identify additional changes we could make to optimize. (Don’t worry: we’ll get to these changes in a minute.)

![logs insights](/images/image_3.png)

We measured performance by evaluating the segment timeline. Take the Segment Timeline below, which shows segment by segment how long each phase took during the initialization of the Lambda. Highlighted in the orange box is the total time that that specific initialization took for Lambda to run our code — which was 1.43 seconds.

You’ll notice that we didn’t focus on the total duration of 2.79 seconds. You may be wondering why. Well, this number includes things like Lambda service overhead of 38 ms, which as a developer, you can’t control. (That overhead is time that Lambda service requires to set up each invocation, like starting up and shutting down the environment.)

Instead, our focus is only on the segments we can directly impact with code changes. Our testing will focus on two metrics: reducing the number of cold starts, and reducing how long an initialization runs. Reducing the execution time of a function will increase the TPS per sandbox. 

![segments timeline](/images/image_4.png)

## Method 1: High-level View, Implementation, Testing/Data Summaries

Amazon RDS Proxy is a natural addition to ensuring performance between a Lambda and the RDS Database. While both the pre-optimized and optimized versions of our application have an RDS Proxy configured, it’s worth calling out here the benefits of the service. This includes the ability to to efficiently scale the connections to your Serverless applications. Further, RDS Proxy enables you to maintain predictable database performance by managing the number of database connections that are opened. Managing connections helps manage unpredictable workloads and can provide higher availability in the event of a transient database failure. 

One last consideration for performance optimization: when designating code as an ES module, you can use the await keyword at the top level of your code. With this feature, Node.js can complete the asynchronous initialization code before the handler invocations. Here we are making the request to AWS Systems Manager Parameter Store, which will complete prior to the first invocation. You can read more about the level await [here](https://aws.amazon.com/blogs/compute/using-node-js-es-modules-and-top-level-await-in-aws-lambda/?sc_channel=el&sc_campaign=reinvent&sc_geo=mult&sc_country=mult&sc_outcome=acq&sc_content=improved-lambda-warm-start-speed-95) in this AWS Blog article. This is important, as you’re getting the benefit of the additional CPU during initialization (above 1.8 GB of memory), providing additional compute that otherwise be used for the TLS Handshake as part of AWS Systems Manager Parameter Store.

![api](/images/image_5.png)

At this stage, we were happy with our API, we have minified and bundle the code, we followed the best practices like top-level await, we set a sensible memory size to mantain the costs low and so on. However we noticed during the ramped up load testing that the application reached 33 TPS before triggering errors. We saw a reduction in execution time. More specifically, we observed that there were 18 cold starts with a 1.42 second execution time. Once the execution environment was created, the cold starts were eliminated, and we saw 167ms execution times. This was exacerbated when we ran a sustained test and saw 137 cold starts, which reduced the number of TPS that the application could scale to until there were sufficient execution environments created.

![The load test results for the unoptimized Lambda function](/images/image_6.png)

So, we asked ourselves: what can we do to make our API handle more requests with the same Lambda function execution environment to decrease the cost and the response time as well? Looking at the most common ways to optimize a workload running on a Lambda function, we could start looking at the bundle size of the Lambda code.

## Dependencies and bundle size

When we analyzed how the bundle was composed using `esbuild —analyse` flag we quickly realized the major offender for the bundle size was the package `moment-timezone`, a dependency used by Sequelize, the SQL module used for querying Postgres.

![moment-timezone is the largest module by far in this bundle](/images/image_7.png)

Therefore, we looked into replacing it with another Postgres library and we found in Postgres.js the perfect answer.

In fact, just refactoring the code and removing Sequelize in favour of Postgres.js moved the bundle size from 1.6MB to slightly over 40KB. The final bundle of the optimized version after adding more libraries ended up being 246KB. This was a great result with a small effort. Considering our function is not very complex, think what you can achieve in workloads with a large codebase per function.

![The unoptimized version has a bundle size of 1.6MB versus the optimized one that is 246KB](/images/image_8.png)

## Leveraging extensions

Using the top-level await for retrieving the parameters from Parameters Store was fine, but at scale the challenge is that you have to deal with the [transactions per second quotas](https://docs.aws.amazon.com/general/latest/gr/ssm.html?sc_channel=el&sc_campaign=reinvent&sc_geo=mult&sc_country=mult&sc_outcome=acq&sc_content=improved-lambda-warm-start-speed-95) of the `getParameter(s)` API. In many cases the parameters are not changing every second or even less. So the Parameters Store team created an extension for Lambda functions that takes care to retrieve the parameters from Parameters Store and/or secrets from Secrets Manager. The extension takes care also to cache these data, and you can configure multiple parameters — for instance, the time-to-live before retrieving again these data from both services.

![some of the parameters you can configure for the Parameters Store and Secrets Manager Lambda extension](/images/image_9.png)

If you are not familiar with Lambda function extensions, think about them like a background process. Therefore the communication between the Lambda function and an extension happens via localhost as you can see in the following example `database/DBParameters.ts` integration.

![a Lambda function communicates with the Parameters Store extension with a simple HTTP request. Then the extension takes care to fetch the requested parameter or retrieve it from the internal cache without calling the Parameters Store API](/images/image_10.png)

When we decided to integrate the extension, we were able to remove all the dependencies to the AWS SDK, trimming down the size of the final bundle and improving the execution time of the function that know retrieves the parameters less often than consuming an API from the AWS SDK and it’s cached in the same network. We moved from double-digit responses via the SDK to single-digit from the extension.

This latency reduction improved the response time of the optimized function making our response time faster and reducing the cost for running our logic.

## Cache Aside Pattern

While we were running load testing sessions, we asked ourselves if the response of the API could be cached or not. In the initial test, also with the best execution time, the Lambda function was spending more than 100ms to perform the same query over and over again.

![Over 100ms of query response time every single invocation](/images/image_11.png)

In our experience — not only in our case but in many others we have seen in the trenches — a cache can become a mechanism to improve the API response time and reduce the strain for upstream dependencies. Even content that changes frequently might have some parts (if not the entire data set) that is cacheable for few seconds or minutes. It might seem like a small amount of time, but absorbing hundreds or thousands of requests using a cache pattern helps you to handle more traffic and reduces the load towards a database or a third party system, for instance.

We decided to use [Amazon ElastiCache](https://docs.aws.amazon.com/elasticache/?sc_channel=el&sc_campaign=reinvent&sc_geo=mult&sc_country=mult&sc_outcome=acq&sc_content=improved-lambda-warm-start-speed-95) for storing temporarily the query result and relying on Redis cache eviction mechanisms for querying fresh data from Postgres when data weren’t available in ElastiCache.

![Amazon ElastiCache is now queried before RDS to check if the data is available in the in-memory cache, otherwise the business logic will perform a query to RDS through RDS Proxy](/images/image_12.png)














