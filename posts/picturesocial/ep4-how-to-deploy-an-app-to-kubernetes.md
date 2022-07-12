---
layout: blog.11ty.js
title: Picturesocial - How to deploy an App to Kubernetes
description: Deploying an App to Kubernetes is like having that only recipe that always works, if is well written once it can be used to create a lot of different dishes. In this episode we are going to learn about Kubernetes Manifest and the basic commands to deploy an App in an easy and reusable way.
tags:
  - containers
  - kubernetes
  - eks
  - picturesocial
authorGithubAlias: jyapurv
authorName: Jose Yapur
date: 2022-07-11
---
# Picturesocial - How to deploy an App to Kubernetes

So far we have learn about Containers, Kubernetes and Terraform. Now it’s time to use the knowledge that we acquired on the previous posts to deploy a container on our Amazon Elastic Kubernetes Service cluster. In this article we are also going to learn about the Kubectl tool and some commands to handle basic Kubernetes tasks.

To understand the basic flow of application deployment into Kubernetes we have to understand the complete flow of a containerized application development. I designed this diagram to help summarize the process.
![ep4](/picturesocial/images/04-01.jpg "ep4")

I divided the diagram in 5 steps explained below to help clarify the activities involved.

1. First, we have to build our Container Image, setting an image name and a tag. Once the Image is created we can test the container locally before going further.
2. Once that the container works properly we have to push the Image into a Container Registry, in the case of AWS we are going to use Elastic Container Registry. All the required to get here are on our [first episode](/picturesocial/ep1-how-to-containerize-app-less-than-15-min)
3. When the Container Image is stored on the Container Registry we have to create a Kubernetes manifest, that way we send instructions to the cluster to create: a pod, a replica set and a service. We also tell the cluster from where to retrieve the Container Image and how are we going to update the application version. If you want to remember how, this a good time to review the [second episode](/picturesocial/ep2-whats-kubernetes-and-why-should-care)
4. Now we are ready to create our Kubernetes Cluster in order to later get the credentials, this is made once per project. We learn how to create and connect to a Kubernetes cluster on our [third episode](/picturesocial/ep3-how-to-deploy-kubernetes-aws-terraform)
5. And last but not least we use Kubectl to deploy our application to Kubernetes using the Manifest. We are going to learn about this final step in the walk-through

Now, that we have remember and put together the things we learned from previous episodes, let’s go and deploy the application! I’m assuming that you already reviewed the walk-throughs from previous episodes before continue with this.

### Pre-requisites

* An AWS Account https://aws.amazon.com/free/
* If you are using Linux or MacOS you can continue to the next bullet point, if you are using Microsoft Windows I suggest you to use WSL2 https://docs.microsoft.com/en-us/windows/wsl/install
* Install Git https://github.com/git-guides/install-git
* Install Kubectl https://docs.aws.amazon.com/eks/latest/userguide/install-kubectl.html
* Install AWS CLI 2 https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html

Or

* If this is your first time working with AWS CLI or you need a refresh on how to set up your credentials, I suggest you to follow this step-by-step of how to configure your local environment https://aws.amazon.com/es/getting-started/guides/setup-environment/ in this same link you can also follow steps to configure Cloud9, that will be very helpful if you don’t want to install everything from scratch.

### Walk-through

* First, we are going to connect to check if we have Kubectl correctly installed by running:

```
kubectl version
```

* You should get a version at least `Major:"1", Minor:"23" `to run this walk-through, otherwise I suggest you to check this link to learn how to upgrade https://docs.aws.amazon.com/eks/latest/userguide/install-kubectl.html
* When you created the cluster, you also run a command to update the kubeconfig file. You don’t have to run it again, but just a friendly reminder that it is a necessary step to continue further.

```
aws eks --region $(terraform output -raw region) update-kubeconfig --name $(terraform output -raw cluster_name)
```

* That step download into your local terminal a kubeconfig file with: a/ the cluster name, b/ kubernetes api url, c/key to connect. That file is saved by default in `/.kube/config` you can see an example, from Kubernetes official documentation, below:

```
apiVersion: v1
clusters:
- cluster:
    certificate-authority: fake-ca-file
    server: https://1.2.3.4
  name: development
- cluster:
    insecure-skip-tls-verify: true
    server: https://5.6.7.8
  name: scratch
contexts:
- context:
    cluster: development
    namespace: frontend
    user: developer
  name: dev-frontend
- context:
    cluster: development
    namespace: storage
    user: developer
  name: dev-storage
- context:
    cluster: scratch
    namespace: default
    user: experimenter
  name: exp-scratch
current-context: ""
kind: Config
preferences: {}
users:
- name: developer
  user:
    client-certificate: fake-cert-file
    client-key: fake-key-file
- name: experimenter
  user:
    password: some-password
    username: exp
## Source: https://kubernetes.io/docs/tasks/access-application-cluster/configure-access-multiple-clusters
```

* Now that we have the kubeconfig we have stablished a trust relationship between your Terminal and Kubernetes that will work through kubectl.
* First, let’s look at the workers for this cluster by running the command below. The command will return the 3 workers that we created, the version of Kubernetes and the age of the worker since creation or upgrade. As you can see, each worker is on a different subnet that belongs to 3 different availability zones.

```
`kubectl get nodes`
```

![ep4](/picturesocial/images/04-02.jpg "ep4")
* As well as nodes you can also check for pods by running the command above, but be mind that we haven’t deploy anything yet, also if you don’t specify a namespace in the command it will return everything from the “default” namespace. 

```
kubectl get pods
```

![ep4](/picturesocial/images/04-03.jpg "ep4")
* But we can also specify the pods in all namespaces, including the ones that Kubernetes needs to run properly by adding the `—all-namespaces` parameter.

```
kubectl get pods --all-namespaces
```

![ep4](/picturesocial/images/04-04.jpg "ep4")
* The same with Services, let’s check all the services in the cluster. As you can see, you have the default service that will handle the kubecontrol requests and the kube-dns that will handle the calls to the coredns of the cluster. It’s important that we don’t edit or delete any of the those services or pods, believe me :)

```
`kubectl get services --al-namespaces`
```

![ep4](/picturesocial/images/04-05.jpg "ep4")
* We can also check the replica sets of the cluster by running.

```
`kubectl get rs --al-namespaces`
```

![ep4](/picturesocial/images/04-06.jpg "ep4")
* As you can see, the commands for running the basics are pretty simple and self explanatory. Now let’s deploy the container that we created from our first episode.
* I have prepared a branch with everything that you will need, we are going to clone it first. And position our self on the folder that we are going to use.

```
git clone https://github.com/aws-samples/picture-social-sample.git -b ep4
cd picture-social-sample/HelloWorld
```

* Now lets open the file manifest.yml. That file includes the Kubernetes Manifest, as we can see, this manifest will create a deployment called `helloworld` with a pod of a container stored at `111122223333.dkr.ecr.us-east-1.amazonaws.com/helloworld` Also replicated twice. The manifest also include a Service with a Public Load Balancer that will expose the port 80 and will target the container port 5111.

```
#########################
# Definicion de las POD
#########################
apiVersion: apps/v1
kind: Deployment
metadata:
  name: helloworld
  labels:
    app: helloworld
spec:
  replicas: 2
  selector:
    matchLabels:
      app: helloworld
  template:
    metadata:
      labels:
        app: helloworld
    spec:
      containers:
      - name: helloworld
        image: 111122223333.dkr.ecr.us-east-1.amazonaws.com/helloworld
        resources:
          requests:
            memory: "256Mi"
            cpu: "250m"
          limits:
            memory: "512Mi"
            cpu: "500m"
---
#########################
# Definicion del servicio
#########################
kind: Service
apiVersion: v1
metadata:
  name: helloworld-lb
spec:
  selector:
    app: helloworld
  ports:
  - port: 80
    targetPort: 5111
  type: LoadBalancer
```

* Now we are ready to deploy the application to Kubernetes, just make sure you change the Amazon ECR Account ID  on the Manifest before proceed.
* We going to work using the Namespace “tests” for this episode. Remember that Namespaces will help us handle the order of the Pods and group them by Business Domain or Affinity. So let’s create the namespace

```
kubectl create namespace tests
```

* Now that we have the namespace created we are going to apply changes to Kubernetes using the manifest and specifying the newly created namespace.

```
kubectl apply -f manifest.yml -n tests
```

![ep4](/picturesocial/images/04-07.jpg "ep4")
* You can now check the deployment, the pods and the service. Just don’t forget to always pass the parameter namespace.
* For pods, you should get two replicas of the same pod.

```
kubectl get pods -n tests
```

![ep4](/picturesocial/images/04-08.jpg "ep4")
* If you want to see details from a specific pod, you can run the following command, where podName is the name of the pod that you want to check. It also include the scheduling from the Kubernetes Control Plane to that specific pod and the historic of all events.

```
kubectl describe pod **podName** -n tests
```

![ep4](/picturesocial/images/04-09.jpg "ep4")
![ep4](/picturesocial/images/04-10.jpg "ep4")

* You can also check the logs from an specific pod in streaming by running the following command and specifying the podName.

```
kubectl logs **podName** -f -n tests
```

![ep4](/picturesocial/images/04-11.jpg "ep4")

* I recommend you to store the Kubernetes logs for observability into CloudWatch, but we are going to cover this in the next episodes. You can take a look to the official Amazon EKS documentation for more information: https://docs.aws.amazon.com/prescriptive-guidance/latest/implementing-logging-monitoring-cloudwatch/kubernetes-eks-logging.html
* Now you can also check your Service status and address to test if the application is running. The EXTERNAL-IP column is the one that contains the FQDN Address that you can use.

```
kubectl get services -n tests
```

![ep4](/picturesocial/images/04-12.jpg "ep4")

* Now you can open the browser and test your application, just be sure to use http instead of https for this specific test. We are going to learn how to protect your API Endpoints on a future episode.

![ep4](/picturesocial/images/04-13.jpg "ep4")

* That simple “Hello Jose“ from the API response is the call to a LoadBalancer that choose one of the two pods to send the request and then it was rendered in your browser as the output. I highly suggest you to try this only locally and not exposing it to internet. We are going to learn how to expose endpoints to the outside world using other security layers like API Gateways and Layer 7 Load Balancers in the next episodes.
* Now let’s proof why Kubernetes is a self-healing Container Orchestrator. We are going to delete one of the two pods and see what happens. 

```
kubectl delete pod podName -n tests
```

* As soon as a pod is deleted, Kubernetes will provision another clone, because the replica set has to be honored. If you want to see the stream of pods and status you can add the `-w `parameter to watch for changes.

```
kubectl get pods -w -n tests
```

![ep4](/picturesocial/images/04-14.jpg "ep4")

* You can also set an autoscale rule for your deployment by running the following command. Where —max is the number of max replicas that will handle this HPA or Horizontal Pod Autoscaler, —min is the number of minimum replicas running and —cpu-percent is the percentage of CPU of all the current pods from this deployment, in case of exceeding the number specified it will scale up.

```
`kubectl autoscale deployment helloworld --max 10 --min 2 --cpu-percent 70 -n tests`
```

* You can check the status of the HPA by running the following command:

```
kubectl get hpa -n tests
```

I hope you enjoy this article as much as I enjoyed writing it! And I also hope that it gave you some clarification from the previous episodes. If everything went well, you learned how to deploy an application to Kubernetes, create services, access the commands to create namespaces and work through namespaces, check for object descriptions, review the logs of your application, scale your application and create rules for autoscaling.

The next episode we are going to develop one of the core parts of Picturesocial, the API for Image Recognition and auto tagging using Amazon Rekognition! 
