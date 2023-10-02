---
title: "Where Do I Put Stuff? Cloud Storage for the Busy Admin"
description: "An overview of how to choose the appropriate cloud storage solution based on multiple criteria. Presents examples from a cloud storage AWS Summit video and a learning path throug AWS Skillbuilder."
tags:
    - storage
    - it-pros
    - skill-builder
authorGithubAlias: spara
authorName: Sophia Parafina
date: 2023-09-29
---

Storage is a topic most people don’t think about unless there isn’t enough, or it’s too slow, or it’s hard to find their data. This is true for both on-premise solutions such as Network Attached Storage (NAS) and cloud storage. Cloud storage offers many solutions to these problems, but the choosing a cloud storage solution depends on a factors such as volume of data, throughput requirements, type of data, durability, and accessibility. This article examines cloud storage options through a scenario based lens. FIrst, we’ll review cloud storage basics. Then we’ll look at a framework for choosing an appropriate cloud storage solution for your organization's needs. We’ll review a video by Senior Storage Solution Architects who present solutions to common customer scenarios. We’ll finish up by presenting an AWS Skill Builder earning path for storage.

## Cloud Storage Basics

There are three types of cloud storage - object storage, block storage and file storage. Let’s start with object storage which is designed for holding massive volumes of data by distributing it across multiple nodes (drives attached to a server), or buckets. Objects contain data, metadata, and a unique object ID. Object IDs look like file paths but store objects in a flat, non-hierarchical address space that scales horizontally. Object storage stores data redundantly across nodes which prevents data loss. Another attribute of object storage is that it grows as needed by adding nodes and shrinks by removing nodes. Object stores use a REST API for putting, retreiveing, or updating objects. 

Block storage stores data in fixed-size pieces called blocks. A collection of blocks forms a volume that can be treated as a unit of storage, e.g., a drive. When you write data to block storage, it's split across blocks. For example if you have a 17kb file and blocks are fixed at 4kb, the data is written across five blocks, i.e., 4kb + 4kb + 4kb + 4kb +1kb. Think of blocks as low-level components for storing data efficiently. When data is written to block storage, each part is written with a unique identifier, and data is retrieved using the identifier.

File storage is how we typically store data and is implemented on top of block storage. File storage is hierarchical and mirrors how we store information physically, i.e., on paper and stored in folders. Every file has a path that is a hierarchy of folders or directories. Files can have metadata such as timestamps and permissions that control reading, writing, and execution. File storage allows for reading and changing a part of a file unlike object stores. It is useful for workloads that require access to a file by multiple services or people. However, file storage has limitations such only one person or service can write to the file at a time. Another limitation is that file systems don’t scale well, a hierarchical structure imposes an operational overhead caused by traversing the path. When there thousands of users and millions of files nested in directories performance can degrade.

The trick to efficiently using cloud storage is knowing which type to use when. In the following section, we’ll look at criteria for deciding which type of storage to use.

## Criteria for Choosing Cloud Storage

There are a number of criteria to consider when choosing cloud storage. The primary factors are protocol, client type, performance, migration strategies and risk, backup and protection requirements, disaster recovery, cost, and security. Let’s look at each factor.

**Protocol** - They determine how data accessed and managed by services, software, and people. For example, most people are familiar with file systems on personal computers and servers. File systems are mountable by operating systems that support NFS or SMB and provide access to data shared by multiple users and services. Review the protocols that your applications use and factor in that information when choosing cloud storage.

Some applications, such as databases, require fast read and write to storage. Block storage is directly attached to servers and offer high performance I/O throughput and low latency access. It’s ideal for applications that require fast and a large volume of throughput, but don’t need the shared access or the overhead of  a hierarchical file system.

If your application access data over the Internet through an application programming interface (API), object storage is an obvious choice. It’s built for read-heavy workloads and highly elastic, growing and shrinking as needed.

**Client Type** - Windows and Unix/Linux are common operating systems that use file system storage. AWS offers file systems tailored to your compute needs. For general purpose computing,[ Elastic File System (EFS)](https://aws.amazon.com/efs/?sc_channel=el&sc_campaign=post&sc_content=practicalcloudguide&sc_geo=mult&sc_country=global&sc_outcome=acq&sc_publisher=amazon_media&sc_category=mult&sc_medium=body) is available. If you’re an enterprise Windows administrator, [Amazon FSx Windows File Server](https://aws.amazon.com/fsx/windows/?sc_channel=el&sc_campaign=post&sc_content=practicalcloudguide&sc_geo=mult&sc_country=global&sc_outcome=acq&sc_publisher=amazon_media&sc_category=mult&sc_medium=body) fully supports Windows applications with the Server Message Block (SMP) protocol. If you need a file system for high performance computing (HPC) or machine learning, [Amazon FSx for Lustre](https://aws.amazon.com/fsx/lustre/?sc_channel=el&sc_campaign=post&sc_content=practicalcloudguide&sc_geo=mult&sc_country=global&sc_outcome=acq&sc_publisher=amazon_media&sc_category=mult&sc_medium=body) works with Unix/Linux file systems. Matching the client type to the storage solution is critical for reliable and efficient data transfer.

**Performance** - This criteria can be defined in different ways depending on the use case. Performance can be defined as low latency, high throughput, e.g., input/output operations per second (IOPs), read and write access patterns, and bandwidth. Consider these performance criteria in the context of the applications accessing storage.

**Migration Strategy and Risks** - If you have terrabytes or petabytes of data, what’s your strategy for moving data into or out of cloud storage? Have you planned the lifecycle for your data, i.e., how long do you have to maintain that data? What are the regulatory compliance requirements, are  you working towards SOC 2 certification? These are the type of questions to consider.

**Backup/protection Requirements** - What are your requirements for preventing data loss from accidental deletion, natural disasters, or hardware failure. Do you have geographic requirements for storing data offsite? These factors feed into disaster recovery.

**Disaster Recovery** - Can you recover from a cyberattack, human error, or a natural disaster? How long will it take for your business to operational after an incident? [Recovery time objectives (RTO) and recovery point objectives (RPO)](https://docs.aws.amazon.com/whitepapers/latest/disaster-recovery-of-on-premises-applications-to-aws/recovery-objectives.html?sc_channel=el&sc_campaign=post&sc_content=practicalcloudguide&sc_geo=mult&sc_country=global&sc_outcome=acq&sc_publisher=amazon_media&sc_category=mult&sc_medium=body) define the the time to restoration of a service and the maximum amount of time acceptable for service interruption, respectively. These are importance considerations when considering storage.

**Cost** - The total cost of storage is more than capacity, it also includes data transfer and availability. AWS provides tools such as the [AWS Cost Explorer](https://aws.amazon.com/aws-cost-management/aws-cost-explorer/?sc_channel=el&sc_campaign=post&sc_content=practicalcloudguide&sc_geo=mult&sc_country=global&sc_outcome=acq&sc_publisher=amazon_media&sc_category=mult&sc_medium=body) and [AWS Pricing Calculator](https://calculator.aws/#/?sc_channel=el&sc_campaign=post&sc_content=practicalcloudguide&sc_geo=mult&sc_country=global&sc_outcome=acq&sc_publisher=amazon_media&sc_category=mult&sc_medium=body) to estimate costs for your workloads and help find the right storage service for your applications.

**Security** - The AWS shared responsibility model ensures that services are secure. There are multiple security requirements including access control, data encryption, monitoring and logging, compliance criteria, and incident response. Customers are responsible for addressing these requirements to protect data, applications, and infrastructure.

## Choosing Cloud Storage in Practice

Applying this decision framework can be complex because the requirements for each situation varies. Matching use cases to solutions would require a lengthy introduction to the storage services offered by AWS. Fortunately, there is a video summarizing five common customer scenarios presented at AWS Atlanta Summit in 2022. Presented by Senior Storage Solution Archtects, Kevin McDonald and Victor Munoz they introduce AWS storage options and some of the considerations when choosing a solution. The video starts with detailed overview of AWS cloud storage.

https://www.youtube.com/embed/A14EbSrZeFM?start=0&end=840

After the introduction, the video presets five common customer scenarios.

* Scenario 1: Migrating existing applications to the cloud
* Scenario 2: Backing up data to the cloud
* Scenario 3: Hybrid - using cloud storage with on-premises applications
* Scenario 4: Building a data lake
* Scenario 5: Building a new application


> Tip: If you prefer to read the video transcript open the `Description`, choose **...more** and the choose the **Transcript** button at below `Key Moments`. The transcript is displayed on the right.

In addition to a top-level scenario, they also discuss variations of each scenario. The video begins with **Scenario 1: Migrating existing  migrating existing applications to the cloud** and divides it into two sub-scenarios. The sub-scenario 1a covers applications the use direct-attached storage or a a SAN. These applications would user cloud block storage. The second sub-scenario 1b addresses applications that use a file share or a NAS, i.e., file storage. This section of the video is also applicable to **Scenario 5: Building a new application**.

https://www.youtube.com/embed/A14EbSrZeFM?start=840&end=1455

The video transitions into **Scenario 2: Backing up data to the cloud**. The video dives into tools and services for migrating data to the cloud.

https://www.youtube.com/embed/A14EbSrZeFM?start=1456&end=1585

The discussion jumps tp **Scenario 4: Building a data lake**, where scenario is divided into sub-scenario 4a which covers building a new data lake and sub-scenario 4b which discusses migrating to an existing data lake. This section focuses on object storage and the different options available through S3.

https://www.youtube.com/embed/A14EbSrZeFM?start=1592&end=2280

The video returns to **Scenario 3: Hybrid - using cloud storage with on-premises applications**. This scenario covers a range of issues including using on-premise applications with data stored in the cloud, on-premise object storage, and even replacing a physical tape library. The video describes in-depth solutions to hybrid storage scenarios.

https://www.youtube.com/embed/A14EbSrZeFM?start=2280&end=3120

The video addresses the complexity of storage, touching upon the criteria discussed earlier. AWS provides tools to assist you when deciding which solution to implement.

## Do You Want to Know More?

AWS offers courses on storage through AWS Skill Builder. Start with [AWS Storage Services - Portfolio Introduction](https://explore.skillbuilder.aws/learn/course/external/view/elearning/16649/aws-storage-services-portfolio-introduction?sc_channel=el&sc_campaign=post&sc_content=practicalcloudguide&sc_geo=mult&sc_country=global&sc_outcome=acq&sc_publisher=amazon_media&sc_category=mult&sc_medium=body), then progess to any of the cloud storage options.

* [AWS Block Storage Services Getting Started](https://explore.skillbuilder.aws/learn/course/external/view/elearning/16650/aws-block-storage-services-getting-started?sc_channel=el&sc_campaign=post&sc_content=practicalcloudguide&sc_geo=mult&sc_country=global&sc_outcome=acq&sc_publisher=amazon_media&sc_category=mult&sc_medium=body)
* [AWS Object Storage Services Getting Started](https://explore.skillbuilder.aws/learn/course/external/view/elearning/16651/aws-object-storage-services-getting-started?sc_channel=el&sc_campaign=post&sc_content=practicalcloudguide&sc_geo=mult&sc_country=global&sc_outcome=acq&sc_publisher=amazon_media&sc_category=mult&sc_medium=body)
* [AWS File Storage Services Getting Started](https://explore.skillbuilder.aws/learn/course/external/view/elearning/16662/aws-file-storage-services-getting-started?sc_channel=el&sc_campaign=post&sc_content=practicalcloudguide&sc_geo=mult&sc_country=global&sc_outcome=acq&sc_publisher=amazon_media&sc_category=mult&sc_medium=body)

With the fundamentals under your belt. Dive into the topics discussed in the video.

* [AWS Hybrid Storage Services Getting Started](https://explore.skillbuilder.aws/learn/course/external/view/elearning/16661/aws-hybrid-storage-services-getting-started?sc_channel=el&sc_campaign=post&sc_content=practicalcloudguide&sc_geo=mult&sc_country=global&sc_outcome=acq&sc_publisher=amazon_media&sc_category=mult&sc_medium=body)
* [AWS Edge Storage, Data Transfer, and File Transfer Services Getting Started](https://explore.skillbuilder.aws/learn/course/external/view/elearning/16669/aws-edge-storage-data-transfer-and-file-transfer-services-getting-started?sc_channel=el&sc_campaign=post&sc_content=practicalcloudguide&sc_geo=mult&sc_country=global&sc_outcome=acq&sc_publisher=amazon_media&sc_category=mult&sc_medium=body)
* [AWS Storage Data Protection Services Getting Started](https://explore.skillbuilder.aws/learn/course/external/view/elearning/16668/aws-storage-data-protection-services-getting-started?sc_channel=el&sc_campaign=post&sc_content=practicalcloudguide&sc_geo=mult&sc_country=global&sc_outcome=acq&sc_publisher=amazon_media&sc_category=mult&sc_medium=body)

These resources will help you choose the best storage solutions based on your organization’s needs.
