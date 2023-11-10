---
title: "Beware the Stateless vs. Stateful Fallacies: Making Informed Decisions in System Design"  
description: "Confronting modern reality, the journey between stateless and stateful is neither linear nor a one-size-fits-all choice. In this article, you will see that usually, round statements about stateful architecture turn out to be fallacies. And after diving deeper, it turns out that choice between two paradigms is not a good-or-bad decision."
tags:
  - architecture
  - stateful-workloads
  - stateless-workloads
  - infrastructure-as-code
  - reinvent-2023
spaces:
  - reinvent-2023 
authorGithubAlias: lpanusz
authorName: Łukasz Panusz
additionalAuthors:
  - authorGithubAlias: andrasome
    authorName: Andra Somesan
  - authorGithubAlias: afronski
    authorName: Wojciech Gawroński
date: 2023-11-29
---

| ToC |
|-----|

At the core of every builder lies a relentless pursuit: crafting systems that not only function but evolve over time. This drive isn't just about piecing together lines of code or orchestrating deployments; it's rooted in the desire to create hassle-free systems that stand resilient against challenges. In the intricate dance of system design, the choice between stateless and stateful workloads becomes pivotal.

But why this emphasis? Because we recognize the need for systems that deliver peak performance, offer seamless user experiences, and scale with precision. Both paradigms come with their set of advantages, tailored to meet specific project needs and infrastructure demands. Yet, amidst these technical deliberations, there is a recurring theme: stateful is inherently bad. It's crucial to address this myth and other fallacies, often fueled by a lack of understanding or sheer ignorance.

Yes, you have read this right – we refer to those as fallacies. The terminology used here is deliberate – as it resonates for us with the idea of fallacies of distributed computing. As in that example, navigating this landscape makes our aim clear: identification of false statements helps us, the builders, make better and informed decisions later.

## Back to the basics!

In the intricate landscape of system design, especially within the cloud environment, understanding foundational concepts becomes even more crucial. Let's dive deeper:

What is a state? At its essence, a state captures the current condition of a system. Simply put, a state is the information a system holds at any given point. Think of it as the combination of configurations, user data, operational details, and more. It's the sum of all the variables and values that determine how a system is currently functioning.

Venturing further, we encounter stateful resources. We're essentially talking about resources that have a "memory" of their past or awareness of the present. It's like a journal that keeps track of all its entries and constantly refers to them. It gives the advantage of quick data access, faster processing, and a notion of the flows. From the other side, imagine a domino setup; if you knock one over (modify, create, or destroy it), it can cause a chain reaction, affecting other interconnected components. This means any change to a stateful resource can have side effects on other parts of the system. Especially in cases where vital information is managed outside the cloud automation and infrastructure as code (IaC) processes, these changes can result in the loss of important data that isn't easily recreated by automation alone.

On the other end of the spectrum, stateless resources stand to be replaceable. They operate without referencing past interactions, ensuring that mutable operations don't send shock waves to other interconnected components. It's like adjusting a single piece in a vast puzzle without disturbing the surrounding pieces. It ensures a seamless and unaffected operation. On the side effects note, they tend to increase response times and operational complexity, for example, due to data retrieval operations.

With these precise definitions in hand, the task of navigating the technicalities of cloud architecture design should become more manageable and straightforward. Unfortunately, a stronger focus on processes and business functionalities is taking over attention when it comes to the decision of whether to use stateless over stateful. Over time, initially shallow and quick thought process leads to overcomplicated and unmanageable system implementations.

## Breaking down the fallacies

Diving deeper into the realm of system design, fallacies often affect our judgment. This results in decisions that might not align with the system's actual needs. Let's try to break them down and address some top fallacies head-on.

### Fallacy 1: Stateful is inherently bad

While stateful systems do have their complexities, labeling them as "bad" is an oversimplification. They offer continuity and context, which can be invaluable in certain applications. Personally, we think it is a clear mislabeling. Our industry tends to classify it as “bad”, mainly because it makes scalability a challenge. However, the fact that scaling is harder should not be transferred as a general discouragement on using the whole category of the workloads. As an example, let’s talk about reporting services. The ability to keep data collections in memory, process, filter, group them on the fly, and respond to user needs is one area where stateless workloads are less efficient. Of course, we cannot forget that an understanding of the stateful interconnected nature is required to manage the systems effectively.

### Fallacy 2: Stateless resources don't store data

It's not that stateless resources don't store data; it's that they don't reference past data for current operations. They just do it differently by pushing the state outside and leveraging other stateful resources (e.g., files stored on NFS). In other words – it is a matter of ownership. Each interaction is treated in isolation, ensuring a clean slate for every operation – because the factual owner of the state is a different component. Stateless components approach each interaction without preconceived notions, ensuring unbiased processing (formally, it allows for idempotency – at least from the action executor’s perspective). At the same time, to ensure consistency and return meaningful information to the end users, they need to reach out and ask for data, which leads to higher processing times.

### Fallacy 3: Transitioning between stateless and stateful is straightforward

Switching gears between these two paradigms is not a mere flip of a switch. It requires a thorough understanding of the system's architecture, the dependencies, and the potential ripple effects of the change. Such transitions require careful planning and responsibility separation. In the majority of cases, it will require very diligent code and architecture-level adjustments. Without mapping risks for application stack, networking, storage, database, IaC, etc., we introduce resilience flaws into our system. A canonical example could be a conversion of a stateful authentication system to a stateless one without considering session management, which can lead to security vulnerabilities or increased latency from the end user's perspective.

### Fallacy 4: Stateful systems are always resource-heavy

While stateful systems manage and reference past data, it doesn't automatically make them resource-heavy. The resource consumption largely depends on the implementation and the specific use case. As an example, let’s take a stateful logging system. It can consume more storage over time, but its CPU and memory usage might be optimized, and as a result, it will not necessarily be considered "heavy".

### Fallacy 5: Stateless systems are inherently faster

Speed isn't solely a factor of whether a system is stateless or stateful. It's about optimization, resource allocation, and how well the system is tailored to its intended function. A poorly optimized stateless web server can be slower than a well-optimized stateful one. It becomes widely visible with distributed architectures. Unoptimized data flows, circular networking dependencies, tight coupling, locking requests, and lack of parallel processing, to name a few, can greatly impact the throughput and latency of our stateless systems.

### Fallacy 6: Stateless systems are always easier to scale

Growth and adaptability in a dynamic environment are one of the most important factors nowadays. While stateless systems can be horizontally scaled in an easier way, their dependence on the other layers of the system might become an issue. First-hand factors like database bottlenecks can hinder scalability. A stateless application might handle increased user requests, but if its database can't scale or connection management is done poorly, performance issues arise. On the other side, stateful cache or content delivery networks can scale during high demand irrespective of individual user histories. A careful observer may laugh at presented examples as very convenient ones – but that’s an example where careful application of a stateful approach helps to reduce accidental complexity.

### Fallacy 7: Stateful means less secure due to data retention

Security is about implementation, not just the state. Stateful systems can be secure if designed with security in mind. Banking systems are stateful but employ rigorous security measures to protect user data. Stateful designs prioritize data protection, ensuring user trust and confidence. For example, a cloud storage solution that retains user files while employing robust encryption measures. It also applies to stateless design, where practices like zero-trust security help to protect highly distributed resources.

### Fallacy 8: Stateless systems can always recover faster after a crash

The belief is that rapid recovery ensures minimal disruption. While recovery depends strongly on system design, not just its state. Stateless systems typically bounce back quickly, starting afresh without lingering issues. Unfortunately, at the same time, a stateless system without proper error handling (like back pressure, circuit breakers, etc.) might fail to recover from specific errors. In contrast, a stateful system with robust backup might recover swiftly. Also, combining the action of pushing out state outside (to make a particular component stateless) with the need to preserve requirements related to performance, e.g., lower latency, often introduces a negative side effect in the form of a warming-up procedure right after stateless application starts. So, in case of a restart, it results in some form of a slow start - as it needs to warm up first to satisfy non-functional requirements.

### Fallacy 9: Stateless servers are always simpler.

The desire for simplicity and straightforwardness in specific tasks is a design choice and isn't solely determined by being stateless. Stateless designs might offer a clean slate, free from the complexities of memory and past data. But, at the same time, reality shows that stateless microservices architecture can be complex due to service interdependencies and communication overhead. We should not forget that stateless systems operate autonomously, focusing solely on the present task. Often, by making an individual component stateless, we have pushed out complexity outside. Using a visual mental model of a typical architecture diagram with lines and boxes, complexity escaped from the box to the arrows interconnecting them. This leads to a modular design and reduced interdependencies, ensuring flexibility, but also introduces distributed transactions, processing, data, and eventual consistency, which over time becomes quite expensive in maintenance and further evolution.

### Fallacy 10: Stateful systems are outdated and unsuitable for modern applications

Evolution and adaptation are at the heart of technological progress. Stateful systems have matured over time, offering depth and continuity in user experience. Many modern applications rely on stateful systems for functionalities that require continuity and context. For example, streaming platforms remember user preferences and watch history, enhancing user experience through stateful design. The fallacy is also connected to the common belief that stateful means monolithic, which obviously isn’t true (a canonical example is any data sharding technique – which is far from monolithic, yet very stateful). We can design and implement services or even microservices that are stateful, yet they can follow the latest trends of modern applications.

## Key takeaways

In the vast expanse of system design, the journey from stateless to stateful is neither linear nor one-size-fits-all. As we've traversed the landscape, it becomes evident that understanding the nuances and intricacies of both paradigms is paramount.

By dispelling these fallacies, we equip ourselves with a clearer lens to view the intricate world of system design, ensuring that our decisions are informed, pragmatic, and purpose-driven. The fallacies surrounding stateless and stateful systems, though pervasive, can be dispelled with a deeper, more informed exploration. It's not merely about choosing one over the other but understanding the "why" behind each choice.

As builders, our mission is to craft systems that are efficient, effective, and tailored to specific needs. This requires a holistic view, considering not just the technical aspects but also the broader implications on infrastructure, user experience, and long-term scalability. In conclusion, the stateless-stateful debate isn't a binary one. It's a spectrum rich with possibilities and potential.

Hopefully, by approaching it with clarity, knowledge, and an open mind, we can harness the strengths of both paradigms, creating systems that truly resonate with our purpose and vision.
