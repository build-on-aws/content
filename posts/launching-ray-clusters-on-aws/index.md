---
title: "How to launch Ray Clusters on AWS"
description: "Getting started with Ray clusters on AWS"
tags:  
  - ai-ml
  - ray
  - aws
  - ai-ml-scaling

spaces:
  - generative-ai
waves:
  - data
  - generative-ai
authorGithubAlias: rucmish
authorName: Ruchi Mishra
additionalAuthors: 
  - authorGithubAlias: naga-gaddamu
    authorName: Naga Gaddamu
date: 2023-10-24
---


|ToC|
|---|

1. [Introduction to Ray](#introduction-to-ray)
2. [Ray and AWS a powerful combination](#ray-and-aws-a-powerful-combination)
3. [AWS Environment SetUp to Launch Ray Cluster](#aws-environment-setup-to-launch-ray-cluster)
4. [Scaling and Distributing Ray workloads on AWS](#scaling-and-distributing-ray-workloads-on-aws)

## Introduction to Ray

Ray is a general purpose universal library that allows you to do distributed computing and it offers you an ecosystem of native libraries to scale ML workloads. It can run anywhere, you can run it on a laptop or on public Cloud , on Kubernetes or on-premise.
In simple words Ray provides you with simple Primitives for you to be able to take your python applications that you have and convert them into distributed manner at scale and take away the undifferentiated heavy lifting.
As a developer you can use Ray to take advantage of the resources available in a distributed environment without having to worry about the underlying infrastructure. Ray removes compute constraints and is fault tolerant.

In this blog we will learn how to get started with Ray on AWS.

## Ray and AWS a powerful combination

AWS is designed to allow application to perform at scale. It does not only support online business as websites but also compute intensive applications consisting of Machine Leaning models. With the growing adoption of ML and GenerativeAI you can use Ray to solve common production challenges for genAI and scale ML. Using Ray you can step away from the heavy lifting of driving the distributed training and focus more on training the models and applications.

## AWS Environment SetUp to Launch Ray Cluster

1. AWS Account: You will need an AWS account to create and manage cloud resources.
2. Python 3.x is installed.
3. AWS user with IAM permission to create EC2 instances
4. The AWS CLI is installed and credentials are configured to authenticate the IAM user. Check out this how to guide :
<https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html>

### Step 1: Launch an EC2 instance

1. Log in to your AWS Management Console.
2. Navigate to the EC2 dashboard.
3. Click on "Launch Instance" to create a new virtual machine.
4. Choose an Amazon Machine Image (AMI) that suits your needs. A standard Linux distribution like Amazon Linux or Ubuntu Server is a good starting point.
5. Select an instance type based on your workload requirements. Ray can be run on various instance types, but for experimentation, a t2.micro (free-tier eligible) instance is sufficient.
6. Configure instance details, storage, security groups, and add tags if needed.
7. Review your settings and launch the instance. You'll need an SSH key pair to access the instance securely.

### Step 2: Connect to Your EC2 Instance

Once your EC2 instance is running, connect to it via ‘EC2 instance Connect’

### Step 3: Install Ray

Now you are logged in the EC2, you can install Ray using pip:

```python
sudo su
yum install python3-pip

pip install ray
```

### Step 4: Write your first Ray program on EC2

1. Make a new directory and create python file raytest

    ```python
    mkdir RayTest
    cd RayTest
    nano raytest.py
    ```

    ```python
    import ray

    ray.init()

    @ray.remote
    def say_hello():
        return "Hello, Let’s get started with Ray on AWS!"

    futures = [say_hello.remote() for _ in range(5)]

    results = ray.get(futures)
    print(results)

    ray.shutdown()
    ```

2. Run your program using the below command

    ```python
    python rayTest.py
    ```

    You'll see the distributed power of Ray in action as it prints out ' Hello, Let’s get started with Ray on AWS!'

## Scaling and Distributing Ray workloads on AWS

One of the significant benefits of Ray is its ability to scale out to multiple nodes. To scale your Ray cluster on AWS:

1. Launch additional EC2 instances following Step 1.
2. Install Ray on each instance as in Step3.
3. On the second instance modify the init block to use the head node i.e. public ip of the first instance.
This allows your program to use multiple nodes for distributed computing.

    ```python
    ray.init(address="ray://<ip address of the first instance>:6379")
    ```

4. Execute your program, and Ray will distribute tasks across all connected instances.

Happy Scaling with Ray on AWS !

- [ruchi-mishra](https://www.linkedin.com/in/ruchimi/)
- [naga-gaddamu](https://www.linkedin.com/in/nagagaddamu/)
