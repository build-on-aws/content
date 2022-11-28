---
title: "Data 101: Data Classification & Storage"
description: "Understanding data classification by looking at structured, semi-structured, and unstructured data."

tags:
  - data-classification
  - data-storage
  - structured-data
  - unstructured-data
  - databases
  - data-warehouses
  - data-lakes
  - foundational
  - aws
authorGithubAlias: aremutem
authorName: Temi Aremu & Yusra Al-Sharafi
date: 2022-10-31
---


The world is drowning in data. Every year, we generate more data than the year before. But what are we doing with all of those facts and figures? When properly collected, organized, stored, and analyzed, we can use data to work smarter, not harder, saving time, energy, and money across the business. In this post, we walk you through the fundamentals of data classification and data storage to help you start managing your data effectively. In the first section, we explain the different types of data and look at some real-world use cases. After that, we’ll look at what happens after you’ve identified the data you want to store and dive deeper into the various data storage options and how they relate to data analytics.

## Part 1: Classifying Data

Before getting into the weeds of classifying data, let’s start at the beginning— what is data?

Simply put, data is a collection of facts. Observations, descriptions, and numbers are all data. All the facts, observations, and statistics that can be digitally stored can be termed as data. Data can be used anywhere, which is why more and more businesses are trying to harness its power.

When we start to classify all of this date, we typically group it into three main types: structured, unstructured, and semi-structured data. A social media application, for example, will collect data about its users; the users will post and stream multimedia data; and in the backend, the application might have some sort of monitoring system that collects and analyzes information about its servers. User data will likely be structured, the data that’s posted and streamed by the users will be unstructured, and data monitored by the servers will be semi-structured. In the next section, we explain what all of this means.


### Structured, Unstructured, and Semi-Structured Data

Structured data is data that has been organized in some manner. It has a defined model, structure, or format. Think data within a spreadsheet, or within a table in a database. Before loading structured data, the data has to be standardized in how its elements relate to one another, typically in tables that have rows and columns. If you have used a spreadsheet before, you’ve worked with structured data.

Let’s talk about unstructured data. As the name suggests, unstructured data exists with no pre-defined format or model and it comes in a diverse set of forms. Unlike structured data, unstructured data has no standardization in how the data elements relate to one another. It represents information that has been stored in its absolute raw form. This makes unstructured data difficult to process right off the bat — however, it also gives unstructured data great flexibility to take in data from various formats. Some examples of where we would see unstructured data is data from social media, conversation transcripts, images, and videos.

Data that is not highly structured, but still has metadata (or data about the data) in place to describe it is called semi-structured data. Semi-structured data is data that is loosely organized. Typically, semi-structured data groups together elements with similar entities but can accommodate unstructured data as well. Take, for example, your typical email. Emails have some structure to them—the subject line and address line—but they also have a free form piece— the message—that does not conform to a particular structure. If you’re looking for more examples, graph databases and documents with key-value attributes are also good examples of semi-structured data.


### Tools

There are many tools and technologies that help us utilize data within these three categories. For example, we use Relational Database Management Systems (RDBMS), Online Analytical Processing (OLAP), and Online Transactional Processing (OLTP) to work with structured data. For unstructured data, we’ll organize and store it using NoSQL databases and AI-driven tools. And we rely on delimited files (CSV, TSV), HTML, XML, and JSON to help us format and utilize semi-structured data.


### Real-world Examples

When you think of what structured data looks like, think of data that could fit nicely in a spreadsheet. Data such as dates, phone numbers, names, and email addresses can all be part of a structured dataset. A contact list on your phone is an example of a structured data set; another example is a list of all orders made on an e-commerce website. All the data elements here have a pre-defined data model and are able to relate to one another.

Data sources like security camera footage, voice recording systems, conversation transcripts, or IoT sensors produce large amounts of unstructured data. This data does not have a true schema associated with it. Let’s consider text analytics as an example — you can use natural language processing to determine trends and patterns from an unstructured data set like conversation transcripts.

As for semi-structured data, server logs that have some standardized descriptive elements, or tweets that are organized by hashtags, are all examples of semi-structured data. If we want to classify images for processing, those images need metadata associated with them to classify and describe them, otherwise the images would be considered unstructured data elements — here, this would demonstrate another example of semi-structured data.

If these sound familiar to you and you’re wondering if it’s possible to store structured, semi-structured, or unstructured data side-by-side — the good news is that it is possible! This is where data lakes come in handy. You can store your structured data alongside your unstructured data to prepare them for processing from there.

So, which category of data do you think is generated the most in the world around us? If you said unstructured data, then you are correct! The overwhelming majority of data that is generated today is unstructured data!

Next, we’ll talk about the various forms of data storage and how they differ to help you choose the best storage for your needs.


## Part 2: Data Storage

To make informed business decisions, you need data. Your organization’s ability to gather data from disparate sources and secure meaningful insights from it can help drive business value. To lay the groundwork for a successful data strategy, you start by determining how your data will be stored, analyzed, and queried. Here, we’ll talk about different storage options, the differences between them, and how they work. We’ll also cover which option to choose based on your data strategy, infrastructure, and goals.


### Databases

A database is a systematic collection of related information, or data stored electronically in a way that’s easily accessed, retrieved, managed and updated. Databases help to facilitate the storage, retrieval, modification, and deletion of data. They typically collect information on people, places, or things. There are different types of purpose-built databases, typically chosen to support diverse data models based on the organizational approach that has been chosen. These could include relational, key-value, document, in-memory, graph, time series, wide column, and ledger databases. It’s important for companies to define their data strategy that aligns with their business. The decision about which database to use is a design/modelling decision as well. It can be as easy as evaluating your transactional data requirements and using that as a framework for choosing the right database. Databases can be used for a variety of use cases like banking transactions, session management, fraud detection, high-traffic web applications, e-commerce systems and so on. For example, social media platforms use document and graph databases to store user information such as names, email addresses and user behaviour. The data is then used to recommend content to users and improve the users experience. SQL databases are perfectly suited for storing structured data while NoSQL databases are best for working with unstructured data and semi-structured data.

Well, businesses rely on databases and the data collected to make informed decisions which could be crucial to profitability. Databases also help organizations provide a tailored set of products and services to customers, improving their experiences and augmenting retention. For example, organizations use their databases to improve business processes by collecting data such as sales, order processing and customer service. Businesses analyze that data to improve these processes, expand their business and grow revenue. Another instance is to secure personal health information: healthcare providers use databases to securely store personal health data to improve patient care.
When we think about selecting the right database for our applications, it is mainly choosing between two types of data processing systems: online analytical processing (OLAP) and online transaction processing (OLTP). The main difference between the two is OLAP is used to gain valuable insights while OLTP is purely operational.

Online analytical processing (OLAP) is typically used for performing analysis on large-scale datasets at high speeds while online transaction processing (OLTP) captures and maintains transaction data in a database. Choosing the right system for your application, mainly depends on your objectives. OLAP can help unlock value from large-scale datasets. Meanwhile, in a situation where you need to manage daily transactions ? Here, you can use OLTP to help manage process large numbers of transactions per second.


###  Data Warehouses

A data warehouse is a central repository of information that can be analyzed to make more informed decisions. Data can flow into a data warehouse from transactional systems, relational, and other sources, typically on a regular cadence. A data warehouse centralizes and consolidates large amounts of data from multiple sources. Because of these capabilities, a data warehouse can be considered an organization’s “single source of truth. Structured data from multiple sources are often stored in data warehouses.

A data warehouse may contain multiple databases. Within each database, data is organized into tables and columns. Within each column, you can define a description of the data, such as integer, data field, or string. Tables can be organized inside of schemas, which you can think of as folders. When data is ingested, it is stored in various tables described by the schema. Query tools use the schema to determine which data tables to access and analyze.

Some benefits of using a data warehouse include: Informed decision making, consolidated data from many sources, historical data analysis, data quality, consistency, and accuracy and separation of analytics processing from transactional databases, which improves performance of both systems.


### Data Lakes

A data lake stores structured, semi-structured and unstructured data, supporting the ability to store raw data from all sources without the need to process or transform it at that time at any scale.  Typically, the primary purpose of a data lake is to analyze the data to gain insights. By having all your data consolidated in one location, you’re able to perform analytics like data transformations and machine learning over data sources like log files, data from click streams and social media stored in the data lake. Another benefit of storing data in a data lake is the ability to store data in a variety of formats including JSON, ORC, and Parquet. The ability to harness more data, from multiple sources, in less time, and empowering users from multiple lines of business to collaborate and analyze data in different ways leads to better, faster decision making. Examples of where data lakes can add value include: aiding customer interactions by helping combine data to empower the business, increasing operational efficiencies that in turn help reduce operational costs and increase quality.

## Putting it all Together

Conventionally, businesses use a combination of a database, a data lake, and a data warehouse to store and analyze data for different use cases. Following one or more common patterns for dealing with data throughout your database, data lake, and data warehouse is helpful as the volume and diversity of data grows:

For instance you can either: Land data in a database or data lake, prepare the data, move selected data into a data warehouse, then perform reporting or land data in a data warehouse, analyze the data, then share data to use with other analytics and machine learning services.

A data warehouse is specially designed for data analytics, which involves reading large amounts of data to understand relationships and trends across the data while a database is used to capture and store data, such as recording details of a transaction.Unlike a data warehouse, a data lake is a centralized repository for all data, including structured, semi-structured, and unstructured. Another way to think about it is that data lakes are schema-less and more flexible to store relational data from business applications as well as non-relational logs from servers, and places like social media. You don't need to know the structure of the data before you can store it. By contrast, data warehouses rely on a schema and only accept relational data where you know the schema or structure of the data beforehand, and would need to update the schema to allow storing a new data field.


## Conclusion

We now know the different characteristics of structured, unstructured, and semi-structured data. We are now able to identify the classification of data when we see it. We have also seen in this post how a database, data lake, and data warehouse work towards providing different ways of efficiently managing your data and the result is an organized environment that can provide organizations with processed data to spur effective decision-making processes.

By understanding these differences, we hope you now have a bit more insight and this helps you to understand data classification and select the most effective data storage solution that fits your data needs and use cases.

To learn more about data analytics on AWS, check out the [Analytics on AWS](https://aws.amazon.com/big-data/datalakes-and-analytics/?nc=sn&loc=0) page that covers all-things-data on AWS. Stay updated with all the releases from [BuildOn AWS](https://aws.amazon.com/developer/learning/buildon-aws-live/).
