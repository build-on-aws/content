---
title: "Choosing your API strategy: GraphQL vs REST"
description: By learning some basic concepts, you can manage your data more effectively throughout the various stages of lifecycle management
tags:
  - aws
  - explainer
  - rest
  - graphql
  - architecture
authorGithubAlias: guimathed
authorName: Matheus Guimaraes
date: 2022-12-17
---

Both REST and GraphQL are popular API architectural styles which can be used to build modern scalable backends. They do, however, take very different approaches. While REST models its recommendations around the capabilities of the HTTP protocol and prescribes using multiple APIs each representing a specific resource, GraphQL takes a bolder stance and defines its own mechanism with no strict reliance on HTTP and funneling all operations via a single API endpoint.

### Which one should I choose?

As usual, you must pick the right one for a given solution. You could also use both since, especially with microservice architecture, you may have complete freedom to implement whatever technical stack you prefer on a service by service basis. However, you should always take into account the level of familiarity and required learning curve since REST and GraphQL do work very differently.

Either one can help you create scalable and secure APIs, so perhaps the most useful approach when making a decision may be to understand the challenges that you should keep in mind when adopting them.

### Wasteful operations

One of the notable challenges of REST that became obvious over time as the volume of data exchanged grew exponentially is that there is not native way in the specification to help you make sure that your API calls are not wasting processing power or carrying too much data on the wire. For example, if you are only interested in retrieving a customer's first name, you would make a GET call to, say, a Customer Service, and then receive a full set of data about that customer from which you'd have to pick out the information you want.

Of course, you could implement your own filter algorithm and allow the calling client to pass in a value such as `filter=first_name`, which would tell the API to only return the data for the specified field as an example. However, this is extra custom code that you have to create, maintain, and keep in synch with any changes required by the frontend and not covered by the REST specification.

With GraphQL, this problem is solved natively since GraphQL queries allow application clients to specify the exact data they want to retrieve, which helps with keeping data operations lean and efficient.

### Sustainability

As an extension of the issue above, REST can be less sustainable than GraphQL since potentially there is a lot of extra processing power required even for simple data operations. GraphQL is designed to be data efficient by its very nature and allows you to perform fine-grained optimization of data operations, meaning that you could at any time improve the sustainability factor of even a simple request such as optimizing how a customer's first name is retrieved.

Because of this, GraphQL is well-positioned to keep up with the early conversations about sustainable coding and software systems as they continue to evolve. You can read more about it on this post: [Four Reasons Why GraphQL Is The Future](https://buildon.aws/posts/four-reasons-why-graphql-is-the-future/).

### Operational Overhead

A major advantage of REST is that it simply leverages existing standards to prescribe its implementation. Except for optional ancillary tools that help with API design, development and testing, the only requirement for a full REST implementation is making sure that both your clients and servers can communicate using HTTP which has been the mainstream ubiquitous protocol for decades.

With GraphQL, you do need to run an implementation of the GraphQL runtime on a server. The GraphQL server is responsible for hosting the single API entry point, resolving data requests, aggregating data and returning response payloads. The good news is that there are many off-the-shelf implementations that you can use without having to implement, host or maintain your own such as [AWS AppSync](https://docs.aws.amazon.com/appsync/latest/devguide/what-is-appsync.html).

### Flexibility

Many teams still struggle with how to create a formal contract between the backend and frontend so teams can work in parallel without affecting each other or resulting in wasted effort. This is because with REST the frontend and backend hold a silent contract between them: the frontend sends a request via an API call and hopes that the data sent is in the right format, contains the right attributes and has the right values needed for the API call to succeed. There is no automatic or formal way within the REST specification of making sure that the frontend is always synched with any changes in those requirements. Therefore, the backend team has to ensure backwards compatibility as they evolve the APIs and more fields are added or changed. They can do this by applying versioning techniques or simply manually coordinating changes with the frontend teams and making sure that all frontend and API changes are released at the same time which is far from ideal.

Many teams fill that gap by using the OpenAPI specification and some use what is known contract-driven development where both the frontend and backend agree on a specific data contract so they can both work in parallel to implement the necessary parts to fulfill the agreement. That kind of approach is how GraphQL works natively, except that instead of using OpenAPI it uses the GraphQL schema language which you must use to create, modify and deploy your GraphQL APIs and from which queries and mutations are derived. That means that all API changes are centralized and all systems are kept in synch since they are all bound by the same API contract.

### Comparison Summary

|  | REST | GraphQL |
|---|---|---|
| **Usage** | A RESTful backend typically consists of many different API endpoints, each representing a resource such as a customer or an order. | GraphQL exposes a single API endpoint to where all queries and mutations are sent and the GraphQL server takes care of locating and calling any backend services needed to complete the request. | |
| **Caching** | Caching is native to the REST specification and, in fact, it's encouraged and easily implemented by simply leveraging the capabilities of HTTP caching. | Without unique URLs that can be used to identify data requests for specific resources it becomes difficult to compare them and determine if it's safe to return saved data from cache. There are a few techniques such as caching based on an object's id if one is available, such as customer id, for example, but there is no native support for caching. |
| **Design** | REST doesn't prescribe a method for designing your APIs or keeping changes in sync as they evolve and more fields are added or edited to their request and response payloads. You can use the OpenAPI schema to fill this gap and create strongly-typed representations of your APIs which may also be used for deployments to ensure a more contract-driven development process. | Strict contracts are a native mechanism in GraphQL. You use the GraphQL Schema language to create, update, deploy, query and manipulate data in strongly-typed APIs. |
| **Efficiency** | REST prescribes no mechanisms for ensuring that your data operations process and return only as much data as needed by the calling clients. | Application clients are given full control over what data they'd like to fetch making read operations very efficient and flexible. |
| **Sustainability** | Due to the potential volume of wasted processing that REST can lead to, it may not be the best candidate for a solution focused on being as sustainable as possible unless you implement custom data filters. | Sustainability can be optimized at any time by adjusting the amount of data requested from the clients without having to make any changes to the server. |
| **Maturity** | REST has been the mainstream API architectural style for many decades now enjoying a rich ecosystem of documentation, tools, services and libraries that integrate seamlessly or help you with REST implementation. | While not as mature, adoption continues to grow fast and many popular tools and libraries used for API design, development and testing have already added support for GraphQL. |
| **Versioning** | It's important to have an API versioning strategy to maintain backwards compatibility with application clients as the APIs evolve and add or delete fields from the request or response payload data. | Application clients have full control of the data they request and all read and write operations are based on a common strongly-typed API definition which serves as a common contract between the frontend and the backend diminishing or completely invalidating the need to API versioning. |