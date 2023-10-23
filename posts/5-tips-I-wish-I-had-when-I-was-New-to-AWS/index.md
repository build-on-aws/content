---
title: "5 tips I wish I had when I was New to AWS"
description: Here are 5 tips I wish I ad know when I started building on AWS. These tips will help you plan your journey to build on AWS and carry.
tags:
  - new-to-aws
  - solutions
  - aws-solutions
  - reinvent
  - reinvent23
  - cloud-foundations
spaces:
  - reinvent
authorGithubAlias: alejtraws
authorName: Alex Torres
date: 2023-10-20
---

| ToC |
|-----|


# 5 tips I wish I had when I was New to AWS

I remember when I started building on AWS, the joy of infinite possibilities, the cloud at my fingertips to build anything I wanted. I hadn't decided what was going to be my first project yet, but I was eager to start! But wait... start where?

I had been building traditional applications on prem, that was easy or at least something I was used to doing. But I found myself navigating through new services, features, and those infinite possibilities started to feel a little too infinite!

I am sure that if you are new to AWS you may have felt the same way at some point of your AWS journey, so I wanted to share with you a few tricks that I have learned over the few years, that I wish I had when I was new to AWS.

## Tip #1. Learn the fundamentals
AWS provides a broad set of services that are powerful enablers for anything you want to build, any type of application, and there is a lot to learn. Getting familiar with some of the basic concepts for permission management, networking on the cloud, different compute options (EC2, Containers, Lambda) will help tremendously before you adventure into the AWS world.

But planning structured learning and mapping the technologies that you are familiar today to the services and features offered by AWS helped me feel more comfortable when deciding where and how I was going to run my applications.

> **A couple examples:** Do I need traditional VMs? Well, that maps to Amazon EC2. Am I building containerized applications? Amazon ECS, Am I going to use Kubernetes? Then Amazon EKS is the answer.

If you are building in a team, it helps to create a table that maps the different technologies to what others are familiar with, and then it will help new people that join your project to select the right technology and AWS service.

How can AWS help with this? Reach out, check our [getting started](https://aws.amazon.com/getting-started/) site, ask in our forums, send an email, come meet us at one of the conferences, and we will be more than happy to help!

📣 If you are just starting your journey and want to learn more, come meet me at [re:Invent in Las Vegas this Novemeber](https://reinvent.awsevents.com/)! I will be presenting [COP308](https://hub.reinvent.awsevents.com/attendee-portal/catalog/?search=COP308) and [ARC324](https://hub.reinvent.awsevents.com/attendee-portal/catalog/?search=ARC324), and I have a few colleagues presenting what they have learned about building new environments - you can find this sessions in the catalog [New to AWS track](https://hub.reinvent.awsevents.com/attendee-portal/catalog/?filters=84E8C1BB-9D54-4827-8E60-E50800C6C02B)

## Tip #2. Choose a project!
When starting to build on AWS there is always new things that need to be done, new things that you want to explore, new things to learn. Sometimes, it is good to stop, take a deep breath and just simplify, focus, and find a fun project you want to work on.

First pick if you are going to either bring to AWS, a.k.a., a migration, or develop brand new and deploy it into AWS. Once you have picked the application, ensure it will be fun, something that can be done relatively quickly, and build a business case around it! Define success, key takeaways, decide on your technology, and have fun! This takes us to our next tip...

## Tip #3. Plan ahead
When we are excited about a new project or a new application, sometimes we overlook some important details along the way, and yes, they tend to be the boring ones...

- What logs do I need and where do I store them?
- What metrics do I need to define and monitor?
- Do I need to set up budget alerts?
- How do I secure my applications and plan for high availability?

And yes, the list goes on and on... So as you build your application, plan with your application, do not forget to plan your [cloud foundation](https://aws.amazon.com/architecture/cloud-foundations/), the little things that you need to have into account that you will need along your journey, like Identity, or Network connectivity, or how to isolate workloads from one another.

At the end of the day... who would buy a house without electric wiring, water supply, windows or doors, right? Think about your cloud foundation the same way, it allows you to actually run things smoothly.

If you create a project plan to build your environment along with your workload you can make you have the tools needed in your environment to scale your workload according to your needs, like the key to unlock your house.

## Tip #4. Start small
Sometimes we set goals for ourselves that are very large, or far away. A couple years ago... I set a goal for myself to build a IoT farm for my garden beds. I knew everything I wanted to do, but I just focused on the big picture. 

It took me 2 years to start... 🤦🏼‍♂️

So, I pivoted, I set small victories for myself, buy the sensors, buy the new soil, configure it all in my raspberry pi, and send the data to the cloud for processing and build a small application. You should see my tomato plant this year, I have been getting 15 tomatoes a week in average! 🍅🍅🍅

![Tomatoes](images/tomatoes.jpeg)

Celebrate small wins, with your peers, with your teammates, with your leadership, it will definitely keep the morale up, and it will also help you to pivot quickly if anything in your project needs to be adjusted!

## Tip #5. Understand the cost cloud model
Unlimited resources is amazing, if you don't use the resources, you don't have to pay for them. AWS provides with the tools to ensure you keep your cost to a minimum when needed, but without the right planning and optimization for resources can get expensive, , but what are they providing that you don't need to do, or worry about anymore.

I like to think about the cost about a profit center rather than a cost center. Wait... don't you pay for the resources? How is it generating profit for my business? Think about all the infrastructure, or services, that you don't need to maintain. Operational hours that can be shifted to build new features for your customers, quicker. Improving their experience.

## Summing it all up!
Getting started on the cloud can come with a little bit of uncertainty. What skills do I need? Do I need to learn a complete new set of skill sets? Will I have to redo something I have already worked on prem? Do I need to rebuild my data center on AWS?

I hear these questions often when working with new organizations moving to AWS. The answer is sometimes yes and sometimes not when finding the right balance between what stays on prem and what comes to the cloud.

And do not try to build everything from scratch yourself, AWS and AWS Partners build solutions that are ready to use, ready to deploy directly into your environment, that can help you with operating your environment easier or even deploying your applications to AWS. Check some of this solutions in the [AWS Solutions Library](https://aws.amazon.com/solutions/)! There is a lot of good stuff in there!

But, remember, find (or become) a champion in your organization that advocates and helps people understand the benefits AWS brings to your business and then:

1. Focus on understanding the basics
2. Pick a fun project to get started
3. Implement a foundation, build a project plan for your workloads
4. Start small, celebrate the little wins! 
5. Understand the cost model

If you have any questions, or would like to connect, please, feel free to reach out to me on [LinkedIn](https://www.linkedin.com/in/agltorres/), shoot me a message, or come chat with me during reinvent!

Have fun, build with joy!
