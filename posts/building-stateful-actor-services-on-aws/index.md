---
title: "Stateless Isn’t Always the Answer.  Building Stateful Actor Services on AWS"
description: Building stateless and stateful services could be challenging.  Actor model and actor frameworks offers a great way of implementing reliable and highly scalable stateful services on AWS
tags:
  - microservices
  - actors
  - concurrency
authorGithubAlias: bbgu1
authorName: Bo Guan
date: 2023-05-16
---

When building Microservices, one of the key principles is for the services to be stateless.  Since stateless servcies do not store and maintain any state data across requests, they are easy to deploy, scale, and replace, provide the scalability and reliability our application needs.  However, many applications and services are required to maintain some sort of state - user sessions, game scores, IoT device status, e.g.   In these applications, our stateless services have to rely on client or external backend store to manage the state data, either of which has many drawbacks including poor performance, data inconsistency, and increased complexity.  

So you may ask, is there a way to build *stateful services*, services that store its own state, therefore avoid the drawbacks of stateless services, while continue to be scalable and reliable?   In this blog post, I will explain that Actor Model and Actor based services may be the answer to that question, as it offers a powerful and elegant way of implementing consistent, efficient, and highly scalable stateful services.  

## The Pursuit of Statelessness

Storing and managing state is a major challenge in Microservices design.   Imagine you are building an backend service for IoT solution, that maintains the status of each IoT device then update it when events and messages are received and processed.  If the service is stateful, i.e.  it stores and maintains the device status in memory of each instance of the service, we will face many challenges that are typical in Microservices:  

* When the service needs to support large number of devices and process the expected high volume of events, it needs to scales out and add many instances, along with a load balancer to distribute the requests to all instances.  How will the load balancers know which instance has the right device data for it to send requests to?  
* If all instances are designed to have a copy of the overall state, how do we synchronize the changes from one instance to all other instances and keep the state data consistent? 
* When an instance crashes, how do we prevent the device data on that instance isn’t going to be lost?    
* When our system launches new instances, either to replace crashed ones or as part of blue-green deployment, how will the new instance know the current status of devices so it can start processing requests? 

Difficulty and complexity to address these challenges with stateful services is the reason why statelessness becomes a principle in Microservices architecture design.   Statelessness allows our services to be ephemeral, makes it highly scalable and easily replaceable, and makes them suitable for containerization and being orchestrated on the beloved Kubernetes and other platforms.

However, when we build real-world applications and services, such as the example above, we realize that they are stateful by nature and often focus on maintaining the state of something.  The IoT solution will manage and monitor the state of IoT devices and act on changes, a banking service needs to retain and update the state of its accounts, and most web applications need to keep tracking user session, among many other examples.   If we design and implement stateless services for these applications, since the services themselves don’t store and maintain the state, we will need depend on the clients or some backing services to manage the state data for us.   

Storing certain state data at the client side is quite common.  In fact, it is how REST procotol works.   As the name indicates, REST, or Representation State Transfer, services are supposed to be stateless:  each request from the client should contain (transfer) all the information (including state) needed for the server to process it and respond.   Being stateless is one of the main reasons that REST becomes the most popular protocol for Microservices.   

With that said, it is not always possible or preferable to store state at the client side, because of the resource limitation, security risks, as well as efficiency / performance / cost concerns.  For example, in our IoT example, our IoT devices (the client) may not have enough storage, or be reliable enough, to keep and track its own status and history.   So for many use cases with stateless service approach, storing state in a backing services is the only option.

## State in Backing Services 

The [Process](https://12factor.net/processes) section of the Twleve-Factor Application Pattern defined the solution well:

> Any data that needs to persist must be stored in a stateful backing service, typically a database

When our stateless service processes a request or event, it will just retrieve the state from the backing service, update it based on the data in the request or event, then persist the updated state data back to the backing services for future requests. So, ironically, the key for this approach to work and  keep our services stateless is to find a stateful backing service that we can trust our state with, that has somehow been able to address the same scaling/recovery and other challenges that we described at the begining of the post.   

In an AWS environment, [DynamoDB](https://aws.amazon.com/dynamodb/) is a popular choice for the backing service, as it provides the durability, scalability, and performance that we need to support our applications. Amazon RDS services like [Aurora](https://aws.amazon.com/rds/aurora/) offers other managed database options. Besides databases, you may also consider using Cache for backing services, which is often faster and cheaper that database options, but volatile and less reliable. [Amazon ElastiCache](https://aws.amazon.com/elasticache/) provides managed Redis or Memcached cluster for those use cases. 

Let’s illustrate the approach, again using the simple IoT solution as an example. Suppose our device here is just a simple counter, that will increase its count every time an event/signal is received. We create a DynamoDB table called `counters` to store the value, and create the service as simple Lambda function:

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

With only a few lines of codes, our function reads the current count (state) of specific Counter, based on the deviceId, from the DynamoDB table. It then increases the count, and persists it back to DynamoDB. 

DynamoDB offers single digit millisecond response time so that, using the device ID as key, retrieving and persisting state records don't add much overhead. The lambda function itself, being stateless, can easily scale out and process large number of requests/events concurrently.   

All seemed quite simple. But before we declare victory, we should run some tests.  We start by setting a high concurrency limit for the function, then triggerring the functions thousands of times for a few counter/device by building and loading messages to a SQS queue that triggers this lambda function. At the end of the tests, we compare the Count values to the number of events we sent, somehow they don’t match.  What went wrong?

## Race Condition in Shared-State Concurrency

It turns out just storing state somewhere else only solves half of the problem.  Microservices need to be scalable and support high concurrency, able to launch many instances of the same service when the volume of requests is high.   When transactions on multiple instances share and access the same state, we run into a common issue of distributed systems and shared-state concurrency, known as [Race Condition](https://en.wikipedia.org/wiki/Race_condition).  

Typical solution to avoid race condition and allow shared data in distributed computing is to introduce 'mutual exclusion' to our solution. Back in monolithic days, we implemented mutual exclusion using objects like 'lock', 'mutex' or 'semaphore'.  For Microservices and distributed systems that don't share memory among its instances, we implement mutual exclusion by introducing additional services like quorum or token management, to alllow only one instance can modify the shared state at any given time.   Blog posts like [1](https://aws.amazon.com/blogs/database/building-distributed-locks-with-the-dynamodb-lock-client/) and [2](https://aws.amazon.com/blogs/compute/controlling-concurrency-in-distributed-systems-using-aws-step-functions/) introduced implementations based on DynamoDb Lock Client and AWS Step Function.  

Needless to say, these additional services and mechanisms are often notoriously difficult to set up and configure. They add complexity and overhead to the system and, if not implemented carefully, may introduce more issues like [Starvation](https://en.wikipedia.org/wiki/Starvation_(computer_science)), where an instance wait indefinitely for accessing the shared state, or [Deadlock](https://en.wikipedia.org/wiki/Deadlock), when two or more instances wait endlessly for each other to release the locks. 

There are other challenges and risks with storing state in backing service and adopt shared concurrency in Microservices. Frequently reading and updating data in backing services / databases could be an expensive operation and performance bottleneck.  With the services tightly coupled with the backing service, any outage to the backing service or network connection in between would bring our services and the whole system down.  

To summarize, building a stateless service and using backing service to store state, in a shared-state concurrency model, may not meet your business requirement and technical requirement, especially when the services are under high volume and high concurrency.   

## Actor Model to the rescue

Fortunately, shared-state concurrency is not the only concurrency model. Actor model, first published in 1973, offers another approach to enable high concurrency for our stateful system. Under actor-based concurrency model, each microservice consists of a collection of independent units of computation - the ‘Actors’. Each actor encapsulates state and behavior, can only communicate with other actors by sending and receiving messages asynchronously.

The key to this model is that each actor has its own private state, that cannot be accessed or modified by other actors and systems. There is no shared-state, therefore we don’t face the challenges of shared-state concurrency and don’t need to implement lock or other complicate mechanisms for the system to be consistent and reliable under high concurrency. 

When I discussed stateful services at the beginning of this post, I explained that services storing its own state are hard to scale and less reliable. How does Actor-based services, in which Actors store its own private state, address the scalability and reliability challenges that other stateful services face? 


## Basic of Actor System

An actor-based stateful service contains an Actor System, which typically has the following concepts and components: 

* Messages and Mailbox. Actors only communicate to each other  by sending and receiving certain messages.   Messages are sent asynchronously to each actor, so they need to be stored in an mailbox of the recipient and wait for their turn to be processed by the actor. Actors process messages one at a time, in the order they arrive.
* Cluster. A cluster is a group of nodes that work together to host actors. In a microservice environment, each node is an instance of a microservice that hosts the actor runtime environment and manages the lifecycle of actors. Actors are distributed across the nodes, often based on the load and resource availability of each node.  
* Remote and Addressing. Actors may live on different nodes and machines in a cluster, actor system must provide a Remote protocol to pass the messages between actors on different nodes while ensuring the reliability and security of the message. Actor identify each other and the recipient of messages through Addressing. Each actor has an unique address that consists of its name and location. Actor system will recognize the address of the recipient of each message and route it to the right node and mailbox. 
* Persistence. In many cases, actors need to save their state to a persistent storage.  They are called ‘persisted actors’. When a persisted actor crash for any reason, the actor can be restarted then resume its state from the last saved snapshot.

To scale out an actor system to handle increasing workload, the service will add more instances, which will join the actor system, become new nodes to the cluster, and start creating and hosting more actors. The cluster may also balance the load among the nodes by moving existing actors to the new and less busy nodes. 

The fault tolerance of the actor system is archived by enabling Persistence. A persisted actor persists each message it receives, along with periodic snapshot of the state, to a back-end database. When an actor failures, the actor system will replace it by initializing a new actor, restoring its state from snapshot, then replaying the stored messages to update the state to exactly the same at the point of the crash. The new actor will then be able to resume work and process messages from exactly where it left off. When a node crash, the actor system will also detect the failure and restart the affected actors on healthy nodes through the same recovery process. 

The actor system is resilient because failure of any actor will not impact other actors or compromise the overall availability. Actors are reactive by definition - it only reacts to events asynchronously, therefore there will not be any blocking or waiting in an actor system. 

Writing Actor code and logic is simple - each actor has only one entry-point, that just receives messages and process them sequentially. However, to make the actor-based stateful service work with high reliability and performance, most people choose to use certain Actor Framework and SDK instead of reinventing the wheel. I will introduce a popular Actor framework next and demonstrate how it can work the best on AWS system.

## Actor Frameworks

There are many Actor frameworks and toolkits available. You may determine which one to use, based on your requirements, preference, and skillsets - do you prefer a specific programming language?   will you benefit from advanced features such as streaming or typed actors?  Or will you manage your own infrastructure, or need fully managed service and platform? [Akka](https://akka.io/) (Java, Scala, and .Net), [Orleans](https://github.com/dotnet/orleans) (.Net only), and [Dapr](dapr.io), are popular choices. I recommend you check out the official documentation of each framework, and try the tutorials and examples, before deciding on the best one to build your microservices on.

In this post, I will demonstrate building an Actor-based microservices application using [Proto.Actor](https://proto.actor/). Proto.Actor is a newer, apache-licensed open source framework, that is arguably easier to use than other frameworks mentioned above. Most importantly to this blog post, Proto.Actor reuses existing proven building blocks for all the secondary aspects - Protobuf for serialization, gRPC for network communication, and as you can see later, EKS or ECS for clustering on AWS, so I can focus on demonstrating the basic concept and benefits of Actor services.

Proto.Actor supports [.Net / C#](https://github.com/asynkron/protoactor-dotnet), [Go](https://github.com/asynkron/protoactor-go), and [Kotlin](https://github.com/asynkron/protoactor-kotlin) programming languages. Sample codes below are all in C#, while the same concept / configuration / logic demonstrated will apply if you choose to use Go or Kotlin.   

## Implementing Actor based services on AWS

To demonstrate how to implement a actor-based service, and how it may benefit from various AWS services, I will rewrite our simple IoT solution using Proto.Actor framework with simple steps below. Please keep in mind that there are many other ways in Proto.Actor, as well as with other Actor frameworks mentioned above, to implement the same actor and logic as my sample project did. Please review the official documentation and examples before implementing your services and applications, and choose the right framework and approach that fit your use case and requirements.

### Setting up the environment

Simply install the Proto.Actor NuGet package in your C# project, you are ready to go.    

### Define messages

Proto.Actor uses Protobuf for serialization. [ProtoBuf](https://protobuf.dev/) is a language-neutral, platform-neutral, extensible mechanism for serializing structured data. With Proto.Actor, we need to define all message types, that our Actors send and receive, in probobuf.  

In this example, we define a message type for the simple event triggered by an IoT device, that only contains the deviceId: 

```csharp
message IotDeviceEvent {
    string DeviceId = 1;
}
```

### Building the actor

In this simple example, we can define the actor class using the IActor interface, and implement the ReceiveAsync method to handle the messages. Our sample actor represents a digital twin of an IoT device. It maintains a counter value for the device, and increases by 1 when a IotDeviceEvent is received.

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

As you can see, the logic and code are very simple. It is stateful, as it keeps the state (`_count`) in memory. There is no concurrency concern, no need to lock the `_count` state data, the code is as simple as the single-threaded program we had in the old days.

### Create a service to host the actors

Just add a simple .net service, with code below in the main program:

```csharp
var system = new ActorSystem();
var props = new Props()
    .WithProducer(()=> new DeviceActor());
    .WithSpawner(Props.DefaultSpawner);
```

We can spawn the actors with another line of code, calling SpawnNamed() function for example, then our service and actor will be ready to receive and process messages.   However, our microservice need to be scalable, responsive, and resilient, for which I introduce Proto.Cluster and [Kubernetes cluster provider](https://proto.actor/docs/cluster/kubernetes-provider-net/). 

### Build a Cluster on EKS

By enabling clustering of actors, we no longer need to manage the actor lifecycle in our code. We don’t ever need to manually spawn actor, or specify which instance that an actor needs to be spawn on. Instead, we just send messages to the cluster, assuming the recipient actor is there. The cluster will find and route messages to the actor with the right id, if one exists. If not, the cluster will pick a node and spawn the actor there. The location of the actor is transparent - we will address them using cluster identity instead of absolute location / path.   

Cluster providers are used to maintain information about available members in the cluster, monitor and notify about any member changes. Proto.Actor, following the same philosophy of not reinventing the wheel again, provides a few implementation of cluster providers built on proven platforms, including Consul, Zookeeper, Kubernetes, etc.   

On AWS, we often deploy and operate our microservices on [ECS](https://aws.amazon.com/ecs/) or [EKS](https://aws.amazon.com/eks/), a managed Kubernetes service. In this example, I added configuration and implementation for deploying our services on an EKS cluster:

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

### Persist Actor state to DynamoDB

The DeviceActor actor needs to persist its state (the current value of _count) in a backend database, so it can recover from crashes and resume processing. Most Actor frameworks provide a `Persistence` module, such as [Proto.Persistence](https://proto.actor/docs/persistence-proto-persistence/). Using the persistence module, our actors can persist their state through EventSourcing, or Snapshotting, or both. 

With event sourcing, the actor calls _persistence.PersistEventAsync( <event>) for each state change.  Both events and snapshots are persisted with the actor identifier, and will only be retrieved by the actor with the same identifer during recovery. 

On AWS, [DynamoDb](https://aws.amazon.com/dynamodb/) is a fully managed key-value database that offers high availability, scaliability, and performance, making it ideal for being the event and snapshot store for Actor-based stateful services. The sample code below is used to create the DynamoDb persistence provider to be injected to the Actors:

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

In our actor-based microservices, actors are stateful and can be spawn on or moved to different locations / nodes by the actor cluster. This makes it difficult to track each actor’s behavior and performance overtime, and to correlate the interactions between actors.   

Proto.Actor solves the observability issue with Proto.OpenTelemetry, and can be instrumented to support distributed tracing and export metrics through OpenTelemetry or Prometheus exporter.  

On EKS, addons including [ADOT collector](https://docs.aws.amazon.com/eks/latest/userguide/deploy-collector.html) or [Prometheus](https://aws-ia.github.io/terraform-aws-eks-blueprints/add-ons/prometheus/) can be easily enabled to start collecting metric from all running instances and actors. Furthermore, [Amazon Managed Service for Prometheus](https://aws.amazon.com/blogs/mt/getting-started-amazon-managed-service-for-prometheus/) and [Amazon Managed Service For Grafana](https://aws.amazon.com/grafana/) can be used to store the metrics collected and display them on dashboards. Traces can be sent to [AWS X-Ray]( https://aws.amazon.com/xray/) where you can view, filter, and get insights of actor interactions.

## Conclusion

In this post, we explained the challenges of building a stateful application with traditional Microservices architecture, and how Actor model and actor-based services can provide a better solution with high concurrency and reliability.   I used modules of Proto.Actor as example and showed that, with Actor model, you can w AWS services, such as EKS and DynamoDB, provide simple and reliable building blocks for your actor system.   
