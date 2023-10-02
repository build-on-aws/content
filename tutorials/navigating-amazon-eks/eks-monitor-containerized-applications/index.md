---
title: "Easily Monitor Containerized Applications with Amazon CloudWatch Container Insights"
description: "How to collect, aggregate, and analyze metrics from your containerized applications using Amazon CloudWatch Container Insights."
tags:
    - eks-container-insight
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
additionalAuthors: 
  - authorGithubAlias: ahmadt312
    authorName: Ahmad Tariq
date: 2023-10-02
---

Monitoring containerized applications requires precision and efficiency. One way to handle the complexities of collecting and summarizing metrics from your applications is to use Amazon CloudWatch Container Insights. As the performance metrics of your containers change, Container Insights offers real-time data, enabling you to maintain consistent application performance through informed decisions.

Building on the Amazon EKS cluster from part 1 of our series, this tutorial dives into setting up Amazon CloudWatch Container Insights. Included in the cluster configuration for the previous tutorial is the [Amazon CloudWatch](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/WhatIsCloudWatch.html?sc_channel=el&sc_campaign=appswave&sc_content=eks-monitor-containerized-applications&sc_geo=mult&sc_country=mult&sc_outcome=acq) IAM policy attached to the IAM Role for Service Account (IRSA) and the [OpenID Connect (OIDC) endpoint](https://docs.aws.amazon.com/eks/latest/userguide/enable-iam-roles-for-service-accounts.html?sc_channel=el&sc_campaign=appswave&sc_content=eks-monitor-containerized-applications&sc_geo=mult&sc_country=mult&sc_outcome=acq). For part one of this series, see [Building an Amazon EKS Cluster Preconfigured to Run High Traffic Microservices](https://community.aws/tutorials/eks-cluster-high-traffic). Alternatively, to set up an existing cluster with the components required for this tutorial, use the instructions in [the _verify prerequisites_ section](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/Container-Insights-prerequisites.html?sc_channel=el&sc_campaign=appswave&sc_content=eks-monitor-containerized-applications&sc_geo=mult&sc_country=mult&sc_outcome=acq) of EKS official documentation.

In this tutorial, you will configure your Amazon EKS cluster, deploy containerized applications, and monitor the application's performance using Container Insights. Container Insights can handle lightweight applications like microservices as well as more complex systems like databases or user authentication systems, providing seamless monitoring.

> Note: If you're within your inaugural 12-month phase, be advised that Amazon CloudWatch Container Insights falls outside the AWS free tier, hence usage could result in additional charges.

| Attributes             |                                                                 |
|------------------------|-----------------------------------------------------------------|
| ✅ AWS experience      | 200 - Intermediate                                              |
| ⏱ Time to complete     | 30 minutes                                                      |
| 🧩 Prerequisites       | - [AWS Account](https://aws.amazon.com/resources/create-account/?sc_channel=el&sc_campaign=appswave&sc_content=eks-monitor-containerized-applications&sc_geo=mult&sc_country=mult&sc_outcome=acq)|
| 📢 Feedback            | <a href="https://www.pulse.aws/survey/Z8XBGQEL" target="_blank">Any feedback, issues, or just a</a> 👍 / 👎 ?    |
| ⏰ Last Updated        | 2023-10-02                                                      |

| ToC |
|-----|

## Prerequisites

Before you begin this tutorial, you need to:

* Install the latest version of [kubectl](https://kubernetes.io/docs/tasks/tools/#kubectl). To check your version, run: `kubectl version --short`.
* Install the latest version of [eksctl](https://eksctl.io/introduction/#installation). To check your version, run: `eksctl info`.

## Step 1: Set up Container Insights on Amazon EKS

For CloudWatch Container Insights to collect, aggregate, and summarize metrics and logs from your containerized applications and microservices on Amazon Elastic Kubernetes Service (Amazon EKS), some setup steps need to be performed. Container Insights supports both Amazon EKS EC2 and [Fargate](https://docs.aws.amazon.com/eks/latest/userguide/fargate-logging.html?sc_channel=el&sc_campaign=appswave&sc_content=eks-monitor-containerized-applications&sc_geo=mult&sc_country=mult&sc_outcome=acq). There are a few ways you can set up Container Insights on an Amazon EKS cluster: using the CloudWatch agent, a “quick start” setup, or through a manual setup approach. Below, you will find the steps required for the “quick start” method.

### Quick Start Setup

First, set and configure the following environment variables, ensuring consistency for `ClusterName` and `RegionName`. In the following example, `my-cluster` is the name of your Amazon EKS cluster, and `us-east-2` is the region where the logs are published. You should replace these values with your own values. It's advisable to specify the same region where your cluster is located to minimize AWS outbound data transfer costs. Additionally, `FluentBitHttpPort` is given a value of '2020' because this port is commonly used for monitoring purposes and allows for integration with existing tools, and `FluentBitReadFromHead` is given a value of 'Off' to ensure that the logs are read from the end, not the beginning, which can be essential for managing large log files and optimizing performance.

```bash
export ClusterName=managednodes-quickstart
export LogRegion=us-east-2
export FluentBitHttpPort='2020'
export FluentBitReadFromHead='Off'
```

Set the following environment variable to ensure that logs are read either from the head or the tail, but not both. 

```bash
[[ ${FluentBitReadFromHead} = 'On' ]] && FluentBitReadFromTail='Off'|| FluentBitReadFromTail='On'
```

Next, set the following environment variable to control whether the HTTP server for Fluent Bit is enabled or disabled. In this command, the `FluentBitHttpServer` for monitoring plugin metrics is on by default.

```bash
[[ -z ${FluentBitHttpPort} ]] && FluentBitHttpServer='Off' || FluentBitHttpServer='On'
```

Download and review the content of the Fluent Bit Daemonset by running the following command:

```bash
curl https://raw.githubusercontent.com/aws-samples/amazon-cloudwatch-container-insights/latest/k8s-deployment-manifest-templates/deployment-mode/daemonset/container-insights-monitoring/quickstart/cwagent-fluent-bit-quickstart.yaml | sed 's/{{cluster_name}}/'${ClusterName}'/;s/{{region_name}}/'${LogRegion}'/;s/{{http_server_toggle}}/"'${FluentBitHttpServer}'"/;s/{{http_server_port}}/"'${FluentBitHttpPort}'"/;s/{{read_from_head}}/"'${FluentBitReadFromHead}'"/;s/{{read_from_tail}}/"'${FluentBitReadFromTail}'"/' > cwagent-fluent-bit-quickstart.yaml
```

Use an IAM role for service accounts for the cluster, and attach the policy to this role. The command below creates an IAM Role and Service Account pair for fluent-bit:

```bash
eksctl create iamserviceaccount --name fluent-bit \
    --namespace amazon-cloudwatch \
    --cluster ${ClusterName} --role-name fluent-bit \
    --attach-policy-arn arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy \
    --approve --region ${LogRegion} \
    --override-existing-serviceaccounts
```

Deploy the Fluent Bit Daemonset to the cluster by running the following command:

```bash
kubectl apply -f cwagent-fluent-bit-quickstart.yaml
```

Validate that the agent is deployed by running the following command:

```bash
kubectl get pods -n amazon-cloudwatch
```

## Step 2: Deploy a Container Application in the Cluster

In this step, you will deploy a comprehensive containerized application environment within your Kubernetes cluster using a manifest file named `workload.yaml`.

1. Create a Kubernetes manifest called workload.yaml and paste the following contents into it.

```yaml
apiVersion: v1
kind: Namespace
metadata:
  labels:
    kubernetes.io/metadata.name: quickstart   
  name: quickstart

---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: "quickstart-nginx-deployment"
  namespace: "quickstart"
spec:
  selector:
    matchLabels:
      app: "quickstart-nginx"
  replicas: 3
  template:
    metadata:
      labels:
        app: "quickstart-nginx"
        role: "backend"
    spec:
      dnsPolicy: Default 
      enableServiceLinks: false    
      automountServiceAccountToken: false
      securityContext:
        seccompProfile:
          type: RuntimeDefault         
      containers:
      - image: public.ecr.aws/nginx/nginx:latest
        imagePullPolicy: Always
        name: "quickstart-nginx"
        resources:
          requests:
           memory: "64Mi"
           cpu: "250m"
          limits:
            memory: "128Mi"
            cpu: "500m"
        securityContext:
          allowPrivilegeEscalation: false
          readOnlyRootFilesystem: true
        ports:
        - containerPort: 80
        command: ["/bin/sh"]
        args: ["-c", "echo PodName: $MY_POD_NAME  NodeName: $MY_NODE_NAME  podIP: $MY_POD_IP> /usr/share/nginx/html/index.html && exec nginx -g 'daemon off;'"]       
        env:
        - name: MY_NODE_NAME
          valueFrom:
           fieldRef:
            fieldPath: spec.nodeName
        - name: MY_POD_IP
          valueFrom:
            fieldRef:
              fieldPath: status.podIP
        - name: MY_POD_NAME
          valueFrom:
            fieldRef:
              fieldPath: metadata.name
        volumeMounts:
        - name: cache
          mountPath: /var/cache/nginx
        - name: usr
          mountPath: /var/run    
        - name: tmp
          mountPath: /usr/share/nginx/html           
      volumes:
        - name: cache
          emptyDir: {}
        - name: tmp
          emptyDir: {}
        - name: usr
          emptyDir: {}

---
apiVersion: v1
kind: Service
metadata:
  name: quickstart-nginx-service
  namespace: quickstart
spec:
  type: NodePort
  selector:
    app: "quickstart-nginx"
    role: "backend"
  ports:
    - port: 80
      targetPort: 80

--- 
apiVersion: v1
kind: Pod
metadata:
  name: load
  namespace: quickstart
spec:
  securityContext:
    seccompProfile:
      type: RuntimeDefault
    runAsNonRoot: true 
    runAsUser: 1000   
    runAsGroup: 1000          
  automountServiceAccountToken: false
  containers:
  - name: load
    image: public.ecr.aws/docker/library/busybox:1.36.1
    imagePullPolicy: Always
    command: ["/bin/sh"]
    args: ["-c", "while sleep 0.5; do wget -q -O- http://quickstart-nginx-service; done"]
    resources:
      requests:
        memory: "64Mi"
        cpu: "250m"
      limits:
        memory: "128Mi"
        cpu: "500m"
    securityContext:
      allowPrivilegeEscalation: false     
      readOnlyRootFilesystem: true
```

2. Deploy the Kubernetes resources in `workload.yaml`.

```bash
kubectl apply -f workload.yaml
```

The expected output should look like this:

```bash
namespace/quickstart created
deployment.apps/quickstart-nginx-deployment created
service/quickstart-nginx-service created
pod/load created
```

3. Use the following command to check the status of the deployed Nginx containers and ensure that they are running: 

```bash
kubectl get all -n quickstart
```

The expected output should look like this:

```bash
NAME                                               READY   STATUS    RESTARTS   AGE
pod/load                                           1/1     Running   0          15s
pod/quickstart-nginx-deployment-7cd757dc7b-9fss6   1/1     Running   0          16s
pod/quickstart-nginx-deployment-7cd757dc7b-fv592   1/1     Running   0          16s
pod/quickstart-nginx-deployment-7cd757dc7b-wpw4x   1/1     Running   0          16s

NAME                               TYPE       CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE
service/quickstart-nginx-service   NodePort   10.100.233.21   <none>        80:31243/TCP   16s

NAME                                          READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/quickstart-nginx-deployment   3/3     3            3           17s

NAME                                                     DESIRED   CURRENT   READY   AGE
replicaset.apps/quickstart-nginx-deployment-7cd757dc7b   3         3         3       17s
```

4. Use the following command to view the real-time logs of the "load" Pod, which is continuously making requests to the Nginx service. Use Ctrl+C to stop.

```bash
kubectl logs -f load -n quickstart
```

The expected output should look like this:

```bash
PodName: quickstart-nginx-deployment-7cd757dc7b-wpw4x NodeName: ip-192-168-141-57.us-east-2.compute.internal podIP: 192.168.136.230
PodName: quickstart-nginx-deployment-7cd757dc7b-fv592 NodeName: ip-192-168-177-109.us-east-2.compute.internal podIP: 192.168.164.31
PodName: quickstart-nginx-deployment-7cd757dc7b-fv592 NodeName: ip-192-168-177-109.us-east-2.compute.internal podIP: 192.168.164.31
PodName: quickstart-nginx-deployment-7cd757dc7b-9fss6 NodeName: ip-192-168-119-7.us-east-2.compute.internal podIP: 192.168.112.25
```

## Step 3: Use [CloudWatch Logs Insights](https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/AnalyzingLogData.html?sc_channel=el&sc_campaign=appswave&sc_content=eks-monitor-containerized-applications&sc_geo=mult&sc_country=mult&sc_outcome=acq) Query to search and analyze container logs

You can use [CloudWatch Logs Insights](https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/AnalyzingLogData.html?sc_channel=el&sc_campaign=appswave&sc_content=eks-monitor-containerized-applications&sc_geo=mult&sc_country=mult&sc_outcome=acq) Query to interactively search and analyze the container logs of the application in Amazon CloudWatch Logs. Fluent Bit sends logs from your containers in the cluster to CloudWatch Logs. In Step 1 above, we’ve set up Fluent Bit as a DaemonSet to send logs to CloudWatch Logs. Fluent Bit creates the log group below if it doesn't already exist:

`/aws/containerinsights/Cluster_Name/application` which contains all log files in `/var/log/containers` on each worker node in the cluster.

### To Run a CloudWatch Logs Insights Sample Query:

* Open the CloudWatch console.
* In the navigation pane, choose **Logs**, and then choose **Log groups**.
* Click the log group `/aws/containerinsights/CLUSTER_NAME/application`. Where CLUSTER_NAME is the actual name of your EKS cluster.
* Under the log details (top-right), click **View in Logs Insights**.
* Delete the default query in the CloudWatch Log Insight Query Editor. Then, enter the following command and select Run query:

```bash
fields @timestamp, kubernetes.pod_name as PodName, kubernetes.host as WorkerNode, kubernetes.namespace_name as Namespace, log
| filter PodName like 'quickstart-nginx-deployment'
| sort @timestamp desc
| limit 200
```

* Use the time interval selector to select a time period that you want to query. For example:

![Logs Insights Query](./images/Container_Insight_Query.png)

## Step 4: Monitor Performance of the Application with Container Insights

Monitoring the performance of your containerized application is essential for maintaining optimal functionality, identifying potential issues, and understanding the behavior of the system. In this step, you'll leverage AWS CloudWatch's Container Insights to gain detailed visibility into your container's performance.

### View Container Insights Dashboard Metrics

In this section, you will learn how to access the Container Insights Dashboard Metrics within AWS CloudWatch. This dashboard provides a centralized view of your Amazon EKS and Kubernetes clusters' performance, offering real-time insights into various metrics such as CPU utilization, memory usage, and network activity. By following these steps, you can quickly navigate to the specific cluster and resources you wish to monitor, enabling you to keep a close eye on the health and performance of your containerized applications.

1. Open the CloudWatch console at https://console.aws.amazon.com/cloudwatch/.
2. In the left navigation pane, open the **Insights** dropdown menu, and then choose **Container Insights**.
3. Under “Container Insights” (top), select **Performance Monitoring** from the dropdown menu.
4. In the “EKS Clusters” dropdown field, select the name of your cluster.
5. Use the additional dropdown menus to filter resources, such as “EKS Clusters” and “EKS Pods.” For example:

![Container Insights Dashboard Metrics](./images/Container_Insights.png)

### View Additional [Amazon EKS and Kubernetes Container Insights Metrics](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/Container-Insights-metrics-EKS.html)

In this section, you will explore how to access a broader set of metrics specific to Amazon EKS and Kubernetes within AWS CloudWatch. These additional metrics, like pod_cpu_utilization_over_pod_limit, provide deeper insights into the performance and behavior of your containerized applications and the underlying infrastructure. Whether you are looking to analyze CPU utilization, Memory usage, or Network metrics, this process allows you to customize your view and focus on the aspects most relevant to your needs.

#### Let’s Explore an Application Exceeding Its Resource Limit

1. Create a Kubernetes manifest called `geo-api.yaml` with the content below to deploy a simple backend application called **geo-api** with the following command:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: geo-api
spec:
  selector:
    matchLabels:
      run: geo-api
  replicas: 1      
  template:
    metadata:
      labels:
        run: geo-api
    spec:
      containers:
      - name: geo-api
        image: registry.k8s.io/hpa-example
        ports:
        - containerPort: 80
        resources:
          limits:
            cpu: 250m
            memory: "12Mi"
          requests:
            cpu: 125m
            memory: "10Mi"
---
apiVersion: v1
kind: Service
metadata:
  name: geo-api
  labels:
    run: geo-api
spec:
  ports:
  - port: 80
  selector:
    run: geo-api
```

The Deployment creates 1 Pod that has 1 container. The container is defined with a request for 0.125 CPU and 10MiB of memory. The container has a limit of 0.25 CPU and 12MiB of memory. 

2. Deploy the application using the command below:

```bash
kubectl apply -f geo-api.yaml
```

3. Create a load for the web server by running a container.

```bash
kubectl create deployment geo-api-load \
  --image=busybox \
  --replicas=2 -- /bin/sh -c "while sleep 0.01; do wget -q -O- http://geo-api; done" 
```

4. Verify the Pods status:

```bash
kubectl get pods
```

The expected output should look like this:

```bash
NAME                           READY   STATUS              RESTARTS       AGE
geo-api-load-c9c7bf98c-4rrn8   0/1     ContainerCreating   0               0s
geo-api-load-c9c7bf98c-kzsjs   0/1     ContainerCreating   0               0s
geo-api-load-c9c7bf98c-4rrn8   1/1     Running             0               1s
geo-api-load-c9c7bf98c-kzsjs   1/1     Running             0               2s
geo-api-76f6dcf999-ptpz5       1/1     Running             20 (5m8s ago)   118m
geo-api-76f6dcf999-ptpz5       0/1     OOMKilled           20 (5m13s ago)   118m
```

The output shows that the geo-api Pod status is Running and sometimes getting OOMKilled.

Get a more detailed view of the Container status:

```bash
kubectl get pod geo-api-76f6dcf999-ptpz5 --output=yaml | grep -i lastState -A7
```

The output shows that the Container was killed because it is out of memory (OOM):

```bash
    lastState:
      terminated:
        containerID: containerd://4bbdfee06a3d3daca0e74f14f18f8a66ac0a415c79720eae44ea9ad4c46bcb37
        exitCode: 137
        finishedAt: "2023-08-26T12:48:37Z"
        reason: OOMKilled
        startedAt: "2023-08-26T12:47:27Z"
    name: geo-api
```

5. Let’s view the Container Insights metrics of this pod:
    1. Open the CloudWatch console at https://console.aws.amazon.com/cloudwatch/.
    2. In the navigation pane, choose **Metrics**, and then choose **All metrics**.
    3. Select the **ContainerInsights** metric namespace. Select the **ClusterName**, **Namespace**, and **PodName**, in the search bar, copy and paste **PodName="geo-api"**.
    4. You can view the percentage of CPU units being used by the pod relative to the pod limit and the percentage of memory that is being used by pods relative to the pod limit by selecting the metrics below:
        * `pod_cpu_utilization_over_pod_limit`
        * `pod_memory_utilization_over_pod_limit`

![Container Insights metrics](./images/resource_monitoring.png)

The graph shows that the container in the pod has completely utilized its CPU and memory limit and you will need to specify enough resources to prevent the container in the pod from being terminated.

## Clean Up

To avoid incurring future charges, you should delete the resources created during this tutorial. You can delete the container application and also delete the CloudWatch agent and Fluent bit for Container Insights with the following command:

```bash
# Delete workloads
kubectl delete -f workload.yaml -n quickstart

kubectl delete -f geo-api.yaml

# Delete the the CloudWatch agent and Fluentbit for Container Insights
kubectl delete -f cwagent-fluent-bit-quickstart.yaml
```

## Conclusion

By following this tutorial, you've successfully set up CloudWatch agent and Fluent Bit for Container Insights to monitor  sample containerized workloads in an Amazon EKS cluster. With these instructions, you'll have a robust monitoring and logging solution to help you monitor the performance of application deployments in the cluster. If you want to explore more tutorials, check out [Navigating Amazon EKS](https://community.aws/tutorials/navigating-amazon-eks#list-of-all-tutorials).
