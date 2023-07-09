---
title: "Stateless Isn’t Always the Answer. Building Stateful Actor Services on AWS."
description: Building stateless and stateful services can be challenging. Actor model and actor frameworks offer a great way of implementing reliable and highly scalable stateful services on AWS.
tags:
  - microservices
  - actors
  - concurrency
  - eks
  - kubernetes
  - dotnet
  - csharp
authorGithubAlias: bbgu1
authorName: Bo Guan
date: 2023-05-16
---

|ToC|
|---|

When building microservices, one key principle is for the services to be stateless. Since stateless services do not store and maintain any state data across requests, they are easy to deploy, scale, and replace, providing the scalability and reliability many applications need. However, many applications and services are required to maintain some sort of state - user sessions, game scores, IoT device status, etc. In these applications, our stateless services have to rely on client or external backend storage to manage the state data, which have many drawbacks, including poor performance, data inconsistency, and increased complexity.  

So you may ask, is there a way to build *stateful services*, services that store their own state, therefore avoiding the drawbacks of stateless services, while continuing to be scalable and reliable? In this blog post, I will explain that Actor Model and Actor-based services may be the answer to that question, as they offer a powerful way of implementing consistent, efficient, and highly scalable stateful services.  

## The Pursuit of Statelessness

Storing and managing state is a major challenge in microservices design. Imagine you are building a backend service for an IoT solution that maintains the status of each IoT device then updates it when events and messages are received and processed. If the service is stateful (i.e. it stores and maintains the device status in memory of each instance of the service), we will face many challenges that are typical in microservices:  

* When the service needs to support a large number of devices and process the expected high volume of events, it needs to scale out and add many instances, along with a load balancer to distribute the requests to all instances. How will the load balancers know which instance has the right device data for it to send requests to?  
* If all instances are designed to have a copy of the overall state, how do we synchronize the changes from one instance to all other instances and keep the state data consistent?
* When an instance crashes, how do we ensure the device data on that instance won’t be lost?
* When our system launches new instances, either to replace crashed ones or as part of blue-green deployment, how will the new instance know the current status of devices so it can start processing requests?

The difficulty and complexity in addressing these challenges with stateful services is the reason why statelessness has become a principle in microservices architecture design.   Statelessness allows our services to be ephemeral, makes them highly scalable and easily replaceable, and makes them suitable for containerization and being orchestrated by Kubernetes and other engines.

However, when we build real-world applications and services, such as the example above, we realize that they are stateful by nature and often focus on maintaining the state of something. An IoT solution will manage and monitor the state of IoT devices and act on changes; a banking service needs to retain and update the state of its accounts; most web applications need to keep tracking user session; the examples go on. If we design and implement stateless services for these applications, since the services themselves don’t store and maintain the state, we will need to depend on the clients or some backing services to manage the state data for us.

Storing certain state data at the client side is quite common. In fact, it is how REST protocol works. As the name indicates, REST, or Representation State Transfer, services are supposed to be stateless: each request from the client should contain and transfer all the information, including current state data, that is needed for the server to process and respond to it. Being stateless is one of the main reasons that REST has become arguably the most popular protocol for microservices.

With that said, it is not always possible or preferable to store state at the client side, because of the resource limitations, security risks, and other efficiency, performance, or cost concerns. For example, in our IoT example, our IoT devices (the client) may not be reliable enough or have enough storage to keep and track their own status and history. So for many use cases with stateless service approach, storing state in some backing service is the only option.

## State in Backing Services

The [Process](https://12factor.net/processes) section of the Twelve-Factor Application Pattern defines the backing service solution well:

> Any data that needs to persist must be stored in a stateful backing service, typically a database

When our stateless service processes a request or event, it will retrieve the latest state data from the backing service, update it based on the data in the request or event, then persist the updated state data back to the backing service for future requests. Ironically, the key for this approach to work and keep our services *stateless* is to find a *stateful* backing service that we can entrust with our state data - that has somehow been able to address the same scalability and reliability challenges we described at the beginning of the post.

Such services do exist. On AWS, for instance, [Amazon DynamoDB](https://aws.amazon.com/dynamodb/?sc_channel=el&sc_campaign=appswave&sc_geo=mult&sc_country=mult&sc_outcome=acq&sc_content=building-stateful-actor-services-on-aws) is a popular choice for the backing service, as it provides the durability, scalability, and performance that we need to support our applications. Amazon RDS services like [Amazon Aurora](https://aws.amazon.com/rds/aurora/?sc_channel=el&sc_campaign=appswave&sc_geo=mult&sc_country=mult&sc_outcome=acq&sc_content=building-stateful-actor-services-on-aws) offer other managed database options. Besides databases, you may also consider using Cache for backing services, which is often faster and cheaper than database options, but volatile and less reliable. [Amazon ElastiCache](https://aws.amazon.com/elasticache/?sc_channel=el&sc_campaign=appswave&sc_geo=mult&sc_country=mult&sc_outcome=acq&sc_content=building-stateful-actor-services-on-aws) provides managed Redis or Memcached cluster for those use cases.

Let’s illustrate the approach, again using the simple IoT solution as an example. Suppose our device here is just a simple counter that will increase its count every time an event/signal is received. We create a DynamoDB table called `counters` to store the value, and create the service as simple Lambda function:

```python
import boto3
dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('counters')

def lamnbda_handler(event, context):
   response = table.get_item(Key={'id': event['deviceId']})
   item = response['item']
   item['current_count'] = item['current_count'] + 1; 
   table.put_item(Item=item)
   
   return item
```

With only a few lines of code, our function reads the current count (state) of our specific counter, based on the deviceId, from the DynamoDB table. It then increases the count and persists it back to DynamoDB.

DynamoDB offers single digit millisecond response time so using the device ID as the key, retrieving and persisting state records don't add much overhead. The lambda function itself, being stateless, can easily scale out and process large number of requests/events concurrently.

All of this seems quite simple. But before we declare victory, we should run some tests. We start by setting a high concurrency limit for the function, then build and load thousands of messages, for one or a few devices, to a SQS queue that triggers this lambda function. At the end of the tests, we compare the count values to the number of events we sent - and discover they don’t match. What went wrong?

## Race Condition in Shared-State Concurrency

It turns out that storing state somewhere else only solves half of the problem. Microservices need to be scalable and support high concurrency, to be able to launch many instances to keep up with a high volume of requests. When transactions on multiple instances share and access the same state data, like they did in the example above, we may run into a common issue of distributed systems and shared-state concurrency, known as [Race Condition](https://en.wikipedia.org/wiki/Race_condition).  

A typical solution to avoid race condition and allow shared data in distributed computing is to introduce 'mutual exclusion' to our solution. Back in monolithic days, we implemented mutual exclusion using objects like 'lock', 'mutex', or 'semaphore'. For microservices and distributed systems that don't share memory among their instances, we implement mutual exclusion by introducing additional services like quorum or token management, to allow only one instance to modify the shared state at any given time. Some blog posts introduced implementations based on [DynamoDb Lock Client](https://aws.amazon.com/blogs/database/building-distributed-locks-with-the-dynamodb-lock-client/?sc_channel=el&sc_campaign=appswave&sc_geo=mult&sc_country=mult&sc_outcome=acq&sc_content=building-stateful-actor-services-on-aws) and [AWS Step Functions](https://aws.amazon.com/blogs/compute/controlling-concurrency-in-distributed-systems-using-aws-step-functions/?sc_channel=el&sc_campaign=appswave&sc_geo=mult&sc_country=mult&sc_outcome=acq&sc_content=building-stateful-actor-services-on-aws).

While valuable in many contexts, these additional services and mechanisms add complexity and overhead to the system and, if not implemented carefully, may introduce more issues like [starvation](https://en.wikipedia.org/wiki/Starvation_(computer_science)), where an instance waits indefinitely to access the shared state, or [deadlock](https://en.wikipedia.org/wiki/Deadlock), when two or more instances wait endlessly for each other to release the locks.

There are other challenges and risks with storing state in backing services and adopting shared concurrency in microservices. Frequently reading and updating data in backing services and databases can be an expensive operation and performance bottleneck. With services tightly coupled with backing services, any outage to the backing service or network connection in between would bring our services and the whole system down.

To summarize, building a stateless service and using backing service to store state, in a shared-state concurrency model, may not meet your business and technical needs, especially when the services are under high volume and high concurrency.

## Actor Model to the Rescue

Fortunately, shared-state concurrency is not the only concurrency model. Actor Model, first published in 1973, offers another approach to enable high concurrency for our stateful system. Under an actor-based concurrency model, each microservice consists of a collection of independent units of computation - the ‘actors’. Each actor encapsulates state and behavior, and can only communicate with other actors by sending and receiving messages asynchronously.

The key to this model is that each actor has its own private state that cannot be accessed or modified by other actors and systems. There is no shared-state, therefore we don’t face the challenges of shared-state concurrency and don’t need to implement lock or other complicated mechanisms for the system to be consistent and reliable under high concurrency.

When I discussed stateful services at the beginning of this post, I explained that services storing their own state are hard to scale and less reliable. How do actor-based services, in which actors store their own private states, address the scalability and reliability challenges that other stateful services face? Let's take a closer look.

## The Basics of an Actor System

An actor-based stateful service contains an Actor System, which typically has the following concepts and components:

* Messages and Mailbox: Actors only communicate to each other by sending and receiving certain messages. Messages are sent asynchronously to each actor, so they need to be stored in an mailbox of the recipient and wait for their turn to be processed by the actor. Actors process messages one at a time, in the order they arrive.
* Cluster: A cluster is a group of nodes that work together to host actors. In a microservice environment, each node is an instance of a microservice that hosts the actor runtime environment and manages the lifecycle of actors. Actors are distributed across the nodes, often based on the load and resource availability of each node.  
* Remote and Addressing: Actors may live on different nodes and machines in a cluster. An actor system must provide a remote protocol to pass the messages between actors on different nodes while ensuring the reliability and security of the message. Actors identify each other and the recipient of messages through addressing. Each actor has a unique address that consists of its name and location. An actor system will recognize the address of the recipient of each message and route it to the right node and mailbox.
* Persistence: In many cases, actors need to save their state to a persistent storage. They are called ‘persisted actors’. When a persisted actor crashes for any reason, the actor can be restarted and then resume its state from the last saved snapshot.

To scale out an actor system to handle increasing workload, the service will add more instances, which will join the actor system, become new nodes in the cluster, and start creating and hosting more actors. The cluster may also balance the load among the nodes by moving existing actors to the new and less busy nodes.

The fault tolerance of the actor system is archived by enabling persistence. A persisted actor persists each message it receives, along with periodic snapshot of the state, to a back-end database. When an actor fails, the actor system will replace it by initializing a new actor, restoring its state from the snapshot, then replaying the stored messages to update the state to exactly the same state at the point of the crash. The new actor will then be able to resume work and process messages from precisely where it left off. When a node crashes, the actor system will also detect the failure and restart the affected actors on healthy nodes through the same recovery process.

The actor system is resilient because failure of any actor will not impact other actors or compromise the overall availability. Actors are reactive by definition - they only react to events asynchronously, therefore there will not be any blocking or waiting in an actor system.

Writing actor code and logic is simple: each actor has only one entry-point that just receives messages and processes them sequentially. However, to make the actor-based stateful service work with high reliability and performance, most people choose to use an Actor Framework and SDK instead of reinventing the wheel. I will introduce a popular Actor Framework next and demonstrate how it can work using AWS.

## Actor Frameworks

There are many Actor frameworks and toolkits available. You may determine which one to use, based on your requirements, preferences, and skillsets. Do you prefer a specific programming language? Will you benefit from advanced features such as streaming or typed actors?  Or will you manage your own infrastructure or need fully managed service and platform? [Akka](https://akka.io/) (Java, Scala, and .Net), [Orleans](https://github.com/dotnet/orleans) (.Net only), and [Dapr](dapr.io) are popular choices. I recommend you check out the official documentation of each framework and try the tutorials and examples before deciding on the best one to build your microservices.

In this post, I will demonstrate building an actor-based microservices application using [Proto.Actor](https://proto.actor/). Proto.Actor is a newer, Apache-licensed open source framework that is arguably easier to use than other frameworks mentioned above. Most importantly to this blog post, Proto.Actor reuses existing proven building blocks for all the secondary aspects - Protobuf for serialization, gRPC for network communication, and as you can see later, EKS or ECS for clustering on AWS, so I can focus on demonstrating the basic concepts and benefits of Actor services.

Proto.Actor supports [.Net / C#](https://github.com/asynkron/protoactor-dotnet), [Go](https://github.com/asynkron/protoactor-go), and [Kotlin](https://github.com/asynkron/protoactor-kotlin) programming languages. Sample codes below are all in C#, while the same concept, configuration, and logic demonstrated will apply if you choose to use Go or Kotlin.

## Implementing Actor-Based Services on AWS

To demonstrate how to implement an actor-based service, and how it may benefit from various AWS services, I will rewrite our simple IoT solution using a Proto.Actor framework with simple steps below. Please keep in mind that there are many other ways in Proto.Actor, as well as with other Actor Frameworks mentioned above, to implement the same actor and logic as my sample project does. Please review the official documentation and examples before implementing your services and applications, and choose the right framework and approach that fit your use case and requirements.

### Setting Up the Environment

Simply install the Proto.Actor NuGet package in your C# project, and you are ready to go.

### Define messages

Proto.Actor uses Protobuf for serialization. [ProtoBuf](https://protobuf.dev/) is a language-neutral, platform-neutral, extensible mechanism for serializing structured data. With Proto.Actor, we need to define all message types, that our actors send and receive, in Protobuf.  

In this example, we define a message type for the simple event triggered by an IoT device, that only contains the deviceId:

```csharp
message IotDeviceEvent {
    string DeviceId = 1;
}
```

### Building the Actor

In this simple example, we can define the actor class using the IActor interface and implement the ReceiveAsync method to handle the messages. Our sample actor represents a digital twin of an IoT device. It maintains a counter value for the device, and increases by 1 when an IotDeviceEvent is received.

```csharp
internal class DeviceActor: IActor
{
    private int _count;
    
    public Task ReceiveAsync(IContext context)
    {
        var msg = context.Message;
        switch (msg)
        {
            case IoTDeviceEvent evt:
                _count ++;
                break;
                
            default:
                break;
        }
        return Task.CompletedTask;
    }
}
```

As you can see, the logic and code are very simple. It is stateful, as it keeps the state (`_count`) in memory. There is no concurrency concern and no need to lock the `_count` state data. The code is as simple as the single-threaded program we had in the old days.

### Create a Service to Host the Actors

Just add a simple .net service, with code below in the main program:

```csharp
var system = new ActorSystem();
var props = new Props()
    .WithProducer(()=> new DeviceActor());
    .WithSpawner(Props.DefaultSpawner);
```

We can spawn the actors with another line of code, calling SpawnNamed() function for example, then our service and actor will be ready to receive and process messages. However, our microservice needs to be scalable, responsive, and resilient, for which I will introduce Proto.Cluster and [Kubernetes cluster provider](https://proto.actor/docs/cluster/kubernetes-provider-net/).

### Build a Cluster on EKS

By enabling clustering of actors, we no longer need to manage the actor lifecycle in our code. We don’t ever need to manually spawn actors or specify which instance an actor needs to spawn on. Instead, we just send messages to the cluster, assuming the recipient actor is there. The cluster will find and route messages to the actor with the right id, if one exists. If not, the cluster will pick a node and spawn the actor there. The location of the actor is transparent - we will address them using cluster identity instead of absolute location and path.

Cluster providers are used to maintain information about available members in the cluster, monitor and notify about any member changes. Proto.Actor, following the same philosophy of not reinventing the wheel again, provides a few implementations of cluster providers built on proven platforms, including Consul, Zookeeper, Kubernetes, etc.

On AWS, we often deploy and operate our microservices on [ECS](https://aws.amazon.com/ecs/?sc_channel=el&sc_campaign=appswave&sc_geo=mult&sc_country=mult&sc_outcome=acq&sc_content=building-stateful-actor-services-on-aws) or [EKS](https://aws.amazon.com/eks/?sc_channel=el&sc_campaign=appswave&sc_geo=mult&sc_country=mult&sc_outcome=acq&sc_content=building-stateful-actor-services-on-aws), a managed Kubernetes service. In this example, I added configuration and implementation for deploying our services on an EKS cluster:

```csharp
IClusterProvider k8sProvider = 
   new KubernetesProvider(
      new Kubernetes(KubernetesClientConfiguration.InClusterConfig())
   );
  
var remoteConfig = GrpcNetRemoteConfig.BindTo(ip, port);

var clusterConfig = ClusterConfig
    .Setup(
        clusterName: _CLUSTER_NAME,
        clusterProvider: k8sProvider,
        identityLookup: new PartitionIdentityLookup())
    .WithClusterKind(
        kind: "device",
        prop: props );

await system.WithRemote(remoteConfig)
    .WithCluster(clusterConfig);
    .Cluster()
    .StartMemberAsync();
```

### Persist Actor State to DynamoDB

The DeviceActor actor needs to persist its state (the current value of _count) in a backend database, so it can recover from crashes and resume processing. Most Actor Frameworks provide a `Persistence` module, such as [Proto.Persistence](https://proto.actor/docs/persistence-proto-persistence/). Using the persistence module, our actors can persist their state through event sourcing, snapshotting, or both.

With event sourcing, the actor calls `_persistence.PersistEventAsync(<event>)` for each state change. Both events and snapshots are persisted with the actor identifier and will only be retrieved by the actor with the same identifier during recovery.

On AWS, [DynamoDb](https://aws.amazon.com/dynamodb/?sc_channel=el&sc_campaign=appswave&sc_geo=mult&sc_country=mult&sc_outcome=acq&sc_content=building-stateful-actor-services-on-aws) is a fully managed key-value database that offers high availability, scalability, and performance, making it ideal for being the event and snapshot store for Actor-based stateful services. The sample code below is used to create the DynamoDb persistence provider to be injected to the actors:

```csharp
    var client = new AmazonDynamoDBClient();

    // Set options - you can replace table names.
    var options = new DynamoDBProviderOptions("events", "snapshots");

    // Optionally: Check/Create tables automatically.
    // Those 1s at the end are just initial read/write capacities.
    // If you don't need snapshots/events don't create that table.
    // If not you have to manually create tables!
    //await DynamoDBHelper.CheckCreateEventsTable(client, options, 1, 1);
    //await DynamoDBHelper.CheckCreateSnapshotsTable(client, options, 1, 1);

    // Initialize provider and use it for your persistent Actors.
    var provider = new DynamoDBProvider(client, options);
```

### Observability

In our actor-based microservices, actors are stateful and can be spawned on or moved to different locations or nodes by the actor cluster. This makes it difficult to track each actor’s behavior and performance over time, and to correlate the interactions between actors.

Proto.Actor solves the observability issue with Proto.OpenTelemetry, and can be instrumented to support distributed tracing and export metrics through OpenTelemetry or Prometheus exporter.  

On EKS, addons including [ADOT collector](https://docs.aws.amazon.com/eks/latest/userguide/deploy-collector.html?sc_channel=el&sc_campaign=appswave&sc_geo=mult&sc_country=mult&sc_outcome=acq&sc_content=building-stateful-actor-services-on-aws) or [Prometheus](https://aws-ia.github.io/terraform-aws-eks-blueprints/add-ons/prometheus/) can be easily enabled to start collecting metrics from all running instances and actors. Furthermore, [Amazon Managed Service for Prometheus](https://aws.amazon.com/blogs/mt/getting-started-amazon-managed-service-for-prometheus/?sc_channel=el&sc_campaign=appswave&sc_geo=mult&sc_country=mult&sc_outcome=acq&sc_content=building-stateful-actor-services-on-aws) and [Amazon Managed Service For Grafana](https://aws.amazon.com/grafana/?sc_channel=el&sc_campaign=appswave&sc_geo=mult&sc_country=mult&sc_outcome=acq&sc_content=building-stateful-actor-services-on-aws) can be used to store the metrics collected and display them on dashboards. Traces can be sent to [AWS X-Ray]( https://aws.amazon.com/xray/?sc_channel=el&sc_campaign=appswave&sc_geo=mult&sc_country=mult&sc_outcome=acq&sc_content=building-stateful-actor-services-on-aws) where you can view, filter, and get insights of actor interactions.

## Conclusion

Building a stateful application with traditional microservices architecture can be challenging, but an actor model and actor-based services can simplify the development of microservcies and distributed systems with high concurrency and reliability. I used modules of Proto.Actor as example, and showed that an actor framework, and AWS services such as EKS and DynamoDB, provide simple and reliable building blocks for developing your actor system.

To learn more about the actor model and actor frameworks, you may check out the following resources:
- [Actor model - Wikipedia](https://en.wikipedia.org/wiki/Actor_model): This article gives an overview of the history, fundamental concepts, applications, and programming languages of the actor model of concurrent computation.  It also lists various programming languages that employ the Actor model, as well as libraries and frameworks that permit actor-style programming in languages that don't have actors built-in. 
- [Actors: A Model of Concurrent Computation in Distributed Systems](https://direct.mit.edu/books/monograph/4794/ActorsA-Model-of-Concurrent-Computation-in): This thesis by Gul Agha provides both a syntactic definition and a denotational model of Hewitt's actor paradigm, explains how actor model addresses some central issues in distributed computing. 
- [How the Actor Model Meets the Needs of Modern, Distributed Systems](https://doc.akka.io/docs/akka/current/typed/guide/actors-intro.html): Akka is a popular framework based on Actor model and built on the principles outlined in the [Reactive Manifesto](https://www.reactivemanifesto.org/).  This guide explains how use of actor model can overcome the challenges in building modern, distributed systems. 




