---
title: "Deploy a Container Web App on Amazon ECS using CodeCatalyst"
description: "Learn to build and deploy a container-based web application using Amazon Elastic Container Service and Amazon CodeCatalyst"
tags:
    - ecs
    - cdk
    - codecatalyst
    - ci-cd
    - tutorial
    - aws
authorGithubAlias: kowsalyajaganathan
authorName: Kowsalya Jaganathan
date: 2023-04-17
---

In this guide, you will learn how to deploy a containerized application on Amazon Elastic Container Service (Amazon ECS) using Amazon CodeCatalyst.

Amazon ECS is a fully managed container orchestration service that helps you easily deploy, manage, and scale containerized applications. It integrates with the rest of the AWS platform to provide a secure and easy-to-use solution for running container workloads in the cloud and now on your infrastructure with Amazon ECS Anywhere.

Amazon CodeCatalyst is an integrated DevOps service which you can leverage to plan, collaborate on code, build, test, and deploy applications with continuous integration and continuous delivery (CI/CD) tools. With all of these stages and aspects of an application’s lifecycle in one tool, you can deliver software quickly and confidently.
## What you will learn
In addition to learning about Amazon ECS and its various components, you will:

- Create the infrastructure to run your container with Amazon ECS
- Deploy a containerized application to Amazon ECS using Amazon CodeCatalyst



## Sections
<!-- Update with the appropriate values -->
| Info                | Level                                  |
| ------------------- | -------------------------------------- |
| ✅ AWS Level        | Beginner                               |
| ⏱ Time to complete  | 15-20 minutes                             |
| 💰 Cost to complete | Less than $0.02 USD if completed in under an hour.     |
| 🧩 Prerequisites    | - [AWS Account](https://portal.aws.amazon.com/billing/signup#/start/email) with administrator-level access*<br>- [CodeCatalyst Account](https://codecatalyst.aws) <br> [*]Accounts created within the past 24 hours might not yet have access to the services required for this tutorial.
| 💻 Code Sample         | Code sample used in tutorial on [GitHub](https://github.com/build-on-aws/automate-web-app-amazon-ecs-cdk-codecatalyst)                             |
| 📢 Feedback            | <a href="https://pulse.buildon.aws/survey/DEM0H5VW" target="_blank">Any feedback, issues, or just a</a> 👍 / 👎 ?    |
| ⏰ Last Updated     | 2023-04-17                             |
 
| ToC |
|-----|
<!-- Use the above to auto-generate the table of content. Only build out a manual one if there are too many (sub) sections. -->
## Prerequisites

Before starting this tutorial, you will need the following:

 - An AWS Account (if you don't yet have one, you can create one and [set up your environment here](https://aws.amazon.com/getting-started/guides/setup-environment/)).
 - CDK installed: Visit the Get Started with AWS CDK guide to learn more.
 - The example project code downloaded to extract the SampleApp.
 - Docker installed and running.
 - [CodeCatalyst](https://codecatalyst.aws/) Account and Space setup with Space administrator role assigned to you ( if you don't have a CodeCatalyst setup already, you can follow the [Amazon CodeCatlyst setting up guide](https://docs.aws.amazon.com/codecatalyst/latest/userguide/setting-up-topnode.html)).

## UNDERSTANDING ECS

The focus of this module is to introduce you to the concepts of Amazon ECS. We will cover the components of Amazon ECS (cluster, task definition, service), what orchestration is, and how to choose which type of compute to use to run your containers. If you are already familiar with Amazon ECS, you can skip ahead to **Module 2**.

### What is Amazon ECS?

Amazon ECS is a fully managed container orchestration service that helps you easily deploy, manage, and scale containerized applications. It integrates with the rest of the AWS platform to provide a secure and easy-to-use solution for running container workloads in the cloud and now on your infrastructure with [**Amazon ECS Anywhere**](https://aws.amazon.com/ecs/anywhere/). An orchestrator manages the lifecycle of your container, from deploying it, ensuring that it is healthy, replacing unhealthy nodes, and handling new deployments.  

### What are the components of ECS?

An Amazon ECS cluster is a logical construct that will group all the containers deployed into a cluster. There is no cost for a cluster, only for the compute and other infrastructure you use to run your containers. 

To launch a container, you provide a [**task definition**](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_definitions.html), which contains properties like the container image location, amount of CPU and memory, logging configuration, and many more. This does not launch a container; it just provides all the configuration needed to be able to run it—to launch it, you will define a [**service**](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs_services.html). 

In the service, you define how many copies of the container you want (or if you need it to run on every instance, a [**daemon**](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs_services.html#service_scheduler_daemon) that needs to run on every host, and ECS will handle the orchestration of it). To expose your services to the internet, you will need to set up an Application Load Balancer to forward requests to your service. Lastly, Amazon ECS can be configured to deploy across multiple Availability Zones (AZs), and will automatically balance the deployment across the number of AZs available and update the load balancer with details of each deployment to allow traffic to be routed to it. 

The following diagram shows what the infrastructure would look like:  

![ECS Infrastructure](images/ecs_infrastructure.png "ECS Infrastructure")


### Compute capacity planning, and options

Amazon ECS can schedule services to run on an EC2 host (virtual machine), or using AWS Fargate, a serverless compute engine for containers. When running containers, you need to account for capacity planning. As an example, if you have two hosts available in your cluster, each with 512MB of memory, the cluster will show a total of 1024MB of memory available, but you won't be able to launch a new container that requires more than 512MB of memory as there is no single host with enough memory. You can mitigate this by using capacity providers to automatically scale the cluster. 

Alternatively, you can use Fargate, which allows you to specify the CPU and memory requirements for each container, and then launches the required compute to run the container for you. The main difference between Fargate and EC2 hosts is that you do not need to set up, manage, or maintain the operating system on the host when using Fargate, nor do you need to do capacity planning as it will launch exactly the amount of capacity you need.

## CREATE INFRASTRUCTURE
In this module, you will create an AWS CDK application that will create all the necessary infrastructure to set up an Amazon ECS cluster, and deploy a sample container to it

### Create the CDK app

First, ensure you have CDK installed. If you do not have it installed, please follow the [**Get Started with AWS CDK**](/getting-started/guides/setup-cdk/) guide.  

```Bash
    cdk --version
```

We will now create the skeleton CDK application using TypeScript as our language of choice. Run the following commands in your terminal:  

```Bash
    mkdir cdk-ecs-infra
    cd cdk-ecs-infra
    cdk init app --language typescript
```

This will output the following:

```Bash
    Applying project template app for typescript
    # Welcome to your CDK TypeScript project
    
    This is a blank project for CDK development with TypeScript.
    
    The `cdk.json` file tells the CDK Toolkit how to execute your app.
    
    ## Useful commands
    
    * `npm run build`   compile typescript to js
    * `npm run watch`   watch for changes and compile
    * `npm run test`    perform the jest unit tests
    * `cdk deploy`      deploy this stack to your default AWS account/region
    * `cdk diff`        compare deployed stack with current state
    * `cdk synth`       emits the synthesized CloudFormation template
    
    Initializing a new git repository...
    hint: Using 'master' as the name for the initial branch. This default branch name
    hint: is subject to change. To configure the initial branch name to use in all
    hint: of your new repositories, which will suppress this warning, call:
    hint: 
    hint:   git config --global init.defaultBranch <name>
    hint: 
    hint: Names commonly chosen instead of 'master' are 'main', 'trunk' and
    hint: 'development'. The just-created branch can be renamed via this command:
    hint: 
    hint:   git branch -m <name>
    Executing npm install...
    npm WARN deprecated w3c-hr-time@1.0.2: Use your platform's native performance.now() and performance.timeOrigin.
    ✅ All done!
```    



#### Create the code for the resource stack

Go to the file **/lib/cdk-ecs-infra-stack.ts.** This is where you will write the code for the resource stack you are going to create.

A resource stack is a set of cloud infrastructure resources (in your particular case, they will all be AWS resources) that will be provisioned into a specific account. The account/Region where these resources are provisioned can be configured in the stack (as covered in the [**Get Started with AWS CDK**](/getting-started/guides/setup-cdk/) guide.

In this resource stack, you are going to create the following resources:

*   IAM role: This role will be assigned to the container to allow it to call other AWS services.
*   ECS Task definition: The specific parameters to use when launching the container.
*   ECS Pattern for Fargate load balanced service: This abstracts away the complexity of all the components required to create the cluster, load balancer, and service, and configures everything to work together.

#### Create the ECS cluster

Edit the **lib/cdk-eb-infra-stack.ts** file to add the dependency at the top of the file:  

```JavaScript
    import * as ec2 from "aws-cdk-lib/aws-ec2";
    import * as ecs from "aws-cdk-lib/aws-ecs";
    import * as ecs_patterns from "aws-cdk-lib/aws-ecs-patterns";
```

These modules provide access to all the components you need for you to deploy the web application. The first step is to find the existing default VPC in your account by adding the following code:  

```JavaScript
  // Look up the default VPC
    const vpc = ec2.Vpc.fromLookup(this, "VPC", {
       isDefault: true
    });
```

Next, you will need to define which container to use, and how it should be configured. This is done by creating a task definition to supply the container port, amount of CPU and memory it needs, and the container image to use. For this guide, we will be building an nginx container by using the publicly available nginx image and have CDK manage the build, upload, and deployment of the container for us. We will also be creating an IAM role to attach to the task definition and a ECR repository for future use when we deploy the sample application in next module.


To create the task definition and IAM role, add the following code:  

```JavaScript
        const repository = new ecr.Repository(this, 'My-Repository',{
        repositoryName: 'my-respository-cdkecsinfrastack'
        });

        const taskIamRole = new cdk.aws_iam.Role(this, "AppRole", {
          roleName: "AppRole",
          assumedBy: new cdk.aws_iam.ServicePrincipal('ecs-tasks.amazonaws.com'),
        });
       
        taskIamRole.addManagedPolicy(
        cdk.aws_iam.ManagedPolicy.fromAwsManagedPolicyName(
            "service-role/AmazonECSTaskExecutionRolePolicy"
        )
        );

        const taskDefinition = new ecs.FargateTaskDefinition(this, 'Task', {
          taskRole: taskIamRole,
          family : 'CdkEcsInfraStackTaskDef',
        });
    
        taskDefinition.addContainer('MyContainer', {
          image: ecs.ContainerImage.fromRegistry('nginx:latest'),
          portMappings: [{ containerPort: 80 }],
          memoryReservationMiB: 256,
          cpu: 256,
        });
```

In the code above, you can see that you specified a task definition type to deploy to Fargate by using FargateTaskDefintion, and by using ContainerImage.fromRegistry. CDK will use the Nginx container image from DockerHub

Next, you need to set up the Amazon ECS cluster, define a service, create a load balancer, configure it to connect to the service, and set up the required security group rules. A service in ECS is used to launch a task definition by specifying the number of copies you want, deployment strategies, and other configurations. For this example, we will only be launching one copy of the container. A security group acts as a virtual firewall for your instance to control inbound and outbound traffic, but you do not need to configure it because the ECS Pattern you are using will do that for you. 

Add the following code to your project below the task definition:  

```JavaScript
    new ecs_patterns.ApplicationLoadBalancedFargateService(this, "MyApp", {
          vpc: vpc,
          taskDefinition: taskDefinition,
          desiredCount: 1,
          serviceName: 'MyWebApp',
          assignPublicIp: true,
          publicLoadBalancer: true,
        })
```

You are passing in the VPC object that you looked up previously to specify where to create all the resources, along with the task definition that defines which container image to deploy. The **desiredCount** indicates how many copies you want, **serviceName** designates what you want to call the service, and **publicLoadBalancer** is set to true so that you can access it over the internet. The line setting the **assignPublicIp** to true is important in this example because we are using the default VPC that does not have private subnets. Best practice recommends launching services in private subnets, but this is outside the scope of this guide.

You are now ready to deploy the web application, but first, you need to set up CDK on the account you are deploying to. 

Edit the **bin/cdk-ecs-infra.ts** file, and uncomment line 14:  

```JavaScript
    env: { account: process.env.CDK_DEFAULT_ACCOUNT, region: process.env.CDK_DEFAULT_REGION },
```

This will use the Account ID and Region configured in the AWS CLI. Before you can use CDK, it needs to be bootstrapped—this will create the required infrastructure for CDK to manage infrastructure in your account. To bootstrap CDK, run **cdk bootstrap**. You should see output similar to:  

```Bash  
    cdk bootstrap
    
    #output
    ⏳  Bootstrapping environment aws://0123456789012/<region>...
    ✅  Environment aws://0123456789012/<region> bootstrapped
```

This will create the required infrastructure for CDK to manage infrastructure in your account. We recommend working through the [**Get Started with AWS CDK**](/getting-started/guides/setup-cdk/) guide if you are not familiar with setting up a CDK application.

Once the bootstrapping has completed, you will run **cdk deploy** to deploy the container, cluster, and all the other infrastructure required. Please note that Docker must be running to build the containerized application. You should see output similar to the following:  

![Cdk deployment output](images/cdk_deploy_1.png "Cdk deployment output")

CDK will prompt you before creating the infrastructure because it is creating infrastructure that changes security configuration—in your case, by creating IAM roles and security groups. Press **y** and then **Enter** to deploy. CDK will now set up all the infrastructure you defined, and it will take a few minutes to complete. 

While it is running, you will see updates like this:  

![Cdk deployment output](images/cdk_deploy_2.png "Cdk deployment output")

Once it completes, you will see output with the link to the public URL to access your service like this:  

![Cdk deployment output](images/cdk_deploy_3.png "Cdk deployment output")

Open the MyServiceAppURL link in a browser of your choice to verify the Nginx deployment.

![Cdk deployment Nginx](images/cdk_Deployment_Nginx.png "Cdk deployment Nginx")

#### Full code sample
```JavaScript
    import * as ec2 from "aws-cdk-lib/aws-ec2";
    import * as ecs from "aws-cdk-lib/aws-ecs";
    import * as ecs_patterns from "aws-cdk-lib/aws-ecs-patterns";
    import * as cdk from 'aws-cdk-lib';
    import { Construct } from 'constructs';
    
    export class CdkEcsInfraStack extends cdk.Stack {
      constructor(scope: Construct, id: string, props?: cdk.StackProps) {
        super(scope, id, props);
    
        // Look up the default VPC
        const vpc = ec2.Vpc.fromLookup(this, "VPC", {
          isDefault: true
        });
    
        const repository = new ecr.Repository(this, 'My-Repository',{
        repositoryName: 'my-respository-cdkecsinfrastack'
        });

        const taskIamRole = new cdk.aws_iam.Role(this, "AppRole", {
          roleName: "AppRole",
          assumedBy: new cdk.aws_iam.ServicePrincipal('ecs-tasks.amazonaws.com'),
        });

        taskIamRole.addManagedPolicy(
        cdk.aws_iam.ManagedPolicy.fromAwsManagedPolicyName(
            "service-role/AmazonECSTaskExecutionRolePolicy"
        )
        );
    
        const taskDefinition = new ecs.FargateTaskDefinition(this, 'Task', {
          taskRole: taskIamRole,
          family : 'CdkEcsInfraStackTaskDef',
        });
    
        taskDefinition.addContainer('MyContainer', {
          image: ecs.ContainerImage.fromRegistry('nginx:latest'),
          portMappings: [{ containerPort: 80 }],
          memoryReservationMiB: 256,
          cpu: 256,
        });
    
        new ecs_patterns.ApplicationLoadBalancedFargateService(this, "MyApp", {
          vpc: vpc,
          taskDefinition: taskDefinition,
          desiredCount: 1,
          serviceName: 'MyWebApp',
          assignPublicIp: true,
          publicLoadBalancer: true,
        })
      }
    }
```

This Sample CDK project is available under cdk-ecs-infra directory in [GitHub](https://github.com/build-on-aws/automate-web-app-amazon-ecs-cdk-codecatalyst) repositoy.

## DEPLOY APPLICATION

In this module, you will create an Amazon CodeCatalyst project, a code repository and a workflow to deploy a containerized [sample application](https://github.com/build-on-aws/automate-web-app-amazon-ecs-cdk-codecatalyst) to the Amazon ECS cluster created in previous module. 

### Create CodeCatalyst CodeCatalystPreviewDevelopmentAdministrator role
You need IAM roles to create workflows to build and deploy your application. Instead of creating two roles, you can create a single role called the CodeCatalystPreviewDevelopmentAdministrator role. CodeCatalystPreviewDevelopmentAdministrator role has broad permissions which may pose a security risk. We recommend that you only use this role in tutorials and scenarios where security is less of a concern.

You can create the role by navigating to the summary page of your space, then click on 'Settings' tab and go to the 'AWS Account' page. Open the 'Manage roles from AWS Management Console' page and create a CodeCatalystPreviewDevelopmentAdministrator role. 

![Create IAM Role](images/CodeCatalyst_IAMRole_1.png "Create IAM Role")

In the **Add IAM Role** page, choose to create a new CodeCatalystPreviewDevelopmentAdministrator role

![Create IAM Role](images/CodeCatalyst_IAMRole_2.png "Create IAM Role")

The role will be created as 'codeCatalystPreviewDevelopmentAdministrator', appended with a unique identifier.

### Create CodeCatalyst Project
To create a CodeCatalyst project, you need to have the [CodeCatalyst](https://codecatalyst.aws/) account and space setup. If you don't have a CodeCatalyst setup already, you can follow the [Amazon CodeCatlyst setting up guide](https://docs.aws.amazon.com/codecatalyst/latest/userguide/setting-up-topnode.html)).

Let's create a project in your CodeCatalyst Space. In the 'Create Project' page, Choose 'Start from Scratch' and provide a valid name to create a project.

![Create CodeCatalyst Project](images/CodeCatalyst_Create_Project.png "Create CodeCatalyst Project")

### Create CodeCatalyst Repository
You can either create a new repository or link an existing GitHub repository. For this tutorial, we will be creating a source repository. You can create a repository 'SampleApp' in your project by navigating to the project that we created in previous step. 

![Create CodeCatalyst Repository](images/CodeCatalyst_Create_Repository.png "Create CodeCatalyst Repository")

### Create CodeCatalyst Dev Environment
 Now we'll create a Dev environment, which will help us to add the sample application to the repository. You can choose an IDE of your choice from the list. For this tutorial, we recommend using AWS Cloud9 or Visual Studio Code.

 ![Create CodeCatalyst Dev Environment](images/CodeCatalyst_DevEnv.png "Create CodeCatalyst Dev Environment")
 
 Next step is to download the sample application from the [Github](https://github.com/build-on-aws/automate-web-app-amazon-ecs-cdk-codecatalyst) to your local machine and add it to the Dev environment. Open the task.json file from the sample application and replace the <account Id> with your account Id 
```json
"executionRoleArn": "arn:aws:iam::<account_ID>:role/AppRole",
```
Your sample application is ready to be uploaded to CodeCatalyst repository and you can commit the changes to the repo. 

### Create CodeCatalyst CI/CD environment
In this step, we will create a CI/CD non-production environment, which will be used to execute the workflow. You can create the CI/CD environment by navigating to the **CI/CD** section of your project, select **Environments** and click on the **Create Environment** button. You need to select an AWS account connection to execute the workflow on the selected AWS account

![Create CI/CD environment](images/CodeCatalyst-CreateCI_CD_Env.png "Create create environment")

### Create CodeCatalyst Workflow
we will create a workflow to build the sample application into a Docker image and deploy to the ECS cluster. A workflow is an automated procedure that describes how to build, test, and deploy your code as part of a continuous integration and continuous delivery (CI/CD) system. With workflow you can define the events or triggers to start the workflow and actions to take during a workflow run. 

To set up a workflow, you create a workflow definition file using the CodeCatalyst console's visual or YAML editor.
Let's create an empty workflow definition for **SampleApp** repository by navigating to the CI/CD section of your project , select **Workflows** within CI/CD section and then click on **Create workflow** button.

![Create CodeCatalyst workflow](images/CodeCatalyst_CreateWorkflow.png "Create CodeCatalyst workflow")

In the workflow definition, set up a trigger to start the workflow when changes gets pushed to the main branch of the repository. 

### Add Build action
First step in the workflow is to build the application to generate a Docker image. To achieve this, you can add **Build** action to the workflow and define a set of input variables. **Region** is used to configure the AWS region you would like the application to be deployed. Provide the same region where your ECS cluster infrastructure is provisioned. **registry** is used to configure the Docker ECR endpoints which will be used in the further build steps. In the below code, replace all occurences of **<Account-Id>** with your CodeCatalyst account id. **image** is the name of your ECR repository, which is created within the cdk project.

Configuration section of the **Build** action includes steps to setup the AWS account & ECR repository, create Docker image , push the Docker image to ECR Repository and export a variable with the ECR Repository URI. ECR Repository URI will be used to pull the image when deploying the application.

Below code snippet shows **Build** action configurations.

```YAML
Triggers:
  - Type: Push
    Branches:
      - main
Build_application:
    Identifier: aws/build@v1
    Inputs:
      Sources:
        - WorkflowSource
      Variables:
        - Name: region
          Value: us-west-2
        - Name: registry
          Value: <Account-Id>.dkr.ecr.us-west-2.amazonaws.com
        - Name: image
          Value: my-respository-cdkecsinfrastack
    Outputs:
      AutoDiscoverReports:
        Enabled: false
      Variables:
        - IMAGE
    Compute:
      Type: EC2
    Environment:
      Connections:
        - Role: <CodeCatalystPreviewDevelopmentAdministrator role>
        # Add account id within quotes. Eg: "12345678"
          Name: <Account-Id>
      Name: Dev
    Configuration:
      Steps:
        - Run: export account=`aws sts get-caller-identity --output text | awk '{ print $1
            }'`
        - Run: aws ecr get-login-password --region ${region} | docker login --username AWS
            --password-stdin ${registry}
        - Run: docker build -t appimage .
        - Run: docker tag appimage ${registry}/${image}:${WorkflowSource.CommitId}
        - Run: docker push --all-tags ${registry}/${image}
        - Run: export IMAGE=${registry}/${image}:${WorkflowSource.CommitId}
```
### Add Render Amazon ECS Task Definition action
**Render Amazon ECS Task Definition** action will update the image field in an ECS task definition file with the Docker image URI that we have exported in the **Build** action.

Add the **Render Amazon ECS Task Definition** action and configure **image** field with the Docker image URI that we have exported in the **Build** action, configure **container-name** field with the container's name created in the cdk project, configure **task-definition** field with **task.json**, which refers to the task.json file in the **SampleApp** repository. This task will output an updated task definition file at the runtime. 

Below code snippet shows **Render Amazon ECS Task Definition** action configurations.

```YAML
RenderAmazonECStaskdefinition:
    Identifier: aws/ecs-render-task-definition@v1
    Configuration:
      image: ${Build_application.IMAGE}
      container-name: MyContainer
      task-definition: task.json
    Outputs:
      Artifacts:
        - Name: TaskDefinition
          Files:
            - task-definition*
    DependsOn:
      - Build_application
    Inputs:
      Sources:
        - WorkflowSource
  ```      

### Add Deploy To Amazon ECS action
As a final setp to your workflow, add the **Deploy To Amazon ECS** action. This action registers the task definition file that is created in the **Render Amazon ECS Task Definition** action. Upon registration, the task definition is then instantiated by your Amazon ECS service running in your Amazon ECS cluster. Instantiating a task definition is equivalent to deploying an application into Amazon ECS.

Set the task definition file created in the **Render Amazon ECS Task Definition** action as an input artifact to this action. In the configuration section of the action, configure **task-definition** to the input artifact file path, configure **cluster** to the ECS cluster ARN that you have created in the cdk project.  You can find the ECS cluster ARN from the AWS Console - Amazon Elastic Container Service - Clusters. Replace <ECS cluster ARN> with your ECS cluster ARN. Configure **service** to the ECS Service's name,which we defined in the cdk project. Alternatively, you can find ECS service name in the AWS Console - Amazon Elastic Container Service - Clusters. **Region** is used to configure the AWS region you would like your application to be deployed. Provide the same region where your ECS cluster infrastructure is provisioned. Provide the environment connection and CI / CD environment information under **Environments**.

For this action to work properly, ensure that ECS cluster and ECS Service names match the infrastructure that you have already provisioned in your AWS environment.

Below code snippet shows the **Deploy To Amazon ECS** action configurations.

```YAML
    DeploytoAmazonECS:
    Identifier: aws/ecs-deploy@v1
    Configuration:
      task-definition: /artifacts/DeploytoAmazonECS/TaskDefinition/${RenderAmazonECStaskdefinition.task-definition}
      service: MyWebApp
      cluster: <ECS cluster ARN>
      region: us-west-2
    Compute:
      Type: EC2
      Fleet: Linux.x86-64.Large
    Environment:
      Connections:
        - Role: <CodeCatalystPreviewDevelopmentAdministrator role>
        # Add account id within quotes. Eg: "12345678"
          Name: <Account Id>
      Name: Non-Prod 
    DependsOn:
      - RenderAmazonECStaskdefinition
    Inputs:
      Artifacts:
        - TaskDefinition
      Sources:
        - WorkflowSource
```
Complete workflow definition file is available under SampleApp directory in [GitHub](https://github.com/build-on-aws/automate-web-app-amazon-ecs-cdk-codecatalyst) repositoy.

### Trigger the workflow
Now you have automated the build and deployment workflow. You can trigger the workflow by pushing a code change or workflow change to the **SampleApp** repository or by manually starting the workflow process.

![CodeCatalyst Workflow](images/CodeCatalyst_workflow_execution.png "CodeCatalyst Workflow")

Your **SampleApp** web application is successfully deployed to your ECS Cluster. You can verify it by refreshing your browser, which was previously displaying the Nginx welcome page.

![ECS Sample application deployment](images/ECS_Deployment_SampleApp.png "ECS Sample application deployment")

Optionally, you can automate the infrastructure provision process as well by creating a CodeCatalyst repository and workflow for your cdk project. CodeCatalyst Workflow definition file can be found in the **cdk-ecs-infra** directory in [GitHub](https://github.com/build-on-aws/automate-web-app-amazon-ecs-cdk-codecatalyst).

## Clean up
In this last part of the guide, you will learn how to remove all the different AWS resources you created early on. If your account is still on the free tier, this would not cost you anything, unless you have other free tier resources running already.

### Cleaning up your AWS environment

You have now completed this guide, but you still need to clean up the resources created during this guide. If your account is still in the free tier, it will cost ~$9.00 USD / month to run, or 1.2c USD per hour. To remove all the infrastructure you created, use the **cdk destroy** command - this will only remove infrastructure created during this guide.  

```Bash
    cdk destroy
```

You should receive the below prompt. After pressing **y** and **enter**, it will start removing all the infrastructure and provide updates. Once completed, you will see the following:  
```Bash
    Are you sure you want to delete: CdkEcsInfraStack (y/n)? y
    CdkEcsInfraStack: destroying...
    
     ✅  CdkEcsInfraStack: destroyed
```
### Cleaning up your CodeCatalyst environment
Clean up the resources created in this tutorial to free up the storage in your CodeCatalyst space.

Manually delete the below resources from your CodeCatalyst Space:

Delete codecatalyst workflow<br>
Delete codecatalyst dev environment<br>
Delete codecatalyst source-repository<br>
Delete codecatalyst project

## Conclusion

Congratulations! You have learnt how to deploy a web application to ECS cluster using CDK and CodeCatalyst.  If you enjoyed this tutorial, found any issues, or have feedback us, [please send it our way](https://pulse.buildon.aws/survey/DEM0H5VW)!

For more DevOps related content, check out [How Amazon Does DevOps in Real Life](https://www.buildon.aws/posts/how-amazon-does-devops-in-real-life/).
