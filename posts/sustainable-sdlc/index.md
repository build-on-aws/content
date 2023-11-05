---
title: "Sustainable Software Development Life Cycle (S-SDLC)"
description: Sustainability is no more a nice to have requirement but must have. Everyone needs to be aware of what sustainability is about and how their work impacts sustainability. There is general misconception that IT doesn't impact environment. This blog is aimed at Developer and Operations teams to provide them best practices that they should consider in their projects to ensure that their project is not contributing negatively to environment. 
tags:
  - sustainability
  - devops
  - best practices
images:
  banner: images/s-sdlc-phases.jpg
authorGithubAlias: ranbirsh
authorName: Ranbir Singh
additionalAuthors: 
  - authorGithubAlias: ghm
    authorName: Sam Mokhtari
date: 2023-11-05
---

| ToC |
|-----|


## Overview

The ICT (Information and Communication Technology) industry has grown exponentially in recent decades and this growth has some consequences to the environment. This industry uses computers, laptops and other electronic devices like routers, switches, printers etc. which are powered by electricity as the major contributor to greenhouse gas (GHG) emissions. In addition, software development activities may not be directly emitting emissions, but there is  an indirect contribution.  In this blog, we will explore the intersection of sustainability and software development, and look at some of the ways that developers can make a positive impact on the environment.  By taking a thoughtful and intentional approach to sustainability in software development, we can create a more sustainable and equitable world for future generations.

## What is Sustainable Software Development Life Cycle (S-SDLC)?

The goal of sustainability in software development life cycle would focus on ensuring responsible application design, development and maintenance keeping energy consumption in mind. We should focus on increasing utilization for spun-up resources and reducing/removing idle resources.  Sustainable Software Development Life Cycle (S-SDLC) is not so much about doing different things as it is about considering sustainability in doing things. The primary audience of this blog consist of software developers and operators, those who design, build, test and operate software in the cloud.<br>

These are the key tenants and principles that are considered in S-SDLC.

* Share learning experiences and create a sustainability mindset across software development lifecycle
* Leverage automation capabilities wherever possible
* Establish measurements to gain insights and create learning opportunities
* Makes sustainability a continuous focus including all stakeholders in the sustainability considerations
* Sustainability is everyone’s responsibility
* Focus on increasing utilization and minimizing waste
* Use efficient resources for your workload and focus on business differentiators while offloading undifferentiated heavy lifting to cloud


## What are the benefits of S-SDLC?

S-SDLC aims to find ways and define best practices for reducing emission of greenhouse gases resulting from use of energy for powering IT systems and resources. This blog intends to provide information that development teams can consider to ensure that their product/solution is in align with organization’s sustainability goals and also helps them in showcasing their commitment to environmental and social responsibility. S-SDLC helps in making sustainability an continuous focus rather than one-time activity. It also helps in reducing waste and improving utilization of running resources thus making it more cost-efficient to run the workload. <br>

The following sections captures some of the sustainability related best practices corresponding to various phases of SDLC. <br>


![S-SDLC Phases](./images/s-sdlc-phases.jpg "Sustainable SDLC Phases")

### Software Requirements
**Capture sustainable requirements**: During requirements elicitation phase, the focus is on gathering functional requirements and non-functional requirements.  Non-functional requirements(NFRs) should include sustainability requirements such as increasing efficiency, improving resource utilization, and waste reduction.  Also identify the the environmental regulations and standards that need to be followed during the project. The sustainability requirements must be SMART (Specific, Measurable, Actionable,  Realistic, Time-bound) and we should focus on efficiency without compromising the software quality for the users. Refer to [SUS06-BP01 Adopt methods that can rapidly introduce sustainability improvements](https://docs.aws.amazon.com/wellarchitected/latest/sustainability-pillar/sus_sus_dev_a2.html) for more details. <br>

**Define sustainability metrics**: It is important to identify fine-grained metrics that can help measure the carbon footprint for your application. In some cases when we can’t measure the carbon emissions directly, we can consider using proxy/indirect metrics instead e.g., when calling a third party API, legacy system.  Common example for proxy metrics includes vCPU minutes for Compute, GB storage provisioned for storage and GB transferred or packets transferred for network.<br>

**Focus on Sustainable SLAs**: When defining/reviewing SLA (Service Level Agreements) for workload, plan to optimize the SLAs based on workload’s sustainability goals. By aligning workload SLAs to sustainability goes, we can optimize resource utilization along with meeting business needs. We should aim to meet your business requirements and not exceed them. Refer to [SUS02-BP02 Align SLAs with sustainability goals](https://docs.aws.amazon.com/wellarchitected/latest/sustainability-pillar/sus_sus_user_a3.html) for more details. <br>

**Understand application team’s responsibility for sustainability**: Sustainability is a shared responsibility between AWS and customers. While AWS is responsible for ensuring sustainability of the cloud( delivering efficient, shared infrastructure, water stewardship, and sourcing renewable power), customers’ application teams are responsible for ensuring sustainability in the cloud ( optimizing workloads and resource utilization, and minimizing the total resources required to be deployed for your workloads). <br>

### Design

**Sustainable UX (User Experience)**: User experience (UX) has a significant impact on environment sustainability. While designing UX, focus on how the user will be interacting with the application and using efficient design patterns like dark themes, lightweight images/videos, lazy loading, cache frequently accessed content, reducing load time(e.g., pagination, avoiding unnecessary data loading), reducing no. of round trips to process request. <br>

**Region Selection**: When considering cloud region to deploy workload, consider regions which are powered by renewal energy sources or where the grid has a lower published carbon intensity. This needs to be evaluated along with other business requirements like close proximity to application users, cost of running workload in region, compliance requirements etc. Please refer [SUS01-BP01 Choose Region based on both business requirements and sustainability goals](https://docs.aws.amazon.com/wellarchitected/latest/sustainability-pillar/sus_sus_region_a2.html) for more details. <br>

**Managing the demand curve**: Many times we over-provision workload resources to meet unforeseen spikes in demand. This results in underutilized resources during non-peak times. We should aim to flatten the demand curve by efficiently managing the spikes. In case workload consumers can retry for transient errors, implement throttling mechanism, where as we can use buffering to defer request processing when consumers can’t retry. To understand various AWS services that can help in flatting the demand curve, checkout [SUS02-BP06 Implement buffering or throttling to flatten the demand curve](https://docs.aws.amazon.com/wellarchitected/latest/sustainability-pillar/sus_sus_user_a7.html). <br>


**Review synchronous invocation requirements**: Synchronous processing typically requires more resources, consumes more energy and are more prone to failures. Except for use cases requiring real-time responses, review use cases that are manageable with delayed responses as well. For use cases that don’t require immediate response, consider using asynchronous processing using Amazon Simple Queue Service (SQS) or Amazon Simple Notification Service (SNS) services. If the request can be processed anything, evaluate using scheduler to process requests in batches. Checkout [SUS03-BP01 Optimize software and architecture for asynchronous and scheduled jobs](https://docs.aws.amazon.com/wellarchitected/latest/sustainability-pillar/sus_sus_software_a2.html) for more guidance on this. <br>


**Choose efficient hardware**: When choosing instances to deploy workload, consider options that provide better price performance along with low energy consumption. AWS Graviton processors (custom silicon with 64-bit Arm processor cores) are designed to be more energy efficient. Graviton-based instances use up to 60% less energy for the same performance than comparable EC2 instances. There are many AWS managed services like Amazon DocumentDB, Amazon Aurora and Amazon ElastiCache that can be easily run on Amazon Graviton processors or can be easily migrated from x86 processors easily without incurring any downtime. Workloads based on Linux and JITd languages (like Java, Python, PHP) can be easily hosted/migrated to graviton, while compiled languages like C/C++, Go require more effort. At the moment, Microsoft Windows servers are not yet available for arm64. For stateless applications, consider exploring Spot Instances( unused EC2 instances that are available at a discounted price) or choosing Burstable instance types for workloads with occasional spikes. For ML (Machine Learning) workloads, leverage [AWS Trainium](https://aws.amazon.com/machine-learning/trainium/) and [AWS Inferentia](https://aws.amazon.com/machine-learning/inferentia/)  for model training and inferencing. These processors are designed and optimized to support deep learning workloads in AWS Cloud. <br>


**Prefer managed services**: Managed services shift the responsibility of maintaining high-average utilization and sustainability optimization of the hardware to AWS. Choosing fully-managed services helps teams focus on their business differentiators rather than spending time of undifferentiated heavy lifting associated with managing infrastructure.  Example of such services includes ECS (Elastic Container Service), EKS (Elastic Kubernetes Service), Amazon API Gateway, Amazon DynamoDB, Amazon S3 (Simple Storage Service), Amazon RDS (Relational Database Service), Amazon Redshift, Amazon SNS (Simple Notification Service), Amazon SQS (Simple Queue Service), AWS Step Function. <br>


**Focus on reusability**:  Before considering developing new application, review any existing application can be modified to cater to new business requirement. Reuse would promote carbon avoidance at first place. Also plan for periodic review of application components/modules that are no more required but are still part of application. <br>

**Minimize data movement**: Reduce the amount of data that needs to be transferred while processing request by co-locating application components closer that reduces the data transfer over wire and save energy. Data compression can also help in reducing the amount of data that needs to be transferred. Review API request and response parameters to minimize amount of data transfer. Prefer chunky API calls (which involves fewer requests with large requests) over chatty API calls ( frequent and small requests).  Checkout [SUS04-BP07 Minimize data movement across networks](https://docs.aws.amazon.com/wellarchitected/latest/sustainability-pillar/sus_sus_data_a8.html) for more details.<br>

**Use efficient software patterns**: While designing applications, choose efficient software designs and architectures. Using [Event-driven architectures](https://aws.amazon.com/what-is/eda/) can promote development team independence due to loose coupling between publishers and subscribers. This allows publishers and subscribers to change independently of each other, providing more flexibility to the overall architecture. [Microservices architecture](https://aws.amazon.com/microservices/) can help break application into independent services which can be developed, deployed, maintained and scaled independently. This also promoted polyglot programming model. <br>

**Choosing storage class**: Amazon S3(Simple Storage Service) is an object storage service offering industry-leading scalability, data availability, security, and performance. Amazon S3 provides different storage classes depends on data access patterns e.g., frequently accessed data, unknown or changing access pattern, long-lived but less frequently accessed data, long-term archive and digital preservation. Use the appropriate [Amazon S3  storage tier](https://aws.amazon.com/s3/storage-classes/) to reduce the carbon impact of your workload. Use energy-efficient, archival-class storage for infrequently accessed data. If you can easily recreate an infrequently accessed dataset, use the <em>Amazon S3 One Zone-IA</em> class to minimize the total data stored. Consider using [Amazon S3 Lifecycle](https://docs.aws.amazon.com/AmazonS3/latest/userguide/object-lifecycle-mgmt.html) configuration to manage objects throughout their lifecycle as well as limiting number of versions to be maintained. This help optimize storage resource utilization and reduce unnecessary storage capacity, contributing to sustainability efforts by minimizing resource waste.  <br>

**Choosing Database instances**: Amazon provide number of [purpose-built databases](https://aws.amazon.com/products/databases/) to choose from. Select the right database for your application workload e.g., Transactional, Analytical or Caching. This has direct impact on application performance and energy requirement. You can benefit from better price-performance with [AWS Graviton processors] (https://aws.amazon.com/ec2/graviton/) for running your databases. Using [Instance scheduler on AWS](https://aws.amazon.com/solutions/implementations/instance-scheduler-on-aws/) solution to automate the starting and stopping of RDS instances which will result in saving energy when there is no load on database (e.g., during night/weekend/holidays) and result in energy saving. <br>

**Evaluate external APIs and libraries**: There are scenarios when we need to call one or more third-party APIs for processing user requests. While evaluating external APIs and libraries for use within your application, consider the energy consumption, latency and amount of data transfer needed to call the external API. <br>

### Development

**Choose Energy efficient programming language**: Choose energy efficient programming languages for development.  5 most energy-efficient programming languages as suggested in [Energy Efficiency across Programming Languages](https://greenlab.di.uminho.pt/wp-content/uploads/2017/10/sleFinal.pdf) are C, C++, Java, Rust and Ada. Python is not a great option from energy efficiency perspective. Checkout [AWS re:Invent 2022 - Sustainability in the cloud with Rust and AWS Graviton (DOP315)](https://www.youtube.com/watch?v=HKAl4tSCp7o) for more details.<br>

**Remove or refactor workload components with low or no use**: Application requirements may change overtime and over the period of time of applications usage. Many times we leave the unused code uncommented and it results in energy waste to run the code block for each request. We should target to comment/remove any code blocks in the existing application which are no longer required. This will help in keeping the codebase smaller as well as makes it easier to maintain application. For more details, checkout [SUS03-BP02 Remove or refactor workload components with low or no use](https://docs.aws.amazon.com/wellarchitected/latest/sustainability-pillar/sus_sus_software_a3.html) page for more details.<br>


**Use appropriate caching solutions**: Caching helps improve application performance by faster data access as well as reducing load on backend servers. Depending on what you want to cache choose the appropriate service e.g., Amazon CloudFront (for web contents), Amazon ElastiCache (for database caching), Amazon File Cache (file system–based cache ) etc.<br>

### Testing

**Use automated testing**: Prefer automating testing over manual testing as later consumes time and energy. Focus on automating test cases that are repeated frequently. Automation can help in speeding up test cycle and minimize the energy and resource consumption associated with manual testing efforts.<br>


**Use managed Device farm**: AWS Device Farm is an application testing service that you can use to test and interact with your Android, iOS, and web apps on real, physical phones and tablets that are hosted by Amazon Web Services (AWS). Device Farm can also be used to execute Selenium tests on different desktop browsers and browser versions that are hosted in the AWS Cloud. Because testing is performed in parallel, tests on multiple devices begin in minutes. You can use AWS CodePipeline to configure a continuous integration flow in which your app is built and tested each time a commit is pushed. <br>

**Managing test artifacts**: Testing artifacts could include test cases, test scripts, test data and test outputs. Avoid storing test artifacts that can be easily generated. Once the testing is over, try to delete data and files (input, output, logs, test evidences) as they might take up lot of space and might not be referred again. Use appropriate S3 storage class for storing test outputs and Use S3 lifecycle policy to delete objects / move to archive class. <br>

### Deployment

**Automated deployment**: Using deployment pipelines to deploy workload in different environments helps to speed up deployment process and reduce errors related to manual deployment. Use [AWS CodePipeline](https://aws.amazon.com/codepipeline/) (or similar tools) to set up a Continuous Deployment Pipeline. <br>

**Automatically Scaling Infrastructure**: Always scale infrastructure to match demand (user load) and avoid overprovisioning resources to deliver the lowest environmental impact. Use dynamic scaling (e.g., target tracking scaling policies) based on target value for right Amazon CloudWatch metrics. AWS provides a range of auto scaling mechanism. Automatic scaling will also ensure that you scale down once the user load has decreased. Verify that scale-in events are working as expected without affecting end use experience. Refer to [SUS02-BP01 Scale workload infrastructure dynamically](https://docs.aws.amazon.com/wellarchitected/latest/sustainability-pillar/sus_sus_user_a2.html) for implementation guidance and steps. <br>


**Focus on automation and Infrastructure as code(IaC)**: By automating frequently repeated tasks, we can save overall time it takes to complete the task as well as avoid manual errors. This time saving is translated to energy savings (as compared to doing the task manually).  Using  [Infrastructure as code (IaC)](https://aws.amazon.com/what-is/iac/) to provision and manage your infrastructure. This reduces manual effort, minimizes resource waste, and allows you to scale up or down based on demand.  AWS services like [AWS Cloud Development Kit (AWS CDK)[(https://aws.amazon.com/cdk/)] and [AWS CloudFormation](https://aws.amazon.com/cloudformation/) can help with your IaC needs . <br>

**Choose right deployment model - managed / containerized**: Designing a deployment solution for your application is a critical part of building a well-architected application on AWS.  Containerized workloads can help provide isolated environment for running workloads with all required dependencies. Containerization can help to run multiple workloads in same host and thus help to reduce overall infrastructure required to run workloads.  We recommend that you use a managed service if there’s one available that meets your needs. Taking advantage of these services, rather than deploying them on your own, can save you a lot of the heavy lifting and allow you to focus on creating value for your business instead of dealing with operational work. [AWS container services](https://aws.amazon.com/containers/) provides an overview of various options available on AWS for managing containerized workloads.<br>

### Operation

**Keep your workload up to date**: Keeping your operating systems, libraries, and applications up to date improves workload efficiency and enables easier adoption of more efficient technologies. Up-to-date software may also include features that help measure the sustainability impact of your workload more accurately.<br>

**Configure Observability**: eriodically review your workload against the sustainability best practices to identify targets for improvements. Use [AWS Cost and Usage Reports (CUR)](https://docs.aws.amazon.com/cur/latest/userguide/what-is-cur.html) and  [AWS Customer Carbon Footprint Tool (CCFT)](https://aws.amazon.com/aws-cost-management/aws-customer-carbon-footprint-tool/) to identify hot spots that you can target to improve resource utilization and/or reduce the resource required to complete  a unit of work. While implementing improvements, identify metrics that can help to quantify the impact of improvement on associated resources (compute, storage, network resources etc.) provisioned for workload being reviewed. In scenarios when we don’t have direct metrics to help track specific improvement or it can be complex and costly to setup, we can rely on [Proxy metrics](https://aws.amazon.com/blogs/aws-cloud-financial-management/measure-and-track-cloud-efficiency-with-sustainability-proxy-metrics-part-i-what-are-proxy-metrics/) to monitor and analyze the performance of a system or workload.  Refer to the [Identifying Proxy Metrics for Sustainability Optimization](https://community.aws/posts/identifying-proxy-metrics-for-sustainability-optimization) for more information on proxy metrics. <br>


**Monitor Code size & Efficiency**: Review your code for code smells (unused code block that can be removed, duplicate code blocks that can be refactored to common function, unused variable declarations that can be removed, memory leaks, loops, switch statements etc.) and  remove them to reduce the overall execution for each request which invokes that code. Use services like [Amazon CodeGuru Reviewer](https://docs.aws.amazon.com/codeguru/latest/reviewer-ug/welcome.html) that performs code reviews and  provide actionable recommendations by analyzing runtime data.  [Amazon CodeGuru Profiler](https://docs.aws.amazon.com/codeguru/latest/profiler-ug/what-is-codeguru-profiler.html) can help to improve code efficiency. <br>

**Define Improvement process**: Sustainability improvement is a cyclic process and not a one time journey. With each iteration, try to identify area of improvement, define an improvement plan, implement and test improvement, and if successful plan for sharing your learnings with other project teams. Refer to [Improvement process](https://docs.aws.amazon.com/wellarchitected/latest/sustainability-pillar/improvement-process.html) for more details.<br>


**Keep up to date with latest best practices and guidelines on Sustainability**: Sustainability is everyone’s responsibility. There is lot of research happening on how we can reduce carbon footprint from IT development and operations. Organizations like Green Software foundation publishes best practices for creating and building green software. AWS also publishes [blogs](https://aws.amazon.com/blogs/architecture/category/sustainability/) covering wide range of topics on how organizations can leverage AWS cloud for their sustainability journey.<br>

**Perform periodic workload reviews**: Optimize your workloads with [Well-Architected for sustainability](https://docs.aws.amazon.com/wellarchitected/latest/sustainability-pillar/sustainability-pillar.html) to further cut carbon emissions and conserve energy . Optimization is not a onetime exercise hence consider periodic review of workloads and optimize as needed. Consider to move to managed services to remove undifferentiated heavy lifting. <br>


**Right-sized provisioning**: Right sizing is the process of matching instance types and sizes to your workload performance and capacity requirements. Right-sizing helps in better resource utilization and minimizing waste. Use Amazon CloudWatch to monitor workload and automatically adjusts capacity to maintain steady, predictable performance at the lowest possible cost. Avoid overprovisioning resources whenever possible. Use AWS Compute Optimizer to provide Amazon EC2 instance recommendations.  Always provision instances to match workload characteristics rather than choosing the general instances e.g., Choose compute-optimized( ideal for compute bound applications), storage-optimized (for IOPS requirement) or memory-optimized(process large data sets in memory) as per workload requirement. 
In the cloud, you have the flexibility to deprovision resources when you do not need them, and provision them when you do. Try not to overprovision resources and use metrics to decide when to provision/deprovision instances to match demand. Also, it is important to note that right sizing is not a one-time activity but an ongoing operation. Always try to test the recommendations in non-production environment first. <br>

**Manage workload assets:**: During development phase, we tend to spin up resources and leave them running even when they are no longer required. Plan to perform periodic analysis on resources and stop/decommission unused ones. Test environments are mostly used during daytime and are idle after office hours/weekends/holidays. If the test resources are not accessed 24/7, it would be recommended to turn them off when not in use.<br>

### Conclusion
Sustainability in the cloud is a continuous, focused effort on energy reduction and efficiency across all components of a workload. By following the various best practices related to sustainable-SDLC, we can help to ensure that running our workload doesn’t have negative impact on environment. Following these best practices can help in reducing cost of running workload in cloud. 
