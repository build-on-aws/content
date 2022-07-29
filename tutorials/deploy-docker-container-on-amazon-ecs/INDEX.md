---
layout: blog.11ty.js
title: Deploy Docker Containers on Amazon ECS
description: Learn how to deploy a container with the Amazon ECS wizard
tags:
  - containers
  - aws-ecs
authorGithubAlias: cobusbernard-amazon
authorName: Cobus Bernard
date: 2022-07-29
---

# Deploy Docker Containers on Amazon ECS
## Overview
Amazon Elastic Container Service (Amazon ECS) is the AWS service you use to run Docker applications on a scalable cluster. In this how-to guide, you will learn how to run a Docker-enabled sample application on an Amazon ECS cluster behind a load balancer, test the sample application, and delete your resources to avoid charges. This tutorial uses AWS Fargate, which has a ~USD 0.004 (less than half a USD cent)
cost when using the 0.25 vCPU / 0.5GB configuration.

| Steps | Image|
| --- | --- |
| **Step 1: Set up your first run with Amazon ECS.** <br/> The Amazon ECS first run wizard will guide you through creating a cluster and launching a sample web application. In this step, you will enter the Amazon ECS console and launch the wizard. |
|a. To launch the Amazon ECS first run wizard, click on [Get Started](https://us-west-1.console.aws.amazon.com/ecs/home?region=us-west-1#/firstRun) (if your layout looks different, disable the _"New ECS Experience"_ toggle button at the top left of the console). | ![ECS Fargate Wizard](../images/ecs_wizard_step_1.png) |
|**Step 2: Create container and task definition** <br/> A task definition is like a blueprint for your application. In this step, you will specify a task definition so Amazon ECS knows which Docker image to use for containers, how many containers to use in the task, and the resource allocation for each container.  | |
| a. In the Container definition field, select `sample-app` | ![Select Sample App](../images/ecs_wizard_step_2a.png) |
| b. The task definition comes pre-loaded with default configuration values. <br/> Review the default values and select `Next`. <br/> If you prefer to modify the configurations or would like to learn more, see [Task Definition Parameters](http://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_definition_parameters.html?p=gsrc&c=ho_ddc). | ![Select Sample App](../images/ecs_wizard_step_2b.png) |
| **Step 3: Define your service** <br/> Now that you have created a task definition, you will configure the Amazon ECS service. A service launches and maintains copies of the task definition in your cluster. For example, by running an application as a service, Amazon ECS will auto-recover any stopped tasks and maintain the number of copies you specify. |
| a. Service options come pre-loaded with default configuration values. <br/><br/> **Service name:** The default `sample-app-service` is a web-based "Hello World" application provided by AWS. It is meant to run indefinitely, so by running it as a service, it will restart if the task becomes unhealthy or unexpectedly stops. <br/><br/> **Desired number of tasks:** Leave the default value of 1, this will create one copy of your task. | ![Review Service name](../images/ecs_wizard_step_3a.png) |
|b. **Load balancing:** You have the option to use a load balancer with your service. Amazon ECS can create an Elastic Load Balancing (ELB) load balancer to distribute the traffic across the container instances your task is launched on. <br/><br/>Select the `Application Load Balancer` option. <br/><br/>The default values for Load balancer listener port and Load balancer listener protocol are set up for the sample application. For more information on load balancing configuration, see [Service Load Balancing](http://docs.aws.amazon.com/AmazonECS/latest/developerguide/service-load-balancing.html?p=gsrc&c=ho_ddc). <br/><br/>Review your settings and select `Next`. | ![Use Application Load Balancer](../images/ecs_wizard_step_3b.png) |
| **Step 4: Configure your cluster** <br/>Your Amazon ECS tasks run on a cluster, which use [AWS Fargate](https://aws.amazon.com/fargate/) to provides the compute engine without having to manage servers. In this step, you will configure the cluster.
|a. In the Cluster name field, enter `sample-cluster` and select `Next`| ![Set cluster name](../images/ecs_wizard_step_4.png) |
| **Step 5: Launch and view your resources** <br/>In the previous steps, you have configured your task definition (which is like an application blueprint), the Amazon ECS service (which launches and maintains copies of your task definitions), and your cluster. In this step, you will review, launch, and view the resources you create. | | 
| a. You have a final chance to review your task definition, task configuration, and cluster configurations before launching. Select `Create`. | ![Create Cluster](../images/ecs_wizard_step_5a.png) | 
|b. You are on a Launch Status page that shows the status of your launch and describes each step of the process. After the launch is complete, select `View service`. | ![View Service](../images/ecs_wizard_step_5b.png) | 
| **Step 6: Open the sample application** <br/> In this step, you will verify that the sample application is up and running by pointing your browser to the load balancer DNS name. | |
|a. On the sample-webapp page, select the `Default` tab and click on the target group. | ![Select Target Group](../images/ecs_wizard_step_6a.png) |
|b. Next, click on the target group name to select it. | ![Select Target Group](../images/ecs_wizard_step_6b.png) |
|c. In the `Details` tab, click on the Load Balancer link. | ![Select Load Balancer](../images/ecs_wizard_step_6c.png) |
|d. In the `Description` tab, click on two page icon next to the load balancer DNS to copy it to your clipboard.| ![Copy Load Balancer DNS link](../images/ecs_wizard_step_6d.png) |
|e. Paste it into a new browser window, and press `enter` to view the sample application (in this case, a static webpage). | ![Open sample app in the browser](../images/ecs_wizard_step_6e.png) |
| **Step 7: Delete your resources** <br/> Throughout this guide, you've launched three resources: an Amazon ECS cluster, AWS Fargate to run your container, and a load balancer. In this step, you will clean up all your resources to avoid unwanted charges.
| a. Navigate back to the Amazon ECS console page and click on the cluster name (`sample-cluster`). | ![Select sample-cluster ECS cluster](../images/ecs_wizard_step_7a.png) |
|b. Click on `Delete` to delete the cluster | ![Delete ECS cluster](../images/ecs_wizard_step_7b.png) |
|c. Enter `delete me` in the dialog box and click on `Delete` | ![Confirm delete ECS cluster](../images/ecs_wizard_step_7c.png) |
|d. You will now see the progress as all the resources created are deleted. | ![ECS Cluster delete progress](../images/ecs_wizard_step_7d.png) |
|e. Once everything has been deleted, you will see the `Deleted cluster sample-cluster successfully` message in green. You have now completed this guide. | ![ECS Cluster delete complete](../images/ecs_wizard_step_7e.png) | 