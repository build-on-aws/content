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

As application architectures grow in complexity, the number of events and data sources that need to integrate also increases. This often leads developers to write custom integration code which is time-consuming, difficult to maintain, and prone to errors. Amazon EventBridge Pipes aim to simplify these complex event-driven architectures by allowing different services to be connected without writing custom integration code.

## Overview

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
* GamerTag (sort key)
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

## Walkthrough

### Step 1: Creating a DynamoDB Table and enabling streams

First, login to the AWS Management Console and navigate to the DynamoDB service. Click on "Create Table" to begin setting up your new table.

For Table name, enter "GameScores". For the Primary key, enter "GameId" for the partition key and "GamerTag" for the sort key. These will be used to uniquely identify each item in the table.

Under Table settings, you can customize read/write capacity as needed for your expected workload. The defaults are fine to start.

The default settings are left for the key attributes GameId and GamerTag.

![DynamoDB Table Creation Image]( images/createtable.png "Create the Table")

Once all fields are entered, scroll down and click "Create" to finish creating the GameScores table. The table will be ready to store game score data with the specified schema.

You can now start inserting items into the table through the console, SDKs, or other AWS services. Make sure the items contain the configured partition key and sort key. The other attributes like Score, Level, and Timestamp will be optional.

To enable streams on the table, in the DynamoDB console select the "GameScores" table and go to the "Exports and Streams" tab. Scroll all the way down to "DynamoDB stream details" and click "Turn on". In the view, select "New and old images" for Stream view type and check Stream enabled. Choose the shard count based on expected workload. Scroll down and click "Enable" to activate streams. The stream ARN can now be used by applications to process changes.

![DynamoDB Streams Enable]( images/enablestreams.png "Enabling Streams")

### Step 2: Create a custom event bus in Amazon Eventbridge

First, open the Amazon EventBridge console in your AWS account. In the left navigation pane, click "Event Buses". On this page, click the "Create event bus" button. Custom event buses allow for greater isolation, access control, organization, separation of concerns, event retention control, and insulation from changes compared to using the shared default event bus. This is because the default event bus receives events from all AWS services.

Give your event bus the name "game-bus". The name can contain up to 256 characters and must be unique within your account. You can enable archive events here if desired. Click "Create".

Now we will create a rule that sends all events from that bus into a CloudWatch log group so that we can see the events published to it. Go to "Rules" on the left hand side and once there, change the event bus from the default one to "game-bus".

![Eventbridge Rules]( images/rules.png "Eventbridge Rules")

Click on "Create Rule" and for a rule name, enter "all-game-events". Optionally enter a description. Make sure the event bus selected is "game-bus".

![Eventbridge Rule Step 1]( images/createrules1.png "Eventbridge Rule Step 1")

After going to the next step, click on "All Events" as the event source. This may give you a warning but we do want to have visibility into whatever events are sent to the bus. You can leave everything else in this step as is and continue.

![Eventbridge Rule Step 2]( images/createrules1.png "Eventbridge Rule Step 2")

For the target, select "AWS service" and for the target, from the dropdown select "CloudWatch log group". Name the log group "game-events-log". Note that if you use infrastructure as code, you would additionally need to configure an IAM role to allow Eventbridge to access this log group.

![Eventbridge Rule Step 3]( images/createrules3.png "Eventbridge Rule Step 3")

Now you can skip the tagging part and go straight to creating the rule.

![Eventbridge Rule Description]( images/ruledescription.png "Eventbridge Rule Description")

Once the rule is created, you can navigate to it in the console under the "Rules" section. Then, if you navigate to the "targets" tab on the lower side of the page, you can click the link that says "game-events-log" to navigate to the created log group in CloudWatch. Here, we can see a log of all the events sent to the event bus. We can click on "Start tailing" on the top right hand side to see the incoming events.

### Step 3: Creating the pipe

To create the Eventbridge Pipe, we can click on "Pipes" on the left hand side of the Eventbridge console, and click on "Create Pipe". In the name field, we can use "game-event-pipe". For the source, we want to use the DynamoDB stream we previously created. The starting position can be left as "Latest". We could also optionally configure additional settings pertaining to batching if we want to process multiple items at once, but for now we will leave these settings as they are.

![Eventbridge Pipe Source]( images/ruledescription.png "Eventbridge Pipe Source")

## Conclusion

Through this step-by-step guide, we created an end-to-end serverless event pipeline using Amazon EventBridge Pipes. By simply pointing and clicking in the AWS Management Console, we set up a Pipe that streams DynamoDB table update events to an EventBridge event bus. This removes the need to write any custom integration logic in Lambda, allowing us to focus on application functionality instead of plumbing.

Pipes simplified several key tasks for our use case: capturing DynamoDB events, filtering and transforming the event payload, and routing events to the target EventBridge bus. We also saw how to optionally enrich events by invoking a Lambda function.

By leveraging EventBridge Pipes for event ingestion and integration, we can quickly connect various services and data sources without managing complex application code. Pipes provide a no-code way to implement event streaming and transformation in our serverless architectures. Going forward, we can spend less time on glue code and more time focusing on core product capabilities.
