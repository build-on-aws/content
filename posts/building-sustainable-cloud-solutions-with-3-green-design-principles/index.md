---
title: "Building Sustainable Cloud Solutions with 3 Green Design Principles"
description: 3 sustainable design principles to help reduce the carbon footprint of your cloud workloads.
tags:
  - sustainability
  - aws
waves:
  - cost
authorGithubAlias: dairiley
authorName: Daisy Riley
date: 2023-09-08
---
|ToC|
|---|
As of 2020, the world’s IT infrastructure makes up about 2.5% of all emissions, with data centers contributing to 0.25% of all emissions ([*How Bad Are Bananas? The Carbon Footprint of Everything* *- Mike Bernes Lee*](https://www.amazon.co.uk/How-Bad-are-Bananas-Everything/dp/1846688914)). While this may not seem like a huge percentage given all we use technology for, this is the equivalent of boiling an electric kettle 35,000,000,000,000 times or building 1,400,000 new electric cars. IT is also innovating a pace beyond comprehension, with an increasing amount of computationally heavy workloads such as cryptocurrency and machine learning being introduced. If left unchecked, the billions of tonnes of emissions from IT will exponentially increase.
Fortunately, there is already a solution. Software Engineers who understand how the world’s IT infrastructure works, can apply their knowledge of it to reduce the use of compute, storage and networking across an application with the goal of reducing emissions. This post dives into 3 green design principles that software engineers can implement to reduce the emissions of cloud workloads.

## Why Cloud?

According to [studies by 451 Research](https://aws.amazon.com/sustainability/resources/?sc_channel=el&sc_campaign=costwave&sc_content=building-sustainable-cloud-solutions-with-3-green-design-principles&sc_geo=mult&sc_country=mult&sc_outcome=acq), moving to the AWS cloud can reduce the carbon footprint of a workload by up to 80% (96% when AWS is powered by 100% renewable energy). This is due to the scale of the AWS infrastructure allowing a higher resource utilization, and designing facilities to consume less water and energy. With this in mind, not all workloads can be moved to the cloud for reasons such as needing to keep a workload in a certain geographic location where there is not currently an AWS region. In these cases, the principles outlined in this post can still be applied to further reduce your emissions and energy consumption.

## 1. Understand Your Users

Every application is built with someone in mind. For example, a website that streams French TV shows would be targeted towards people living in France. This sort of website may experience spikes when a new episode of a popular show is released. It wouldn’t make sense to host an application like this globally and always have the same number of resources up and running.

Understanding your users is the idea of aligning your workload better for your customers, with the added bonus of reducing usage. By observing when, where and how your customers use an application, you can identify what is not used and remove it.  Some examples of how you can achieve this is with [Amazon EC2](https://aws.amazon.com/ec2/?sc_channel=el&sc_campaign=costwave&sc_content=building-sustainable-cloud-solutions-with-3-green-design-principles&sc_geo=mult&sc_country=mult&sc_outcome=acq) usage reports for an application running on EC2 instances, or by observing memory usage for an [AWS Lambda](https://aws.amazon.com/lambda/?sc_channel=el&sc_campaign=costwave&sc_content=building-sustainable-cloud-solutions-with-3-green-design-principles&sc_geo=mult&sc_country=mult&sc_outcome=acq) function.

The geographic placement of the users should also be taken into consideration. By having a cloud application physically closer to your user locations, data does not have to travel as far across networks, reducing the energy consumed. If you use [Amazon CloudFront](https://aws.amazon.com/cloudfront/?sc_channel=el&sc_campaign=costwave&sc_content=building-sustainable-cloud-solutions-with-3-green-design-principles&sc_geo=mult&sc_country=mult&sc_outcome=acq) to distribute content, you can utilize the CloudFront viewers reports to view the locations of visitors who access your content most frequently. With this information, you can adjust the region your workload is deployed in to be closest to your users.

## 2. Only Use What You Need

Only using what you need may sound like a familiar phrase echoed by parents or teachers over your lifetime. But it doesn’t just apply to taking all the crayons out of the box when you only need one color, it’s one of the most overlooked areas of optimization in IT.

Increasing the sustainability of your application shouldn’t mean compromising on performance. Low latency is crucial for a variety of applications such as banking apps or online gaming. At the same time, having high performance doesn’t necessarily equate to a larger EC2 instance type or more memory for your Lambda function. An efficient application is one that has a high utilization. Configuring auto-scaling that allows you to react to increases or decreases in traffic removes the need for idle ‘just-in-case’ resources. These unused resources will still consume energy (and money) without improving the user experience. You can use the [AWS Compute Optimizer](https://aws.amazon.com/compute-optimizer/?sc_channel=el&sc_campaign=costwave&sc_content=building-sustainable-cloud-solutions-with-3-green-design-principles&sc_geo=mult&sc_country=mult&sc_outcome=acq) to analyze the efficiency metrics for [Amazon EC2](https://aws.amazon.com/ec2/?sc_channel=el&sc_campaign=costwave&sc_content=building-sustainable-cloud-solutions-with-3-green-design-principles&sc_geo=mult&sc_country=mult&sc_outcome=acq), [AWS Lambda](https://aws.amazon.com/lambda/?sc_channel=el&sc_campaign=costwave&sc_content=building-sustainable-cloud-solutions-with-3-green-design-principles&sc_geo=mult&sc_country=mult&sc_outcome=acq) and [Amazon Elastic Block Store](https://aws.amazon.com/ebs/?sc_channel=el&sc_campaign=costwave&sc_content=building-sustainable-cloud-solutions-with-3-green-design-principles&sc_geo=mult&sc_country=mult&sc_outcome=acq) to identify savings opportunities. [Amazon RDS](https://aws.amazon.com/rds/?sc_channel=el&sc_campaign=costwave&sc_content=building-sustainable-cloud-solutions-with-3-green-design-principles&sc_geo=mult&sc_country=mult&sc_outcome=acq) also provides a selection of different instance types with different memory, CPU and storage depending on your workload requirements.
Serverless technology also allows you to reduce energy consumption. Lambda functions ensure you only use the resources you need, without wasting energy on idle processes.

Rightsizing isn’t the only side to being frugal with your resources. The question also needs to be asked: Do I need this at all? An internal application for making time-off requests does not need the same latency as your customer facing application with hundreds of requests a minute. And if you’re hanging on to archival data that hasn’t been accessed in years, it may be time to delete it. If you’re using [Amazon S3](https://aws.amazon.com/s3/?sc_channel=el&sc_campaign=costwave&sc_content=building-sustainable-cloud-solutions-with-3-green-design-principles&sc_geo=mult&sc_country=mult&sc_outcome=acq) and deletion isn’t an option, reevaluate your storage classes depending on how frequently data is accessed. Additionally, set up lifecycle policies that can automatically move and delete data. And don’t backup everything. Data should only be backed up when it would be more impactful, or impossible to recreate.

## 3. Stay Up to Date

Legacy applications are usually full of spaghetti code, outdated dependencies and processes that don’t necessarily serve their original purpose. Removing redundancy from code would be one of the first steps to reducing your emissions, but it may not always be possible if things start to break for seemingly no reason (we’ve all broken production by deleting a line of commented out code at some point).

As software and hardware evolves, it becomes more efficient. By switching to the latest instance types, you can take advantage of more energy efficient hardware. [AWS Graviton-based EC2 instances](https://aws.amazon.com/ec2/graviton/?sc_channel=el&sc_campaign=costwave&sc_content=building-sustainable-cloud-solutions-with-3-green-design-principles&sc_geo=mult&sc_country=mult&sc_outcome=acq) are one example of this, using up to 60% less energy for the same performance than comparable instances. This is becoming increasingly important with the demand for compute and machine learning on the rise. You can migrate to Graviton based instances easily from [AWS managed services](https://aws.amazon.com/managed-services/?sc_channel=el&sc_campaign=costwave&sc_content=building-sustainable-cloud-solutions-with-3-green-design-principles&sc_geo=mult&sc_country=mult&sc_outcome=acq), and with a few extra steps for Linux workloads. .NET applications require migration to Linux and .NET core on Arm64, but the migration has high reward.

To simplify the task of staying up-to-date with the latest software releases and patches, use managed services where possible. Managed services additionally distribute the environmental impact of the service, due to the many users.

## Conclusion

It’s crucial that leaders across all disciples and industries work together for a sustainable future, and software engineers have a huge part to play as technology takes up more and more of our lives day by day. Just taking action to switch to the cloud can reduce the carbon footprint of a workload significantly (up to 80%), with further savings to be realized by optimizing according to the sustainable design principles in this post. If you are just getting started on your sustainability journey, start by evaluating the utilization of your current workload and user behavior patterns. And if you want to take things further, check out the [Sustainability Pillar of the AWS Well-Architected Framework](https://docs.aws.amazon.com/wellarchitected/latest/sustainability-pillar/sustainability-pillar.html?sc_channel=el&sc_campaign=costwave&sc_content=building-sustainable-cloud-solutions-with-3-green-design-principles&sc_geo=mult&sc_country=mult&sc_outcome=acq) and consider signing up for [The Climate Pledge](https://www.theclimatepledge.com/), a joint action to achieve net-zero carbon emissions by 2040.

And if you're looking for more specific guidance on Graviton migration, check out these blogs for Rust and Go applications:

- [Building Rust Applications For AWS Graviton](/tutorials/building-rust-applications-for-aws-graviton)
- [Building Go Applications For AWS Graviton](/tutorials/building-go-applications-for-aws-graviton)
