---
title: "Coding Publish and Subscribe Using SNS, SQS, and the AWS SDKs"
description: "Confused about the trying to code publish and subscribe using SNS and SQS? AWS Console tutorials help, but they are not the same as sample code. Here we acquaint you with the topics and queues workflow code example, part of the code examples repository."
tags:
    - sns
    - sqs
    - sdk
    - c++ 
    - java
    - kotlin
    - dotnet
 
authorGithubAlias: meyertst-aws
authorName: Steven Meyer
date: YYYY-MM-DD (expected publication date) TODO
---
##

| ToC |
|-----|


This article describes the topics and queues workflow sample code that is part of the [AWS SDK code examples GitHub repository](https://github.com/awsdocs/aws-doc-sdk-examples). 
This workflow sample code demonstrates publish and subscribe 
using Amazon Simple Notification Service (Amazon SNS) and Amazon Simple Queue Service (Amazon SQS). This sample code is implemented in multiple programming languages. 
For example, if you would like to code publish and subscribe using Java, 
there is Java topics and queues workflow sample code to get you started. The topics and queues workflow sample code runs as a command-line application. This 
application allows you to select options and observe their behavior. You can play with filter subscriptions, or you can see what is required to implement a FIFO queue.


[Topics and Queues Workflow in the code example library](https://docs.aws.amazon.com/code-library/latest/ug/sns_example_sqs_Scenario_TopicsAndQueues_section.html)

## Publish and Subscribe

Publish and subscribe is a mechanism for passing information. It’s used in social media, and it’s also used internally in software applications. A producer publishes a message, and the subscribers receive the message. In software, publish and subscribe notifications make message passing flexible and robust. The producers of messages are decoupled from the consumers of messages.

You can publish and subscribe using Amazon SNS alone. But combining Amazon SNS with Amazon SQS gives you more flexibility in how the messages are consumed.

Amazon SNS is a push service. It pushes to endpoints such as email addresses, mobile application endpoints, or SQS queues. (For a full list of endpoints, see [SNS event destinations](https://docs.aws.amazon.com/sns/latest/dg/sns-event-destinations.html)).

With Amazon SQS, messages are received from a queue by polling. With polling, the subscriber receives messages by calling a receive message API. Any code can poll the queue. Also, the messages stay in the queue until you delete them. This gives you more flexibility in how the messages are processed.

## SNS Workflow Command-line application 

Note: The actual interface may vary slightly between programming languages. 

### Create an SNS topic

```
Would you like to work with FIFO topics? (y/n) 
```

You configure FIFO (First-In-First-Out) topics when you create them. Choosing a FIFO topic enables other options, too. To learn more, see [FIFO topics example use case](https://docs.aws.amazon.com/sns/latest/dg/fifo-example-use-case.html).


```
Use content-based deduplication instead of a deduplication ID? (y/n)
```

Deduplication is only available for FIFO topics. Deduplication prevents the subscriber from responding more than once to events that are determined to be duplicates. If a message gets published to an SNS FIFO topic and it’s found to be a duplicate within the five-minute deduplication interval, the message is accepted but not delivered. For more information, see [Message deduplication for FIFO topics](https://docs.aws.amazon.com/sns/latest/dg/fifo-message-dedup.html).

Content-based deduplication uses a hash of the content as a deduplication ID. If content-based deduplication is not enabled, you must include a deduplication ID with each message.

```
Enter a name for your SNS topic:
```

Topic names can have 1-256 characters. They can contain uppercase and lowercase ASCII letters, numbers, underscores, and hyphens. If you chose a FIFO topic, the application automatically adds a “.fifo” suffix, which is required for FIFO topics.

### Create two SQS queues

Now, configure two SQS queues to subscribe to your topic. Separate queues for each subscriber can be helpful. For
instance, you can customize how messages are consumed and how messages are filtered.

```
Enter a name for an SQS queue.
```

Queue names can have 1-80 characters. They can contain uppercase and lowercase ASCII letters, numbers, underscores, and hyphens. If you chose a FIFO topic, the application automatically adds a “.fifo” suffix, which is required for FIFO queues.


```
Filter messages for "<queue name>.fifo"s subscription to 
the topic "<topic name>.fifo"?  (y/n)
```

If you chose FIFO topics, you can add a filter to the queue’s topic subscription. There are many ways to filter a topic. In this example code, you have the option to filter by a predetermined selection of attributes. For more information about filters, see [Message filtering for FIFO topics](https://docs.aws.amazon.com/sns/latest/dg/fifo-message-filtering.html).


```
You can filter messages by one or more of the following "tone" attributes.
1. cheerful
2. funny
3. serious
4. sincere
Enter a number (or enter zero to stop adding more)
```

If you add a filter, you can select one or more “tone” attributes to filter by. When you’re done, enter “0’” to continue.

The application now prompts you to add the second queue. Repeat the previous steps for the second queue.

The following diagram shows the topic and queue options.

![Diagram of the options](images/fifo_topics_diagram.png)

After you create the topic and subscribe both queues, the application lets you publish messages to the topic.


```
Enter a message text to publish.
```

All configurations include a message text.


```
Enter a message group ID for this message.
```

If this is a FIFO topic, then you must include a group ID. The group ID can contain up to 128 alphanumeric characters `(a-z, A-Z, 0-9)` and punctuation `(!"#$%&'()*+,-./:;<=>?@[\]^_``{|}~)`.
For more information about group IDs, see [Message grouping for FIFO topics](https://docs.aws.amazon.com/sns/latest/dg/fifo-message-grouping.html).


```
Enter a deduplication ID for this message.
```

If this is a FIFO topic and content-based deduplication is not enabled, then you must enter a deduplication ID. The message deduplication ID can contain up to 128 alphanumeric characters `(a-z, A-Z, 0-9)` and punctuation `(!"#$%&'()*+,-./:;<=>?@[\]^_``{|}~)`.


```
Add an attribute to this message? (y/n) y
```

If you added a filter to one of the subscriptions, you can choose to add a filtering attribute to the message.


```
1. cheerful
2. funny
3. serious
4. sincere
Enter a number for an attribute: 
```

Select a number for an attribute.


```
Post another message? (y/n)
```

You can post as many messages as you want.

When you are done posting messages, the application polls the queues and displays their messages.

## Conclusion

At the time of this writing, topics and queues workflows exist for the following languages.
* Java
* C++
* Kotlin

Implementations for other languages will soon be added. The existing implementations can be found on the [code example library](https://docs.aws.amazon.com/code-library/latest/ug/sns_example_sqs_Scenario_TopicsAndQueues_section.html) website. The code can be downloaded from [AWS SDK Code Examples](https://github.com/awsdocs/aws-doc-sdk-examples)  github repository.