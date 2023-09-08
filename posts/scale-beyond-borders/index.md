---
title: "Scale across borders: build a multi-region architecture while maintaining data residency"
description: In this post, we cover a high-level reference architecture to illustrate how you can deploy a multi-region architecture while maintaining data residency. This architecture is suitable for scaling startups and businesses operating in regulated industries and, those who are building the foundation for a global business.
tags:
  - architectural-patterns
  - multi-region
  - security
  - compliance
waves:
  - modern-apps
authorGithubAlias: wirjo
authorName: Daniel Wirjo
additionalAuthors: 
  - authorGithubAlias: benduncan
    authorName: Ben Duncan
date: 2023-09-08
---

|ToC|
|---|

# Scale across borders: build a multi-region architecture while maintaining data residency

![](./images/cover.png)

## Overview

In a world where data security and privacy requirements are becoming increasingly stringent, businesses face the challenge of expanding globally while maintaining compliance with data residency requirements. In this post, we cover a high-level reference architecture to illustrate how you can deploy a multi-region architecture while maintaining data residency. We provide accompanying [code sample](https://github.com/aws-samples/multi-region-data-residency) using [AWS Cloud Development Kit (CDK)](https://aws.amazon.com/cdk/) as well as considerations and best-practices to assist with your implementation.

This architecture is suitable for scaling startups and businesses operating in regulated industries such as Healthcare and Life Sciences (HCLS) and Financial Services (FinTech). And, those who are building the foundation for a global business, or seeking to scale from a single-region architecture.

## AWS reference architecture for multi-region with data residency

The example high-level architecture covers a full-stack web application. It uses a [silo](https://docs.aws.amazon.com/wellarchitected/latest/saas-lens/silo-pool-and-bridge-models.html) model with isolated infrastructure stacks for each region. With this architecture, businesses can securely handle sensitive data like Personally Identifiable Information (PII) or Personal Health Information (PHI) while adhering to regional compliance standards.

![Multi-Region Reference Architecture](./images/multi-region-architecture.png)

Let’s walk through the components of the high-level architecture: 

1. User connects to application hosted on [AWS Amplify](https://aws.amazon.com/amplify/). [Amazon CloudFront](https://aws.amazon.com/cloudfront/) provides global edge caching to minimize end-user latency.  

2. [Amazon Cognito](https://aws.amazon.com/cognito/) is used for authentication including login and sign up. It is a regional service and can be deployed to each region. The application can integrate to Cognito using [Amplify UI Authenticator](https://ui.docs.amplify.aws/react/connected-components/authenticator).  

3. [Amazon DynamoDB Global Tables](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/GlobalTables.html) is used to store the user’s data residency and replicated across regions. [Amazon Cognito Lambda Triggers](https://docs.aws.amazon.com/cognito/latest/developerguide/cognito-user-identity-pools-working-with-aws-lambda-triggers.html) (pre-auth and pre-signup) will use the data to ensure that the user is allocated to the appropriate region.  

4. [Amazon Route 53 Geolocation Routing](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/routing-policy-geo.html) (alternatively [Latency Routing](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/routing-policy-latency.html)) provides a global API endpoint based on the user’s geolocation, and failover capability.  

5. [Amazon API Gateway Regional Endpoint](https://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-api-endpoint-types.html#api-gateway-api-endpoint-types-regional) (alternatively [Application Load Balancer](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/introduction.html)) provides an endpoint for each region. See #8 for more details.  

6. [AWS Lambda](https://aws.amazon.com/lambda/) (or alternative compute services such as [Amazon ECS with Fargate](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/AWS_Fargate.html)) provides the backend for the API.  

7. Storage and databases (such as [Amazon Simple Storage Service (S3)](https://aws.amazon.com/s3/)and Amazon [Relational Database Service (RDS)](https://aws.amazon.com/rds/), and [Amazon DynamoDB](https://aws.amazon.com/dynamodb/)) is used to store sensitive data. These are isolated to each region.  

8. Optionally, the regional API endpoint can be accessed directly for the user to access their desired region, bypassing the default. For additional security, consider [Amazon CloudFront](https://aws.amazon.com/cloudfront/) and [AWS WAF](https://aws.amazon.com/waf/).

For more details on the implementation, see [code sample](https://github.com/aws-samples/multi-region-data-residency) for demo application.

## Preparing for a multi-region architecture

Adopting multi-region is a significant undertaking, consider the following before taking the plunge:

### Be wary of added cost and complexity

Adopting a multi-region architecture can bring additional costs, complexities across your application design and [operations](https://docs.aws.amazon.com/whitepapers/latest/aws-multi-region-fundamentals/multi-region-fundamental-4-operational-readiness.html). As such, we typically advise startups to challenge and dive deep on the the necessity for a multi-region architecture, including understanding specific compliance requirements, and key drivers. Expanding your business globally does *not* necessarily  require a multi-region architecture.

### Deep dive into regulatory and compliance requirements

As at time of writing, compliance to [GDPR](https://aws.amazon.com/compliance/gdpr-center/) does *not* necessarily mandate data residency.  Many regulations are principles-based and does *not* mandate specific requirements. If data residency is *not* strictly required, then implementing general security controls may be of higher priority. Here, consider working towards compliance to a recognised international security standards (such as ISO27001, SOC II, and NIST800-53) which provide guidance on security for your overall organization. Tools such as AWS Config, AWS Artifact and AWS Audit Manager can assist with your compliance journey.

### Consider a simpler architecture

To achieve the best performance and user experience for customers in the new region, you may think that a multi-region architecture is required. However, let’s challenge this assumption. Consider starting with a simplified architecture such as introducing [Amazon CloudFront](https://aws.amazon.com/cloudfront/) to a single-region architecture. CloudFront has global points-of-presence to reduce end-user latency to your global users. Similarly, for availability and Disaster Recovery (DR), we recommend to first consider a multi-AZ architecture. At AWS, we define an [availability zone (AZ)](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-regions-availability-zones.html) as isolated locations with redundancy. The risk of outage of multiple availability zones is very low.

### Automate, automate, automate

If you have not adopted infrastructure as code and automated your deployment process, consider implementing this first. In the reference architecture, we have used [AWS Cloud Development Kit (CDK)](https://aws.amazon.com/cdk/) which allows you to define your infrastructure with familiar programming languages such as TypeScript or Python.

## Considerations and best-practices when adopting a multi-region architecture

If a multi-region architecture is required, consider the following factors:

### Think big, but start small

The fastest path to get your application into a new region is to replicate your infrastructure stack to the new region. Starting with this approach allows you to get your product in market and into the hands of users in your target region. This allows you to iterate your product,  obtain feedback from customers, and localize your product offering for the new region.

### Support local requirements through global customization

If you are required to release updates specific to the local region, consider introducing the feature as a configurable feature. This allows consistent application source code and infrastructure across regions. To implement, consider using [feature flags using AWS AppConfig](https://aws.amazon.com/blogs/mt/using-aws-appconfig-feature-flags/) which also facilitates fast iteration through [trunk-based development](https://aws.amazon.com/builders-library/cicd-pipeline/).

### Build foundation for efficiency using SaaS design principles

As you grow, it is important to review [software-as-a-service (SaaS) design principles](https://docs.aws.amazon.com/wellarchitected/latest/saas-lens/general-design-principles.html). The example reference architecture draws upon some of the concepts outlined such as [tenant](https://docs.aws.amazon.com/wellarchitected/latest/saas-lens/tenant.html). In a SaaS, typically a tenant corresponds to a customer, and data is partitioned accordingly. For example, *Customer 1* cannot see data for *Customer 2*. The same principle can be applied to this architecture where *Region 1* is isolated from *Region 2*. As each tenant uses its own separate infrastructure, the architecture uses a [silo isolation](https://docs.aws.amazon.com/wellarchitected/latest/saas-lens/silo-isolation.html) model. For cost efficiency, infrastructure resources can be [pooled](https://docs.aws.amazon.com/wellarchitected/latest/saas-lens/pool-isolation.html) over time.

### Bind user identity to tenant identity

It is highly likely that every layer of the application will need to be aware of this tenant context. The most efficient approach is to introduce the context is through the identity layer. In the reference architecture, we use `custom:region` user attribute which is then passed to the application via JSON Web Tokens (JWT) tokens as a custom claim. As the application is expanded to multiple services, each service can simply use the token to gain tenant awareness. Without relying on another service, each service can decrypt the tokens to determine the context, apply the appropriate isolation logic, connect to the relevant data source as well as pass data to monitoring and logging tools. The logic can be abstracted from developers for development efficiency and simplicity.

### Implement additional security controls as your grow

As your team grows, there can be more room for mistakes. Consider layering security controls over time to improve protection of sensitive data. For example, you can consider [data residency controls](https://docs.aws.amazon.com/controltower/latest/userguide/data-residency-controls.html) using [AWS Control Tower](https://aws.amazon.com/controltower/), performing a [Well-Architected: Security](https://docs.aws.amazon.com/wellarchitected/latest/security-pillar/welcome.html) review for a holistic assessment, and [evolving your security capabilities at key growth stages](https://www.youtube.com/watch?v=_i4YcLkZrLc&t=494s).

## Conclusion

In this post, we explored the significance of data residency, particularly in regulated industries such as healthcare, life sciences and financial services, where protecting sensitive customer data is paramount. We covered a high-level reference architecture which allows you to establish a solid foundation for your global business, enabling expansion to new regions, while maintaining compliance, and safeguarding sensitive data. If you would like to learn more, we encourage you to explore the accompanying [code sample](https://github.com/aws-samples/multi-region-data-residency) and demo application, and diving deeper into the links to resources posted throughout the post.

If you are plotting for world domination or looking to expand to a new region, feel free to [connect with me](https://linkedin.com/in/wirjo) or contact your [AWS account team](https://aws.amazon.com/blogs/startups/meet-your-aws-account-team/) to learn more about the programs we offer and alternative multi-region architecture patterns.
