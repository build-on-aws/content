---
title: Which Data Storage Option Do I Choose
description: How to choose a data storage solution based on a scenario
tags:
    - data storage
    - post
    - aws
authorGithubAlias: spara
authorName: Sophia Parafina
date: <expected publish date in YYYY-MM-DD format>
---

As a cloud engineer, you can choose from object storage, block storage, and file system storage to support application business requirements. Each type of storage has attributes that meet specific business requirements. Let's examine a common scenario for each type of storage. 

## Building a Datalake

A company is building a data lake to serve their customers by analyzing business data. In addition to the transaction data collected in a data warehouse, they collect data from log files, social media, click streams, and Internet of Things (IoT) devices.

First, the data collected is customer data which requires secure and durable storage. The data is collected continuously and requires petabyte or larger storage as it grows. It is also unstructured and analysts plan to use an extraction, translation, and loading (ETL) tool that writes a schema on the fly making the data available to analytic tools, such as [Apache Spark](https://spark.apache.org/) or [PrestoDB](https://prestodb.io/), and machine learning frameworks for forecasting outcomes. Analytics and machine learning both require low latency for processing the data.

Given the requirements for scale, security, durability, and low latency, object storage is ideal for any application with these requirements. Object storage uses a flat address space that allows it grow as more data is added. Object data uses extensible metadata which allows cloud providers to implement security and compliance models to protect the data. In object storage, data is written across multiple nodes for redundancy, meaning that if one node is dropped there are copies of data, making object storage durable. The implementation of fast object storage supports the transfer of data at 100 gbps within the same region.

## Building an E-Commerce Database

A business is migrating from an on premise e-commerce platform to a cloud based e-commerce platform. The platform they've chosen uses a relational database the holds customer data, transactions, and product inventory. As with many large B2B sites, it processes thousands of transaction per second while maintaining inventory. The database requires extremely low latency and high input/output per second (IOPS).

To meet these requirements, a solution must be highly optimized to support frequent read and write changes without rewriting an entire file. Direct I/O access is crucial to system performance. The storage device must attach to the database host and scale as needed. 

In this case, block storage meets these requirements. Similar to a Storage Area Network (SAN), block storage can provide sub-millisecond latency, up to 256,000 IOPS, and 4,000 MB/second throughput with 64 TB of capacity. Block volumes can attach directly to a database and resize volumes as data grows. In addition, block storage is redundant and provides the durability required for e-commerce applications. 

## Building a Shared Workspace

A company is expanding it's offices across the globe. Previously, most offices maintained Network Attached Storage (NAS) for locally shared storage, but as the company has grown it needs centralized storage for business documents, media assets, database backups, and home directories for its employees. Storage has to be available 24/7, durable, scalable, low latency, and most importantly integrate with existing business systems and software.

File storage is a hierarchical system of files and directories that the majority of software currently support. Employees are familiar with file storage because it works similarly to their computer's file system and NAS. However, unlike local file systems file storage in the cloud is a fully managed solution deployable at a global scale. Cloud file storage is available in all time zones and built on top of block storage which provides the durability, scalability, and low latency required by business operations. File sharing protocols, such as SMB and NFS, are included with cloud file systems and applications natively connect to cloud storage.  However, the hierarchical design of file storage placed limitations on the size of files, the number of files stored, and directory depth because exceeding those limits would degrade performance and increase latency. Keep in mind that file storage will meet the requirements of most business operations and software. In addition, cloud providers have other storage implementations for business processes with requirements not met by general file storage.

## Once More with Feeling

Object storage is the choice for elastic scaling into the petabytes, where security, durability, and low latency are required.

Block storage is the choice where applications need direct I/O access and optimized for high throughput of data read/write. It provides durability by storing data redundantly and can be directly attached to a host server.

File storage is a general purpose storage solution that fulfills most business requirements by providing a shared file system accessible by business applications. It is available globally, and has the same durability and security features as the block storage it is built on.
