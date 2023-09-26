---
title: "Automatically Manage DNS Records for Your Microservices in Amazon EKS with ExternalDNS"
description: "Configure Amazon Route53 as a DNS provider for external access to microservices"
tags:
    - external-dns
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
authorGithubAlias: kamaljoshi123
authorName: Kamal Joshi
date: 2023-09-30
---

In modern cloud-native environments, microservices are often distributed across clusters, scaled dynamically, and frequently moved due to orchestration. Manually updating DNS records for each microservice instance becomes impractical and is error-prone. 

It is crucial to automate DNS record management for microservices hosted on Kubernetes clusters. This automation streamlines application accessibility and maintains operational efficiency. By deploying [ExternalDNS](https://github.com/kubernetes-sigs/external-dns), the need for manual intervention is eliminated. It ensures that domain names are always up-to-date and accurately reflect the addresses of the running Kubernetes services. This not only simplifies the user experience by allowing clients to access Kubernetes services using readable URLs, but also improves fault tolerance and resilience. With automated DNS management, microservices can be deployed, scaled, and relocated quickly without affecting accessibility. The External DNS add-on automatically creates and manages DNS records for services exposed externally, using supported DNS providers. It enables external clients to access services running inside the cluster by resolving the service's hostname to the external IP address of the Kubernetes cluster.

Building on the Amazon EKS cluster from **part 1** of our series, this tutorial dives into setting up the [ExternalDNS](https://github.com/kubernetes-sigs/external-dns) add-on. Included in the cluster configuration for the previous tutorial is the IAM Role for Service Account (IRSA) for the External DNS add-on and the OpenID Connect (OIDC) endpoint. For part one of this series, see [Building an Amazon EKS Cluster Preconfigured to Run High Traffic Microservices](https://quip-amazon.com/BSptA7qRYm2l/Building-an-Amazon-EKS-Cluster-Preconfigured-to-Run-High-Traffic-Microservices). Alternatively, to setup an existing cluster with the components required for this tutorial, use the instructions in [Create an IAM OpenID Connect (OIDC) endpoint](https://docs.aws.amazon.com/eks/latest/userguide/enable-iam-roles-for-service-accounts.html) in EKS official documentation and [Create an IAM Role for Service Account (IRSA)](https://repost.aws/knowledge-center/eks-set-up-externaldns) in Re:Post.

In this tutorial, you will configure the [ExternalDNS](https://github.com/kubernetes-sigs/external-dns) add-on on your Amazon EKS cluster. This will involve creating a private hosted zone, installation of the [ExternalDNS](https://github.com/kubernetes-sigs/external-dns) add-on that utilizes the IAM Role for Service Account (IRSA) for the management of AWS Route53 DNS records. Additionally, we will illustrate the validation of user-friendly URLs to access these Kubernetes services. This methodology enhances fault tolerance and guarantees robust accessibility to these Kubernetes services.

![](./images/arch.png)

| Attributes             |                                                                 |
|------------------------|-----------------------------------------------------------------|
| ✅ AWS experience      | 200 - Intermediate                                              |
| ⏱ Time to complete     | 30 minutes                                                      |
| 🧩 Prerequisites       | - [AWS Account](https://aws.amazon.com/resources/create-account/?sc_channel=el&sc_campaign=appswave&sc_content=eks-cluster-high-traffic&sc_geo=mult&sc_country=mult&sc_outcome=acq)|
| 📢 Feedback            | <a href="https://www.pulse.aws/survey/Z8XBGQEL" target="_blank">Any feedback, issues, or just a</a> 👍 / 👎 ?    |
| ⏰ Last Updated        | 2023-09-30                                                      |

| ToC |
|-----|

## Prerequisites

* Install the latest version of [kubectl](https://kubernetes.io/docs/tasks/tools/#kubectl). To check your version, run: `kubectl version --short`.
* Install the latest version of [eksctl](https://eksctl.io/introduction/#installation). To check your version, run: `eksctl info`.
* Install the latest version of [Helm](https://helm.sh/docs/intro/install/). To check your version, run: `helm version`.
* Install the latest version of [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html). To check your version, run: `aws --version`.

## Overview

This tutorial is the second part of a series on managing high traffic microservices platforms using Amazon EKS, and it's dedicated to the setup and configuration of [External DNS](https://github.com/kubernetes-sigs/external-dns) add-on. It also outlines the process of creating a private hosted zone and introduces the implementation of authentication and authorization using IAM Roles for Service Accounts (IRSA) to manage the AWS Route53 DNS records.

* **Authentication:** Utilize the IAM Role for Service Account (IRSA) for the [ExternalDNS](https://github.com/kubernetes-sigs/external-dns) add-on with the [OpenID Connect (OIDC) endpoint](https://docs.aws.amazon.com/eks/latest/userguide/enable-iam-roles-for-service-accounts.html?sc_channel=el&sc_campaign=appswave&sc_content=eks-cluster-load-balancer-ipv4&sc_geo=mult&sc_country=mult&sc_outcome=acq) to ensure secure communication between Kubernetes pods and AWS services.
* **Route53 Hosted Zone Creation:** Create a private hosted zone that will hold the DNS records of the Kubernetes service. This hosted zone will serve as a container for all the DNS records related to your Kubernetes service.
*  **ExternalDNS Add-on Setup:** Deploy the[ExternalDNS](https://github.com/kubernetes-sigs/external-dns) add-on on your Amazon EKS cluster and configure it to synchronize Kubernetes service DNS records with your Route53 domain.
* **Sample Application Deployment:** As a practical example, we'll walk you through the steps to build and expose the "2048 Game Sample Application" on port 80. To facilitate this, we'll utilize custom annotations for [ExternalDNS](https://github.com/kubernetes-sigs/external-dns), particularly the 'hostname' annotation, which instructs the [ExternalDNS](https://github.com/kubernetes-sigs/external-dns) controller on how to access the Kubernetes service via the specified HTTP path. For more annotations, see [Setting up ExternalDNS for Services on AWS](https://kubernetes-sigs.github.io/external-dns/v0.13.5/tutorials/aws/#annotations).

> *Note that even if you're still within your initial 12-month AWS Free Tier period, the Route 53 hosted zone falls outside the AWS free tier. Hence usage could result in additional charges.*  
*The ExternalDNS add-on is self-managed, and customers are responsible for overseeing its lifecycle and maintenance.*

## Step 1: Configure Cluster Environment Variables

Before interacting with your Amazon EKS cluster using Helm or other command-line tools, it's essential to define specific environment variables that encapsulate your cluster's details. These variables will be used in subsequent commands, ensuring that they target the correct cluster and resources.

1. First, confirm that you are operating within the correct cluster context. This ensures that any subsequent commands are sent to the intended Kubernetes cluster. You can verify the current context by executing the following command:

```
kubectl config current-context
```

2. Define the `CLUSTER_ACCOUNT` environment variable to store your AWS account ID. 

```
export CLUSTER_ACCOUNT=$(aws sts get-caller-identity --query Account --o text)
```

3. Define the `CLUSTER_NAME` environment variable for your EKS cluster.

```
export CLUSTER_NAME="managednodes-quickstart"
```

4. Define the `CLUSTER_REGION` environment variable for your EKS cluster. 

```
export CLUSTER_REGION="us-east-2"
```

5. Define the `CLUSTER_VPC` environment variable for your EKS cluster. 

```
export CLUSTER_VPC=$(aws eks describe-cluster --name ${CLUSTER_NAME} --region ${CLUSTER_REGION} --query "cluster.resourcesVpcConfig.vpcId" --output text)
```

## Step 2: Create Route53 Domain

In this section, we will create a private Route53 hosted zone called "my-externaldns-demo.com". If you already own a public domain, feel free to use that instead. 

1. Define the `AWS_ROUTE53_DOMAIN` environment variable to store your Route 53 domain name.

```
export AWS_ROUTE53_DOMAIN="my-externaldns-demo.com"
```

2. Create a new hosted zone in AWS Route 53. 

```
aws route53 create-hosted-zone --name "${AWS_ROUTE53_DOMAIN}." --vpc VPCRegion=${CLUSTER_REGION},VPCId=${CLUSTER_VPC} --caller-reference "my-externaldns-demo-$(date +%s)"
```

The expected output should look like this:

```
{
    "Location": "https://route53.amazonaws.com/2013-04-01/hostedzone/Z0116663IIIIIIVJ3D",
    "HostedZone": {
        "Id": "/hostedzone/Z0116663IIIIIIVJ3D",
        "Name": "my-externaldns-demo.com.",
        "CallerReference": "my-externaldns-demo-1691704176",
        "Config": {
            "PrivateZone": true
        },
        "ResourceRecordSetCount": 2
    },
    "ChangeInfo": {
        "Id": "/change/C02072961XZD56YBSLPL",
        "Status": "PENDING",
        "SubmittedAt": "2023-08-10T21:49:38.828000+00:00"
    },
    "VPC": {
        "VPCRegion": "us-east-1",
        "VPCId": "vpc-0c508g5678242g7g"
    }
}
```

3. Retrieve the ID of the hosted zone you created in AWS Route 53. 

```
export HOSTED_ZONE_ID=$(aws route53 list-hosted-zones-by-name --dns-name "${AWS_ROUTE53_DOMAIN}." --query 'HostedZones[0].Id' --o text | awk -F "/" {'print $NF'})
```

4. Verify that the Route53 hosted zone was created successfully. 

```
aws route53 list-resource-record-sets --hosted-zone-id  ${HOSTED_ZONE_ID}  --query "ResourceRecordSets[?Name == '${AWS_ROUTE53_DOMAIN}.']"
```

The expected output should look like this:

```
[
    {
        "Name": "my-externaldns-demo.com.",
        "Type": "NS",
        "TTL": 172800,
        "ResourceRecords": [
            {
                "Value": "ns-1536.awsdns-00.co.uk."
            },
            {
                "Value": "ns-0.awsdns-00.com."
            },
            {
                "Value": "ns-1024.awsdns-00.org."
            },
            {
                "Value": "ns-512.awsdns-00.net."
            }
        ]
    },
    {
        "Name": "my-externaldns-demo.com.",
        "Type": "SOA",
        "TTL": 900,
        "ResourceRecords": [
            {
                "Value": "ns-1536.awsdns-00.co.uk. awsdns-hostmaster.amazon.com. 1 5600 500 1209600 86400"
            }
        ]
    }
]
```

## Step 3: Verify or Create the IAM Role for Service Account 

Make sure the "external-dns" service account is correctly set up in the "kube-system" namespace in your cluster.

```
kubectl get sa external-dns -n kube-system -o yaml  
```

The expected output should look like this:

```
apiVersion: v1
kind: ServiceAccount
metadata:
  annotations:
    eks.amazonaws.com/role-arn: arn:aws:iam::#########:role/eksctl-managednodes-quickstart-addon-iamserv-Role1-U0CHMZQX2WC4
  creationTimestamp: "2023-08-31T16:43:32Z"
  labels:
    app.kubernetes.io/managed-by: eksctl
  name: external-dns
  namespace: kube-system
  resourceVersion: "1469"
  uid: 68923daf-7865-4ffe-dfgd-01d98a00a01a
```

**Optionally**, if you do not already have an IAM role set up, or you receive an error, the following command will create the IAM Role along with the service account names "external-dns". Note that you must have an [OpenID Connect (OIDC) endpoint](https://docs.aws.amazon.com/eks/latest/userguide/enable-iam-roles-for-service-accounts.html?sc_channel=el&sc_campaign=appswave&sc_content=eks-cluster-load-balancer-ipv4&sc_geo=mult&sc_country=mult&sc_outcome=acq) associated with your cluster before you run these commands.

1. Configure IAM permissions to allow ExternalDNS pods to manage Route 53 records in your AWS account.

```
cat << EOF > external-dns-policy.json
{  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "route53:ChangeResourceRecordSets"
      ],
      "Resource": [
        "arn:aws:route53:::hostedzone/${HOSTED_ZONE_ID}"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "route53:ListHostedZones",
        "route53:ListResourceRecordSets"
      ],
      "Resource": [
        "*"
      ]
    }
  ]
}
EOF
```

2. Create the policy to grant the necessary permissions for ExternalDNS to interact with Route 53.

```
aws iam create-policy --policy-name "ExternalDNSUpdatesPolicy" --policy-document file://external-dns-policy.json
```

3. Use the policy to create an IAM role for the service account. This service account will be used by external DNS pods to manage records in the route53 hosted zone. 

```
eksctl create iamserviceaccount --name external-dns --namespace kube-system --cluster ${CLUSTER_NAME} --attach-policy-arn arn:aws:iam::${AWS_CURRENT_ACCOUNT}:policy/ExternalDNSUpdatesPolicy --approve --override-existing-serviceaccounts --region ${CLUSTER_REGION}
```

## Step 4: Install the ExternalDNS Add-On

In this section, you will deploy the ExternalDNS add-on within your EKS cluster, specifically in the "kube-system" namespace. You will further configure the add-on to synchronize DNS records for the  `my-externaldns-demo.com` hosted zone. This configuration enables the ExternalDNS add-on to automate the management of DNS records for services running in your Kubernetes cluster, ensuring that these services can be accessed using domain names. To learn more, see [ExternalDNS parameters](https://artifacthub.io/packages/helm/bitnami/external-dns#external-dns-parameters).

1. Update the kubeconfig file to set the context to the current EKS cluster.

```
aws eks update-kubeconfig --name ${CLUSTER_NAME} --region ${CLUSTER_REGION}
```

2. Run the following Helm command to install the ExternalDNS add-on on your EKS cluster. This command will configure the ExternalDNS add-on to manage DNS records for your specified domain.

```
helm upgrade --wait --timeout 900s --install externaldns-release \
  --set provider=aws \
  --set aws.region=${CLUSTER_REGION} \
  --set txtOwnerId=${HOSTED_ZONE_ID} \
  --set domainFilters\[0\]="${AWS_ROUTE53_DOMAIN}" \
  --set serviceAccount.name=external-dns \
  --set serviceAccount.create=false \
  --set policy=sync \
  oci://registry-1.docker.io/bitnamicharts/external-dns --namespace kube-system
```

The expected output should look like this:

```
Release "externaldns-release" does not exist. Installing it now.
Pulled: registry-1.docker.io/bitnamicharts/external-dns:6.23.3
Digest: sha256:79479fb62f8955c37c4994ac208f2f367aba22559473d5ceb4d07531a9c2dd6e
NAME: externaldns-release
LAST DEPLOYED: Thu Aug 10 12:15:45 2023
NAMESPACE: kube-system
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
CHART NAME: external-dns
CHART VERSION: 6.23.3
APP VERSION: 0.13.5

** Please be patient while the chart is being deployed **

To verify that external-dns has started, run:

  kubectl --namespace=kube-system get pods -l "app.kubernetes.io/name=external-dns,app.kubernetes.io/instance=externaldns-release"
```

## Step 5: Verify the Functionality of ExternalDNS

Now that we have set up the external DNS, we can allow users outside the cluster to access containerized applications using human-readable URLs. In this section, we will deploy the popular "2048 game" as a sample application within the cluster. The manifest we provide includes custom annotations for the external DNS, specifically for the hostname. These annotations work together with the external DNS controller to access the Kubernetes service through an HTTP path. For more annotations, refer to the [External DNS](https://kubernetes-sigs.github.io/external-dns/v0.13.5/tutorials/aws/#annotations) documentation.

1. Define the `SUB_DOMAIN` environment variable. 

```
export SUB_DOMAIN="game-2048"
```

2. Create the Namespace, Deployment and [Service](https://kubernetes.io/docs/concepts/services-networking/service/) with an ExternalDNS annotation. To learn more about these components, refer to the following resources, [Deployments](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/), [Services, Load Balancing, and Networking](https://kubernetes.io/docs/concepts/services-networking/) & [ExternalDNS](https://github.com/kubernetes-sigs/external-dns) . 

```
cat << EOF > game-2048.yaml
---
apiVersion: v1
kind: Namespace
metadata:
  name: game-2048
---
apiVersion: apps/v1
kind: Deployment
metadata:
  namespace: game-2048
  name: deployment-2048
spec:
  selector:
    matchLabels:
      app.kubernetes.io/name: app-2048
  replicas: 5
  template:
    metadata:
      labels:
        app.kubernetes.io/name: app-2048
    spec:
      containers:
      - image: public.ecr.aws/l6m2t8p7/docker-2048:latest
        imagePullPolicy: Always
        name: app-2048
        ports:
        - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  namespace: game-2048
  name: service-2048
  annotations:
    external-dns.alpha.kubernetes.io/hostname: ${SUB_DOMAIN}.${AWS_ROUTE53_DOMAIN}
spec:
  ports:
    - port: 80
      targetPort: 80
      protocol: TCP
  type: LoadBalancer
  selector:
    app.kubernetes.io/name: app-2048
EOF
```

3. Create the Kubernetes resources by applying the configuration file to the Kubernetes API server.

```
kubectl apply -f game-2048.yaml`
```

You should see the following response output:

```
namespace/game-2048 created
deployment.apps/deployment-2048 created
service/service-2048 created
```

4. You can verify the logs using the following command. Please note that it may take a few seconds to update the entries.  

```
kubectl logs --namespace=kube-system -l "app.kubernetes.io/name=external-dns,app.kubernetes.io/instance=externaldns-release"
```

The expected output should look like this:

```
time="2023-08-31T20:37:38Z" level=info msg="Applying provider record filter for domains: [my-externaldns-demo.com. .my-externaldns-demo.com.]"
time="2023-08-31T20:37:38Z" level=info msg="Desired change: CREATE cname-game-2048.my-externaldns-demo.com TXT [Id: /hostedzone/Z0116663IIIIIIVJ3D]"
time="2023-08-31T20:37:38Z" level=info msg="Desired change: CREATE game-2048.my-externaldns-demo.com A [Id: /hostedzone/Z0116663IIIIIIVJ3D]"
time="2023-08-31T20:37:38Z" level=info msg="Desired change: CREATE game-2048.my-externaldns-demo.com TXT [Id: /hostedzone/Z0116663IIIIIIVJ3D]"
time="2023-08-31T20:37:38Z" level=info msg="3 record(s) in zone game-2048.my-externaldns-demo.com. [Id: /hostedzone/Z0116663IIIIIIVJ3D] were successfully updated"
```

5. You can verify the newly created DNS records, which point to the `game-2048` service within the private hosted zone, by running the following command.

```
aws route53 list-resource-record-sets --hosted-zone-id  ${HOSTED_ZONE_ID}  --query "ResourceRecordSets[?Name == '${SUB_DOMAIN}.${AWS_ROUTE53_DOMAIN}.']"
```

The expected output should look like this:

```
[
    {
        "Name": "game-2048.my-externaldns-demo.com.",
        "Type": "A",
        "AliasTarget": {
            "HostedZoneId": "Z0116663IIIIIIVJ3D",
            "DNSName": "g23456d6180ec4a76540b9a1ecdb17d-1018765421.us-east-1.elb.amazonaws.com.",
            "EvaluateTargetHealth": true
        }
    },
    {
        "Name": "game-2048.my-externaldns-demo.com.",
        "Type": "TXT",
        "TTL": 300,
        "ResourceRecords": [
            {
                "Value": "\"heritage=external-dns,external-dns/owner=/hostedzone/Z0116663IIIIIIVJ3D,external-dns/resource=service/game-2048/service-2048\""
            }
        ]
    }
]
```

6. Since the hosted domain is private, you can access the service `game-2048` using the user-friendly URL `game-2048.my-externaldns-demo.com` from within the pods. We will be creating a test pod and running a curl command to verify the setup.

```
kubectl run nginx-test-conn --image=nginx -n game-2048  && sleep 5 && kubectl exec -it nginx-test-conn -n game-2048 -- sh -c "curl http://${SUB_DOMAIN}.${AWS_ROUTE53_DOMAIN}" > test.html
```

7. Double click the `test.html` file that was created by the previous command. You should see the following contents.

![](./images/out.png)

Please note for public domains, you can access the URL directly from browser.

## Conclusion

With the completion of this tutorial, you’ve effectively deployed the ExternalDNS add-on on your Amazon EKS cluster, enabling automatic DNS management for your Kubernetes services. By integrating with DNS providers like AWS Route 53, you have set the stage for effortless domain name resolution, fully in line with industry standards. This tutorial has walked you through the initial setup of the ExternalDNS add-on, the configuration of environment variables like `HOSTED_ZONE_ID` and `AWS_ROUTE53_DOMAIN`, and the steps for domain registration. You've also delved into the specifics of URL navigation for external clients. 

To continue your journey with a real domain, you'll need to [Register a Domain Name with Amazon Route 53](https://aws.amazon.com/getting-started/hands-on/get-a-domain/). After you've registered a domain name with Amazon Route 53, set the `HOSTED_ZONE_ID` & `AWS_ROUTE53_DOMAIN` variable with your registered domain, then revisit the steps in this guide. By doing so, you'll be able to access the service directly from a browser by navigating to `<SUB_DOMAIN>.<AWS_ROUTE53_DOMAIN>`. This final setup ensures a comprehensive, fully operational environment, poised for both internal and external service accessibility.

## Clean Up

After finishing with this tutorial, for better resource management, you may want to delete the specific resources you created. 

```
# Delete the Deployments, Services by deleting namespace
kubectl delete namespace game-2048 

# Delete the ExternalDNS add-on
helm delete externaldns-release -n kube-system

# Remove Route53 Domain
aws route53 delete-hosted-zone --id ${HOSTED_ZONE_ID}
```

To learn more about ExternalDNS watch this [video](https://www.youtube.com/watch?v=3sUsZq1TA2g) or read kubernetes [documentation](https://kubernetes-sigs.github.io/external-dns/v0.13.5/tutorials/aws/).