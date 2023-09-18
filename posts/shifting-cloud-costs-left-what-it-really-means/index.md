---
title: "Shift Cloud Costs Left: What Does It Really Mean?"
description: What does it really mean to shift cloud costs left, and how to do it
tags:
  - finops
  - cost-optimization
  - essentials
  - cost-control-automation
authorGithubAlias: hassankhosseini
authorName: Hassan Khajeh-Hosseini
date: 2023-09-17
---

### Introduction

I have some pretty strong beliefs when it comes to cloud costs, how they should be looked at, and who should be responsible for what. 

I’ll share those with you, but first, let me take you back to 2011. I was working in London for one of the big consulting companies when I got a call from my brother, Ali, who was doing his PhD in Cloud Computing. He said he had built this prototype that could help companies assess the total cost of ownership of moving to the cloud. I got the train to Edinburgh that Friday, and met up with him to see what he was working on. I quit my job on Monday. We went on to build a company that would be acquired within the year, and then we built one of the first cloud cost management products out there. And, we’ve never left the space.

I tell this story because I’ve been deeply embedded in cloud costs and the different methods and attempts companies have made to reduce cloud costs, which ones work and which ones don’t. I want to make three points.


### Understanding Cloud Usage is Key

If your [FinOps practice](https://www.infracost.io/finops/) is not engineering-led, it’s missing the main point. The cloud is priced based on usage, and only engineers can impact what is used. Let’s look at the [cloud cost formula](https://www.infracost.io/blog/cloud-cost-optimization-formula/):

Cloud Cost = Usage x Unit Price

The usage component of this formula is fully within engineering control. Engineering choose which services to use, how they are configured, set up, and even how the usage of those resources scale.

The unit price component can be a financial decision. However, it is important to optimize this after the usage has been optimized. A thought exercise: If an instance is not being used at all, it doesn’t matter if you save 60% of the unit price of that instance, it’s still 40% waste.

Usage is the more important part of this formula, and it is fully within engineering control. It is also the harder part of the equation to address and work on.

<img src="/posts/shifting-cloud-costs-left-what-it-really-means/images/infracost-cost-optimization-formula.png" alt="Cloud cost optimization formula" width="60%" />


### Understand Cloud Costs Before Making Changes

When people talk about shifting cloud costs left, and go on to say the way they achieve it is by alerting engineers when a cost spike or anomaly happens—that’s not shifting left, that’s just marketing.

I asked AI to tell me what “shifting left” means: “Shifting left in computing means moving processes or tasks earlier in the development cycle to catch and address issues earlier, rather than waiting until later stages or after deployment”.

When we talk about shifting FinOps left, it means showing how much the cloud costs <u>before</u> we spend the money, it means checking for the right tags and values <u>before</u> we merge the pull request, it means checking for best practice policies directly in <u>our workflow</u>.

### Cloud Costs Are Complex

Engineers have code to write, features to ship, bugs to fix, and so on… You can’t just “shift it left” without providing them with the right tools.

I’ve heard people say “engineers don’t take action” when talking about [cost optimization](https://www.infracost.io) tasks. What a strange thing to say, I thought to myself, taking action is literally all that engineers do. They are given fully loaded sprints, and tasked with completing it all in two weeks. If you want more out of the engineering team, provide them with better tools. 

In the great words of Gwen Stefani, “this sh*t is bananas”: [cloud costs are complex](https://www.infracost.io/blog/why-are-cloud-costs-so-complex/). Here at [Infracost](https://www.infracost.io), we have a database of all [resource prices](https://www.infracost.io/blog/why-are-cloud-costs-so-complex/) from AWS, Microsoft Azure, and GCP, and it comes to 4 million prices! How do we expect anyone to know which price points are being used? We need to automate this and put tools in place to help engineers understand the cost impact of the changes they are making before they happen.

### FinOps Should Be Engineering-Led

Cloud costs should be shifted left — proactive, not reactive, and done so with tooling. I don’t even mind if you don’t use [Infracost (it’s free and open source, so why not)](https://www.infracost.io/), but please help your fellow engineers, your engineering managers, and FinOps folks by providing them with the right tools built into their workflows! Share the love. Cheers.