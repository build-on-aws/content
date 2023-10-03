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
    - eks-with-efs-add-on
    - managing-high-volume-batch-sqs-eks
    - eks-cluster-batch-processing
    - eks-monitor-containerized-applications
    - automating-dns-records-for-microservices-using-externaldns
--- 
|ToC|
|---|

## Unlock the potential of Amazon EKS across a spectrum of Kubernetes workloads, from microservices to batch processing, with our step-by-step tutorials.

Migrating to Amazon Elastic Kubernetes Service (EKS) opens up new possibilities, but the sheer number of choices can feel overwhelming initially. You find yourself facing questions around IAM roles, networking, autoscaling, and compute options.  Whether you're building a real-time analytics engine with auto-scaling or you want to enable sophisticated logging mechanisms, the decisions seem endless.

This series aims to bridge the gap between Amazon EKS and the world of open-source Kubernetes integrations, offering you a comprehensive guide to navigate the myriad of choices you'll encounter—be it AWS-specific drivers, controllers, or even integrating AWS services into your Kubernetes workloads. In collaboration with cloud experts, we offer opinionated, real-world learning paths that guide you from one tutorial to the next for each Kubernetes use case. This modular design gives you the freedom to customize your journey and choose configurations that suit your needs. From guiding you in crafting a cluster using IaC ‘quickstart’ templates, to seamlessly integrating AWS services and add-ons, we lead you all the way to real-world operational readiness.

**📚 Keep this page on your radar**! We'll regularly update it with new tutorials addressing a wide range of use-cases. Your feedback matters—take our survey provided in each tutorial to influence our tutorial and product roadmap.

## **What You Will Learn**

* **Boost Capabilities**: Explore a wide array of EKS-managed and self-managed add-ons to augment your Kubernetes workloads, including the use of the EFS CSI Driver for stateful batch operations.
* **Fortify Security**: Master the intricacies of safeguarding your cloud environment through AWS services, utilizing IAM Roles for Service Accounts (IRSAs) and OpenID Connect (OIDC) for secure access points.
* **Optimize Costs**: Evaluate and select the most suitable auto-scaling mechanisms tailored to your unique Kubernetes workloads, such as Karpenter for compute-heavy batch and machine learning tasks.
* **Tailor Compute Resources**: Determine the Amazon EC2 instance types that best match your Kubernetes projects, whether focused on batch processing or microservices.
* **Configure Data Storage**: Gain insights on setting up persistent data storage and creating volume snapshots with AWS-backed Container Storage Interfaces (CSIs).
* **Monitor Operations**: Utilize monitoring solutions like Amazon CloudWatch Container Insights for an exhaustive view of your containerized applications' performance.
* **Implement Networking**: Opt for either public or private IPv4/IPv6 network configurations within a VPC, enabled by Infrastructure as Code (IaC) frameworks.
* **Deploy Applications**: Gain a hands-on understanding of the necessary custom annotations for your Kubernetes workloads using sample applications, or build from the ground up and deploy a multi-architecture container image onto Amazon Elastic Container Registry (ECR).

## **Road Map to the Cloud**

Navigating the cloud ecosystem with Amazon EKS is like assembling a complex puzzle, where every piece is a crucial lego block for secure, high-performing, and efficient operations. To make your cloud adoption journey a little more digestible, each tutorial guides you through a few stages. Here's how we've structured your roadmap to the cloud:

### Stage 1: Create Pre-configured Clusters

These tutorials guide you through the process of building Amazon EKS clusters pre-configured for specific Kubernetes workloads. You'll start by setting up essential components like VPCs, drivers, controllers, and IAM Service Accounts (IRSAs), laying the groundwork for future cloud-based applications and resource deployments.

The following tutorials are included in this stage:

* [Building an IPv6-based EKS Cluster for Globally Scalable Applications](/tutorials/navigating-amazon-eks/eks-cluster-ipv6-globally-scalable)
* [Building an Amazon EKS Cluster Preconfigured to Run Asynchronous Batch Tasks](/tutorials/navigating-amazon-eks/eks-cluster-batch-processing)
* [Building an Amazon EKS Cluster Preconfigured to Run High Traffic Microservices](/tutorials/navigating-amazon-eks/eks-cluster-high-traffic)

### Stage 2: Enhance and Extend Cluster Capabilities

These tutorials focus on the installation and configuration of essential drivers, controllers, and other foundational components for your EKS cluster. They serve as prerequisites for deploying Kubernetes workloads and for extending your cluster with additional AWS services and features.

The following tutorials are included in this stage:

* [Designing Scalable and Versatile Storage Solutions on Amazon EKS with the Amazon EFS CSI](/tutorials/navigating-amazon-eks/eks-with-efs-add-on/)
* [Dynamic Database Storage with the Amazon EBS CSI Driver for Amazon EKS](/tutorials/navigating-amazon-eks/eks-dynamic-db-storage-ebs-csi)
* [Exposing and Grouping Applications Using the AWS Load Balancer Controller on an Amazon EKS IPv4 Cluster](/tutorials/navigating-amazon-eks/eks-cluster-load-balancer-ipv4)
* [Exposing and Grouping Applications Using the AWS Load Balancer Controller (LBC) on an Amazon EKS IPv6 Cluster](/tutorials/navigating-amazon-eks/eks-cluster-load-balancer-ipv6)

### Stage 3: Optimize and Integrate with AWS Services

These tutorials guide you through optimizing the operational aspects of your EKS clusters and seamlessly integrating them with additional AWS services. You'll build upon foundational elements to master cloud sustainability using tools and services like Prometheus, Amazon CloudWatch, or AWS Batch.

The following tutorials are included in this stage:

* [Automatically Manage DNS Records for Your Microservices in Amazon EKS with ExternalDNS](/tutorials/navigating-amazon-eks/automating-dns-records-for-microservices-using-externaldns/)
* [Easily Monitor Containerized Applications with Amazon CloudWatch Container Insights](/tutorials/navigating-amazon-eks/eks-monitor-containerized-applications)
* [Managing Asynchronous Tasks with SQS and EFS Persistent Storage in Amazon EKS](/tutorials/navigating-amazon-eks/managing-high-volume-batch-sqs-eks)

## List of all Tutorials

|SeriesToC|
|---------|
