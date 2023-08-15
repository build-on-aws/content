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

Building resilient systems is a high priority for customers and is critical to delivering a positive customer experience. Designing these systems requires a data-driven decision making process, appropriate technology support, and people defining a centralized strategy across the organization. In this blog we’ll cover considerations for developing an observability strategy to support your resilience and business objectives. First we’ll define what observability and resilience means. Then, cover a few different areas across the resilience domain where having a well defined metrics and data is critical, and finally share some guidance and best practices to help you build your own observability strategy.

## What is observability and what is resilience?

Observability is ... Resilience is ...

## Observability metrics to establish baselines and define resilience objectives

Need to establish your foundation.

## Observability into the customer experience, operations, and failure scenarios

Start by measuring the customer experience.

## Observability for post-incident retrospectives

An important part to maintaining resilient systems is ensuring that issues that do occur, only do so once.

## Conclusion

Now picture the same scenario that we started with, this time with the appropriate observability measures in place. Starting at 2:00 pm, you get warnings of increased error rates on your order processing applications. Support engineers swarm to investigate and resolve this issue while customer service prepares potential communications for customers. Senior management is alerted early that there’s an ongoing issue but that 90% of customer’s are without impact, and ones impacted are only receiving intermittent errors. Management is now closely monitoring this metric to see if it reaches a critical point and the failover plan needs to be executed. Thankfully, you’ve caught the problem early on and identified an underlying infrastructure failure. The troublesome infrastructure has been replaced and requests error rates drop to a healthy level by 3:15 pm. Customer impact was minimized and your teams get to go home early and enjoy the weekend!

Thanks to having a well-defined observability strategy you had the data you needed to make critical decisions, were aware in near real-time of the status of your service and what customers were experiencing, and finally able to quickly identify the cause of the problem and mitigate the impact. Following the event you also have data needed to complete a retrospective of the incident, perform a root-cause analysis and build your correction of error plan to avoid this happening again.
