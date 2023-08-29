---
title: "Exposing and Grouping Applications using the AWS Load Balancer Controller (LBC) on an Amazon EKS IPv6 Cluster"
description: "How to route external traffic to your Kubernetes services and manage Ingress resources using the AWS Load Balancer Controller (LBC) on an IPv6-based cluster."
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
date: 2023-08-29
---

In the multifaceted realm of networking, managing access to applications within a Kubernetes cluster is a sophisticated endeavor. The AWS Load Balancer Controller (LBC) is vital, streamlining the routing of traffic to your applications via IPv6, the protocol increasingly adopted for internet communication. This tutorial hones in on IPv6 within a Kubernetes cluster, utilizing AWS LBC to manage ingress, i.e., external traffic. It introduces Ingress Classes, an essential mechanism for controlling external access to services within an IPv6-enabled Kubernetes cluster, and Ingress Group, a feature that groups multiple Ingress resources into one Application Load Balancer (ALB), enhancing both efficiency and ALB management. Whether dealing with agile microservices or robust systems, this tutorial offers step-by-step directions for smooth traffic flow. With AWS LBC, the intricacies of traffic management are greatly simplified, allowing you to concentrate on your application, while AWS LBC takes care of the routing. As traffic shifts, AWS LBC adapts, assuring uninterrupted access to your application over IPv6.

Building on the Amazon EKS cluster from [**part 1**](/tutorials/eks-cluster-ipv6-globally-scalable) of our series, we deployed a Linux Bastion host within our VPC. This host serves as a bridge, linking external IPv4 networks to IPv6-enabled applications within the cluster. It's an essential tool for testing and validating the connectivity of applications running on the IPv6 EKS cluster, ensuring they're accessible and performing as expected. Also included in the cluster configuration for the previous tutorial is an OpenID Connect (OIDC) endpoint. For part one of this series, see [Building an IPv6-based EKS Cluster for Globally Scalable Applications](/tutorials/eks-cluster-ipv6-globally-scalable).

In this tutorial, you will set up the AWS Load Balancer Controller (LBC) on your IPv6-enabled Amazon EKS cluster, deploy a sample application and access it using the Linux Bastion host, and create an Ingress Group to group applications together under a single Application Load Balancer (ALB) instance.

| Attributes             |                                                                 |
|------------------------|-----------------------------------------------------------------|
| ✅ AWS experience      | 300 - Advanced                                              |
| ⏱ Time to complete     | 60 minutes                                                      |
| 💰 Cost to complete    | Free tier eligible                                               |
| 🧩 Prerequisites       | - [AWS Account](https://aws.amazon.com/resources/create-account/?sc_channel=el&sc_campaign=appswave&sc_content=eks-cluster-load-balancer-ipv6&sc_geo=mult&sc_country=mult&sc_outcome=acq)|
| 📢 Feedback            | <a href="https://www.pulse.aws/survey/Z8XBGQEL" target="_blank">Any feedback, issues, or just a</a> 👍 / 👎 ?    |
| ⏰ Last Updated        | 2023-08-29                                                      |

| ToC |
|-----|

## Prerequisites

Before you begin this tutorial, you need to:

* Install the latest version of [kubectl](https://kubernetes.io/docs/tasks/tools/#kubectl). To check your version, run: `kubectl version --short`.
* Install the latest version of [eksctl](https://eksctl.io/introduction/#installation). To check your version, run: `eksctl info`.
* Install the latest version of [Helm](https://helm.sh/docs/intro/install/). To check your version, run: `helm version`.

## Overview

This tutorial is the second part of a series on deploying global applications on an Amazon EKS cluster that supports IPv6 networking, and it's dedicated to exposing applications and creating an Ingress Group with the [AWS Load Balancer Controller (LBC)](https://kubernetes-sigs.github.io/aws-load-balancer-controller/). This tutorial shows not only how to expose an application outside the cluster, but it also introduces the concept of an Ingress Class for IPv6 clusters and Ingress Group. It covers the following components:

* **Authentication**: Utilize the [OpenID Connect (OIDC) endpoint](https://docs.aws.amazon.com/eks/latest/userguide/enable-iam-roles-for-service-accounts.html?sc_channel=el&sc_campaign=appswave&sc_content=eks-cluster-load-balancer-ipv6&sc_geo=mult&sc_country=mult&sc_outcome=acq) within the Amazon EKS IPv6-based cluster, enabling seamless communication between Kubernetes pods and AWS services.
* **AWS LBC Setup**: Deploy the AWS Load Balancer Controller (LBC) on an Amazon EKS cluster, focusing on Custom Resource Definitions (CRDs) and the installation of the Load Balancer Controller itself. Upgrade the AWS LBC to utilize the Ingress class, vital for managing network egress within an IPv6-enabled Kubernetes cluster.
* **Sample Application Deployment**: Build and expose the “2048 Game Sample Application” on port 80, defining routing rules and annotations for an internet-facing Application Load Balancer (ALB). Utilize custom annotations for the ALB, including the ['scheme' annotation](https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.6/guide/ingress/ingress_class/#specscheme), ['target-type' annotation](https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.6/guide/ingress/annotations/#target-type), and ['ip-address-type' annotation](https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.6/guide/ingress/annotations/#ip-address-type), to instruct the AWS LBC to handle incoming HTTP traffic for IPv6-based clusters. For an Ingress Group, use the ['group.name' annotation](https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.6/guide/ingress/ingress_class/#specgroup) to combine multiple Ingress resources under one ALB instance. To learn more, see [Ingress annotations](https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.6/guide/ingress/annotations/) in the AWS LBC documentation.

>Note that if you're still within your initial 12-month AWS Free Tier period, be advised that the Application Load Balancer (ALB) falls outside the AWS free tier, hence usage could result in additional charges.

## Step 1: Configure Cluster Environment Variables

Before interacting with your Amazon EKS cluster using Helm or other command-line tools, it's essential to define specific environment variables that encapsulate your cluster's details. These variables will be used in subsequent commands, ensuring that they target the correct cluster and resources.

1. First, confirm that you are operating within the correct cluster context. This ensures that any subsequent commands are sent to the intended Kubernetes cluster. You can verify the current context by executing the following command:

```bash
kubectl config current-context
```

1. Define the `CLUSTER_NAME` environment variable for your EKS cluster. Replace the sample value for cluster `region`.

```bash
export CLUSTER_NAME=$(aws eks describe-cluster --region us-east-2 --name ipv6-quickstart --query "cluster.name" --output text)
```

1. Define the `CLUSTER_REGION` environment variable for your EKS cluster. Replace the sample value for cluster `region`.

```bash
export CLUSTER_REGION=$(aws eks describe-cluster --name ${CLUSTER_NAME} --query "cluster.arn" --output text | cut -d: -f4)
```

1. Define the `CLUSTER_VPC` environment variable for your EKS cluster. 

```bash
export CLUSTER_VPC=$(aws eks describe-cluster --name ${CLUSTER_NAME} --region ${CLUSTER_REGION} --query "cluster.resourcesVpcConfig.vpcId" --output text)
```

1. Define the `ACCOUNT_ID` environment variable for the account associated with your EKS cluster.

```bash
export ACCOUNT_ID=$(aws eks describe-cluster --name ${CLUSTER_NAME} --region ${CLUSTER_REGION} --query "cluster.arn" --output text | cut -d':' -f5)
```

## Step 2: Create the IAM Role for Service Account (IRSA)

The IPv6 cluster from part one of our series doesn’t currently have an IAM Role for Service Account (IRSA) set up. Use the steps in this section to create the IAM Role with a service account name of “aws-load-balancer-controller”. 

1. Download the IAM role policy:

```bash
curl -O https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.5.4/docs/install/iam_policy.json
```

1. Create the IAM role policy:

```bash
aws iam create-policy \
    --policy-name AWSLoadBalancerControllerIAMPolicy \
    --policy-document file://iam_policy.json
```

1. Create the AWS LBC IAM Role for Service Account (IRSA). 

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
`helm repo add eks https://aws.github.io/eks-charts`
```

1. Update the repositories to ensure Helm is aware of the latest versions of the charts:

```bash
helm repo update eks
```

1. Run the following [Helm](https://helm.sh/docs/intro/install/) command to simultaneously install the Custom Resource Definitions (CRDs) and the main controller for the AWS Load Balancer Controller (AWS LBC). To skip the CRD installation, pass the `--skip-crds` flag, which might be useful if the CRDs are already installed, if specific version compatibility is required, or in environments with strict access control and customization needs.

```bash
helm install aws-load-balancer-controller eks/aws-load-balancer-controller \ 
    --namespace kube-system \ 
    --set clusterName=${CLUSTER_NAME} \ 
    --set serviceAccount.create=false \ 
    --set region=${CLUSTER_REGION} \ 
    --set vpcId=${CLUSTER_VPC} \ 
    --set serviceAccount.name=aws-load-balancer-controller
```

You should see the following response output:

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

## Step 4: Use the Ingress Class for IPv6 Clusters

In this section, you will upgrade the AWS Load Balancer Controller (LBC) to use the Ingress class, a critical component for managing external access to services within an IPv6-enabled Kubernetes cluster. The Ingress class allows you to define how inbound connections are handled and routed, providing a unified way to manage the traffic entering the cluster.

1. Run the following command to upgrade the AWS LBC to use the Ingress class. 

```bash
helm upgrade aws-load-balancer-controller eks/aws-load-balancer-controller \ 
  --namespace kube-system \ 
  --set clusterName=${CLUSTER_NAME} \ 
  --set serviceAccount.create=false \ 
  --set serviceAccount.name=aws-load-balancer-controller \ 
  --set createIngressClassResource=true
```

The expected output should look like this:

```bash
Release "aws-load-balancer-controller" has been upgraded. Happy Helming!
NAME: aws-load-balancer-controller
LAST DEPLOYED: Mon Aug 14 22:54:27 2023
NAMESPACE: kube-system
STATUS: deployed
REVISION: 3
TEST SUITE: None
NOTES:
AWS Load Balancer controller installed!
```

## Step 5: Deploy the 2048 game sample application

Now that the load balancer has been set up, it's time to enable external access for containerized applications in the cluster. This section will walk you through the steps to deploy the popular 2048 game as a sample application within the cluster. The provided manifest includes custom annotations for the Application Load Balancer (ALB), specifically the ['scheme' annotation](https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.6/guide/ingress/ingress_class/#specscheme), ['target-type' annotation](https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.6/guide/ingress/annotations/#target-type), and ['ip-address-type' annotation](https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.6/guide/ingress/annotations/#ip-address-type). These annotations integrate with and instruct the AWS Load Balancer Controller (LBC) to handle incoming HTTP traffic as "internet-facing" and route it to the appropriate service in the 'game-2048' namespace using the target type "ip". Furthermore, it specifies the 'ip-address-type' as 'dualstack', which allows the ALB to be provisioned with an IPv6-enabled subnet, making it accessible over IPv6 clusters. This dualstack configuration ensures that the application is accessible over both IPv4 and IPv6, enhancing connectivity and compatibility with various client devices and networks. For more annotations, see [Annotations](https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.6/guide/ingress/annotations/) in the AWS LBC documentation.

1. Create a Kubernetes namespace called `game-2048` with the `--save-config` flag.

```bash
kubectl create namespace game-2048 --save-config
```

The expected output should look like this:

```bash
namespace/game-2048 created
```

1. Deploy the 2048 Game Sample Application.

```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.6.0/docs/examples/2048/2048_full_dualstack.yaml
```

The expected output should look like this:

```bash
namespace/game-2048 configured
deployment.apps/deployment-2048 created
service/service-2048 created
ingress.networking.k8s.io/ingress-2048 created
```

## Step 6: Access the Deployed Application

After deploying the application and load balancer, wait a few minutes to allow the necessary components to initialize and become operational. During this time, the system is preparing the Ingress resource within the 'game-2048' namespace.

1. To retrieve the details of the Ingress resource, run the following command:

```bash
kubectl get ingress -A
```

The expected output should look like this:

```bash
NAMESPACE   NAME           CLASS   HOSTS   ADDRESS                                                                   PORTS   AGE
game-2048   ingress-2048   alb     *       k8s-game2048-ingress2-4406ad7f91-1137451950.us-east-2.elb.amazonaws.com   80      45s
```

1. Run the following command to retrieve information about all the pods in the game-2048 namespace, including additional details such as the node each pod is running on.

```bash
kubectl get po -n game-2048 -o wide
```

1. Copy any one of the following IP addresses in `IP` with a `STATUS` of “Running” for the next step. The expected output should look like this:

```bash
NAME                               READY   STATUS    RESTARTS   AGE     IP                            NODE                                           NOMINATED NODE   READINESS GATES
deployment-2048-7ccfd8fdd6-4nst5   1/1     Running   0          8m23s   2600:1f16:1cc8:4001:9b29::5   ip-192-168-48-127.us-east-2.compute.internal   <none>           <none>
deployment-2048-7ccfd8fdd6-8q8zd   1/1     Running   0          8m23s   2600:1f16:1cc8:4001:9b29::3   ip-192-168-48-127.us-east-2.compute.internal   <none>           <none>
deployment-2048-7ccfd8fdd6-k6zgg   1/1     Running   0          8m23s   2600:1f16:1cc8:4002:f92b::1   ip-192-168-92-106.us-east-2.compute.internal   <none>           <none>
deployment-2048-7ccfd8fdd6-mr88r   1/1     Running   0          8m23s   2600:1f16:1cc8:4002:f92b::5   ip-192-168-92-106.us-east-2.compute.internal   <none>           <none>
deployment-2048-7ccfd8fdd6-nxs86   1/1     Running   0          8m23s   2600:1f16:1cc8:4002:f92b::4   ip-192-168-92-106.us-east-2.compute.internal   <none>           <none>
```

1. Open your Linux EC2 bastion host instance from the [Amazon EC2 console](https://console.aws.amazon.com/ec2/?sc_channel=el&sc_campaign=appswave&sc_content=eks-cluster-load-balancer-ipv6&sc_geo=mult&sc_country=mult&sc_outcome=acq), then run the following curl command to access the IPv6 IP address of the game application. Replace the sample value with your `IP` from the previous step.

```bash
curl -g -6 http://\[2600:1f16:1cc8:4001:9b29::5\]
```

You should see the HTML output for the app. The expected output should look like this:

```html
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <title>2048</title>
   ...
    <p class="game-explanation">
      <strong class="important">How to play:</strong> Use your <strong>arrow keys</strong> to move the tiles. When two tiles with the same number touch, they <strong>merge into one!</strong>
    </p>
    <hr>
    <p>
    <strong class="important">Note:</strong> This site is the official version of 2048. You can play it on your phone via <a href="http://git.io/2048">http://git.io/2048.</a> All other apps or sites are derivatives or fakes, and should be used with caution.
    </p>
    <hr>
    <p>
    Created by <a href="http://gabrielecirulli.com" target="_blank">Gabriele Cirulli.</a> Based on <a href="https://itunes.apple.com/us/app/1024!/id823499224" target="_blank">1024 by Veewo Studio</a> and conceptually similar to <a href="http://asherv.com/threes/" target="_blank">Threes by Asher Vollmer.</a>
    </p>
  </div>
   ...
</body>
</html>
```

If you encounter any issues with the response, you may need to manually configure your public subnets for automatic subnet discovery. To learn more, see [How can I tag the Amazon VPC subnets in my Amazon EKS cluster for automatic subnet discovery by load balancers or ingress controllers?](https://repost.aws/knowledge-center/eks-vpc-subnet-discovery?sc_channel=el&sc_campaign=appswave&sc_content=eks-cluster-load-balancer-ipv6&sc_geo=mult&sc_country=mult&sc_outcome=acq)

## Step 8: Create an Ingress Group

In this section, we will update the existing Ingress object by introducing an Ingress Group. This is achieved by adding the ['group.name' annotation](https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.6/guide/ingress/ingress_class/#specgroup) within the Ingress object's metadata. When this group name is consistently applied across different Ingress resources, the AWS Load Balancer Controller (LBC) identifies them as constituents of the same group, thereby managing them in unison. The advantage of this approach is that it allows for the consolidation of multiple Ingress resources under a single Application Load Balancer (ALB) instance. This not only streamlines the management of these resources but also optimizes the utilization of the ALB. By grouping them together through this annotation, you create a cohesive and efficient structure that simplifies the orchestration of your load balancing needs. 

1. Copy the entire sample below and run it in the terminal window of your Linux EC2 bastion host. 

```bash
cat <<EoF>updated-ingress-2048.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  namespace: game-2048
  name: ingress-2048
  annotations:
    alb.ingress.kubernetes.io/scheme: internet-facing
    alb.ingress.kubernetes.io/target-type: ip
    alb.ingress.kubernetes.io/ip-address-type: dualstack
    alb.ingress.kubernetes.io/group.name: my-group # Adds this line to create the Ingress group
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
<EoF>                
```

1. Deploy the Kubernetes resources in `updated-ingress-2048.yaml`:

```bash
kubectl apply -f updated-ingress-2048.yaml
```

This will update the existing Ingress object with the new annotation, creating an Ingress group with the name "my-group." After deploying the group, wait a few minutes to allow the necessary components to initialize and become operational. The expected output should look like this:

```bash
ingress.networking.k8s.io/ingress-2048 configured
```

1. In your Linux EC2 bastion host terminal window, use curl to access the IPv6 IP address of the application using the following command. 

```bash
curl -g -6 http://\[2600:1f16:1cc8:4001:9b29::5\]
```

You should see the HTML output for the app. To view your Application Load Balancer (ALB) instance, open the [Load balancers](https://us-east-2.console.aws.amazon.com/ec2/home?#LoadBalancers:?sc_channel=el&sc_campaign=appswave&sc_content=eks-cluster-load-balancer-ipv6&sc_geo=mult&sc_country=mult&sc_outcome=acq) page on the Amazon EC2 console.

## Clean up

After finishing with this tutorial, for better resource management, you may want to delete the specific resources you created. 

```bash
# Delete the Namespace, Deployment, Service, and Ingress
`kubectl ``delete`` ``namespace game-2048`

# Delete the AWS Load Balancer Controller
helm uninstall aws-load-balancer-controller -n kube-system

# Remove IAM Roles for Service Accounts (IRSA)
eksctl delete iamserviceaccount --cluster=${CLUSTER_NAME} --namespace=kube-system --name=aws-load-balancer-controller
```

## Conclusion

With the completion of this tutorial, you have successfully configured the AWS Load Balancer Controller (LBC) on your Amazon EKS cluster to manage high traffic platforms using IPv6. By exposing applications and creating an Ingress Group, you have implemented a method to consolidate multiple Ingress resources, fully aligned with best practices for IPv6-based clusters. This tutorial has guided you through streamlined authentication using the IAM Role for Service Account (IRSA), the setup of the AWS LBC on an Amazon EKS cluster, and the deployment of the "2048 Game Sample Application." You have also explored custom annotations for the ALB, specifically for IPv6-based clusters, and understood the concept of Ingress Group. In order to associate other applications to the same ALB instance, you need to specify this same group (i.e., `my-group`) using the ['group.name' annotation](https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.6/guide/ingress/ingress_class/#specgroup). To continue your journey by deploying a stateful workload, you need to set up data storage, such as the [EBS CSI Driver](https://github.com/kubernetes-sigs/aws-ebs-csi-driver/tree/master) or the [EFS CSI Driver](https://github.com/kubernetes-sigs/aws-efs-csi-driver). These final installations will provide you with a robust, fully functional environment, ready for deploying your stateless and stateful applications.
