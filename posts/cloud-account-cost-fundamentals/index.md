---
title: "AWS Cloud Account Fundamentals: Five Best Practices for Managing Cloud Spend"
description: "AWS Account fundamentals and best practices in one blog"
tags:
    - foundational
    - aws
    - cost-optimization 
spaces:
  - cost-optimization
waves:
  - cost
authorGithubAlias: gaonkarr
authorName: Rohini Gaonkar
date: 2023-08-31
showInHomeFeed: true
---

| ToC |
|-----|

## Introduction

Congratulations, if you have decided to embark on your cloud journey with Amazon Web Services (AWS). Its been more than a decade since I have been working with AWS products and services - as a customer and as an employee. Throughout this time, I've had the privilege of observing the curiosity of builders like yourself, frequently posing remarkably similar questions about how to set the foundation right.

Setting up an AWS cloud account is a significant step, but navigating the vastness of its capabilities requires more than just sign-up knowledge. Over the years, certain patterns of best practices have emerged, strategies that make the difference between a smoothly operating AWS environment and one that is riddled with challenges. Ensuring a solid foundation in your AWS cloud account is paramount to optimize costs, enhance security, and ensure smooth operations.

Today, I'll share five of those best practices for AWS cloud account fundamentals, to guide you in setting up and maintaining your AWS environment in the most effective way possible.. By the end of this read, you'll have insights drawn from years of experience, ensuring that your cloud journey is set on the right path from the very beginning.

## 1. Understanding AWS Accounts

An [AWS Account](https://portal.aws.amazon.com/billing/signup#/start/email) is how you access the AWS Services. The AWS account can be created quickly by using a credit card.

![AWS Account Sign up](images/aws-account-signup.png)

Before you begin creating the account consider following scenarios:

### Is this a personal or business account?

- If this is your **personal account**, ensure you are creating this account with right intentions. The reason I say this is, many students or beginners create AWS account with a credit card (if they can get any), and then regret when resources are left unused and they receive a bill they cannot afford. If you are just starting to learn and want to play with AWS, then **check out [AWS Educate Account](https://aws.amazon.com/education/awseducate/)**. It requires **no credit card** and provides labs that you can play and get AWS experience with. Once you have some experience, you can then create an AWS account with a credit card and continue exploring.

- If this is your **business account**, then make sure you use company e-mail address that is an alias in your company domain. I have seen customers using one individual's company email address, and regret when this person is on holiday, changed roles or has left the company. **Create an email alias** in your company domain (e.g. `aws-admins@example.com`), add multiple administrators to it and then use this alias to create the AWS account. This will ensure you retain access to the AWS account, even if any of the employees move to different role or leave the company. Also, AWS emails will be sent to the distribution list and do not have single point of failure on one individual. Same with the phone number, **use a corporate phone number** instead of a personal one.

> Never ignore emails from AWS

If you wish to report a suspicious email claiming to be from Amazon that you believe is a forgery, you may submit a report. You may also forward phishing emails and other suspected forgeries directly to stop-spoofing@amazon.com. To seek [more information on suspicious emails](https://aws.amazon.com/contact-us/)

### Do you need single or multiple AWS Accounts?

There are many reasons why businesses would prefer multiple AWS accounts. You may want isolation between accounts for security control and data access, or different teams and business units. Some customers have benefitted from keeping their production and non-production workloads in different accounts. This also gives them visibility on their development vs production spend. These are listed in detail in the AWS Documentation for [Do I need multiple AWS accounts](https://docs.aws.amazon.com/accounts/latest/reference/welcome-multiple-accounts.html). Use AWS Organizations, which is a free AWS service to manage multiple accounts in your organizations.

If you do not wish to create separate accounts, you should at the very least, ensure that you have created separate Amazon Virtual Private Cloud (VPC) for your different environments.

Story time: I had a customer, who had development 
UPDATE


## 2. Choosing AWS Regions and Services

If you are starting with AWS, there 2 important concepts you need to understand - Regions, and Availability Zones. Amazon cloud computing resources are hosted in multiple locations world-wide. Each AWS Region is a separate geographic area. Each AWS Region has multiple, isolated locations known as Availability Zones.

![image]() 

UPDATE

It is important to remember that each AWS Region is completely independent.

Choosing which AWS Region to use depends on multiple factors:

- **Latency:** If this is an application/website service end customers, identify where are majority of your customers located and choose the AWS Region closest to your customers. This helps reduce Internet latency.

https://www.cloudping.info/
https://clients.amazonworkspaces.com/Health.html

add more info on internet latencies, and this tool, cli? https://github.com/ekalinin/awsping

- **Cost:**

  Not all components of your application require high latency, example development
  aws services, anecdotally us east 
  Newer EC2 instance type generations will be more cost-effective.

- **Compliances:**
gdpr, data privacy laws, 

- **AWS Services:** [List of AWS Services Available by Region](https://aws.amazon.com/about-aws/global-infrastructure/regional-product-services/)

## 3. Free Tier and Budget alerts

A common misconception among builders is that AWS Free Tier means everything is free for first 12months. Well if you thought so too, then let me break the ice for you, NO.

> Free Tier: Not everything is free.

When you create a new AWS account, AWS provides **some resources** in **some AWS services** free for the first 12 months only.

Within those 12 months, if in a month you exceed the free tier limit, your credit card will be charged as per the on-demand prices.

For example, 750 hours of Linux and Windows t2.micro instances (t3.micro for the regions in which t2.micro is unavailable), each month for one year. If you exceed 750 hours, you wil be charge an On-Demand hourly rate of $0.0116 (in US East N. Virginia Region). While Displayed pricing is an hourly rate but depending on which instances you choose, you pay by the hour or second (minimum of 60 seconds) for each instance type.

> If you are a beginner, I recommended to use EC2 Micro instances only.

For more information, you can read pricing pages for each AWS service. For example, refer [Amazon EC2 On-Demand Pricing](https://aws.amazon.com/ec2/pricing/on-demand/)

You can also use the [AWS Pricing Calculator](https://calculator.aws/) to cost estimate your needs.

![Pricing Calculator](images/pricing-calculator.png)

### How can you ensure that you do not exceed the Free tier limits?

1. As soon as you create the account, the first step is to **turn on AWS Free Tier usage alerts**. It is important to note, the AWS Free Tier usage alerts automatically notifies you over email when you **exceed 85 percent** of your Free Tier limit for each service:

    - Sign in to the AWS Management Console and open the [Billing console](https://console.aws.amazon.com/billing/).

    - Under `Preferences` in the navigation pane, choose `Billing preferences`.

    - For `Alert preferences`, choose `Edit`.

    - Select `Receive AWS Free Tier alerts` to opt in to Free Tier usage alerts. By default, it will deliver alerts to the root user email address, you can optionally add one more additional recipient. Once done, choose `Update`.

    ![billing alert preferences update](images/billing-alert-preferences-update.png)

2. For additional tracking, you can create a new budget in the [AWS Console for AWS Budgets](https://us-east-1.console.aws.amazon.com/billing/home?region=us-east-1#/budgets) to track your usage to **100 percent** of the Free Tier limit by setting a `zero spend budget` using the simplified template as shown in the image below:

    ![Budget in console](images/create-budget-aws-console.png)

3. Optionally, you can also filter your budget to track individual services. Set a monthly usage budget with a fixed usage amount and forecasted notifications to help ensure that you are staying within the service limits for a specific service. You can also be sure you are staying under a specific AWS Free Tier offering.

4. **Review your AWS Free Tier usage** by using the Free Tier page in the Billing console.

    ![Review your AWS Free Tier usage](images/aws-free-tier-billing-console.png)

## 4. Security is important

Shared Security model? limits in place, UPDATE

After you set your billing alerts, create AWS Identity and Access Management (IAM) User(s). Even if this is your personal account and you are the only one using this, DO NOT use AWS root (i.e. email id and password based) login. Create an IAM User with Administrative access for yourself and use that to login to the AWS Console.

### Why securing root access is of utmost importance

The root user credentials can perform all actions on your account, including actions that ONLY the root user can perform like change account details or close the account. If you, by any means, unknowingly, leak the credentials, your account and personal details will be at risk. You can find detailed list of [tasks that require root user credentials](https://docs.aws.amazon.com/IAM/latest/UserGuide/root-user-tasks.html)

To secure the root user credentials:

- Enable AWS multi-factor authentication (MFA) on your AWS account root user. Because the root user can perform sensitive operations in your account, adding this additional layer of authentication helps you to better secure your account. There are many different types of MFA - hardware, software. I have personally used a third-party app like [Authy](https://authy.com/).

- Never share your AWS account root user password or access keys with anyone.

- Use a strong password

- You use an access key (an access key ID and secret access key) to make programmatic requests to AWS. Do NOT create an AWS account root user access key.


### IAM User Best Practices

As mentioned earlier, create an IAM User with administrative permissions. This might feel like an additional burden, on your journey to begin using cloud, however, like with any other activity on the internet, SECURITY should be your highest priority. If you do not follow these best practices, you are making yourself vulnerable and it can ultimately affect your pocket.

Detailed steps on [how to set up AWS account access for an administrative user using IAM Identity Center](https://docs.aws.amazon.com/SetUp/latest/UserGuide/setup-configadminuser.html)

To secure the IAM user credentials:

- DO NOT share IAM Users. Create IAM User for each user in your business.

- Only provide limited access using IAM Users. Not everyone needs Administrative access. You can create IAM Groups like Administrators, Developers, etc. Provide these group with limited permissions required by each role and then add users to these groups.

- Same applies for the Access Keys and Secret Access keys required for programmatic access. You can use IAM Roles for programmatic access. If you do create these keys for IAM Users, ensure you DO NOT share these between users.

- Enable MFA for the IAM Users. If this is a business account, you can also enforce IAM Users to enable MFA to login to AWS Console. More information on [configuring MFA device enforcement](https://docs.aws.amazon.com/singlesignon/latest/userguide/how-to-configure-mfa-device-enforcement.html)

- Regularly review, delete old, un-used IAM Users/Roles. You can find this information in the [AWS IAM Console](https://us-east-1.console.aws.amazon.com/iamv2/home?region=us-east-2#/users).
![Alt text](images/aws-console-iam-user-age.png) 

If you need more help, UPDATE

(support, stackoverflow, re:post)

## 5. Clean up as you go, delete everything

Regular maintenance and hygiene is very important - in our house and in our account too! Remember it is pay as you go model, any resource left running in the cloud will be charged for.

Myth Burst 1: If you stop an EC2 instance, then you will stop paying for it. While it is technically true, you need to understand there are 3 types of cost associate with an EC2 instance - compute, storage and network. When an EC2 instance is stopped, you stop getting charged for the compute and network cost. However, the instance might still have an attached EBS volume (i.e. storage) which is provisioned. You will continue being charged for it. Keep volumes small. If you do not need this EC2 instance, then Terminate the instance.

> Keep storage small UPDATE

Myth Burst 2: If you close the account, you are good

### How do you identify resources left behind in your account?

You can use AWS Resource Explorer to identify resources in your AWS account. Check out detailed blog post on how to clean up resources in the blog [Tidying up your bedroom](/tutorials/tidy-your-bedroom-identify-unused-resources).

![AWS Resource Explorer](images/aws-resource-explorer.png)

## Conclusion

In this blog post, we looked at five fundamentals and learnt best practices on your journey to exploring AWS Cloud. By adhering to these best practices for AWS cloud account, you not only secure your resources but also set the stage for efficient and scalable operations, ensuring less wastage and unnecessary spend.

While it seems tempting to take the easier route and leave it to fate, let's take the correct path to ensure we're building on solid ground, one best practice at a time. Whether you're just beginning your AWS journey or looking to refine your approach, these fundamentals are your roadmap to cloud success. Safe travels!
