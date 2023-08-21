---
title: "Building an Observability Strategy for Resilience"
description: "Replace with your description"
tags:
    - aws
    - observability
    - resilience
    - cloud-strategy
authorGithubAlias: khubyar
authorName: Khubyar Behramsha
date: 2023-09-20
showInHomeFeed: true
---
**EVERYTHING BELOW GETS REPLACED WITH YOUR CONTENT ONCE YOU'VE UPDATED THE FRONTMATTER ABOVE**

## Introduction

It is 4:25pm on a Friday afternoon, you’re an engineer that get’s a call saying that a customer can’t complete their order on your website. Immediately you start investigating and start to ask around if there are any issues with your system, but you are having trouble understanding if this is a platform issue or something isolated to one customer. Soon you find out that parts of your order processing service is down and multiple customers are impacted, but not all. Questions start to come down from management about what exactly is impacted, what is the level of impact, how much longer can we sustain increased load on the remaining infrastructure, and finally, should we engage our disaster recovery plan? 

Building resilient systems is a high priority for customers and is critical to delivering a positive customer experience. Designing these systems requires a data-driven decision making process, appropriate technology support, and people defining a centralized strategy across the organization. In this blog we will cover considerations for developing an observability strategy to support your resilience and business objectives. First we will define what observability and resilience means. Then cover a few different areas across the resilience domain where having well defined telemetry is critical. Finally, we'll share some guidance and best practices to help you build your own observability strategy.

## What is observability and what is resilience?

Let's start by aligning on how we define a few terms we'll use throughout this blog: observability, monitoring, and resilience. In modern control system theory, observability is defined as the ability to determine the internal states of the system by observing its output. Monitoring is the systematic collection of data about a system, and serves as an enabler for observability. Resilience is the ability of an application to resist or recover from certain types of faults or load spikes, and remain functional from the customer perspective. These three things are closely intertwined with monitoring being an enabler for observability which is an enabler for resilience.

## Observability metrics to establish baselines and define resilience objectives

Before starting planning any journey, its typically important to know at least these two things: where you want to go and where you are starting from. Things are no different here. To start building a observability strategy it's important to know what we are working toward, and that is where having well defined resilience objectives comes in. Resilience objectives are commonly measured in terms of recovery point objective (RPO) and recovery time objective (RTO), or simply, "how much data can you lose?" and "how long can your service be disrupted?". Establishing these requires collaboration between the technology and business teams and should be a nuanced discussion of the trade offs on complexity, cost, and resources required to meet the objectives. Once this is in place, you have a common target that all teams can work toward. 

To aid in the RPO/RTO discussion it is helpful and in some cases a pre-requisite, to be prepared with data points on the current state of your workloads. Arming yourself with information like duration and cause of past incidents, current performance benchmarks, and metrics on the current customer experience will allow you to have a data-driven conversation with the business when establishing your objectives. You may consider capturing things like the current requests per second, the average CPU and memory usage, average request duration, and any alarms that are currently configured. In addition to capturing what you already are doing, you also want to establish the key indicators you will use to identify the health of your system, often referred to as SLIs or service level indicators. It is important to select the right amount of these based on the things your users expect from the system. If your application's primary purpose is storing data, a user is likely to be more concerned with durability and receiving a timely notification that their data has been securely saved. On the other hand, if you've got a system that shares data to customers in real-time, page load times and throughput might be better indicators of system health. Choosing too few SLIs puts you at risk of leaving large parts of the system unexamined, while selecting too many could distract from the critical SLIs. 

## Observability into the customer experience, operations, and failure scenarios

Now that we've established where we are and where we want to go, we need to start taking steps down the appropriate path. Starting with the objectives set out, we worked backwards to establish the key indicators we want to monitor. With resilience in mind, the most important thing is reducing negative impacts to the customer experience. So in addition to monitoring actual user metrics, it will be helpful if we can simulate customer actions using synthetic canaries and simulated customer load. This provides a steady stream of data points that we can measure against and also allows us the ability to test, in a non-production environment, the impact of changes to our system from things like code deployments, infrastructure modifications, new architecture designs. 

While monitoring simulated and live user metrics provides a good representation of the customer experience, these are often lagging indicators. To improve our overall resilience posture, ideally we can prevent the user experience from ever being impacted by identifying the things at our application and infrastrcuture level that cause downstream impacts to the customer. When building an observability strategy, there will be some standard metrics and best practices you can safely recommend all workloads implement, and others that will be specific to that workload. The strategy should be focused on the outcomes of implementing the appropriate telemetry so that individual teams have the flexibility to develop what they need, but still meet your organization's resilience objectives. Setting hard requirements like "CPU utilization should always be less than 85%" may not apply to workloads that use serverless services. Instead, recommending that system capacity should stay 15% higher than system load, allows DevOps teams across the organziation to monitor their systems and respond in a similar way even though the underlying infrastructure looks different.

## Observability for post-incident retrospectives

An important part to maintaining resilient systems is ensuring that issues that do occur, only do so once.

## Conclusion

Now picture the same scenario that we started with, this time with the appropriate observability measures in place. Starting at 2:00 pm, you get warnings of increased error rates on your order processing applications. Support engineers swarm to investigate and resolve this issue while customer service prepares potential communications for customers. Senior management is alerted early that there’s an ongoing issue but that 90% of customer’s are without impact, and ones impacted are only receiving intermittent errors. Management is now closely monitoring this metric to see if it reaches a critical point and the failover plan needs to be executed. Thankfully, you’ve caught the problem early on and identified an underlying infrastructure failure. The troublesome infrastructure has been replaced and requests error rates drop to a healthy level by 3:15 pm. Customer impact was minimized and your teams get to go home early and enjoy the weekend!

Thanks to having a well-defined observability strategy you had the data you needed to make critical decisions, were aware in near real-time of the status of your service and what customers were experiencing, and finally able to quickly identify the cause of the problem and mitigate the impact. Following the event you also have data needed to complete a retrospective of the incident, perform a root-cause analysis and build your correction of error plan to avoid this happening again.
