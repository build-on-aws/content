---
layout: blog.11ty.js
title: Building a serverless Kafka data pipeline
description: Learn about the tradeoffs of building a serverless Apache Kafka cluster
tags:
  - github-actions
  - ci-cd
  - cdk
authorGithubAlias: aws-banjo
authorName: Banjo Obayomi
date: 2022-08-16
---

In this post I will explain how to build a serverless Kafka data pipeline utilizing Amazon MSK (Managed Streaming for Apache Kafka). Serverless services allow us to build applications without having to worry about the underlying infrastructure. When it comes to Apache Kafka this allows developers to avoid provisioning, scaling, and managing resource utilization of their clusters. 

![Architecture of our solution](images/serverless_kafka_infra.png "Architecture of our solution")

## Serverless Kafka Tradeoffs

Apache Kafka is a distributed event store and stream-processing platform. Kafka provides a mechanism to decouple data processing from the source and target destinations as it's highly scalable and resilient. Kafka is very customizable, based on your workload, which introduces operational overhead. With Amazon MSK Serverless the tradeoff is you lose the flexibility of being able to configure the capacity of your cluster while gaining

* The ability to use Kafka through a single interface that provides an endpoint for clients. 
* Throughput based scaling so you don't need to monitor cluster capacity or reassign Apache Kafka partitions.
* Throughput based pricing so you pay for the data volume you stream and retain, and don’t have to worry about idle brokers and storage

Amazon MSK Serverless provides 200 Mib/s for ingress and 400 Mib/s of egress which is great for default workloads. When workloads grow in size, and the serverless cluster is unable to keep up with the write/read throughput, you can explore using the [Managed AWS Kafka](https://aws.amazon.com/msk/) cluster that provides the flexibility to tune the cluster for your workload but at a higher operational cost.

## Starting a Serverless Kafka Cluster

To get started on AWS you can create a cluster from the [console page](https://aws.amazon.com/msk/features/msk-serverless/).

![Kafka method configuration](images/kafka_config_1.png)

With Serverless, you don't have to worry about configuration. You can use the provided defaults to have cluster up in minutes.

![Kafka cluster configuration](images/kafka_config_2.png)

Once the cluster is up, you can view the API endpoint needed for the clients in the properties tab in the console.

![Kafka API](images/kafka_api_endpoint.png)

For more information on setting up the cluster check out the official [documentation](https://docs.aws.amazon.com/msk/latest/developerguide/serverless-getting-started.html)

## Creating Serverless Kafka Clients

Now we can create Kafka clients to send data to the cluster and consume from it. In this section I will explain the following...

* How to set up the required IAM permissions for our Lambda Function
* Build a Docker image for the Lambda Function
* Configure the Lambda Function to communicate with the serverless Kafka cluster

### Setting permissions

Currently IAM based authentication is required to communicate with the cluster.  The following is an example policy that can be used for the clients.

```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "kafka-cluster:Connect",
                "kafka-cluster:AlterCluster",
                "kafka-cluster:DescribeCluster"
            ],
            "Resource": [
                "arn:aws:kafka:REGION:Account-ID:cluster/CLUSTER_NAME/*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "kafka-cluster:*Topic*",
                "kafka-cluster:WriteData",
                "kafka-cluster:ReadData"
            ],
            "Resource": [
                "arn:aws:kafka:REGION:Account-ID:topic/CLUSTER_NAME/*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "kafka-cluster:AlterGroup",
                "kafka-cluster:DescribeGroup"
            ],
            "Resource": [
                "arn:aws:kafka:REGION:Account-ID:group/CLUSTER_NAME/*"
            ]
        }
    ]
}
```

Next, we can create a new role for the Lambda function and attach the policy above to the role.

![Select IAM role](images/IAM_select.png)

Additionally, the Role will need to have the AWSLambdaVPCAccessExecutionRole policy as the function needs to be deployed in the same VPC as the serverless cluster.

![Select VPC role](images/vpc_select.png)

### Building a Docker Image

For our Lambda function we will use a custom container that has all the prerequisites needed to connect to the Kafka cluster. Below is an example Dockerfile that can be used for building a Kafka client Lambda function. Check out these links for the [handler.py](https://gist.github.com/aws-banjo/9406de18ebb9b434214b27274016a684) and [client.properties files](https://gist.github.com/aws-banjo/68c37dd95c7f87fdced3a791514d5d8f).

```Dockerfile
# Lambda base image
FROM public.ecr.aws/lambda/python:3.8
# Install Kafka prereqs
RUN yum -y install java-11 wget tar
RUN wget https://archive.apache.org/dist/kafka/2.8.1/kafka_2.12-2.8.1.tgz
RUN tar -xzf kafka_2.12-2.8.1.tgz
RUN wget https://github.com/aws/aws-msk-iam-auth/releases/download/v1.1.1/aws-msk-iam-auth-1.1.1-all.jar
RUN mv aws-msk-iam-auth-1.1.1-all.jar ${LAMBDA_TASK_ROOT}/kafka_2.12-2.8.1/libs
COPY ./client.properties ${LAMBDA_TASK_ROOT}
# Remove tgz
RUN rm kafka_2.12-2.8.1.tgz
# Lambda code
COPY handler.py ${LAMBDA_TASK_ROOT}
# Run handler
CMD ["handler.action"]
```

Follow the instructions [here](https://docs.aws.amazon.com/AmazonECR/latest/userguide/docker-push-ecr-image.html) to push your image to [Amazon Elastic Container Registry](https://aws.amazon.com/ecr/) (ECR). Once your image is in ECR, you can create a [Lambda Function using the container image](https://docs.aws.amazon.com/lambda/latest/dg/gettingstarted-images.html). Once the function is created we need to update some settings.

### Configuring the Lambda Function

Finally, we need to configure the Lambda Function, so it can interact with the cluster. For the basic settings we need to increase the memory to 1024 MB, timeout to 1 min and use the IAM role we created above.

![Select Lambda Settings](images/lambda_config_1.png)

Next, we need to make sure the Lambda Function has the same VPC, subnets, and security group as the MSK Cluster

![Select Lambda Settings](images/lambda_config_2.png)

Finally, we need to add the KAFKA_ENDPOINT environment variable set as the MSK cluster endpoint from the “View client information” button.

![Select Lambda Settings](images/lambda_config_3.png)

With that we are ready to begin producing and consuming data.

## Producing and Consuming Data

With Lambda we can send test events through the “Test” tab in the console to verify that our container image is working.  To test the produce function, we can send this payload to push data to `my_topic`

```
{
  "action": "produce",
  "topic": "my_topic",
}
```

The [producer code](https://gist.github.com/aws-banjo/9406de18ebb9b434214b27274016a684#file-handler-py-L73) invokes the producer script with the passed in parameters, using sample data.

```
./kafka_2.12-2.8.1/bin/kafka-console-producer.sh  
--topic {topic} 
--bootstrap-server {KAFKA_ENDPOINT} 
--producer.config client.properties < /tmp/test.json
```

Once the code runs the metrics from the MSK cluster will update in a few minutes to indicate that data was received. The metrics can be viewed from the metrics tab on the cluster main page.

![Kafka data graph](images/kafka_data.png)

We can also then test the consumer code by updating the payload 

```
{
  "action": "consume",
  "topic": "my_topic",
}
```

Similarly, the consumer code invokes the consumer script with the passed in parameters and writes the output to a sample file. The file can be uploaded to S3 or have other functions run on the data depending on your use case. The timeout parameter ensures that the script shuts down, or it will stay up waiting for input. 

```
"./kafka_2.12-2.8.1/bin/kafka-console-consumer.sh 
--topic {topic} --from-beginning 
--bootstrap-server {KAFKA_ENDPOINT} 
--consumer.config client.properties --timeout-ms 12000 > /tmp/output.json"
```

All of the code is configurable to fit your use case, so feel free to use this as a starter guide and adapt as needed.

## Conclusion

In this post, we discussed how to successfully set up the infrastructure needed to begin scaling out a serverless Kafka pipeline by

* Starting a Serverless MSK Cluster
* Creating a Kafka Client Docker Image
* Deploying a Container based Lambda Function
* Producing and Consuming data through the Lambda Console

This solution can be extended to fit different use cases such as reading data from a database on periodic intervals using Eventbridge, or uploading processed messages to S3.  The flexibility of Lambda paired with Kafka’s ability to decouple data processing from the source and target destinations provide the foundation for a serverless data pipeline.

Follow Banjo on Twitter [@banjtheman](https://twitter.com/banjtheman) and [@AWSDevelopers](https://twitter.com/awsdevelopers) for more useful tips and tricks about the cloud in general and AWS.

## About the Author

Banjo is a Senior Developer Advocate at AWS, where he helps builders get excited about using AWS. Banjo is passionate about operationalizing data and has started a podcast, a meetup, and open-source projects around utilizing data. When not building the next big thing, Banjo likes to relax by playing video games especially JRPGs and exploring events happening around him.

