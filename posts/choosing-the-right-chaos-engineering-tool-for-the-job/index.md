---
title: "Choosing The Right Chaos Engineering Tool for the Job"
description: Basic guide for choosing chaos engineering tools for your AWS workload
tags:
  - chaos-engineering
  - fault-injection-simulator
  - fault-injection-service
  - chaostoolkit
  - gremlin
  - resilience
waves:
    - resilience
spaces:
    - resilience
authorGithubAlias: user57231
authorName: Josh Henry and Charles-David Teboul
date: 2023-10-31
---
## Introduction

In an always-on, competitive marketplace, it is becoming increasingly important that your applications are always available by applying [resilience as a shared responsibility between AWS and the customer](https://docs.aws.amazon.com/whitepapers/latest/disaster-recovery-workloads-on-aws/shared-responsibility-model-for-resiliency.html?sc_channel=el&sc_campaign=resiliencewave&sc_geo=mult&sc_country=mult&sc_outcome=acq&sc_content=choosing-the-right-chaos-engineering-tool-for-the-job). Making your applications more resilient so they can withstand failures is a crucial activity for any company and isn’t a single time event or annual test, it requires continuous improvement. 

[Resilience](https://docs.aws.amazon.com/wellarchitected/latest/reliability-pillar/resiliency-and-the-components-of-reliability.html?sc_channel=el&sc_campaign=resiliencewave&sc_geo=mult&sc_country=mult&sc_outcome=acq&sc_content=choosing-the-right-chaos-engineering-tool-for-the-job) often requires redundancy and excess capacity to handle failures, which can be expensive and impact your carbon footprint. You may need to find tradeoffs between downtime tolerance, budget, and SLA goals. A balanced approach is to define business-driven RTO/RPO values and to architect for sufficient resilience while provisioning the environment.
Quickly restoring service after an outage requires resilient architecture and thorough [disaster recovery testing](https://docs.aws.amazon.com/whitepapers/latest/disaster-recovery-workloads-on-aws/testing-disaster-recovery.html?sc_channel=el&sc_campaign=resiliencewave&sc_geo=mult&sc_country=mult&sc_outcome=acq&sc_content=choosing-the-right-chaos-engineering-tool-for-the-job)

So how can you test for resilience to failures on a regular basis, and with some level of automation? Enter Chaos Engineering. In this article we will guide you through what Chaos Engineering is and why you need it. We will also introduce several tools available today, including AWS native service offerings, open source, and commercial options. 

Chaos engineering is a great addition to your resilience toolbox, and you won't need to be an expert to incorporate it into your organization.

## What is Chaos Engineering, and why might I want it?

Based on the pioneering work done by [Jesse Robbins](https://en.wikipedia.org/wiki/Jesse_Robbins) in the early days of [amazon.com](https://www.amazon.com/), then taken further by [Netflix’s Chaos Monkey](https://github.com/Netflix/chaosmonkey), chaos engineering is the operational practice of introducing disruption to a workload and discovering vulnerable parts to determine behavior based on a hypothesis. The goal is to observe how the workload responds by proactively injecting safe levels of faults, such as latency, or failure of underlying compute, networking databases, server errors and more. Based on observations, improvements can be made, ultimately causing the workload to become more reliable.
Chaos engineering helps developers easily setup and run controlled experiments across a range of AWS services and could be used to find blind spots and respond to infrequent but critical events.

There is no right or wrong when it comes to the environment where you run chaos experiments. When you are getting started, it’s recommended to run your experiments in pre-production to reduce the risk to your production workloads. Carelessly running chaos experiments in production could certainly lead to more downtime and reduced availability in the short-term, potentially impacting SLAs. Done properly however, finding weaknesses through chaos testing helps build more fault-tolerant systems that should improve availability and performance in the long run wihout impacting SLA.

The failure scenarios injected through chaos experiments are typically small-scale, localized events. But it's possible for an experiment to trigger unexpected cascading failures that could become impactful enough to impact production performance. In order to minimize impact on the business, check with all relevant stakeholders to establish sage parameters before running experiments in production and ensure your tools and processes support fast rollbacks of in-progress experiments.

Many think of chaos engineering as simply breaking a production environment on purpose at random times and in random ways. This is not the case. Chaos engineering is really just an additional part of the continuous improvement cycle that can also improve performance and should be planned for accordingly. To run a chaos experiment, you need the following:

* A known workload you want to test.
* A data driven hypothesis of how you expect a workload to respond to disruption.
* The type of disruption you want to introduce.
* A tool to run the experiment.

## Different failure scenario based on a resilient architecture


Let’s say you have a two tier application running on AWS as shown in Figure1. This uses [Route53](https://aws.amazon.com/route53/?sc_channel=el&sc_campaign=resiliencewave&sc_geo=mult&sc_country=mult&sc_outcome=acq&sc_content=choosing-the-right-chaos-engineering-tool-for-the-job) to direct client traffic to multiple web servers in a single [Availability Zone](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Concepts.RegionsAndAvailabilityZones.html?sc_channel=el&sc_campaign=resiliencewave&sc_geo=mult&sc_country=mult&sc_outcome=acq&sc_content=choosing-the-right-chaos-engineering-tool-for-the-job) (AZ) which are sized to accept 100% of peak load, and an [Amazon RDS](https://aws.amazon.com/rds/?sc_channel=el&sc_campaign=resiliencewave&sc_geo=mult&sc_country=mult&sc_outcome=acq&sc_content=choosing-the-right-chaos-engineering-tool-for-the-job) instance for the backend. We can start with a basic scenario to simulate loss of a single EC2 instance. Our hypothesis is that our application will remain available to end users due to having a second instance running the application which can accept the client connections. We have chosen [AWS Fault Injection Service](https://aws.amazon.com/fis/?sc_channel=el&sc_campaign=resiliencewave&sc_geo=mult&sc_country=mult&sc_outcome=acq&sc_content=choosing-the-right-chaos-engineering-tool-for-the-job) (FIS) as our chaos engineering tool for this experiment. We can setup an experiment to target a random EC2 instance out of a group by using tags. We do this using the FIS aws:ec2:stop-instances action. When we run the experiment, we find that half our clients lose connectivity to the application until they refresh, which is an unacceptable loss of service. We can now take this information to build out a more resilient architecture like that in Figure2 which might include an [Elastic Load Balancer](https://aws.amazon.com/elasticloadbalancing/?sc_channel=el&sc_campaign=resiliencewave&sc_geo=mult&sc_country=mult&sc_outcome=acq&sc_content=choosing-the-right-chaos-engineering-tool-for-the-job) and an [Autoscaling Group](https://docs.aws.amazon.com/autoscaling/ec2/userguide/auto-scaling-groups.html?sc_channel=el&sc_campaign=resiliencewave&sc_geo=mult&sc_country=mult&sc_outcome=acq&sc_content=choosing-the-right-chaos-engineering-tool-for-the-job). We then run the experiment again to validate the hypothesis based on the updated architecture, and continue to run it on a regular basis to confirm correct behavior going forward. 
For more information on using FIS to stop EC2 instances, please visit [here](https://docs.aws.amazon.com/fis/latest/userguide/fis-tutorial-stop-instances.html?sc_channel=el&sc_campaign=resiliencewave&sc_geo=mult&sc_country=mult&sc_outcome=acq&sc_content=choosing-the-right-chaos-engineering-tool-for-the-job)

### Figure1

![Figure1](images/figure1.png)

### Figure2

![Figure2](images/figure2a.png)

You can expand your chaos experiments to simulate the loss of an Availability Zone or even an entire AWS region.

An availability zone (AZ) failure refers to an outage or disruption that impacts a single AZ within an AWS region. When architecting fault tolerant systems, it's important to design your architecture to withstand the loss of an entire AZ. For example, distributing critical infrastructure across multiple AZs ensures that a failure in one AZ won't take down your entire application. To simulate a loss of power to an AZ during chaos testing, you need to consider the impact to many different resources running in that AZ that include networking, EC2 instances, Autoscaling Groups, RDS databases etc. Doing so allows you to validate that your system can maintain availability despite the loss of a single AZ. You can learn more about using FIS to simulate power loss to an AZ [here](https://docs.aws.amazon.com/fis/latest/userguide/az-availability-scenario.html?sc_channel=el&sc_campaign=resiliencewave&sc_geo=mult&sc_country=mult&sc_outcome=acq&sc_content=choosing-the-right-chaos-engineering-tool-for-the-job)

A region failure refers to a disruption that impacts an entire AWS region and causes sufficient service degredation in that single region that you would choose to serve customers from a different region instead. A region failure is a low probability event that most customers will never experience and as such result in a high impact event. Chaos engineering helps you prepare for even these unlikely scenarios. Because shifting service to a different region can take many forms depending on the disaster recovery option you choose, a common way to simulate a region failure is to simulate the loss of connectivity to an AWS region for chaos testing. For this you could disable all the API endpoints for a region or revoke access to the AWS accounts that host your resources in that region, and pause S3 and DynamoDB replication. Running such an extreme failure scenario ensures that you have disaster recovery plans to shift entirely to a separate region if needed. Testing region-level disasters will build confidence that you can maintain business continuity even during major outages. You can learn more about using FIS to simulate connectivity loss to a region [here](https://docs.aws.amazon.com/fis/latest/userguide/cross-region-scenario.html?sc_channel=el&sc_campaign=resiliencewave&sc_geo=mult&sc_country=mult&sc_outcome=acq&sc_content=choosing-the-right-chaos-engineering-tool-for-the-job)

The comparison chart towards the end of this article lists the chaos engineering tools can simulate the failure scenarios in the same or similar method described. 

## Tools available

There are a number of chaos engineering tools available today, and most will have at least some level of integration with AWS so they can be used to run experiments against your AWS workloads. In the following section we will introduce several options.

### Fault Injection Service

[Fault Injection Service (FIS)](https://aws.amazon.com/fis/?sc_channel=el&sc_campaign=resiliencewave&sc_geo=mult&sc_country=mult&sc_outcome=acq&sc_content=choosing-the-right-chaos-engineering-tool-for-the-job) is an AWS native, fully managed fault injection/chaos engineering service. FIS supports best practice chaos engineering parameters to make it easy to get started running experiments, without the need to install any agents. Sample experiments are available to use as a starting point. Fully managed fault injection actions are used to define actions such as stopping an instance, throttling an API, and failing over a database. Fault Injection Service supports [Amazon CloudWatch](https://aws.amazon.com/cloudwatch/?sc_channel=el&sc_campaign=resiliencewave&sc_geo=mult&sc_country=mult&sc_outcome=acq&sc_content=choosing-the-right-chaos-engineering-tool-for-the-job) so that you can use your existing metrics to monitor Fault Injection Service experiments. FIS also enables you to use CloudWatch metrics to abort impacting chaos engineering experiments. You do not need to know any special code or scripting language in order to use FIS out of the box.

As of today, FIS has native support for the following:

* AWS APIs
* Amazon CloudWatch
* Amazon EBS
* Amazon EC2
* Amazon ECS
* Amazon EKS
* AWS Networking
* Amazon RDS
* AWS Systems Manager

A full list of the current [supported fault injections can be found here](https://docs.aws.amazon.com/fis/latest/userguide/fis-actions-reference.html#fis-actions-reference-fis?sc_channel=el&sc_campaign=resiliencewave&sc_geo=mult&sc_country=mult&sc_outcome=acq&sc_content=choosing-the-right-chaos-engineering-tool-for-the-job).
FIS can be used for both simplistic scenarios like throttling a single EC2 instance CPU, to complex real-world scenarios to gradually and simultaneously impairing performance of different types of resources, APIs, services, and geographic locations. Affected resources can be randomized, and custom fault types can be created using [AWS Systems Manager](https://aws.amazon.com/systems-manager/?sc_channel=el&sc_campaign=resiliencewave&sc_geo=mult&sc_country=mult&sc_outcome=acq&sc_content=choosing-the-right-chaos-engineering-tool-for-the-job)to further increase complexity. You can setup guardrails to only affect resources with specific tags, and set rules based on CloudWatch alarms or other tools to stop an experiment. 
FIS is integrated with [AWS Identity and Access Management (IAM)](https://aws.amazon.com/iam/?sc_channel=el&sc_campaign=resiliencewave&sc_geo=mult&sc_country=mult&sc_outcome=acq&sc_content=choosing-the-right-chaos-engineering-tool-for-the-job) so you can control which users and resources have permission to access and run experiments, and which resources and services can be affected.
FIS provides visibility throughout every stage of an experiment via the AWS console and APIs. You can observe which actions have executed while an experiment is running, and view details of actions, stop conditions which were triggered, how metrics compared to your expected behavior, and more. You can use FIS from within the AWS console, AWS CLI, and [AWS SDKs](https://aws.amazon.com/developer/tools/?sc_channel=el&sc_campaign=resiliencewave&sc_geo=mult&sc_country=mult&sc_outcome=acq&sc_content=choosing-the-right-chaos-engineering-tool-for-the-job). You can access the FIS service programmatically to integrate experiments into your CI/CD pipelines.
You can get started with AWS FIS [here](https://docs.aws.amazon.com/fis/latest/userguide/what-is.html?sc_channel=el&sc_campaign=resiliencewave&sc_geo=mult&sc_country=mult&sc_outcome=acq&sc_content=choosing-the-right-chaos-engineering-tool-for-the-job)

### Chaos Toolkit

[Chaos Toolkit](https://chaostoolkit.org/) is an open source chaos engineering tool which you can use to run experiments against your AWS workloads. The chaostoolkit CLI is implemented in Python 3, so your team will need to have working knowledge of python to install the toolkit and to build and run your experiments.
Chaos Toolkit can be deployed locally, onto an EC2 instance, or in AWS Batch as a Docker image to run from inside your AWS environment. Extension modules for AWS have been added to Chaos Toolkit and can be found on [Github](https://github.com/chaostoolkit-incubator/chaostoolkit-aws). 
Each Chaos Toolkit Experiment is built around a single file using JSON. The JSON file will consist of the following sections:

* steady-state-hypothesis describes the normal state of your workload and checks before an experiment runs to make sure normal state is in place, and after the experiment runs to compare.
* method contains the actual experiment activities which will take place.
* action is the activity which will be applied to the workload during the experiment.
* probes define how to observe the workload during the experiment.
* controls are declared operational controls which affect the experiment execution.
* rollbacks define how to revert back to a normal state.

Not all sections are required to be filled out to run an experiment. For example, the [tutorial experiment](https://chaostoolkit.org/reference/tutorials/ec2/) for running Chaos Toolkit on EC2 provided by Chaos Toolkit has no method or rollback.
Experiments can be built using JSON to run AWS modules which call the AWS API to perform actions. Each experiment consists of Actions which are made operations against the workload, and Probes, which collect information from the workload during the experiment. 
Chaos Toolkit allows you to run a discovery which can be used to help build your experiments. After running an experiment you can generate a report as a PDF or HTML to view the results. 
Chaos Toolkit is suitable for more experienced teams who desire to run specific experiments against their AWS workloads, but requires a significant amount of hands-on. 
You can get started with Chaos Toolkit [here](https://chaostoolkit.org/reference/tutorial/)

### Gremlin

Gremlin is a commercial chaos engineering platform which uses agents to run experiments against EC2, ECS and EKS. Gremlin supports a wide range of experiments in three categories:

* Resource experiments targeting compute resources.
* Network experiments targeting network latency, packet loss, DNS, and certificates.
* State experiments targeting instance state, processes, and system time.

Gremlin allows you to monitor your experiments in real time with a central dashboard. You can run targeted experiments to run against specific instances, or randomized to target a random instance or container out of a group. Because Gremlin is a paid commercial product, there is extensive documentation and support to get started.
Gremlin does not have the same native AWS API integration as FIS or the extension modules like Chaos Toolkit. You can however create custom experiments to simulate scenarios like an AZ failure by dropping all network traffic or killing an application process. 
Gremlin is a good fit for a team which desires to run experiments against just their compute resources versus native AWS API integration to target managed services. A less experienced team can make use of the ease of use and minimal effort to get started. 
You can get started with Gremlin [here](https://www.gremlin.com/docs/reliability-management/quick-start-guide/)

### Comparison chart
Below is a feature comparison between the tools previously discussed, as of the date this article was posted. 

|	|AWS FIS	|Chaos Toolkit	|Gremlin	|
|---	|---	|---	|---	|
|License	|Pay-For-What-You-Use	|Open Source	|Commercial	|
|Deployment	|AWS Managed Service	|EC2, Docker container using AWS Batch	|Agent based on EC2, EKS	|
|Metrics/Scoring	|Yes (when integrated with AWS Resilience Hub)	|No	|Yes	|
|Custom experiments	|Yes	|Yes	|Yes	|
|Rollback	|Yes	|Yes	|Yes	|
|ECS/EKS	|Yes	|Yes	|Yes	|
|EC2	|Yes	|Yes	|Yes	|
|RDS failover	|Yes	|Yes	|No	|
|GUI	|Yes	|No	|Yes	|
|CLI	|Yes	|Yes	|Yes	|
|Application testing	|Yes	|No	|Yes	|
|Randomized target	|Yes	|Yes	|Yes	|
|Network testing	|Yes	|Yes	|Yes	|
|AZ failure	|Yes (Managed scenario from library to simulate complete AZ power interruption including loss of zonal compute, no re-scaling, subnet connectivity loss, RDS failover, Elasticache failover, unresponsive EBS volumes)	|Yes (Blackhole ACL, ELB target changes, ElastiCache failover, ActiveMQ failover)	|Yes (Blackhole ACL)	|
|Region failure	|Yes (Managed scenario from library to simulate loss of cross-region connectivity including pausing cross-region replication for S3 and DynamoDB)	|No	|Yes (Blackhole ACL)	|

## Conclusion

In summary, there are a growing number of tools available for chaos engineering, each with their own strengths and limitations. When evaluating chaos engineering tools, key factors to consider include the types of failures supported, integration with your specific infrastructure, automation capabilities, visualization and analytics, RBAC controls, and extensibility. Teams should evaluate trade-offs like complexity vs control when selecting a chaos tool and assess their resilience testing needs and map them to tool features accordingly. There is no one-size-fits-all solution, but using a combination of custom scripts and robust frameworks can provide comprehensive chaos coverage. As chaos engineering continues maturing, we can expect tools to become more interoperable, customizable, and intelligent. 
Thoughtfully incorporating the right chaos tools into your testing regimen will strengthen system resilience and improve incident response when outages strike.

In this article we shared with you what Chaos Engineering is and how it can be applied to your workloads on AWS. We dove into the use cases, features and limitations of various Chaos Engineering tools which are available today, and why you might choose each, depending on your workload and the goal of your chaos experiments. The goal of any tool is to help you achieve greater reliability for your workload, the choice comes down to which one will help you reach that goal easier, cheaper and faster. The experience of your team and the maturity of your AWS workload may also impact which tool you choose, as a more experienced team or a cloud native application may need more capability, or closer integration with AWS managed services. 

### Training

After reading this blog you might want to get some hands-on practice with chaos engineering. The best training option depends on your preferred learning style and depth of knowledge desired. we recommend starting with fundamental training like the [Chaos Engineering course](https://www.linkedin.com/learning/devops-foundations-chaos-engineering), [O'Reilly book](https://www.oreilly.com/library/view/chaos-engineering/9781492043850/), or [AWS re:Invent sessions](https://www.oreilly.com/library/view/chaos-engineering/9781492043850/) then progressing to hands-on workshops and conference sessions. Developing chaos engineering skills takes practice.

The AWS Well Architected Labs has a 300 level lab available [here](https://wellarchitectedlabs.com/reliability/300_labs/300_testing_for_resiliency_of_ec2_rds_and_s3/) which will walk you through multiple chaos experiments including EC2 instance failure, AZ failure, and RDS instance failover. The labs include both API script based experiments and Fault Injection Service experiments.

### External resources

- Chaos Engineering with AWS Fault Injection Service: [https://www.youtube.com/watch?v=AThR8dFmPP4](https://www.youtube.com/watch?v=AThR8dFmPP4)
- Chaos engineering leveraging AWS Fault Injection Service in a multi-account AWS environment: [https://aws.amazon.com/blogs/mt/chaos-engineering-leveraging-aws-fault-injection-simulator-in-a-multi-account-aws-environment/](https://aws.amazon.com/blogs/mt/chaos-engineering-leveraging-aws-fault-injection-simulator-in-a-multi-account-aws-environment/?sc_channel=el&sc_campaign=resiliencewave&sc_geo=mult&sc_country=mult&sc_outcome=acq&sc_content=choosing-the-right-chaos-engineering-tool-for-the-job)
- AWS Fault Injection Service blogs: [https://aws.amazon.com/blogs/devops/tag/aws-fault-injection-simulator/](https://aws.amazon.com/blogs/devops/tag/aws-fault-injection-simulator/?sc_channel=el&sc_campaign=resiliencewave&sc_geo=mult&sc_country=mult&sc_outcome=acq&sc_content=choosing-the-right-chaos-engineering-tool-for-the-job)
- How Finbourne Assures Resiliency Through Chaos Engineering Events Every 17 min: [https://www.youtube.com/watch?v=lkDq9g43djw](https://www.youtube.com/watch?v=lkDq9g43djw)
- DPG Media Successfully Launches Video On Demand Service with Gremlin and AWS: [https://aws.amazon.com/partners/success/dpg-media-gremlin/?did=ps_card&trk=ps_card](https://aws.amazon.com/partners/success/dpg-media-gremlin/?sc_channel=el&sc_campaign=resiliencewave&sc_geo=mult&sc_country=mult&sc_outcome=acq&sc_content=choosing-the-right-chaos-engineering-tool-for-the-job)
