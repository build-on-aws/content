---

title: How to Store Data in the Cloud
description: An introductory article on the different types of cloud storage and their application
tags:
  - cloud storage
  - foundational
authorGithubAlias: spara
authorName: Sophia Parafina
date: 2022-09-26
---

Whether you're building a website or a cloud application or backing up data, you need storage that is accessible and scalable. There are three main types of cloud storage: 1. block storage, 2. object storage, and 3. file storage. Selecting the right type of storage will depend on what type of data you have and how you plan to access it.  

## 1. Block storage

Block storage stores data in fixed-size pieces of storage called blocks. A collection of blocks forms a volume that can be treated as a unit of storage, such as a hard drive. 

When writing data, block storage splits files across blocks with a unique identifier. To retrieve data, the storage server uses the unique ID to find the blocks with the data and returns the parts of the file. In practice, this process is transparent to us because a file system is used to manage blocks. The file system implements a lookup table of unique IDs stored in blocks that manage the efficient storage of data.

Think of blocks as low-level components that manage storing data efficiently. Operating systems implement file systems to enable us to work with data as files and directories.

### How is it used?

Block storage provides fine-grained control over how data is stored. A major advantage of block storage is the ability to optimize how data is distributed across blocks. Block storage can make small and frequent changes to a file without rewriting the file. This enables fast reads and writes for workloads that must be performant, such as transactional workloads or database queries.

By choosing blocks carefully, you can fine-tune and optimize your storage to be as fast as possible. This makes it popular for any workloads that are particularly performance sensitive. The key characteristics of block storage are high IOPS (input/output operations per second) and low latency.

Cloud-based compute resources, such as virtual machines, can attach block storage as disk volumes. Block storage can also be used to boot operating systems for VMs and cloud compute. Cloud compute resources can add block storage without downtime. Block storage is durable and can be moved from its current server by attaching it to another server.

Block storage offers the following features:

- optimized storage for workloads that require high data throughput and low latency
- built for small and frequent changes to data without rewriting a file
- can be locally attached to cloud compute and added as needed without a performance penalty
- durable and can be moved between cloud compute resources 

## 2. Object storage

Object storage is designed for holding massive volumes of data by distributing across multiple nodes, or buckets. Objects are made up of data, metadata, and a unique object ID. Object IDs look like file paths, but differ from hierarchical file systems by storing object IDs in a flat, non-hierarchical address space that scales horizontally.      

Object storage is durable because it stores data redundantly across nodes. Data is stored according to rules that determine which node to use based on the object ID. Nodes use [block storage](#block-storage) and data is distributed across nodes to keep node size balanced, which prevents scaling issues. When nodes are filled, the object store adds new nodes to store more data. Alternatively, when objects are deleted, nodes are removed. Object stores are elastic because they can grow or shrink as needed.

To retrieve an object, an HTTP request is sent to the object store's REST API, which retrieves the data from the storage nodes using a lookup table of object IDs. The lookup tables are also stored in nodes.

Objects can't be changed, but a new object can be created from a current object with the same object ID. Metadata tracks the version of these objects. In addition to versions, metadata can track the owner of the object and when it was created, making tracking, indexing, and concurrent writes possible.   

### How is it used?

Object storage is built to store petabytes of data that don't change often and have associated metadata. Object storage is ideal for WORM (write once, read many) data, such as backups, log files, data lakes, video, and imagery. In addition, object storage can efficiently hold large data sets for machine learning and data collected by IoT devices.

In addition to scalability, object storage delivers low latency performance. Because object storage uses a flat address space to index data, workloads can retrieve data faster than hierarchical file systems.

In addition to efficiently scaling, rich metadata associated with an object allows for better analytics and versioning, which lets multiple users concurrently work on a file.

## 3. File storage

In the previous section, we discussed how file storage is the way data is managed on block storage. File storage is hierarchical and mirrors how we used to store information physically with paper files and folders. Every file has a path to make it findable in the hierarchy, and files can be logically grouped in folders or directories.

Files can have fixed, system-defined metadata, such permissions to read, write, or execute the file; a timestamp of when the file was last written; and the type and size of the file. File storage is useful for many types of workloads, but the ability for multiple services and people to read the same file across a network is one of its main advantages. However, file storage prevents simultaneous changes to a file among users. However, file storage prevents users from making simultaneous changes to a file by allowing only one person to write to a file at a time.

The difference between file storage and block storage is that maintaining a file hierarchy doesn't scale when there are thousands of users and millions of files. The operating system must traverse the file system tree to locate files instead of reading through a flat lookup table of unique identifiers and manage locking to prevent concurrent writes that may corrupt the file. As a file system adds more users and stores more files, performance degrades.

### How is it used?

Although file storage doesn't scale like object or locally attached block storage, it supports many types of workloads where scaling or throughput are not requirements. File storage enables sharing datasets, videos, and documents among many users. File storage is user friendly; it implements data management in a way that is familiar to most computer users.

## Takeaways

Object storage addresses the need for storing petabytes of write-once, read-many data, such as photos, backups, log files, IoT data, and machine learning datasets. It also offers versioning, low latency, and rich metadata for analytics.

Block storage is ideal for transactional workloads where low latency for read and write is required, such as a database. It can attach locally to virtual machines or cloud compute resource, and provides fine-grained control over blocks for optimized read and write throughput.

File storage is appropriate for many uses, but particularly for file sharing across resources. Its hierarchical design and resemblance to a traditional filing system make it accessible to people across an organization.

There are many types of databases such as relational databases (RDMS), document databases, key-value pair databases, data warehouses, and data lakes. The following [article](https://blog.buildon.aws/posts/which-data-storage-option-do-i-choose) examines the type of storage appropriate for these databases.