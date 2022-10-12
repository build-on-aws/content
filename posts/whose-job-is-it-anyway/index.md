---
title: Application Resilience - Whose Job Is It Anyway?
description: Is it possible for application resilience and innovation to co-exist? In this article, we will look at what team cultural changes and technical considerations during software development ensure the co-existence of application resilience and innovation. 
tags:
  - application-resilience
  - shared-responsibility
  - digital-transformation
authorGithubAlias: aws-veliswaboya
authorName: Veliswa Boya
date: 2022-10-12
---

During my recent talks on continuous resilience, first at a [developer conference](https://www.devconf.co.za/) here at home in South Africa, and later at the [AWS London Summit](https://aws.amazon.com/events/summits/london/agenda/), I was asked a ton of thought-provoking questions.
Beyond application resilience, organizations are looking to innovate for their customers. A question that I was asked a lot therefore was whether it is possible to have both application resilience AND innovation? Does the pursuit of application resilience not hold back innovation? How do teams organize in order to ensure that there is both application resilience and innovation? Who in the team is responsible for application resilience, and who is responsible for innovation?

Continuous resilience is when teams move away from a robustness-centric approach to instead facing up to the fact that applications will fail at some point, and thus embracing failure with an intention to build capabilities that ensure resilience of their applications when they ultimately experience failure.

The talk was actually based on an [awesome blog](https://medium.com/the-cloud-architect/towards-continuous-resilience-3c7fbc5d232b) written by one of my colleagues and mentor [Adrian Hornsby](https://twitter.com/adhorn) and it’s a great blog to read if you are looking to evolve your team away from being robustness-centric to instead embracing failure and moving towards continuous resilience.

In this article, we will look at what team cultural changes and technical considerations during software development will ensure the co-existence of application resilience and innovation. 
The shared responsibility model in software development unifies teams, we will look at this as we answer the question of who in the application team is responsible for application resilience.

## Cultural Transformation for Digital Transformation
Organizations that seek to digitally transform and become tomorrow’s disruptors are not able to do this without undergoing cultural transformation.

Siloed functions within a software development life cycle get in the way of communication and collaboration, thus slowing down innovation and the delivery of business value to customers. It is also worth mentioning that siloed functions can introduce conflicts within roles — which can manifest through statements such as “that is not my job” and further compromising a quality product being delivered to the customer.

As teams seek to move out of the siloed development approach, communication between teams is important. Communication moves teams towards a shared responsibility model and is important for innovation. 

Teams can explore tools that better support collaboration during software development. Tools like [GitHub](https://github.com/) are popular among developers as they offer collaborative features that make life easier for developers such as code reviews, pull requests, notifications and more.
Software development projects can be better organized using tools like [Trello](https://trello.com/) which lets teams organize projects into boards so that teams can have a view of what’s on the to-do list, what’s being worked on, and what’s done in order to eliminate confusion with project status.

## Shared Responsibility Model in Software Development
I briefly talked about the shared responsibility model in the previous section and I’ll expand on it more here.
Good quality code is only but one of the contributing factors in application resilience. Performance efficiency, security, and functional suitability go hand-in-hand with good quality code to contribute towards application resilience.
If you decide to tackle these contributing factors individually, it is easy to fall back into siloed functions where individual roles within teams are responsible for only some of these contributing factors.

It is however more beneficial for everyone in the team and ultimately in the organization to make quality a shared responsibility. This approach reduces development costs, and ultimately the customer or end user benefits from a better product.

Paraphrasing Eric Mader [who wrote for DevOps.com](https://devops.com/solving-the-devops-accountability-problem/), “team members are equally ultimately responsible for application resilience”. Outdated organizational structures however tend to place responsibilities on a single employee, team, or role. Organizing team structures around products — instead of projects — will accelerate innovation and increase the quality of work due to increased collaboration that is fostered by this team structure.
Shared responsibility? Collaboration? It sounds like I’ve gone and started a whole conversation on a popular term – DevOps!
In the book [DevOps for Dummies](https://www.amazon.com/DevOps-Dummies-Computer-Tech/dp/1119552222) author [Emily Freeman](https://twitter.com/editingemily/) describes DevOps as a philosophy that is meant to build a culture of trust, collaboration, and continuous improvement.

Emily further goes to give a guide on how to design your organization so that you support this collaboration and continuous improvement. Is the culture of your organization healthy in that the worst of tech culture is avoided with diversity of thought being encouraged?

Are your team members empowered to make decisions without always consulting management for every decision making?

Staying with this topic of DevOps a little longer, it is worth iterating that building a common DevOps team or having DevOps-focused members in the team introduces shared responsibility in the team.
Over time, several essential practices have emerged when adopting DevOps: Continuous Integration, Continuous Delivery, Infrastructure as Code, and Monitoring and Logging but we will discuss these more later.

## Technical Considerations for Shared Responsibility 
Now that the culture has been addressed, what technical considerations will support this Shared Responsibility in teams?
1. Distributed Architectures
In this really insightful book [Fundamentals of Software Architecture](https://www.amazon.com/Fundamentals-Software-Architecture-Comprehensive-Characteristics/dp/1492043451) the authors contrast two architecture styles; monolithic vs distributed. Monolithic is described as a single deployment unit of ALL code whereas distributed involves multiple deployment units connected through remote access protocols. An example of a distributed architecture is a microservices architecture which is an architectural style that structures an application as a collection of loosely coupled services, which implement business capabilities.
It is a way of breaking up a monolithic software into various components that can function separately, have specific tasks, and communicate with each other through a simple **Application Programming Interface (API)**.
2. Continuous Integration and Delivery 
The [AWS Whitepaper on introducing DevOps](https://docs.aws.amazon.com/whitepapers/latest/introduction-devops-aws/introduction.html) highlights AWS capabilities that help you accelerate your DevOps journey, and services that can help remove the undifferentiated heavy lifting associated with DevOps adaptation.
It expands on these essential practices when adopting DevOps — some of which I already briefly talked about previously:
- **Continuous Integration:** A software development practice where developers regularly merge their code changes into a central repository, after which automated builds and tests are run.
- **Infrastructure as Code:** A practice in which infrastructure is provisioned and managed using code and software development techniques, such as version control, and continuous integration. Consider tools like [Terraform](https://www.terraform.io/) which lets you automate the provision of your infrastructure including databases, servers, and firewall policies among others – across multiple cloud platforms.,
- **Monitoring and Logging:** Enables organizations to see how application and infrastructure performance impacts the experience of their product’s end user. [OpenTelemetry](https://opentelemetry.io/) is a collection of tools, APIs, and SDKs. Use it to instrument, generate, collect, and export telemetry data (metrics, logs, and traces) to help you analyze your software’s performance and behavior.
- **Communication and Collaboration:** Practices are established to bring the teams closer and by building workflows and distributing the responsibilities for DevOps.
- **Security:** Should be a cross cutting concern. Your continuous integration and continuous delivery (CI/CD) pipelines and related services should be safeguarded and proper access control permissions should be set up.

**In conclusion**, it seems that the old saying remains true; you cannot keep on doing the same things and expecting different results. Teams will have to evolve in order to ensure innovation for their customers. Teams will have to evolve into a shared responsibility model in order to be better positioned to work towards application resilience.

So where in this evolution journey are you and your team? I'd love to know;
- Do you still have siloed functions as part of a software development life cycle?
- Are you in the process of transitioning from siloed functions to a shared  responsibility team?
- Have you fully transitioned to a shared responsibility team?

x


