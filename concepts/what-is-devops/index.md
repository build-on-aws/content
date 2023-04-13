---
title: What is DevOps?
description: An essential guide for learning what DevOps is and it’s core concepts. 
tags:
  - devops
  - foundational
  - aws
authorGithubAlias: gogococo 
authorName: Jacquie Grindrod
date: 2023-04-01
---

What is DevOps? Is it a tool? Is it a kind of agile process like Scrum or Kanban? Does deploying to Kubernetes mean we are doing DevOps? Where does it start and when have we reached the end?

The short answer: it’s complicated. 

A lot of people have [wrong ideas about DevOps](https://www.buildon.aws/posts/devops-wrong-answers-only), but this definition [from AWS](https://aws.amazon.com/devops/what-is-devops/) is one of the best I’ve seen: "DevOps is the combination of cultural philosophies, practices, and tools that increases an organization’s ability to deliver applications and services at high velocity: evolving and improving products at a faster pace than organizations using traditional software development and infrastructure management processes." 

DevOps is about people and processes - and how to bring them together to accelerate the pace of innovation. By the end of this post, you should have a better understanding of what DevOps is (and isn't), its history, and how it can be applied today.


| ToC |
| --- |

## What Is Not DevOps

Before we dive into what DevOps is, let's touch on what it's not. DevOps is not a silver-bullet solution for all of your problems. It's not a product, tool, or solution you can purchase and forget. DevOps is not a solo engineer who catches all the glue work; neither is it a superficial change to the job titles of your developers. Even embracing Agile or Scrum processes - though they can potentially support you on your DevOps journey - will not solve your DevOps problem for you.

DevOps is bigger than all these things. So let's take a look at how it emerged.

## A Bit Of History

The history of modern manufacturing goes back centuries, but a few innovations in the 20th century played an outsized role in shaping the development and deployment of technology. Here’s a brief overview of some key moments that laid the foundations for contemporary implementations of DevOps.

### *Waterfall* Methodology

In the early days of software development, teams approached product development in much the same way they did for hardware. Development basically looked like 6-month stretches of building, followed by big-bang deployments. Practically, this approach, called the Waterfall methodology, consisted of 5 phases:

1. Requirements
2. Design
3. Implementation
4. Verification
5. Maintenance

Waterfall development made sense in some contexts: before the rise of the internet, fixing bugs after deployment was unrealistic, and in some contexts, like the aerospace industry, small mistakes could cause loss of life - which made a high level of pre-deployment precision vital.

When applied in software, though, the Waterfall methodology came with problems. It often meant large quantities of work would accumulate over time and eventually culminate in one mega-deployment. Then the teams went back to work for another long delivery cycle. Not only would this result in more bugs at release - it also made addressing those bugs quickly extremely difficult, if not impossible. Just imagine learning that the feature set you spent six months building is missing a critical feature, and the next release is another six months away.

The single points of failure encountered along the way, and friction involved in developing under the waterfall methodology set the stage for a DevOps classic: [The Phoenix Project](https://www.goodreads.com/book/show/17255186-the-phoenix-project).

### *Lean Manufacturing* and *Kanban*

In 1953, Toyota implemented something called Lean Manufacturing, using the Kanban system. Kanban was created as a way to minimize waste by focusing on producing only what was needed, when it was needed, and in the quantity that was needed. You might be familiar with the Kanban board, on which complex projects move through a series of stages. This segmentation brings clarity to the larger process, and it enables teams to monitor and address gluts forming in certain stages.

The underlying goal of Kanban was to reduce seven common wastes:

1. **Overproduction** - Producing ahead of what is required by the process or customer. It contributes to the rest of the wastes.
2. **Waiting** - Time spent waiting with machines or operators idle due to missing parts or equipment failures.
3. **Transporting** - Moving the products or pieces when it's not needed such as changing warehouses to complete the next step when they could have been located together.
4. **Processing** - Waste through unnecessary or wrong processing often due to poor tool or product design.
5. **Inventory** - Having an excess of inventory on hand
6. **Motion** - Making movements that aren't productively contributing such as looking for parts, tools, or documents.
7. **Defects** - When the product is created incorrectly and inspection, rework, and scrapping is required.

But if this approach to manufacturing predated the Waterfall methodology, why didn’t it address some of the problems in it? Well, Lean Manufacturing didn’t reach American software development processes until the 1980s and '90s. And that set the stage for the eventual rise of DevOps itself.

This is just a quick summary of Lean Manufacturing, but you can go directly to the source to learn more with [The Toyota Way to Lean Leadership](https://www.goodreads.com/en/book/show/11722275), or dig more into Lean in software with [The Lean Startup](https://www.goodreads.com/en/book/show/10127019).

### *DevOps*

The term DevOps was coined in 2009 by [Patrick Debois](https://twitter.com/patrickdebois) and is a combination of practices from both software development (Dev) and information-technology operations (Ops).

It addressed some of the problems of the Waterfall methodology, implemented some of the structural strategies of Lean Manufacturing, and created something all its own.

## What Is DevOps?

At its core, DevOps is an approach to solving problems collaboratively. It values teamwork and communication, fast feedback and iteration, and removing friction or waste through automation. It became popular because it encouraged teams to break their work down into smaller chunks, and approach product delivery collaboratively, with a holistic view of the product, enabling better team transparency, and quicker, more reliable deployments. Kanban was only one of many ways this could practically look.

DevOps consists of a combination of practices including Culture, Process, and Tooling. While it’s important to note that implementing DevOps practices is more than simply adding a pipeline or using containers, these, and others strategies, are common technical areas that we work in to help accomplish our goals. If you’d like to learn more about those technical areas, you can find that information in [DevOps Essentials](/concepts/devops-essentials/).

Check out this talk from DevOpsDays Cape Town 2016 [What Is DevOps?](https://www.youtube.com/watch?v=kCRD4pNuh80) by [Dan Maher](https://speaking.dark.ca/).

https://www.youtube.com/watch?v=kCRD4pNuh80

Here are some of the frameworks for understanding and approaching DevOps in different contexts.

## The Three Pillars

This first framework comes from [The DevOps Handbook](https://www.goodreads.com/en/book/show/26083308), and you can see it in action in [The Phoenix Project](https://www.goodreads.com/book/show/17255186-the-phoenix-project). The DevOps Handbook focuses on 3 major pillars.

* **First Pillar** - Principles of Flow and Systems Thinking:
The first pillar focuses on the performance of the entire system, as an individual team's success doesn't matter if the organization as a whole fails to deliver. To begin, we focus on creating a culture of continuous improvement and ensuring that work flows smoothly and efficiently throughout the entire value stream: from development, to operations, to customer feedback, and then back again. This involves optimizing processes, breaking work into smaller chunks, and reducing friction at each stage to enable fast and reliable delivery of high quality products.

* **Second Pillar** - Principles of Feedback and Amplifying Feedback Loop:
The second pillar emphasizes the importance of getting fast and actionable feedback at all stages of the development process to constantly iterate and improve using feedback loops and team collaboration. This involves fostering a culture of experimentation and learning, where feedback from customers and stakeholders is used to inform decisions and drive continuous improvement. Teams work together to identify and resolve issues as quickly as possible, and prioritize transparency and communication to promote collaboration and knowledge sharing.
  
* **Third Way** - Principles of Continuous Experimentation and Learning:
The third pillar focuses on creating a culture of continual learning and experimentation, where teams are encouraged to take risks and innovate in order to drive continuous improvement. Exploration and discovery are just as important as being open to making mistakes and failures. This involves fostering a culture of innovation and experimentation, where teams are empowered to try new ideas and learn from both successes and failures. Organizations should also prioritize the use of data and analytics to inform decision making, and should invest in ongoing training and development to promote a culture of learning and growth.

The idea is that by focusing on these three pillars, organizations can drive better business outcomes and value for our customers. The DevOps Handbook provides detailed guidance on how to bring these principles to life. As we’ve continued to iterate on the concept of DevOps itself, we've continued to create other frameworks to inform and measure our success at DevOps.

## CALMS

CALMS is a framework that represents the five key components crucial for implementing DevOps practices successfully, and it can help teams identify areas for improvement to efficiently prioritize their time and effort.

* **Culture** - DevOps is a people-first approach, so it makes sense that culture is the first point covered. It's about more than just implementing tools and processes; it's about creating a collaborative culture which emphasizes communication, trust, and shared goals. This culture is a relationship between how people communicate and how they expect to be communicated with. It focuses on bridging the distance between different departments, encouraging knowledge sharing, and creating a shared sense of ownership and accountability. The people and their needs drive the processes and tools, not the other way around.

* **Automation** - Teams are empowered to work more efficiently and deliver higher quality products more quickly when they are freed from repetitive and mundane tasks. Leverage tools and technology to seek out ways to automate as many tasks as possible that the team is comfortable with. This uses the strength of machines to quickly compute, repetitively deliver, or perform other similar tasks, while allowing the people to excel in creative or complex tasks that push the business forward.

* **Lean** - The Lean principle emphasizes the value of minimizing waste and focusing on delivering. When we speak about DevOps, this means optimizing processes and workflows to find bottlenecks, and reduce the time it takes to deliver, while also prioritizing feedback. Teams can do this by visualizing their work in progress, limiting batch sizes and managing queue lengths. One way to do this is by adoption Scrum or Kanban.

* **Measurement** - In order to continuously improve and optimize the teams' processes, you need to be able to measure and track metrics related to your development, delivery, and performance. Data is collected, and there are mechanisms in place that provide visibility into all systems, which can involve tools like monitoring or observability based software to help generate insights which inform decision making. All systems is important here. Measuring our technical systems is important but so are Key Performance Indicators (KPIs). Those are the raw numbers which make up the framework of the company and illustrate it's success or failure. There's a story to be told between the infrastructure your application lives on and the actions your organization is taking.

* **Sharing** - Information gathered is powerless until it is shared. Within and between teams, knowledge sharing improves the overall performance of the organization and can consist of sharing best practices, lessons learned, or other information. There are user-friendly communication channels that encourage ongoing communication between development and operations. Create platforms, or processes, such as feedback cycles, as information sharing is one of the strongest ways to break down silos. Bring people from different teams and perspectives in earlier to avoid making mistakes based on poor data or assumptions.

These are the essential ingredients to DevOps success. If you automate everything without measuring or sharing, there's no way to validate if it's working as intended. If you measure without automation, it's difficult to validate that it was exactly the same, and that your results are correct. This level of execution requires a top-down buy in to accomplish as an individual cannot own or drive this level of organization process. That's not to say an individual can't move the needle, just that you can't be the sole owner. Internal DevOps advocacy has its place in building momentum, knowledge sharing, and helping to drive change.

So what do healthy DevOps organizations look like?

## Team Topologies

You’ve probably heard lots of different terms, roles, or team names for DevOps - traditionally infrastructure problems were solved by System Administrators, but more recently, you may also have heard about Platform Engineering or Site Reliability Engineering. It’s my opinion that all of these roles fall under the same umbrella but may have different approaches, organizational structures, or perspectives on how to solve their problems.

Some of the common team patterns you'll encounter:

* **Functional Teams**: Teams are organized by their function such as development, testing, and operations. Each one is responsible for a particular part of the software development lifecycle and functions independently from the others often by handing off the product and ticket to the next team in the cycle.

* **Feature Teams**: These teams are cross-functional teams that work together to deliver a specific feature or component of the product.

* **Service Teams**: Teams are responsible for specific parts of the software infrastructure or platform, such as networking or database management. Typically they receive tickets to create the service for the Development teams before handing it off.

* **Platform Teams**: These teams provide and maintain the underlying platform or infrastructure which supports the software development and delivery process. A key component of Platform teams is that they typically provide the ability for developers to self-service to spin up stable and compliant services or infrastructure through tools or platforms.

First and foremost, the best team structure is the one that works in your environment, targeting the specific needs and goals of your organization. No matter which team structure you have, the key is to optimize communication and cross-team collaboration. Across all the models and patterns, the most common red flag is if silos still exist between your development and operations teams. Whichever model you're using, if there isn't open collaboration between the teams, then it isn't DevOps. Their goals and KPIs should also be aligned: in the past, operations teams were incentivized to keep the system running and stable, while developers were measured by the number of features they shipped. Such incentives worked at cross-purposes: operations wanted as few changes to production as possible, and developers want as many - but the developers didn't have to deal with outages.

Team Topologies describe the different patterns of organizing teams for optimizing the flow of work and communication across an organization. While we've talked above about some of the different setups for teams, there's also different ways for them to collaborate and engage. If you're interested in diving more deeply into the patterns and anti-patterns of DevOps teams, you can learn more here: [DevOps Topologies](https://web.devopstopologies.com/).

A DevOps practitioner or engineer is not a specific kind of coder. This is fantastic news because it means anyone can do it. While you can't do "the DevOps" alone, you can be responsible for shepherding and advocating DevOps principles and gaining momentum within your organization.

## Getting Started
<!-- (Nice place to link to the post on "Good Places to Start Your DevOps Journey" article.) -->

So how do we know where to start and when we've reached our goals?

As you’re getting started, it’s important to note that there’s no step that’s too small to count toward progress. You don’t need to dive all the way in: in fact, it’s probably better not to! At the beginning, you want to minimize risk and friction by taking on smaller actions and getting fast feedback. Then you will continue to improve by making small, iterative changes and building momentum.

Another way to find a good starting place is by talking to the teams you collaborate with and who depend on your work. Are there manual steps they’re taking that lead to wasted time or bottlenecks? Do they have a wish list for how they’d like to be deploying or testing their work? Sometimes the easiest place to start is the one you already know you need. You’ve decided to make small, iterative changes, but how you approach those changes can be as important as which changes you implement. There are multiple ways to build out infrastructure, and each comes with different benefits and challenges.

So what kind of areas do we tend to work in when we are solving problems from a DevOps perspective? We've covered the day-to-day technical concepts from the DevOps Toolchain that you can expect to encounter in [DevOps Essentials](/concepts/devops-essentials).

## Wrap Up

It's not possible to learn every DevOps concept from a single post or in a single day, but if you continuously learn and iterate on your culture, processes, and technology - and work on your gaps and pain points - you'll be surprised at how quickly you're able to make a big difference. You and your team are not alone in this journey; there's been over a decade of other teams learning and documenting their successes and challenges. This piece will continue to be updated with references to other DevOps articles we release. You can also find additional resources below.

### Resources

You can find other articles on [BuildOn.AWS](https://buildon.aws) about DevOps using the [DevOps](https://www.buildon.aws/tags/devops) tag. There's also a variety of DevOps meetups run around the globe. If community based learning is your thing, you should definitely look for one near you!

Conferences:

* [DevOpsDays](https://devopsdays.org/)

Books:

* [DevOps Handbook](https://www.goodreads.com/book/show/26083308-the-devops-handbook)
* [Phoenix Project](https://www.goodreads.com/book/show/17255186-the-phoenix-project)
* [Accelerate: Building and Scaling High Performing Technology Organizations](https://www.goodreads.com/book/show/35747076-accelerate)
* [DevOps For Dummies](https://www.goodreads.com/book/show/50128575-devops-for-dummies)

Online Learning:

* [DevOps Roadmap](https://roadmap.sh/devops)
* [99 Days of DevOps](https://github.com/MichaelCade/90DaysOfDevOps)
* [A Cloud Guru - AWS DevOps](https://acloudguru.com/learning-paths/aws-devops)
* [2022 State of DevOps Report](https://cloud.google.com/devops/state-of-devops/)
