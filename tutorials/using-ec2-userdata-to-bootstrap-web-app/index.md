---
title: "Bootstrapping an EC2 instance using user-data to run a Python web app"
description: "Installing Nginx, uWSGI, and Python on an EC2 instance when it boots the first time using user-data."
tags:
    - aws
    - tutorial
    - ec2
    - cdk
authorGithubAlias: cobusbernard
authorName: Cobus Bernard
date: 2023-01-03
---

Setting up and configuring the packages required to run a Python web app using [Nginx](https://www.nginx.com/) and [uWSGI](https://uwsgi-docs.readthedocs.io/en/latest/) on a server can be time consuming and error prone when done manually. EC2 instances have ability to run [user data](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/user-data.html) scripts when it starts up, and you can automate creating the all the infrastructure along with these scripts using [CDK](https://docs.aws.amazon.com/cdk/api/v2/) to configure your instance when it first boots. In this tutorial, **you will learn** to:

- Create an AWS CDK stack with an Amazon EC2 instance, a security group with inbound access, and an IAM instance profile.
- Install software packages on the EC2 instance's first launch by creating a user data asset.
- Configure the software packages after installation using a script downloaded by the user data.
- Deploying the application using user data.

| Attributes             |                                                                 |
|------------------------|-----------------------------------------------------------------|
| ✅ AWS experience      | Beginner                                                        |
| ⏱ Time to complete    | 30 minutes                                                      |
| 💰 Cost to complete    | [Free tier](https://aws.amazon.com/free/) eligible                                               |
| 🧩 Prerequisites       | - [AWS Account](https://portal.aws.amazon.com/billing/signup#/start/email)<br>-CDK installed: Visit [Get Started with AWS CDK](https://aws-preview.aka.amazon.com/getting-started/guides/setup-cdk/) to learn more.  |

## Table of Contents

| ToC |
|-----|

## Introduction

Before we deploy the web application, we need to create an Amazon EC2 instance and supporting resources to run it. In this tutorial, we'll create a new AWS CDK app to create our infrastructure, install the dependencies for our web app, allow access to it, and finally deploy it.

First, let's check if our CDK version is up to date - this guide is based on v2 of the CDK, if you are still using v1, please read through the [migration docs](https://docs.aws.amazon.com/cdk/v2/guide/migrating-v2.html). To check the version, run the following:

```bash
cdk --version

# 2.35.0 (build 85e2735)
```

If you see output showing `1.x.x`, or you just want to ensure you are on the lastest version, run the following:

```bash
npm install -g aws-cdk
```

We will now create the skeleton CDK application using TypeScript as our language of choice:

```bash
mkdir ec2-cdk
cd ec2-cdk
cdk init app --language typescript

# Output:

Applying project template app for typescript
# Welcome to your CDK TypeScript project

This is a blank project for CDK development with TypeScript.

The `cdk.json` file tells the CDK Toolkit how to execute your app.

## Useful commands

* `npm run build`  compile typescript to js
* `npm run watch`  watch for changes and compile
* `npm run test` perform the jest unit tests
* `cdk deploy` deploy this stack to your default AWS account/region
* `cdk diff` compare deployed stack with current state
* `cdk synth`  emits the synthesized CloudFormation template

Initializing a new git repository...
Executing npm install...
npm WARN deprecated w3c-hr-time@1.0.2: Use your platform's native performance.now() and performance.timeOrigin.
npm notice 
npm notice New patch version of npm available! 8.19.2 → 8.19.3
npm notice Changelog: https://github.com/npm/cli/releases/tag/v8.19.3
npm notice Run npm install -g npm@8.19.3 to update!
npm notice 
✅ All done!
```

### Create the code for the resource stack

CDK uses the folder name for the files it generates. For this guide, we will be using `ec2-cdk`, if you named your directory differently, please replace this with the folder name you used. To start adding infrastructure, go to the file `lib/ec2-cdk-stack.ts`. This is where we will write the code for the resource stack you are going to create.

A resource stack is a set of cloud infrastructure resources (in your particular case, they will be all AWS resources) that will be provisioned into a specific account. The account and Region where these resources are provisioned, can be configured in the stack - we will cover this later on.

In this resource stack, you are going to create the following resources:

- IAM role: This role will be assigned to the EC2 instance to allow it to call other AWS services.
- EC2 instance: The virtual machine you will use to host your web application.
- Security group: The virtual firewall to allow inbound requests to your web application.
- EC2 SSH key pair: A set of credentials you can use to SSH to the instance to execute commands to set everything up.

### Create the EC2 instance

To start creating the EC2 instance, and other resources, you first need to import the [CDK Constructs](https://docs.aws.amazon.com/cdk/v2/guide/constructs.html) and [EC2 Key pair](https://docs.aws.amazon.com/cdk/api/v1/docs/@aws-cdk_aws-ec2.CfnKeyPair.html) libraries. Run the following command in the `ec2-cdk` folder to install the libraries:

```bash
npm i aws-cdk-lib cdk-ec2-key-pair
```

To use these libraries, we need to import them into our CDK project. Open `lib/ec2-cdk-stack.ts` to add the dependencies at the top of the file below the existing import statement (you can remove the commented out line for `aws-sqs`):

```typescript
import * as ec2 from 'aws-cdk-lib/aws-ec2'; 
import * as iam from 'aws-cdk-lib/aws-iam';
import * as s3assets from 'aws-cdk-lib/aws-s3-assets'; 
import * as keypair from 'cdk-ec2-key-pair';
import * as path from 'path';
```

During the course of this tutorial, there will be code checkpoints where we show what the full file should look like at that point. We do recommend following step by step by typing out or copy/pasting the sample code blocks to ensure you understand what each part is responsible for.

These modules provide access to all the components you need for you to deploy the web application. The first step is to find the existing default [VPC](https://docs.aws.amazon.com/vpc/) in your account by adding the following code below the placeholder comment:

```typescript
// The code that defines your stack goes here
      
      // Look up the default VPC
      const vpc = ec2.Vpc.fromLookup(this, "VPC", {
        isDefault: true
      });
```

Using the `cdk-ec2-key-pair` package, we will create an SSH key pair and store it in AWS Secrets Manager so we can download it later to be able to SSH to the instance.

```typescript
      // Create a key pair to be used with this EC2 Instance
      const key = new keypair.KeyPair(this, "KeyPair", {
        name: "cdk-keypair",
        description: "Key Pair created with CDK Deployment",
      });
      key.grantReadOnPublicKey; 
```

We also need to be able to access our instance via 2 ports: 22 and 80. SSH uses port 22, and we will serve the web app via port 80 (http). To allow access, we need to set up firewall rules to allow traffic to these 2 ports by creating a [security group](https://docs.aws.amazon.com/vpc/latest/userguide/VPC_SecurityGroups.html). Note that SSH access from all IP addresses is acceptable for a short time in a test environment, but not recommended for production environments. We will also create an [IAM role](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles.html) for the EC2 instance to allow it to call other AWS services, and attach a pre-built policy to read configurations out of AWS Secrets Manager (where the SSH public key will be stored):

```typescript
      // Security group for the EC2 instance
      const securityGroup = new ec2.SecurityGroup(this, "EC2-Python-App", {
        vpc,
        description: "Allow SSH (TCP port 22) and HTTP (TCP port 80) in",
        allowAllOutbound: true,
      });

      // Allow SSH access on port tcp/22
      securityGroup.addIngressRule(
        ec2.Peer.anyIpv4(),
        ec2.Port.tcp(22),
        "Allow SSH Access"
      );

      // Allow HTTP access on port tcp/80
      securityGroup.addIngressRule(
        ec2.Peer.anyIpv4(),
        ec2.Port.tcp(80),
        "Allow HTTP Access"
      );

      // IAM role to allow access to other AWS services
      const role = new iam.Role(this, "ec2Role", {
        assumedBy: new iam.ServicePrincipal("ec2.amazonaws.com"),
      });

      // IAM policy attachment to allow access to 
      role.addManagedPolicy(
        iam.ManagedPolicy.fromAwsManagedPolicyName("AmazonSSMManagedInstanceCore")
      );
```

We are now ready to create the EC2 instance using a pre-built [Amazon Machine Image](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/AMIs.html) (AMI - pronounced "Ay-Em-Eye") - for this guide, we will be using the [Amazon Linux 2](https://aws.amazon.com/amazon-linux-2/) one for X86_64 CPU architecture. We will also pass the IAM role you created, the default VPC, and the instance type to run on, in your case, a `t2.micro` that has 1 vCPU and 1GB of memory. If you are running this tutorial in one of the newer AWS regions, the `t2.micro` type may not be available, please use the `t3.micro` one. To view all the different instance types, see the [EC2 instance types page](https://aws.amazon.com/ec2/instance-types/).

```typescript
      // Look up the AMI Id for the Amazon Linux 2 Image with CPU Type X86_64
      const ami = new ec2.AmazonLinuxImage({
        generation: ec2.AmazonLinuxGeneration.AMAZON_LINUX_2,
        cpuType: ec2.AmazonLinuxCpuType.X86_64,
      });

      // Create the EC2 instance using the Security Group, AMI, and KeyPair defined.
      const ec2Instance = new ec2.Instance(this, "Instance", {
        vpc,
        instanceType: ec2.InstanceType.of(
          ec2.InstanceClass.T2,
          ec2.InstanceSize.MICRO
        ),
        machineImage: ami,
        securityGroup: securityGroup,
        keyName: key.keyPairName,
        role: role,
      });
```

We have now defined our AWS CDK stack to create an EC2 instance, a security group with inbound access rules, and an IAM role, attached to the EC2 instance as an IAM instance profile. Before deploying the stack, we still need to install the packages on the host OS to run your application, and also copy our sample application code to the instance.

### Checkpoint 1

Your `lib/ec2-cdk-stack.ts` file should now look like this:
```typescript
import * as cdk from 'aws-cdk-lib';
import { Construct } from 'constructs';

import * as ec2 from 'aws-cdk-lib/aws-ec2'; 
import * as iam from 'aws-cdk-lib/aws-iam';
import * as s3assets from 'aws-cdk-lib/aws-s3-assets'; 
import * as keypair from 'cdk-ec2-key-pair';
import * as path from 'path';

export class Ec2CdkStack extends cdk.Stack {
  constructor(scope: Construct, id: string, props?: cdk.StackProps) {
    super(scope, id, props);

      // Look up the default VPC
      const vpc = ec2.Vpc.fromLookup(this, "VPC", {
        isDefault: true
      });

      // Create a key pair to be used with this EC2 Instance
      const key = new keypair.KeyPair(this, "KeyPair", {
        name: "cdk-keypair",
        description: "Key Pair created with CDK Deployment",
      });
      key.grantReadOnPublicKey; 

      // Security group for the EC2 instance
      const securityGroup = new ec2.SecurityGroup(this, "EC2-Python-App", {
        vpc,
        description: "Allow SSH (TCP port 22) and HTTP (TCP port 80) in",
        allowAllOutbound: true,
      });

      // Allow SSH access on port tcp/22
      securityGroup.addIngressRule(
        ec2.Peer.anyIpv4(),
        ec2.Port.tcp(22),
        "Allow SSH Access"
      );

      // Allow HTTP access on port tcp/80
      securityGroup.addIngressRule(
        ec2.Peer.anyIpv4(),
        ec2.Port.tcp(80),
        "Allow HTTP Access"
      );

      // IAM role to allow access to other AWS services
      const role = new iam.Role(this, "ec2Role", {
        assumedBy: new iam.ServicePrincipal("ec2.amazonaws.com"),
      });

      // IAM policy attachment to allow access to 
      role.addManagedPolicy(
        iam.ManagedPolicy.fromAwsManagedPolicyName("AmazonSSMManagedInstanceCore")
      );

      // Look up the AMI Id for the Amazon Linux 2 Image with CPU Type X86_64
      const ami = new ec2.AmazonLinuxImage({
        generation: ec2.AmazonLinuxGeneration.AMAZON_LINUX_2,
        cpuType: ec2.AmazonLinuxCpuType.X86_64,
      });

      // Create the EC2 instance using the Security Group, AMI, and KeyPair defined.
      const ec2Instance = new ec2.Instance(this, "Instance", {
        vpc,
        instanceType: ec2.InstanceType.of(
          ec2.InstanceClass.T2,
          ec2.InstanceSize.MICRO
        ),
        machineImage: ami,
        securityGroup: securityGroup,
        keyName: key.keyPairName,
        role: role,
      });
  }
}

```

## Adding user data to your EC2 instance

We will be using an existing sample Python web app that also includes the required scripts to install the dependencies on the instance to run it. Download a copy to your `ec2-cdk` folder using the following `git` command:

```bash
git clone https://github.com/build-on-aws/sample-pyton-web-app
```

The sample web application hosted in the `sample-pyton-web-app` folder is a Python application that we will be deploying. It requires Nginx and uWSGI to run. To install these components, we need to follow a number of steps. First, we need to install all the OS packages, then configure Nginx and uWSGI, ensure they are are running, and copy the sample application to the instance. A bash script file that configures all of these setup steps is provided in `sample-pyton-web-app/configure_amz_linux_sample_app.sh`. Have a look at the steps in it if you want to know more about how the instance is configured.

To deploy the web application, we need to add code to our CDK application that will copy the configuration files and scripts to a location that the instance has access to, along with the sample app code - we will use S3 for this. To do so, add the following code in `lib/ec2-cdk-stack.ts` below the previous code:

```typescript
      // Use an asset to allow uploading files to S3, and then download it to the EC2 instance as part of the user data

      // --- Sample App ---
      // Upload the sample app to S3
      const sampleAppAsset = new s3assets.Asset(this, "SampleAppAsset", {
        path: path.join(__dirname, "../sample-python-web-app"),
      });

      // Allow EC2 instance to read the file
      sampleAppAsset.grantRead(role);

      // Download the file from S3, and store the full location and filename as a variable
      const sampleAppFilePath = ec2Instance.userData.addS3DownloadCommand({
        bucket: sampleAppAsset.bucket,
        bucketKey: sampleAppAsset.s3ObjectKey,
      });

      // --- Sample App ---

      // --- Configuration Script ---
      // Upload the configuration file to S3
      const configScriptAsset = new s3assets.Asset(this, "ConfigScriptAsset", {
        path: path.join(__dirname, "../sample-python-web-app/configure_amz_linux_sample_app.sh"),
      });

      // Allow EC2 instance to read the file
      configScriptAsset.grantRead(ec2Instance.role);

      // Download the file from S3, and store the full location and filename as a variable
      const configScriptFilePath = ec2Instance.userData.addS3DownloadCommand({
        bucket: configScriptAsset.bucket,
        bucketKey: configScriptAsset.s3ObjectKey,
      });

      // Add a line to the user data to execute the downloaded script file
      ec2Instance.userData.addExecuteFileCommand({
        filePath: configScriptFilePath,
        arguments: sampleAppFilePath,
      });

      // --- Configuration Script ---

```

There is one more step before we can deploy everything: adding output to the CDK stack to print out the command to download the SSH key, SSH command to connect to the instance, and IP address to access the instance on. In the infrastructure above, you created an SSH key, and stored it in AWS Secrets Manager. To print out these outputs, add the following to the bottom of the CDK app:

```typescript
      // Create outputs for connecting

      // Output the public IP address of the EC2 instance
      new cdk.CfnOutput(this, "IP Address", {
        value: ec2Instance.instancePublicIp,
      });

      // Command to download the SSH key
      new cdk.CfnOutput(this, "Download Key Command", {
        value:
          "mkdir -p ~/.ssh \
          && aws secretsmanager get-secret-value \
            --secret-id ec2-ssh-key/cdk-keypair/private \
            --query SecretString \
            --output text > ~/.ssh/ec2-cdk-key.pem \
            && chmod 600 ~/.ssh/ec2-cdk-key.pem",
      });

      // Command to access the EC2 instance using SSH
      new cdk.CfnOutput(this, "Ssh Command", {
        value:
          "ssh -i ~/.ssh/cdk-key.pem -o IdentitiesOnly=yes ec2-user@" +
          ec2Instance.instancePublicIp,
      });
```

These three outputs will show you the following:

- How to download the SSH key to access the instance
- The public IP of the instance to use in your browser to see the Python web app running
- An SSH command to access the instance

We are now ready to deploy the stack.

### Checkpoint 2

We have now completed all code changes to our CDK app, and the `lib/ec2-cdk-stack.ts` file should look like this:

```typescript
import * as cdk from 'aws-cdk-lib';
import { Construct } from 'constructs';
// import * as sqs from 'aws-cdk-lib/aws-sqs';

import * as ec2 from 'aws-cdk-lib/aws-ec2'; 
import * as iam from 'aws-cdk-lib/aws-iam';
import * as s3assets from 'aws-cdk-lib/aws-s3-assets'; 
import * as keypair from 'cdk-ec2-key-pair';
import * as path from 'path';

export class Ec2CdkStack extends cdk.Stack {
  constructor(scope: Construct, id: string, props?: cdk.StackProps) {
    super(scope, id, props);

      // Look up the default VPC
      const vpc = ec2.Vpc.fromLookup(this, "VPC", {
        isDefault: true
      });

      // Create a key pair to be used with this EC2 Instance
      const key = new keypair.KeyPair(this, "KeyPair", {
        name: "cdk-keypair",
        description: "Key Pair created with CDK Deployment",
      });
      key.grantReadOnPublicKey; 

      // Security group for the EC2 instance
      const securityGroup = new ec2.SecurityGroup(this, "EC2-Python-App", {
        vpc,
        description: "Allow SSH (TCP port 22) and HTTP (TCP port 80) in",
        allowAllOutbound: true,
      });

      // Allow SSH access on port tcp/22
      securityGroup.addIngressRule(
        ec2.Peer.anyIpv4(),
        ec2.Port.tcp(22),
        "Allow SSH Access"
      );

      // Allow HTTP access on port tcp/80
      securityGroup.addIngressRule(
        ec2.Peer.anyIpv4(),
        ec2.Port.tcp(80),
        "Allow HTTP Access"
      );

      // IAM role to allow access to other AWS services
      const role = new iam.Role(this, "ec2Role", {
        assumedBy: new iam.ServicePrincipal("ec2.amazonaws.com"),
      });

      // IAM policy attachment to allow access to 
      role.addManagedPolicy(
        iam.ManagedPolicy.fromAwsManagedPolicyName("AmazonSSMManagedInstanceCore")
      );

      // Look up the AMI Id for the Amazon Linux 2 Image with CPU Type X86_64
      const ami = new ec2.AmazonLinuxImage({
        generation: ec2.AmazonLinuxGeneration.AMAZON_LINUX_2,
        cpuType: ec2.AmazonLinuxCpuType.X86_64,
      });

      // Create the EC2 instance using the Security Group, AMI, and KeyPair defined.
      const ec2Instance = new ec2.Instance(this, "Instance", {
        vpc,
        instanceType: ec2.InstanceType.of(
          ec2.InstanceClass.T2,
          ec2.InstanceSize.MICRO
        ),
        machineImage: ami,
        securityGroup: securityGroup,
        keyName: key.keyPairName,
        role: role,
      });

      // Use an asset to allow uploading files to S3, and then download it to the EC2 instance as part of the user data

      // --- Sample App ---
      // Upload the sample app to S3
      const sampleAppAsset = new s3assets.Asset(this, "SampleAppAsset", {
        path: path.join(__dirname, "../sample-python-web-app"),
      });

      // Allow EC2 instance to read the file
      sampleAppAsset.grantRead(role);

      // Download the file from S3, and store the full location and filename as a variable
      const sampleAppFilePath = ec2Instance.userData.addS3DownloadCommand({
        bucket: sampleAppAsset.bucket,
        bucketKey: sampleAppAsset.s3ObjectKey,
      });

      // --- Sample App ---

      // --- Configuration Script ---
      // Upload the configuration file to S3
      const configScriptAsset = new s3assets.Asset(this, "ConfigScriptAsset", {
        path: path.join(__dirname, "../sample-python-web-app/configure_amz_linux_sample_app.sh"),
      });

      // Allow EC2 instance to read the file
      configScriptAsset.grantRead(ec2Instance.role);

      // Download the file from S3, and store the full location and filename as a variable
      const configScriptFilePath = ec2Instance.userData.addS3DownloadCommand({
        bucket: configScriptAsset.bucket,
        bucketKey: configScriptAsset.s3ObjectKey,
      });

      // Add a line to the user data to execute the downloaded script file
      ec2Instance.userData.addExecuteFileCommand({
        filePath: configScriptFilePath,
        arguments: sampleAppFilePath,
      });

      // --- Configuration Script ---

      // Create outputs for connecting

      // Output the public IP address of the EC2 instance
      new cdk.CfnOutput(this, "IP Address", {
        value: ec2Instance.instancePublicIp,
      });

      // Command to download the SSH key
      new cdk.CfnOutput(this, "Download Key Command", {
        value:
          "mkdir -p ~/.ssh \
            && aws secretsmanager get-secret-value \
            --secret-id ec2-ssh-key/cdk-keypair/private \
            --query SecretString \
            --output text > ~/.ssh/ec2-cdk-key.pem \
            && chmod 600 ~/.ssh/ec2-cdk-key.pem",
      });

      // Command to access the EC2 instance using SSH
      new cdk.CfnOutput(this, "Ssh Command", {
        value:
          "ssh -i ~/.ssh/cdk-key.pem -o IdentitiesOnly=yes ec2-user@" +
          ec2Instance.instancePublicIp,
      });
  }
}
```

## Bootstrap CDK

Before we can deploy our CDK app, we need to configure CDK on the account you are deploying to. Edit the `bin/ec2-cdk.ts` and uncomment line 14:

```typescript
env: { account: process.env.CDK_DEFAULT_ACCOUNT, region: process.env.CDK_DEFAULT_REGION },
```

This will use the Account ID and Region configured in the AWS CLI - if you have not yet set this up, please follow [this tutorial section](https://aws.amazon.com/getting-started/guides/setup-environment/module-three/). We also need to bootstrap CDK in our account. This will create the required infrastructure for CDK to manage infrastructure in your account, and it only needs to be done once per account. If you have already done the bootstrapping, or are not sure, you can just run the command again. It will only bootstrap if needed. To bootstrap CDK, run `cdk bootstrap` (your account ID will be different from the placeholder ones below):

```bash
cdk bootstrap

#output
⏳  Bootstrapping environment aws://0123456789012/<region>...
✅  Environment aws://0123456789012/<region> bootstrapped
Deploying the stack
```

Once the bootstrapping has completed, we are ready to deploy all the infrastructure. Run the following:

```bash
cdk deploy
```

You will be presented with the following output and confirmation screen. Because there are security implications for our stack, you will see a summary of these and need to confirm them before deployment proceeds.

![CDK output showing infrastructure it will create, with a security confirmation to create the required IAM role.](./images/ec2-user-data-python-cdk.png)

Enter `y` to continue with the deployment and create the resources. The CLI will show the deployment progress, and in the end, the output we defined in our CDK app.

```bash
Do you wish to deploy these changes (y/n)? y
Ec2CdkStack: deploying...
[0%] start: Publishing afe67465ec62603d27d77795221a45e68423c87495467b0265ecdadad80bb5e2:current
[33%] success: Published afe67465ec62603d27d77795221a45e68423c87495467b0265ecdadad80bb5e2:current
[33%] start: Publishing 73887b77b71ab7247eaf6dc4647f03f9f1cf8f0da685460f489ec8f2106d480d:current
[66%] success: Published 73887b77b71ab7247eaf6dc4647f03f9f1cf8f0da685460f489ec8f2106d480d:current
[66%] start: Publishing 13138ebf2da51426144f6f5f4f0ad197787f52aad8b6ceb26ecff68d33cd2b78:current
[100%] success: Published 13138ebf2da51426144f6f5f4f0ad197787f52aad8b6ceb26ecff68d33cd2b78:current
Ec2CdkStack: creating CloudFormation changeset...

✅  Ec2CdkStack

Outputs:
Ec2CdkStack.DownloadKeyCommand = mkdir -p ~/.ssh \
  && aws secretsmanager get-secret-value \
  --secret-id ec2-ssh-key/cdk-keypair/private \
  --query SecretString \
  --output text > ~/.ssh/cdk-key.pem \
  && chmod 600 ~/.ssh/cdk-key.pem
Ec2CdkStack.IPAddress = 54.75.32.202
Ec2CdkStack.SshCommand = ssh -i ~/.ssh/cdk-key.pem -o IdentitiesOnly=yes ec2-user@54.75.32.202

Stack ARN:
arn:aws:cloudformation:eu-west-1:123456789012:stack/Ec2CdkStack/c8bde0b0-16ed-11ec-a147-0a4fed479a1b
```

Your infrastructure is now deployed, the instance is spinning up, and you can use the outputs at the bottom to download the SSH key, and then access the EC2 instance if you need to. You can also access the application in your browser by pasting in the IP printed above. You may need to wait a few minutes before the instance has completed spinning up and running the user data script. The first of these commands will be the same for every one:

```bash
mkdir -p ~/.ssh \
  && aws secretsmanager get-secret-value \
  --secret-id ec2-ssh-key/cdk-keypair/private \
  --query SecretString \
  --output text > ~/.ssh/cdk-key.pem \
  && chmod 600 ~/.ssh/cdk-key.pem
```

Let's go through each of the command steps. Firstly, the `\` at the end of the lines tells your shell that the command is split onto a new line, which is why we add it to the first 5 lines to make the command more readable. The first of the commands, `mkdir -p ~/.ssh` creates the directory `.ssh` in your OS user's home directory, and the `-p` indicates to create the directory with parents, and to not error if it already exists - this may be the first time you use SSH on your local machine, in which case the directory may not exist. What is meant by "with parents" is that if you would to create a new nested directory structure, e.g. `mkdir -p ~/something/very/nested/here`, it would create all the parent directories of `something`, with `very` in it, `nested` inside `very`, and `here` inside `nested` without you needing to run multiple `mkdir` commands. The second command uses the AWS CLI to call `secretsmanager` where we stored the SSH key to fetch it raw data, and we specify the `query` as `SecretString` to only bring back that field as `text`. We then use the `>` operator to tell our shell to take the output, and write it to the file `~/.ssh/cd-key.pem`, overwriting any existing content - if the file does not exist, it will be created, if it did, we will overwrite the contents. Lastly, the [`chmod`](https://en.wikipedia.org/wiki/Chmod) command limits who can access the file - SSH requires keys to be locked down, so we limit read and write access to our OS user only.

Once we have run this command, we can SSH to the instance by using the public IP address, specifying which SSH key to use with the `-i ~/.ssh/cdk-key.pem`, and to only offer that key to the server by specifying `-o IdentitiesOnly=yes` - there is quite a lot of detail in that parameter which we won't cover here, the short version is that if you have many SSH keys, the SSH server in your instance would reject your login attempt if too many incorrect keys were sent as it would try each of them in your `~/.ssh` directory with certain names.

Lastly, to access the Python web app we just deployed, use the `Ec2CdkStack.IPAddress` value in your browser as the address to open to see the app running.

## Cleaning up your AWS environment

You have now completed this tutorial, but we still need to clean up the resources created during this guide. If your account is still in the Free Tier, there will not be any monthly charges. Once out of the Free Tier, it will cost ~$9.45 USD per month, or $0.0126 USD per hour.

To remove all the infrastructure we created, use the `cdk destroy` command. This will only remove infrastructure created during this guide in our CDK application. You will see a confirmation:

```bash
cdk destroy

# Enter y to approve the changes and delete any stack resources.

Ec2CdkStack: destroying...

✅  Ec2CdkStack: destroyed
```

When the output shows `Ec2CdkStack: destroyed`, your resources have been removed. TODO! Add how to clean the bucket, and check if the secretmanager value was also delete.

## Conclusion

Congratulations! You have finished the Build a Web Application on Amazon EC2 tutorial using CDK to provision all infrastructure, and configure your EC2 instance to install and configure OS packages to run the sample Python web app.
