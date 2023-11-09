---
title: "Lightsail vs AWS Compute: Comparing Costs with AWS Pricing Calculator"
description: "How to compare costs between Lightsail and AWS services."
tags:
    - lightsail
    - pricing-calculator
    - ec2
    - fargate
authorGithubAlias: spara
authorName: Sophia Parafina
date: 2023-11-08
---

A feature of AWS Lightsail is fixed monthly pricing. You can estimate the cost and budget for it accordingly. However, if you want to run a similar deployment or expand it using other AWS compute resources such as Amazon EC2 or AWS Fargate and cost is a decision factor, you can estimate the cost with the AWS Pricing Calculator.

## Estimating Deployment Costs

To use the Pricing Calculator, search and add the services you need for the deployment. For each service, configure the expected usage. For example, if a deployment regularly sends outbound data, estimate the volume of data sent to calculate the cost. Similarly, compute resources, such as scaling EC2 instances horizontally, requires specifying the instance type and the number of instances. Once you have added all the service you need for a deployment, the Pricing Calculator provides a monthly cost and an annual cost for the deployment. The estimate can be exported as CSV file, as JSON, or as a PDF which is convenient for importing into a spreadsheet or for a report.

Learn how to use the Pricing Calculator with this short video.

https://www.youtube.com/watch?v=n8BQ83lG8lQ&t=95s

## How Much? It Depends

The Pricing Calculator produces estimates and the final cost can vary depending upon configuration choices and usage. The important things to remember are:

- You can purchase compute based on [On-Demand pricing](https://aws.amazon.com/ec2/pricing/on-demand/sc_channel=el&sc_campaign=post&sc_content=lightsail-vs-aws-compute-comparing-costs-with-aws-pricing-calculator&sc_geo=mult&sc_country=mult&sc_outcome=acq), a [1 or 3 year Reserved instance](https://aws.amazon.com/ec2/pricing/reserved-instances/pricing/sc_channel=el&sc_campaign=post&sc_content=lightsail-vs-aws-compute-comparing-costs-with-aws-pricing-calculator&sc_geo=mult&sc_country=mult&sc_outcome=acq), or [Savings Plans](https://aws.amazon.com/savingsplans/sc_channel=el&sc_campaign=post&sc_content=lightsail-vs-aws-compute-comparing-costs-with-aws-pricing-calculator&sc_geo=mult&sc_country=mult&sc_outcome=acq). Choosing a plan based on usage can save up to 72% of operating costs.

-  Costs vary by geographic Regions, the estimated cost in one Region may be more or less in another. In addition, estimates do not include taxes, which may also vary by location.
- The Pricing Calculator produces estimates that maybe higher than the realized cost. Free tier pricing, promotional credits, or other discounts are not used to estimate costs.

Read about [Pricing Calculator assumptions](https://aws.amazon.com/calculator/calculator-assumptions/sc_channel=el&sc_campaign=post&sc_content=lightsail-vs-aws-compute-comparing-costs-with-aws-pricing-calculator&sc_geo=mult&sc_country=mult&sc_outcome=acq) to understand how it arrives at an estimate.

## Comparing Lightsail to AWS Individual Services

Lightsail provides [three pricing examples](https://aws.amazon.com/lightsail/pricing/sc_channel=el&sc_campaign=post&sc_content=lightsail-vs-aws-compute-comparing-costs-with-aws-pricing-calculator&sc_geo=mult&sc_country=mult&sc_outcome=acq). Let’s compare the Lightsail bundled deployments to deployments using individual AWS services. Here are the assumptions used in these estimates:

- US East is the region used in these estimates
- Compute resources are based on shared tenancy and use the Savings Plan where applicable
- Compute resources and data transfer options were chosen to match the examples as closely as possible.

### Example 1

> You have a globally available WordPress website hosted on Amazon Lightsail. This website runs on a $5 / month Linux instance bundle with 1 GB memory, one core processor, a 40 GB SSD disk, and 2 TB transfer. The website uses a CDN distribution to serve content around the world with a year free up to 50 GB, and hosts its static content in a Lightsail object storage bucket with 5 GB storage and 25 GB transfer.
> 
> **Lightsail charges:**
> 
> - WordPress instance = $5 USD / month
> - CDN distribution = Free first year
> - Object Storage bucket = $1 USD / month
>
> Total charges: $6 to get your WordPress site delivered around the world

### EC2 Deployment

Website is hosted on Linux t3.micro instances with a weekly peak CPU usage of 60 minutes. Outbound data transfer to the Internet is 50 GB per month. The instance uses the EC2 instance 1-year Savings Plan. The deployment uses a standard S3 5 GB bucket. AWS CloudFront is the CDN.

### EC2 Charges

- EC2 instance = $9.30 USD / month
- S3 bucket = $0.12 USD / month
- CloudFront CDN = $4.25 USD / month
 
Total charges: $13.67 for a WordPress site with global delivery.

The Lightsail example uses a discounted price for the CDN, which is $2.50 USD / month after the first year. No discounts were applied to the EC2 deployment which could lower the cost.

### Example 2

> You have a multi-tier web application running on Lightsail that includes a Nano container service with 0.25 (shared) vCPU and 512 MB of RAM, a load balancer, and a standard managed database with 1 GB of memory, one core processor, a 40 GB SSD Disk, 100 GB Transfer, and no data encryption.

> **Lightsail charges:**
>
> - Container service = $7 USD / month
> - Database = $15 USD / month
> - Load balancer = $18 USD / month
>
> Total charges: $40 USD / month

**AWS Fargate Deployment**

[Fargate](https://docs.aws.amazon.com/AmazonECS/latest/userguide/what-is-fargate.htmlsc_channel=el&sc_campaign=post&sc_content=lightsail-vs-aws-compute-comparing-costs-with-aws-pricing-calculator&sc_geo=mult&sc_country=mult&sc_outcome=acq) is a service that runs on [AWS Elastic Container Service (ECS)](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/Welcome.htmlsc_channel=el&sc_campaign=post&sc_content=lightsail-vs-aws-compute-comparing-costs-with-aws-pricing-calculator&sc_geo=mult&sc_country=mult&sc_outcome=acq). Like Lightsail, Fargate can run containers without having to manage a cluster. The container is running Linux on a x86 CPU. There is only a single container that runs on an average duration of one day. The database is an on-demand MySQL RDS running on a db.t2.micro instance with 40 GB of storage. The deployment includes a single application load balancer (ALB).

**Fargate charges:**

- Fargate service = $9.01 USD / month
- MySQL RDS service = $18.06 USD / month
- Application Load Balancer = $18.77 USD / month

Total charges: $45.84 US / month

Based on the assumptions, the monthly estimated cost for a Fargate deployment is similar to the Lightsail deployment. Note that these prices are based on assumed usage because the example did not specify usage.

### Example 3

> You ran simulations in RStudio using a Standard XL Lightsail for Research bundle with 4 vCPUs and 8 GB Memory. You also attached an additional 32 GB storage volume (block storage). The simulations were run for 20 hours after which you stopped the bundle, but did not delete the bundle. The bundle was in a stopped state for the rest of the month.
>
> **Lightsail charges:**
>
> - Standard XL bundle running = 20 hours x $0.90 USD / hour = $18 USD
> - Standard XL bundle stopped = 710 hours x $0.00685 USD / hour = $4.86 USD
> - Block storage = $3.20 USD / month
>
> Total charges: $26.06 USD / month to run your RStudio simulations for 20 hours and attach a 32 GB storage volume.

### EC2 Deployment

A similar deployment uses a [c6g.xlarge EC2 instance](https://aws.amazon.com/ec2/instance-types/c6g/sc_channel=el&sc_campaign=post&sc_content=lightsail-vs-aws-compute-comparing-costs-with-aws-pricing-calculator&sc_geo=mult&sc_country=mult&sc_outcome=acq) which is optimized for compute intensive tasks such as machine learning. Included with the instance is 32 GB of block storage and 512 GB of outbound data transfer. Pricing is based on On-Demand utilization for 20 hours/month.

Total EC2 charges: $49.57 USD / month

Even though most of the options are included with a `c6g.xlarge` instance, the cost is nearly double of a Lightsail instance.

## Summary

Depending on the use case, the cost of building a deployment from a combination of AWS services can approximate a Lightsail deployment. It’s important to note that the website and R Studio examples include pre-installed software. The time and effort to install software and configure environments are not included in the cost of deployments that use individual AWS services. The cost of AWS compute and associated services are driven by a number of factors. Usage and pricing plans are a major contributor to the estimated cost. In contrast, Lightsail provide fixed monthly costs that keep operational budgets stable. However, as deployments scale, volume discounts along with the appropriate pricing plan could provide more cost savings. The AWS Pricing Calculator can help decide which path to take.
