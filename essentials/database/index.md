---
title: Database Essentials
description: Learn about Databases at AWS
tags:
    - database
    - essentials
    - aws
authorGithubAlias: bketelsen
authorName: Brian Ketelsen
date: 2022-11-15
---

# Database Essentials

Every application needs a place to store data from users, devices, and the application itself. Databases are important backend systems that are used to store, manage, update, and analyze data for all types of applications, from small back-office systems to mobile and consumer web applications with global scale.

## **Sections:**

- [What are the different categories of databases?](#what-are-the-differernt-categories-of-databases)
- [What are relational databases?](#what-are-relational-databases)
- [What are key-value databases?](#what-are-key-value-databases)
- [What are document databases?](#what-are-document-databases)
- [What are in-memory databases?](#what-are-in-memory-databases)
- [What are graph databases?](#what-are-graph-databases)
- [What are time-series databases?](#what-are-time-series-databases)
- [What are ledger databases?](#what-are-ledger-databases)

## **What are the different categories of databases?**

AWS offers seven categories of purpose-built databases. Each category offers different performance characteristics, allowing you to choose the data store that performs best with your workloads and applications.

The seven categories are:

* [Relational](#what-are-relational-databases)
* [Key-Value](#what-are-key-value-databases)
* [Document](#what-are-document-databases)
* [In-Memory](#what-are-in-memory-databases)
* [Graph](#what-are-graph-databases)
* [Time Series](#what-are-time-series-databases)
* [Ledger](#what-are-ledger-databases)


## **What are relational databases?**

Relational databases store and provide access to data that has pre-defined relationships. This category of database is well suited for storing data about entities with related metadata. An example use for relational databases is an e-commerce store which can be modeled with data tables for products, customers, and orders.

[Amazon RDS Tutorial](https://aws.amazon.com/getting-started/hands-on/create-connect-postgresql-db/)
[Amazon Aurora Tutorial](https://aws.amazon.com/getting-started/hands-on/configure-connect-serverless-mysql-database-aurora/)


## **What are key-value databases?**

A key-value database is a type of nonrelational database that uses a simple key-value method to store data. A key-value database stores data as a collection of key-value pairs in which a key serves as a unique identifier. Both keys and values can be anything, ranging from simple objects to complex compound objects. Key-value databases are frequently used for session storage in web applications and other applications where data can be retrieved by a single key.

[DynamoDB Tutorial](https://aws.amazon.com/getting-started/hands-on/create-nosql-table/)

## **What are document databases?**

A document database is a type of nonrelational database that is designed to store and query data as JSON-like documents. Document databases make it easier for developers to store and query data in a database by using the same document-model format they use in their application code. 

[DocumentDB Tutorial](https://aws.amazon.com/getting-started/hands-on/getting-started-amazon-documentdb-with-aws-cloud9/)

## **What are in-memory databases?**

In-memory databases are purpose-built databases that rely primarily on memory for data storage, in contrast to databases that store data on disk or SSDs. In-memory data stores are designed to enable minimal response times by eliminating the need to access disks.

[MemoryDB Tutorial](https://docs.aws.amazon.com/memorydb/latest/devguide/getting-started.html)
[ElastiCache for Redis Tutorial](https://docs.aws.amazon.com/AmazonElastiCache/latest/red-ug/GettingStarted.html)

## **What are graph databases?**

Graph databases are purpose-built to store and navigate relationships. Relationships are first-class citizens in graph databases, and most of the value of graph databases is derived from these relationships. Graph databases use nodes to store data entities, and edges to store relationships between entities. An edge always has a start node, end node, type, and direction, and an edge can describe parent-child relationships, actions, ownership, and the like. There is no limit to the number and kind of relationships a node can have.

[Getting Started with Amazon Neptune](https://docs.aws.amazon.com/neptune/latest/userguide/graph-get-started.html)

## **What are time-series databases?**

Time-series databases are optimized to store and access event data. Time-series databases allow you to access and analyze events in near real-time providing insight into trends and patterns in your systems as they occur.

[Amazon Timestream Tutorial](https://docs.aws.amazon.com/timestream/latest/developerguide/getting-started.db-w-sample-data.html)

## **What are ledger databases?**

A ledger database provides a transparent, immutable, and cryptographically verifiable transaction log. Ledger databases are append-only, giving you an accurate history of all change history, while cryptographic verification gives you proof of data integrity.

[Getting Started with Amazon QLDB](https://docs.aws.amazon.com/qldb/latest/developerguide/getting-started.html)