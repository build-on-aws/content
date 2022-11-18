
# How Do Backend Architectures Work?

<table>
    <tr>
        <td>AWS Experience</td>
        <td>Begginner</td>
    </tr>
   <tr>
        <td>Time to complete</td>
        <td></td>
    </tr>
    <tr>
        <td>Requires</td>
        <td></td>
    </tr>
     <tr>
        <td>Services discussed</td>
        <td></td>
    </tr>
     <tr>
        <td></> Code</td>
        <td></td>
    </tr>
     <tr>
        <td>Last Updated</td>
        <td>Nov 15th 2022</td>
    </tr>
</table>

## Overview
In this guide, we will learn the basics of modern backend architecture by exploring a few of the technologies and architectures that power most applications today. We will look into the improvements gained by moving away from a traditional monolith and embracing API and event-driven distributed architecture to help realize the benefits of a modern application stack.

We will also learn how to integrate your client application's frontends with the backends and cover the basics of REST and GraphQL.


### Before starting this course, you should:
- have basic understanding of application development

### Sections
This topic is divided into the following sections which are listed in recommended order, but you can also jump to sections based on your experience. 
1. The evolution of backend architecture (outcome: Context of backends and how they evolved)
   1. introduction
   2. Keeping backend and frontend separate
2. What is an API?
   1. the "-ilities" of software architecture (outcome: why scalability matters)
   2. what is three-tier architecture?
3. Monolith vs. Distributed Architecture (outcome: distributed vs. monolithic architecture)
   1. introduction
   2. What is monolithic architecture?
   3. What is distributed architecture?
4. What is event-driven architecture? (outcome: event-driven architecture)
   1. introduction
   2. loosely-coupled microservices (outcome: why scalability matters)
   3. Asynchronous Communication
5. How to connect your frontend to your backend (outcome: connecting your front and backends)
   1. introduction
   2. Calling APIs
6. API Architectural Styles
   1. introduction (outcome: API-driven concepts of GET and POST)
   2. What is REST? (outcome: background on REST (theory)) (outcome: API-driven concepts of GET and POST) (outcome: API-driven concepts of GET and POST)
   3. What is GraphQL? (outcome: background on GraphQL (theory))


## The evolution of backend architectures: from monolith to distributed

### Introduction
In this section, you will learn about the evolution of backend architecture, understand what is meant by three-tier architecture and discover why mainstream software architecture has shifted from monolithic to a distributed architecture over the decades.

### Keeping backend and frontend separate
There was once a time when backend architecture consisted simply of a bunch of functions in your codebase that were triggered in response to a user's action. This changed dramatically over the years as we went from entering simple commands on a plain terminal in the 80s to using increasingly complex desktop graphical interfaces which required more code and more coordination of parts to process each action. 

Fast forward to today's digital era and you can expect even the least tech-savvy user to interact with a number of different devices and be fluent in typing, clicking, touching, swiping, drag and dropping, touch and holding, to a name but a few. Technology has embedded itself in the daily life of every modern human and we expect seamless experiences as we switch from one device to another.

The need to provide not only the same functionality, but also a continuous experience to users irrespective of the visual interface, commonly referred to as the user interface or UI, became the biggest driver to create a clear separation between the presentation layer, most commonly referred to as the frontend, and the application layer, known as the backend, which holds all your business logic and algorithms.

By fully disassociating these layers we afford ourselves the ability to create, upgrade or even experiment with different UIs and then bring them to life by hooking them up to our re-useable backend logic. For example, if your application allows users to upload files to your server, you could expose the same functionality via a drag-and-drop interface for desktop users or a simple button on a mobile app that allows them to pick from files stored on their phone. Either way, you'd only have to write the backend logic that processes the uploaded file once and then simply trigger it from these different interaction points. 

This level or re-usability became a key enabler to delivering and maintaining applications as users demanaded more of their software products and those became increasingly complex to develop. As such, architects looked for ways to capitalize on this approach and soon API-driven design became the norm for implementing re-usable backend code.

## What is an API?
At the beginning, the internet was all about creating new user experiences through fairly static experiences. However, over time, speed, stability and availability of networks improved allowing code to be executed realiably and fast across distant network boundaries. To enable this, we need a way for remote parts to communicate so they can trigger the execution and perhaps consume the output of these codebases which may be runninng from completely separate locations and on different machines. An Application Programming Interface (API) enables this communication between system parts by exposing a set of operations that can be called remotely by any one or any machines with access and then takes care of triggering the right piece of code to execute the desired action and return any relevant data, if any.

Much like a web site, an API is assigned a specific network address such as a URL that you can use to invoke it. APIs usually expose actions through these URLs such as, for example, "create a customer" or "delete an item" that your frontend or even other APIs can call to execute them. 

Besides enhancing the re-usability factor, breaking your backend architecture into multiple APIs allows you to look after your solution more easily and efficiently by addressing aspects such as availability, scalability and security for each API rather than have to deal with the complexity of the entire application at all times.

<a id="ilities"></a>
### The "-ilities" of software architecture

There are many aspects involved in delivering great features and exciting stable user experiences. A robust application must strive to achieve high standards across a number of architectural concerns. These are sometimes referred to as "-ilities", due to their wording in English and the fact that each word ends in "ility". Some examples are:
    - Availability: a highly-available application is one which experiences minimum or no downtime in the event of failure.
    - Scalability: this measures how much an application can cope with increased volumes of concurrent usage before it starts to fail
    - Security: a famous and self-explanatory one, this determines how secure your application is at any given point in time
    - Maintainability: this determines how easy or how difficult it is to maintain your application

Depending on the nature of the application, certain aspects will be more important than others, however, besides security, which must always be a top priority concern for obvious reasons, one of the most important ones that must be factored into modern application architecture is scalability. Without making sure that your application has sufficient levels of scale for your goals, your users will have slow and poor experiences which can lead to them abandoning your service or product. Equally, you should make sure that you are not wasting processing time and, perhaps even more importantly, money during times when your application may not be as busy. This can be a challenging puzzle to solve on your own and that is why so many applications are being built or migrating to serverless technology. Serverless allows you to run your applications without having to manage any infrastructure and it will grow and shrink the scalability required by your application based on usage. You can read more about how serverless can help you accelerate to high scalability standards as well as some of these other -ilities on this post: <a href="https://aws.amazon.com/blogs/compute/getting-started-with-serverless-for-developers-part-1/">Getting started with serverless for developers</a>.

All of these qualities are at the center of architectural decisions and many specifications, patterns and tools continue to be created to aid in achieving high standards across all these different "ilities". For a long time, the most accepted approach which tried to tackle many of these challenges was what is referred to as the three-tier architecture. While some of the concepts of three-tier architecture still stand, its implementation looks a bit different than it did a few years ago as the world adapted to the mainstream adoption of microservice architecture. 


### What is three-tier architecture?

The concept of a three-tier architecture is pretty simple. It states that an application should be split into three independent layers: presentation, application and data. 

<img src="/imgs/three-tier-architecture-diagram.jpeg"/>

Presentation refers to any UI that can be interacted with. This could be a web site, a mobile app, a kiosk, or even the feedback touch panels with the emoji faces that you see at some events and public facilities. This layer is concerned with layout, design and user experience only. Does the application look nice and on brand? Can the user achieve the most common tasks with as few mouse clicks as possible? These are typical concerns shared by the user interface and user experience designers as well as, traditionally, by the frontend developers.

The application layer refers to code that performs business logic and serves as the bridge between the presentation and the data layer. It can be triggered by the presentation layer to run algorithms or execute simple logic as the user interacts with visual elements and performs actions. For example, say a user clicks on the "Profile Details" button on a web site. This will trigger code that would call the the application layer which would receive the request, and then retrieve the information from the data layer before passing it back to the presentation layer for display.

The data layer is the most straightforward one. It is concerned only with the storage and retrieval of data. It allows the application layer to perform data operations without having to know anything about the actual underlying database hosting the data. The data layer takes care of setting up and managing database connections as well as using the specific syntax required by the database to implement any queries or storage requests that it receives. For example, the application layer may call the data layer to request a search for customers whose first names begin with the letter "M". The data layer would be responsible for composing a search query according to the syntax used by the database hosting customer data, clean and transform the results, if necessary, and then return the dataset to the application layer. 

Three-tier architecture could be summarized in three (indeed!) rules:
1- isolate the code for your presentation, business logic and data handling into their own silos
2- never allow the presentation layer to talk directly to the data layer, always go through the application layer
3- never allow the application layer to talk directly to the database, always go through the data layer

Three-tier architecture was accepted as the de-facto approach for a long time because it helped to address many of <a href="#ilities">"-ilities"</a> such as improving an application's availability, scalability and maintainability by making software engineering and maintenance more manageable while also isolating and spreading the burden of catering for large number of users a bit thinner across different layers.

The principles of three-tier architecture still apply today, however, the implementation looks a bit different. That is because traditionally software was built as a block and all three layers would be coded, built and released together as a unit resulting in what is called a monolith. However, as more people flocked to online channels, it became obvious that the monolithic approach would struggle to keep up with modern application requirements and support the ever-growing number of digital users. This allowed distributed architecture to finally make its way onto the spotlight and become the new default approach for building applications in the digital era.

## Monolith vs. Distributed Architecture

### Introduction
While the principles of distributed software architecture can be traced all the way back to the 1970s, it was largely disregarded for a long time in favor of the monolithic approach which was much easier to execute. It wasn't until around the late 90s when technology and tools finally became advanced enough to help offset the complexity of distributed systems allowing it to take off and culminating into what we know today as microservices which rapidly became the default standard for modern backend architecture. 

### What is Monolithic architecture?
A monolith is simply an application which is released as one big block. Typically that also means that all of the code is stored as one codebase which gets built together every time. 

The main advantage with this type of architecture is simplicity. You only ever need to maintain one place where you store all of your code. You also only need to configure one build and deploy only one application. This can seem ideal on the surface since one of the main goals of software architecture is indeed simplicity, but like anything in technology, it comes at a price.

Having only one application package to deploy certainly makes operations easier, but it also means that even a small change in the presentation, application or data layer of your three-tier architecture, such as, for example, a typo correction on your user interface, warrants replacing the whole application. As the codebase grows over time, this means that you not only end up with very wasteful and long build times, but also the release process will get progressively longer even for small changes. Worse yet, you risk de-stabilizng your application since you may unintentionally release unfinished changes that you are not aware of in other parts of the codebase.

The developer experience also suffers since developers must always retrieve changes for the whole application even when they're only working on discrete parts. They also must make sense of the ever-growing monolithic code which will become harder to navigate over time. Lastly, they will most likely have to deal with a lot of code conflicts depending on how many developers are working on the same codebase.

Many systems have been built as monoliths, and while most of those have started to be migrated to modern architecture standards, many still run those systems successfully due to various techniques, processes and tools that can help offset some of the problems described. However, even if the limited scalability of monoliths could be tolerated or is sufficient for an application to keep being maintained and running stable and healthy, the effort required to make this happen may invalidate the level of simplicity expected from implementing this type of architecture.


### What is Distributed architecture?

In distributed architecture, we break down our application into independent modules called services. They are self-contained and can be managed and deployed separately from each other. Each service functions as a black box fully encapsulating related business logic that is exposed to application clients as well as other services via APIs. 

This architectural style became popular in the late 90s when Service-Oriented Architecture, SOA, was proposed describing patterns that put APIs at the heart of application design with a focus on enabling as much re-usability of code as possible. The SOA specification was instrumental in challenging the status quo and driving the industry to move away from monoliths in favor of utilizing distributed patterns. 

Over the years, SOA practices matured and they eventually evolved into a streamlined architectural style known as microservice architecture which, currently, is the most popular approach to implementing backend architecture.

Microservice architecture centers around the idea that every service should be as independent as possible. The main distinctive factor between microservices and a monolithic system is that each service is independently deployed allowing them to be coded, built, released, patched, maintained and observed individually. This means that each microservice can have its own mini application stack including allowing them to be coded using completely different languages and having their own databases. For example, you may have a Customer microservice which is coded in Java and stores customer data in a MySQL database. However, you could also have a Basket service which is coded in Python and stores its data on Amazon DynamoDB, a cloud-native NoSQL database. The important thing is that both services would hide these details behind an API which is the single point of communication between them and the rest of the world. 

Microservices offset a lot of the challenges encountered with monoliths. Every service is small enough that they can be easily managed and the codebase would never get so large as to overwhelm developers or to cause build times to become too long. Moreover, because each service effectively runs on its own isolated process or even its own hardware, the impact of failure or even of a security breach is significantly reduced since they will only affect the discrete area of the service and not the whole application.

The main downside of microservices is the complexity resulting from the multiplicity of parts. As the system scales and more services are created to support new features and business functions, it can become difficult to maintain many separate modules. That is why the adoption of microservices is intrisically tied with the idea of devops and automation which are key to offseting this complexity. Teams are encouraged to spend time automating as many operations as possible including building code, provisioning environments and releasing the application to them, perfoming tests, self-healing, and many others. 

The other challenge with microservices is constantly making sure that they remain as loosely coupled as possible to maintain a high degree of independence and isolation as you create more services that are composed together to deliver full application features. One the primary concerns is making sure that those services can be integrated and communicate efficiently without actually depending on each other and that is exactly the problem solved by event-driven architecture and why it is very common to see it implemented alongside microservice architecture.


## What is Event-Driven Architecture?

### Introduction

Event-driven architecture is the practice of using asynchronous communication to allow distributed parts to communicate without introducing dependencies allowing them to remain highly independent from each other promoting high standards of isolation and scalability. This is why it is such a great fit to solve some of the challenges with microservice architecture as it allows efficient communication between services without compromising their level of independence and allowing them to reamin as loosely coupled as possible.

### Loosely-Coupled Microservices

Being loosely-coupled means that a module is able to interact with other parts of the system without directly depending on them. This concept applies to both code and architecture and there are many patterns and solutions that address different interdependency problems. 

When a dependency exists, the part or parts involved are said to be tightly coupled. For example, if an Order Service makes a direct request to a Customer Service to retrieve details about a customer and waits for the response before it can continue then the Order Service is said to be tightly-coupled to the Customer Service. This is a type of temporal coupling since the time that it takes for the Order Service to complete a request is dependant on to the performance, availability and scalability of the Customer Service.


### Asynchronous Communication

Thinking asynchronously can be a challenge since it goes against human instincts and much like our day-to-day tasks, we tend to devise solutions that depend on sequential steps. However, Modern applications have trained us to accept and even expect asynchronous flows more so a lot of operations that we think may need to be temporally coupled at first could in fact happen at different times without consequence to end users. 

Imagine a customer making a purchase through an online system. Do they really need to get an email about their order being completed right away or could you first simply complete the order, show that it's been successful on the UI and then allow for the email to be sent eventually at a later time? Having an email with the order summary is not essential to completing the order and, in most cases, users wouldn't mind receiving an email after a few minutes or longer. 

To achieve this, you could first process the order within an Order Service and show the response on your UI once it's completed. You would then simply raise an OrderCompleted event which would trigger an action on microservices that are subscribing to it. This could be, for example, an Email Service which, in its own time, can use the data sent in the OrderCompleted event to process the order summary and then send the email to the user.

This is an example of event-driven architecture. The Order Service mentioned above did not need to call the Email Service directly and wait for it. Microservices can raise and subscribe to events to exchange data and allow for asynchronous integration while remaining loosely-coupled from each other. 


## How to connect your frontend to your backend?

### Introduction
Modern applications can be very complex with most having a variety of visual elements tha trigger a variety of actions. For example, when browsing for flights, a simple click on the "Select Flight" button may do two things: add the flight to the basket for visualization and actually reserve a seat on it for a set period of time. Both actions would rely on calling APIs to perform the actual business logic and save any data records while the UI would simply be responsible for making the API calls and updating the user interface accordingly. That is how most modern frontend codebases are structured. They mostly contain visual elements which are hooked up to presentation logic while user actions such as button clicks, for example, trigger calls to APIs which return useful data which is used to update the visual interface. 

### Calling APIs

Modren applications isolate business logic into APIs which is why frontend developers need to understand how to call them and be familiar with concepts such as preparing a request, making an API call, consuming the response payload and extracting the relevant data which is needed to update the UI. Fortunately, the vast majority of frameworks, programming languages and sdks include built-in support for simplifying these tasks. However, you still need to understand how to configure those API calls such as specifying the API endpoint, choosing the correct HTTP verb and adding any required authentication.

An API endpoint is simply an unique URL that you can use to send data serving as the backend trigger to run some business logic. For example, I may have a Customer Service, which is exposed via the endpoint https://example.com/customer that I could call to perform various data operations such as adding or retrieving customers. If adding a customer, I would call that endpoint sending data such as the value for first and last name, whereas if I were retrieving a customer I would perhaps simply send the value of the customer id. 

However, in the example above, how would the service know when I am adding or retrieving a customer if I'm calling the same endpoint? The key is to use different HTTP verbs. Unless there is a need to specialize the transmission protocol, most APIs communicate using HTTP and require you to specifiy an HTTP verb when accessing an endpoint. The HTTP verb used determines the operation to be executed.

There are a handful of HTTP verbs, but the most commonly used ones are GET and POST. When retrieving data the industry standard dictates that you should always use GET. That means that if you want to retrieve a customer by id you would call the API endpoint from your frontend by specifying that the HTTP verb that you want to use is GET. On the other hand, POST is used when you want to change data, not just retrieve it, such as when adding a new customer to the database. There is also PUT that you can use to send updates to data that you know already exists in the system as opposed to creating new records. 

These HTTP verbs are very helpful for APIs to determine context. They simplify discovery since they don't create, for example, separate endpoints for adding and retrieving a customer, you can simply use the same one and pick a different HTTP verb. In fact, having only one endpoint represnting a specific resource such as a customer and exposing different data operations on this resource via HTTP verbs has been the default industry standard for decades now and this architectural style is known as REST.


## API Architectural Styles

### What is REST?

Until the early 2000s, the industry standard for creating scalable backends was what is known as Service-Oriented Architecture, or SOA, for short, which emphasized the practice of creating distributed services with a heavy focus on re-usability. Uunfortunately, while SOA doesn't specifically dictate how these services should communitcate it was intrinsically associate with SOAP (Simple Object Acces Protocol), an XML-based protocol with limited scalability due to it being very verbose and slow to parse. An alternative approach was proposed by Roy Fielding in 2000 which prescribed leveraging HTTP for API design and implementation which he called Representational State Transfer, or, REST.

A RESTful service is a web service which represents a given resource such as a customer and exposes operations via an HTTP-based API.

REST prescribes various conventions that serve to standardize the way APIs are designed and implemented. For example, it dictates a specific purpose for HTTP verbs stating that GET should always be used for read-only operations, POST for creating new resources, PUT for updating resources, DELETE to remove them, among a few others.

Another characteristic of REST is that all APIs should be stateless. That means that every call to a RESTful API must be fully independent and no aspects of that call should need to be remembered. This is very important for scalability since if you depend on database reads and writes every time you make an API call, the execution time would increase significantly which would limit the number of requests that your API could process and potentially lead to state or broken experiences for the end users. Every RESTful call is simply discarded once processed and there is no need to save or load data in order to contextualize the call. The full context should be self-contained in the HTTP request including the verb used, header values and the request payload, or, in other words, the data that you add to your request immediately following the HTTP headers. 

REST doesn't dictate how you should format your request or response payload data, however, currently, the industry standard is JSON, or Javascript Object Notation. In spite of the name, even though JSON does indeed come from Javascript, it has become an ubiquitous eletronic data exchange format which is used and understood by many different frameworks and programming languages. The main advantage of JSON is that it can be easily read by humans while also being efficiently parsed by machines so it's a great way to serialize data.

### What is GraphQL?

In 2015, Meta Platforms, Inc., formely known as Facebook,Inc., publicly introduced a whole new way of designing APIs called GraphQL. As a result of its fast and wide adoption, on November 2018, Meta handed the technology over to the Linux Foundation which formed the non-profit GraphQL Foundation responsible for hosting and maintains the GraphQL specification.

GraphQL is both a language and a runtime. The GraphQL schema language allows you to create strongly-typed APIs that can be used to perform read operations called queries, and write operations referred to as mutations. All requests are made to a single API endpoint hosted by a GraphQL server which takes care of interpreting the queries and mutations and coordinating all the operations needed to fulfill those requests.

One of the main strenghts of GraphQL is that by using queries application clients are able to ask for the exact data that they need to be retrieve which prevents overfetching or underfetching. Overfetching means that you get back more data than needed from an API call which results in wasteful processing both on the client and the server side as well as degraded performance since more data has to travel on the wire. On the other hand, underfetching is when you don't have all the data you need after making an API call which may lead to even more performance issues and wasteful processing since you are forced to make multiple API calls to retrieve the full data set. With GraphQL queries, you simply specify which data values you want returned from the GraphQL API and it will honor it returning no more and no less than what is needed.

For write operations you would use a mutation. This is simply a strongly-typed request that allows you to create, update or delete existing data using the GraphQL language syntax. While queries can be executed in paralell if they fetch multiple pieces of information, mutations are processed sequentially to avoid race conditions. 

Lastly, GraphQL offers one more operation type: subscriptions. This an alternative read-only operation that, unlike queries, maintains an active connection between the client and the GraphQL server. This means that the server can update the client at any time if any data changes happen for the objects and fields that the client has subscribed to. This is usually implemented via WebSockets, however, due to the overhead added to maintain that live connection, it is recommended to use it only for the specific cases where this makes sense such as when your application may require real-time updates.


## Next Steps
A modern backend is typically one built on microservice architecture that makes use of event-driven architecture to enable communication amongst loosely-coupled distributed services allowing them to be scalable and highly independent. 

Services expose functionality via APIs and, currently, the two most popular API architectural styles are REST and GraphQL. Like anything else, there are trade-offs when choosing one over the other so it's important to understand their pros and cons before making a decision of which one is right for a given solution.
