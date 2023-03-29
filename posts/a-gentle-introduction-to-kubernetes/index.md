---  
title: "A Gentle Introduction to Kubernetes"  
description: Introducing container, Container orchestration and EKS?  
tags:  
- cloud
- basics
- containers
- container orchestration
- kubernetes
- eks
authorGithubAlias: sguruvar
authorName: Siva Guruvareddiar
date: 2023-03-29  
---
## Introduction to Kubernetes

Kubernetes is an open-source platform that is used to manage containerized applications. It was originally developed by Google and is now maintained by the Cloud Native Computing Foundation (CNCF), a non-profit organization that promotes the use of cloud-native technologies. Kubernetes is a Greek word that means "helmsman" or "pilot". The term was chosen by the founders of Kubernetes because the system is designed to be a pilot or conductor for a fleet of containers, just as a helmsman or pilot is responsible for steering a ship. Sometimes Kubernetes is abbreviated as k8s.

Kubernetes helps developers deploy, scale, and manage their containerized applications in a more efficient and effective manner. Containers are lightweight, portable, and self-contained packages that include all the code and dependencies needed to run an application. Kubernetes provides a set of tools and APIs that make it easier to manage these containers, making it a popular choice for developers.

### Why Kubernetes
Kubernetes provides a number of benefits that make it a popular choice for managing containerized applications. First, it allows developers to easily deploy and scale applications, making it easier to handle traffic spikes or changes in demand. Additionally, Kubernetes offers built-in load balancing and automatic failover capabilities, which helps ensure that applications remain available and responsive. It also provides a consistent development and deployment environment, which makes it easier to move applications between different environments, such as development, testing, and production. Finally, Kubernetes is open source and has a large and active community, which means it's constantly evolving and improving with new features and capabilities.

### Kubernetes Components
Kubernetes is made up of several components that work together to manage containerized applications. Here are the key components of Kubernetes:
1. Control Plane: This is the brain of Kubernetes, and it manages the overall state of the cluster. It includes several components:
* API Server: This is the main interface for interacting with the Kubernetes API. It receives requests from users and other components in the cluster, and it stores the state of the cluster in etcd.
* etcd: This is a distributed key-value store that holds the configuration data and the state of the cluster. All changes to the cluster state are recorded in etcd.
* Controller Manager: This component runs various controllers that are responsible for maintaining the desired state of the cluster. For example, the ReplicaSet controller makes sure that the desired number of replicas of a containerized application are running.
* Scheduler: This component is responsible for assigning containers to nodes in the cluster based on resource availability and other constraints.
* Nodes: These are the individual computers that run containers. Each node runs a container runtime (like Docker) and communicates with the other nodes in the cluster through the Kubernetes API.

2. Kubernetes API: This is the main interface for interacting with the Kubernetes control plane. Users and other components can use the API to create, update, and delete resources in the cluster.

3. Add-ons: These are optional components that provide additional functionality to the cluster. Some examples of add-ons include:
* DNS: This provides a way for containers to discover and communicate with each other by name.
* Dashboard: This is a web-based user interface for managing the cluster.
* Ingress Controller: This provides a way to route external traffic to the appropriate container.

4. Pods: Pods are the smallest deployable units in Kubernetes. They are like tiny containers that can run a single container or multiple containers that share the same resources.

5. Services: Services are used to define a set of pods and the network endpoints for accessing them. They provide a stable IP address and DNS name for accessing the pods, even if they move around in the cluster.

6. Volumes: Volumes are used to provide persistent storage for containers. They can be used to store data that needs to survive even if the container is deleted or recreated.

7. ConfigMaps and Secrets: ConfigMaps and Secrets are used to manage configuration data and sensitive information, like passwords or API keys.

### Kubernetes under the hood
At its core, Kubernetes is a complex system of interacting components that work together to manage containerized applications. When a user deploys an application to Kubernetes, the system creates a set of objects that define how the application should run. These objects are then scheduled onto a set of nodes in the Kubernetes cluster, which are responsible for running the actual containers that make up the application. Kubernetes monitors these objects and nodes, making decisions about when to scale the application, how to route traffic to it, and how to recover from failures. Under the hood, Kubernetes relies on a number of different technologies, including etcd for distributed state management, the Kubernetes API for communication between components, and various network plugins for managing communication between containers and nodes. All of these components work together to provide a powerful and flexible platform for running containerized applications at scale.

### Benefits of Kubernetes
1. Scalability: Kubernetes allows you to easily scale your applications up or down in response to changes in demand, making it easy to handle traffic spikes and ensure that your applications remain responsive.

2. Fault tolerance: Kubernetes has built-in features for automatic failover and recovery, which helps ensure that your applications remain available even in the face of failures or downtime.

3. Portability: Kubernetes provides a consistent development and deployment environment, which makes it easy to move applications between different environments, such as development, testing, and production.

4. Flexibility: Kubernetes supports a wide range of container runtimes, including Docker and containerd, and can run on a variety of different platforms, including on-premises data centers, public cloud providers, and hybrid cloud environments.

5. Community: Kubernetes is open source and has a large and active community of developers, which means it's constantly evolving and improving with new features and capabilities.

## Introduction to AWS EKS
AWS EKS is a managed service that provides a fully-managed Kubernetes control plane on AWS. With EKS, you don't need to manage the control plane yourself, as AWS takes care of this for you. Instead, you can focus on deploying and managing your applications using Kubernetes.

### EKS Components
Here are the key components of AWS EKS:

1. Amazon EKS Control Plane: The Amazon EKS Control Plane is the central management system that handles the Kubernetes API operations and state management of the cluster. It includes components such as the Kubernetes API server, etcd, and the Kubernetes scheduler.

2. Worker Nodes: Worker nodes are the compute resources in your Kubernetes cluster that run your applications and other Kubernetes components. In EKS, these are typically EC2 instances that are managed by the Amazon EKS Control Plane.

3. Kubernetes API Server: The Kubernetes API Server is the front-end for the Kubernetes Control Plane. It exposes the Kubernetes API, which is used by other Kubernetes components and applications to interact with the cluster.

4. etcd: etcd is a distributed key-value store that is used by Kubernetes to store the state of the cluster. It is a critical component of the Kubernetes Control Plane and is responsible for ensuring that the state of the cluster remains consistent across all nodes.

5. Kubernetes Controller Manager: The Kubernetes Controller Manager is responsible for running the various controllers that are used to manage the state of the cluster. These controllers include the Node Controller, which manages the state of the worker nodes, and the Replication Controller, which manages the state of replicated pods.

6. Kubernetes Scheduler: The Kubernetes Scheduler is responsible for scheduling pods onto worker nodes based on the resource requirements of the pod and the available resources on the worker node.

7. AWS VPC: Amazon EKS clusters are deployed into a Virtual Private Cloud (VPC), which allows you to control network traffic and security for your Kubernetes workloads.

8. AWS IAM: Amazon EKS integrates with AWS Identity and Access Management (IAM), which allows you to manage access to your Kubernetes clusters and resources using AWS IAM roles and policies.

### Benefits of AWS EKS
Here are some of the benefits of using AWS EKS in addition to the above Kubernetes benefits:

1. Fully Managed Service: Amazon EKS is a fully managed service, which means that AWS takes care of managing and maintaining the underlying infrastructure for your Kubernetes cluster. This includes the Kubernetes Control Plane, worker nodes, and other components, allowing you to focus on your applications and business logic.

2. Scalability: Amazon EKS is designed to be highly scalable, allowing you to easily scale your Kubernetes clusters up or down based on your application needs. You can add or remove worker nodes, or even create multiple clusters, all with just a few clicks in the AWS Management Console.

3. Security: Amazon EKS integrates with AWS security services, such as AWS Identity and Access Management (IAM), AWS Key Management Service (KMS), and Amazon Virtual Private Cloud (VPC), to provide a secure environment for your Kubernetes workloads. This includes features such as encryption at rest and in transit, network isolation, and access control.

4. High Availability: Amazon EKS is designed to provide high availability for your Kubernetes clusters, with automatic failover and redundancy built in. This ensures that your applications remain available even in the event of a failure of a single node or component.

5. Cost-Effective: Amazon EKS offers a cost-effective way to run Kubernetes clusters on AWS, with pay-as-you-go pricing and no upfront costs or commitments. You only pay for the resources you use, making it easy to scale your clusters up or down as needed.

6. Interoperability: Amazon EKS is compatible with any application that runs on Kubernetes, allowing you to take advantage of the vast ecosystem of Kubernetes tools and services. This includes tools for container orchestration, service discovery, monitoring, and more.


**If you want to [learn more about Kubernetes](https://www.cncf.io/projects/kubernetes/) and start your hands-on container orchestration journey with [AWS EKS](https://docs.aws.amazon.com/eks/latest/userguide/getting-started.html), start from here https://eksworkshop.com/.**
