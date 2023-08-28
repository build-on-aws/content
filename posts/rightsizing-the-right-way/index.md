---
title: "Rightsizing - The right way!"
description: "Explore what rightsizing is, why it is important, and how to identify opportunities to do it. Also, explore tools provided by AWS/open source and link to related tutorial."
tags:
  - tag-1
  - tag-2
  - list-of-other-tags-as-kebab-case-like-this-with-dashes-separating-and-all-lower-case-like-below
authorGithubAlias: mergenf
authorName: Ben Mergen
date: 2023-08-21
showInHomeFeed: true
---

<!-- Throughout this template there will be comments like these, please remove them before committing the first version of the content piece. -->
<!-- NB: READ THE COMMENT ABOVE, AND DELETE THIS AND OTHER COMMENTS!!! -->

**EVERYTHING BELOW GETS REPLACED WITH YOUR CONTENT ONCE YOU'VE UPDATED THE FRONTMATTER ABOVE**

## Frontmatter Instructions

All frontmatter must be in [syntactically correct YAML](https://learnxinyminutes.com/docs/yaml/).

- `title` - the title of your post in quotes, less than 100 characters i.e. "What Happens When You Type a URL Into Your Browser" - Please put this inside double-quotes
- `description` - a description of your post used to surface a short description on the site and for SEO, less than 250 characters - Please put this inside double-quotes
- `tags` - help readers discover posts on the same topics. Use `kebab-case`.
- `authorGithubAlias` - your GitHub username
- `authorName` - how you want your name to display for the author credit of this post
- `date` - date this post is published in `YYYY-MM-DD` format. This does not effect when your post goes live and is purely for display purposes.
- `showInHomeFeed` - Set this to `false` if you don't want the post to be on the home and RSS feeds.

## Header 2

Do **NOT** include any h1 headers (single `#`) as this is reserved for the title of your post that is handled automatically. Headings should start with h2 and be implemented in semantically correct, outline form.

### Header 3

Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.

# Rightsizing - The right way!

## Introduction

There are many tools in the market which can help you to reduce your cloud costs and their major recommendations are about using the right resources based on the metrics.

“Good intentions don't work; mechanisms do” (reference Jeff Bezos). No matter what is the root cause of oversized or undersized resource usage, there should be mechanism and playbook in organizations to right-size their resources based on their business needs.

“Rightsizing does not mean downsizing only”. There are variety of instance types with varying amounts of CPU, memory, and other resources. Selecting the right instance type for your workload ensures that you are using resources efficiently. If you oversize, you might be wasting resources that could be used by other workloads. If you undersize, then you might be creating performance bottlenecks and slowdowns. Rightsizing ensures that your application has the necessary resources to operate optimally, avoiding performance degradation.

## What is rightsizing mean?

Rightsizing in cloud computing refers to the process of optimizing the resources allocated to compute resources and other cloud resources to match their actual utilization needs. This involves adjusting the amount of CPU, memory, storage, and other resources to ensure that you are paying for and utilizing the cloud resources efficiently. In essence, rightsizing can be summarized as the practice of meeting business requirements (KPIs) at the anticipated performance level by utilizing specific resource types, all while minimizing any wastage

Rightsizing involves aligning your cloud resources with your business requirements and performance expectations, all while minimizing waste and inefficiency. By selecting the appropriate resource types and allocations, you ensure that your applications meet their Key Performance Indicators (KPIs) without overspending or underperforming.

## Why rightsizing is important?

Oversizing your resources can lead to unnecessary expenses, as you are paying for more resources than you actually need. Rightsizing helps you align your resource allocation with your application's requirements, minimizing costs while still delivering the required performance.

Undersized resources can lead to performance bottlenecks and slowdowns, negatively affecting your application's performance. Rightsizing ensures that your application has the necessary resources to operate optimally, avoiding performance degradation.

### Cost Impact

Unnecessary resource usage will cause waste and cost you more than you should pay.
TBD - in progress

### Forecasting

Understanding your application requirements, user/customer behaviors, business requirements and cost of right-sized resources will allow you to calculate forecasting accurately for future costs. With rightsizing, you can accurately forecast your cloud costs since you'll be using the resources that you actually need. This predictability is crucial for budgeting and financial planning.

To achieve effective rightsizing, you should monitor your application's resource usage over time, analyze performance metrics, and use tools provided by the cloud provider or third-party solutions to recommend appropriate instance types and resource allocations. Regularly reviewing and adjusting your resource allocation ensures that your cloud environment remains optimized and cost-effective.

## what can be rightsized?

List of AWS services such as
EC2
RDS
EFS
Redshift
EMR
...

## How to start Rightsizing

To start healthy rightsizing activity, you need to understand your business requirements, application and expected traffic to your workload (definition of workload)

1. Gather Information: Understand your application's requirements, workload patterns, and performance goals. Collect data on resource usage, such as CPU, memory, and storage, over a period of time.
2. Analyze Usage Patterns: Review the collected data to identify usage patterns and peak periods. Determine which resources are consistently overutilized or underutilized.
3. Set Performance Metrics: Define Key Performance Indicators (KPIs) for your application's performance. This could include response times, latency, throughput, and other relevant metrics.
4. Choose Monitoring Tools: Select monitoring and analytics tools provided by your cloud provider or third-party solutions to track resource usage and performance metrics in real-time.
5. Identify Oversized Resources: Identify instances or resources that are consistently using more resources than required. These are potential candidates for downsizing.
6. Identify Undersized Resources: Identify instances that experience performance bottlenecks due to insufficient resources. These are potential candidates for upsizing.
7. Evaluate Instance Types: Examine the various instance types offered by your cloud provider. Consider factors like CPU, memory, storage, and networking capabilities. Choose instances that align with your workload's requirements.
8. Test Changes: Before making changes in production, test resizing on non-production environments. Monitor performance during and after resizing to ensure the desired improvements are achieved.
9. Implement Changes: Resize the instances or resources based on your analysis. For underutilized instances, downsize to reduce resource waste. For instances facing performance issues, upscale to meet performance requirements.
10. Monitor Performance: Continuously monitor performance after rightsizing. Compare actual performance against your defined KPIs. Adjust as needed to ensure the desired outcomes.
11. Optimize Storage: Rightsizing isn't limited to just compute resources. Evaluate storage usage as well and consider optimizing storage types and configurations based on access patterns and performance requirements.
12. Automate Scaling if possible: Set up auto-scaling mechanisms to dynamically adjust resources based on workload demands. This ensures that you can maintain optimal performance even during traffic spikes.
13. Periodic Reviews: Workload requirement and environments changes over time, so periodically review your application's resource usage and performance. Adjust instances and resource allocations accordingly.
14. Use Right Tools to right-size: Leverage cloud management tools that provide insights and recommendations for rightsizing, making the process more efficient.
15. Educate Team Members: Creating cost-aware culture is probably the hardest one in organizations. Ensure that your team is aware of the importance of rightsizing and the process involved. Encourage a culture of resource efficiency and optimization.
