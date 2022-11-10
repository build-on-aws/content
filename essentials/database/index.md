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
* [Time-Series](#what-are-time-series-databases)
* [Ledger](#what-are-ledger-databases)


## **What are relational databases?**

Relational databases store and provide access to data that has predefined relationships. This category of database is well suited for storing data about entities with related metadata. The database uses indexes called keys to store relationships between records in the system.

An example use for relational databases is an e-commerce store which can be modeled with data tables for products, customers, and orders. A `products` table might have a field with a numeric identity like `29476` that represents an individual product in a company's catalog. That field would be the key for the `products` table, and other tables &mdash; like `orders` &mdash; can reference a product by its key instead of duplicating the product information in the `orders` table. Similarly the `customers` table would have a unique key for each customer and the `orders` table can reference the customer by storing the key to the customer instead of keeping duplicate copies of data in each table.


[Amazon RDS Tutorial](https://aws.amazon.com/getting-started/hands-on/create-connect-postgresql-db/)
[Amazon Aurora Tutorial](https://aws.amazon.com/getting-started/hands-on/configure-connect-serverless-mysql-database-aurora/)


## **What are key-value databases?**

A key-value database is a type of nonrelational database that uses a simple key-value method to store data. A key-value database stores data as a collection of key-value pairs in which a key serves as a unique identifier. Both keys and values can be anything, ranging from simple objects to complex compound objects. Key-value databases are frequently used for session storage in web applications and other applications where data can be retrieved by a single key.

Game developers often use key-value databases to store the state of an individual user's gaming session as a single `value` with the user's unique identifier as the `key`. Instead of creating multiple records with individual values for each attribute of the session, the developer will create a single nested object&mdash;often encoded as `JSON` data. Then the session data can be stored or retrieved with a single call to the database, making reads and updates efficient and fast.


[Amazon DynamoDB Tutorial](https://aws.amazon.com/getting-started/hands-on/create-nosql-table/)

## **What are document databases?**

<<<<<<< HEAD
## **What about high availability and fault tolerance?**
=======
A document database is a type of nonrelational database that is designed to store and query data as JSON-like documents. Document databases make it easier for developers to store and query data in a database by using the same document-model format they use in their application code. 
>>>>>>> fcc9896e0c9e3e56a236abddaf4334f547bb89c5

Document databases are frequently used for content management systems where a single web page is modeled with many nested content components.

[Amazon DocumentDB Tutorial](https://aws.amazon.com/getting-started/hands-on/getting-started-amazon-documentdb-with-aws-cloud9/)

## **What are in-memory databases?**

In-memory databases are purpose-built databases that rely primarily on memory for data storage, in contrast to databases that store data on disk or SSDs. In-memory data stores are designed to enable minimal response times by eliminating the need to access disks.

In-memory databases are perfect for applications where response time is critical. One common use case is a search engine, where different facets of records are listed in the database with references to the originating document. Indexable values in the document are stored as keys in the in-memory database and the value is stored as a reference to the original document. Searches only need to scan the keys in memory to get a list of documents that match the search criteria.

[MemoryDB Tutorial](https://docs.aws.amazon.com/memorydb/latest/devguide/getting-started.html)
[Amazon ElastiCache for Redis Tutorial](https://docs.aws.amazon.com/AmazonElastiCache/latest/red-ug/GettingStarted.html)

## **What are graph databases?**

Graph databases are purpose-built to store and navigate relationships. Relationships are first-class citizens in graph databases, and most of the value of graph databases is derived from these relationships. Graph databases use nodes to store data entities, and edges to store relationships between entities. An edge always has a start node, end node, type, and direction, and an edge can describe parent-child relationships, actions, ownership, and the like. There is no limit to the number and kind of relationships a node can have.

Fraud detection engines often use graph databases to find links between real-time activities and known fraudulent historical data. Entities like `person` or `bank account` are connected to fraud activities. Following the edges of the entities allows the fraud engine to determine whether there is a relationship between the actor and historical fraud records.

[Getting Started with Amazon Neptune](https://docs.aws.amazon.com/neptune/latest/userguide/graph-get-started.html)

## **What are time-series databases?**

Time-series databases are optimized to store and access event data. Time-series databases allow you to access and analyze events in near-real time, providing insight into trends and patterns in your systems as they occur.

IoT (Internet of Things) data is commonly stored in a time-series database. Internet-connected devices will send periodic status snapshots of important metrics like `temperature` or `fuel-level`. The time-series database allows applications to rapidly query data for a specific date range, or perform more complex calculations required for alerting operators when data changes in ways that are contrary to previously recorded historical data.

[Amazon Timestream Tutorial](https://docs.aws.amazon.com/timestream/latest/developerguide/getting-started.db-w-sample-data.html)

## **What are ledger databases?**

A ledger database provides a transparent, immutable, and cryptographically verifiable transaction log. Ledger databases are append-only, giving you an accurate history of all change history, while cryptographic verification gives you proof of data integrity.

Inventory systems are good candidates for ledger databases. Inventory changes are stored as transactions in the system either adding or subtracting from inventory. Because the ledger is append-only, the system is verifiably accurate and tamper proof. 

[Getting Started with Amazon QLDB](https://docs.aws.amazon.com/qldb/latest/developerguide/getting-started.html)