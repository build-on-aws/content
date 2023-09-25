---
title: "Managing Asynchronous Tasks with SQS and EFS Persistent Storage in Amazon EKS"
description: "Run background tasks in a job queue and leverage scalable, multi-availability zone storage."
tags:
    - eks-cluster-setup
    - eks
    - kubernetes
    - eksctl
    - tutorials

authorGithubAlias: tucktuck9
authorName: Leah Tucker
date: 2023-09-28
---

When it comes to managing background work in a Kubernetes environment, the use case isn't solely confined to massive data crunching or real-time analytics. More often, you'll be focused on nuanced tasks like data syncing, file uploads, or other asynchronous activities that work quietly in the background. Amazon SQS, with its 256 KB message size limitation, is especially adept at queuing metadata or status flags that indicate whether jobs are complete or still pending. When combined with Amazon EFS, which offers secure, multi-AZ storage for larger data objects, SQS is free to specialize in task orchestration. This pairing yields two key advantages: it allows for modular operation by segregating different aspects of your background tasks, and it capitalizes on the scalable, multi-availability zone architecture of EFS to meet your evolving storage needs without service interruptions.

Building on the Amazon EKS cluster from [**part 1**](#) of our series, this tutorial dives into the deployment of batch jobs and job queues. Included in the cluster configuration for the previous tutorial is the installation of the [EFS CSI Driver Add-On](https://docs.aws.amazon.com/eks/latest/userguide/eks-add-ons.html#workloads-add-ons-available-eks), [IAM Role for Service Account (IRSA) for the EFS CSI Driver](https://docs.aws.amazon.com/eks/latest/userguide/efs-csi.html#efs-create-iam-resources), and an [OpenID Connect (OIDC) endpoint](https://docs.aws.amazon.com/eks/latest/userguide/enable-iam-roles-for-service-accounts.html). For part one of this series, see [Building an Amazon EKS Cluster Preconfigured to Run Compute-Intensive Batch Processes](#). To complete the last half of this tutorial, you’ll need the EFS CSI Driver Add-On setup on your cluster. For instructions, see [Designing Scalable and Versatile Storage Solutions on Amazon EKS with the Amazon EFS CSI](#). 

You'll also integrate Amazon SQS with your Amazon EKS cluster, build a batch processing application, containerize the application and deploy to Amazon ECR, then use an Amazon SQS job queue to run your batch tasks. In the second half, we'll shift gears to the EFS CSI Driver, which allows us to keep our data intact across multiple nodes while running batch workloads.

## Prerequisites
Before you begin this tutorial, you need to:

* Install the latest version of [kubectl](https://kubernetes.io/docs/tasks/tools/#kubectl). To check your version, run: `kubectl version --short`.
* Install the latest version of [eksctl](https://eksctl.io/introduction/#installation). To check your version, run: `eksctl info`.
* Install [Python 3.9+](https://www.python.org/downloads/release/python-390/). To check your version, run: `python3 --version`.
* Install [Docker](https://docs.docker.com/get-docker/) or any other container engine equivalent to build the container.

| Attributes                |                                   |
| ------------------- | -------------------------------------- |
| ✅ AWS Level        | Intermediate - 200                         |
| ⏱ Time to complete  | 30 minutes                             |
| 🧩 Prerequisites    | - [AWS Account](https://aws.amazon.com/resources/create-account/?sc_channel=el&sc_campaign=devopswave&sc_content=cicdetlsprkaws&sc_geo=mult&sc_country=mult&sc_outcome=acq)|                           |
| 📢 Feedback            | <a href="https://www.pulse.aws/survey/Z8XBGQEL" target="_blank">Any feedback, issues, or just a</a> 👍 / 👎 ?    |
| ⏰ Last Updated     | 2023-09-28                             |

| ToC |
|-----|
<!-- Use the above to auto-generate the table of content. Only build out a manual one if there are too many (sub) sections. -->

---
## Step 1: Configure Cluster Environment Variables

Before interacting with your Amazon EKS cluster using Helm or other command-line tools, it's essential to define specific environment variables that encapsulate your cluster's details. These variables will be used in subsequent commands, ensuring that they target the correct cluster and resources.

1. First, confirm that you are operating within the correct cluster context. This ensures that any subsequent commands are sent to the intended Kubernetes cluster. You can verify the current context by executing the following command:

```
kubectl config current-context
```

2. Define the `CLUSTER_NAME` environment variable for your EKS cluster. Replace the sample value for cluster `region`.

```
export CLUSTER_NAME=$(aws eks describe-cluster --region us-east-1 --name batch-quickstart --query "cluster.name" --output text)
```

3. Define the `CLUSTER_REGION` environment variable for your EKS cluster. Replace the sample value for cluster `region`.

```
export CLUSTER_REGION=$(aws eks describe-cluster --name ${CLUSTER_NAME} --region us-east-1 --profile isengard --query "cluster.arn" --output text | cut -d: -f4)
```

4. Define the `ACCOUNT_ID` environment variable for the account associated with your EKS cluster.

```
export ACCOUNT_ID=$(aws eks describe-cluster --name ${CLUSTER_NAME} --region ${CLUSTER_REGION} --profile isengard --query "cluster.arn" --output text | cut -d':' -f5)
```

## Step 2: Verify or Create the IAM Role for Service Accounts

In this section, we will verify that the required IAM roles for service accounts are properly set up in your Amazon EKS cluster. These roles are crucial for enabling smooth interaction between AWS services and Kubernetes, so you can make use of AWS capabilities within your pods. Since batch workloads are typically stored in private container registries, we will create a service account specifically for Amazon ECR.

Make sure the required service accounts for this tutorial are correctly set up in your cluster:

```
kubectl get sa -A | egrep "efs-csi-controller|ecr"
```

The expected output should look like this:

```
default           ecr-sa                               0         31m
kube-system       efs-csi-controller-sa                0         30m
```

Optionally, if you do **not** already have these service accounts set up, or you receive an error, the following commands will create the service accounts. Note that you must have an [OpenID Connect (OIDC) endpoint](https://docs.aws.amazon.com/eks/latest/userguide/enable-iam-roles-for-service-accounts.html?sc_channel=el&sc_campaign=appswave&sc_content=eks-cluster-load-balancer-ipv4&sc_geo=mult&sc_country=mult&sc_outcome=acq) associated with your cluster before you run these commands.

1. To create a Kubernetes service account for Amazon ECR:

```
eksctl create iamserviceaccount \
 --profile isengard \
 --region ${CLUSTER_REGION} \
 --name ecr-sa \
 --namespace default \
 --cluster batch-quickstart \
 --attach-policy-arn arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly \
 --approve
```

The EFS CSI Driver does not have an AWS managed policy, so there are a few additional steps to create the service account. For instructions, see [Designing Scalable and Versatile Storage Solutions on Amazon EKS with the Amazon EFS CSI](https://quip-amazon.com/KQAIAANyMa13).

## Step 3: Verify the EFS CSI Driver Add-On Is Installed

In this section, we'll verify that the EFS CSI Driver managed add-on is properly installed and active on your Amazon EKS cluster. The EFS CSI Driver is crucial for enabling Amazon EFS to work seamlessly with Kubernetes, allowing you to mount EFS file systems as persistent volumes for your batch workloads.

1. Check that the EFS CSI driver is installed:

```
eksctl get addon --cluster ${CLUSTER_NAME} --region ${CLUSTER_REGION} | grep efs
```

The expected output should look like this:

```
aws-efs-csi-driver      v1.5.8-eksbuild.1       ACTIVE  0
```

If the EFS CSI Driver Add-On is **not** installed on your cluster, see [Designing Scalable and Versatile Storage Solutions on Amazon EKS with the Amazon EFS CSI](https://quip-amazon.com/KQAIAANyMa13).

## Step 4: Run the Sample Batch Application

In this section, we'll delve into the sample batch application that's part of this tutorial. This Python-based batch processing app serves as a practical example to demonstrate how you can read, process, and write data in batches. It reads data from an `input.csv` file, performs data manipulation using randomization for demonstration, and writes the processed data back to an `output.csv` file. This serves as a hands-on introduction before we deploy this application to Amazon ECR and EKS.

1. Create a Python script named `batch_processing.py` and paste the following contents:

```
import csv
import time
import random

def read_csv(file_path):
   with open(file_path, 'r') as f:
       reader = csv.reader(f)
       data = [row for row in reader]
   return data

def write_csv(file_path, data):
   with open(file_path, 'w', newline='') as f:
       writer = csv.writer(f)
       writer.writerows(data)

def process_data(data):
   processed_data = [["ID", "Value", "ProcessedValue"]]
   for row in data[1:]:
       id, value = row
       processed_value = float(value) * random.uniform(0.8, 1.2)
       processed_data.append([id, value, processed_value])
   return processed_data

def batch_task():
   print("Starting batch task...")
  
   # Read data from CSV
   input_data = read_csv('input.csv')
  
   # Process data
   processed_data = process_data(input_data)
  
   # Write processed data to CSV
   write_csv('output.csv', processed_data)
  
   print("Batch task completed.")

if __name__ == "__main__":
   batch_task()
```

2. In the same directory as your Python script, create a file named `input.csv` and paste the following contents:

```
ID,Value
1,100.5
2,200.3
3,150.2
4,400.6
5,300.1
6,250.4
7,350.7
8,450.9
9,500.0
10,600.8
```

3. Run the Python script:

```
`python3 batch_processing.py`
```

The expected output should look like this:

```
`Starting batch task...`
`Batch task completed.`
```

Additionally, an `output.csv` file will be generated, containing the processed data with an additional column for the processed values:

```
ID,Value,ProcessedValue
1,100.5,101.40789448456849
2,200.3,202.2013222517103
3,150.2,139.82822974457673
4,400.6,470.8262553815611
5,300.1,253.4504054915937
6,250.4,219.48492376021267
7,350.7,419.3203869922816
8,450.9,495.56898757853986
9,500.0,579.256459785631
10,600.8,630.4063443182313
```

## Step 5: Preparing and Deploying the Batch Container

In this section, we’ll build a container from the ground up and store it in a private ECR repository. This section guides you through the process of packaging your batch processing application in a container and uploading it to Amazon's Elastic Container Registry (ECR). Upon completing this section, you'll have a Docker container image securely stored in a private ECR repository, primed for deployment on EKS.

1. In the same directory as the other files you created, create a `Dockerfile` and paste the following contents:

```
FROM python:3.8-slim

COPY batch_processing.py /
COPY input.csv /

CMD ["python", "/batch_processing.py"] 
```

2. Build the Docker image:

```
docker build -t batch-processing-image .
```

3. Create a new private Amazon ECR repository:

```
aws ecr create-repository --repository-name batch-processing-repo --region ${CLUSTER_REGION}
```

4. Authenticate the Docker CLI to your Amazon ECR registry:

```
aws ecr get-login-password --region ${CLUSTER_REGION} | docker login --username AWS --password-stdin ${ACCOUNT_ID}.dkr.ecr.${CLUSTER_REGION}.amazonaws.com
```

5. Tag your container image for the ECR repository:

```
docker tag batch-processing-image:latest ${ACCOUNT_ID}.dkr.ecr.${CLUSTER_REGION}.amazonaws.com/batch-processing-repo:latest
```

6. Push the tagged image to the ECR repository:

```
docker push ${ACCOUNT_ID}.dkr.ecr.${CLUSTER_REGION}.amazonaws.com/batch-processing-repo:latest
```

## Step 6: Create the Multi-Architecture Image

To ensure that your batch application can be deployed across various hardware architectures, like within your Kubernetes cluster, it's vital to create a multi-architecture container image. This step leverages Docker's [buildx](https://docs.docker.com/engine/reference/commandline/buildx/) tool to accomplish this. By the end of this section, you will have successfully built and pushed a multi-architecture container image to Amazon ECR, making it accessible for deployment on your Amazon EKS cluster.

1. Create and start new builder instances for the batch service:

```
docker buildx create --name batchBuilder
docker buildx use batchBuilder
docker buildx inspect --bootstrap
```

2. Build and push the images for your batch service to Amazon ECR:

```
docker buildx build --platform linux/amd64,linux/arm64 -t ${ACCOUNT_ID}.dkr.ecr.${CLUSTER_REGION}.amazonaws.com/batch-processing-repo:latest . --push
```

3. Verify that the multi-architecture image is in the ECR repository:

```
aws ecr list-images --repository-name batch-processing-repo --region ${CLUSTER_REGION}
```

## Step 7: Deploy the Kubernetes Job

In this section, we'll transition to deploying your containerized batch processing application as a Kubernetes Job on your Amazon EKS cluster. Your batch tasks, encapsulated in a container and stored in a private ECR repository, will now be executed in a managed, scalable environment within EKS. 

1. Get the details of your ECR URL:

```
echo ${ACCOUNT_ID}.dkr.ecr.${CLUSTER_REGION}.amazonaws.com/batch-processing-repo:latest
```

2. Create a Kubernetes Job manifest file named `batch-job.yaml` and paste the following contents. Replace the sample value in `image` with your ECR URL.

```
apiVersion: batch/v1
kind: Job
metadata:
  name: my-batch-processing-job
spec:
  template:
    spec:
      serviceAccountName: ecr-sa   
      containers:
      - name: batch-processor
        image: 985866617021.dkr.ecr.us-west-1.amazonaws.com/batch-processing-repo:latest
      restartPolicy: Never
```

3. Apply the Job manifest to your EKS cluster:

```
kubectl apply -f batch-job.yaml
```

The expected output should look like this:

```
job.batch/batch-processing-job created
```

4. Monitor the Job execution:

```
kubectl get jobs
```

The response output should show that the jobs have completed:

```
NAME                      COMPLETIONS   DURATION   AGE
my-batch-processing-job   1/1           8s         11s
```

## Step 8: Enable Permissions for Batch Processing Jobs on SQS

In this section, you'll dive into the orchestration of batch processing jobs in a Kubernetes cluster, leveraging Amazon SQS as a job queue. Additionally, you'll learn how to extend the permissions of an existing Kubernetes service account. In our case, we'll annotate the Amazon ECR service account to include Amazon SQS access, thereby creating a more versatile and secure environment for your batch jobs. 

1. Create an Amazon SQS queue that will serve as our job queue:

```
aws sqs create-queue --queue-name eks-batch-job-queue
```

You should see the following response output. Save the URL of the queue for subsequent steps.

```
{
 "QueueUrl": "https://sqs.us-west-1.amazonaws.com/985866617021/eks-batch-job-queue"
}
```

2. Annotate the existing Amazon ECR service account with Amazon SQS permissions.

```
eksctl create iamserviceaccount \
  --region ${CLUSTER_REGION} \
  --cluster batch-quickstart \
  --namespace default \
  --name ecr-sa \
  --attach-policy-arn arn:aws:iam::aws:policy/AmazonSQSFullAccess \
  --override-existing-serviceaccounts \
  --approve
```

## Step 9: Create a Kubernetes Secret

In this section, we’ll create a Kubernetes secret to ensure our pods have access to our private Amazon ECR repository. This is a critical step because it ensures that your Kubernetes cluster can pull the necessary container images from your private ECR repository. Now, you might be wondering whether this ECR secret will survive pod restarts, especially considering that ECR tokens are only valid for 12 hours. Kubernetes will automatically refresh the secret when it nears expiration, ensuring uninterrupted access to your private ECR repository.

1. Generate an Amazon ECR authorization token:

```
ECR_TOKEN=$(aws ecr get-login-password --region ${CLUSTER_REGION})
```

2. Create the Kubernetes Secret called “regcred” in the "default" namespace:

```
kubectl create secret docker-registry regcred \
--docker-server=${ACCOUNT_ID}.dkr.ecr.${CLUSTER_REGION}.amazonaws.com \
--docker-username=AWS \
--docker-password="${ECR_TOKEN}" \
-n default
```

The expected output should look like this:

```
secret/regcred created
```

## Step 10: Deploy the Kubernetes Job With Queue Integration

In this section, you'll orchestrate a Kubernetes Job that is tightly integrated with an Amazon SQS queue. This integration is crucial for handling batch processing tasks in a more distributed and scalable manner. By leveraging SQS, you can decouple the components of a cloud application to improve scalability and reliability. You'll start by creating a Kubernetes Job manifest that includes environment variables for the SQS queue URL. This ensures that your batch processing application can interact with the SQS queue to consume messages and possibly trigger more complex workflows. 

1. Create a Kubernetes Job manifest file named `batch-job-queue.yaml` and paste the following contents. Replace the sample values for `image` with your ECR URL and `value` with your SQS queue URL.

```
apiVersion: batch/v1
kind: Job
metadata:
 name: batch-processing-job-with-queue
spec:
 template:
   spec:
     containers:
     - name: batch-processor
       image: 985866617021.dkr.ecr.us-west-1.amazonaws.com/batch-processing-repo:latest
       env:
       - name: SQS_QUEUE_URL
         value: "https://sqs.us-west-1.amazonaws.com/985866617021/eks-batch-job-queue"
     restartPolicy: Never
     serviceAccountName: ecr-sa
     imagePullSecrets:
        - name: regcred
```

2. Apply the Job manifest to your EKS cluster:

```
kubectl apply -f batch-job-queue.yaml
```

The expected output should look like this:

```
job.batch/batch-processing-job-with-queue created
```

3. Monitor the Job execution:

```
kubectl get jobs
```

When the Job is completed, you'll see the completion status in the output:

```
NAME                              COMPLETIONS   DURATION   AGE
batch-processing-job-with-queue   1/1           8s         13s
my-batch-processing-job           1/1           8s         16m
```

**Congratulations!** You've successfully deployed a batch processing job to your EKS cluster with an integrated Amazon SQS job queue. This setup allows you to manage and scale your batch jobs more effectively, leveraging the full power of Amazon EKS and AWS services.

## Step 11: Create the PersistentVolume and PersistentVolumeClaim for EFS

In this section, you'll create a PersistentVolume (PV) and PersistentVolumeClaim (PVC) that will use the EFS storage class. This will provide a persistent storage layer for your Kubernetes Jobs. This builds upon the previous tutorial at [Designing Scalable and Versatile Storage Solutions on Amazon EKS with the Amazon EFS CSI](https://quip-amazon.com/KQAIAANyMa13), where you set up environment variables for your EFS URL.

1. Echo and save your EFS URL for the next step:

```
echo $FILE_SYSTEM_ID.efs.$CLUSTER_REGION.amazonaws.com
```

2. Create a YAML file named `batch-pv-pvc.yaml` and paste the following contents. Replace the sample value for `server` with your EFS URL.

```
apiVersion: v1
kind: PersistentVolume
metadata:
  name: efs-pv
spec:
  capacity:
    storage: 5Gi
  volumeMode: Filesystem
  accessModes:
    - ReadWriteMany
  persistentVolumeReclaimPolicy: Retain
  storageClassName: efs-sc
  nfs:
    path: /
    server: fs-0ff53d77cb74d6474.efs.us-east-1.amazonaws.com
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: efs-claim
spec:
  storageClassName: efs-sc
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: 5Gi
```

3. Apply the PV and PVC to your Kubernetes cluster:

```
kubectl apply -f batch-pv-pvc.yaml
```

The expected output should look like this:

```
persistentvolume/efs-pv created
persistentvolumeclaim/efs-claim created
```

## Step 12: Implement Persistent Storage With Amazon EFS

In this section, you'll enhance your Kubernetes Jobs to use Amazon EFS for persistent storage. Building on the previous tutorial at [Designing Scalable and Versatile Storage Solutions on Amazon EKS with the Amazon EFS CSI](https://quip-amazon.com/KQAIAANyMa13), where you set up an EFS-based 'StorageClass,' you'll add a Persistent Volume Claim (PVC) to your existing Job manifests. Due to the immutable nature of Jobs, you'll also adopt a versioning strategy. Instead of updating existing Jobs, you'll create new ones with different names but similar specs, allowing for historical tracking and version management through labels and annotations.

1. Create a Kubernetes Job manifest file named `update-batch-job.yaml` and paste the following contents. Replace the sample value in `image` with your ECR URL.

```
apiVersion: batch/v1
kind: Job
metadata:
  name: new-batch-job
  namespace: default
spec:
  template:
    spec:
      serviceAccountName: ecr-sa
      containers:
      - name: batch-processor
        image: 985866617021.dkr.ecr.us-west-1.amazonaws.com/batch-processing-repo:latest
        volumeMounts:
        - name: efs-volume
          mountPath: /efs
      volumes:
      - name: efs-volume
        persistentVolumeClaim:
          claimName: efs-claim
      restartPolicy: OnFailure
```

2. Apply the Job manifest to your EKS cluster:

```
kubectl apply -f update-batch-job.yaml
```

3. Create a Kubernetes Job Queue manifest file named `update-batch-job-queue.yaml` and paste the following contents. Replace the sample values for `image` with your ECR URL and `value` with your SQS queue URL.

```
apiVersion: batch/v1
kind: Job
metadata:
  name: new-batch-processing-job-queue
  namespace: default
spec:
  template:
    spec:
      containers:
      - name: batch-processor
        image: 985866617021.dkr.ecr.us-west-1.amazonaws.com/batch-processing-repo:latest
        env:
        - name: SQS_QUEUE_URL
          value: "https://sqs.us-west-1.amazonaws.com/985866617021/eks-batch-job-queue"
        volumeMounts:
        - name: efs-volume
          mountPath: /efs
      volumes:
      - name: efs-volume
        persistentVolumeClaim:
          claimName: efs-claim
      restartPolicy: OnFailure
      serviceAccountName: ecr-sa
      imagePullSecrets:
        - name: regcred
```

4. Apply the Job Queue manifest to your EKS cluster:

```
kubectl apply -f update-batch-job-queue.yaml
```

You can watch the logs of the job to see it processing the batch task:

```
kubectl logs -f new-batch-job-k267b
```

The expected output should look like this:

```
Starting batch task...
Batch task completed.
```

## Clean Up

After finishing with this tutorial, for better resource management, you may want to delete the specific resources you created.

```
# Delete the SQS Queue
aws sqs delete-queue --queue-url YOUR_SQS_QUEUE_URL

# Delete the ECR Repository
aws ecr delete-repository --repository-name YOUR_ECR_REPO_NAME --force
```

If you enjoyed this tutorial, found any issues, or have feedback for us, <a href="https://www.pulse.aws/survey/Z8XBGQEL" target="_blank">please send it our way!</a>

## Conclusion
You've successfully orchestrated batch processing tasks in your Amazon EKS cluster using Amazon SQS and EFS! You've not only integrated SQS as a robust job queue but also leveraged the EFS CSI Driver for persistent storage across multiple nodes. This tutorial has walked you through the setup of your Amazon EKS cluster, the deployment of a Python-based batch processing application, and its containerization and storage in Amazon ECR. You've also learned how to create multi-architecture images and deploy them as Kubernetes Jobs. Furthermore, you've extended the capabilities of your Kubernetes Jobs by integrating them with Amazon SQS and providing persistent storage through Amazon EFS. 

To continue your journey, setup the [Cluster Autoscaler](https://github.com/kubernetes/autoscaler/tree/master/cluster-autoscaler) for dynamic scaling, or explore [EFS Lifecycle Management](https://docs.aws.amazon.com/efs/latest/ug/lifecycle-management-efs.html) to automate moving files between performance classes or enabling [EFS Intelligent-Tiering](https://docs.aws.amazon.com/efs/latest/ug/intelligent-tiering.html) to optimize costs.

