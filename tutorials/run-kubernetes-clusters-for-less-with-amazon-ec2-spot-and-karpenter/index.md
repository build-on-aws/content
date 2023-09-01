---
title: "Run Kubernetes Clusters for Less with Amazon EC2 Spot and Karpenter"
description: "Learn how to run Kubernetes clusters for up to 90% off with Amazon Elastic Kubernetes Service (EKS), Amazon EC2 Spot Instances and Karpenter in less than 45 minutes."
tags:
  - kubernetes
  - karpenter
  - terraform
  - eks  
  - spot  
spaces:
  - cost-optimization
  - kubernetes
  - devops
waves:
  - cost
authorGithubAlias: chrismld
authorName: Christian Melendez
date: 2023-09-10
---
| ToC |
|-----|

One of the main cost factors for Kubernetes clusters relies on the compute layer for the data plane. Running Kubernetes clusters on Amazon EC2 Spot instances are a great way to reduce your compute costs significantly. When using Spot instances, you can get up to a 90% price discount compared to On-Demand Instances. 

Spot is a great match for workloads that are stateless, fault-tolerant, and flexible applications such as big data, containerized workloads, CI/CD, web servers, high-performance computing (HPC), and test & development workloads. Containers often match with these characteristics as they’re Spot-friendly. For non Spot-friendly workloads, like stateful applications within your cluster, you can continue using On-Demand Instances.

To optimize data place capacity further, you can adjust the number of nodes when pods are unscheduable due to available capacity, or remove nodes when they’re no longer needed. For automatic nodes adjustment, use either [Cluster Autoscaler (CA)](https://github.com/kubernetes/autoscaler/tree/master/cluster-autoscaler) or [Karpenter](https://karpenter.sh/). Both tools have support for Spot, and in this tutorial I’ll focus on Karpenter.

I’ll guide you on the steps you need to follow to configure an EKS cluster with Spot instances and Karpenter. Additionally, I’ll show you how to configure a workload to see Karpenter in action by provisioning the required capacity using Spot instances.

## Why go with Karpenter?

Karpenter is an open-source node provisioning project built for Kubernetes. As new pods continue coming to your cluster, either because you increased the number of replicas manually or through an [HPA](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/) policy or a [KEDA](https://aws.amazon.com/blogs/mt/proactive-autoscaling-kubernetes-workloads-keda-metrics-ingested-into-aws-amp/?sc_channel=el&sc_campaign=costwave&sc_content=run-kubernetes-clusters-for-less-with-amazon-ec2-spot-and-karpenter&sc_geo=mult&sc_country=mult&sc_outcome=acq) event, at some point your data plane nodes will be at full capacity, causing you to have pending (unschedulable) pods. The Karpenter controller reacts to this problem, and aggregates the capacity of these pending pods by evaluating scheduling constraints (resource requests, nodeselectors, affinities, tolerations, and topology spread constraints). Then, Karpenter provisions the right nodes that meet the requirements of these pending pods.

One of the main advantages of using Karpenter is the simplicity of configuring Spot best practices like instance type diversification (multiple families, sizes, generations, etc) in what Karpenter calls a provisioner. If you’re getting started with Spot in Amazon Elastic Kubernetes Service (EKS) or are struggling with the complexity of configuring multiple node groups, I recommend using Karpenter. However, if you’re already using CA and want to start spending less, you can find the detailed configuration to use Spot with CA [here](https://aws.amazon.com/tutorials/amazon-eks-with-spot-instances/?sc_channel=el&sc_campaign=costwave&sc_content=run-kubernetes-clusters-for-less-with-amazon-ec2-spot-and-karpenter&sc_geo=mult&sc_country=mult&sc_outcome=acq).

| Attributes             |                                                                 |
|------------------------|-----------------------------------------------------------------|
| ✅ AWS experience      | Advanced - 300                                           |
| ⏱ Time to complete     | 45 minutes                                                      |
| 💰 Cost to complete    | < $5.00 USD                                              |
| 🧩 Prerequisites    | - [AWS Account](https://aws.amazon.com/resources/create-account/?sc_channel=el&sc_campaign=costwave&sc_content=run-kubernetes-clusters-for-less-with-amazon-ec2-spot-and-karpenter&sc_geo=mult&sc_country=mult&sc_outcome=acq)<br>- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html?sc_channel=el&sc_campaign=costwave&sc_content=run-kubernetes-clusters-for-less-with-amazon-ec2-spot-and-karpenter&sc_geo=mult&sc_country=mult&sc_outcome=acq) <br> - [Kubernetes CLI (kubectl)](https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/)<br> - [Terraform CLI](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)<br> - [Helm](https://helm.sh/docs/intro/install/)<br> |
| 📢 Feedback            | <a href="https://pulse.buildon.aws/survey/DEM0H5VW" target="_blank">Any feedback, issues, or just a</a> 👍 / 👎 ?    |
| 💾 Code                | [Download the code](https://github.com/build-on-aws/run-kubernetes-clusters-for-less-with-amazon-ec2-spot-and-karpenter) |
| ⏰ Last Updated        | 2023-09-10                                                     |



## Prerequisites

* You need access to an AWS account with IAM permissions to create an EKS cluster, and an AWS Cloud9 environment if you're running the commands listed in this tutorial.
* Install and configure the [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html?sc_channel=el&sc_campaign=costwave&sc_content=run-kubernetes-clusters-for-less-with-amazon-ec2-spot-and-karpenter&sc_geo=mult&sc_country=mult&sc_outcome=acq)
* Install the [Kubernetes CLI (kubectl)](https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/)
* Install the [Terraform CLI](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)
* Install Helm ([the package manager for Kubernetes](https://helm.sh/docs/intro/install/))

## Step 1: Create a Cloud9 Environment

> 💡 Tip: You can skip this step if you already have a Cloud9 environment or if you’re planning to run all steps on your own computer. Just make sure you have the proper permissions listed in the pre-requisites section of this tutorial.

I’ve prepared an AWS CloudFormation template to create a Cloud9 environment. It has all the tools to follow this tutorial like kubectl and Terraform CLI. Now, let’s create the Cloud9 environment running the following command:

```bash
wget https://raw.githubusercontent.com/build-on-aws/run-kubernetes-clusters-for-less-with-amazon-ec2-spot-and-karpenter/main/cloud9-cnf.yaml
aws cloudformation deploy --stack-name EKSKarpenterCloud9 --template-file cloud9-cnf.yaml --capabilities "CAPABILITY_IAM"
```

Wait 5-10 minutes after CloudFormation finishes, then open the [Cloud9 console](https://console.aws.amazon.com/cloud9control/home?sc_channel=el&sc_campaign=costwave&sc_content=run-kubernetes-clusters-for-less-with-amazon-ec2-spot-and-karpenter&sc_geo=mult&sc_country=mult&sc_outcome=acq) and open the environment. From now on, you’ll be running all commands in this tutorial in the [Cloud9 terminal](https://docs.aws.amazon.com/cloud9/latest/user-guide/tour-ide.html#tour-ide-terminal?sc_channel=el&sc_campaign=costwave&sc_content=run-kubernetes-clusters-for-less-with-amazon-ec2-spot-and-karpenter&sc_geo=mult&sc_country=mult&sc_outcome=acq).

Cloud9 normally manages IAM credentials dynamically. This isn’t currently compatible with the EKS IAM authentication, so you need to disable it and rely on the IAM role instead. To do so, run the following commands in the Cloud9 terminal:

```bash
aws cloud9 update-environment --environment-id ${C9_PID} --managed-credentials-action DISABLE
rm -vf ${HOME}/.aws/credentials
```

To confirm that you have all the CLI tools needed for this tutorial, input these commands:

```bash
aws --version
kubectl version --client=true -o json
terraform version
helm version
```

## Step 2: Create an EKS Cluster with Karpenter using EKS Blueprints for Terraform

> 💡 Tip: The Terraform template used in this tutorial is using an On-Demand managed node group to host the Karpenter controller. However, if you have an existing cluster, you can use an existing node group with On-Demand instances to deploy the Karpenter controller. To do so, you need to follow the [Karpenter getting started guide](https://karpenter.sh/docs/getting-started/).

In this step you'll create an Amazon EKS cluster using the [EKS Blueprints for Terraform project](https://github.com/aws-ia/terraform-aws-eks-blueprints). The Terraform template you’ll use in this tutorial is going to create a VPC, an EKS control plane, and a Kubernetes service account along with the IAM role and associate them using IAM Roles for Service Accounts (IRSA) to let Karpenter launch instances. Additionally, the template configures the Karpenter node role to the `aws-auth` configmap to allow nodes to connect, and creates an On-Demand managed node group for the `kube-system` and `karpenter` namespaces.

To create the cluster, run the following commands:

```bash
wget https://raw.githubusercontent.com/build-on-aws/run-kubernetes-clusters-for-less-with-amazon-ec2-spot-and-karpenter/main/cluster/terraform/main.tf
helm registry logout public.ecr.aws
terraform init
terraform apply --auto-approve
```

Once complete (after waiting about 15 minutes), run the following command to update the `kube.config` file to interact with the cluster through `kubectl`:

```bash
aws eks --region eu-west-1 update-kubeconfig --name spot-and-karpenter
```

> 💡 Tip: If you’re using another region or changed the name of the cluster, you can get this command from the Terraform output. You can get the specific command for your setup by running this command: `terraform output -raw configure_kubectl`.

You need to make sure you can interact with the cluster and that the Karpenter pods are running:

```bash
$ kubectl get pods -n karpenter
NAME                       READY STATUS  RESTARTS AGE
karpenter-5f97c944df-bm85s 1/1   Running 0        15m
karpenter-5f97c944df-xr9jf 1/1   Running 0        15m
```

## Step 3: Set up a Karpenter Provisioner

The EKS cluster already has a static managed node group configured in advance for the `kube-system` and `karpenter` namespaces, and it’s going to be only one you’ll need. For the rest of pods, Karpenter will launch nodes through a `Provisioner` CRD. The Provisioner sets constraints on the nodes that can be created by Karpenter and the pods that can run on those nodes. A single Karpenter provisioner is capable of handling many different pod shapes, and for this tutorial you’ll only create the `default` provisioner.

> 💡 Tip: Karpenter simplifies the data plane capacity management using an approach called **group-less auto scaling**. This is because Karpenter is no longer using node groups, which matches with [Auto Scaling groups](https://docs.aws.amazon.com/autoscaling/ec2/userguide/AutoScalingGroup.html?sc_channel=el&sc_campaign=costwave&sc_content=run-kubernetes-clusters-for-less-with-amazon-ec2-spot-and-karpenter&sc_geo=mult&sc_country=mult&sc_outcome=acq), to launch nodes. Over time, clusters using the paradigm of running different types of applications (that require different capacity types), end up with a complex configuration and operational model where node groups must be defined and provided in advance.

You need to create two environment variables that we’ll use next, the values you need can be obtained from the Terraform output variables. Make sure you’re in the same folder where the Terraform `main.tf` file lives and run the following command:

```bash
export CLUSTER_NAME=$(terraform output -raw cluster_name)
export KARPENTER_NODE_IAM_ROLE_NAME=$(terraform output -raw node_instance_profile_name)
```

Let’s create a default provisioner by running the following commands:

```bash
cat <<EOF | kubectl apply -f -
apiVersion: karpenter.sh/v1alpha5
kind: Provisioner
metadata:
  name: default
spec:
  labels:
    intent: apps
  requirements:
    - key: "karpenter.sh/capacity-type"
      operator: In
      values: ["spot", "on-demand"]
    - key: "karpenter.k8s.aws/instance-category"
      operator: In
      values: ["c", "m", "r"]
    - key: "karpenter.k8s.aws/instance-cpu"
      operator: Gt
      values: ["2"]
    - key: "karpenter.k8s.aws/instance-memory"
      operator: Gt
      values: ["4095"] # 4 * 1024 - 1
  limits:
    resources:
      cpu: 1000
      memory: 2000Gi
  consolidation:
    enabled: true
  ttlSecondsUntilExpired: 604800 # 7 Days = 7 * 24 * 60 * 60 Seconds
  providerRef:
    name: default
---
apiVersion: karpenter.k8s.aws/v1alpha1
kind: AWSNodeTemplate
metadata:
  name: default
spec:
  subnetSelector:
    karpenter.sh/discovery: ${CLUSTER_NAME}
  securityGroupSelector:
    karpenter.sh/discovery: ${CLUSTER_NAME}
  instanceProfile: ${KARPENTER_NODE_IAM_ROLE_NAME}
  tags:
    karpenter.sh/discovery: ${CLUSTER_NAME}
    project: build-on-aws
    KarpenterProvisionerName: "default"
    NodeType: "default"
    intent: apps
EOF
```

Let me highlight a few important settings from the default `Provisioner` you just created:

* `requirements`: Here’s where you define the type of nodes Karpenter can launch. Be as flexible as possible and let Karpenter choose the right instance type based on the pod requirements. For this `Provisioner`, you’re saying Karpenter can launch either Spot or On-Demand Instances, families including `c`, `m` and `r`, with a minimum of 4 vCPUs and 8 GiB of memory. With this configuration, you’re choosing around 150 instance types from the 700+ available today in AWS. Read the next section to understand why this is important.
* `limits`: This is how you constrain the maximum amount of resources that the `Provisioner` will manage. Karpenter can launch instances with different specs, so instead of limiting a max number of instances (as you’d typically do in an Auto Scaling group), you define a maximum of vCPUs or memory to limit the number of nodes to launch. Karpenter provides a [metric to monitor the percentage usage](https://karpenter.sh/docs/concepts/metrics/#karpenter_provisioner_usage_pct) of this `Provisioner` based on the limits you configure.
* `consolidation`: Karpenter does a great job at launching only the nodes you need, but as pods can come an go, at some point in time the cluster capacity can end up in a fragmented state. To avoid fragmentation and optimize the compute nodes in your cluster, you can enable [consolidation](https://karpenter.sh/docs/concepts/deprovisioning/#consolidation). When enabled, Karpenter works to actively reduce cluster cost by identifying when nodes can be removed, as their workloads will run on other nodes in the cluster, and when nodes can be replaced with cheaper variants due to a change in the workloads.
* `ttlSecondsUntilExpired`: Here’s where you define when a node will be deleted. This is useful to force new nodes with up-to-date AMI’s. In this example we have set the value to 7 days.
* `providerRef`: This is where you reference the template to launch a node. An `AWSNodeTemplate` is where you define which subnets, security groups, and IAM role the nodes will use. You can set node tags or even configure a [user-data](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/user-data.html?sc_channel=el&sc_campaign=costwave&sc_content=run-kubernetes-clusters-for-less-with-amazon-ec2-spot-and-karpenter&sc_geo=mult&sc_country=mult&sc_outcome=acq). To learn more about which other configurations are available, go [here](https://karpenter.sh/docs/concepts/node-templates/).

You can also learn more about which other configuration properties are available for a `Provisioner` [here](https://karpenter.sh/docs/concepts/provisioners/).

### Why Is It a Good Practice To Configure a Diverse Set of Instance Types?

As you noticed, with the above `Provisioner` we’re basically letting Karpenter choose from a diverse set of instance types to launch the best instance type possible. If it’s an On-Demand Instance, Karpenter uses the `lowest-price` allocation strategy to launch the cheapest instance type that has available capacity. When you use multiple instance types, you can avoid the [InsufficientInstanceCapacity error](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/troubleshooting-launch.html#troubleshooting-launch-capacity?sc_channel=el&sc_campaign=costwave&sc_content=run-kubernetes-clusters-for-less-with-amazon-ec2-spot-and-karpenter&sc_geo=mult&sc_country=mult&sc_outcome=acq).

If it’s a Spot Instance, Karpenter uses the `price-capacity-optimized` (PCO) allocation strategy. PCO looks at both price and capacity availability to launch from the [Spot Instance pools](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-spot-instances.html#spot-features?sc_channel=el&sc_campaign=costwave&sc_content=run-kubernetes-clusters-for-less-with-amazon-ec2-spot-and-karpenter&sc_geo=mult&sc_country=mult&sc_outcome=acq) that are the least likely to be interrupted and have the lowest possible price. For Spot Instances, applying diversification is key. Spot Instances are spare capacity that can be reclaimed by EC2 when it is required. Karpenter allows you to diversify extensively to replace reclaimed Spot Instances automatically with instances from other pools where capacity is available.

## Step 4: Deploy a Spot-friendly Workload

You’re now going to see Karpenter in action. Your default `Provisioner` can launch both On-Demand and Spot Instances, but Karpenter considers the constraints you configure within a pod to launch the right node(s). Let’s create a Deployment with a [nodeSelector](https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#nodeselector) to run the pods on Spot instances. To do so, run the following command:

```bash
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: stateless
spec:
  replicas: 20
  selector:
    matchLabels:
      app: stateless
  template:
    metadata:
      labels:
        app: stateless
    spec:
      nodeSelector:
        intent: apps
        karpenter.sh/capacity-type: spot
      containers:
      - name: app
        image: public.ecr.aws/eks-distro/kubernetes/pause:3.7
        resources:
          requests:
            cpu: 512m
            memory: 512Mi
EOF
```

As there are no nodes that match the pod’s requirements, all pods will be `Pending`, making Karpenter to react and launch the nodes, similar to this output:

```bash
$ kubectl get pods
NAME                        READY STATUS  RESTARTS AGE
stateless-5c77994ccb-4mtsp   0/1  Pending 0        3s
stateless-5c77994ccb-4mtsp   0/1  Pending 0        3s
stateless-5c77994ccb-4mtsp   0/1  Pending 0        3s
stateless-5c77994ccb-4mtsp   0/1  Pending 0        3s
stateless-5c77994ccb-4mtsp   0/1  Pending 0        3s
stateless-5c77994ccb-4mtsp   0/1  Pending 0        3s
stateless-5c77994ccb-4mtsp   0/1  Pending 0        3s
stateless-5c77994ccb-4mtsp   0/1  Pending 0        3s
stateless-5c77994ccb-4mtsp   0/1  Pending 0        3s
stateless-5c77994ccb-4mtsp   0/1  Pending 0        3s
```

Review Karpenter logs to see what’s happening while you wait for the new node to be ready. Create the following alias:

```bash
alias kl='kubectl logs deployment/karpenter --since 5m -n karpenter -f';
```

Karpenter logs should look similar to this (I’m including only the lines I want to highlight):

```bash
$ kl
2023-08-25T10:10:20.704Z    INFO    controller.provisioner    found provisionable pod(s)    {"commit": "34d50bf-dirty", "pods": 10}
2023-08-25T10:10:20.704Z    INFO    controller.provisioner    computed new machine(s) to fit pod(s)    {"commit": "34d50bf-dirty", "machines": 1, "pods": 10}
2023-08-25T10:10:20.725Z    INFO    controller.provisioner    created machine    {"commit": "34d50bf-dirty", "provisioner": "default", "requests": {"cpu":"5245m","memory":"5Gi","pods":"12"}, "instance-types": "c3.2xlarge, c3.4xlarge, c4.2xlarge, c4.4xlarge, c4.8xlarge and 95 other(s)"}
2023-08-25T10:10:23.976Z    INFO    controller.machine.lifecycle    launched machine    {"commit": "34d50bf-dirty", "machine": "default-zx45m", "provisioner": "default", "provider-id": "aws:///eu-west-1b/i-0f89c0a89d0a78ae7", "instance-type": "m5.2xlarge", "zone": "eu-west-1b", "capacity-type": "spot", "allocatable": {"cpu":"7910m","ephemeral-storage":"17Gi","memory":"29317Mi","pods":"58"}}
```

By reading the logs, you can see that Karpenter:

* Noticed there were 10 pending pods, and decided that can fit all pods in only one node.
* Is considering the kubelet and kube-proxy `Daemonsets` (2 additional pods), and it’s aggregating all resources need for 12 pods. Moreover, Karpenter noticed that 100 instance types match these requirements.
* Launched an `m5.2xlarge` Spot Instance in `eu-west-1b` as this was the pool with more spare capacity with lowest price.

## Step 5: Spread Pods Within Multiple AZs

Karpenter launched only one node for all pending pods. However, putting all eggs in the same basket is not recommended as if you lose that node, you’ll need to wait for Karpenter to provision a replacement node (which can be fast, but still, you’ll have an impact). To avoid this, and make the workload more highly available, let’s spread the pods within multiple AZs. Let’s configure a [Topology Spread Constraint](https://karpenter.sh/docs/concepts/scheduling/#topology-spread) within the `Deployment`. To do so, add the following snippet within the `Deployment` spec block (after the `nodeSelector` block) you deployed in the previous step:

```bash
      topologySpreadConstraints:
        - labelSelector:
            matchLabels:
              app: stateless
          maxSkew: 1
          minDomains: 3
          topologyKey: topology.kubernetes.io/zone
          whenUnsatisfiable: DoNotSchedule
```

> 💡 Tip: You can download the full version of the deployment manifest including the Topology Spread Constraints [here](https://raw.githubusercontent.com/build-on-aws/run-kubernetes-clusters-for-less-with-amazon-ec2-spot-and-karpenter/main/karpenter/workload.yaml).

Remove the stateless `Deployment`:

```bash
kubectl delete deployment stateless
```

Create the stateless `Deployment` again. If you downloaded the manifest from GitHub, you can simply run:

```bash
kubectl apply -f workload.yaml
```

Then, you can review the Karpenter logs and notice how different the actions are.  Wait one minute and you should see the pods running within three nodes in different AZs:

```bash
kubectl get nodes -L karpenter.sh/capacity-type,beta.kubernetes.io/instance-type,topology.kubernetes.io/zone -l karpenter.sh/capacity-type=spot
```

You should see an output similar to this:

```bash
NAME                                         STATUS   ROLES    AGE    VERSION               CAPACITY-TYPE   INSTANCE-TYPE   ZONE
ip-10-0-123-233.eu-west-1.compute.internal   Ready    <none>   2m4s   v1.27.3-eks-a5565ad   spot            m5.xlarge       eu-west-1c
ip-10-0-34-248.eu-west-1.compute.internal    Ready    <none>   2m3s   v1.27.3-eks-a5565ad   spot            m5.xlarge       eu-west-1a
ip-10-0-76-166.eu-west-1.compute.internal    Ready    <none>   2m4s   v1.27.3-eks-a5565ad   spot            m5.xlarge       eu-west-1b
```

## Step 6: (Optional) Simulate Spot Interruption

You can simulate a Spot interruption to test the resiliency of your applications. As I said before, Spot is spare capacity for steep discounts in exchange for returning them when EC2 needs the capacity back. Spot interruptions have a 2 minute notice before EC2 reclaims the instance. Karpenter can watch these interruptions (the cluster you created with Terraform is already configured this way). When this happens, the `Provisioner` starts a new node as soon as it sees the Spot interruption warning. Karpenter’s average node startup time means that, generally, there is sufficient time for the new node to become ready and to move the pods to the new node before the node is reclaimed.

You can simulate a [Spot interruption using Fault Injection Simulator (FIS)](https://docs.aws.amazon.com/fis/latest/userguide/fis-tutorial-spot-interruptions.html?sc_channel=el&sc_campaign=costwave&sc_content=run-kubernetes-clusters-for-less-with-amazon-ec2-spot-and-karpenter&sc_geo=mult&sc_country=mult&sc_outcome=acq). To do this, you can either do it through the [console](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/initiate-a-spot-instance-interruption.html?sc_channel=el&sc_campaign=costwave&sc_content=run-kubernetes-clusters-for-less-with-amazon-ec2-spot-and-karpenter&sc_geo=mult&sc_country=mult&sc_outcome=acq), or using the [Amazon EC2 Spot Interrupter](https://github.com/aws/amazon-ec2-spot-interrupter) CLI. In this tutorial, I’ll use `ec2-spot-interrupter`, so make sure you install it before you continue.

Before you start, you’ll need two extra terminals: 1) to monitor the nodes `STATUS`, and 2) for the Karpenter logs. In one terminal watch the nodes using this command:

```bash
kubectl get nodes -L karpenter.sh/capacity-type,beta.kubernetes.io/instance-type,topology.kubernetes.io/zone -l karpenter.sh/capacity-type=spot --watch
```

In another terminal, run the following commands:

```bash
alias kl='kubectl logs deployment/karpenter —since 5m -n karpenter -f';
kl
```

In the third terminal, run the following command, and choose one of the Spot Instances listed:

```bash
$ ec2-spot-interrupter —interactive
Which Spot Instances would you like to interrupt?

> [x] i-06391b132dcc25a0b (karpenter.sh/provisioner-name/default)
  [ ] i-01876750d829475b6 (karpenter.sh/provisioner-name/default)
  [ ] i-062023013287e8c87 (karpenter.sh/provisioner-name/default)

Press q to quit.
```

Press `Enter` two times, and the Spot interruption warning will be sent. Review what happens by looking at the Karpenter logs, as soon as the Spot interruption warning lands, Karpenter immediately cordons and drains the node, but also launches a replacement instance:

```bash
2023-08-25T11:27:12.266Z    DEBUG    controller.interruption    removing offering from offerings    {"commit": "34d50bf-dirty", "queue": "karpenter-spot-and-karpenter", "messageKind": "SpotInterruptionKind", "machine": "default-dc58z", "action": "CordonAndDrain", "node": "ip-10-0-99-126.eu-west-1.compute.internal", "reason": "SpotInterruptionKind", "instance-type": "m5.2xlarge", "zone": "eu-west-1c", "capacity-type": "spot", "ttl": "3m0s"}
2023-08-25T11:27:12.281Z    INFO    controller.interruption    initiating delete for machine from interruption message    {"commit": "34d50bf-dirty", "queue": "karpenter-spot-and-karpenter", "messageKind": "SpotInterruptionKind", "machine": "default-dc58z", "action": "CordonAndDrain", "node": "ip-10-0-99-126.eu-west-1.compute.internal"}
2023-08-25T11:27:12.317Z    INFO    controller.termination    cordoned node    {"commit": "34d50bf-dirty", "node": "ip-10-0-99-126.eu-west-1.compute.internal"}
2023-08-25T11:27:13.544Z    DEBUG    controller.provisioner    10 out of 684 instance types were excluded because they would breach provisioner limits    {"commit": "34d50bf-dirty", "provisioner": "default"}
2023-08-25T11:27:13.568Z    INFO    controller.provisioner    found provisionable pod(s)    {"commit": "34d50bf-dirty", "pods": 3}
2023-08-25T11:27:13.568Z    INFO    controller.provisioner    computed new machine(s) to fit pod(s)    {"commit": "34d50bf-dirty", "machines": 1, "pods": 3}
2023-08-25T11:27:13.584Z    INFO    controller.provisioner    created machine    {"commit": "34d50bf-dirty", "provisioner": "default", "requests": {"cpu":"1661m","memory":"1536Mi","pods":"5"}, "instance-types": "c3.2xlarge, c3.4xlarge, c4.2xlarge, c4.4xlarge, c5.2xlarge and 95 other(s)"}
2023-08-25T11:27:13.786Z    INFO    controller.termination    deleted node    {"commit": "34d50bf-dirty", "node": "ip-10-0-99-126.eu-west-1.compute.internal"}
2023-08-25T11:27:14.062Z    INFO    controller.machine.termination    deleted machine    {"commit": "34d50bf-dirty", "machine": "default-dc58z", "node": "ip-10-0-99-126.eu-west-1.compute.internal", "provisioner": "default", "provider-id": "aws:///eu-west-1c/i-06391b132dcc25a0b"}
2023-08-25T11:27:16.675Z    INFO    controller.machine.lifecycle    launched machine    {"commit": "34d50bf-dirty", "machine": "default-kj2x5", "provisioner": "default", "provider-id": "aws:///eu-west-1c/i-0769cccd857ada568", "instance-type": "m6i.2xlarge", "zone": "eu-west-1c", "capacity-type": "spot", "allocatable": {"cpu":"7910m","ephemeral-storage":"17Gi","memory":"29317Mi","pods":"58"}}
```

> 💡 Tip: You’ll end up seeing only two Spot nodes running, and if you review the Karpenter logs, you’ll see that it was because of the consolidation process.

## Step 7: (Optional) Deploy a Stateful Workload

You can still launch On-Demand Instances in a cluster that’s also running Spot Instances for those non Spot-friendly workloads. Continue using the default Karpenter `Provisioner` you created before. But make sure you’re configuring the workload properly. One way of doing it is to use a similar approach for the Spot-friendly workload by using a `nodeSelector`.

Deploy the following application to simulate a stateful workload:

```bash
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: stateful
spec:
  replicas: 7
  selector:
    matchLabels:
      app: stateful
  template:
    metadata:
      labels:
        app: stateful
    spec:
      nodeSelector:
        intent: apps
        karpenter.sh/capacity-type: on-demand
      containers:
      - name: app
        image: public.ecr.aws/eks-distro/kubernetes/pause:3.7
        resources:
          requests:
            cpu: 512m
            memory: 512Mi
EOF
```

Same as before, wait one minute, and you should see all pods running and one On-Demand node running:

```bash
$ kubectl get nodes -L karpenter.sh/capacity-type,[beta.kubernetes.io/instance-type,topology.kubernetes.io/zone](http://beta.kubernetes.io/instance-type,topology.kubernetes.io/zone) -l karpenter.sh/capacity-type=on-demand
NAME STATUS ROLES AGE VERSION CAPACITY-TYPE INSTANCE-TYPE ZONE
ip-10-0-102-206.eu-west-1.compute.internal Ready <none> 46s v1.27.3-eks-a5565ad on-demand c6a.2xlarge eu-west-1c
```

You can review the Karpenter logs as well, you’ll see a similar behavior as before with the Spot-friendly workload.

## Step 8: Clean Up

When you’re done with this tutorial, remove the two deployments you created:

```bash
kubectl delete deployment stateless
kubectl delete deployment stateful
```

Wait 30 seconds until the nodes that Karpenter launched are gone (due to consolidation), then remove all resources:

```bash
terraform destroy --auto-approve
```

## Conclusion

Using Spot Instances for your Kubernetes data plane nodes helps you reduce computing costs. As long as your workloads are fault-tolerant, stateless, and can use a variety of instance types, you can use Spot. Karpenter allows you to simplify the process of configuring your EKS cluster with a high-instance type diversification, and provisions only the capacity you need.

You can learn more about using Karpenter on EKS with [this hands-on workshop](https://ec2spotworkshops.com/karpenter.html), or dive deeper into the Karpenter cocepts [here](https://karpenter.sh/docs/concepts/).
