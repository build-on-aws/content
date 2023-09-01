---
title: "Building an Amazon EKS Cluster Preconfigured to Run High Traffic Microservices"
description: "Deploy a preconfigured Amazon EKS cluster optimized for high-demand microservice applications using an eksctl \"quickstart\" template."
tags:
    - eks-cluster-setup
    - eks
    - kubernetes
    - tutorials
    - aws
showInHomeFeed: true
waves:
  - modern-apps
spaces:
  - kubernetes
  - modern-apps
authorGithubAlias: berry2012
authorName: Olawale Olaleye
date: 2023-08-29
---

The modern digital landscape thrives on high traffic platforms, such as bustling online marketplaces, media streaming services, and real-time data analytics applications. These platforms often face unpredictable surges in user activity, like a sudden influx of ticket sales due to a concert announcement or a streaming service being swamped during a much-anticipated series premiere. Such scenarios require an architecture that can dynamically scale and swiftly recover from failures. Microservices are key to meeting these demands, but the real challenge lies in their efficient orchestration. Amazon EKS stands out as a solution, offering streamlined deployment and scaling of services, allowing each one to independently handle spikes without affecting others. With the robust support of AWS's infrastructure, Amazon EKS ensures both performance and reliability.

This tutorial shows you how to create a managed node groups-based Amazon EKS cluster using an [eksctl](https://eksctl.io/) “quickstart” template. This use case-specific template creates and sets up a cluster preconfigured and ready to run your dynamic frontends, such as interactive web dashboards, and data-intensive backends, such as analytics engines or recommendation systems.

| Attributes             |                                                                 |
|------------------------|-----------------------------------------------------------------|
| ✅ AWS experience      | 200 - Intermediate                                              |
| ⏱ Time to complete     | 30 minutes                                                      |
| 🧩 Prerequisites       | - [AWS Account](https://aws.amazon.com/resources/create-account/?sc_channel=el&sc_campaign=appswave&sc_content=eks-cluster-high-traffic&sc_geo=mult&sc_country=mult&sc_outcome=acq)|
| 📢 Feedback            | <a href="https://www.pulse.aws/survey/Z8XBGQEL" target="_blank">Any feedback, issues, or just a</a> 👍 / 👎 ?    |
| ⏰ Last Updated        | 2023-08-29                                                      |

| ToC |
|-----|

## Prerequisites

Before you begin this tutorial, you need to:

* Install the latest version of [kubectl](https://kubernetes.io/docs/tasks/tools/#kubectl). To check your version, run: `kubectl version --short`.
* Install the latest version of [eksctl](https://eksctl.io/introduction/#installation). To check your version, run: `eksctl info`.

## Overview

This tutorial is the first part of a series on managing high traffic microservices platforms using Amazon EKS, and it's dedicated to preconfiguring a cluster with the components it needs to run microservice applications with data-intensive workloads. Using the eksctl cluster template that follows, you'll build a robust, scalable, and secure Amazon EKS cluster with [managed node groups](https://docs.aws.amazon.com/eks/latest/userguide/managed-node-groups.html?sc_channel=el&sc_campaign=appswave&sc_content=eks-cluster-high-traffic&sc_geo=mult&sc_country=mult&sc_outcome=acq). This template not only enables application workloads but also fortifies the cluster with an additional layer of security, fully aligned with best practices for production environments. It configures the following components:

* **Autoscaling**: Managed node groups use an "m5.large" [instance type](https://docs.aws.amazon.com/eks/latest/userguide/choosing-instance-type.html?sc_channel=el&sc_campaign=appswave&sc_content=eks-cluster-high-traffic&sc_geo=mult&sc_country=mult&sc_outcome=acq), providing a balance of resources. With a minimum size of "2" and a maximum size of "5", node groups can dynamically scale. The volume size is set to "100", ensuring ample capacity, and required subnet tags allow the [Kubernetes Cluster Autoscaler (CA)](https://github.com/kubernetes/autoscaler) to dynamically scale your cluster. 
* **Authentication**: Necessary IAM Roles for Service Accounts (IRSAs) mappings to enable communication between Kubernetes pods and AWS services. This includes the [AWS Load Balancer Controller (LBC)](https://kubernetes-sigs.github.io/aws-load-balancer-controller/) used to expose applications, [Amazon EFS CSI Driver](https://github.com/kubernetes-sigs/aws-efs-csi-driver) for persistent data storage, [Kubernetes External DNS](https://github.com/kubernetes-sigs/external-dns) to automatically manage DNS records, and [Cert Manager](https://cert-manager.io/) to streamline management of SSL/TLS certificates. Additionally, an [OpenID Connect (OIDC) endpoint](https://docs.aws.amazon.com/eks/latest/userguide/enable-iam-roles-for-service-accounts.html?sc_channel=el&sc_campaign=appswave&sc_content=eks-cluster-high-traffic&sc_geo=mult&sc_country=mult&sc_outcome=acq) enables seamless and secure communication.
* **Add-ons**: Latest versions of the following [add-ons](https://docs.aws.amazon.com/eks/latest/userguide/eks-add-ons.html#workloads-add-ons-available-eks?sc_channel=el&sc_campaign=appswave&sc_content=eks-cluster-high-traffic&sc_geo=mult&sc_country=mult&sc_outcome=acq), including "vpc-cni" to enable the Amazon VPC Container Network Interface, "coredns" to facilitate DNS resolution, "kube-proxy" to maintain network rules on each Amazon EC2 node, and the [EBS CSI Driver Add-On](https://docs.aws.amazon.com/eks/latest/userguide/managing-ebs-csi.html?sc_channel=el&sc_campaign=appswave&sc_content=eks-cluster-high-traffic&sc_geo=mult&sc_country=mult&sc_outcome=acq).
* **Public/Private Networking**: Managed node groups utilize private networking and a NAT gateway to bolster security by limiting direct internet access. The AWS Load Balancer Controller (LBC) manages and securely distributes all incoming web traffic to private subnets.
* **Monitoring**: An [Amazon CloudWatch](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/WhatIsCloudWatch.html?sc_channel=el&sc_campaign=appswave&sc_content=eks-cluster-high-traffic&sc_geo=mult&sc_country=mult&sc_outcome=acq) IAM policy is attached to the IAM Role for Service Account (IRSA), aiding optional components like [CloudWatch Container Insights](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/ContainerInsights.html?sc_channel=el&sc_campaign=appswave&sc_content=eks-cluster-high-traffic&sc_geo=mult&sc_country=mult&sc_outcome=acq) to collect and summarize metrics and logs.

>Note that if you're still within your initial 12-month AWS Free Tier period, certain Amazon EC2 instances for managed node groups and additional AWS services may not be included in the Free Tier, and charges may apply based on your usage.

## Step 1: Configure the Cluster

In this section, you will configure the Amazon EKS cluster to meet the specific demands of high-traffic microservice applications. By creating this `cluster-config.yaml` file, you'll define the settings for IAM roles, scalable resources, private networking, and monitoring. These configurations are essential for ensuring that the cluster is robust, scalable, and secure, with optimized performance for dynamic scalability and data persistence.

### To Create the Cluster Config

1. Create a `cluster-config.yaml` file and paste the following contents into it. Replace the `region` with your preferred region. 

```yaml
apiVersion: eksctl.io/v1alpha5
kind: ClusterConfig

metadata:
  name: managednodes-quickstart
  region: us-east-2
  version: "1.27"
  tags:
    # Add more cloud tags if needed for billing
    environment: managednodes-quickstarts


# The IAM section is for managing IAM roles and service accounts for your cluster.
iam:
  withOIDC: true
  serviceAccounts:
  - metadata:
  # Service account used by Container Insights. (See https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/Container-Insights-prerequisites.html)  
      name: cloudwatch-agent
      namespace: amazon-cloudwatch
      labels: {aws-usage: "container-insights"}
    attachPolicyARNs:
    - "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"    
  - metadata:
      # Service account used by the AWS Load Balancer Controller.
      name: aws-load-balancer-controller
      namespace: kube-system
    wellKnownPolicies:
      awsLoadBalancerController: true    
  - metadata:
  # Service account used by Amazon EFS CSI driver. (See https://docs.aws.amazon.com/eks/latest/userguide/efs-csi.html)
      name: efs-csi-controller-sa
      namespace: kube-system
    wellKnownPolicies:
      efsCSIController: true
  - metadata:
  # Service account used by External DNS. (See https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.5/guide/integrations/external_dns/)
      name: external-dns
      namespace: kube-system
    wellKnownPolicies:
      externalDNS: true
  - metadata:
  # Service account used by Certificate Manager. (See https://cert-manager.io/docs/installation/)
      name: cert-manager
      namespace: cert-manager
    wellKnownPolicies:
      certManager: true   
  - metadata:
  # Service account used by Cluster Auto-scaler. (See https://github.com/kubernetes/autoscaler/blob/master/cluster-autoscaler/cloudprovider/aws/CA_with_AWS_IAM_OIDC.md)
      name: cluster-autoscaler
      namespace: kube-system
      labels: {aws-usage: "autoscaling-worker-nodes"}
    wellKnownPolicies:
      autoScaler: true


managedNodeGroups:
  - name: managed-ng
    instanceType: m5.large
    minSize: 2
    desiredCapacity: 3
    maxSize: 5
    # launch nodegroup in private subnets
    privateNetworking: true
    volumeSize: 100
    volumeType: gp3
    # Encrypt Worker Nodes Amazon EBS Volumes by default
    volumeEncrypted: true
    labels: 
      node-class: "production-workload" 
      role: "worker"   
    tags:
      nodegroup-role: worker
      env: prod     
      # EC2 tags required for cluster-autoscaler auto-discovery - these tags are automatically applied to a managed nodegroup autoscaling group
      k8s.io/cluster-autoscaler/enabled: "true"
      k8s.io/cluster-autoscaler/managednodes-quickstart: "owned"      

addons:
  - name: vpc-cni # no version is specified so it deploys the default version
    attachPolicyARNs:
      - arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy
  - name: coredns
    version: latest # auto discovers the latest available
  - name: kube-proxy
    version: latest
  - name: aws-ebs-csi-driver
    wellKnownPolicies:      # add IAM and service account
      ebsCSIController: true


cloudWatch:
 clusterLogging:
   enableTypes: ["*"]
    # Sets the number of days to retain the logs for (see [CloudWatch docs](https://docs.aws.amazon.com/AmazonCloudWatchLogs/latest/APIReference/API_PutRetentionPolicy.html#API_PutRetentionPolicy_RequestSyntax)).
    # By default, log data is stored in CloudWatch Logs indefinitely.
   logRetentionInDays: 60
```

## Step 2: Create the Cluster

Now, we're ready to create our Amazon EKS cluster. This process takes several minutes to complete. If you'd like to monitor the status, see the [AWS CloudFormation](https://console.aws.amazon.com/cloudformation?sc_channel=el&sc_campaign=appswave&sc_content=eks-cluster-high-traffic&sc_geo=mult&sc_country=mult&sc_outcome=acq) console.

1. Create the EKS cluster using the `cluster-config.yaml`.

```bash
eksctl create cluster -f cluster-config.yaml
```

Upon completion, you should see the following response output:

```text
2023-08-26 08:59:54 [✔]  EKS cluster "managednodes-quickstart" in "us-east-2" region is ready
```

When the previous command completes, verify that all of your nodes have reached the `Ready` state with the following command:

```bash
kubectl get nodes
```

The expected output should look like this:

```text
NAME                                            STATUS   ROLES    AGE   VERSION
ip-192-168-119-7.us-east-2.compute.internal     Ready    <none>   27m   v1.27.4-eks-8ccc7ba
ip-192-168-141-57.us-east-2.compute.internal    Ready    <none>   19m   v1.27.4-eks-8ccc7ba
ip-192-168-177-109.us-east-2.compute.internal   Ready    <none>   19m   v1.27.4-eks-8ccc7ba
```

## Step 3: Verify Cluster Node and Pod Health

Verify that the Amazon EBS CSI Driver was successfully installed with the following command:

```bash
kubectl get deployment ebs-csi-controller -n kube-system
```

The expected output should look like this:

```text
NAME                 READY   UP-TO-DATE   AVAILABLE   AGE
ebs-csi-controller   2/2     2            2           15m
```

Verify all the service accounts created in the cluster with the following command:

```bash
 kubectl get sa -A | egrep "cert-manager|efs|aws-load|external|cloudwatch-agent|cluster-autoscaler"
```

The expected output should look like this:

```text
amazon-cloudwatch   cloudwatch-agent                     0         43m
cert-manager        cert-manager                         0         43m
cert-manager        default                              0         43m
kube-system         aws-load-balancer-controller         0         42m
kube-system         cluster-autoscaler                   0         43m
kube-system         efs-csi-controller-sa                0         43m
kube-system         external-dns                         0         43m
```

**Congratulations!** You've successfully set up the foundational infrastructure of your Amazon EKS cluster, laying the essential groundwork for deploying high-traffic microservices workloads. This setup provides you with the groundwork needed to begin deploying applications, but keep in mind that additional configurations are required for a fully optimized, production-ready environment.

## (Optional) Deploy a Sample Application

Now, we’re all set to launch a sample application and enable its accessibility on the internet through an Application Load Balancer (ALB). For step-by-step guidance, check out the tutorial at [Exposing and Grouping Applications using the AWS Load Balancer Controller (LBC) on an EKS IPv4 Cluster](/tutorials/eks-cluster-load-balancer-ipv4). This tutorial will guide you through the required Ingress annotations for the AWS LBC, an essential mechanism for controlling external access to services within an EKS cluster. You’ll also explore Ingress Groupings, a sophisticated feature that amalgamates multiple Ingress resources into one ALB, enhancing both efficiency and ALB management.

## Clean Up

To avoid incurring future charges, you should delete the resources created during this tutorial. You can delete the EKS cluster with the following command:

```bash
eksctl delete cluster -f ./cluster-config.yaml
```

Upon completion, you should see the following response output:

```text
2023-08-26 17:26:44 [✔]  all cluster resources were deleted
```

## Conclusion

In this tutorial, you've not only successfully set up an Amazon EKS cluster optimized for deploying microservice applications but also laid the foundation for a seamless integration between AWS and Kubernetes. By configuring the necessary IAM Roles for Service Accounts (IRSAs), node groups, and other essential components, you've established the infrastructure that ensures smooth communication with AWS services and drivers needed to run high-traffic microservices. To fully leverage your new setup, remember that the installation of the [ExternalDNS](https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.5/guide/integrations/external_dns/), [Cluster Autoscaler](https://github.com/kubernetes/autoscaler/blob/master/cluster-autoscaler/cloudprovider/aws/CA_with_AWS_IAM_OIDC.md), [Container Insights](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/deploy-container-insights-EKS.html?sc_channel=el&sc_campaign=appswave&sc_content=eks-cluster-high-traffic&sc_geo=mult&sc_country=mult&sc_outcome=acq), and [AWS Load Balancer Controller](https://docs.aws.amazon.com/eks/latest/userguide/aws-load-balancer-controller.html?sc_channel=el&sc_campaign=appswave&sc_content=eks-cluster-high-traffic&sc_geo=mult&sc_country=mult&sc_outcome=acq) are still required. With these final installations, you'll have a robust, fully operational environment ready for your microservice application deployment, all while taking advantage of the unique strengths of both Amazon EKS and Kubernetes.
