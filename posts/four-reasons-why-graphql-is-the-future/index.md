---
layout: blog.11ty.js
title: Four Reasons Why GraphQL Is The Future
description: The cracks of REST API design are starting to show in an age where everyone needs fast and cheap while being kind to the planet. GraphQL offers a new approach and here are four reasons why it is primed to become the norm not the exception.
tags:
  - apis
  - rest-apis
  - graphql
  - microservices
authorGithubAlias: guimathed
authorName: Matheus Guimaraes
date: 2022-08-26
---

REST architecture has revolutionized the industry and powered much of the innovation of the last decades including microservice architecture which rose to prominence and rapidly became the new de-facto modern Service-Oriented Architecture (SOA) pattern. 

In fact, distributed systems and SOA grew to such degree that a typical modern application has a dependency on tens, hundreds or even thousands of microservices which are composed together to deliver rich user experiences. This leads to a few frontend and backend challenges.

Application frontends have to find clever ways of coping with the volume of configuration needed to keep track of all the services that they need to call and their specific request requirements. In addition, frontend developers have to learn about the bespoke data filtering capabilities built for each service or the lack thereof, so they can avoid wasteful response payloads that contain way more data than is needed. 

Backend developers, in turn, must explicitly code and maintain these data filtering capabilities in the microservices as well address the complexities of API versioning and discoverability. 

These challenges coupled with a desire to be able to represent a whole network of interlinked data within one API, were some of the reasons why, in 2012, Facebook created GraphQL. It remained as an internal project until 2015 when it was made public before being handed over in 2018 to the GraphQL Foundation hosted by the non-profit Linux Foundation.

This rapid progression that GraphQL has experienced, from conception to general availabilty to standardized technology governed by a reputable consortium, is testament to its disruptive potential. GraphQL has been put to the test by hyper-scale digital products such as Facebook, Instagram, Twitter, The New York Times and so many others which serve as great evidence to its inherent power and flexibilty. 

There are a great many considerations when talking about API-driven design and microservice architecture, but here are four mains reasons why GraphQL is well aligned to be the next big thing in that space.

## Efficiency

There are many frontend and backend patterns which attempt to solve the problem of handling the sheer number of services that a modern application must integrate with. One of the most popular ones is the Aggregator pattern. Effectively, you create a microservice that encapsulates the logic of calling multiple services functioning as a single endpoint and returning a single combined payload.  This keeps configuration as lean as possible by reducing the number of services that the calling application needs to know about while allowing you to mix and match functionality from various microservices and combine their results to return different data shapes.

What if, though, we upgraded the Aggregator pattern and made it a first-class citizen of our API design? What if our entire private web of services was funneled through a really smart aggregator which not only served as the single endpoint to all of our applications, but could automatically make calls on our behalf behind the scenes to fetch the data that we need? That is exactly what GraphQL does!

With GraphQL, your API is served from a single endpoint and you map the location of your data elements with code through what is called a resolver, which is effectively an implementation of another very popular pattern: the Adapter. By doing this, GraphQL allows you keep full control while keeping everything very flexible and loosely coupled. In addition, it allows client applications to keep things simple by minimizing configuration and allowing them to simply query or change data at will without having to worry about the backend implementation details.

In a way, it’s like applying Inversion of Control for data availability. You register the data that you want to make available to your applications using the GraphQL schema, you then tell GraphQL how to resolve it, and then you make it available to your users via the single endpoint which they can use to ask for whatever they want instead of making explicit calls to various individual services. 

It's brilliant! This relatively simple approach knocks quite a few birds in one go: it solves current discoverability challenges, it maintains a clean separation between the frontend and backend allowing them to be optmized and changed with a high degree of independence from each other, and, finally, it simplifies and reduces the amount of configuration data and logic for consumers.

## Economy

While the single endpoint façade provided by the GraphQL is quite a powerful concept, the thing that GraphQL is better known for, and one of the main drivers for adoption, is the fact that you only get the data that you ask for; no more, no less. This is because one of the main challenges faced by frontend developers today is not only knowing what web service to call to fetch the right data, but also finding ways to fetch the right amount of data. Unless an API offers data filtering or projection capabilities, the developer is forced to fetch a big chunk of useless information only to discard most of it. 

A classic example would be a greeting widget which displays a hello message to the customer. Unless the developers of the Customer microservice have added logic that allows you to return the customer's name and nothing else, your web app may be forced to fetch the full customer profile only to cherry pick the information from the response payload so it may display the simple greeting message.

One of the most sung about advantages of GraphQL is that, by design, you can fetch exactly the data that you need, without any knowledge about the backend. There is no need to worry about slowing the system down due to over-fetching, or even under-fetching, which also affects performance by forcing the front-end to make multiple API calls to get all the data required. With GraphQL, you explicitly specify the data elements you want, allowing you to “right-size” your query, as I like to call it.

It is very common these days for infrastructure engineers to think about right-sizing their virtual server instances to optimize cost performance, and the same thinking applies here. As an API designer, you want to make sure that your datasets are not just reachable, but that they’re also not wasteful. Reducing the data exchanged by APIs doesn’t only have an impact on the performance, but also will likely reduce your costs especially if you’re implementing pay-per-usage serverless architecture, which typically charges for data served.

There is one caveat here about performance, however. While having less data will indeed reduce download times when fetching data from the GraphQL service, GraphQL itself won’t do anything to improve your performance directly. That is because GraphQL is ultimately, first and foremost, an orchestrator. It is up to you to implement resolvers that instruct the GraphQL server where to fetch the data elements from and look after that integration. That means that, much like any other orchestrator, GraphQL is only as fast as your slowest integration. If you have a performance bottleneck in your Customer Service, for example, and you configure it as the resolver to fetch the customer name for your greeting widget as per the example above, then GraphQL will obediently request that information from that service and be as stuck as anything else that calls it directly unless you solve the problem.

## Sustainability

A surprising byproduct of the efficiency and economy gained by using GraphQL is a higher sustainability factor for your workload. Sustainable coding is very much a niche topic at this point of time; however, the conversation is starting to spread fast as developers wrap their heads around what it means.

It’s quite simple in principle really. Basically, the less you process, the less energy you consume, the more sustainable your application is. There are some ongoing benchmarks which are pitting programming languages against each other to determine which are more sustainable based on how much CPU and memory they use to run equivalent operations. Some language designers are starting to take sustainable coding as a consideration for future releases and it won’t be long until more contributions are made to open-source projects to increase their sustainability factor as the community becomes more aware of the subject.

The good news is that while we wait for programming languages to sort themselves out, we can already start facilitating sustainable API design by adopting GraphQL since it empowers the API consumers to make economical choices and limit the amount of processing done on the backend simply by requesting only the data elements needed for any operation. Backend developers can then take care of optimizing the resolvers and services behind the scenes to work towards maximum sustainability too. Everyone can do their part.

## Real-time User Experiences

GraphQL doesn’t just solve today’s challenges, though. It also looks into the future and natively supports two-way long-lasting conversations between client and server in the form of subscriptions. A GraphQL subscription is an abstraction of WebSockets making it really easy to leverage its power to deliver real-time experiences such as a web-based dashboard, for example, that gets automatically updated as data changes on the server side. 

Application users are becoming so accustomed to real-time experiences that it is fast becoming the norm. In this day and age, even non-tech-savvy people complain about loading times and spinners. People are now used to immediate feedback and the trend is only going to intensify over the years which places GraphQL in a leading position for future proofing your APIs with that kind of capability built in.

## Conclusion

Much like any of its ancestors, GraphQL will continue to mature and evolve as the community embraces it. It has already gone from first public release in 2015 to mainstream adoption in hyper-scale production systems such as PayPal, GitHub, Instagram and many others in a couple of years. It only keeps on growing as the community learns more about it and more businesses keep proving its potential. There is great appetite for reducing data waste and finding sustainable options for running systems without compromising on features and GraphQL fits perfectly as a core piece of this new wave of application design.
