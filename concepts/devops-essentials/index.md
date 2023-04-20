---
title: DevOps Essentials  
description: An essential guide for learning about DevOps and its core concepts. 
tags:
  - devops
  - essentials
  - aws
spaces:
  - devops
authorGithubAlias: gogococo 
authorName: Jacquie Grindrod
date: 2023-01-12
---

This guide is for beginners who are looking for an overview of what DevOps is and an introduction to the core concepts they should be aware of. You’ve probably landed here because you’re looking to learn more about it and how you can apply this knowledge to the problems you are facing. You can think of this post as a guide post to help you discover where you are and where you're going next. This guide will not sell you products, platforms or tools as solutions to those problems. There is no one size fits all solution, however there are existing patterns, frameworks, and mechanisms that have been tested and iterated upon which you can leverage. Feel free to read this post from start to finish or to skip to sections that you're most interested in, whichever works best for you!

| Sections                                                    |
|-------------------------------------------------------------|
| 1. [What is DevOps?](#what-is-devops)                       |
| 2. [Getting started](#getting-started)                      |
| 3. [Infrastructure implementation patterns](#infrastructure-implementation-patterns)  |
| 4. [Infrastructure as code](#infrastructure-as-code)        |
| 5. [Configuration management](#configuration-management)    |
| 6. [Containers](#containers)                                |
| 7. [Container orchestration](#container-orchestration)      |
| 8. [CI/CD](#continuous-integration-and-continuous-delivery) |
| 9. [Logging](#Logging)                                      |
| 10. [Monitoring](#Monitoring)                               |
| 11. [Observability](#Monitoring)                            |
| 12. [Where should I start?](#where-should-i-start)          |
| 13. [Conclusion](#conclusion)                                     |
| 14. [Additional Learning Resources](#resources)             |

## What is DevOps?

The term DevOps was coined in 2009 by [Patrick Debois](https://twitter.com/patrickdebois) and is a combination of practices from both software development (Dev) and information-technology operations (Ops). At its core, DevOps is an approach to solving problems collaboratively. It values teamwork and communication, fast feedback and iteration, and removing friction or waste through automation. It became popular because it encouraged teams to break their work down into smaller chunks and approach product delivery collaboratively, with a holistic view of the product, enabling better team transparency and quicker, more reliable deployments. DevOps consists of a combination of practices including Culture, Process, and Tooling. While it’s important to note that implementing DevOps practices is more than simply adding a pipeline or using containers, these and others are common technical areas that we work in to help accomplish our goals. A large aspect of DevOps revolves around adopting the DevOps culture, which we cover in more detail in DevOps Foundations, along with common frameworks and team topologies.

## Getting started

In this section, we will cover concepts such as how to decide where to start and different approaches to begin. As you’re getting started, it’s important to note that there’s no step that’s too small to count towards progress. You don’t need to dive all the way in - in fact, it’s probably better not to! At the beginning, you want to minimize risk and friction by taking on smaller actions and getting fast feedback. Then you will continue to improve by making small, iterative changes and building momentum. 

Another way to find a good starting place is by talking to the teams who will depend on your work. Are there manual steps they’re taking that lead to wasted time or bottlenecks? Do they have a wish list for how they’d like to be deploying or testing their work? Sometimes, the easiest place to start is the one you already know you need. You’ve decided to make small iterative changes, but how we approach that is also important. There’s multiple ways to build out infrastructure, and each comes with different benefits and challenges. 

## Infrastructure implementation patterns
Usually there exists some infrastructure that teams use to deliver software systems, from build pipelines, to databases, web servers, load balancers, etc. There are a few ways to approach setting up this infrastructure.

### *ClickOps*

Using a browser-based console for tools or platforms such as the [AWS Management Console](https://console.aws.amazon.com/) can be a great way to explore which services are available to you and how they fit together. However, it doesn’t scale well as it’s not repeatable, apparent who made the change, or easy to collaborate with others and opens you up to creating more manual mistakes.  

### *Procedural* 

These are a series of steps that are programmatically automated, such as a script that must be completed in a specific order to finish a task. This approach tells the program what to do, step by step, and the program executes the instructions in the order that they are written. An example of a procedural script might look like a database backup script that connects to the database, exports the data to a file, and then copies the file to a backup storage location.

### *Declarative* config

Describes the desired end state of a system, rather than specifying the steps needed to get there. The program is responsible for determining the steps needed to achieve the desired state. An example of a declarative script might be a configuration file that specifies the desired settings for a system, such as the packages that should be installed, the users that should be created, and the network configuration.

These are listed in order from minimal complexity and shorter-term gains compared to higher complexity and longer-term gains. It’s typically easier to explore and create something quickly by following browser-based wizards or using an existing CLI command but it’s harder to scale and maintain as your team or system grows. It’s fine to start higher up on the list and work your way down. You can assess the trade-offs and decide which fits your team best at the moment.

### Examples of procedural compared to declarative

Let's use an example to illustrate the difference between **procedural** and **declarative** approaches. In this example, you need to create a new virtual machine and a database, and configure the firewall rules to allow access from the virtual machine to the database. In a **procedural** approach, you would create a script with the following steps (pseudo code):

```csharp
create-virtual-machine --name "my server" --cpu 8 --mem 16 --disk 50
create-database --name "my db" --cpu 8 --mem 16 --disk 50
create-firewall --name "database firewall"
create-firewall-rull --name "allow db access from vm" --port 3306 --protocol tcp --source <ip of vm>
```

This script can be run once, and if you need to make any changes, you will need to modify it or write a new script. Repeatedly running this script won't work because it will attempt to create brand new resources and not manage the existing ones. The commands need to be run in a certain order, or you will encounter errors. For example, you will not be able to create the firewall rule before the VM exists. If you need to change the name, you can't run the same command, and instead need to add `update-virtual-machine --machine-id XYZ --name "My new servers"`. With **declarative**, you can approach it by specifying what you need, and leave it up to the tool to decide how to do that. Compare the above **procedural** example to the below **declarative** example (pseudo code):

```csharp
virtual-machine: { name: "my server", cpu: 8, mem: 8, disk: 50 }
database: { name: "my db", cpu: 8, mem: 8, disk: 50 }
firewall: { name: "database firewall", rules: [ { name: "allow db access from vm", port: 3306, protocol: tcp, source: virtual-machine.IP } ] }
```

The **declarative** tool you use will create the resources you declared, without needing to specify the order. Additionally, if you need to change the VM name, you can just update the name variable and rerun it. It will then determine what changes are needed to get you to the desired state you declared.

## Core concepts and why they’re important

As someone applying concepts from DevOps, you will work in a number of different places throughout your stack. You may at times work directly in the source code, networking, security, data, the testing framework, or anywhere in between due to the nature of cross-team collaboration that comes with the domain. Now that we’ve discussed getting started and some approaches, let’s cover some key concepts, their benefits, and examples of tools you will use to implement them.

### Infrastructure as Code

Infrastructure as Code (IaC) is typically a declarative method of managing infrastructure in a way that treats your infrastructure components, such as physical servers and virtual machines, similar to application code. Depending on the tool you choose, you can describe them using a markup language ([YAML](https://yaml.org/), [HCL](https://pkg.go.dev/github.com/hashicorp/hcl/v2), or [TOML](https://toml.io/en/)), or a more general-purpose language ([Python](https://www.python.org/), [Go](https://go.dev/), or [Java](https://www.java.com/en/)), which is then stored in version control allowing us to manage it in a repeatable and automated way. Infrastructure as code allows us to apply the same best practices and procedures we use when developing application code to our infrastructure. Configuration files can be tested and versioned and changes to infrastructure can be made using the same processes as code changes. If something goes wrong, we can roll back to the last stable version. This can help to reduce errors and improve reliability. Additionally, IaC makes it easier to scale and manage infrastructure, especially in dynamic environments where infrastructure needs to change frequently. Some of the tools you might use for provisioning infrastructure are [HashiCorp’s Terraform](https://www.terraform.io/), [AWS CDK](https://docs.aws.amazon.com/cdk/v2/guide/home.html), or [AWS CloudFormation](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/Welcome.html). 

### Configuration management

Configuration management (CM) allows us to maintain systems in a desired state by organizing and maintaining information about our hardware and software. Think of a file that lists information such as which operating system to use, which software and their versions to install on a device, or the settings and configurations that will be applied to the system. In the past, this may have been done manually, or with a procedural script that connected to a repository and installed each tool one at a time, stopping at the first issue. CM helps build visibility and streamlines the configuration process, which makes it easier to track and manage changes over time with the goal of reducing cost, complexity, and errors. Some examples of configuration management tools are [Ansible](https://www.ansible.com/), [Chef](https://www.chef.io/), and [Puppet](www.puppet.com).

### Secrets management

Secrets management allows us to securely organize and maintain information for our applications by storing, managing, and distributing sensitive information such as passwords, API keys, and cryptographic keys. It is an important aspect of security and compliance, as it helps to ensure that sensitive information is stored and transmitted in a secure manner, and that it is only accessed through code and authorized procedures. Some examples of Secrets Management tools are [HashiCorp Vault](https://www.vaultproject.io/), [AWS Secrets Manager](https://docs.aws.amazon.com/secretsmanager/latest/userguide/intro.html), and [AWS Key Management Service](https://docs.aws.amazon.com/kms/latest/developerguide/overview.html).

### Containers

Containers are a way of packaging and running applications in a consistent, lightweight, and portable manner so they can be run on a developer's laptop, a test server, or in a production environment. The application, and it's dependencies, are packaged together into a container image which ensures the application will run consistently whether it's on your laptop, test server, or in a production environment, which makes it easier to develop, test, and deploy. Not only does this help build reliability, it also simplifies the operational overhead of running software as it provides a standardized way to build, test, deploy, and run it. The most common containerization tool you'll see is [Docker](https://www.docker.com/).

### Container orchestration

As your environment scales, you’ll discover that you need a way to manage your containers, including their lifecycle, scaling, networking, load balancing, persistent storage, and more. Orchestration can help you with more complex tasks such as making the most of your resources, providing high availability for your services by automatically restarting containers that fail, distributing them across multiple hosts, and providing a way to schedule and deploy your services. Some popular container orchestration tools include [Kubernetes](https://kubernetes.io/), [Amazon EKS](https://docs.aws.amazon.com/eks/latest/userguide/what-is-eks.html), [Docker Swarm](https://docs.docker.com/engine/swarm/), [Amazon ECS](https://docs.aws.amazon.com/ecs/index.html), and [HashiCorp Nomad](https://www.nomadproject.io/). 

### Continuous integration and continuous delivery

You’re likely to hear the terms "CI/CD" and "pipelines" a lot throughout your DevOps journey. *Continuous integration (CI)* is a practice where developers regularly merge their code changes into a shared code repository, and then use automated processes to build, test, and validate the code. The goal is to detect and fix integration problems as early as possible by ensuring the testing process is repeatable and consistent. This builds trust in the process and allows developers to more easily collaborate and work on the codebase without causing conflicts or breaking the build.

*Continuous delivery (CD)* is a practice where code changes are automatically built, tested, and deployed to a test environment for additional testing and bug hunting prior to pushing to production. Similarly to **CI**, the goal of **CD** is to create a repeatable process that enables rapid, reliable, and low-risk delivery of software updates. Unlike **CI**, it takes it a step further by automatically deploying the code to an environment. Typically the code is tested and then run through manually gated processes and checks before being approved and released to production.

*Continuous deployment*, also commonly abbreviated to CD, is often (and understandably) confused with continuous delivery. While it sounds similar, continuous deployment is a different practice. Just like **CI/CD**, **continuous deployment** is an automated and repeatable process intended to enable faster and more reliable production deployments. The main difference is that continuous deployments run automatically all the way from code commit to releasing and deploying the software to production without manual intervention. The only way a new code change would not be deployed is via a failed test in the pipeline.

These practices can help to improve the speed and quality of software development by allowing for fast feedback and reducing manual gates and time spent waiting. This can help to reduce the time required to deliver new features and improvements to users, and can make it easier to iterate and evolve software over time.

Pipelines built using these concepts can apply to a number of things including application code, infrastructure code, security checks, and more. They can exist as a single pipeline, or possibly as multiple pipelines that are chained together. 

### Logging

Logging is the process of recording messages and events generated by an application or the services it uses to run. These logs can provide valuable information, including error messages, performance data, and user activity. They’re helpful for debugging your code, monitoring the performance and the behavior of your application, auditing for security incidents, and more. Common features for logs include the ability to log messages at different levels of severity, searching or filtering through logs, and being able to send logs to external storage or analysis systems. Examples of logging tools are the  [Elastic Stack](https://www.elastic.co/elastic-stack/), [Splunk](https://www.splunk.com/), and [Loki](https://grafana.com/oss/loki/).  

### Monitoring

Monitoring is the process of tracking the performance, availability, and other aspects of a system or component. It involves collecting data and analyzing that data to identify problems or trends. It can be used to help detect and fix problems, improve performance by highlighting constraints or other issues, and to track resource usage to better plan for future capacity needs. Monitoring is commonly used to track important events and metrics related to applications, networks, infrastructure, or business metrics like number of sign-ups, transactions processed, and more. Examples of application or infrastructure monitoring tools include [Amazon CloudWatch](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/WhatIsCloudWatch.html), [OpenTelemetry](https://opentelemetry.io/), [Prometheus](https://prometheus.io/), [Grafana](https://grafana.com/), and [Datadog](https://www.datadoghq.com/).

### Tracing

Tracing is often used in distributed systems to allow seeing the flow of a user action or request through multiple, different systems inside the distributed system. It is easier to describe it using an example. Let's say you have a distributed system where a user is logged in via the `Login` system, which makes a call to the `Fraud` system, as well as the `Loyalty Program` system in a fictional e-commerce site. To be able to see the entire action, you would need to somehow combine the logs from all three systems in sequential order to get the full view of what occurred. Tracing allows you to do this, usually by adding a tracing ID to each call that is the same to make it easier to collate these disparate logs. Examples of tracing frameworks include [Jaeger](https://www.jaegertracing.io/), [ZipKin](https://zipkin.io/), some of the previously mentioned commercial offerings, like [Splunk](https://www.splunk.com/), and [Datadog](https://www.datadoghq.com/).

### Observability

Observability is a practice that focuses on understanding your system's current state through the various kinds of data it generates. It's the next logical step after implementing **Logging**, **Monitoring**, and **Tracing** - the three pillars of observability are metrics, traces and logs. Plenty of the companies who are listed for logging and monitoring also have observability offerings. The most prominent one not already mentioned in this guide is [Honeycomb](https://www.honeycomb.io).

If you'd like to try out some of the concepts introduced in this section, check out our [hands-on tutorial showing how to implement OpenTelemetry in a Java application.](https://www.buildon.aws/posts/instrumenting-java-apps-using-opentelemetry/)

## Where should I start?

As mentioned earlier, you should use these questions to find the best place to start:

1. Where is there a bottleneck or pain point for the team(s) that they are struggling with?
2. What services or piece of infrastructure can you work on that is not mission critical?
3. What things would benefit the most from being automated?

Once you have found a place to start, you can decide which of the following approaches to use: automate the creation of infrastructure with IaC, add an automated build to a software project (CI), implement automated deployment (CD), containerize an application, add some monitoring, or configuration and secret management.

## Wrap Up

We've learned a lot in this post today! We started with an introduction to what DevOps is and how to get started, discussed different patterns you'll encounter when automating your processes and gave an overview of the key concepts you'll encounter on your journey. It's not possible to become an expert on every DevOps concept in a post or a day, but if you continuously learn and iterate on your culture, processes and technology you'll be surprised at how quickly you'll be able to make an impact. You and your team are not alone in this journey - there's been over a decade of other teams learning and documenting their successes and challenges. Stay tuned for more DevOps content! You can also find additional resources below.

### Additional Resources

You can find other articles on BuildOn about DevOps using the DevOps tag. If community based learning is your thing, you should definitely look for one near you, there are a variety of DevOps meetups run around the globe!

**Conferences:**

* [DevOpsDays](https://devopsdays.org/)
* If you're looking to learn more specifically about AWS & our tools, we have lots of options! These aren't specific to DevOps but often have talks or tracks that are related to it. We have [re:Invent](https://reinvent.awsevents.com/) every year. There are multiple [AWS Summits](https://aws.amazon.com/events/summits/) every year, have a look to see if one is in a city close to you. If you are just getting started with cloud, we recommend attending an [AWSome Day](https://aws.amazon.com/events/awsome-day/) and reading our [AWS Cloud Essentials](https://aws.amazon.com/getting-started/cloud-essentials/) page.
* Many of the vendors mentioned run their own conferences and those can be a great place to learn as well!

**Books:**

* [DevOps Handbook](https://www.goodreads.com/book/show/26083308-the-devops-handbook)
* [Phoenix Project](https://www.goodreads.com/book/show/17255186-the-phoenix-project)
* [Accelerate: Building and Scaling High Performing Technology Organizations](https://www.goodreads.com/book/show/35747076-accelerate)
* [DevOps For Dummies](https://www.goodreads.com/book/show/50128575-devops-for-dummies)

**Online Learning:**

* [DevOps Roadmap](https://roadmap.sh/devops)
* [90 Days of DevOps](https://github.com/MichaelCade/90DaysOfDevOps)
* [A Cloud Guru - AWS DevOps](https://acloudguru.com/learning-paths/aws-devops)
* [2022 State of DevOps Report](https://cloud.google.com/devops/state-of-devops/)
