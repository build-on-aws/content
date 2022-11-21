---
title: Which Data Storage Option Should I Choose?
description: How to choose a data storage solution based on a scenario
tags:
    - data storage
    - post
    - aws
authorGithubAlias: spara
authorName: Sophia Parafina
date: <expected publish date in YYYY-MM-DD format>
---

Modern applications need storage for data, logs, user files, and databases. As a cloud engineer, you can choose from object storage, block storage, and file system storage. Each type of storage can meet specific business requirements, but which one should you use? Let's examine a common scenario for each type of storage to learn when you should -- or shouldn't -- use them.

## When to use object storage

Let's say a company is building a data lake to serve their customers better by analyzing business data they collect. In addition to the transaction data collected in a data warehouse, they collect data from log files, social media, click streams, and Internet of Things (IoT) devices.

It's important to know that the data collected is customer data, which requires secure and durable storage because it contains Personally Identifiable Information (PII). The data is collected continuously and requires petabyte or larger storage as it grows; it is also unstructured. Data analysts use an extraction, translation, and loading (ETL) tool that writes a schema on the fly, making the data available to analytic tools like [Apache Spark](https://spark.apache.org/) or [PrestoDB](https://prestodb.io/). Machine learning specialists process the data with machine learning frameworks for forecasting outcomes. The applictions used by data analytists and machine learning specialists require low latency for processing data to produce forecasts for consumer behavior, to support cross-selling and upselling.

In this case, the company's data lake requires scalability, security, durability, and low latency. Object storage is ideal for any application with these requirements for several reasons. First, object storage uses a flat address space that allows it grow as more data is added. Second, object storage uses extensible metadata which allows cloud providers to implement security and compliance models to protect the data. Third, data is written across multiple nodes for redundancy, meaning that if one node is dropped there are copies of data, making object storage durable. Finally, object storage supports the transfer of data at 100 gbps within the same region.

Object storage is commonly used by companies that stream rich media content such as videos, perform data backup and archiving, machine learning, and big data analytics. 

## When to use block storage

A business is migrating from an on-premise e-commerce platform to a cloud based e-commerce platform. The platform they've chosen uses a relational database that holds customer data, transactions, and product inventory. As with many large B2B sites, the e-commerce platform processes thousands of transactions per second while maintaining inventory. The database requires extremely low latency and high input/output per second (IOPS).

The business needs a highly optimized solution that supports frequent read and write changes without rewriting an entire file. Direct I/O access is crucial to system performance. Furthermore, the storage solution must attach to the database host and scale as needed. 

In this case, block storage is the best solution for low-latency and high throughput storage required by relational database processing thousands of transactions per second. Similar to a Storage Area Network (SAN), block storage can provide sub-millisecond latency, up to 256,000 IOPS, and 4,000 MB/second throughput with 64 TB of capacity. Block volumes can attach directly to a database and resize volumes as data grows. In addition, block storage is redundant and provides the durability required for e-commerce applications.

Block storage is ideal for mission critical business applications such as Oracle, SAP, or Microsoft Exchange. Server-side applications built with Java, .NET, or PHP also benefit from high throughput and low latency provided by block storage.

## When to use file storage

A company is expanding it's offices across the globe. Previously, most offices maintained Network Attached Storage (NAS) for locally shared storage, but as the company has grown it needs centralized storage for business documents, media assets, database backups, and home directories for its employees. Storage has to be available 24/7, durable, scalable, low latency, and most importantly integrate with existing business systems and software.

File storage is a hierarchical system of files and directories that the majority of software currently support. File storage is ideal for common office workloads becaue employees are familiar with file storage which works like a desktop computer's file system or NAS. Unlike local file systems, cloud file storage is a fully managed solution deployable at a global scale. Cloud file storage is available in all time zones and built on top of block storage which provides the durability, scalability, and low latency required by business operations. File sharing protocols, such as SMB and NFS, are included with cloud file systems and applications natively connect to cloud storage. 

However, the hierarchical design of file storage places limitations on the size of files, the number of files stored, and directory depth because exceeding those limits would degrade performance and increase latency. Files systems scale horizontally by adding more systems to increase storage. This is differs from block or object storage which scales vertically by adding resources to an instance.

Despite this limitation, file storage can meet the requirements of most business operations and software. File storage is the best solution for shared drives, popular business software such as Microsoft Word or Excel, and other desktop applications.

## Once More with Feeling

Start with your storage needs, based on the application or task requirements, to choose which solution best fits.

If you need to store large volumes of data, object storage is the choice for elastic scaling into the petabytes, where security, durability, and low latency are required.

If your application performs frequent reads and writes of data, block storage is the choice for applications needing direct I/O access and optimized for high throughput of data read/write. It provides durability by storing data redundantly and can be directly attached to a host server.

Finally, file storage is a flexible general purpose storage solution that fulfills most business requirements by providing a shared file system accessible by business applications. It is available globally, and has the same durability and security features as the block storage it is built on.

If you want to learn more about each type of storage, check out this [resource](https://aws.amazon.com/products/storage/?stod_rr2) with use cases, tutorials, and guides.
