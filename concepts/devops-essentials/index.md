---
title: DevOps Essentials  
description: An essential guide for learning about DevOps and its core concepts. 
tags:
  - devops
  - essentials
  - aws
authorGithubAlias: gogococo 
authorName: Jacquie Grindrod
date: 2023-01-12
---


This guide is intended for beginners who are looking for an overview of what DevOps is and an introduction to the core concepts they should be aware of. You’ve probably landed here because you’re looking to learn more about it and how you can apply this knowledge to the problems you are facing. You can think of this post as a guidepost to help you find your location and the direction you’re going next. This guide will not sell you products, platforms or tools as solutions to those problems. There is no one size fits all solution, however there are existing patterns, frameworks, and mechanisms that have been tested and iterated upon which you can leverage. Feel free to read this post from start to finish or to skip to sections that you're most interested in, whichever works best for you!


| Sections                                                                       |
|--------------------------------------------------------------------------------|
| 1. [What Is DevOps?](#what-is-devops)                                          |
| 2. [Getting Started](#getting-started)                                         |
| 3. [Implementation Approaches](#implementation-approaches)                     |
| 4. [Infrastructure as Code](#infrastructure-as-code)                           |
| 5. [Configuration Management](#configuration-management)                       |
| 6. [Containers](#containers)                                                   |
| 7. [Container Orchestration](#container-orchestration)                         |
| 8. [CI/CD](#continuous-integration-and-continuous-delivery)                    |
| 9. [Logging](#Logging)                                                         |
| 10. [Monitoring](#Monitoring)                                                  |
| 11. [Wrap Up](#wrap-up)                                                        |
| 12. [Additional Learning Resources](#resources)                                |


## What is DevOps?

The term DevOps was coined in 2009 by [Patrick Debois](https://twitter.com/patrickdebois) and is a combination of practices from both software development (Dev) and information-technology operations (Ops). At its core, DevOps is an approach to solving problems collaboratively. It values teamwork and communication, fast feedback and iteration, and removing friction or waste through automation. It became popular because it encouraged teams to break their work down into smaller chunks and approach product delivery collaboratively with a holistic view of the product enabling better team transparency and quicker, more reliable deployments. While it’s important to note that DevOps consists of a combination of People, Process & Tooling, there’s a couple of common areas that we work in to help accomplish our goals. If you’d like to learn more about the context of DevOps, common frameworks and team topologies you can find that information in DevOps Foundations. 

## Getting Started

In this section we’ll cover concepts such as how to decide where to start and different approaches to begin! As you’re getting started, it’s important to note that there’s no step that’s too small to count towards progress. You don’t need to dive 100% in - in fact, it’s probably better not to! At the beginning, you want to minimize risk and friction by taking on smaller actions and getting fast feedback. Then you’ll continue to improve by making small, iterative changes and building momentum. Another way to find a good starting place is by talking to the teams who will depend on your work - are there manual steps they’re taking that lead to wasted time or bottlenecks? Do they have a wish list for how they’d like to be deploying or testing their work? Sometimes, the easiest place to start is the one you already know you need. You’ve decided to make small iterative changes, but how we approach that is also important! There’s multiple ways to build out infrastructure, and each comes with different benefits and challenges. 

## Implementation Approaches

### *ClickOps*

Using the browser based console for tools like AWS can be a great way to explore which services are available to you and how they fit together, but doesn’t scale well as it’s not transparent or easy to collaborate with others and opens you up to creating more manual mistakes. 

### *Procedural* models 

These are a series of steps completed in order to finish a task. This approach tells the computer what to do, step by step, and the computer executes the instructions in the order that they are written. An example of a procedural script might be a script that backs up a database by connecting to the database, exporting the data to a file, and then copying the file to a backup location.

### *Declarative* models 

Describes the desired end state of a system, rather than specifying the steps needed to get there. The computer is responsible for determining the steps needed to achieve the desired state. An example of a declarative script might be a configuration file that specifies the desired settings for a system, such as the packages that should be installed, the users that should be created, and the network configuration.

These are listed in order from minimal complexity and shorter term gains vs higher complexity and longer term gains. It’s typically easier to explore and create something quickly by following browser based wizards or using an existing CLI command but it’s harder to scale and maintain as your team or system grows. It’s totally ok to start higher up on the list and work your way down and it’s up to you to assess the trade offs and decide which fits your team best at the moment. 

## Core Concepts & Why They’re Important!

As someone applying concepts from DevOps, you will work in a number of different places throughout your stack. You may at times work directly in the source code, networking, security, data, the testing framework, or anywhere in-between due to the nature of cross team collaboration that comes with the domain. Now that we’ve discussed getting started and some approaches let’s cover some key concepts, their benefits, and examples of tools you’ll use to implement them. 

### Infrastructure As Code
Infrastructure as code (IaC) is a method of managing infrastructure in a way that treats your infrastructure components such as physical servers and virtual machines similarly to application code. You describe them using a configuration language (such as yaml, HCL or toml), which is then stored in version control allowing us to manage it in a repeatable and automated way. Configuration files can be tested and reviewed and changes to infrastructure can be made using the same processes as code changes. This can help to reduce errors and improve reliability. Additionally, IaC makes it easier to scale and manage infrastructure, especially in dynamic environments where infrastructure needs to change frequently. Some of the tools you might use for provisioning infrastructure are HashiCorp’s [Terraform](https://www.terraform.io/), [AWS CDK](https://docs.aws.amazon.com/cdk/v2/guide/home.html), or [CloudFormation](https://aws.amazon.com/cloudformation/). 

### Configuration  Management 
Configuration Management (CM) allows us to maintain systems in a desired state by organizing and maintaining information about our hardware and software. This includes information such as the version of an operating system, the software installed on a device, or the settings and configurations that have been applied to the system. They help automate and streamline configuration management processes which makes it easier to track and manage changes over time with the goal of reducing cost, complexity and errors. Some examples of Configuration Management tools are [Ansible](https://www.ansible.com/), [Chef](https://www.chef.io/), and [Puppet](www.puppet.com). 

### Secrets Management
Secrets management allows us to securely organize and maintain information for our applications by storing, managing, and distributing sensitive information such as passwords, API keys, and cryptographic keys. It is an important aspect of security and compliance, as it helps to ensure that sensitive information is stored and transmitted in a secure manner, and that it is only accessed by authorized users. Some examples of Secrets Management tools are [HashiCorp Vault](https://www.vaultproject.io/) or [AWS Secrets Manager](https://aws.amazon.com/secrets-manager/), [AWS Key Management Service](https://aws.amazon.com/kms/)

### Containers
Containers are a way of packaging and running applications in a consistent, lightweight and portable manner so they can be run on a developer's laptop, a test server, or in a production environment. The application and it's dependencies are packaged together into a container image which ensures the application will run consistently regardless of the external environment which makes it easier to develop, test and deploy. The most common containerization tool you'll see is [Docker](https://www.docker.com/).

### Container Orchestration
As your environment scales you’ll discover that you need a way to manage the operational overhead of containers including things like managing their lifecycle, scaling, networking, load balancing, persistent storage and more. Orchestration can also help you with more complex tasks such as making the most of your resources,  providing high availability for your services by doing things like automatically restarting containers that fail and distributing them across multiple hosts, and providing a way to schedule and deploy your services. Some popular container orchestration tools include [Kubernetes](https://kubernetes.io/) or [Amazon EKS](https://aws.amazon.com/eks/), [Docker Swarm](https://docs.docker.com/engine/swarm/), and [HashiCorp Nomad](https://www.nomadproject.io/). 

### Continuous Integration and Continuous Delivery
You’re likely to hear the terms CI/CD and Pipelines a lot throughout your DevOps journey. 
*Continuous integration (CI)* is a practice where developers regularly merge their code changes into a shared code repository, and automated processes are then used to build, test, and validate the code. The goal of CI is to detect and fix integration problems as early as possible, so that developers can more easily collaborate and work on the codebase without causing conflicts or breaking the build.

*Continuous delivery (CD)* is a software development practice in which code changes are automatically built, tested, and deployed to production. The goal of CD is to enable rapid, reliable, and low-risk delivery of software updates, by automating the build, test, and deployment process.

Together, CI and CD can help to improve the speed and quality of software development by reducing manual gates and time spent waiting and giving fast feedback. This can help to reduce the time required to deliver new features and improvements to users, and can make it easier to iterate and evolve software over time.

Pipelines built using these concepts can apply to a number of things including application code, infrastructure code, security checks and more. They can exist as a single pipeline, or possibly as multiple pipelines that are chained together. 

### Logging
Logging is the process of recording messages and events generated by an application or the services it uses to run. These logs can provide valuable information including error messages, performance data, and user activity. They’re helpful for debugging your code, monitoring the performance and the behaviour of your application, auditing for security incidents or more! Common features for logs include the ability to log messages at different levels of severity, searching or filtering through logs and being able to send logs to external storage or analysis systems. Examples of logging tools are the [Elastic Stack](https://www.elastic.co/elastic-stack/), [Splunk](https://www.splunk.com/), [Loki](https://grafana.com/oss/loki/).  

### Monitoring
Monitoring is the process of tracking the performance, availability, and other aspects of a system or component. It involves collecting data and analyzing that data to identify problems or trends. It can be used to help detect and fix problems, improve the performance by highlighting constraints or other issues and with tracking resource utilization to better plan for future capacity needs. There’s a variety of ways monitoring is used including application monitoring, network monitoring and infrastructure monitoring. Examples of application or infrastructure monitoring tools you may encounter include [Amazon CloudWatch](https://aws.amazon.com/cloudwatch/), [OpenTelemetry](https://opentelemetry.io/), [Jaeger](https://www.jaegertracing.io/),  [Prometheus](https://prometheus.io/), [Grafana](https://grafana.com/) and [Datadog](https://www.datadoghq.com/). 


## Wrap Up
It's not possible to learn every DevOps concept in a post or a day, but if you continuously learn and iterate on your culture, processes and technology, and work on your gaps and pain points you'll be surprised at how quickly you'll be able to make a big difference. You and your team are not alone in this journey - there's been over a decade of other teams learning and documenting their successes and challenges. This piece will continue to be updated with references to other DevOps articles we release. You can also find additional resources below. 

### Resources

You can find other articles on BuildOn about DevOps here using the DevOps tag. There's a variety of DevOps meetups run around the globe. If community based learning is your thing, you should definitely look for one near you! 

Conferences: 
* [DevOpsDays](https://devopsdays.org/)
* We have re:Invent every year and many of the vendors mentioned run their own conferences and those can be a great place to learn as well! We have [re:Invent](https://reinvent.awsevents.com/) as well as multiple [AWS Summits](https://aws.amazon.com/events/summits/) every year. 

Books:
* [DevOps Handbook](https://www.goodreads.com/book/show/26083308-the-devops-handbook)
* [Phoenix Project](https://www.goodreads.com/book/show/17255186-the-phoenix-project)
* [Accelerate: Building and Scaling High Performing Technology Organizations](https://www.goodreads.com/book/show/35747076-accelerate)
* [DevOps For Dummies](https://www.goodreads.com/book/show/50128575-devops-for-dummies)

Online Learning
* [DevOps Roadmap](https://roadmap.sh/devops)
* [99 Days of DevOps](https://github.com/MichaelCade/90DaysOfDevOps)
* [A Cloud Guru - AWS DevOps](https://acloudguru.com/learning-paths/aws-devops)
* [2022 State of DevOps Report](https://cloud.google.com/devops/state-of-devops/)

