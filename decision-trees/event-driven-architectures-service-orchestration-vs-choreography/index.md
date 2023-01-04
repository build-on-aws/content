---
title: Event-Driven Architectures: Service Orchestration vs. Choreography
description: Quick introduction and comparison of two architectural styles, service orchestration and service choreography, including an overview of possible implementations on AWS.
tags:
    - ditributed architecture
    - service orchestration
    - service choreography
    - workflow
    - event-driven
    - decision-trees
    - aws
authorGithubAlias: danilop
authorName: Danilo Poccia
date: 2021-01-31
---

When designing a distributed application, two main architectural styles can be used: service orchestration or service choreography.

With service orchestration, we have a central point of control, the orchestrator, that coordinates all interactions between services. This is usually implemented using a workflow with the workflow engine being the orchestrator.

With service choreography, each service knows what to do and how to interact with other services but there is no centralized control. For example, in an event-driven architecture, each service knows which events it can receive and which events it can emit. The responsibility of the bus is just to route events to the right receivers.

## Comparing Service Orchestration and Choreography

To compare the two architectures, let’s see what happens if we try to add a new service to an existing distributed architecture:

- To add a new service to a workflow, we need to update the workflow to use the new service in the correct way. For example, when adding a fraud detection system to an ecommerce application, we have to find the right place in the different workflows (such as order creation) that can benefit from fraud detection. If the fraud detection service detects a possible fraud, then the workflow should follow a different path where this is managed.

- When adding a new service to an event-driven architecture, we need to know which events the new service is interested to, which events can be emitted, and who can be interested to these emitted events. For example, when adding a fraud detection system to an ecommerce application, we tell the bus which events the fraud detection system is interested to (such as a `NewOrder` event) and which services could be interested in its output (such as a `PossibleFraud` event). If a fraud detection can block an order, we can have the delivery service wait for an explicit `NoFraudDetected` event before progressing the order.

Events work best when connecting services managed by different teams. Event-driven architectures keep these services loosely coupled so that it is easier to update them without having side effects on other services. In this way, the work of one team has a more limited impact on the work of other teams, and teams are not blocked waiting for other teams to complete their part of a task.

Workflows work best to coordinate work inside a single service, managed by a single team, when strict coordination is needed. For example, using the saga pattern, workflows can replace distributed transactions.

> Starting from scratch with events can be more complex than using a workflow but adding new functionality to an event-driven architecture should be easier because of the reduced coupling.

## Implementing Service Choreography

On AWS, you can use different services to implement service choreography. For example:

- [Amazon EventBridge](https://aws.amazon.com/eventbridge/) provides a serverless event bus that by default can listen to events emitted by AWS services and can be extended to process custom events. You can create rules that look for events published on a bus a route those events to the correct destinations.

- [Amazon SNS](https://aws.amazon.com/sns/) provides Pub/Sub messaging using topics. You can use [Amazon SQS](https://aws.amazon.com/sqs/) to subscribe queues to those topics to improve resilience and control the speed at which messages sent to these topics are consumed. You can use Pub/Sub messaging to build an event-driven architecture but it is usually more complex than when using an event bus. With SNS, you might need to create multiple topics and subscriptions (using message filtering to receive only a subset of the messages published to the topic) while, with EventBridge, you can have a single bus with multiple rules to control how event are routed to their destinations.

- In case you need strict message ordering and deduplication, you can send first in, first out (FIFO) Pub/Sub messages using [SNS FIFO](https://docs.aws.amazon.com/sns/latest/dg/sns-fifo-topics.html) topics and [SQS FIFO](https://docs.aws.amazon.com/AWSSimpleQueueService/latest/SQSDeveloperGuide/FIFO-queues.html) queues. There are some scalability limits when using SNS and SQS FIFO compared to their normal implementation so check if there are ok for your use case.

- To integrate with existing and open-source solutions, you can use [Amazon MQ](https://aws.amazon.com/amazon-mq/), a managed message broker service for [Apache ActiveMQ](https://activemq.apache.org) and [RabbitMQ](https://www.rabbitmq.com), or [Amazon Managed Streaming for Apache Kafka (Amazon MSK)](https://aws.amazon.com/msk/), a fully managed, highly available [Apache Kafka](https://kafka.apache.org) service.

- To collect and process real-time data streams for analytics and machine learning, you can use [Amazon Kinesis Data Streams](https://aws.amazon.com/kinesis/data-streams/).

- [AWS AppSync](https://aws.amazon.com/appsync/) provides a [GraphQL](https://graphql.org) interface for the application frontend including Pub/Sub APIs that can interact with data in the backend and supports offline data synchronization, versioning, and conflict resolution.

- For IoT use cases, you can use [AWS IoT Core](https://aws.amazon.com/iot-core/) to use the [MQTT](https://mqtt.org) protocol to exchange messages between IoT devices, applications, and AWS services.

## Implementing Service Orchestration

On AWS, you can use different services to implement service orchestration. For example:

- With [AWS Step Functions](https://aws.amazon.com/step-functions/) you can design and run workflows using state machines. The business logic can run on any compute platform, such as [AWS Lambda](https://aws.amazon.com/lambda/) functions, [AWS Fargate](https://aws.amazon.com/fargate/) containers, [Amazon EC2](https://aws.amazon.com/ec2/) instances, and on-prem resources.

- You can use [Amazon Managed Workflows for Apache Airflow (MWAA)](https://aws.amazon.com/managed-workflows-for-apache-airflow/) to orchestrate workflows using directed acyclic graphs (DAGs) written in Python. This is well suited to connect cloud and on-premises resources using [Apache Airflow](https://airflow.apache.org) providers or custom plugins.

- To automate data flows between software as a service (SaaS) and AWS services, you can use [Amazon AppFlow](https://aws.amazon.com/appflow/), a fully managed integration service to transfer data between services such as [Salesforce](https://www.salesforce.com/), [SAP](https://www.sap.com/), [Google Analytics](https://analytics.google.com/), and [Amazon Redshift](https://aws.amazon.com/redshift/).
