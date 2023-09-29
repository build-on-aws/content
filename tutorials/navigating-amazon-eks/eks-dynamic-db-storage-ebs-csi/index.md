---
title: "Dynamic Database Storage with the Amazon EBS CSI Driver for Amazon EKS"
description: "How to implement dynamic provisioning of Amazon EBS volumes for your self-managed databases in Kubernetes with the EBS CSI Driver Add-On."
tags:
    - eks-cluster-setup
    - eks
    - kubernetes
    - tutorials
    - eksctl
    - ebs
    - aws
showInHomeFeed: true
waves:
  - modern-apps
spaces:
  - kubernetes
authorGithubAlias: madhusnagaraj
authorName: Madhu Nagaraj
additionalAuthors: 
  - authorGithubAlias: tucktuck9
    authorName: Leah Tucker
movedFrom: /tutorials/eks-dynamic-db-storage-ebs-csi
date: 2023-08-30
---

In today's cloud computing landscape, enterprises and SaaS platforms face challenges in managing complex databases and real-time data processing. These scenarios require storage solutions that are both robust and scalable. AWS offers Container Storage Interface (CSI) drivers for its various storage services, including Amazon Elastic Block Store (EBS). These drivers enable you to choose the right type of storage for your specific workload requirements. The EBS CSI driver, in particular, provides a Kubernetes-native way to provision and manage block storage on AWS. This allows you to dynamically provision storage, recover quickly from failures, and ensure data consistency, all within the context of Amazon EKS. Whether you're dealing with self-managed databases like PostgreSQL, MySQL, or MongoDB, the EBS CSI driver simplifies the deployment and scaling of these storage solutions.

Building on the Amazon EKS cluster from **part 1** of our series, this tutorial dives into setting up the EBS CSI Driver Add-On. Included in the cluster configuration for the previous tutorial is the installation and association of the EBS CSI Driver Add-On and the OpenID Connect (OIDC) endpoint. For part one of this series, see [Building an Amazon EKS Cluster Preconfigured to Run High Traffic Microservices](/tutorials/navigating-amazon-eks/eks-cluster-high-traffic). Alternatively, to set up an existing cluster with the components required for this tutorial, use the instructions in [Create an IAM OpenID Connect (OIDC) endpoint](https://docs.aws.amazon.com/eks/latest/userguide/enable-iam-roles-for-service-accounts.html?sc_channel=el&sc_campaign=appswave&sc_content=eks-dynamic-db-storage-ebs-csi&sc_geo=mult&sc_country=mult&sc_outcome=acq) and [Create an IAM Role for Service Account (IRSA)](https://docs.aws.amazon.com/eks/latest/userguide/csi-iam-role.html?sc_channel=el&sc_campaign=appswave&sc_content=eks-dynamic-db-storage-ebs-csi&sc_geo=mult&sc_country=mult&sc_outcome=acq) in EKS official documentation.

| Attributes             |                                                                 |
|------------------------|-----------------------------------------------------------------|
| ✅ AWS experience      | 200 - Intermediate                                              |
| ⏱ Time to complete     | 30 minutes                                                      |
| 🧩 Prerequisites       | - [AWS Account](https://aws.amazon.com/resources/create-account/?sc_channel=el&sc_campaign=appswave&sc_content=eks-dynamic-db-storage-ebs-csi&sc_geo=mult&sc_country=mult&sc_outcome=acq)|
| 📢 Feedback            | <a href="https://www.pulse.aws/survey/Z8XBGQEL" target="_blank">Any feedback, issues, or just a</a> 👍 / 👎 ?    |
| ⏰ Last Updated        | 2023-08-30                                                      |

| ToC |
|-----|

In this tutorial, you'll use the [EBS CSI Driver Add-On](https://docs.aws.amazon.com/eks/latest/userguide/ebs-csi.html?sc_channel=el&sc_campaign=appswave&sc_content=eks-dynamic-db-storage-ebs-csi&sc_geo=mult&sc_country=mult&sc_outcome=acq) installed on your Amazon EKS cluster, enabling dynamic provisioning of EBS volumes for database storage, and deploy a sample workload for a MySQL database.

## Prerequisites

Before you begin this tutorial, you need to:

* Install the latest version of [kubectl](https://kubernetes.io/docs/tasks/tools/#kubectl). To check your version, run: `kubectl version --short`.
* Install the latest version of [eksctl](https://eksctl.io/introduction/#installation). To check your version, run: `eksctl info`.

## Overview

This tutorial is the second part of a series on managing high traffic microservices platforms using Amazon EKS, and it's dedicated to dynamic provisioning and storage solutions with the EBS CSI Driver. This tutorial shows not only how to provision storage within the cluster but also introduces the concept of dynamic provisioning. It covers the following components:

* **Authentication**: Utilize the pre-configured IAM Role for Service Account (IRSA) specifically designed for the [EBS CSI Driver](https://docs.aws.amazon.com/eks/latest/userguide/csi-iam-role.html?sc_channel=el&sc_campaign=appswave&sc_content=eks-dynamic-db-storage-ebs-csi&sc_geo=mult&sc_country=mult&sc_outcome=acq). This role, used within a designated AWS Availability Zone, works with the [OpenID Connect (OIDC) endpoint](https://docs.aws.amazon.com/eks/latest/userguide/enable-iam-roles-for-service-accounts.html?sc_channel=el&sc_campaign=appswave&sc_content=eks-dynamic-db-storage-ebs-csi&sc_geo=mult&sc_country=mult&sc_outcome=acq) to ensure secure communication between Kubernetes pods and AWS services.
* **EBS CSI Driver Add-On Set-Up**: [Amazon EKS add-ons](https://docs.aws.amazon.com/eks/latest/userguide/eks-add-ons.html?sc_channel=el&sc_campaign=appswave&sc_content=eks-dynamic-db-storage-ebs-csi&sc_geo=mult&sc_country=mult&sc_outcome=acq), such as the EBS CSI Driver Add-On, are curated software add-ons that include the latest security patches and bug fixes. The AWS Management Console notifies you of new versions for an Amazon EKS add-on. If you choose to [install the EBS CSI driver manually](https://github.com/kubernetes-sigs/aws-ebs-csi-driver/blob/master/docs/install.md?sc_channel=el&sc_campaign=appswave&sc_content=eks-dynamic-db-storage-ebs-csi&sc_geo=mult&sc_country=mult&sc_outcome=acq), you are responsible for keeping it up to date. Note that EBS volumes are bound to a specific AWS Availability Zone and can only be accessed by nodes within the same zone, making it suitable for workloads running nodes within the same availability zone.
* **Sample Application Deployment**: Build and provision storage for self-managed databases using a sample MySQL database. Utilize custom annotations and parameters for the EBS CSI Driver, specifically the 'ReadWriteOnce' access mode, to instruct the EBS CSI Driver to handle storage provisioning for databases. For more examples, see Examples in the EBS CSI Driver GitHub repository.

>Note that if you're still within your initial 12-month AWS Free Tier period, it's important to note that usage of EBS volumes beyond the free tier will result in additional AWS charges.

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

The `ebs-csi-controller-sa` service account is crucial for managing EBS volumes in Kubernetes. Make sure it's correctly set up in the `kube-system` namespace on your cluster.

```bash
kubectl get sa ebs-csi-controller-sa -n kube-system -o yaml
```

The expected output should look like this:

```yaml
apiVersion: v1
automountServiceAccountToken: true
kind: ServiceAccount
metadata:
  annotations:
    eks.amazonaws.com/role-arn: arn:aws:iam::111111111111:role/AmazonEKS_EBS_CSI_DriverRole
  creationTimestamp: "2023-08-17T00:20:02Z"
  labels:
    app.kubernetes.io/component: csi-driver
    app.kubernetes.io/managed-by: EKS
    app.kubernetes.io/name: aws-ebs-csi-driver
    app.kubernetes.io/version: 1.21.0
  name: ebs-csi-controller-sa
  namespace: kube-system
  resourceVersion: "14579"
  uid: faab5e29-76bc-4a04-8f73-7906a5621050
```

If you do **not** already have an IAM Role for Service Account (IRSA) set up for the EBS CSI Driver, or you receive an error for the above command, the following command will create the [IAM Role for Service Account (IRSA)](https://docs.aws.amazon.com/eks/latest/userguide/iam-roles-for-service-accounts.html?sc_channel=el&sc_campaign=appswave&sc_content=eks-dynamic-db-storage-ebs-csi&sc_geo=mult&sc_country=mult&sc_outcome=acq) along with the service account names `ebs-csi-controller-sa`. Note that you must have an [OpenID Connect (OIDC) endpoint](https://docs.aws.amazon.com/eks/latest/userguide/enable-iam-roles-for-service-accounts.html?sc_channel=el&sc_campaign=appswave&sc_content=eks-dynamic-db-storage-ebs-csi&sc_geo=mult&sc_country=mult&sc_outcome=acq) associated with your cluster before you run this command.

```bash
eksctl create iamserviceaccount \ 
    --name ebs-csi-controller-sa \ 
    --namespace kube-system \ 
    --region ${CLUSTER_REGION} \ 
    --cluster ${CLUSTER_NAME} \ 
    --role-name `AmazonEKS_EBS_CSI_DriverRole` \ 
    --attach-policy-arn arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy \ 
    --approve
```

## Step 3: Verify or Install the EBS CSI Driver Add-On

Verify that the Amazon EBS CSI Driver Add-On was successfully installed using the following command:

```bash
kubectl get deployment ebs-csi-controller -n kube-system
```

The expected output should look like this:

```bash
NAME                 READY   UP-TO-DATE   AVAILABLE   AGE
ebs-csi-controller   2/2     2            2           101m
```

Optionally, if you do **not** already have the EBS CSI Driver Add-On installed, or you receive an error, install the add-on by running the following command.

```bash
eksctl create addon \ 
--name aws-ebs-csi-driver \ 
--cluster ${CLUSTER_NAME} \ 
--region ${CLUSTER_REGION} \ 
--service-account-role-arn arn:aws:iam::${ACCOUNT_ID}:role/AmazonEKS_EBS_CSI_DriverRole \ 
--force
```

The expected output should look like this:

```bash
2023-08-19 10:13:14 [ℹ]  creating addon
```

## Step 4: Create a Kubernetes Secret

In this section, you will create a Kubernetes secret to securely store the MySQL credentials. By using a secret, you can keep sensitive information such as passwords and user names out of your application code and configuration files. This enhances the security of your application by allowing you to manage access to this information separately from the rest of your application. The secret will be referenced in the StatefulSet to provide the necessary environment variables to the MySQL container.

1. Create an `.env` file and paste the following contents.

```bash
MYSQL_ROOT_PASSWORD=my-secret-pw
MYSQL_USER=test-user
MYSQL_PASSWORD=my-secret-user-pw
MYSQL_DATABASE=sample
```

2. In the same directory as the `.env` file you just created, run the following command to create a Kubernetes secret with sensitive credentials.

```bash
kubectl create secret generic mysql-secrets --from-env-file=.env
```

## Step 5: Deploy a MySQL Database

This file contains the necessary Kubernetes manifests to set up the Amazon EBS CSI Driver on an Amazon EKS cluster. It defines a StorageClass named `ebs-sc` that sets up storage provisioning on AWS EBS, with a binding mode that waits for the first consumer; and a Pod named `mysql-ebs` that runs a Linux OS container. It also specifies the EBS CSI Driver as the provisioner (i.e., `ebs.csi.aws.com`). Together, these components provide a complete example of defining, claiming, and utilizing persistent storage within a Kubernetes cluster.

1. Create a Kubernetes manifest called mysql-ebs.yaml and paste the following contents into it.

```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: ebs-sc
provisioner: ebs.csi.aws.com
volumeBindingMode: WaitForFirstConsumer
---
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: mysql-ebs
  namespace: default
  labels:
    app.kubernetes.io/team: database
spec:
  replicas: 1
  selector:
    matchLabels:
      app.kubernetes.io/component: mysql-ebs
  serviceName: mysql
  template:
    metadata:
      labels:
        app.kubernetes.io/component: mysql-ebs
        app.kubernetes.io/team: database
    spec:
      containers:
        - name: mysql
          image: "public.ecr.aws/docker/library/mysql:5.7"
          args: 
            - "--ignore-db-dir=lost+found"
          imagePullPolicy: IfNotPresent
          envFrom:
            - secretRef:
                name: mysql-secrets
          ports:
            - name: mysql
              containerPort: 3306
              protocol: TCP
          volumeMounts:
            - name: data
              mountPath: /var/lib/mysql
  volumeClaimTemplates:
    - metadata:
        name: data
      spec:
        accessModes: ["ReadWriteOnce"]
        storageClassName: gp2
        resources:
          requests:
            storage: 30Gi
```

2. Deploy the Kubernetes resources in `mysql-ebs.yaml`:

```bash
kubectl apply -f mysql-ebs.yaml
```

When you deploy the workload, the EBS CSI driver uses the `StorageClass` to provision an EBS volume based on the specified configuration. The `volumeClaimTemplates` in the `StatefulSet` define the desired properties of the volume, such as `accessModes`, `storageClassName`, and resource requests. The EBS CSI driver then binds the volume to the `StatefulSet`'s Pod, allowing the MySQL container to utilize the persistent storage.

## Step 6: Verify the Volume is Mounted to the Pod

In this section, you'll validate that the volume has been dynamically provisioned and mounted using the following command:

```bash
kubectl exec --stdin mysql-ebs-0 -- bash -c "df -h"
```

You can see the recently attached EBS volume on the Linux OS. If everything is functioning correctly, a 30G volume should be visible at the `/var/lib/mysql` path. This verifies that the Pod has successfully created and attached the volume to the Linux OS. The expected output should look like this:

```bash
Filesystem Size Used Avail Use% Mounted on
overlay 80G 2.8G 78G 4% /
tmpfs 64M 0 64M 0% /dev
tmpfs 3.8G 0 3.8G 0% /sys/fs/cgroup
shm 64M 0 64M 0% /dev/shm
/dev/nvme0n1p1 80G 2.8G 78G 4% /etc/hosts
/dev/nvme1n1 30G 211M 30G 1% /var/lib/mysql
tmpfs 6.9G 12K 6.9G 1% /run/secrets/[kubernetes.io/serviceaccount](http://kubernetes.io/serviceaccount)
tmpfs 3.8G 0 3.8G 0% /proc/acpi
tmpfs 3.8G 0 3.8G 0% /sys/firmware
```

## Clean Up

After finishing with this tutorial, for better resource management, you may want to delete the specific resources you created. You can delete the service account and other resources with the following commands:

```bash
# Delete the MySQL deployment (Pod)
kubectl delete pods mysql-ebs-0

# Delete the PersistentVolumeClaim (PVC)
kubectl delete pvc data-mysql-ebs-0

# Delete the StorageClass
kubectl delete sc ebs-sc

# Delete the EBS CSI Driver Add-On
eksctl delete addon --name aws-ebs-csi-driver --cluster ${CLUSTER_NAME}
```

## Conclusion

Upon completion of this tutorial, you have successfully navigated the complex process of setting up data storage for stateful workloads using the EBS CSI Driver on your Amazon EKS cluster. This comprehensive journey included deploying a sample application and configuring essential components that are vital to the robustness of your system. With the completion of this tutorial, you've not only set up the EBS CSI Driver for dynamic provisioning of Amazon EBS volumes but also laid the groundwork for a scalable and resilient storage solution. To further enhance your new setup, explore enabling additional features such as volume scheduling, snap-shotting, and resizing capabilities. To learn more, see the [EBS CSI Driver documentation](https://github.com/kubernetes-sigs/aws-ebs-csi-driver) on GitHub.
