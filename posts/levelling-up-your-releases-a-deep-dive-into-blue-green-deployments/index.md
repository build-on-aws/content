---
title: "Levelling up your releases: a deep dive into blue/green deployments"
description: Deploying to production is a critical step in the software deployment lifecycle. Given the risks, engineering teams should be careful, intentional and decisive on the release process. One approach to reduce risk is blue/green deployments. Blue/green deployments reduce risk and maintain availability during deployments of new features. 
tags:
  - aws
  - resilience
  - codedeploy
  - deployment
  - devops
  - ci-cd
  - ecs
  - api-gateway
  - serverless
authorGithubAlias: wirjo
authorName: Daniel Wirjo
date: 2023-08-11
---

## Introduction to Blue/Green Deployments

Deploying to production is a critical step in the software deployment lifecycle. Given the risks, engineering teams should be careful, intentional and decisive on the release process. One approach to reduce risk is blue/green deployments. Blue/green deployments reduce risk and maintain availability during deployments of new features. This by deploying the new functionality to a separate new environment, and then cutting over all production traffic to the new environment. This ensures a clean cut over with near zero downtime, and allows for rollback. 

Here we will cover what you need to know for blue/green deployments, show how AWS services support these, and share a real-world example.

## Benefits of Blue/Green Deployments

Unlike traditional “in-place” deployments, blue/green deployments make it easy for teams to validate a new update for release, while continuing the current version of the application in parallel. This is facilitated by creating two isolated environments blue (current production environment) and green (parallel new environment). 

With this approach, you benefit from the ability to: 

* Validate the new update by sending test traffic (e.g. small sample of production users)
* Running smoke tests to verify important functions prior to release
* Rollback to the previous version in the blue environment if things don’t go as planned

Ultimately, the approach simplifies operations and overall deployment risks is reduced through automation.

## Key considerations for blue/green deployments

The first consideration for implementing blue/green deployments is aligning your organisation on its benefits. Driving changes require planning, prioritisation and investment, and may impact a broad stakeholder group including product and business teams. It is important that benefits for each set of stakeholders are articulated. For example, for the engineering team, this may lead to greater satisfaction through greater confidence around deployments. For the product team, it may mean improved cycle time and a new approach on how to engage with new releases.  

The second consideration is to scope your environment boundary and testing process. For a micro-services architecture, rollouts can happen gradually to limit the blast radius. However, for a monolithic application, this may mean applying the approach to your entire application which may involve more extensive testing.

Lastly, if the new release contains database or schema changes, a simplest approach is to decouple this from the application and ensure that there is backwards compatibility between both the existing (blue) and new (green) versions. In other words, we recommend that the application is *stateless*. For more information, see [Best Practices for Managing Data Synchronization and Schema Changes](https://docs.aws.amazon.com/whitepapers/latest/blue-green-deployments/best-practices-for-managing-data-synchronization-and-schema-changes.html).

## Practical steps to get started

### Managed blue/green deployments

The good news is that AWS provides a number of fully managed blue/green deployment options:

If you are getting started with a container-based application, [AWS App Runner](https://docs.aws.amazon.com/apprunner/latest/dg/what-is-apprunner.html) automates deployment and will deploy a new version using blue/green under the hood. 

If you are using Amazon ECS (container) or AWS Lambda (serverless) for your application, deployments can be managed using [AWS CodeDeploy](https://aws.amazon.com/codedeploy/). The integration allows you to automate blue/green deployment for both [ECS](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/deployment-type-bluegreen.html) and [Lambda](https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/automating-updates-to-serverless-apps.html). This includes:
    * Configuration on how traffic is shifted. For example, you can shift traffic to the new version all at once or test using a percentage of production traffic, also known as *canary releases*. 
    * Integration to your CI/CD pipeline such as [Github Actions](https://github.com/aws-samples/aws-codedeploy-github-actions-deployment) or [Amazon CodePipeline.](https://docs.aws.amazon.com/codepipeline/latest/userguide/action-reference-CodeDeploy.html) 
    * Test automation using [lifecycle event hooks](https://docs.aws.amazon.com/codedeploy/latest/userguide/reference-appspec-file-structure-hooks.html#appspec-hooks-ecs). For example, you can consider incorporating some smoke tests into the `BeforeAllowTraffic` hook. 

![Blue/green deployment using Amazon CodeDeploy](images/blue-green-codedeploy.png)

If your application is an API, consider [Amazon API Gateway](https://docs.aws.amazon.com/apigateway/latest/developerguide/canary-release.html). API Gateway supports [canary releases](https://docs.aws.amazon.com/apigateway/latest/developerguide/canary-release.html) natively in addition to API management capabilities such as throttling and authorization. To quickly get started, you can find sample code and patterns on [Serverless Land](https://serverlessland.com/patterns/apigw-canary-deployment-cdk).

![Canary releases using Amazon API Gateway](images/api-gateway-canary-releases.png)

These fully managed capabilities help you take care of the heavy-lifting associated with implementation, so you can better focus building your application.

### Using the routing layer of your architecture

While we recommend starting with fully managed capabilities outlined, you can also consider implementing blue/green deployment at the routing layer of your architecture by [using Amazon Route 53](https://docs.aws.amazon.com/whitepapers/latest/blue-green-deployments/update-dns-routing-with-amazon-route-53.html) or [swapping the Auto Scaling Group behind an Elastic Load Balancer](https://docs.aws.amazon.com/whitepapers/latest/blue-green-deployments/swap-the-auto-scaling-group-behind-elastic-load-balancer.html). This can provide you with greater control on the process.

![Blue/green by swapping the Auto Scaling Group behind an Elastic Load Balancer](images/swap-auto-scaling-group.png)

While there are many ways to implement, the goal should be to automate the process, and ultimately reduce errors and costs. Overall, you should choose the appropriate implementation based on your architecture, the nature of your application, and goals for your organisation.

## A real-world experience

As a Solutions Architect, I advise CTOs, technical leaders and engineering teams on applying best-practices to get the most out of AWS. I worked with scaling startup who dread their release process and was fearful of deployments. They experienced a number of incidents whereby intended production releases were not successful. The team was scarred by the painful experiences. 

As a result, both the application developers and platform team tend to stay back outside of business hours in order to deploy. They also developed step-by-step playbooks for rollbacks and risk mitigation. They believed that the impact to users will be minimal as most will use the platform during business hours. However, over time, they realised that it’s not full-proof: there were a number of customers that had a critical use the platform outside business hours. After switching their release windows to accommodate and going through the cumbersome release process numerous times, they decided to explore a better way. 

With curiosity to learn from Amazon’s engineering practices, I directed them to [Amazon Builders Library](https://aws.amazon.com/builders-library/going-faster-with-continuous-delivery/), a collection of resources based on Amazon’s own experience building software. They studied the post on continuous delivery and educated themselves on deployment approaches. They then championed the approach across the organisation and figured out a way to safely test a component of their application to minimise blast radius. They tested their rollback processes and adjusted their process for database migrations to be suitable with the new process. With increased conviction, they rolled out the process across their entire platform over time. 

Since implementing the approach, they noticed that they were able to release with confidence. Moreover, they iterated on their automated deployment process transitioning from initial manual tests to automated tests, as well as incorporating other best-practices such as using feature flags. They now release multiple times a day during business hours which allowed them to better coordinate with their product, sales and risk teams. Ultimately, the process helped drove greater innovation on behalf of their customers.

## Conclusion

Blue/green deployments offer much more than reducing risks and increasing confidence. The approach has been a game-changer for many AWS customers: from improving developer experience, culture and satisfaction, to greater agility and speed to release features and updates with confidence. If you haven’t tried blue/green deployments yet, we highly recommend giving it a go and tell us what you think. Key resources and relevant documentation for the different approaches are linked throughout the post. 