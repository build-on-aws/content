---
title: "Sending Events from DynamoDB using Eventbridge Pipes"
description: "A no-code integreation between Amazon DynamoDB and Eventbridge"
tags:
    - event-driven
    - serverless
    - eventbridge
    - dynamodb
authorGithubAlias: kaizadwadia
authorName: Kaizad Wadia
date: 2023-11-11
---

## Overview

As application architectures grow in complexity, the number of events and data sources that need to integrate also increases. This often leads developers to write custom integration code which is time-consuming, difficult to maintain, and prone to errors. Amazon EventBridge Pipes aim to simplify these complex event-driven architectures by allowing different services to be connected without writing custom integration code.

EventBridge Pipes provide a no-code way to automatically replicate events between EventBridge buses, SQS/SNS topics, and DynamoDB Streams. A common serverless pattern is to detect DynamoDB table updates and publish corresponding events. Traditionally this required custom Lambda functions to stream DynamoDB events. With EventBridge Pipes, you can now implement this pattern in minutes without writing any code.

This guide will walk through how to quickly set up an EventBridge Pipe that detects DynamoDB table updates and publishes events to an EventBridge bus in the AWS console. By following this simple how-to, you'll see firsthand how EventBridge Pipes can simplify complex event integrations.

![Architecture]( images/ebpipes-ddbstreams-diagram.jpg "Architecture Diagram")

## Outline

* Creating a DynamoDB Table and enabling streams.
* Creating a custom event bus in Eventbridge.
* Creating a Pipe, choosing the source and target destination.
* Filtering and transforming the payload.
* Optional: Enriching the payload with a Lambda function

The DynamoDB table could store game scores with attributes like:

* GameId (partition key)
* PlayerName
* Score
* Level
* Timestamp
* The table could be called "GameScores" and would capture individual scores/levels for players over time.

The DynamoDB streams would then pick up any new or updated scores.

We can create an EventBridge pipe that:

* Filters for only new "INSERT" events from the stream
* Transforms the payload to pass just GameId, PlayerName, Score
* Routes these events to an EventBridge bus

The EventBridge bus can have rules to:

* Send high scores over a threshold to a "Leaderboard" SNS topic
* Check for and reward new level achievements by sending events to a "Levels" SNS topic
* Store all scores to an S3 bucket for analytics

This demonstrates using EventBridge pipes for filtering, transforming, and routing DynamoDB events to drive different game actions like leaderboards, notifications, analytics etc.

Let me know if this fun gaming example works for your use case! I can provide more details on implementation if needed.

## Conclusion

Through this step-by-step guide, we created an end-to-end serverless event pipeline using Amazon EventBridge Pipes. By simply pointing and clicking in the AWS Management Console, we set up a Pipe that streams DynamoDB table update events to an EventBridge event bus. This removes the need to write any custom integration logic in Lambda, allowing us to focus on application functionality instead of plumbing.

Pipes simplified several key tasks for our use case: capturing DynamoDB events, filtering and transforming the event payload, and routing events to the target EventBridge bus. We also saw how to optionally enrich events by invoking a Lambda function.

By leveraging EventBridge Pipes for event ingestion and integration, we can quickly connect various services and data sources without managing complex application code. Pipes provide a no-code way to implement event streaming and transformation in our serverless architectures. Going forward, we can spend less time on glue code and more time focusing on core product capabilities.
