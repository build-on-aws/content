---

title: Co-ordination patterns between microservices with orchestration and choreography
description: An overview of the co-ordination patterns between services with choreography and orchestration in a distributed services architecture.
tags:
  - microservices
  - orchestration
  - choreography
  - workflows
authorGithubAlias: codesforwork
authorName: Mohammed Fazalullah Qudrath
date: 2022-12-16
---

## Oveview

The idea of implementing co-ordination patterns to build distributed systems isn't new to the microservcies world. This has been an approach taken since the time of monoliths and Service Oriented Architecture architected applications where you would see a need to, say, send a message or an event to a job that is polling a queue to work on the next item. Over the years, due to the complexity of business processes growing the systems built to reflect the real-world, developers tend to implement services that adopt behaviours like parallel processing, long term wait on status updates, rollback and a few others.

I first start with covering key concepts around events and messages in distributed systems. I then discuss the differences between choreography and orchestration - and talk about why they matter so much to developers.

## Events and messages

Some people use 'events' and 'messages' interchangeably, but they're actually distinct in what kind of systems are included as part of the scope of communication. 

An architecture that uses messaging has a specific format that is framed earlier when building APIs (similar to a function call), where the API knows what is being called and what the expected response is. An example of this is when a passenger uses a mobile application to check for the gate information for their flight. Since the mobile app needs to fetch very speicifc set of information (flight number and date) it knows which API to call and with what speific fields so that it retrieves the required information. The request in this case will be a message.

In an event-driven architecture, disparate systems that comprise a set of complex processes and transactions must be 'told' that something has occurred and a flow to handle it must be initiated. For example, if a flight is delayed for any reason, the airline must deal with customers who may miss flights and others who may wish to cancel them, as well as notify subsequent airlines that passengers may be late. This could include providing meal vouchers and arranging for temporary lodging for passengers who are stranded overnight.

## Co-ordination patterns in distributed systems

### Choreography
The core idea of the choreography pattern is to keep the decision logic distributed and let each service decide what needs to be done upon an event. It thus laid the foundation for Event Driven Architecture.

Lets take an example of an e-commerce store which takes orders from customers through a browser. When the order is placed by a customer, the Orders service will simply emit an event to which all the involved services subscribe. Upon receiving an event, the services will react accordingly and do what they are supposed to. For example, a Logistics service that is subscribing to any new Order event emitted by the Order service will start the process of contacting a logistics partner to come and pick up the order for delivery.

For all the involved services in a choreography designed system, the services are totally decoupled and independent; making this a truly distributed and decentralized architecture.


### Orchestration
Orchestration is the simplest way to model workflows. The core idea of the orchestration pattern is to keep the decision logic centralized and have a single brain in the system.

Taking the same example of the e-commerce store, if it is re-designed with an orchestration approach, the Orders service can be that central co-ordinator that talks to Notification, Seller, and Logistics services and get the necessary things done. The communication between them is synchronous and the Orders service acts as the coordinator.

![Comparison between service choreography and orchestration](images/choreography-orchestration-comparison.png)

## Orchestration vs Choreography

Most model systems favor choreography because it provides some standard asynchronous architecture benefits.

- Loose coupling: Services involved are decoupled
- Extensibility: Extending the functionality is simple and natural
- Flexibility: Search service owns its own decision on the next steps
- Robustness: If one service is down, it does not affect others

A challenge when using choreography is observability and the need to track each service and the events published, the action(s) that were taken as part of an event being emitted by an origin service, and the completion of the business flow or process.

Although choreography is the first choice when building decoupled asyncronous systems, it does not mean orchestration isn't an option. Orchestration has its advantages and can be used in modeling services that are involved transactionally.

Sending an One-Time Password (OTP) during login, for example, is best modeled synchronously rather than asynchronously. Another example is that when we want to render recommended items, a Recommendation service communicates with relevant services to enrich the information before it is sent to the user.

## Which one to choose?

Depending on the work at hand, the size of the company, and a number of other variables, you should choose the appropriate communication style for your microservices. When your program or application demands regular updates and new features, choreography makes more sense. This is because any ongoing activities or procedures are not interfered with. It can be difficult to execute frequent upgrades if your system is more centralized and dependant.

It is preferable to use orchestration when there are intricate workflows requiring levels of synchronization and coordination between thousands of microservices. This is so that complex workflows can be orchestrated smoothly. The orchestrator can function as a controlling unit.

An alternate perspective is adjusting to a hybrid system that, as necessary, combines orchestration and choreography. This is advantageous as it prevents a single point of failure (when the orchestrator malfunctions) and enables sophisticated operations. The organization's context and aim will determine the choice. 

To learn more about orchestration and choreography, refer to the following resources:
[Enterprise Integration Patterns - Choreography](https://www.enterpriseintegrationpatterns.com/patterns/conversation/Choreography.html)
[Enterprise Integration Patterns - Orchestration](https://www.enterpriseintegrationpatterns.com/patterns/conversation/Orchestration.html)

