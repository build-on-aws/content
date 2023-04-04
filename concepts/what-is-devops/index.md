---
title: What is DevOps 
description: An essential guide for learning about DevOps and it’s core concepts. 
tags:
  - devops
  - foundational
  - aws
authorGithubAlias: gogococo 
authorName: Jacquie Grindrod
date: 2023-04-01
---
So, what is DevOps? Is it a tool? Is it a kind of agile process like Scrum or Kanban? Does deploying to kubernetes mean we are doing DevOps? Where does it start and when have we reached the end?

This guide is for anyone looking to learn or refresh themselves on the fundamental concepts of DevOps and its principles. You’ve probably landed here because you’re looking to learn more about it and how you can apply this knowledge to the problems you are facing. This guide will not sell you products, platforms or tools as solutions to those problems. There is no one size fits all solution, however there are existing patterns, frameworks, and mechanisms that have been tested and iterated upon which you can leverage. The goal for this document is to cover core DevOps concepts to leave you with a better understanding of what DevOps is, where it came from and optional resources to support your learning journey and inspiration for your next pursuit. By the end of this article, you should have a better understanding of what DevOps is, the history of where it came from, and what it isn't. Feel free to read this post from start to finish or to skip to sections that you're most interested in, whichever works best for you! 



| ToC |
| --- |

## What Is Not DevOps
Before we dive into what DevOps *is*, let's touch on what it's *not*. DevOps is not a silver bullet solution for all of your problems. It is not a product, tool or solution you can buy and be done with. It also is not changing the name of an existing operations, system administrator or similar team and informing the rest of engineering that you now do the DevOps. It is not a solo engineer who catches all the glue work nor is it telling your developers that they've all been promoted to DevOps engineers and will now maintain the infrastructure too. This is a recipe for disaster. Adopting Agile or Scrum processes will not solve the DevOps problem for you. While embracing Agile or Scrum processes can potentially support you on your DevOps journey, they alone do not set you up to succeed. 

To learn more about what DevOps is not with a side of humor, check out [How to Succeed At DevOps: Wrong Answers Only!](https://www.buildon.aws/posts/devops-wrong-answers-only)

## A Bit Of History

### 1970 - *Waterfall* Methodology
Historically, software teams delivered their products utilizing the Waterfall methodology which was created in 1970 and is a model where requirements for the next 6 months are captured in business requirements documentation, and you build features for multiple months before doing a big-bang release. It consists of 5 phases:

1. Requirements
2. Design 
3. Implementation 
4. Verification 
5. Maitnenance 

It's a model intended for situations requiring a high degree of precision before implementing. Consider scenarios which require a high amount of scrutiny such as in the aerospace industry where mistakes could cause loss of life. 
In software, this often meant large quanities of work accumulated over time and were eventually released in one mega deployment before the teams went back to working for another long delivery cycle. Imagine taking months, or even *years* of your code and not knowing if it'll work until you finally get to deploy it? How do you manage all of the differences in the system? The untested changes?

The friction involved in developing under the waterfall methodology and the single points of failure encountered along the way set the stage for a DevOps classic: [The Phoenix Project](https://www.goodreads.com/book/show/17255186-the-phoenix-project)

So where did DevOps come from?

### 1953 - *Lean Manufacturing and Kanban*
Some might say that DevOps began almost 20 years prior to the creation of the waterfall methodology in 1953 with Toyota, Lean manufacturing and something you may have heard about before - the Kanban system. Kanban was created as a way to minimize waste by focusing on producing what is needed, when it's needed and in the amount that's needed. 

They did this by reducing the seven wastes:

1. Overproduction
2. Waiting
3. Transporting
4. Inappropriate Processing
5. Unnecessary Inventory
6. Unnecessary / Excess Motion
7. Defects 

This is just a quick summary of Lean Manufacturing but you can go directly to the source to learn more with [The Toyota Way to Lean Leadership](https://www.goodreads.com/en/book/show/11722275) or dig more into Lean in software with [The Lean Startup](https://www.goodreads.com/en/book/show/10127019)


### 2009 - *DevOps*
More recently, the term DevOps was coined in 2009 by [Patrick Debois](https://twitter.com/patrickdebois) and is a combination of practices from both software development (Dev) and information-technology operations (Ops).

But what does that mean? 


## What Is DevOps?
 At its core, DevOps is about the people behind the technology and is an approach to solving problems collaboratively. It values teamwork and communication, fast feedback and iteration, and removing friction or waste through automation. It became popular because it encouraged teams to break their work down into smaller chunks and approach product delivery collaboratively with a holistic view of the product enabling better team transparency and quicker, more reliable deployments. DevOps consists of a combination of practices including Culture, Process & Tooling. While it’s important to note that implementing DevOps practices is more than simply adding a pipeline or using containers, these and others are common technical areas that we work in to help accomplish our goals. If you’d like to learn more about those technical areas, you can find that information in [DevOps Essentials](https://www.buildon.aws/concepts/devops-essentials/). 

Check out this talk from DevOpsDays Cape Town 2016 [What Is DevOps?](https://www.youtube.com/watch?v=kCRD4pNuh80) by Dan Maher. 

## The Three Ways 

This first framework comes from [The DevOps Handbook](https://www.goodreads.com/en/book/show/26083308) and you can see it in action in [The Phoenix Project](https://www.goodreads.com/book/show/17255186-the-phoenix-project). 
The DevOps Handbook focuses on 3 major pillars.

* First Way - Principles of Flow and Systems Thinking:
The first way focuses on the performance of the entire system as one teams' success does not matter if the organization as a whole fails to deliver. To begin we focus on creating a culture of continuous improvement and ensuring that work flows smoothly and efficiently throughout the entire value stream, from development to operations to customer feedback and then back again. This involves optimizing processes, breaking work into smaller chunks and reducing friction at each stage to enable fast and reliable delviery of high quality products. 


* Second Way - Principles of Feedback and Amplifying Feedback Loop:
The second way emphasizes the importance of getting fast and actionable feedback at all stages of the development process to constantly iterate and improve using feedback loops and team collaboration. This involves fostering a culture of experimentation and learning, where feedback from customers and stakeholders is used to inform decisions and drive continuous improvement. Teams work together to identify and resolve issues as quickly as possible, and prioritize transparency and communication to promote collaboration and knowledge sharing.
  

* Third Way - Principles of Continuous Experimentation and Learning:  
The third way focuses on creating a culture of continual learning and experimentation, where teams are encouraged to take risks and innovate in order to drive continuous improvement. Exploration and discovery are just as important as being open to making mistakes and failures. This involves fostering a culture of innovation and experimentation, where teams are empowered to try new ideas and learn from both successes and failures. Organizations should also prioritize the use of data and analytics to inform decision-making, and should invest in ongoing training and development to promote a culture of learning and growth.

The idea is that by focusing on these three principles, organizations can drive bettter business outcomes and value for our customers. The DevOps Handbook provides detailed guidance on how to bring these principles to life. As we’ve continued to iterate on the concept of DevOps itself, we've continued to create other frameworks to inform and measure our success at DevOps. 

## CALMS
CALMS is a framework that represents the five key components crucial for implementing DevOps practices successfully and can help teams identify areas for improvement to efficiently prioritize their time and effort. 

* Culture - DevOps is a people first approach so it makes sense that culture is the first point covered. It's about more than just implementing tools and processes and is about creating a collaborative coluture which emphasizes communication, trust and shared goals. This culture is a relationship between how people communicate and how they expect to be communicated with. It focuses on bridging the distance between different departments, encouraging knowledge sharing and creating a shared sense of ownership and accountability. The people and their needs drive the processes and tools, not the other way around. 

* Automation - Teams are empowered to work more efficiently and deliver higher quality products quicker when they are freed from repetitive and mundance tasks. Leverage tools and technology to seek out ways to automate as many tasks as possible and the team is comfortable with. This uses the strength of machines to quickly compute, repetitively deliver or other similar tasks while allowing the people to excel in creative or complex tasks that push the business forward. 

* Lean -
The Lean principle emphasizes the value of minimizing waste and focusing on delivering. When we speak about DevOps, this means optimizing processes and workflows to iliminate bottlenecks and reduce the time it takes to deliver while also prioritizing feedback. Teams can do this by visualizing their work in progress, limiting batch sizes and managing queue lengths. 

* Measurement - In order to continuously improve and optimize the team's processes, you need to be able to measure and track metrics related to your development, delivery and performance. Data is collected and there are mechanisms in place that provide visibility into all systems which can involve tools like monitoring or observability based software to help generate insights which inform decision making. All systems is important here. Measuring our technical systems is important but so are Key Performance Indicators. Those are the raw numbers which make up the framework of the company and illustrate it's success or failure. There's a story to be told between the infrastructure your application lives on and the actions your organization is taking.

* Sharing - 
Information gathered is powerless until it is shared. Within or between teams, knowledge sharing improves the overall performance of the organization and can consist of sharing best practices, lesosns learned or other information. There are user-friendly communication channels that encourage ongoing communication between development and operations. Create platforms or processes such as feedback cycles as information sharing is one of the strongest ways to break down silos. Bring people from different teams and perspectives in earlier to avoid making mistakes based on poor data or assumptions. 

These are the essential ingredients to succeed at DevOps. If you automate everything without measuring or sharing, there's no way to know if it's working as intended. If you measure without automation, it's difficult to validate that it was exactly the same and that your results are correct. This level of execution requires a top down buy in to accomplish as an individual cannot own or drive this level of organization process. That's not to say an individual can't move the needle, just that you can't be the sole owner. Internal DevOps advocacy has it's place in building moment, knowledge sharing and helping to drive change. 

So what do healthy DevOps organizations look like? 

## Team topologies

Team Topologies describe the different patterns of organizing teams to optimize the flow of work and communication across the organization. 

Some of the common team patterns you'll encounter: 

Functional Teams: Teams are organized by their function here such as development, testing, and operations. Each one is responsible for a particular part of the software development lifecycle and functions independently from the others. Anti-Type A vs Type 1. 

Feature Teams: These teams are cross-functional teams that work together to deliver a specific feature or component of the product. 

Service Teams: Teams are responsible for specific parts of the software infrastructure or platform such as networking or database management. 

Platform Teams: These teams provide and maintain the underlying platform or infrastructure which supports the software development and delivery process. 

First and foremost the best team structure is the one that works in your environment and targets the specific needs and goals of your organization. No matter which team structure you have, the key is to optimize communication and cross team collaboration. 

Across all the models and patterns the most common red flag is if silos still exist between your development and operations teams. Whichever model you're using, if there isn't open collaboration between the teams than it isn't DevOps. 

If you're interested in deep diving into this topic for more information on the patterns and anti-patterns of teams in a DevOps organization, you can learn more here: [DevOps Topologies](https://web.devopstopologies.com/)

<!-- You’ve probably heard lots of different terms for DevOps - traditionally infrastructure problems were solved by System Administrators, but more recently you may also have heard Platform Engineering or Site Reliability Engineering. It’s my opinion that all of these roles fall under the same umbrella but may have different approaches, metrics or perspectives on how to solve their problems. 

Organational structure & buy in -> ability to deliver using DevOps methodology.
An individual cannot do the devops -> explain why.
That's not to say that if your job title is devops you're out of luck etc. 
*come back to this to explain why. There’s quite a heated debate around whether DevOps can be a role/title/team or is only a philosophy - there’s something to be said here about organizational structure. Roles and responsibilities often follow under an organizational structure... 


DevOps Engineer - not a specific kind of coder.
Anyone can do it.
It means someone who's responsible for shepherding & fostering DevOps principales  -->

## Getting Started
(Nice place to link to the post on "Good Places to Start Your DevOps Journey" article.)
As we’re getting started, it’s important to note that there’s no step that’s too small to count towards progress. You don’t need to dive 100% in - in fact, it’s probably better not to! Make small, iterative changes and continue to build momentum. 

Look for the waste. There’s different kinds of waste. 

* Wasted Actions to be eliminated
* Wasted actions that are necessary within the current system
* Actions that add value to the process

Focus on manual steps, time spent waiting, bottlenecks. 

Internal Advocacy?

So what kind of areas do we tend to work in when we are solving problems from a DevOps perspective? 
This can link to DevOps Essentials

Describe, model & take action on DevOps -> DevOps Essentials to learn about the pieces of the DevOps Toolchain. 

DevOps literature figure 8. 

## Wrap Up
It's not possible to learn every DevOps concept in a post or a day, but if you continuously learn and iterate on your culture, processes and technology, and work on your gaps and pain points you'll be surprised at how quickly you'll be able to make a big difference. You and your team are not alone in this journey - there's been over a decade of other teams learning and documenting their successes and challenges. This piece will continue to be updated with references to other DevOps articles we release. You can also find additional resources below. 

### Resources

You can find other articles on BuildOn about DevOps here using the DevOps tag. There's a variety of DevOps meetups run around the globe. If community based learning is your thing, you should definitely look for one near you! 

Conferences: 
* [DevOpsDays](https://devopsdays.org/)

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

