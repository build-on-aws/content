---
title: "Designing Scalable and Versatile Storage Solutions on Amazon EKS with the Amazon EFS CSI"
description: "Configure persistent shared storage for container workloads on Amazon EKS with the Amazon EFS CSI"
tags:
    - eks-cluster-setup
    - eks
    - tutorials
    - aws
    - storage
showInHomeFeed: true
waves:
  - modern-apps
spaces:
  - kubernetes
  - modern-apps
authorGithubAlias: ashishkamble4
authorName: Ashish Kamble
date: 2023-09-30
---

Managing storage solutions for containerized applications requires careful planning and execution. Kubernetes workloads such as content management systems and video transcoding may benefit from using Amazon Elastic File System (EFS). EFS is designed to provide serverless, fully elastic file storage that lets you share file data without provisioning or managing storage capacity and performance. EFS is ideal for applications that need shared storage across multiple nodes or even across different availability zones. In contrast, Amazon Elastic Block Store (EBS) requires configuring volumes that are limited by size and region. The Amazon Elastic File System (EFS) CSI Driver add-on exposes EFS File Systems to your workloads, handling the complexities of this versatile and scalable storage solution.

In this tutorial, you will set up the Amazon EFS CSI Driver on your Amazon EKS cluster and configure persistent shared storage for container workloads. More specifically, you will install the EFS CSI Driver as an Amazon EKS add-on. Amazon EKS add-ons automate installation and management of a curated set of add-ons for EKS clusters. You'll configure the EFS CSI Driver to handle both lightweight applications, akin to microservices, and more substantial systems, comparable to databases or user authentication systems, achieving seamless storage management. 


| Attributes             |                                                                 |
|------------------------|-----------------------------------------------------------------|
| ✅ AWS experience      | 200 - Intermediate                                              |
| ⏱ Time to complete     | 30 minutes                                                      |
| 🧩 Prerequisites       | - [AWS Account](https://aws.amazon.com/resources/create-account/|
| 📢 Feedback            | <a href="https://www.pulse.aws/survey/Z8XBGQEL" target="_blank">Any feedback, issues, or just a</a> 👍 / 👎 ?    |
| ⏰ Last Updated        | 2023-09-30                                                      |

| ToC |
|-----|

## Prerequisites

Before you begin this tutorial, you need to:

* Install the latest version of [kubectl](https://kubernetes.io/docs/tasks/tools/#kubectl). To check your version, run: `kubectl version --short`.
* Install the latest version of [eksctl](https://eksctl.io/introduction/#installation). To check your version, run: `eksctl info`.

## Overview

This tutorial is the second installment in a series on optimizing stateful applications in Amazon EKS, focusing on the Amazon EFS CSI Driver for managing complex containerized applications that require persistent and shared storage content across availability zones. This tutorial not only guides you through the configuration of the EFS CSI Driver in the "kube-system" namespace but also delves into the intricacies of storage management within the cluster. It covers the following components:

* **Authentication**: Leverage the pre-configured IAM Role for the Amazon EFS CSI Driver, integrated with the OpenID Connect (OIDC) endpoint, to ensure secure communication between Kubernetes pods and AWS services.
* **EFS CSI Driver Setup**: Deploy the Amazon EFS CSI Driver within the Amazon EKS cluster, focusing on Custom Resource Definitions (CRDs) and the installation of the driver itself.
* **Sample Application Deployment**: Build and deploy a stateful application that writes the current date to a shared EFS volume. Define routing rules and annotations for a Persistent Volume Claim (PVC) based on the CentOS image. Utilize custom annotations for the PVC, specifically the 'accessMode' and 'storageClassName', to instruct the EFS CSI Driver on how to handle storage requests. For Dynamic Provisioning, use the 'storageClassName' annotation to automate the creation of Persistent Volumes (PVs).
* **EFS Access Points and Security**: Explore how the Amazon EFS CSI Driver leverages Amazon EFS access points as application-specific entryways. Understand the role of port 2049 for NFS traffic and how to configure security groups to allow or restrict access based on CIDR ranges. These access points enforce both user identity and root directory, offering flexibility to further refine access based on specific subnets. By fine-tuning the security group to permit traffic on this port, you empower the instances or pods within your designated CIDR range to interact with the shared file system. This granular control not only ensures the accessibility of the EFS File System by relevant cluster resources but also allows for further access restrictions based on specific subnets.
* **Mount Targets**: Delve into the creation of mount targets for the EFS File System, which serve as crucial connection points within the VPC for EC2 instances. It's essential to note that EFS File System only allows one mount target to be created in each Availability Zone, regardless of the subnets within that zone. If you are using an EKS cluster with nodes in private subnets, we recommend creating the Mount targets for those specific subnets.

>Note If you are still in your initial 12-month period, you can get started with EFS for free by receiving 5 GB of EFS storage in the EFS Standard storage class.

## Step 1: Set Environment Variables

Before interacting with your Amazon EKS cluster using command-line tools, it's essential to define specific environment variables that encapsulate your cluster's details. These variables will be used in subsequent commands, ensuring that they target the correct cluster and resources.

1. First, confirm that you are operating within the correct cluster context. This ensures that any subsequent commands are sent to the intended Kubernetes cluster. You can verify the current context by executing the following command:

```bash
kubectl config current-context
```

2. Define the ```CLUSTER_NAME``` environment variable for your EKS cluster. Replace the sample value for cluster ```region```.

```bash
export CLUSTER_NAME=$(aws eks describe-cluster --region us-east-2 --name managednodes-quickstart --query "cluster.name" --output text)
```

3. Define the ```CLUSTER_REGION``` environment variable for your EKS cluster. Replace the sample value for cluster ```region```.

```bash
export CLUSTER_REGION=$(aws eks describe-cluster --name ${CLUSTER_NAME} --query "cluster.arn" --output text | cut -d: -f4)
```

4. Define the ```CLUSTER_VPC``` environment variable for your EKS cluster.

```bash
export CLUSTER_VPC=$(aws eks describe-cluster --name ${CLUSTER_NAME} --region ${CLUSTER_REGION} --query "cluster.resourcesVpcConfig.vpcId" --output text)
```

## Step 2: Verify or Create the IAM Role for Service Account

Now we will verify that the necessary IAM roles for service accounts are configured in your Amazon EKS cluster. These IAM roles are essential for enabling AWS services to interact seamlessly with Kubernetes, allowing you to leverage AWS capabilities within your pods.

Make sure the required service accounts for this tutorial are correctly set up in your cluster.

```bash
kubectl get sa -A | egrep "efs-csi-controller"
```

The expected output should look like this:

```text
kube-system       efs-csi-controller-sa                0         30m
```

**Optionally**, if you do **not** already have the ```“efs-csi-controller-sa”``` service account set up, or you receive an error, the following commands will create the service account. Note that you must have an [OpenID Connect (OIDC) endpoint](https://docs.aws.amazon.com/eks/latest/userguide/enable-iam-roles-for-service-accounts.html?sc_channel=el&sc_campaign=appswave&sc_content=eks-cluster-load-balancer-ipv4&sc_geo=mult&sc_country=mult&sc_outcome=acq) associated with your cluster before you run these commands.

Define the ROLE_NAME environment variable:

```bash
export ROLE_NAME=AmazonEKS_EFS_CSI_DriverRole
```

Run the following command to create the IAM role, Kubernetes service account, and attach the AWS managed policy to the role:

```bash
eksctl create iamserviceaccount \
--name efs-csi-controller-sa \
--namespace kube-system \
--cluster $CLUSTER_NAME \
--region $CLUSTER_REGION \
--role-name $ROLE_NAME \
--role-only \
--attach-policy-arn arn:aws:iam::aws:policy/service-role/AmazonEFSCSIDriverPolicy \
--approve
```

It takes a few minutes for the operation to complete. The expected output should look like this:

```text
2023-08-16 15:27:19 [ℹ]  4 existing iamserviceaccount(s) (cert-manager/cert-manager,default/external-dns,kube-system/aws-load-balancer-controller,kube-system/efs-csi-controller-sa) will be excluded
2023-08-16 15:27:19 [ℹ]  1 iamserviceaccount (kube-system/efs-csi-controller-sa) was excluded (based on the include/exclude rules)
2023-08-16 15:27:19 [!]  serviceaccounts in Kubernetes will not be created or modified, since the option --role-only is used
2023-08-16 15:27:19 [ℹ]  no tasks
```

Run the following command to add the Kubernetes service account name to the trust policy for the IAM role:

```bash
export TRUST_POLICY=$(aws iam get-role --role-name $ROLE_NAME --query 'Role.AssumeRolePolicyDocument' | \
sed -e 's/efs-csi-controller-sa/efs-csi-*/' -e 's/StringEquals/StringLike/')
```

Update the IAM role:

```bash
aws iam update-assume-role-policy --role-name $ROLE_NAME --policy-document "$TRUST_POLICY" --region $CLUSTER_REGION
```

## Step 3: Verify or Install the EFS CSI Driver Add-on

Here, we will verify that the EFS CSI Driver managed add-on is properly installed and active on your Amazon EKS cluster. The EFS CSI Driver is crucial for enabling Amazon EFS to work seamlessly with Kubernetes, allowing you to mount EFS File Systems as persistent volumes for your batch workloads.

Check whether the EFS CSI driver add-on is installed on your cluster:

```bash
eksctl get addon --cluster ${CLUSTER_NAME} --region ${CLUSTER_REGION} | grep efs
```

The expected output should look like this:

```text
aws-efs-csi-driver      v1.5.8-eksbuild.1       ACTIVE  0
```

**Optionally**, if the EFS CSI Driver add-on is **not** installed on your cluster, or you receive an error, the following commands show you the steps to install it. Note that you must have an [OpenID Connect (OIDC) endpoint](https://docs.aws.amazon.com/eks/latest/userguide/enable-iam-roles-for-service-accounts.html?sc_channel=el&sc_campaign=appswave&sc_content=eks-cluster-load-balancer-ipv4&sc_geo=mult&sc_country=mult&sc_outcome=acq) associated with your cluster before you run these commands.

List the add-ons available in eksctl. Replace the sample value for ```kubernetes-version```.

```bash
eksctl utils describe-addon-versions --kubernetes-version 1.27 | grep AddonName
```

The expected output should look like this:

```text
"AddonName": "coredns",
"AddonName": "aws-guardduty-agent",
"AddonName": "aws-ebs-csi-driver",
"AddonName": "vpc-cni",
"AddonName": "kube-proxy",
"AddonName": "aws-efs-csi-driver",
"AddonName": "adot",
"AddonName": "kubecost_kubecost",
```

Set an environment variable for the “aws-efs-csi-driver” add-on:

```bash
export ADD_ON=aws-efs-csi-driver
```

List the versions of add-ons available for Kubernetes v1.27: 

```bash
eksctl utils describe-addon-versions --kubernetes-version 1.27 --name $ADD_ON | grep AddonVersion
```

The expected output should look like this:

```text
"AddonVersions": [
"AddonVersion": "v1.5.8-eksbuild.1",
```

Retrieve the ```Arn``` for the “AmazonEKS_EFS_CSI_DriverRole” we created in previous steps:

```bash
aws iam get-role --role-name AmazonEKS_EFS_CSI_DriverRole | grep Arn
```

The expected output should look like this:

```text
"Arn": "arn:aws:iam::xxxxxxxxxxxx:role/AmazonEKS_EFS_CSI_DriverRole",
```

Run the following command to install the EFS CSI Driver add-on. Replace the ```service-account-role-arn``` with the ARN from the previous step.

```bash
eksctl create addon --cluster $CLUSTER_NAME --name $ADD_ON --version latest \
--service-account-role-arn arn:aws:iam::xxxxxxxxxxxx:role/AmazonEKS_EFS_CSI_DriverRole
```

The expected output should look like this:

```text
[ℹ] Kubernetes version "1.27" in use by cluster "CLUSTER_NAME"
[ℹ] using provided ServiceAccountRoleARN "arn:aws:iam::xxxxxxxxxxxx:role/AmazonEKS_EFS_CSI_DriverRole"
[ℹ] creating addon
[ℹ] addon "aws-efs-csi-driver" active
```

## Step 4: Create an EFS File System

In this section, you will create an EFS File System and create a security group. The security group permits ingress from the CIDR for your cluster’s VPC to the EFS service. The security group is further restricted to port 2049, the standard port for NFS.

1. Retrieve the CIDR range for your cluster's VPC and store it in an environment variable:

```bash
export CIDR_RANGE=$(aws ec2 describe-vpcs \
    --vpc-ids $CLUSTER_VPC \
    --query "Vpcs[].CidrBlock" \
    --output text \
    --region $CLUSTER_REGION)
```

2. Create a security group with an inbound rule that allows inbound NFS traffic for your Amazon EFS mount points:

```bash
export SECURITY_GROUP_ID=$(aws ec2 create-security-group \
    --group-name MyEfsSecurityGroup \
    --description "My EFS security group" \
    --vpc-id $CLUSTER_VPC \
    --region $CLUSTER_REGION \
    --output text)
```

3. Create an inbound rule that allows inbound NFS traffic from the CIDR for your cluster's VPC.

```bash
aws ec2 authorize-security-group-ingress \
    --group-id $SECURITY_GROUP_ID \
    --protocol tcp \
    --port 2049 \
    --cidr $CIDR_RANGE \
    --region $CLUSTER_REGION
```

The expected output should look like this:

```text
{
    "Return": true,
    "SecurityGroupRules": [
        {
            "SecurityGroupRuleId": "sgr-0106e3f85cd3b82d9",
            "GroupId": "sg-0a0a11596fe0ae56f",
            "GroupOwnerId": "000866617021",
            "IsEgress": false,
            "IpProtocol": "tcp",
            "FromPort": 2049,
            "ToPort": 2049,
            "CidrIpv4": "192.168.0.0/16"
        }
    ]
}
```

Now, we’ll create an Amazon EFS File System for our Amazon EKS cluster.

```bash
export FILE_SYSTEM_ID=$(aws efs create-file-system \
--region $CLUSTER_REGION \
--performance-mode generalPurpose \
--query 'FileSystemId' \
--output text)
```

## Step 5: Configure Mount Targets for the EFS File System

EFS only allows one mount target to be created in each Availability Zone, so you’ll need to place the mount target on the appropriate subnet. If your worker nodes are on a private subnet, you should create the mount target on that subnet. We will now create mount targets for the EFS File System, The mount target is an IP address on a VPC subnet that accepts NFS traffic. The Kubernetes nodes will open NFS connections with the IP address of the mount target.

1. Determine the IP address of your cluster nodes:

```bash
kubectl get nodes
```

The expected output should look like this:

```text
NAME                                         STATUS   ROLES    AGE   VERSION
ip-192-168-56-0.region-code.compute.internal   Ready    <none>   19m   v1.XX.X-eks-49a6c0
```

2. Determine the IDs of the subnets in your VPC and which Availability Zone the subnet is in.

```bash
aws ec2 describe-subnets \
    --filters "Name=vpc-id,Values=$CLUSTER_VPC" \
    --region $CLUSTER_REGION \
    --query 'Subnets[*].{SubnetId: SubnetId,AvailabilityZone: AvailabilityZone,CidrBlock: CidrBlock}' \
    --output table
```

The expected output should look like this:

```text
|                           DescribeSubnets                          |
+------------------+--------------------+----------------------------+
| AvailabilityZone |     CidrBlock      |         SubnetId           |
+------------------+--------------------+----------------------------+
|  region-codec    |  192.168.128.0/19  |  subnet-EXAMPLE6e421a0e97  |
|  region-codeb    |  192.168.96.0/19   |  subnet-EXAMPLEd0503db0ec  |
|  region-codec    |  192.168.32.0/19   |  subnet-EXAMPLEe2ba886490  |
|  region-codeb    |  192.168.0.0/19    |  subnet-EXAMPLE123c7c5182  |
|  region-codea    |  192.168.160.0/19  |  subnet-EXAMPLE0416ce588p  |
+------------------+--------------------+----------------------------+
```

3. **Add Mount Targets** for the Subnets Hosting Your Nodes: Run the following command to create the mount target, specifying each subnet. For example, if the cluster has a node with an IP address of 192.168.56.0, and this address falls within the CidrBlock of the subnet ID subnet-EXAMPLEe2ba886490, create a mount target for this specific subnet. Repeat this process for each subnet in every Availability Zone where you have a node, using the appropriate subnet ID.

```bash
aws efs create-mount-target \
    --file-system-id $FILE_SYSTEM_ID \
    --subnet-id subnet-EXAMPLEe2ba886490 \
    --security-groups $SECURITY_GROUP_ID \
    --region $CLUSTER_REGION
```

>Note: EFS only allows 1 mount target to be created in one Availability Zone, irrespective of the subnets in the Availability Zone. If you are using an EKS cluster with Worker Nodes in Private Subnets, it would be recommended to create the mount targets for the same subnets.

## Step 6: Set Up a Storage Class for the Sample Application

In Kubernetes, there are two ways to provision storage for container applications: Static Provisioning and Dynamic Provisioning. In Static Provisioning, a cluster administrator manually creates Persistent Volumes (PVs) that specify the available storage for the cluster's users. These PVs are part of the Kubernetes API and can be easily used. On the other hand, Dynamic Provisioning automates the creation of PVs. Kubernetes uses Storage Classes to generate PVs automatically when a pod requests storage through PersistentVolumeClaims. This method simplifies the provisioning process and adjusts to the specific needs of the application. To learn more, refer [PersistentVolumes](https://kubernetes.io/docs/concepts/storage/persistent-volumes/) in Kubernetes documentation. For our lab, we will use the “Dynamic Provisioning Method” method.


1. First, download the Storage Class manifest:

```bash
curl -O https://raw.githubusercontent.com/kubernetes-sigs/aws-efs-csi-driver/master/examples/kubernetes/dynamic_provisioning/specs/storageclass.yaml
```

2. Verify that the ```$FILE_SYSTEM_ID``` environment variable is configured:

```bash
echo $FILE_SYSTEM_ID
```

3. Update the FileSystem identifier in the storageclass.yaml manifest:

```bash
sed -i 's/fs-92107410/$FILE_SYSTEM_ID/g' storageclass.yaml
```

4. **Optionally**, if you're running this on macOS, run the following command to change the file system:

```bash
sed -i '' 's/fs-92107410/'"$FILE_SYSTEM_ID"'/g' storageclass.yaml
```

5. Deploy the Storage Class: 

```bash 
kubectl apply -f storageclass.yaml
```

The expected output should look like this:

```text
storageclass.storage.k8s.io/efs-sc created
```

## Step 7: Deploy a Sample Application

Let's deploy a sample application that writes the current date to a shared location on the EFS Shared Volume. The deployment process begins by downloading a manifest file containing the specifications for a Persistent Volume Claim (PVC) and a pod based on the CentOS image.

1. First, download the PersistentVolumeClaim manifest:

```bash
curl -O https://raw.githubusercontent.com/kubernetes-sigs/aws-efs-csi-driver/master/examples/kubernetes/dynamic_provisioning/specs/pod.yaml
```

>Note: This manifest includes our Sample pod that utilizes the CentOs Image. It incorporates specific parameters to record the Current Date and store it in the /data/out directory on the EFS Shared Volume. Furthermore, the Manifest includes a PVC (Persistent Volume Claim) object that requests 5Gi Storage from the Storage Class we established in the preceding step.

2. Now, we will deploy our sample application that will write "Current Date" to a shared location:

```bash
kubectl apply -f pod.yaml
```

3. Run the following command to ensure the sample application was deployed successfully and is running as expected:

```bash
kubectl get pods -o wide
```

The expected output should look like this:

```text
NAME          READY   STATUS    RESTARTS   AGE   IP               NODE                                             NOMINATED NODE   READINESS GATES
efs-app       1/1     Running   0          10m   192.168.78.156   ip-192-168-73-191.region-code.compute.internal   <none>           <none>
```

>Note: It will take a couple minutes for the pod to transition to the "Running" state. If the pod remains in a "ContainerCreating" state, make sure that you have included a mount target for the subnet where your node is located (as shown in step two). Without this step, the pod will remain stuck in the "ContainerCreating" state.

4. Verify that the data is being written to the /data/out location within the shared EFS volume. Use the following command to verify:

```bash
kubectl exec efs-app -- bash -c "cat data/out"
```

The expected output should look like this:

```text
[...]
Fri Aug 4 09:13:40 UTC 2023
Fri Aug 4 09:13:45 UTC 2023
Fri Aug 4 09:13:50 UTC 2023
Fri Aug 4 09:13:55 UTC 2023
[...]
```

>Optionally, terminate the node hosting your pod and await pod rescheduling. Alternatively, you may delete the pod and redeploy it. Repeat the previous step once more, ensuring the output contains the prior output.

## Clean Up

To avoid incurring future charges, you should delete the resources created during this tutorial.

```text
# Delete the pod
kubectl delete -f pod.yaml

# Delete the Storage Class
kubectl delete -f storageclass.yaml

# Delete the EFS CSI add-on
eksctl delete addon --cluster $CLUSTER_NAME --name $ADD_ON

# Delete the IAM Role
aws iam delete-role --role-name AmazonEKS_EFS_CSI_DriverRole
```

## Conclusion

With the completion of this tutorial, you have successfully configured Amazon EFS for persistent storage for your EKS-based container workloads. The sample pod, leveraging the CentOS image, has been configured to capture the current date and store it in the ```/data/out``` directory on the EFS shared volume. To align with best practices, we recommend running your container workloads on private subnets, exposing only ingress controllers in the public subnets. Furthermore, make sure that EFS mount targets are established in all availability zones where your EKS cluster resides; otherwise, you may encounter a 'Failed to Resolve' error. To continue your journey, you're now ready to store your stateful workloads like batch processes or machine learning training data to your EFS volume. 
