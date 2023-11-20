---
title: "Easily Consume AWS Secrets Manager Secrets From Your Amazon EKS Workloads"
description: "Leverage secret stores without complex code modifications."
tags:
    - eks-cluster-setup
    - eks
    - kubernetes
    - tutorials
    - aws
waves:
  - modern-apps
spaces:
  - kubernetes
authorGithubAlias: rstebaws
authorName: Ryan Stebich
date: 2023-10-30
---

Secrets management is a challenging but critical aspect of running secure and dynamic containerized applications at scale. To support this need to securely distribute secrets to running applications, Kubernetes provides native functionality to manage secrets in the form of [Kubernetes Secrets](https://kubernetes.io/docs/concepts/configuration/secret/). However, many customers choose to centralize the management of secrets outside of their Kubernetes clusters by using external secret stores such as [AWS Secrets Manager](https://aws.amazon.com/secrets-manager/?sc_channel=el&sc_campaign=appswave&sc_content=eks-integrate-secrets-manager&sc_geo=mult&sc_country=mult&sc_outcome=acq) to improve the security, management, and auditability of their secret usage.

Consuming secrets from external secret stores often requires modifications to your application code so it supports secret store specific API calls, allowing retrieval of secrets at application run time. This can increase the complexity of your application code base and potentially reduce the portability of containerized applications as they move between environments or even leverage different secret stores. However, when running applications on [Amazon EKS](https://aws.amazon.com/eks/?sc_channel=el&sc_campaign=appswave&sc_content=eks-integrate-secrets-manager&sc_geo=mult&sc_country=mult&sc_outcome=acq), you have a more streamlined alternative that minimizes code changes. Specifically, you can leverage the [AWS Secrets and Configuration Provider](https://github.com/aws/secrets-store-csi-driver-provider-aws) (ASCP) and the [Kubernetes Secrets Store CSI Driver](https://secrets-store-csi-driver.sigs.k8s.io/). Acting as a bridge between AWS Secrets Manager and your Kubernetes environment, ASCP mounts your application secrets directly into your pods as files within a mounted storage volume. This approach simplifies management and enhances the portability of your workloads, without requiring significant application-level code modifications to access secrets.

Building on the Amazon EKS cluster from [**part 1**](/tutorials/navigating-amazon-eks/eks-cluster-high-traffic) of our series, this tutorial dives into setting up the AWS Secrets and Configuration Provider(ASCP) for the Kubernetes Secrets Store CSI Driver. Included in the cluster configuration for the previous tutorial is the OpenID Connect (OIDC) endpoint to be used by the ASCP IAM Role for Service Account (IRSA). For part one of this series, see [Building an Amazon EKS Cluster Preconfigured to Run High Traffic Microservices](/tutorials/navigating-amazon-eks/eks-cluster-high-traffic). Alternatively, to set up an existing cluster with the components required for this tutorial, use the instructions in [Create an IAM OpenID  Connect (OIDC) endpoint](https://docs.aws.amazon.com/eks/latest/userguide/enable-iam-roles-for-service-accounts.html?sc_channel=el&sc_campaign=appswave&sc_content=eks-integrate-secrets-manager&sc_geo=mult&sc_country=mult&sc_outcome=acq) in EKS official documentation.

In this tutorial, you will learn how to set up the [AWS Secrets and Configuration Provider](https://github.com/aws/secrets-store-csi-driver-provider-aws) (ASCP) for the [Kubernetes Secrets Store CSI Driver](https://secrets-store-csi-driver.sigs.k8s.io/) on your Amazon EKS cluster and AWS Secrets Manager to store you application secrets. You will leverage ASCP to expose secrets to your applications running on EKS improving the security and portability of your workloads.

| Attributes             |                                                                 |
|------------------------|-----------------------------------------------------------------|
| ✅ AWS experience      | 200 - Intermediate                                              |
| ⏱ Time to complete     | 30 minutes                                                      |
| 🧩 Prerequisites       | - [AWS Account](https://aws.amazon.com/resources/create-account/?sc_channel=el&sc_campaign=appswave&sc_content=eks-integrate-secrets-manager&sc_geo=mult&sc_country=mult&sc_outcome=acq)|
| 📢 Feedback            | <a href="https://www.pulse.aws/survey/Z8XBGQEL" target="_blank">Any feedback, issues, or just a</a> 👍 / 👎 ?    |
| ⏰ Last Updated        | 2023-10-30                                                      |

| ToC |
|-----|

## Prerequisites

* Install the latest version of [kubectl](https://kubernetes.io/docs/tasks/tools/#kubectl). To check your version, run: `kubectl version --short`
* Install the latest version of [eksctl](https://eksctl.io/introduction/#installation). To check your version, run: `eksctl info`
* Install the latest version of [Helm](https://helm.sh/docs/intro/install/). To check your version, run: `helm version`
* Install the latest version of the [AWS CLI (v2)](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html?sc_channel=el&sc_campaign=appswave&sc_content=eks-integrate-secrets-manager&sc_geo=mult&sc_country=mult&sc_outcome=acq). To check your version, run: `aws --version`
* Get [IAM OIDC provider](https://docs.aws.amazon.com/eks/latest/userguide/enable-iam-roles-for-service-accounts.html?sc_channel=el&sc_campaign=appswave&sc_content=eks-integrate-secrets-manager&sc_geo=mult&sc_country=mult&sc_outcome=acq) configured on an existing EKS cluster.

## Overview

This tutorial is part of a series on managing high traffic microservices platforms using Amazon EKS, and it's dedicated to managing application secrets with [AWS Secrets and Configuration Provider](https://github.com/aws/secrets-store-csi-driver-provider-aws) (ASCP) for the [Kubernetes Secrets Store CSI Driver](https://secrets-store-csi-driver.sigs.k8s.io/). This tutorial shows not only how to consume an external secret from your EKS workloads, but also how to create a secret in AWS Secrets Manager. It covers the following components:

* **Secret Creation** — Creation of an application secret in [AWS Secrets Manager](https://aws.amazon.com/secrets-manager/?sc_channel=el&sc_campaign=appswave&sc_content=eks-integrate-secrets-manager&sc_geo=mult&sc_country=mult&sc_outcome=acq) to be consumed by the sample pod.
* **Authentication** — Necessary IAM Role for Service Account (IRSA) mappings to enable communication between Kubernetes pods and AWS. This includes the Pod service account that will be used to access the [AWS Secrets Manager](https://aws.amazon.com/secrets-manager/?sc_channel=el&sc_campaign=appswave&sc_content=eks-integrate-secrets-manager&sc_geo=mult&sc_country=mult&sc_outcome=acq) secret via the [AWS Secrets and Configuration Provider](https://github.com/aws/secrets-store-csi-driver-provider-aws) (ASCP).
* **ASCP Setup** — Deployment of the [AWS Secrets and Configuration Provider](https://github.com/aws/secrets-store-csi-driver-provider-aws) (ASCP) and the [Kubernetes Secrets Store CSI Driver](https://secrets-store-csi-driver.sigs.k8s.io/). 
* **Sample Application Deployment** — Deploy a sample pod to mount the secret from [AWS Secrets Manager](https://aws.amazon.com/secrets-manager/?sc_channel=el&sc_campaign=appswave&sc_content=eks-integrate-secrets-manager&sc_geo=mult&sc_country=mult&sc_outcome=acq) and execute a command in the pod to validate the secret is accessible.

>Note that [AWS Secrets Manager](https://aws.amazon.com/secrets-manager/pricing/?sc_channel=el&sc_campaign=appswave&sc_content=eks-integrate-secrets-manager&sc_geo=mult&sc_country=mult&sc_outcome=acq) includes a 30-day free trial period that starts when you store your first secret. If you have already stored a secret and are past the 30-day mark, additional charges based on usage will apply. 

## Step 1: Set Environment Variables

Before interacting with your Amazon EKS cluster using Helm or other command-line tools, it's essential to define specific environment variables that encapsulate your cluster's details. These variables will be used in subsequent commands, ensuring that they target the correct cluster and resources.

1. First, confirm that you are operating within the correct cluster context. This ensures that any subsequent commands are sent to the intended Kubernetes cluster. You can verify the current context by executing the following command:

```bash
kubectl config current-context
```

2. Define the `CLUSTER_NAME` environment variable for your EKS cluster. Replace the sample value for cluster `region`. If you are using your own existing EKS cluster, replace the sample value for `name`.

```bash
export CLUSTER_NAME=$(aws eks describe-cluster --region us-east-2 --name managednodes-quickstart --query "cluster.name" --output text)
```

3. Define the `CLUSTER_REGION` environment variable for your EKS cluster. Replace the sample value for cluster `region`.

```bash
export CLUSTER_REGION=$(aws eks describe-cluster --name ${CLUSTER_NAME} --region us-east-2 --query "cluster.arn" --output text | cut -d: -f4)
```

To validate the variables have been set properly, run the following commands. Verify the output matches your specific inputs. 

```bash
echo $CLUSTER_REGION
echo $CLUSTER_NAME
```

## Step 2: Create Secret in AWS Secrets Manager

Creating a secret in AWS Secrets Manager is the first step in securely managing sensitive information for your applications. Using the AWS CLI, you'll store a sample secret that will later be accessed by your Kubernetes cluster. This eliminates the need to hard-code sensitive information in your application, thereby enhancing security. 

```bash
SECRET_ARN=$(aws secretsmanager create-secret --name eksSecret --secret-string '{"username":"eksdemo", "password":"eksRocks!"}' --region "$CLUSTER_REGION" --query ARN) 
```

The above command will store the Secret’s ARN in a variable for later use. To validate you successfully created the secret, run the following command to output the variable:

```bash
echo $SECRET_ARN
```

The expected output should look like this:

```bash
"arn:aws:secretsmanager:us-east-2:0123456789:secret:eksSecret-JeuuzY"
```

## Step 3: Create IAM Policy for Accessing the Secret in AWS Secrets Manager

In this section, you'll use the AWS CLI to create an IAM policy that grants specific permissions for accessing the secret stored in AWS Secrets Manager. By using the `$SECRET_ARN` variable from the previous step, you'll specify which secret the IAM policy should apply to. This approach ensures that only the specified secret can be accessed by authorized entities within your Kubernetes cluster. We will associate this IAM Policy to a Kubernetes service account in the next step. 

```bash
POLICY_ARN=$(aws --region "$CLUSTER_REGION" --query Policy.Arn --output text iam create-policy --policy-name eksdemo-secretsmanager-policy --policy-document '{
    "Version": "2012-10-17",
    "Statement": [ {
        "Effect": "Allow",
        "Action": ["secretsmanager:GetSecretValue", "secretsmanager:DescribeSecret"],
        "Resource": ['$SECRET_ARN']
    } ]
}')
```

The above command will store the policy’s ARN in a variable for later use. To validate you successfully created the policy, run the following command to output the variable:

```bash
echo $POLICY_ARN
```

The expected output should look like this: 

```bash
`arn:aws:iam::0123456789:policy/eksdemo-secretsmanager-policy`
```

## Step 4: Create IAM Role and Associate With Kubernetes Service Account

In this section, you'll use [IAM Roles for service accounts (IRSA)](https://docs.aws.amazon.com/eks/latest/userguide/iam-roles-for-service-accounts.html?sc_channel=el&sc_campaign=appswave&sc_content=eks-integrate-secrets-manager&sc_geo=mult&sc_country=mult&sc_outcome=acq) to map your Kubernetes service accounts to AWS IAM roles, thereby enabling fine-grained permission management for your applications running on EKS. Using [eksctl](https://eksctl.io/), you'll create and associate an AWS IAM Role with a specific Kubernetes service account within your EKS cluster. With the Secret Store CSI driver, you will apply IAM permissions at the application pod level, not the CSI driver pods. This ensures that only the specific application pods that are leveraging the IRSA associated Kubernetes service account will have permission to access the secret stored in AWS Secrets Manager. We will associate the IAM policy we created in the previous step to the newly created IAM role. Note that you must have an [OpenID Connect (OIDC) endpoint](https://docs.aws.amazon.com/eks/latest/userguide/enable-iam-roles-for-service-accounts.html?sc_channel=el&sc_campaign=appswave&sc_content=eks-integrate-secrets-manager&sc_geo=mult&sc_country=mult&sc_outcome=acq) associated with your cluster before you run these commands.

```bash
eksctl create iamserviceaccount --name eksdemo-secretmanager-sa --region="$CLUSTER_REGION" --cluster "$CLUSTER_NAME" --attach-policy-arn "$POLICY_ARN" --approve --override-existing-serviceaccounts
```

Upon completion, you should see the following response output:

```bash
[2023-08-07 15](tel:2023080715):45:32 [ℹ] created serviceaccount "default/eksdemo-secretmanager-sa"
```

Ensure the "eksdemo-secretmanager-sa" service account is correctly set up in the "default" namespace in your cluster.

```bash
kubectl get sa eksdemo-secretmanager-sa -o yaml
```

The expected output should look like this:

```bash
apiVersion: v1
kind: ServiceAccount
metadata:
  annotations:
    eks.amazonaws.com/role-arn: arn:aws:iam::01234567890:role/eksctl-managednodes-quickstart-addon-iamserv-Role1-WRJJQSRMC4LK
  creationTimestamp: "2023-09-12T18:32:23Z"
  labels:
    app.kubernetes.io/managed-by: eksctl
  name: eksdemo-secretmanager-sa
  namespace: default
  resourceVersion: "4456"
  uid: 5c7989b7-2cdb-42f6-a9ee-db20a7e484d9
```

## Step 5: Install AWS Secrets and Configuration Provider and Secrets Store CSI Driver

In this section, you’ll install the [AWS Secrets and Configuration Provider (ASCP)](https://github.com/aws/secrets-store-csi-driver-provider-aws) and [Secrets Store CSI Driver](https://github.com/aws/secrets-store-csi-driver-provider-aws) using [Helm](https://helm.sh/docs/intro/install/), which sets up a secure bridge between AWS Secrets Manager and your Kubernetes cluster. This enables your cluster to access secrets stored in AWS Secrets Manager without requiring complex application-code changes. The ASCP and Secrets Store CSI Driver will each be installed as DaemonSets to ensure a copy of the driver and provider are running on each node in the cluster. 

The following command will add the Secrets Store CSI Driver Helm chart repository to your local Helm index to allow for installation: 

```bash
helm repo add secrets-store-csi-driver https://kubernetes-sigs.github.io/secrets-store-csi-driver/charts
```

The expected output should look like this:

```bash
"secrets-store-csi-driver" has been added to your repositories
```

The following command will add the AWS Secrets and Configuration Provider(ASCP) Helm chart repository to your local Helm index to allow for installation:

```bash
helm repo add aws-secrets-manager https://aws.github.io/secrets-store-csi-driver-provider-aws
```

The expected output should look like this:

```bash
"aws-secrets-manager" has been added to your repositories
```

To install the Secrets Store CSI Driver, run the following Helm command: 

```bash
helm install -n kube-system csi-secrets-store secrets-store-csi-driver/secrets-store-csi-driver
```

The expected output should look like this:

```bash
NAME: csi-secrets-store
LAST DEPLOYED: Fri Sep 29 17:30:00 2023
NAMESPACE: kube-system
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
The Secrets Store CSI Driver is getting deployed to your cluster.

To verify that Secrets Store CSI Driver has started, run:

kubectl --namespace=kube-system get pods -l "app=secrets-store-csi-driver"

Now you can follow these steps https://secrets-store-csi-driver.sigs.k8s.io/getting-started/usage.html
to create a SecretProviderClass resource, and a deployment using the SecretProviderClass.
```

As mentioned in the above output, to verify the Secrets Store CSI Driver has started run the following command:

```bash
kubectl --namespace=kube-system get pods -l "app=secrets-store-csi-driver"
```

You should see the following output. Make sure all the pod’s `STATUS` are `Running`:

```bash
NAME READY STATUS RESTARTS AGE
csi-secrets-store-secrets-store-csi-driver-5l4sr 3/3 Running 0 2m31s
csi-secrets-store-secrets-store-csi-driver-jhbnf 3/3 Running 0 2m31s
csi-secrets-store-secrets-store-csi-driver-qsdm6 3/3 Running 0 2m31s
```

To install the AWS Secrets and Configuration Provider(ASCP), run the following Helm command:

```bash
helm install -n kube-system secrets-provider-aws aws-secrets-manager/secrets-store-csi-driver-provider-aws
```

The expected output should look like this:

```bash
NAME: secrets-provider-aws
LAST DEPLOYED: Tue Sep 12 18:33:45 2023
NAMESPACE: kube-system
STATUS: deployed
REVISION: 1
TEST SUITE: None
```

You can also run the following Helm command to verify the installation has completed successfully: 

```bash
`helm list -n kube-system` 
```

You will see an output like below:

```bash
NAME NAMESPACE REVISION UPDATED STATUS CHART APP VERSION
csi-secrets-store kube-system [1 2023-08-07 15](tel:12023080715):39:24.856932796 +0000 UTC deployed secrets-store-csi-driver-1.3.4 1.3.4
secrets-provider-aws kube-system [1 2023-08-07 15](tel:12023080715):39:55.851595668 +0000 UTC deployed secrets-store-csi-driver-provider-aws-0.3.4
```

## Step 6: Create ASCP SecretProviderClass Resource

In this section, you’re defining the `SecretProviderClass` Kubernetes object, which sets the stage for seamless secrets management within your Kubernetes workloads. This resource acts as a set of instructions for the AWS Secrets and Configuration Provider (ASCP), specifying which secrets to fetch from AWS Secrets Manager and how to mount them into your pods. Note that the SecretProviderClass must be deployed in the same namespace as the workload that references it. To learn more, see [SecretProviderClass documentation](https://docs.aws.amazon.com/secretsmanager/latest/userguide/integrating_csi_driver_SecretProviderClass.html?sc_channel=el&sc_campaign=appswave&sc_content=eks-integrate-secrets-manager&sc_geo=mult&sc_country=mult&sc_outcome=acq).

Create a Kubernetes manifest called `eksdemo-spc.yaml` and paste the following contents into it:

```yaml
apiVersion: secrets-store.csi.x-k8s.io/v1
kind: SecretProviderClass
metadata:
  name: eks-demo-aws-secrets
  namespace: default
spec:
  provider: aws
  parameters:
    objects: |
        - objectName: "eksSecret"
          objectType: "secretsmanager"
```

Apply the YAML manifest. 

```bash
`kubectl apply -f eksdemo-spc.yaml`
```

To verify the SecretProviderClass was created successfully, run the following command:

```bash
kubectl describe secretproviderclass eks-demo-aws-secrets
```

The expected output should look like this:

```bash
Name:         eks-demo-aws-secrets
Namespace:    default
Labels:       <none>
Annotations:  <none>
API Version:  secrets-store.csi.x-k8s.io/v1
Kind:         SecretProviderClass
Metadata:
  Creation Timestamp:  2023-08-09T21:13:50Z
  Generation:          1
  Resource Version:    9853
  UID:                 d11bbadc-f3c8-4e70-8b1e-effe72b1518e
Spec:
  Parameters:
    Objects:  - objectName: "eksSecret"
  objectType: "secretsmanager"

  Provider:  aws
Events:      <none>
```

## Step 7: Deploy Sample Workload to Consume Secret

In this section, you'll deploy a sample workload to bridge your application and AWS Secrets Manager. By mounting the secret as a file on the workload's filesystem, you'll complete the end-to-end process of securely managing and accessing secrets within your Kubernetes environment. In the pod template you will specify the Secrets Store CSI as the volume driver and then a path to mount your secret, just like you would a traditional volume mount. In this example we will mount the secret in the `/mnt/secrets-store` location.

Create a Kubernetes manifest called `eksdemo-app.yaml` and paste the following contents into it: 

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: busybox
  namespace: default
spec:
  serviceAccountName: eksdemo-secretmanager-sa
  volumes:
  - name: secrets-store-inline
    csi:
       driver: secrets-store.csi.k8s.io
       readOnly: true
       volumeAttributes:
         secretProviderClass: "eks-demo-aws-secrets"
  containers:
  - image: public.ecr.aws/docker/library/busybox:1.36
    command:
      - sleep
      - "3600"
    imagePullPolicy: IfNotPresent
    name: busybox
    volumeMounts:
    - name: secrets-store-inline
      mountPath: "/mnt/secrets-store"
      readOnly: true
  restartPolicy: Always
```

Apply the YAML manifest. 

```bash
`kubectl apply ``-``f eksdemo-app.yaml`
```

To verify the pod was created successfully, run the following command:

```bash
kubectl get pod busybox
```

You should see the following output. Make sure the pod  `STATUS` is `Running`:

```bash
NAME READY STATUS RESTARTS AGE
busybox 1/1 Running 0 11s
```

## Step 8: Test the Secret

Finally, we’ll use kubectl to execute into the pod we just deployed and see if we can read the mounted secret. 

```bash
kubectl exec -it $(kubectl get pods | awk '/busybox/{print $1}' | head -1) -- cat /mnt/secrets-store/eksSecret; echo
```

This command should output the secret we created earlier:

```bash
`{"username":"eksdemo", "password":"eksRocks!"}`
```

## Clean Up

After finishing with this tutorial, for better resource management, you may want to delete the specific resources you created. 

```bash
# Delete the Sample Pod
kubectl delete pod busybox

# Delete the SecretProviderClass Resources
kubectl delete secretproviderclass eks-demo-aws-secrets

# Remove IAM Roles for Service Accounts (IRSA
`eksctl ``delete`` iamserviceaccount` --cluster="$CLUSTER_NAME" --name=eksdemo-secretmanager-sa --region="$CLUSTER_REGION"

# Delete AWS Secrets Manager Secret without recovery window
aws secretsmanager delete-secret --secret-id eksSecret --region "$CLUSTER_REGION" --force-delete-without-recovery

# Uninstall the AWS Secrets and Configuration Provider
helm uninstall -n kube-system csi-secrets-store
helm uninstall -n kube-system secrets-provider-aws

# Delete IAM Policy
aws iam delete-policy --policy-arn $POLICY_ARN
```

## Conclusion

Upon completion of this tutorial, you will have successfully set up an integration between AWS Secrets Manager and your Amazon EKS cluster. This integration allows you to centralize the management of your application secrets, while easily consuming these secrets from your workloads running on EKS, without complex code modifications. Security and governance of your secrets as well as portability of your applications is improved with minimal overhead. This example can easily be replicated for the various types of secrets your workloads may require such as database credentials, API keys, and more. 

To learn more about setting up and managing Amazon EKS for your workloads, check out [Navigating Amazon EKS](https://community.aws/tutorials/navigating-amazon-eks#list-of-all-tutorials?sc_channel=el&sc_campaign=appswave&sc_content=eks-integrate-secrets-manager&sc_geo=mult&sc_country=mult&sc_outcome=acq).
