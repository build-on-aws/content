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
date: 2023-09-18
---

### Introduction

I have some pretty strong beliefs when it comes to cloud costs, how they should be looked at, and who should be responsible for what. 

First, lets go back to 2011. I was working in London for a major consulting company when my brother, Ali, who was doing his PhD in Cloud Computing, called me. He told me about a prototype he had built that could help companies assess the Total Cost of Ownership (TCO) of transitioning to the cloud. I got the train to Edinburgh that Friday, talked to him over the weekend, and quit my job on Monday. From there, we developed one of the first cloud cost management products available. And since then, we have remained in this field.

I tell this story because I’ve been deeply embedded in cloud costs and the different methods and attempts companies have made to reduce cloud costs, which ones work and which ones don’t. 

I want to make three points in this blog. These points are what you, as engineers can take to your management team to push for engineering led FinOps practice. I will also show you what tool you should use as the first step to shift cloud costs left (it's open source too!).


### 1. Understanding Cloud Usage is Key

Let's quickly cover the basics. When looking at cloud costs, it is helpful if we understand the [cloud cost formula](https://www.infracost.io/blog/cloud-cost-optimization-formula/):

![Cloud cost optimization formula](images/infracost-cost-optimization-formula.png)

**Cloud Cost = Usage x Unit Price**

The **Usage** component refers to the cloud resources you are provisioning - for example you have chosen an EC2 instance or a serverless Lambda function to run your feature. This component of this formula is fully within your control. Engineering choose which services to use, how they are configured, set up, and even how the usage of those resources scale.

The **Unit Price** component refers to the rate you pay per-service per time-unit. For example, AWS EC2 instances have a specific price rate based on instance size, family, region, OS etc. These resources can be purchased in multiple ways (on-demand, Reserved, Savings Plans etc). How the services are paid for is a financial decision. It doesn't impact the service and how it is run or managed, it just impacts the rate which will be charged. 

The **Usage** component is the more important part of this formula. If an instance is not being used at all, it doesn’t matter if you save 60% of the cost via a purchase plan, it’s still 40% waste.


This is why the [FinOps practice](https://www.infracost.io/finops/) should be engineering-led. The core work that needs to be done under the FinOps umbrella requires engineering effort. Engineering is required for cost optimization, tagging of resources, and right-sizing decisions. Engineering is required to do the cost-benefit analysis for each action.


### 2. Understand Cloud Costs Before Making Changes

Many companies discuss the concept of shifting cloud costs left, but what they actually do is not shifting left. Setting up alerting when a cost spike or anomaly happens is great, but that's not shifting left. When you receive a production alert and quickly address the issue, that's not shifting left, the same concept applies to costs.

Hey Chat GPT, define “shifting left”: “Shifting left in computing means moving processes or tasks earlier in the development cycle to catch and address issues earlier, rather than waiting until later stages or after deployment”. That's a pretty good [definition](https://about.gitlab.com/topics/ci-cd/shift-left-devops/#how-to-shift-left-with-continuous-integration).

When we talk about shifting FinOps left, it means knowing how much the cloud costs <u>before</u> we spend the money. It means checking for the right tags and values <u>before</u> we merge the pull request. It means checking for best practice policies directly in <u>our workflow</u>.

### 3. Cloud Costs Are Complex

We have code to write, features to ship, bugs to fix, and so on. Testing was shifted left; security was shifted left; if we keep shifting things left, we won't be coding anymore! ... I hear you say, and I agree. We can't just "shift it left" without putting in tools to help. We need the right information at the right time appended directly in our workflow.

In the great words of Gwen Stefani, “this sh*t is bananas”: [cloud costs are complex](https://www.infracost.io/blog/why-are-cloud-costs-so-complex/). Here at [Infracost](https://www.infracost.io), we have a database of all resource prices from AWS, Microsoft Azure, and GCP, and it comes to 4 million prices! How do we expect anyone to know which price points are being used? We need to automate this to understand the cost impact of the changes before we spend the money. Non-engineering people are always surprised when I tell them that the cloud doesn't't have a checkout screen!

### FinOps Should Be Engineering-Led

Here is the first step to take: [Infracost is free and open source](https://www.infracost.io/), install it into your GitHub or GitLab now. As soon as you've installed it, every time someone makes Infrastructure as Code change, Infracost will leave a comment like "this change is going to increase costs by 10% next month" along with a detailed breakdown of the costs. Knowing costs before spending money is the first step - that's our checkout screen. Next, you can setup checks to make sure [resources are tagged correctly](https://www.infracost.io/docs/infracost_cloud/tagging_policies/), best practice [cloud cost policies](https://www.infracost.io/docs/infracost_cloud/cost_policies/) are being followed, and [cost guardrails](https://www.infracost.io/docs/infracost_cloud/guardrails/) are put in place.

I hope I have given you some firepower and the next steps with cloud cost optimization. Push for FinOps to be engineering led, and if you want me to talk to your managers, tag me in!

Cheers,
[Hassan](https://www.linkedin.com/in/hassanhosseini/)