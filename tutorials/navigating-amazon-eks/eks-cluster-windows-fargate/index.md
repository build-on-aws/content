---
title: "Deploying Amazon EKS Windows managed node groups and Fargate nodes"
description: "How to ensure high availability of production-grade Windows EKS cluster with Fargate"
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
  - modern-apps
authorGithubAlias: berry2012
authorName: Olawale Olaleye
date: 2023-11-30
---

Windows Kubernetes containers allow organisations to easily migrate their existing Windows workloads to Amazon EKS.
To run Windows workloads on Amazon EKS, you’d need Windows nodes and a Linux node in the cluster. The Linux nodes are critical to the functioning of the cluster as they run core cluster components, and thus, for a production-grade cluster, such organization must ensure that the linux nodes are well architected for high availability.

While Amazon EKS clusters must contain one or more Linux or Fargate nodes to run core system Pods that only run on Linux, such as CoreDNS, organizations seeking to reduce operational overhead in managing a Windows EKS cluster can leverage the benefits of Managed Node groups and Fargate.

![EKS Cluster with Windows and Fargate Nodes](./images/fargate-windows.png)


| Attributes             |                                                                 |
|------------------------|-----------------------------------------------------------------|
| ✅ AWS experience      | 200 - Intermediate                                              |
| ⏱ Time to complete     | 30 minutes                                                      |
| 🧩 Prerequisites       | - [AWS Account](https://aws.amazon.com/resources/create-account/?sc_channel=el&sc_campaign=appswave&sc_content=eks-monitor-containerized-applications&sc_geo=mult&sc_country=mult&sc_outcome=acq)|
| 📢 Feedback            | <a href="https://www.pulse.aws/survey/Z8XBGQEL" target="_blank">Any feedback, issues, or just a</a> 👍 / 👎 ?    |
| ⏰ Last Updated        | 2023-11-30                                                      |

| ToC |
|-----|


## Prerequisites

Before you begin this tutorial, you need to:

* Install the latest version of [kubectl](https://kubernetes.io/docs/tasks/tools/#kubectl). To check your version, run: `kubectl version`.
* Install the latest version of [eksctl](https://eksctl.io/introduction/#installation). To check your version, run: `eksctl info`.

## Overview

Using the eksctl cluster template that follows, you'll build an Amazon Windows EKS cluster that will be a mixture of Windows nodes running on EC2 and Linux node running on Fargate. It configures the following components:

* **Managed Node groups**: With Amazon EKS managed node groups, you don't need to separately provision or register the Amazon EC2 instances that provide compute capacity to run your Kubernetes applications. As part of this tutorial, we will create a managed node group using `WINDOWS_FULL_2022_x86_64` AMI with the help of `eksctl`. This node group will provide the compute capacity to run Windows workloads in the cluster.
* **Fargate Profile**: [AWS Fargate](https://aws.amazon.com/fargate/) is a compute engine for EKS that removes the need to configure, manage, and scale EC2 instances. Fargate ensures Availability Zone spread while removing the complexity of managing EC2 infrastructure and works to ensure that pods in a Replica Service are balanced across Availability Zones. In this tutorial, we will use Fargate to provide the compute capacity we need to run the core clusters components in the kube-system namespace.

## Step 1: Configure the Cluster

In this section, you will configure the Amazon EKS cluster to meet the specific requirements of Windows EKS cluster. By creating this `cluster-config.yaml` file, you'll define the settings for Fargate profile and Windows Managed node group.

**To create the cluster config**

1. Copy and paste the content below in your terminal to create a `cluster-config.yaml` file. Replace the `region` with your preferred region. 

```yaml
cat << EOF > cluster-config.yaml
---
apiVersion: eksctl.io/v1alpha5
kind: ClusterConfig

metadata:
  name: eks-windows-mng-fg-mix
  region: us-west-2
  version: '1.28'
  
managedNodeGroups:
  - name: windows-managed-ng-2022
    amiFamily: WindowsServer2022FullContainer
    instanceType: m5.large
    volumeSize: 50
    minSize: 2
    maxSize: 4
    taints:
      - key: os
        value: "windows"
        effect: NoSchedule

fargateProfiles:
  - name: fp
    selectors:
      - namespace: default
      - namespace: kube-system

cloudWatch:
    clusterLogging:
        # enable specific types of cluster control plane logs
        enableTypes: ["*"]    
EOF
```

## Step 2: Create the Cluster

Now, we're ready to create our Amazon EKS cluster. This process takes several minutes to complete. If you'd like to monitor the status, see the [AWS CloudFormation](https://console.aws.amazon.com/cloudformation) console.

1. Create the EKS cluster using the `cluster-config.yaml`.

```bash
eksctl create cluster -f cluster-config.yaml
```

Upon completion, you should see the following response output:

```bash
2023-10-17 09:38:15 [ℹ]  nodegroup "windows-managed-ng-2022" has 2 node(s)
2023-10-17 09:38:15 [ℹ]  node "ip-192-168-28-156.us-west-2.compute.internal" is ready
2023-10-17 09:38:15 [ℹ]  node "ip-192-168-55-87.us-west-2.compute.internal" is ready
2023-10-17 09:38:17 [✔]  EKS cluster "eks-windows-mng-fg-mix" in "us-west-2" region is ready
```

When the previous command completes, verify that all of your nodes have reached the `Ready` state with the following command:

```bash
kubectl get nodes -o=custom-columns=NODE:.metadata.name,OS-Image:.status.nodeInfo.osImage,OS:.status.nodeInfo.operatingSystem
```

Sample output:

```bash
NODE                                                    OS-Image                         OS
fargate-ip-192-168-102-165.us-west-2.compute.internal   Amazon Linux 2                   linux
fargate-ip-192-168-103-37.us-west-2.compute.internal    Amazon Linux 2                   linux                
ip-192-168-28-156.us-west-2.compute.internal            Windows Server 2022 Datacenter   windows
ip-192-168-55-87.us-west-2.compute.internal             Windows Server 2022 Datacenter   windows
```

Let’s verify the core cluster component

```bash
kubectl get pods -A
```

Expected result:

```bash
NAMESPACE     NAME                       READY   STATUS    RESTARTS   AGE
kube-system   coredns-56666498f9-8mw4s   1/1     Running   0          12m
kube-system   coredns-56666498f9-zr79z   1/1     Running   0          12m
```


An appropriate Pod disruption budgets (PDBs) was automatically created for CoreDNS to control the number of Pods that can be down simultaneously.

```bash
kubectl get PodDisruptionBudget -A
NAMESPACE     NAME                 MIN AVAILABLE   MAX UNAVAILABLE   ALLOWED DISRUPTIONS   AGE
kube-system   coredns              N/A             1                 1                     12m
```

## Step 3: Deploy Sample Windows Application

1. Copy and paste the content below in your terminal to create a `windows-workload.yaml` file 

```yaml
cat << EOF > windows-workload.yaml
apiVersion: v1
kind: Namespace
metadata:
  labels:
    kubernetes.io/metadata.name: windows
  name: windows
---  
apiVersion: apps/v1
kind: Deployment
metadata:
  name: windows-server-iis-ltsc2022
  namespace: windows
spec:
  selector:
    matchLabels:
      app: windows-server-iis-ltsc2022
      tier: backend
      track: stable
  replicas: 2
  template:
    metadata:
      labels:
        app: windows-server-iis-ltsc2022
        tier: backend
        track: stable
    spec:
      containers:
      - name: windows-server-iis-ltsc2022
        image: mcr.microsoft.com/windows/servercore/iis:windowsservercore-ltsc2022
        ports:
        - name: http
          containerPort: 80
        imagePullPolicy: IfNotPresent
        command:
        - powershell.exe
        - -command
        - "Add-WindowsFeature Web-Server; Invoke-WebRequest -UseBasicParsing -Uri 'https://dotnetbinaries.blob.core.windows.net/servicemonitor/2.0.1.6/ServiceMonitor.exe' -OutFile 'C:\\ServiceMonitor.exe'; echo '<html><body><br/><br/><center><h1>Amazon EKS cluster with Windows managed nodegroup and Fargate linux nodes!</h1></center></body><html>' > C:\\inetpub\\wwwroot\\iisstart.htm; C:\\ServiceMonitor.exe 'w3svc'; "
      nodeSelector:
        kubernetes.io/os: windows
      tolerations:
          - key: "os"
            operator: "Equal"
            value: "windows"
            effect: "NoSchedule"
---
apiVersion: v1
kind: Service
metadata:
  name: windows-server-iis-ltsc2022-service
  namespace: windows
spec:
  ports:
  - port: 80
    protocol: TCP
    targetPort: 80
  selector:
    app: windows-server-iis-ltsc2022
    tier: backend
    track: stable
  sessionAffinity: None
  type: LoadBalancer
EOF
```

1. Deploy the sample application with the command below:

```bash
kubectl apply -f windows-workload.yaml
```

1. Verify the deployment:

```bash
kubectl get pods -o wide -n windows
```

Expected output:

```bash
NAME                                           READY   STATUS    RESTARTS   AGE     IP               NODE                                           NOMINATED NODE   READINESS GATES
windows-server-iis-ltsc2022-6c87658cb7-hg8ft   1/1     Running   0          5m54s   192.168.18.205   ip-192-168-28-156.us-west-2.compute.internal   <none>           <none>
windows-server-iis-ltsc2022-6c87658cb7-m9psj   1/1     Running   0          5m54s   192.168.33.108   ip-192-168-55-87.us-west-2.compute.internal    <none>           <none>
```


We had exposed the deployment externally using a LoadBalancer service type. Use the command below to get the service url:

```bash
kubectl get svc -n windows
```

Output:

```bash
NAME                                  TYPE           CLUSTER-IP       EXTERNAL-IP                                                              PORT(S)        AGE
windows-server-iis-ltsc2022-service   LoadBalancer   10.100.134.219   a4cebe53a9a35460886878031518849a-712875067.us-west-2.elb.amazonaws.com   80:30267/TCP   13m
```

Copy the EXTERNAL-IP URL into your browser of choice and you should be presented with a basic HTML site.

![A Sample Window Application](./images/web-app.png)

## Step 4: Additionally, create a workload on Fargate

Run the command below to create a sample nginx pod in the default namespace:

```bash
kubectl run test --image=nginx
```

It may take about a minute for the pod to be scheduled on a fargate node. Run the command below to confirm that the pod is in running state:

```bash
kubectl get pods -o wide
```

Expected result:

```bash
NAME   READY   STATUS    RESTARTS   AGE   IP               NODE                                                   NOMINATED NODE   READINESS GATES
test   1/1     Running   0          11m   192.168.103.37   fargate-ip-192-168-103-37.us-west-2.compute.internal   <none>           <none>
```



## Clean Up

To avoid incurring future charges, you should delete the resources created during this tutorial. 

Delete the sample deployment:

```bash
kubectl delete -f windows-workload.yaml
```

You can delete the EKS cluster with the following command:

```bash
eksctl delete cluster -f cluster-config.yaml
```

Upon completion, you should see the following response output:

```bash
2023-08-26 17:26:44 [✔]  all cluster resources were deleted
```


## Conclusion

In this tutorial, you've successfully set up an Amazon EKS Windows Cluster with a mix of Windows managed nodes and Fargate nodes for a reduced operational efforts in managing a Amazon EKS Windows cluster. This cluster gives you the infrastructure you need to start deploying your Windows application deployments.