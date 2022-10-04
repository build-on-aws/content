
# Database Essentials

TBD Intro

## **Sections:**

- [What are the different types of databases?](#what-are-the-differernt-types-of-databases)
- [What kind of applications use a database?](#what-kind-of-applications-use-a-database)
- [What are the benefits of using a database?](#what-are-the-benefits-of-using-a-database)
- [What are the security concerns with a database?](#what-are-the-security-concerns-with-a-database)
- [What are transactions?](#what-are-transactions)
- [What about high availability and fault tolerance?](#what-about-high-availability-and-fault-tolerance)
- [What are the deployment options for database servers?](#what-are-the-deployment-options-for-database-servers)

## **What are the different types of databases?**

Databases are generally categorized by one of three features:

1. How it stores relationships
2. How you query data
3. How it promises consistency for reads and writes

Some examples of variations in relationship storage:

1. Graph Database
2. Relational Database
3. Object Database
4. Key/Value Store

Some examples of variations in the way you query data:

1. SQL queries
2. NoSQL or Document queries
3. Graph queries

Some examples of variations in consistency guarantees:

1. Sequentially consistent - all readers see the data in the same order, even if they are reading stale data
2. Strict consistency - all readers see the same data at any point in time.
3. Atomic consistency - all readers see data from writes that have completed at the time of the read
4. Causal consistency - all readers see data from related writes in the same order.
5. Eventual consistency - all readers will eventually see the same data, which is determined by the last write

## **What are the benefits of using a database?**

Databases allow you to store information centrally in a manner that facilitates retrieval of the information. Using a database allows developers to rely on the database server for management tasks like backups, and operational tasks like indexing for faster data retrieval.

## **What are the security concerns with a database?**

Every database has a different security model, but all of them have the same security risk. You need to ensure that your database is protected from unauthorized access by using physical, logical, and application level barriers. 

## **What are transactions?**

A transaction is a group of reads and writes to a database that is guaranteed to succeed or fail as a whole. If any step in the transaction fails, the whole transaction fails. Consider a classical example from the banking world. A customer transfers money from a source account to a target account. The process might have these steps:

1. Check balance in source account
2. Add money to target account
3. Subtract money from source account

If the process fails after step two, the customer will appear to have extra money in the target account because the final step wasn't completed. A transaction ensures that all three steps have to complete for the transaction to be successful. Any failure in the process triggers a "roll-back" of previous steps.

## **What about high availability and fault tolerance?**

The [CAP Theorem](https://en.wikipedia.org/wiki/CAP_theorem) states that there are three guarantees that a database can offer: Consistency, Availability, and Partition Tolerance. When your database is running on a single server, you have only _Consistency_. In order to get _Availability_, databases are often replicated to multiple instances. When you have multiple instances cooperating to agree on the current state of your data, you have a risk of failure due to network failure, also known as a _Partition_.

Every database is designed to provide one or more of the guarantees of the CAP Theorem. You should choose your database based on which guarantee is most important for your use case. If you value _Availability_ over _Consistency_, you can choose an eventually consistent database. If accuracy is more important, you'll want to choose a database with strong consistency. Some databases let you choose at runtime which level of consistency you want.

## **What are the deployment options for database servers?**

Your deployment options in the cloud range from self managed to fully managed. Which option you choose should depend on your ability to meet your operational needs within your budgetary limits. Most of the time it is more cost-effective to use a managed database service unless you already have experienced database and system administrators on your team.