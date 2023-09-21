---
title: "Navigating Amazon EKS"
description: "A Curated Collection of Hands-On Tutorials"
navigationBars: none
posts:
    - eks-cluster-load-balancer-ipv4
    - eks-cluster-load-balancer-ipv6
    - eks-cluster-ipv6-globally-scalable
    - eks-dynamic-db-storage-ebs-csi
    - eks-cluster-high-traffic
--- 
|ToC|
|---|

## Unlock the potential of Amazon EKS across a spectrum of Kubernetes workloads, from microservices to batch processing, with our step-by-step tutorials.

Migrating to Amazon Elastic Kubernetes Service (EKS) opens up new possibilities, but the sheer number of choices can feel overwhelming initially. You find yourself facing questions around IAM roles, networking, autoscaling, and compute options.  Whether you're building a real-time analytics engine with auto-scaling or you want to enable sophisticated logging mechanisms, the decisions seem endless.

Streamline your voyage through the cloud with our curated EKS tutorials, designed as a structured learning path to ease the learning curve and maximize EKS' capabilities across diverse Kubernetes workloads. In collaboration with cloud experts, we offer prescriptive deployments that connect you from one tutorial to the next. This modular design gives you the freedom to customize your journey and choose configurations that suit your needs. From guiding you in crafting a cluster using IaC ‘quickstart’ templates, to seamlessly integrating AWS services and add-ons, we lead you all the way to real-world operational readiness.

**📚 Keep this page on your radar**! We'll regularly update it with new tutorials addressing a wide range of use-cases. Your input matters—take our survey provided in each tutorial to influence our tutorial and product roadmap.

## **What You Will Learn**

* **Boost Capabilities**: Explore a wide array of EKS-managed and self-managed add-ons to augment your Kubernetes tasks, including the use of the EFS CSI Driver for stateful batch operations.
* **Fortify Security**: Master the intricacies of safeguarding your cloud environment through AWS services, utilizing IAM Roles for Service Accounts (IRSAs) and OpenID Connect (OIDC) for secure access points.
* **Scale Dynamically**: Evaluate and select the most suitable auto-scaling mechanisms tailored to your unique Kubernetes workloads, such as Karpenter for compute-heavy batch and machine learning tasks.
* **Optimize Compute Resources**: Determine the Amazon EC2 instance types that best match your Kubernetes projects, whether focused on batch processing or microservices.
* **Configure Data Storage**: Gain insights on setting up persistent data storage through AWS-backed Container Storage Interfaces (CSIs).
* **Monitor Operations**: Utilize monitoring solutions like Amazon CloudWatch Container Insights for an exhaustive view of your containerized applications' performance.
* **Implement Networking**: Opt for either public or private IPv4/IPv6 network configurations within a VPC, enabled by Infrastructure as Code (IaC) frameworks.
* **Deploy Applications**: Acquire practical skills through deploying multi-architecture containers via Amazon Elastic Container Registry (ECR) and other sample applications onto Amazon EKS.

## **Road Map to the Cloud**

Navigating the cloud ecosystem with Amazon EKS is like assembling a complex puzzle, where every piece is a crucial lego block for secure, high-performing, and efficient operations. To make your cloud adoption journey a little more digestible, this tutorial series adopts a pragmatic three-stage approach. For starters, we use Infrastructure as Code (IaC) templates and opinionated, hands-on deployments to significantly flatten your learning curve. Here's how we've structured your roadmap to the cloud:

### Stage 1: Pre-configured Clusters

Here, you'll create a new Amazon EKS cluster pre-configured to run specific Kubernetes workloads using an Infrastructure as Code (IaC) template. From the get-go, you'll configure essential components like VPCs, drivers, controllers, and IAM Service Accounts (IRSAs). These tutorials lay the foundation for cloud-based application and resource deployment in subsequent stages.

The following tutorials are included in this stage:

* [Building an IPv6-based EKS Cluster for Globally Scalable Applications](/tutorials/eks-cluster-ipv6-globally-scalable)
* [Building an Amazon EKS Cluster Preconfigured to Run High Traffic Microservices](/tutorials/eks-cluster-high-traffic)

### Stage 2: Setup and Application Deployment

These tutorials delve into the Amazon EKS ecosystem, exploring add-ons and AWS service integrations. You'll discover how to enhance your EKS clusters with AWS-specific features, leveraging the full AWS toolkit for a robust cloud experience.

The following tutorials are included in this stage:

* [Dynamic Database Storage with the Amazon EBS CSI Driver for Amazon EKS](/tutorials/eks-dynamic-db-storage-ebs-csi)
* [Exposing and Grouping Applications Using the AWS Load Balancer Controller on an Amazon EKS IPv4 Cluster](/tutorials/eks-cluster-load-balancer-ipv4)
* [Exposing and Grouping Applications Using the AWS Load Balancer Controller (LBC) on an Amazon EKS IPv6 Cluster](/tutorials/eks-cluster-load-balancer-ipv6)

### Stage 3: Operational Readiness

These tutorials dive into the operational core of your EKS clusters, focusing on the components you put in place for clusters in production. You'll master the facets of cloud sustainability from using Amazon CloudWatch for seamless monitoring to DNS record automation with ExternalDNS, capitalizing on AWS services for a resilient operational foundation.

Tutorials coming soon!

## List of all Tutorials

|SeriesToC|
|---------|