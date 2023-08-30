---
title: "How to Build and Manage a Resilient Service Using Health Checks, Decoupled Dependencies, and Load Balancing using AWS SDKs"
description: "Did you know you can deploy and manage a load-balanced, resilient web service entirely with AWS SDKs?"
tags:
  - ec2
  - auto-scaling
  - load-balancing
  - resilience
  - sdk
  - python
authorGithubAlias: Laren-AWS
authorName: Laren Crawford
date: 2023-08-30
---

| ToC |
| --- |

Are you a developer who wants to build and manage a resilient service? Have you worked through tutorials like 
[Health Checks and Dependencies](https://wellarchitectedlabs.com/reliability/300_labs/300_health_checks_and_dependencies/?sc_channel=el&sc_campaign=resiliencewave&sc_geo=mult&sc_country=mult&sc_outcome=acq&sc_content=resilient-service)
and want to accomplish the same thing using code to build and manage your infrastructure? This article and code
example show you how to use AWS SDKs to set up a resilient architecture that includes AWS services like 
Amazon EC2 Auto Scaling and Elastic Load Balancing. You’ll learn how to write code to monitor your service, 
manage health checks, and make real-time repairs to make your service more resilient. And you’ll do it all 
without ever opening the AWS Management Console.

This example is available now in the [AWS SDK Code Example Library](https://docs.aws.amazon.com/code-library/latest/ug/what-is-code-library.html?sc_channel=el&sc_campaign=resiliencewave&sc_geo=mult&sc_country=mult&sc_outcome=acq&sc_content=resilient-service).

### Just want to see the code?

The code for this example is part of a collection of code examples that show you how to use 
[AWS software development kits (SDKs)](https://aws.amazon.com/what-is/sdk/?sc_channel=el&sc_campaign=datamlwave&sc_geo=mult&sc_country=mult&sc_outcome=acq&sc_content=sagemaker-pipelines) 
with your development language of choice to work with AWS services and tools. You can download all of the examples, 
including this one, from the [GitHub repository](https://github.com/awsdocs/aws-doc-sdk-examples).

To see the code and follow along with this example, clone the repository and choose your preferred language 
SDK from the list below. Each language link takes you to a README file that includes setup instructions 
and prerequisites for that specific version.

- [Python](https://github.com/Laren-AWS/aws-doc-sdk-examples/tree/resilient-architecture-python/workflows/resilient_service/README.md)

## How does this example work?  

This code example is an interactive scenario that you run at a command prompt. It deploys all of the resources 
needed to run a load-balanced web service that returns recommendations of books, movies, and songs. It begins with 
a fairly naive design, simulates varying kinds of failures, and shows you how to address failures in increasingly 
sophisticated ways. Along the way, you can make requests to the web service and get information about the health of 
your system. At the end of the demo, the service has become more resilient and presents a more
consistent and positive customer experience even when failures occur.

Several components are used to demonstrate the resilience of the example web service:

* [Amazon EC2 Auto Scaling](https://docs.aws.amazon.com/autoscaling/ec2/userguide/what-is-amazon-ec2-auto-scaling.html) 
  is used to create 
  [Amazon Elastic Compute Cloud (Amazon EC2)](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/concepts.html) 
  instances based on a launch template and to ensure that the number of instances is kept 
  in a specified range.
* [Elastic Load Balancing](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/introduction.html) 
  handles HTTP requests, monitors the health of instances in the Auto Scaling group, and 
  dispatches requests to healthy instances. 
* A Python web server runs on each EC2 instance to handle HTTP requests. It responds
  with recommendations and health checks.
* An [Amazon DynamoDB](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/Introduction.html) 
  table simulates a recommendation service that the web server depends on to get recommendations.
* A set of [AWS Systems Manager](https://docs.aws.amazon.com/systems-manager/latest/userguide/what-is-systems-manager.html) 
  parameters that control how the web server responds to requests and health checks to 
  simulate failures and demonstrate resiliency. 

### Explore the interactive scenario

The interactive scenario has three main phases: deploy resources, demonstrate resiliency, and destroy resources.

#### Deploy resources

The first part of the example deploys all of the resources you need for a load-balanced web service:

```bash
stuff
```

#### Demonstrate resiliency

```bash
stuff
```

#### Destroy resources

```bash
stuff
```

### What features are included in the example?

The following sections describe some primary features of this code example. This, and related information, can also be found within each language README within the GitHub repository.

#### Pipeline steps

[Pipeline steps](https://docs.aws.amazon.com/sagemaker/latest/dg/build-and-manage-steps.html?sc_channel=el&sc_campaign=datamlwave&sc_geo=mult&sc_country=mult&sc_outcome=acq&sc_content=sagemaker-pipelines) define the actions and relationships of the pipeline operations. The pipeline in this example includes an [AWS Lambda step](https://docs.aws.amazon.com/sagemaker/latest/dg/build-and-manage-steps.html#step-type-lambda?sc_channel=el&sc_campaign=datamlwave&sc_geo=mult&sc_country=mult&sc_outcome=acq&sc_content=sagemaker-pipelines)
and a [callback step](https://docs.aws.amazon.com/sagemaker/latest/dg/build-and-manage-steps.html#step-type-callback?sc_channel=el&sc_campaign=datamlwave&sc_geo=mult&sc_country=mult&sc_outcome=acq&sc_content=sagemaker-pipelines).
Both steps are processed by the same example Lambda function.

The Lambda function handler is included as part of the example, with the following functionality:

- Starts a [SageMaker Vector Enrichment Job](https://docs.aws.amazon.com/sagemaker/latest/dg/geospatial-vej.html?sc_channel=el&sc_campaign=datamlwave&sc_geo=mult&sc_country=mult&sc_outcome=acq&sc_content=sagemaker-pipelines) with the provided job configuration.
- Processes Amazon SQS queue messages from the SageMaker pipeline.
- Starts the export function with the provided export configuration.
- Completes the pipeline when the export is complete.

![Pipeline image](/images/Pipeline.PNG)

#### Pipeline parameters

The example pipeline uses [parameters](https://docs.aws.amazon.com/sagemaker/latest/dg/build-and-manage-parameters.html?sc_channel=el&sc_campaign=datamlwave&sc_geo=mult&sc_country=mult&sc_outcome=acq&sc_content=sagemaker-pipelines) that you can reference throughout the steps. You can also use the parameters to change
values between runs and control the input and output setting. In this example, the parameters are used to set the Amazon Simple Storage Service (Amazon S3)
locations for the input and output files, along with the identifiers for the role and queue to use in the pipeline.
The example demonstrates how to set and access these parameters before executing the pipeline using an SDK.

#### Geospatial jobs

A SageMaker pipeline can be used for model training, setup, testing, or validation. This example uses a simple job
for demonstration purposes: a [Vector Enrichment Job (VEJ)](https://docs.aws.amazon.com/sagemaker/latest/dg/geospatial-vej.html?sc_channel=el&sc_campaign=datamlwave&sc_geo=mult&sc_country=mult&sc_outcome=acq&sc_content=sagemaker-pipelines) that processes a set of coordinates to produce human-readable
addresses powered by Amazon Location Service. Other types of jobs can be substituted in the pipeline instead.

### Try it for yourself

Using the AWS SDK, you can manage, execute, and update AWS SageMaker pipelines in your preferred programming language. Using pipeline parameters and steps alongside SDK actions, you can utilize the features of AWS SageMaker machine learning in a dynamic way that can be integrated into larger systems. 

Check out the [example code library](https://docs.aws.amazon.com/code-library/latest/ug/what-is-code-library.html?sc_channel=el&sc_campaign=datamlwave&sc_geo=mult&sc_country=mult&sc_outcome=acq&sc_content=sagemaker-pipelines) for this and other detailed examples for your AWS services.
