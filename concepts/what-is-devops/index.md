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

This guide is for anyone looking to learn or refresh themselves on the fundamental concepts of DevOps and its principles. You’ve probably landed here because you’re looking to learn more about it and how you can apply this knowledge to the problems you are facing. This guide will not sell you products, platforms or tools as solutions to those problems. There is no one size fits all solution, however there are existing patterns, frameworks, and mechanisms that have been tested and iterated upon which you can leverage. The goal for this document is to cover core DevOps concepts to leave you with a better understanding of what DevOps is, where it came from and optional resources to support your learning journey and inspiration for your next pursuit. Feel free to read this post from start to finish or to skip to sections that you're most interested in, whichever works best for you! 

By the end of this article, you should have a better understanding of what DevOps is, the history of where it came from, and what it isn't.


| ToC |
| --- |

## What Is Not DevOps
Before we dive into what DevOps *is*, let's touch on what it's *not*. DevOps is not a silver bullet solution for all of your problems. It is not a product, tool or solution you can buy and be done with. It also is not changing the name of an existing operations, sysadmin or similar team and informing the rest of engineering that you now do the DevOps. It is not a solo engineer who catches all the glue work nor is it telling your developers that they've all been promoted to DevOps engineers and will now maintain the infrastructure too. This is a recipe for disaster. Adopting Agile or Scrum processes will not solve the DevOps problem for you. While embracing Agile or Scrum processes can potentially support you on your DevOps journey, they alone do not set you up to succeed. 

To learn more about what DevOps is not with a side of humor, check out [How to Succeed At DevOps: Wrong Answers Only!](https://www.buildon.aws/posts/devops-wrong-answers-only)

## A Bit Of History

### 1970 - *Waterfall* Methodology
Historically software teams delivered their products utilizing the Waterfall methodology which was created in 1970 and is a model where requirements for the next 6 months are captured in business requirements documents, and you build features for multiple months before doing a big-bang release. It consists of 5 phases:

1. Requirements
2. Design 
3. Implementation 
4. Verification 
5. Maitnenance 

It's a model intended for situations requiring a high degree of precision before implementing. Consider scenarios which require a high degree of scrutinty such as in the aerospace industry where mistakes could cause loss of life. 
In software, this often meant large quanities of work accumulated over time and were eventually released in one mega deployment before the teams went back to working for another long delivery cycle. Imagine taking months, or even *years* of your code and not knowing if it'll work until you finally get to deploy it? How do you manage all of the deprecated systems? The untested changes?

The friction involved in developign under the waterfall methodology and the single points of failure encountered along the way set the stage for a DevOps classic: [The Phoenix Project](https://www.goodreads.com/book/show/17255186-the-phoenix-project)

So where did DevOps come from?

### 1953 - *Lean Manufacturing and Kanban*
Some might say that it began almost 20 years prior to the creation of the waterfall methodlogy in 1953 with Toyota, Lean manufacturing and something you may have heard about before - the Kanban system. Kanban was created as a way to minimize waste by focusing on producing what is needed, when it's needed and in the amount that's needed. 

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

But what is it? 


## What Is DevOps?
 At its core, DevOps is about the people behind the technology and is an approach to solving problems collaboratively. It values teamwork and communication, fast feedback and iteration, and removing friction or waste through automation. It became popular because it encouraged teams to break their work down into smaller chunks and approach product delivery collaboratively with a holistic view of the product enabling better team transparency and quicker, more reliable deployments. DevOps consists of a combination of practices including Culture, Process & Tooling. While it’s important to note that implementing DevOps practices is more than simply adding a pipeline or using containers, these and others are common technical areas that we work in to help accomplish our goals. If you’d like to learn more about those technical areas, you can find that information in [DevOps Essentials](https://www.buildon.aws/concepts/devops-essentials/). 

//
Although there's plenty of different content pieces about how to learn and implement DevOps, there's common values shared across most of them. 
Encourage teamwork, reduce silos/share info, practice systems thinking, embrace failure, communicate, accept feedback and automate processes (when applicable). 

If you're someone who likes to learn through videos or conference talks, check out this talk "What Is DevOps" by Dan Maher [What Is DevOps?](https://www.youtube.com/watch?v=kCRD4pNuh80)

## The Three Ways 
The Phoenix Project (2013), DevOps Handbook (2016) 

The DevOps Handbook focuses on 3 major pillars.

* First Way - Principles of Flow/Systems Thinking - about breaking work into smaller chunks and reducing friction for each stage of work.
The first way focuses on the performance of the entire system. Put simply, one team's success doesn't matter if the org fails to deliver.

* Second Way - Principles of Feedback / Amplifying Feedback Loops- Getting fast, actionable feedback at all stages of the development process to constantly iterate and improve.

* Third Way - Principles of Continuoual Experimentation & Learning -  Creating an environment where learning, exploring and discovery are encouraged. A major piece is being open to making mistakes & failures. 


As we’ve continued to iterate on the concept of DevOps itself, we've found other frameworks to measure our success at DevOps. 

## CALMS

* Culture - A culture of shared responsibility, expectations and socials contracts between a group of people. It's a relationship between how people communicate & how they expect to be communicated with. We use people and processes, needs drive the tools. 
* Automation - Team members seek out ways to automate as many tasks as possible and are comfortable with the idea of continuous delivery. 
Again - People before Tools. We should be intentional with our automation to move repetitive tasks from people to machines in order to free up our people for more complex or creative tasks. 
Automate to unlock human potential.
* Lean - team members are able to visualize work in progress, limit batch sizes and manage queue lengths
Throwing back to [A Bit Of History](#a-bit-of-history), Lean 
DevOps can make Lean adoption more efficient. 
* Measurement - Measure everything, always. Data is collected on everything and there are mechanisms in place that provide visibility into all systems 
Measuring computer things are important but so is Key Performance Indicators. They're the raw numbers that make up the framework of the company and illustrate it's success or failure. 
There's a story between the infrastructure your orgs application lives on and what your organization is doing. If it moves, graph it lol.
* Sharing - There are user-friendly communication channels that encourage ongoing communication between development and operations 
Sharing as a feedback cycle. Information wants to be free, and sharing is one of the strongest ways to break down silos. 
Bring people from different teams and perspectives in earlier to avoid making mistakes based on poor data or assumptions. Feedback cycles. 
Awareness of other teams and the work they're doing. 

The essential elements/recipe items of DevOps.
Executing on CALMS -> DevOps.
If you automate everything without measuring or sharing, it's not DevOps.
Need top down buy in to accomplish.
An individual cannot accomplish DevOps alone because it's an organizational thing but that's where DevOps internal advocacy comes in 


There’s other frameworks out there as well that we won’t cover here today. 
When we look at the values and different frameworks, a few things jump out. At it’s heart, DevOps is about creating a collaborative culture with shared responsibility, improving processes for better visibility and sharing, and finally the actual tools that we create or implement to further our teams. 

## Team topologies
You’ve probably heard lots of different terms for DevOps - traditionally infrastructure problems were solved by System Administrators, but more recently you may also have heard Platform Engineering or Site Reliability Engineering. It’s my opinion that all of these roles fall under the same umbrella but may have different approaches, metrics or perspectives on how to solve their problems. 

https://web.devopstopologies.com/

Organational structure & buy in -> ability to deliver using DevOps methodology.
An individual cannot do the devops -> explain why.
That's not to say that if your job title is devops you're out of luck etc. 
*come back to this to explain why. There’s quite a heated debate around whether DevOps can be a role/title/team or is only a philosophy - there’s something to be said here about organizational structure. Roles and responsibilities often follow under an organizational structure... 


DevOps Engineer - not a specific kind of coder.
Anyone can do it.
It means someone who's responsible for shepherding & fostering DevOps principales 

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

