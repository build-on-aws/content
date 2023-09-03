---
title: "Exposing and Grouping Applications Using the AWS Load Balancer Controller on an Amazon EKS IPv4 Cluster"
description: "How to route external traffic to your Kubernetes services and manage Ingress resources using the AWS Load Balancer Controller on an IPv4-based cluster."
tags:
    - eks-cluster-setup
    - eks
    - kubernetes
    - eksctl
    - tutorials
    - aws
showInHomeFeed: true
waves:
  - modern-apps
spaces:
  - kubernetes
authorGithubAlias: tucktuck9
authorName: Leah Tucker
date: 2023-08-30
---

In the intricate field of networking, managing access to applications within a Kubernetes cluster presents a multifaceted challenge. The AWS Load Balancer Controller (LBC) is essential, facilitating the direction of traffic to your applications through IPv4, the protocol predominantly utilized for internet traffic. This guide focuses on IPv4 within a Kubernetes cluster, employing AWS LBC to supervise external traffic. It emphasizes Ingress Group, a function that consolidates multiple Ingress resources into one Application Load Balancer (ALB), augmenting both effectiveness and ALB utilization. Whether working with nimble microservices or sturdy systems, this manual provides sequential instructions for seamless traffic navigation. With AWS LBC, the complexities of traffic control are significantly reduced, enabling you to focus on your application, as AWS LBC manages the routing. As traffic evolves, AWS LBC adjusts, ensuring continuous access to your application.

Building on the Amazon EKS cluster from [**part 1**](/tutorials/eks-cluster-high-traffic) of our series, this tutorial dives into setting up the AWS Load Balancer Controller (LBC). Included in the cluster configuration for the previous tutorial is the IAM Role for Service Account (IRSA) for the AWS LBC and the OpenID Connect (OIDC) endpoint. For part one of this series, see [Building an Amazon EKS Cluster Preconfigured to Run High Traffic Microservices](/tutorials/eks-cluster-high-traffic). Alternatively, to set up an existing cluster with the components required for this tutorial, use the instructions in [Create an IAM OpenID Connect (OIDC) endpoint](https://docs.aws.amazon.com/eks/latest/userguide/enable-iam-roles-for-service-accounts.html?sc_channel=el&sc_campaign=appswave&sc_content=eks-cluster-load-balancer-ipv4&sc_geo=mult&sc_country=mult&sc_outcome=acq) and [Create an IAM Role for Service Account (IRSA)](https://docs.aws.amazon.com/eks/latest/userguide/aws-load-balancer-controller.html?sc_channel=el&sc_campaign=appswave&sc_content=eks-cluster-load-balancer-ipv4&sc_geo=mult&sc_country=mult&sc_outcome=acq) in EKS official documentation.

In this tutorial, you will set up the AWS Load Balancer Controller (LBC) on your IPv4-enabled Amazon EKS cluster, deploy a sample application to it, and create an Ingress Group to group applications together under a single Application Load Balancer (ALB) instance. 

| Attributes             |                                                                 |
|------------------------|-----------------------------------------------------------------|
| ✅ AWS experience      | 200 - Intermediate                                              |
| ⏱ Time to complete     | 30 minutes                                                      |
| 🧩 Prerequisites       | - [AWS Account](https://aws.amazon.com/resources/create-account/?sc_channel=el&sc_campaign=appswave&sc_content=eks-cluster-load-balancer-ipv4&sc_geo=mult&sc_country=mult&sc_outcome=acq)|
| 📢 Feedback            | <a href="https://www.pulse.aws/survey/Z8XBGQEL" target="_blank">Any feedback, issues, or just a</a> 👍 / 👎 ?    |
| ⏰ Last Updated        | 2023-08-30                                                      |

| ToC |
|-----|

## Prerequisites

Before you begin this tutorial, you need to:

* Install the latest version of [kubectl](https://kubernetes.io/docs/tasks/tools/#kubectl). To check your version, run: `kubectl version --short`.
* Install the latest version of [eksctl](https://eksctl.io/introduction/#installation). To check your version, run: `eksctl info`.
* Install the latest version of [Helm](https://helm.sh/docs/intro/install/). To check your version, run: `helm version`.

## Overview

This tutorial is the second part of a series on managing high traffic microservices platforms using Amazon EKS, and it's dedicated to exposing applications and creating an Ingress Group with the [AWS Load Balancer Controller (LBC)](https://kubernetes-sigs.github.io/aws-load-balancer-controller/). This tutorial shows not only how to expose an application outside the cluster, but it also introduces the concept of Ingress Groups. It covers the following components:

* **Authentication**: Utilize the pre-configured IAM Role for Service Account (IRSA) for the [AWS Load Balancer Controller (LBC)](https://docs.aws.amazon.com/eks/latest/userguide/aws-load-balancer-controller.html?sc_channel=el&sc_campaign=appswave&sc_content=eks-cluster-load-balancer-ipv4&sc_geo=mult&sc_country=mult&sc_outcome=acq) with the [OpenID Connect (OIDC) endpoint](https://docs.aws.amazon.com/eks/latest/userguide/enable-iam-roles-for-service-accounts.html?sc_channel=el&sc_campaign=appswave&sc_content=eks-cluster-load-balancer-ipv4&sc_geo=mult&sc_country=mult&sc_outcome=acq), ensuring secure communication between Kubernetes pods and AWS services.
* **AWS LBC Setup**: Deploy the AWS Load Balancer Controller (LBC) on the Amazon EKS cluster, focusing on Custom Resource Definitions (CRDs) and the installation of the Load Balancer Controller itself.
* **Sample Application Deployment**: Build and expose the “2048 Game Sample Application” on port 80, defining routing rules and annotations for an internet-facing Application Load Balancer (ALB). Utilize custom annotations for the ALB, specifically the ['scheme' annotation](https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.6/guide/ingress/ingress_class/#specscheme) and ['target-type' annotation](https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.6/guide/ingress/annotations/#target-type), to instruct the AWS LBC to handle incoming HTTP traffic for IPv4-based clusters. For an Ingress Group, use the ['group.name' annotation](https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.6/guide/ingress/ingress_class/#specgroup) to combine multiple Ingress resources under one ALB instance. To learn more, see [Ingress annotations](https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.6/guide/ingress/annotations/) in the AWS LBC documentation.

>Note that even if you're still within your initial 12-month AWS Free Tier period, the Application Load Balancer (ALB) falls outside the AWS free tier, hence usage could result in additional charges.

## Step 1: Configure Cluster Environment Variables

Before interacting with your Amazon EKS cluster using Helm or other command-line tools, it's essential to define specific environment variables that encapsulate your cluster's details. These variables will be used in subsequent commands, ensuring that they target the correct cluster and resources.

1. First, confirm that you are operating within the correct cluster context. This ensures that any subsequent commands are sent to the intended Kubernetes cluster. You can verify the current context by executing the following command:

```bash
kubectl config current-context
```

2. Define the `CLUSTER_NAME` environment variable for your EKS cluster. Replace the sample value for cluster `region`.

```bash
export CLUSTER_NAME=$(aws eks describe-cluster --region us-east-2 --name managednodes-quickstart --query "cluster.name" --output text)
```

3. Define the `CLUSTER_REGION` environment variable for your EKS cluster. Replace the sample value for cluster `region`.

```bash
export CLUSTER_REGION=$(aws eks describe-cluster --name ${CLUSTER_NAME} --query "cluster.arn" --output text | cut -d: -f4)
```

4. Define the `CLUSTER_VPC` environment variable for your EKS cluster. 

```bash
export CLUSTER_VPC=$(aws eks describe-cluster --name ${CLUSTER_NAME} --region ${CLUSTER_REGION} --query "cluster.resourcesVpcConfig.vpcId" --output text)
```

5. Define the `ACCOUNT_ID` environment variable for the account associated with your EKS cluster.

```bash
export ACCOUNT_ID=$(aws eks describe-cluster --name ${CLUSTER_NAME} --region ${CLUSTER_REGION} --query "cluster.arn" --output text | cut -d':' -f5)
```

## Step 2: Verify or Create the IAM Role and Service Account

Make sure the "aws-load-balancer-controller" service account is correctly set up in the "kube-system" namespace in your cluster.

```bash
kubectl get sa aws-load-balancer-controller -n kube-system -o yaml
```

The expected output should look like this:

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  annotations:
    eks.amazonaws.com/role-arn: arn:aws:iam::01234567890:role/AmazonEKSLoadBalancerControllerRole
  creationTimestamp: "2023-08-15T01:53:29Z"
  labels:
    app.kubernetes.io/managed-by: eksctl
  name: aws-load-balancer-controller
  namespace: kube-system
  resourceVersion: "23721"
  uid: 2491b69e-449e-44ea-affd-1d1c2d7437cf
```

Optionally, if you do **not** already have an IAM role set up, or you receive an error, the following command will create the IAM Role along with the service account names “aws-load-balancer-controller”. Note that you must have an [OpenID Connect (OIDC) endpoint](https://docs.aws.amazon.com/eks/latest/userguide/enable-iam-roles-for-service-accounts.html?sc_channel=el&sc_campaign=appswave&sc_content=eks-cluster-load-balancer-ipv4&sc_geo=mult&sc_country=mult&sc_outcome=acq) associated with your cluster before you run these commands.

First, download the IAM policy:

```bash
curl -O https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.5.4/docs/install/iam_policy.json
```

Create the IAM role policy:

```bash
aws iam create-policy \ 
    --policy-name AWSLoadBalancerControllerIAMPolicy \ 
    --policy-document file://iam_policy.json
```

Lastly, create the service account. 

```bash
eksctl create iamserviceaccount \ 
  --cluster=${CLUSTER_NAME} \ 
  --namespace=kube-system \ 
  --name=aws-load-balancer-controller \ 
  --role-name AmazonEKSLoadBalancerControllerRole \ 
  --attach-policy-arn=arn:aws:iam::${ACCOUNT_ID}:policy/AWSLoadBalancerControllerIAMPolicy \ 
  --approve
```

## Step 3: Install the Load Balancer Controller (LBC)

In this section, you will install the AWS Load Balancer Controller (LBC) on your EKS cluster. The LBC leverages Custom Resource Definitions (CRDs) to manage AWS Elastic Load Balancers (ELBs). These CRDs define custom resources such as load balancers and TargetGroupBindings, enabling the Kubernetes cluster to recognize and manage them.

1. Use [Helm](https://helm.sh/docs/intro/install/) to add the EKS chart repository to Helm.

```bash
helm repo add eks https://aws.github.io/eks-charts
```

2. Update the repositories to ensure Helm is aware of the latest versions of the charts:

```bash
helm repo update eks
```

3. Run the following [Helm](https://helm.sh/docs/intro/install/) command to simultaneously install the Custom Resource Definitions (CRDs) and the main controller for the AWS Load Balancer Controller (LBC). To skip the CRD installation, pass the `--skip-crds` flag, which might be useful if the CRDs are already installed, if specific version compatibility is required, or in environments with strict access control and customization needs.

```bash
helm install aws-load-balancer-controller eks/aws-load-balancer-controller \ 
    --namespace kube-system \ 
    --set clusterName=${CLUSTER_NAME} \ 
    --set serviceAccount.create=false \ 
    --set region=${CLUSTER_REGION} \ 
    --set vpcId=${CLUSTER_VPC} \ 
    --set serviceAccount.name=aws-load-balancer-controller
```

The expected output should look like this:

```bash
NAME: aws-load-balancer-controller
LAST DEPLOYED: Thu Aug 17 19:43:12 2023
NAMESPACE: kube-system
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
AWS Load Balancer controller installed!
```

## Step 4: Deploy the 2048 Game Sample Application

Now that the load balancer is set up, it's time to enable external access for containerized applications in the cluster. In this section, we walk you through the steps to deploy the popular “2048 game” as a sample application within the cluster. The provided manifest includes custom annotations for the Application Load Balancer (ALB), specifically the ['scheme' annotation](https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.6/guide/ingress/ingress_class/#specscheme) and ['target-type' annotation](https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.6/guide/ingress/annotations/#target-type). These annotations integrate with and instruct the AWS Load Balancer Controller (LBC) to handle incoming HTTP traffic as "internet-facing" and route it to the appropriate service in the 'game-2048' namespace using the target type "ip". For more annotations, see [Annotations](https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.6/guide/ingress/annotations/) in the AWS LBC documentation.

1. Create a Kubernetes namespace called `game-2048` with the `--save-config` flag.

```bash
kubectl create namespace game-2048 --save-config
```

The expected output should look like this:

```bash
namespace/game-2048 created
```

2. Deploy the 2048 game sample application.

```bash
kubectl apply -n game-2048 -f https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.6.0/docs/examples/2048/2048_full.yaml
```

The expected output should look like this:

```bash
namespace/game-2048 configured
deployment.apps/deployment-2048 created
service/service-2048 created
ingress.networking.k8s.io/ingress-2048 created
```

## Step 5: Access the Deployed Application

After deploying the application and load balancer, wait a few minutes to allow the necessary components to initialize and become operational. During this time, the system is preparing the Ingress resource within the 'game-2048' namespace.

1. To retrieve the details of the Ingress resource, run the following command:

```bash
kubectl get ingress -n game-2048
```

The expected output should look like this:

```bash
NAME           CLASS   HOSTS   ADDRESS                                                                  PORTS   AGE
ingress-2048   alb     *       k8s-game2048-ingress2-eb379a0f83-378466616.us-east-2.elb.amazonaws.com   80      31s
```

2. Open a web browser and enter the ‘ADDRESS’ from the previous step to access the web application. For example, `k8s-game2048-ingress2-eb379a0f83-378466616.us-east-2.elb.amazonaws.com`. You should see the following 2048 game:
  ![Screenshot of the 2048 game screen](images/2048_game.png)

If you encounter any issues with the response, you may need to manually configure your public subnets for automatic subnet discovery. To learn more, see [How can I tag the Amazon VPC subnets in my Amazon EKS cluster for automatic subnet discovery by load balancers or ingress controllers?](https://repost.aws/knowledge-center/eks-vpc-subnet-discovery?sc_channel=el&sc_campaign=appswave&sc_content=eks-cluster-load-balancer-ipv4&sc_geo=mult&sc_country=mult&sc_outcome=acq)

## Step 6: Create an Ingress Group

In this section, we will update the existing Ingress object by introducing an Ingress Group. This is achieved by adding the ['group.name' annotation](https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.6/guide/ingress/ingress_class/#specgroup) within the Ingress object's metadata. When this group name is consistently applied across different Ingress resources, the AWS Load Balancer Controller (LBC) identifies them as constituents of the same group, thereby managing them in unison. The advantage of this approach is that it allows for the consolidation of multiple Ingress resources under a single Application Load Balancer (ALB) instance. This not only streamlines the management of these resources but also optimizes the utilization of the ALB. By grouping them together through this annotation, you create a cohesive and efficient structure that simplifies the orchestration of your load balancing needs. 

1. Create a Kubernetes manifest called `updated-ingress-2048.yaml` and paste the following contents into it.

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  namespace: game-2048
  name: ingress-2048
  annotations:
    alb.ingress.kubernetes.io/scheme: internet-facing
    alb.ingress.kubernetes.io/target-type: ip
    alb.ingress.kubernetes.io/group.name: my-group # Adds this line to create the Ingress Group
spec:
  ingressClassName: alb
  rules:
    - http:
        paths:
        - path: /
          pathType: Prefix
          backend:
            service:
              name: service-2048
              port:
                number: 80
```

2. Deploy the Kubernetes resources in `updated-ingress-2048.yaml`:

```bash
kubectl apply -f updated-ingress-2048.yaml
```

This will update the existing Ingress object with the new annotation, creating an Ingress Group with the name "my-group." After deploying the group, wait a few minutes to allow the necessary components to initialize and become operational. The expected output should look like this:

```bash
ingress.networking.k8s.io/ingress-2048 configured
```

3. To retrieve the details of the new Ingress resource, run the following command:

```bash
kubectl get ingress -n game-2048
```

The expected output should look like this:

```bash
NAME           CLASS   HOSTS   ADDRESS                                                         PORTS   AGE
ingress-2048   alb     *       k8s-mygroup-d7adaa7af2-1349935440.us-east-2.elb.amazonaws.com   80      4d1h
```

4. Open a web browser and enter the "game-2048" ‘ADDRESS’ to access the web application. For example, `k8s-mygroup-d7adaa7af2-1349935440.us-east-2.elb.amazonaws.com`. 

You should see the 2048 game. To view your Application Load Balancer (ALB) instance, open the [Load balancers](https://us-east-2.console.aws.amazon.com/ec2/home?#LoadBalancers:) page on the Amazon EC2 console.

## Clean Up

After finishing with this tutorial, for better resource management, you may want to delete the specific resources you created. 

```bash
# Delete the Namespace, Deployment, Service, and Ingress
kubectl delete namespace game-2048

# Delete the AWS Load Balancer Controller
helm uninstall aws-load-balancer-controller -n kube-system
```

## Conclusion

With the completion of this tutorial, you have successfully configured the AWS Load Balancer Controller (LBC) on your Amazon EKS cluster, enabling the precise control and management of external traffic to your Kubernetes services. By exposing applications and creating an Ingress Group, you have implemented a method to consolidate multiple Ingress resources, fully aligned with best practices. This tutorial has guided you through streamlined authentication using the IAM Role for Service Account (IRSA), the setup of the AWS LBC on an Amazon EKS cluster, and the deployment of the "2048 Game Sample Application." You have also explored custom annotations for the ALB, and understood the concept of Ingress Group. In order to associate other applications to the same ALB instance, you need to specify this same group (i.e., `my-group`) using the ['group.name' annotation](https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.6/guide/ingress/ingress_class/#specgroup). To continue your journey by deploying a stateful workload, you need to set up data storage, such as the [EBS CSI Driver](https://github.com/kubernetes-sigs/aws-ebs-csi-driver/tree/master) or the [EFS CSI Driver](https://github.com/kubernetes-sigs/aws-efs-csi-driver). These final installations will provide you with a robust, fully functional environment, ready for deploying your stateless and stateful applications.
