---
title: "Running the top open source Vector Database on AWS: What They Don't Tell You in the Quickstart Guide"
description: In this post, we will create an EKS cluster and deploy a Milvus vector database on AWS in a smarter way than the Milvus docs describe. 
tags:
  - vector-databases
  - eks
  - llm
authorGithubAlias: JoeStech
authorName: Joe Stech
date: 2023-10-25
---

You're a seasoned cloud practitioner, and your company leadership has come to you with a bunch of different use cases for LLMs. You know that to make most of the solutions performant and cost effective you're going to need the ability to index vector embeddings in real-time so you can perform euclidean distance calculations on them immediately.

Maybe you just need to cache and re-use LLM inputs/outputs.

Maybe you know that you don't even need an LLM and you just want to implement entity comparison features on your existing corpus of documents.

Maybe you have users uploading millions of documents a day and you need to do comparison searches on chunks of uploaded text in real-time.

Whatever the reason, you've decided that Milvus is the vector database for you, because it's got a proven track record and is open source, so you can run it yourself on top of AWS.

## Creating the EKS cluster

You go to the milvus website and you start digging around in the documentation. Awesome, they've got a section called "Administration Guide->Deploy on Clouds->AWS"! They've got ways to deploy on raw EC2 instances or on EKS, and you [decide to go with EKS](https://milvus.io/docs/eks.md) because you don't want to have to manage a bunch of raw instances yourself.

You make sure you've got all the required tools installed, and you get to the first code block in the quickstart: the EKS yaml file.

```
apiVersion: eksctl.io/v1alpha5
kind: ClusterConfig
metadata:
  name: my-eks-cluster
  region: us-west-2
  version: "1.23"

nodeGroups:
  - name: ng-1-workers
    labels: { role: workers }
    instanceType: m5.4xlarge
    desiredCapacity: 2
    volumeSize: 80
    iam:
      withAddonPolicies:
        ebs: true

addons:
- name: aws-ebs-csi-driver
  version: v1.13.0-eksbuild.1 # optional
```


You can see that it's pretty good, it will get the job done, but you're a pro. The first thing you notice is that you need to change the EKS version, since 1.23 is no longer within standard support, so you change it to the [latest version](https://docs.aws.amazon.com/eks/latest/userguide/kubernetes-versions.html). You also don't want to be setting up a cluster that allows anyone on the public internet to be accessing your service endpoint, even if you do have it locked down with proper IAM permissions.

So you add these lines:

```
vpc:
  publicAccessCIDRs:
    - [your IP, or the IP range of your company VPC]
```

Longer term you'll probably want to provision the VPC yourself, but for now you can let eksctl create one that's dedicated to your EKS cluster.

Now you're ready to run

`eksctl create cluster -f milvus_cluster.yaml`

Once the cluster is provisioned, you'll want to configure kubectl so that you can control your EKS cluster:

`aws eks --region ${aws-region} update-kubeconfig --name ${cluster-name}`

And if you're working with other trusted devs, you'll want to add them to your EKS masters group with an iamidentitymapping:

`eksctl create iamidentitymapping --cluster ${cluster-name} --region ${aws-region} --arn ${user-ARN} --username ${username} --group system:masters --no-duplicate-arns`

Now you and your collaborators are all set up to manage the EKS cluster together.

## Installing Milvus on the EKS cluster

As the Milvus docs will tell you, the next thing you'll want to do is configure the helm repo locally:

`helm repo add milvus https://zilliztech.github.io/milvus-helm/`

And if you want to look at the various version available for install, you'll use

`helm search repo milvus -l`

The milvus documentation will tell you to run
```
helm upgrade --install --set cluster.enabled=true --set externalS3.enabled=true --set externalS3.host='s3.us-west-2.amazonaws.com' --set externalS3.port=80 --set externalS3.accessKey=${access-key} --set externalS3.secretKey=${secret-key} --set externalS3.bucketName=${bucket-name} --set minio.enabled=False --set service.type=LoadBalancer milvus milvus/milvus
```

But we both know that you're going to want to specify all these values, and more, in a `values.yaml` file instead of chucking them all on the command line.

Specifically, you're going to want to add a specific version of Milvus that you want to deploy, plus `loadBalancerSourceRanges` to restrict access by IP for security (like we did with the EKS cluster!). You'll also want to turn on authorization for security, and enable Kafka instead of Pulsar for efficiency.

Put it all together and it looks like:


```
cluster:
  enabled: true
  
dataNode:
  replicas: 2
  
indexNode:
  replicas: 2
  
queryNode:
  replicas: 2
  
proxy:
  replicas: 2
  
externalS3:
  enabled: true
  host:"s3.us-west-2.amazonaws.com"
  port: 80
  
kafka:
  enabled: true
  
pulsar:
  enabled: false
  
minio:
  enabled: false
  
service:
  type: LoadBalancer
  loadBalancerSourceRanges:
    - [your IP]
    
extraConfigFiles:
  user.yaml: |+
    common:
      security:
        authorizationEnabled: true
```

And finally, to actually deploy the cluster, you'll run


`helm upgrade --install -f values.yaml --set externalS3.accessKey=${access-key} --set externalS3.secretKey=${secret-key} --set externalS3.bucketName=${bucket-name} --version ${milvus-helm-version} milvus milvus/milvus`

You can see that you should still specify the S3 creds from the command line, you don't want those being accidentally checked in to your code repo.

Beautiful! You now have a Milvus vector database running on EKS, ready to be scaled up.

You can peek in the AWS EKS console to find the ELB endpoint where Milvus can be queried.

Your next step might be to check out the [Milvus Sizing Tool](https://milvus.io/tools/sizing) in order to figure out how many nodes you'll need to deploy to index and retrieve the number of embeddings you'll be storing.

You are now an AWS vector db wizard.