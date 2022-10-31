---
title: How to choose the right database for your use case
description: Use this decision tree to help you pick the right database.
tags:
    - database
    - decision-trees
    - aws
authorGithubAlias: bketelsen
authorName: Brian Ketelsen
date: 2022-11-15
---

<!-- Throughout this template there will be comments like these, please remove them before committing the first version of the content piece. -->

Choosing the right database for your workload can be overwhelming. To help you navigate through the options and choose a solution that is best for your workload, we've created this decision tree. Answer this series of questions about your workload and business requirements to get a database recommendation.


<!-- Each branch of the decision tree has 2+ options to it, and we show that here by splitting it into branch and option sections -->

## My Data is Relational

Relational databases enforce strict data schema and relationship structures between entities in your data. Use a relational database when the structure of your data is known in advance, and slow to change. Common uses for relational databases are CRM, finance, ERP and web applications.

### Amazon RDS

<!-- Description here is limited to 100 words, focus on the why/when to choose this option -->
This is the first concrete implementation recommended

### Amazon Aurora

<!-- Description here is limited to 100 words, focus on the why/when to choose this option -->
This is the first concrete implementation recommended

## My Application Requires High Throughput Reads and Writes with Low Latency

Overview of what this branch focusses on, why you would choose it.

### Amazon DynamoDB

<!-- Description here is limited to 100 words, focus on the why/when to choose this option -->
This is the first concrete implementation recommended

### Option 2b

<!-- Description here is limited to 100 words, focus on the why/when to choose this option -->
This is the first concrete implementation recommended

## My Data is Highly Connected

Overview of what this branch focusses on, why you would choose it.

### Amazon Neptune

<!-- Description here is limited to 100 words, focus on the why/when to choose this option -->
This is the first concrete implementation recommended

### Option 2b

<!-- Description here is limited to 100 words, focus on the why/when to choose this option -->
This is the first concrete implementation recommended

## My Application Has Large Traffic Spikes and Needs Microsecond Response Times

Overview of what this branch focusses on, why you would choose it.

### Amazon ElastiCache

<!-- Description here is limited to 100 words, focus on the why/when to choose this option -->
This is the first concrete implementation recommended

### Option 2b

<!-- Description here is limited to 100 words, focus on the why/when to choose this option -->
This is the first concrete implementation recommended

## My Application needs to Aggregate, Index, and Search in Near Real Time

Overview of what this branch focusses on, why you would choose it.

### Amazon ElasticSearch Service

<!-- Description here is limited to 100 words, focus on the why/when to choose this option -->
This is the first concrete implementation recommended

### Option 2b

<!-- Description here is limited to 100 words, focus on the why/when to choose this option -->
This is the first concrete implementation recommended   