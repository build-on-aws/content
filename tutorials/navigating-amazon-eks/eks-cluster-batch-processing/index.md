---
title: "Building an Amazon EKS Cluster Preconfigured to Run Asynchronous Batch Tasks"
description: "Deploy a preconfigured Amazon EKS cluster tailored for asynchronous background tasks, enhanced with scalable data storage solutions using an eksctl 'quickstart' template."
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
authorGithubAlias: ahmadt312
authorName: Ahmad Tariq
date: 2023-09-30
---

In the diverse ecosystem of cloud-native applications, there are times when real-time interactivity or immediate responses aren't your prime directive. Instead, the crux lies in executing asynchronous background tasks with precision and efficiency. Whether you're transferring large files, harmonizing disparate datasets, or orchestrating complex job schedules, you need an environment built to handle workload fluctuations and optimized for resource utilization. With Amazon EKS, the EFS CSI Driver for scalable storage, and the Cluster Autoscaler for automated scaling policies, you can effortlessly establish an EKS cluster that is not only optimized for asynchronous operations but also adapts intelligently to workload demands.

This tutorial shows you how to create a managed node groups-based Amazon EKS cluster using an [eksctl](https://eksctl.io/) “quickstart” template. The cluster is designed to integrate seamlessly with Amazon SQS for decoupled job orchestration and Amazon EFS for persistent, scalable storage, setting the stage for the advanced use-cases explored in the next part of this series.


| Attributes             |                                                                 |
|------------------------|-----------------------------------------------------------------|
| ✅ AWS experience      | 200 - Intermediate                                              |
| ⏱ Time to complete     | 30 minutes                                                      |
| 🧩 Prerequisites       | - [AWS Account](https://aws.amazon.com/resources/create-account/?sc_channel=el&sc_campaign=appswave&sc_content=eks-cluster-high-traffic&sc_geo=mult&sc_country=mult&sc_outcome=acq)|
| 📢 Feedback            | <a href="https://www.pulse.aws/survey/Z8XBGQEL" target="_blank">Any feedback, issues, or just a</a> 👍 / 👎 ?    |
| ⏰ Last Updated        | 2023-09-30                                                     |

| ToC |
|-----|

## Prerequisites

Before you begin this tutorial, you need to:

* Install the latest version of [kubectl](https://kubernetes.io/docs/tasks/tools/#kubectl). To check your version, run: `kubectl version --short`.
* Install the latest version of [eksctl](https://eksctl.io/introduction/#installation). To check your version, run: `eksctl info`.

## Overview

This tutorial is the first installment in a series focused on optimizing Amazon EKS for batch processing workloads. It aims to guide you through the preconfiguration of a cluster equipped to handle small- to medium-scale asynchronous background tasks, using an eksctl 'quickstart' template. This template not only facilitates the execution of batch jobs but also adds an extra layer of security, aligning with best practices for production deployments. The template configures the following components:

* **Autoscaling**: The managed node groups in this setup use a "c5a.xlarge" [instance type](https://docs.aws.amazon.com/eks/latest/userguide/choosing-instance-type.html?sc_channel=el&sc_campaign=appswave&sc_content=eks-cluster-high-traffic&sc_geo=mult&sc_country=mult&sc_outcome=acq), ideal for compute-bound applications that benefit from high performance processors and well-suited for batch processing workloads. With a minimum size of "3" and a maximum size of "6", these node groups can dynamically adapt to workload demands. The subnet tags allow the [Kubernetes Cluster Autoscaler (CA)](https://github.com/kubernetes/autoscaler) to dynamically scale your cluster on demand.
* **Authentication**: Necessary IAM Roles for Service Accounts (IRSAs) mappings to enable communication between Kubernetes pods and AWS services. This includes the [Kubernetes Cluster Autoscaler (CA)](https://github.com/kubernetes/autoscaler) for dynamic scaling, [Amazon ECR](https://docs.aws.amazon.com/AmazonECR/latest/userguide/what-is-ecr.html) for private repository access of container images, essential for batch workloads, the [Amazon EBS CSI Driver](https://docs.aws.amazon.com/eks/latest/userguide/ebs-csi.html) for block-level persistent data storage, [Amazon EFS CSI Driver](https://docs.aws.amazon.com/eks/latest/userguide/efs-csi.html) for shared file system storage across multiple nodes. Additionally, an [OpenID Connect (OIDC) endpoint](https://docs.aws.amazon.com/eks/latest/userguide/enable-iam-roles-for-service-accounts.html) enables seamless and secure communication.
* **Add-ons**: The template includes the installation of the EFS CSI Driver add-on to facilitate shared file systems for complex batch jobs.
* **Private Networking**: Managed node groups utilize private networking and a NAT gateway to bolster security by limiting direct internet access.
* **Monitoring**: An [Amazon CloudWatch](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/WhatIsCloudWatch.html?sc_channel=el&sc_campaign=appswave&sc_content=eks-cluster-high-traffic&sc_geo=mult&sc_country=mult&sc_outcome=acq) IAM policy is attached to the IAM Role for Service Account (IRSA), aiding optional components like [CloudWatch Container Insights](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/ContainerInsights.html?sc_channel=el&sc_campaign=appswave&sc_content=eks-cluster-high-traffic&sc_geo=mult&sc_country=mult&sc_outcome=acq) to collect and summarize metrics and logs.

## Step 1: Configure the cluster

In this section, you will configure the Amazon EKS cluster to meet the specific demands of high-traffic microservice applications. By creating this `cluster-config.yaml` file, you'll define the settings for IAM roles, scalable resources, private networking, and monitoring. These configurations are essential for ensuring that the cluster is robust, scalable, and secure, with optimized performance for dynamic scalability and data persistence.

**To create the cluster config**

1. Create a `cluster-config.yaml` file and paste the following contents into it. Replace the `region`. 

```YAML
---
apiVersion: eksctl.io/v1alpha5
kind: ClusterConfig

metadata:
  name: async-batch-quickstart
  region: us-east-1
  version: "1.27"

managedNodeGroups:
- name: managed-ng
  minSize: 3
  maxSize: 6
  desiredCapacity: 3
  instanceType: c5a.xlarge
  privateNetworking: true
  tags:
    k8s.io/cluster-autoscaler/enabled: 'true'
    k8s.io/cluster-autoscaler/async-batch-quickstart: 'owned'

addons:
  - name: aws-efs-csi-driver
  
iam:
  withOIDC: true
  serviceAccounts:
  - metadata:
      name: cluster-autoscaler
      namespace: kube-system
    wellKnownPolicies:
      autoScaler: true
  - metadata:
      name: efs-csi-controller-sa
      namespace: kube-system
    wellKnownPolicies:
      efsCSIController: true
  - metadata:
      name: ecr-sa
      namespace: default
    attachPolicyARNs:
      - arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser

cloudWatch:
 clusterLogging:
   enableTypes: ["*"]
   logRetentionInDays: 30
```

## **Step 2: Create the cluster**

Now, we're ready to create our Amazon EKS cluster. This process takes several minutes to complete. If you'd like to monitor the status, see the [AWS CloudFormation](https://console.aws.amazon.com/cloudformation) console.

1. Create the EKS cluster by running the following command.

```
eksctl create cluster -f cluster-config.yaml
```

**Note**: if you receive an “Error: checking AWS STS access” in the response, be sure to check that you’re using the right[user identity](https://quip-amazon.com/aeTGA01eqKm2/Developer-Foundations-Quickstart-EKS-docs#temp:C:VfJ11091e508f5441ddb9a94e800) for the current shell session. Depending on how you configured the AWS CLI, you may also need to specify a named profile (for example, `--profile clusteradmin`).

Upon completion, you should see the following response output:

```
2023-08-15 19:48:34 [✔]  EKS cluster "async-batch-quickstart" in "us-east-1" region is ready
```

When the previous command completes, verify that all of your nodes have reached the `Ready` state with the following command:

```
`kubectl get nodes`
```

The expected output should look like this:

```
NAME                                           STATUS   ROLES    AGE     VERSION
ip-192-168-157-61.us-east-1.compute.internal   Ready    <none>   34m    v1.27.1-eks-2f008fe
ip-192-168-119-216.us-east-1.compute.internal  Ready    <none>   34m    v1.27.1-eks-2f008fe
ip-192-168-40-177.us-east-1.compute.internal   Ready    <none>   34m    v1.27.1-eks-2f008fe
```

## Step 3: Verify Cluster Node and Pod Health

Check whether the EFS CSI driver add-on is installed on your cluster. Replace the sample value for `region`.

```
eksctl get addon --cluster async-batch-quickstart --region us-east-1 | grep efs
```

The expected output should look like this:

```
aws-efs-csi-driver      v1.5.8-eksbuild.1       ACTIVE  0
```

Verify all the service accounts created in the cluster with the following command:

```
kubectl get sa -A | egrep "ecr-sa|efs-csi-controlle`r`|amazon-ebs|cluster-autoscaler"
```

The expected output should look like this:

```bash
default             ecr-sa                               0         43m
kube-system         cluster-autoscaler                   0         43m
kube-system         efs-csi-controller-sa                0         43m
```

**Congratulations!** You've successfully set up the foundational infrastructure of your Amazon EKS cluster, laying the essential groundwork for deploying data-intensive batch processes. This setup provides you with fully operational environment needed to begin deploying batch jobs and job queues.

## (Optional) Deploy a Sample Application

Now, you're ready to orchestrate batch processing workloads in your Kubernetes cluster, leveraging Amazon SQS as a job queue and Amazon EFS for data persistence. For a comprehensive walkthrough, refer to [Managing Asynchronous Tasks with SQS and EFS Persistent Storage in Amazon EKS](https://quip-amazon.com/C9K0ADJ2FT1x). This tutorial guides you through the process of setting up Amazon SQS for job queue management and integrating Amazon EFS for persistent storage. Lastly, you can optionally configure the EFS CSI Driver Add-On to handle complex batch jobs that require a shared file system across multiple nodes.

## **Clean Up**

To avoid incurring future charges, you should delete the resources created during this tutorial. You can delete the EKS cluster with the following command. Replace the `region`.

```
eksctl delete cluster -f ./cluster-config.yaml
```

## Conclusion

Upon the successful completion of this tutorial, you've effectively set up an Amazon EKS cluster tailored for batch processing tasks. By choosing compute-optimized EC2 instances and implementing key IAM policies, you've engineered a cluster that's both agile and robust. This tutorial has guided you through the creation and deployment of your Amazon EKS cluster, and the verification of node and pod health. To extend your cluster's capabilities, consider integrating services like Amazon SQS for job queuing or Amazon EFS for persistent storage. These additional configurations will furnish you with a versatile, fully operational environment, ready for deploying both stateless and data-intensive batch jobs.
