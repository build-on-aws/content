---
title: "Using Flux to Implement GitOps on AWS"
description: GitOps is an effective way to achieve continuous deployment based on Kuberentes clusters while meeting enterprise-level requirements such as security,separation of privileges, auditability, and agility. We would like to use demo videos to share the best practices for GitOps based on AWS EKS. It includes :1/how to deploy Flux CD in AWS EKS, 2/how to use Flux CD to build a GitOps workflow, ,3/how to use Flux realize Multi-tenant management, and 4/how to automate deployment based image update. - DevOps - GitOps - FluxCD.
tags:
  DevOps
  GitOps
  FluxCD
authorGithubAlias: betty714, tyyzqmf
authorName: bettyzheng, Mingfei Que
date: 2023-03-23
---

# Using Flux to Implement GitOps on AWS

A large number of enterprise have adopted Kubernetes in their production, they confused about how to achieve continuous deployment, high security, permission separation, and auditing while ensuring business agility with multiple Kubernetes clusters running at different stages simultaneously. We believe that GitOps is the well method approach to continuous deployment based on Kubernetes clusters, while meeting enterprise-level requirements such as security and permission separation.

In this blog, we will use a case to practice how to implement GitOps in Amazon EKS environment. We will use AWS CodeCommit for the code repository in the CI/CD pipeline, we will use AWS CodePipeline for the CI part. And Flux, the pioneer of GitOps philosophy from WeaveWorks, is used for the CD engine. We will demonstrate in detail how to set up a GitOps workflow that meets production requirements in the Amazon EKS environment, and will show how will microservice applications continuous integration and continuous delivery on the GitOps-style CI/CD pipeline.

Before we get into best practices, let's synchronize what GitOps is and why we're talking about GitOps best practices at AWS

## What is GitOps

GitOps is a way of implementing Continuous Deployment for cloud native applications. It focuses on a developer-centric experience when operating infrastructure, by using tools developers are already familiar with, including Git and Continuous Deployment tools.

The core idea of GitOps is having a Git repository that always contains declarative descriptions of the infrastructure currently desired in the production environment and an automated process to make the production environment match the described state in the repository. If you want to deploy a new application or update an existing one, you only need to update the repository - the automated process handles everything else. It’s like having cruise control for managing your applications in production.

GitOps has the following features compared to traditional continuous deployment.

| Traditional CD                                               | **GitOps**                                             |
| :----------------------------------------------------------- | ------------------------------------------------------ |
| Triggered by push events, such as code commits, timed tasks, manual, etc. | System constantly polls for changes                    |
| Deployment of changes only                                   | Declared the entire system for any deployment          |
| System would drift between deployments                       | The system will correct any drift                      |
| Access to the deployment environment is a requirement        | Deployment pipeline is authorized to run within system |

## Why is GitOps 

We believe GitOps is the ideal way to implement continuous deployment of Kuberentes-based clusters. The main reason is that we can go through the details of GitOps specific practices on Kuberentes.
Based on GitOps method, Git is the only actual source of the required state for the system. It supports repeatable and automated deployment, cluster management, and monitoring. Developers reuse Git workflows that are well-established in the enterprise for building, testing, scanning, and other continuous integration steps. Once the final state of the system is declared in the main Git repository branch, the GitOps tool chain is used to verify/deployment, observe/ alerts, and fix/operations. The process is like below:

![why is GitOps](https://github.com/betty714/content/blob/1edd0f0b25f13ebf247f73e21702f9e89c4d0e7b/tutorials/Using-Flux-to-Implement-GitOps-on-AWS/images/why%20is%20GitOps.jpg))
## Amazon EKS-based Best Practices for GitOps 

The overall CI/CD pipeline for the best practices of this case is shown in the figure below.

![overview](https://github.com/betty714/content/blob/514c9da25c084b4e4c086018d1f36ae9ada57eaf/tutorials/Using-Flux-to-Implement-GitOps-on-AWS/images/overall%20cd:cd%20plipeline.png)

There are three code repositories under the CodeCommit repository. One is flux-repo , the configuration repository for Flux CD, which is used to define Flux-related resources. The other is microservices-repo, which saves microservice application configurations and deployment files. The third one is the source repository app-repo for business services. In this post, a front-end project will be as an example. We used the CodePipeline for continuous integration in the CI/CD pipeline, built and stored the docker image in Amazon ECR, and deployed the CD engine Flux as pod in the Amazon EKS environment.

**The basic workflow is:**

1)  Coding engineers write code and push the final code to app-repo;

2)  Code changes in the app-repo trigger AWS CodePipeline;

3)  AWS CodePipeline edits and packages code, generates container images, and pushes them to the container image repository/ Amazon ECR.

4)  The CD engine Flux running in the EKS environment regularly scans the ECR container image repository and pulls container image metadata for applications.

5)  Automatically synchronize the new container image address to the application deployment file stored in microservices-repo via git commit/push when a new version of the container image detected.

6)  Flux regularly pulls application configurations and deployment files from the flux-repo. Since the flux-repo repository references the microservices-repo, flux checks the consistency of the workload running state of the cluster with the expectations described in the microservices-repo files. If any difference, Flux will automatically enable the EKS cluster to synchronize the differences to ensure that workloads run in the expected state.

**Table of best practices**

Since we have explained the GitOps concept and the architecture of the CI/CD pipeline, we will use a case to complete this practice by going through the four modules below:

- Deploy the cloud infrastructure using Infrastructure as Code (IaC).

- Deploy Flux CD on AWS EKS cluster

- Deploy GitOps workflow using Flux CD

- Implemente automatic deployment based on images using GitOps workflow

### 1．Deploy Cloud Infrastructure with IaC

One of the fundamental principles of the DevOps is that infrastructure get “equal status” with codes. Infrastructure as Code (IaC) use code to enables cloud infrastructure deployment and governance of the cloud environment. Coding engineers use configuration files or codes to define the infrastructure and create it by coding to ensure the consistency and repeatability. With IaC, coding engineers also manage the lifecycle of resources, such as hosting infrastructure definitions in version control repositories, and using Continuous Integration/Continuous Deployment (CI/CD) that is compatible with app coding for changing the definition of of IaC, synchronizing the environments (e.g., development, testing, production) with the changes of the IaC codes. Additionally, automatic rollback is possible in case of failures and drift detection helps to identify differences from the expected state.

In the cloud, coding engineers can use the AWS Cloud Development Kit (CDK) to build their infrastructure model with Python, Java, and Typescript. CDK provides advanced components that called Constructs, which preconfigure cloud resources with validated default values. It also allows coding engineers to write and share their custom constructs according to their organization's requirements. All of these will accelerate projects

#### 1.1 Create a Project with CDK CLI

Create a TypeScript CDK project with cdk init, which will create the folder structure and install the modules that TypeScript CDK project needs.

```
mkdir -p ~/environment/quickstart
cd ~/environment/quickstart
cdk init --language typescript 
```

#### 1.2 Create an EKS cluster with EKS Blueprints

**EKS Blueprints** helps you compose complete EKS clusters that are fully bootstrapped with the operational software that is needed to deploy and operate workloads. With EKS Blueprints, you describe the configuration for the desired state of your EKS environment, such as the control plane, worker nodes, and Kubernetes add-ons, as an IaC blueprint. Once a blueprint is configured, you can use it to stamp out consistent environments across multiple AWS accounts and Regions using continuous deployment automation.

You can use EKS Blueprints to easily bootstrap an EKS cluster with Amazon EKS add-ons as well as a wide range of popular open-source add-ons, including Prometheus, Karpenter, Nginx, Traefik, AWS Load Balancer Controller, Fluent Bit, Keda, ArgoCD, and more. EKS Blueprints also helps you implement relevant security controls needed to operate workloads from multiple teams in the same cluster.

Run the following codes to install project dependencies.

```
npm install @aws-quickstart/eks-blueprints@1.3.0 typescript@~4.8.4 --save

```

Open lib/quickstart-stack.ts and write the EKS Blueprints codes.

[TABLE]

In the above codes, we created an EKS cluster, defined its NodeGroup, and added the AwsLoadBalancerController plugin.

| Best Practice: We recommend customizing the cluster parameters via clusterProvider and adding plugins through the built-in addOns in EKS Blueprints. |
|------------------------------------------------------------------------------------------------------------------------------------------------------|

![image-20230323220830677](/Users/betzheng/Library/Application Support/typora-user-images/image-20230323220830677.png)



While deploying a stack with a CDK command-line tool is convenient, we recommend setting up an automated pipeline responsible for deploying and updating the EKS infrastructure. This makes it easier to deploy development, testing, and production environments in different regions with the framework's code pipeline stack.

CodePipelineStack is a structure for continuous delivery of AWS CDK applications. When the source code of an AWS CDK application is uploaded to Git, the stack automatically build, test, and deploy new versions. If any application stage or stack is added, it will automatically reconfigure itself to deploy these new stages or stacks.

| Best Practice: Defining infrastructure with CDK code and using pipelines to manage changes in multiple clusters that is also a form of implementing the GitOps concept. |
|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------|

Then, we execute the cdk deploy command to deploy the stack.

| cdk deploy |
|------------|

After completing the cluster deployment, search for information

| kubectl get ns |
|----------------|

And the output is:

![image-20230323220923490](/Users/betzheng/Library/Application Support/typora-user-images/image-20230323220923490.png)

Finally, we used a command to check whether the AWS Application Load Balancer has been installed successfully.

| kubectl get pod -n kube-system |
|--------------------------------|

Check the output to confirm that the deployment of the AWS Application Load Balancer is done.

![image-20230323220947758](/Users/betzheng/Library/Application Support/typora-user-images/image-20230323220947758.png)

#### 1.3 Summary

This section introduces the concept of IaC and creates a custom EKS cluster with CDK while installing the AWS Application Load Balancer plugin, providing a prerequisite for accessing the web pages of microservices in the future. The following is a summary of this section:

- Initialized a CDK project using cdk init.

- Defined an EKS cluster quickly with EKS Blueprint while adding the AWS Application Load Balancer plugin.

### 2．Deploying Flux CD on Amazon EKS Cluster

Flux CD is a continuous delivery tool initially developed by Weaveworks and open-sourced to CNCF. It became successful due to its ability to sense Kubernetes changes and easy setup. The most significant feature it provides is allowing teams to manage their Kubernetes deployment declaratively. Flux CD synchronizes the Kubernetes manifest files stored in the source repository with the Kubernetes cluster by regularly polling the repository, and teams don't have to worry about running kubectl or monitoring the environment to see if they have deployed the right workload. Flux CD ensures that the Kubernetes cluster always stays in sync with the configuration defined in the source repository.

#### 2.1 Flux CLI Installation

The Flux CLI is a binary executable file for all platforms, which can be downloaded from the GitHub release page.

| curl -s https://fluxcd.io/install.sh \| sudo bash |
|---------------------------------------------------|

#### 2.2 Preparing AWS CodeCommit credentials

![image-20230323221028266](/Users/betzheng/Library/Application Support/typora-user-images/image-20230323221028266.png)



#### 2.3 Installing Flux on the cluster

![image-20230323221056360](/Users/betzheng/Library/Application Support/typora-user-images/image-20230323221056360.png)

| Best practice: The project structure we recommend is dividing Flux-related resources into the infrastructure layer, cluster management layer, and application layer. We support multi-cluster deployment with Kustomization (base, overlays). |
|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|

Install Flux on the Kubernetes cluster and configure it to manage itself from the Git repository with flux bootstrap. If there are Flux components on the cluster, the bootstrapping command will perform an upgrade as needed. The bootstrapper is idempotent, and the command can be safely run any number of times. Replace username and password in the command below with the HTTPS Git credentials for AWS CodeCommit.

[TABLE]

| Note: Enable the image automatic update feature, add the --components-extra=image-reflector-controller,image-automation-controller parameter when bootstrapping Flux. |
|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------|

Use **git pull** to check the updates pushed by the bootstrapper. Three new files will appear in the clusters/dev-cluster/flux-system directory of the Git repository:

- **gotk-components.yaml**: defined the six controllers of Flux: helm, kustomize, source, notification, image-automation, and image-reflector.

- **gotk-sync.yaml**: the Git source of Flux, the Source Controller in the cluster monitoring code changes in the GitOps repository and making the corresponding changes.

- **kustomization.yaml**: multi-cluster configuration

Check if Flux is installed successfully with **flux get kustomizations --watch**. The output will look similar to:

![image-20230323221206157](/Users/betzheng/Library/Application Support/typora-user-images/image-20230323221206157.png)

Check the components deployed by flux-system with **kubectl -n flux-system get pod,services**. The output will be as follows:

![image-20230323221223718](/Users/betzheng/Library/Application Support/typora-user-images/image-20230323221223718.png)

#### 2.4 Summary 

In this section, we used the flux bootstrap command to install Flux on the Kubernetes cluster and introduced the three most important configuration files: **gotk-components.yaml, gotk-sync.yaml, and kustomization.yaml.** The following is a summary of this section:

- Flux client installation

- Creating an IAM user and CodeCommit credentials

- Installing Flux on an Amazon EKS cluster and enabling the image automatic update feature.

### 3．Deploying GitOps Workflow with Flux CD

For EKS with GitOps CI/CD practices and workloads running on it, configuration modifications and status changes to the EKS cluster and workloads stem from the code changes in Git (triggered by git push, or pull request and finally delivered, GitOps recommending the use of pull request), rather than directly manipulating the cluster with kubectl create/apply or helm install/upgrade as in traditional CI/CD pipelines initiated by the CI engine. Therefore, through the GitOps approach, we streamlined the traditional CI/CD pipeline to build a more efficient and simpler GitOps CI/CD pipeline.

| Best practice: Flux regulaly pulls the application configurations and deployment files in the repository, compares the current application load status of the cluster with the expected state described in the files, and when differences are detected, Flux will automatically synchronize the differences to the EKS cluster, ensuring that the workloads always run as expected. |
|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|

We will demonstrate a specific application, sock shop, through practical exercises to show how it achieves continuous integration and delivery on a GitOps CI/CD pipeline.

#### 3.1 About Sock Shop

We use the user-facing section of the sock shop online store as an sample application for demonstrating and testing of microservices and cloud-native technologies. It is built with Spring Boot, Go Kit and Node and packaged in Docker containers. As a "Microservice Standard Demo", it will provide:

- Best practices for microservices (including examples of mistakes)

- Cross-platform deployment capabilities

- Showing the advantages of continuous integration/deployment

- Showing the complementary nature of DevOps and microservices

- Providing a "real" testable application for various orchestration platforms

The reference architecture is as follows:

![image-20230323221252945](/Users/betzheng/Library/Application Support/typora-user-images/image-20230323221252945.png)



#### 3.2 About Kustomize

In addition to building the GitOps workflow, we also need to understand the applications management approach in K8s. Traditional resource inventory-based management (yaml) becomes increasingly difficult to maintain as system complexity and environment complexity increase. Multiple business applications, multiple environments (development, testing, pre-release, production), and a large number of yaml resource inventories need to be maintained and managed. Although Helm can solve some pain points, such as unified management of scattered resource files, application distribution, upgrade, rollback, etc., dealing with tiny differences between the environments in Helm is more complex and requires a complex DSL (template syntax) syntax, with a high learning curve. Therefore, the declarative configuration management tool Kustomize was born. Kustomize helps manage a large number of Kubernetes YAML resources for applications in different environments or teams in a lightweight way, and manage the nuances among the environments, making resource configurations reusable, reducing the workload of copy and change, and the error rate of configuration. The entire application configuration process does not require learning additional template syntax.

**Kustomize solves the above problems in the following ways:**

- Kustomize maintains application configuration for different environments through Base & Overlays.

- Kustomize uses patch to reuse Base configuration and implements resource reuse by describing the differences between Overlay and Base application configurations.

- Kustomize manages native Kubernetes YAML files, without learning additional DSL syntax.

According to the official website, Kustomize has become a native configuration management tool for Kubernetes, allowing users to customize application configurations without templates. Kustomize uses native K8s concepts to help create and reuse resource configurations (YAML), allowing users to use an application description file (YAML) as the basis (Base YAML) and then generate the required description file for the final deployed application through Overlays.

![image-20230323221343232](/Users/betzheng/Library/Application Support/typora-user-images/image-20230323221343232.png)



#### 3.3 Multi-cluster Configuration

With the understanding to the configuration management tool Kustomize, we use the Kustomization (base, overlays) to enable a multi-cluster deployment transformation.

We created two directories in the microservice project: the base directory to store the complete resource configuration (YAML) files, and the overlays directory to store the different environment or cluster's differential configuration.

For example, in this case, the complete configuration file for the microservice is complete-demo.yaml, and we copyed it to the base directory.

| cp deploy/kubernetes/complete-demo.yaml deploy/kubernetes/base/complete-demo.yaml |
|-----------------------------------------------------------------------------------|

Then we reference the file through kustomization.yaml:

[TABLE]

For the development environment, if there are differential needs, such as changing the number of service ports and replica numbers, just configure the differential settings in the overlays/development/kustomization.yaml file, without copying and modifying the existing complete-demo.yaml.

| Best practice: Flux will automatically merge the base configuration with the overlays configuration according to the environment during service deployment. What we recommend is to define differential configurations for multiple environments, such as development, testing, and prod, under overlays. Support for multi-environment clusters does not adopt a multiple repository/multiple branch strategy, but rather different paths to manage different clusters. This is also the strategy Flux recommended, which will make the code maintenance and merging less difficult. |
|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|

#### 3.4 Deploying Microservices with GitOps Workflow

> After completing the multi-cluster support for microservices, we need Flux to be aware that microservices’ configuration has been changed, so we register the CodeCommit address of the microservices repository (microservices-repo) in the Flux repository (flux-repo).

##### 3.4.1 Adding the Microservices Repository Address 

> We return to the Flux repository, under the application layer/apps directory:
>
> ![image-20230323221450479](/Users/betzheng/Library/Application Support/typora-user-images/image-20230323221450479.png)
>
> 
>
> Open the tenant.yaml file under apps/base/sock-shop/, and replace MICRO_SERVICES_REPO with the microservices address: https://git-codecommit.xxx.amazonaws.com/v1/repos/microservices-repo.
>
> ![image-20230323221520073](/Users/betzheng/Library/Application Support/typora-user-images/image-20230323221520073.png)

##### 3.4.2 Adding CodeCommit Credentials

Find the account and password for "Preparing AWS CodeCommit Credentials". Convert the value of the data to base64 encoding before executing the command.

Then open the file base/sock-shop/basic-access-auth.yaml, and replace **BASE64_USERNAME** and **BASE64_PASSWORD** with the generated base64 encoding:

![image-20230323221556126](/Users/betzheng/Library/Application Support/typora-user-images/image-20230323221556126.png)

##### 3.4.3 Deployment

With the microservice's Git address added in the Flux configuration repository, Flux will automatically scan for microservices’ configuration changes. If the code is committed, and Flux will find no microservices deployed in the cluster, and there is a mismatch with the Git repository definition, Flux will automatically deploy microservices in the cluster.

After committing the code, execute the command "flux get kustomizations -watch" and wait for Flux to update. When the READY status of all kustomizations is True, the deployment is complete.

Query the **pods and services** in the sock-shop namespace, shown as below:

![image-20230323221656362](/Users/betzheng/Library/Application Support/typora-user-images/image-20230323221656362.png)

Access the DNS name of AWS Load Balancer.

![](/Users/betzheng/Library/Application Support/typora-user-images/image-20230323221725169.png)

#### 3.5 Summary

In this section, we introduced a microservice business application, Sock Shop online store, and completed the multi-cluster configuration of the service. We also built a standard GitOps workflow based on Flux, which automatically synchronizes the target cluster with the changes in the configuration files to complete the microservice deployment in the EKS cluster. Meanwhile, we introduced a practical K8s configuration management tool, Kustomize, to manage the resource files of the application. Here is summary of this section:

- Introduction to the microservice business application

- Introduction to the configuration management tool Kustomize (base, overlays) to modify the microservice multi-cluster deployment

- Building a GitOps workflow and deploying microservices.

### 4．Image-Based Automated Deployment with GitOps Workflow

We choose the front-end microservice of Sock Shop as an example to demonstrate the detailed process of code changes, image building, and customized release with GitOps workflow.

#### 4.1 Defining the CodePipeline CI

Front-end is a pure front-end service of Node.js to support Docker image packaging. Add a buildspec.yml file to the front-end project source code to define the CI process executed in the CodePipeline:

[TABLE]

| Best Practice: We took the CI steps in CodePipeline with CodeBuild, and the buildspec.yml file was required for this step in CodeBuild. |
|-----------------------------------------------------------------------------------------------------------------------------------------|

This CI process will automatically build an image and upload it to the ECR repository weaveworksdemos/front-end if any front-end code changed. The format of the image tag is \[branch\]-\[commit\]-\[build number\].

![image-20230323222106277](/Users/betzheng/Library/Application Support/typora-user-images/image-20230323222106277.png)

#### 4.2 Image Auto-Updating

In an agile environment of continuous integration, such as development testing, it is too cumbersome to update GitOps repository manually or via scripts after building and releaseing new service images. Flux provides comprehensive and powerful automatic Git repository image upgrading feature. The automatic image updating feature requires Flux to enable the image updating component in configuration. If not, it can be enabled by adding the parameters --components-extra=image-reflector-controller,image-automation-controller when repeating Flux bootstrap.

To achieve image-based automatic updating, we need to take the following steps:

- Register the image repository of the front-end microservice, to allow Flux to periodically scan the ECR image repository correspondent to the front-end project.

- Configure the credentials for accessing the image repository. Flux needs the credentials to access ECR image repository to read the image information.

- Set the image updating policy. In most cases, we do not want all the image versions changes to trigger CD every time. Instead, we only want the specified branch (main) code changes to trigger CD. A special update policy is needed to fulfill this need.

Next, we will complete the above operations one by one.

##### 4.2.1 Adding an image policy to the front-end of Git repository

In the microservices-repo project, we will use Kustomization overlays in the DEV environment to replace the front-end microservice with a customized and updated version. Modify the file deploy/kubernetes/overlays/development/kustomization.yaml. (Note: replace **ACCOUNT_ID** with your own ACCOUNT_ID).

[TABLE]

| Note: The annotation \$imagepolicy is mandatory, which is for locating. If Flux discovers the image version is changed , it will locate and modify the file content according to this annotation. |
|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|

##### 4.2.2 Registing the front-end of microservice under flux-repo 

In the project flux-repo, create a new file apps/overlays/development/sock-shop/registry.yaml, and replace ACCOUNT_ID with your own ACCOUNT_ID.

[TABLE]

##### 4.2.3 Configuring the access credentials for AWS ECR 

There are two methods available for AWS ECR credentials in Flux.

- Automatic authentication mechanism (image-reflector-controller retrieves credentials by itself, only applicable to: AWS ECR, GCP GCR, Azure ACR)

- Refreshing credentials (stored in the cluster through Secret)regularly with CronJob

| Best practice: We used AWS ECR to choose the automatic authentication mechanism， modify clusters/dev-cluster/flux-system/kustomization.yaml and add the --aws-autologin-for-ecr parameter through patching. |
|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|

[TABLE]

##### 4.2.4 Setting image update policy

Add file gitops/apps/overlays/development/sock-shop/policy.yaml. The following rules match image versions such as master-d480788-1, master-d480788-2, and master-d480788-3.

[TABLE]

Add file gitops/apps/overlays/development/sock-shop/image-automation.yaml. Flux's automatic image configuration will specify a Git repository for the application configuration, including branch, path, and other information.

[TABLE]

#### 4.3 Release and Verify 

We verify the entire process of automatic image updates by modifying the front-end source code.

##### 4.3.1 Update the front-end code

Change the footer of the front-end page, and modify the file: front-end/public/footer.html.

![image-20230323222145784](/Users/betzheng/Library/Application Support/typora-user-images/image-20230323222145784.png)

Commit changes.

![image-20230323222206553](/Users/betzheng/Library/Application Support/typora-user-images/image-20230323222206553.png)

##### 4.3.2 Check CodePipeline 

Code changes to the front-end will automatically get CodePipeline to run.

![image-20230323222226636](/Users/betzheng/Library/Application Support/typora-user-images/image-20230323222226636.png)

##### 4.3.3 ECR Image Version Changing Confirmation

When the CodePipeline is completed, log in the AWS ECR console and query the weaveworksdemos/front-end image version:

![image-20230323222247576](/Users/betzheng/Library/Application Support/typora-user-images/image-20230323222247576.png)

##### 4.3.4 Verify Flux Image Information 

Through Flux CLI, check if the ImageRepository and ImagePolicy successfully retrieved the latest version.

![image-20230323222336102](/Users/betzheng/Library/Application Support/typora-user-images/image-20230323222336102.png)

##### 4.3.5 Microservice Source Code Automatically Updates 

Flux automatically updated the front-end image version.The latest commit was made by fluxcdbot, and the image tag was successfully modified to the latest version: master-1f49071-24.

![image-20230323222350967](/Users/betzheng/Library/Application Support/typora-user-images/image-20230323222350967.png)

##### 4.3.6 Verify Pod Image Version

Verify the pod name with kubectl get pod -n sock-shop \| grep front-end. Check the pod details with kubectl describe pod/front-end-759476784b-9r2rt -n sock-shop \| grep Image: to confirm that the image version is updated. It shows as follows:

![image-20230323222419526](/Users/betzheng/Library/Application Support/typora-user-images/image-20230323222419526.png)

##### 4.3.7 Confirm the static page is up-to-date.

![image-20230323222446340](/Users/betzheng/Library/Application Support/typora-user-images/image-20230323222446340.png)

#### 4.5 Summary

In this section, we have detailed the entire process of automatic deployment based on images. To summarize it, we use Flux's continuous monitoring capability for image repositories. When a change in image version is detected, it automatically modifies the image configuration in the Git repository, and completes automatic deployment by connecting to the standard GitOps workflow in the previous section. To summarize this section:

- Implementing the CI process through CodePipeline to achieve continuous integration of front-end code.
- Locating and modifying business configuration file by annotating Flux.
- Configuring Flux's image update policy to enable Flux to monitor the specific versions of images and complete automatic deployment.

## Conclusion

This blog focuses on how to use FluxCD to automate the publishing of microservices in the Amazon EKS cluster on cloud, as well as best practices for GitOps pipelines. GitOps is a continuous delivery method that encompasses a series of best practices. There are no strict restrictions on building CI/CD tools, if they conform to the basic principles of GitOps. I hope you take somethings from this blog to build your GitOps technology stack. For more diverse and complex production scenarios, we need to continuously optimize these practices, for example:

- How to Gray-Release with security and increments for critical online-production-systems?

- How to improve the GitOps Key Management on cloud when Sealed Secrets introduced additional private key management requirements.

- How to Coordinate manage for Coding of IaC and EKS GitOps

- How to develop Kubernetes manifests (YAML) more efficiently

We will explore each of these issues in subsequent blogs.

## References

- [GitOps: Cloud-native Continuous Deployment](https://www.gitops.tech/)
- [GitOps on Kubernetes: Deciding Between Argo CD and Flux](https://thenewstack.io/gitops-on-kubernetes-deciding-between-argo-cd-and-flux/)
- [[Tech Blog\] Bootstrapping clusters with EKS Blueprints ](https://aws.amazon.com/cn/blogs/containers/bootstrapping-clusters-with-eks-blueprints/)
- [Amazon EKS Blueprints Quick Start ](https://aws-quickstart.github.io/cdk-eks-blueprints/)
- [Amazon EKS Blueprints for CDK ](https://github.com/aws-quickstart/cdk-eks-blueprints)
- <https://aws.amazon.com/cn/blogs/china/build-ci-cd-pipeline-in-gitops-on-aws-china-eks/>
- <https://www.weave.works/technologies/gitops/>
