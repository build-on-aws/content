---
title: "Build a CI/CD pipeline to improve your IaC with CloudFormation"
description: A walk-through of how to create a CI/CD pipeline from scratch using Amazon CodeCatalyst, to deploy your Infrastructure as Code (IaC) with AWS CloudFormation.
tags:
  - aws
  - devops
  - infrastructure-as-code
authorGithubAlias: gaonkarr
authorName: gaonkarr
date: 2023-03-02 
---

Infrastructure as Code (IaC) has been revolutionary for over a decade now. We can define our Cloud Infrastructure in a template file in YAML/JSON and use services like AWS CloudFormation to create the infrastructure. This is great as now I don't have to click in the AWS Management Console to set up everything, or create scripts and run using the CLI.

However, we are not done yet. Just writing CloudFormation templates and updating stacks manually is not using the ultimate superpower of defining IaC. The real purpose of defining IaC is to go through the same CI/CD pipeline as an application does during software development, applying the same versioning, track changes, code reviews, test, rollbacks to the infrastructure code. This will help you make your infrastructure more repeatable, reliable, consistent, increase in speed of deployments, reduce errors and eliminate configuration drift.

This tutorial will show you how to set up a CI/CD pipeline using Amazon CodeCatalyst for your Infrastructure as Code written with CloudFormation. The pipeline will utilize pull requests to submit, test, and review any changes requested to the infrastructure.


## Table of Contents

| Attributes             |                                                                 |
|------------------------|-----------------------------------------------------------------|
| ✅ AWS experience      | 100 - Beginner                                              |
| ⏱ Time to complete     | 30 minutes                                                      |
| 💰 Cost to complete    | Free tier eligible                                               |
| 🧩 Prerequisites       | - [AWS Account](https://portal.aws.amazon.com/billing/signup#/start/email)<br>- [CodeCatalyst Account](https://codecatalyst.aws)<br>- AWS [CloudFormation basic understanding](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/cfn-whatis-howdoesitwork.html)|
| 💻 Code Sample         | Code sample used in tutorial on [GitHub](https://github.com/build-on-aws/ci-cd-iac-aws-cloudformation)                            |
| 📢 Feedback            | <a href="https://pulse.buildon.aws/survey/DEM0H5VW" target="_blank">Any feedback, issues, or just a</a> 👍 / 👎 ?    |
| ⏰ Last Updated        | 2023-03-02                                                      |

| ToC |
|-----|



## Pre-requisites

#### <b> AWS account. </b>
Before we begin, ensure you have an AWS Account. You can create a new account by signing up [here](https://portal.aws.amazon.com/billing/signup#/start/email).

#### <b>CodeCatalyst account. </b>

Follow steps in the documentation to [set up CodeCatalyst](https://docs.aws.amazon.com/codecatalyst/latest/userguide/setting-up-topnode.html)


#### <b>IAM Roles </b>
We need to create CloudCatalyst service roles in our AWS account. These will be using these to provide permission to CodeCatalyst. This is one time activity only.

Simply deploy a CloudFormation stack. You can find detailed instructions on how to deploy this stack using AWS Console [here](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/GettingStarted.Walkthrough.html#GettingStarted.Walkthrough.createstack).

- Stack name `CodeCatalyst-IAM-roles` 
- Region: any (preferred `us-west-2`)
- Download the template provided [here](https://raw.githubusercontent.com/build-on-aws/ci-cd-iac-aws-cloudformation/main/cloudformation-templates/IAM_roles_CodeCatalyst.json) and upload this in CloudFormation console -> Create new stack -> Template -> Upload a template.

This will create 2 new AWS Identity and Access Management (IAM) roles - `main_branch_IAM_role` and `pr_branch_IAM_role` in your AWS account.

> Please note, the `main_branch_IAM_role` provides full access to AWS resources in EC2 and CloudFormation services, as those will be used by sample CloudFormation template mentioned in this blog. Please use this role carefully and delete it when not required.

## Getting started

### Setting up a CodeCatalyst Space, Project, Repo, Environment 
Before we create the CI/CD pipeline and workflows, lets setup CodeCatalyst. 
![Setting up a CodeCatalyst Space, Project, Repo,  Environment inside AWS account](images/cc_create_components.png)

#### <b>Space </b>
Lets start with our CodeCatalyst Space. A space represents you, your company, your department, or your group. Your development teams can manage projects inside it. 

Create a new space by clicking on `Create Space` on the [CodeCatalyst Dashboard](https://codecatalyst.aws), add a name (we will use `CloudFormation CodeCatalyst`), and add the AWS Account ID to link for billing. Follow the prompts to link your AWS Account with CodeCatalyst.

Please note, `012345678901` is a placeholder; replace it with your own account ID. You can find your account ID in the top right of your AWS Console. Before you can create the space, follow the `Verify in the AWS console` link and complete the verification. You should get green tick to proceed!

(At the time this writing, CodeCatalyst is in public preview, and only one region is currently supported.)

![CodeCatalyst Create Space dialog](images/cc_create_space.png)
</br>

Once the space is created, go to the `AWS Accounts` tab, click on your account ID, and then click on `Manage roles from the AWS Management Console`. 

This will open a new browser tab to `Add IAM role to Amazon CodeCatalyst space`. In the dialog, select the option `Add an existing role you have created in IAM` and select the `main_branch_IAM_role` from the dropdown. Click `Add role`. 
Follow the same steps for the `pr_branch_IAM_role`. 

![Console Add IAM role to Amazon CodeCatalyst space dialog](images/console_add_iam_role_to_codecatalyst.png)
 
#### <b>Project </b>
Next, we create a new Project inside the space. We can have multiple projects inside a space.

To create a project click on the `Create Project` button, select `Start from scratch`, and give your project a name - we will use `ThreeTierApp`.

![CodeCatalyst Create Project dialog](images/cc_create_project.png)
</br>
 
#### <b>Repository</b> 
Now we'll create a new repository for our code - in our case the CloudFormation template and other resources. Click `Code` in the left-side navigation menu, then select `Source repositories`, `Add repository`, and choose `Create repository`. Set a repository name ( we will use `3-tier-app` in this tutorial), add a description and `none` for the .gitignore file :

![CodeCatalyst Create Repository dialog](images/cc_create_repository.png)
</br>
 
#### <b>Environment </b>
Lastly, we need to setup the AWS environment where our CloudFormation stack will be deployed by automated workflows. This is my non-production environment where my sample CloudFormation template will be deployed.   

From the left navigation panel, select `CI/CD`, `Environments`, and click on `Create Environment`. In the Environment details enter following:
- Environment name : `PreProdEnv`
- Environment type : `Non-production`
- Description : `Pre-production environment to learn, test and experiment with CloudFormation`
- AWS account connection 
    - `Connection` : Select the AWS account ID that will be used in the workflows to deploy this environment

![CodeCatalyst Create Deployment Environment dialog](images/cc_create_environment.png)
</br>

## Setting up a Dev Environment

To work on our infrastructure as code with CloudFormation, we need a <b>Dev Environment</b>. You have the option to use the following support IDEs (Integrated Development Environments): 
- AWS Cloud9
- Visual Studio Code
- JetBrains IDEs
  - IntelliJ IDEA Ultimate
  - GoLand
  - PyCharm Professional

For this blog, we will be using `AWS Cloud9` for our development environment. 

From the left navigation panel, select `Code`, `Dev Environments`, and click on `Create Dev Environment`. In the `Create dev environment and open with AWS Cloud9` dialog box select following: 
- Repository : `Clone a repository` 
- Repository : Select the repo that you want to clone. We created a repo `3-tier-app1` above, so select same. 
- Branch : `Work in existing branch`
- Alias : `bootstrap`

By default, it will launch a Small (2vCPU, 4 GB RAM), 16 Gib storage with 15minutes timeout.

![CodeCatalyst Create Dev Environment IDE dialog](images/cc_create_dev_environment_cloud9.png) 


</br>

Click on `Create` and it will open a new Cloud9 dev environment. It will take a minute or two, so grab a coffee before we start the CloudFormation magic. 
![Cloud9 IDE Welcome Screen](images/Cloud9_welcome_screen.png)

</br>
On the welcome screen, you can modify the Dev Environment Settings if you want.   
</br>
</br>

You will find an empty repository `3-tier-app`, with a readme.md, devfile.yaml, and some hidden folders. The `devfile.yaml`, contains the definition to build your application libraries and toolchain. You can ignore it for the purpose of this tutorial.

### Sample CloudFormation template

You can use your own CloudFormation template, or simply use one of the sample templates. 

For this blog, I am using a [sample template](https://raw.githubusercontent.com/build-on-aws/ci-cd-iac-aws-cloudformation/main/cloudformation-templates/VPC_AutoScaling_With_Public_IPs.json) that deploys a VPC with 2 subnets and publicly accessible Amazon EC2 instances that are in an Auto Scaling group behind a Load Balancer form. Feel free to use the same as I will be making changes to this template and run a pull request workflow.

>In the real world, you would deploy the networking infrastructure and application deployment in separate CloudFormation templates. However, to keep your first deployment with CodeCatalyst simple, let's deploy everything in a single template.

Let's ensure we commit our changes to our git repo using the following commands:
```bash
# go to the root folder of the repo and run following

$ cd 3-tier-app/
$ wget https://raw.githubusercontent.com/build-on-aws/ci-cd-iac-aws-cloudformation/main/cloudformation-templates/VPC_AutoScaling_With_Public_IPs.json

# check git status
$ git status

# add changed files, commit and push to the git repo
$ git add . -A
$ git commit -m "Uploading first CloudFormation template"
$ git push
```

**Output :** 
```bash
$ git status
On branch main
Your branch is up to date with 'origin/main'.

Untracked files:
  (use "git add <file>..." to include in what will be committed)
        VPC_AutoScaling_With_Public_IPs.json

nothing added to commit but untracked files present (use "git add" to track)

$ git add .
$ git commit -m "Uploading first CloudFormation template"
[main eca3764] Uploading first CloudFormation template
 1 file changed, 560 insertions(+)
 create mode 100644 VPC_AutoScaling_With_Public_IPs.json

$ git push
Enumerating objects: 4, done.
Counting objects: 100% (4/4), done.
Delta compression using up to 2 threads
Compressing objects: 100% (3/3), done.
Writing objects: 100% (3/3), 4.59 KiB | 4.59 MiB/s, done.
Total 3 (delta 0), reused 0 (delta 0), pack-reused 0
remote: Validating objects: 100%
To https://git.us-west-2.codecatalyst.aws/v1/CloudFormation-CodeCatalyst/ThreeTierApp/3-tier-app
   cbbfab7..eca3764  main -> main
```
</br>

You can verify if the CloudFormation template is successfully updated in the repo - in the CodeCatalyst console, click `Code` in the left-side navigation menu, then select `Source repositories`. A new file `VPC_AutoScaling_With_Public_IPs.json` should be added to the repo.

</br>

## Setting up workflows to deploy non-prod environment

Next step is to create automated workflows. The intention is whenever a commit is pushed to the main branch, trigger automated actions. In our case, we are defining only one action - deploy the updated CloudFormation template and/or update the stack.

Now you have 2 options for creating a workflow : 
1. Create Workflow using Code Catalyst Console in Visual drag-drop method [navigate to CI/CD -> Workflows]
2. Create Workflow using the dev environment using yaml [the method we are following in the blog]

To create the workflow, create a hidden folder in your repo and add a `main_branch.yaml` file:

```bash
# go to the root folder of the repo and run following

mkdir -p .codecatalyst/workflows
touch .codecatalyst/workflows/main_branch.yaml
```
</br>

Open `.codecatalyst/workflows/main_branch.yaml` in your IDE, and add the following. Remember to 
- replace the placeholder AWS account ID `123456789012` with the value of your account, and the IAM role name `main_branch_IAM_role`, if you changed it
- if you are using your own CloudFormation template, replace the CloudFormation filename in `template`, 
</br>

* main_branch.yaml
``` yaml
Name: Main_Branch_Workflow
SchemaVersion: "1.0"

# Optional - Set automatic triggers.
Triggers:
  - Type: Push
    Branches:
      - main

# Required - Define action configurations.
Actions:
  DeployAWSCloudFormationstack_7c:
    Identifier: aws/cfn-deploy@v1
    Configuration:
      parameter-overrides: SSHLocation=54.10.10.2/32,WebServerInstanceType=t2.micro
      capabilities: CAPABILITY_IAM,CAPABILITY_NAMED_IAM,CAPABILITY_AUTO_EXPAND
      template: VPC_AutoScaling_With_Public_IPs.json
      region: us-west-2
      name: PreProdEnvStack
    Timeout: 10
    Environment:
      Connections:
        - Role: main_branch_IAM_role
          Name: "123456789012"
      Name: PreProdEnv
    Inputs:
      Sources:
        - WorkflowSource
```
</br>

In the workflow, we have provided parameter values for the CloudFormation stack creation. If you are using your own template, make sure you modify the parameter-overrides section and the template name accordingly.

Let's try out our new workflow! 

First, we need to stage, commit, and push our changes directly to the main branch - this is needed as only workflows committed to the repo will be run by CodeCatalyst. 

Use the following commands:
```bash
$ git add . -A
$ git commit -m "Adding main branch workflow"
$ git push
```

**Output :** 

```bash
$ git add . -A
$ git commit -m "Adding main branch workflow"
[main 5677f67] Adding main branch workflow
 1 file changed, 28 insertions(+)
 create mode 100644 .codecatalyst/workflows/main_branch.yaml
$ git push
Enumerating objects: 6, done.
Counting objects: 100% (6/6), done.
Delta compression using up to 2 threads
Compressing objects: 100% (3/3), done.
Writing objects: 100% (5/5), 911 bytes | 455.00 KiB/s, done.
Total 5 (delta 0), reused 0 (delta 0), pack-reused 0
remote: Validating objects: 100%
To https://git.us-west-2.codecatalyst.aws/v1/CloudFormation-CodeCatalyst/ThreeTierApp/3-tier-app
   eca3764..5677f67  main -> main
```
</br>

In your browser, navigate to the `CI/CD` -> `Workflows` page. You should see the workflow running:

![CodeCatalyst Workflow recent runs started automatically](images/cc_workflow_run.png)
 
</br>
 
If you click on Recent runs to expand it, you will see the details of the currently running job. Click on the job ID (Run-XXXXX) to view the different stages of the build:

![CodeCatalyst Workflow run success](images/cc_main_workflow_run_success.png)
 
</br>
 
It will take sometime for CodeCatalyst to go through all the stages and deploy the CloudFormation stack. The stack deployment time depends on the resources defined in the template. For example, this deployment was done in 3mins 48 seconds. 

Great our CloudFormation stack is successfully deployed by the Workflow! You can find the CloudFormation outputs in the `Variables` tab. 

![CodeCatalyst Workflow run variables output website](images/cc_workflow_run_variables_output.png)
 
</br>
 
If you open the Website link, you can access the sample application deployed by this template. 
![CodeCatalyst Workflow website sample application](images/website_cfn_sample_appln.png)
 
</br>
 
> It might happen that the run fails due to errors. Read through the logs, to understand the issue and remediate it. If you get internal error, at this point it is good to check the  stack deployment in the CloudFormation dashboard of AWS Management Console. If the CloudFormation stack has rolled back, then delete the stack manually, fix the issues and run workflow again. You can find help in [Documentation for Troubleshooting](https://docs.aws.amazon.com/codecatalyst/latest/userguide/troubleshooting.html), [Premium Support center](https://support.console.aws.amazon.com/support/home#/) or [AWS re:Post](https://repost.aws/tags/TAT_2FdxcETxyhEvwsLjVZaA/amazon-code-catalyst). 


## Make code changes with Pull Request Workflow
Lets say you now want to make changes to the infrastructure. For example, we want to add a third subnet to the VPC, update LoadBalancer and Autoscaling groups to use it. 

As a **best practice**, you should never make changes directly to the main branch. We should always create a separate branch on which changes will be done, and once these changes are approved by reviewers they will be merged with main branch. There are many git branching strategies that you can explore and use for your specific org/team needs. 

For this blog, I am keeping it simple. Anytime I need to make changes, I am creating a new branch _(step2)_ and I make new changes to infrastructure here _(step3)_. I then create a Pull Request (PR) to merge the new branch with main branch. As shown in the image, anytime a PR is opened _(step4)_, CodeCatalyst will automatically run PR workflow to create a changeset _(step5)_. A ChangeSet allows you to preview how proposed changes to a stack might impact your currently running resources, you can then decide if you want to execute the changes or not.

Once a reviewer approves the changes, and proceeds with merging the pull request _(step6)_, the `main_workflow` that we created earlier will automatically merge the code and deploy changes to `PreProdEnv`, my non-prod environment _(step7)_. You might have different branching strategies and more tests for your production environment deployment.


![Branches and workflows used in the blog](images/branching_workflows_blog_sequence.png)

We are going to first write a PR workflow, so that anytime a new Pull request is created CodeCatalyst will first run this workflow. In this PR workflow, we are **NOT deploying** any changes to the PreProdEnv. When a PR is opened or revised, we are validating it using [super-linter](https://github.com/marketplace/actions/super-linter) and then creating a CloudFormation changeset. 

Create a new file `pr_branch.yaml` in the hidden `.codecatalyst/workflows/` directory and paste following. 

Remember to :
- replace the placeholder AWS account ID `123456789012` with the value of your account, and the IAM role name `main_branch_IAM_role`, if you changed it
- if you are using your own CloudFormation template, replace the CloudFormation filename in `template`, 

</br>

* pr_branch.yaml
```yaml
Name: PR_Branch_Workflow
SchemaVersion: "1.0"

# Optional - Set automatic triggers.
Triggers:
  - Type: PULLREQUEST
    Branches:
      - main
    Events:
      - OPEN
      - REVISION

# Required - Define action configurations.
Actions:
  Super-Linter_0d:
    # Identifies the action. Do not modify this value.
    Identifier: aws/github-actions-runner@v1

    # Specifies the source and/or artifacts to pass to the action as input.
    Inputs:
      # Optional
      Sources:
        - WorkflowSource # This specifies that the action requires this Workflow as a source

    # Defines the action's properties.
    Configuration:
      # Required - Steps are sequential instructions that run shell commands
      # Action URL: https://github.com/marketplace/actions/super-linter
      # Please visit the action URL to look for examples on the action usage.
      # Be aware that a new version of the action could be available on GitHub.
      Steps:
        - name: Lint Code Base
          uses: github/super-linter@v4
          env:
            VALIDATE_CLOUDFORMATION: "true"
  CreateChangeSet:
    Identifier: aws/cfn-deploy@v1
    DependsOn: 
      - Super-Linter_0d    
    Configuration:
      parameter-overrides: SSHLocation=54.10.10.2/32,WebServerInstanceType=t2.micro
      capabilities: CAPABILITY_IAM,CAPABILITY_NAMED_IAM,CAPABILITY_AUTO_EXPAND
      no-execute-changeset: "1"
      template: VPC_AutoScaling_With_Public_IPs.json
      region: us-west-2
      name: PreProdEnvStack
    Timeout: 10
    Environment:
      Connections:
        - Role: pr_branch_IAM_role
          Name: "123456789012"
      Name: PreProdEnv
    Inputs:
      Sources:
        - WorkflowSource
```
</br>

In the above Pull Request Workflow, notice following definitions :

1. In the `Super-Linter_0d` action, we are defining `VALIDATE_CLOUDFORMATION: "true"` environment variable. This ensures that our CloudFormation template is validated using the `cfn-lint` github action. [cfn-lint](https://github.com/aws-cloudformation/cfn-lint) is an open source tool that helps validate AWS CloudFormation yaml/json templates against the [AWS CloudFormation Resource Specification](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/cfn-resource-specification.html) and additional checks. Includes checking valid values for resource properties and best practices.

2. In the `CreateChangeSet` action, the `no-execute-changeset: "1"`option in the workflow below, it indicates whether to run the change set or have it reviewed. Default is `'0'`, which means it will run the change set. We don't want it to execute the changes, we just want to see the changes that will happen if PR is merged, hence we set it to `'1'`, do not execute the changeset.

3. In the `CreateChangeSet` action, we have added a new property `DependsOn: - Super-Linter_0d`. This tells the workflow to first run `Super-Linter_0d` action, and if it is successful, only then run the `CreateChangeSet` action.

 
Now stage, commit, and push our changes directly to the main branch using following commands:
``` bash
$ git add . -A
$ git commit -m "Adding PR branch workflow"
$ git push
```

**Output :** 
``` bash
$ git add . -A
$ git commit -m "Adding PR branch workflow"
[main e844b70] Adding PR branch workflow
 1 file changed, 1 insertion(+), 1 deletion(-)
$ git push
Enumerating objects: 9, done.
Counting objects: 100% (9/9), done.
Delta compression using up to 2 threads
Compressing objects: 100% (4/4), done.
Writing objects: 100% (5/5), 451 bytes | 225.00 KiB/s, done.
Total 5 (delta 2), reused 0 (delta 0), pack-reused 0
remote: Validating objects: 100%
To https://git.us-west-2.codecatalyst.aws/v1/CloudFormation-CodeCatalyst/ThreeTierApp/3-tier-app
   d410f15..e844b70  main -> main
```
</br>
 
CodeCatalyst will then create another workflow. You can confirm this from the CodeCatalyst console CI/CD -> Workflow. You can see that `PR_Branch_Workflow`  is created but it has not run.

![CodeCatalyst PR Branch Workflow added](images/cc_pr_branch_workflow.png)
</br>

If you click on the `PR_Branch_Workflow`, you can see the workflow. As defined in the workflow yaml above, the workflow will run the  action `Super-Linter_0d` first and if it is successful, only then it will run action `CreateChangeSet`.

 ![CodeCatalyst PR Branch Workflow sequence and dependency](images/cc_pr_workflow.png)

Now lets go back to our Dev Environment and before we start making changes to the CloudFormation template, ensure we have created a new test-pr-workflow branch. 

**Output :** 
``` bash
$ git checkout -b test-pr-workflow
Switched to a new branch 'test-pr-workflow'
```

### Make changes to Cloudformation template

- If you are using **your own CloudFormation template**, make any changes to the template to create a change set. 

- **For the sample CloudFormation template** used in this blog, you have **2 options** : 
  - simply **replace its content** with [this already modified template](https://raw.githubusercontent.com/build-on-aws/ci-cd-iac-aws-cloudformation/main/cloudformation-templates/VPC_AutoScaling_With_Public_IPs-3-subnets.json). Make sure the name of template file is same(*VPC_AutoScaling_With_Public_IPs.json*), as workflow has filename mentioned in it, 
  
      OR

  - you can **make following changes manually** to add third subnet and its resources to the template :

    Add following JSON code to the sample CloudFormation template under `Resources` section. 

      ``` JSON
        "PublicSubnet3" : {
          "Type" : "AWS::EC2::Subnet",
          "Properties" : {
            "VpcId" : { "Ref" : "VPC" },
            "CidrBlock" : { "Fn::FindInMap" : [ "SubnetConfig", "Public3", "CIDR" ]},
            "AvailabilityZone" : {"Fn::Select": [2, {"Fn::GetAZs": ""}]},
            "Tags" : [
              { "Key" : "Application", "Value" : { "Ref" : "AWS::StackId" } },
              { "Key" : "Network", "Value" : "Public" }
            ]
          }
        },
        "PublicSubnetRouteTableAssociation3" : {
          "Type" : "AWS::EC2::SubnetRouteTableAssociation",
          "Properties" : {
            "SubnetId" : { "Ref" : "PublicSubnet3" },
            "RouteTableId" : { "Ref" : "PublicRouteTable" }
          }
        },
        "PublicSubnetNetworkAclAssociation3" : {
          "Type" : "AWS::EC2::SubnetNetworkAclAssociation",
          "Properties" : {
            "SubnetId" : { "Ref" : "PublicSubnet3" },
            "NetworkAclId" : { "Ref" : "PublicNetworkAcl" }
          }
        },
      ```
 
     In the Mappings, LoadBalancer and AutoScaling resources, add the `PublicSubnet3` like following :

    ```JSON
        "Mappings" : {
          "SubnetConfig" : {
            "VPC"     : { "CIDR" : "10.0.0.0/16" },
            "Public1" : { "CIDR" : "10.0.0.0/24" },
            "Public2" : { "CIDR" : "10.0.1.0/24" },
            "Public3" : { "CIDR" : "10.0.2.0/24" } 
          },
    ```

    ```JSON
        "WebServerFleet" : {
          "Type" : "AWS::AutoScaling::AutoScalingGroup",
          "DependsOn" : "PublicRoute",
          "Properties" : {
            "VPCZoneIdentifier" : [{ "Ref" : "PublicSubnet1" }, { "Ref" : "PublicSubnet2" },  { "Ref" : "PublicSubnet3" }],
    ```
    ```JSON
        "PublicApplicationLoadBalancer" : {
          "Type" : "AWS::ElasticLoadBalancingV2::LoadBalancer",
          "Properties" : {
            "Subnets" : [ { "Ref" : "PublicSubnet1"}, { "Ref" : "PublicSubnet2" },  { "Ref" : "PublicSubnet3" }  ],
            "SecurityGroups" : [ { "Ref" : "PublicLoadBalancerSecurityGroup" } ]
          }
        },
    ```
</br>

Now save the modified file and push it to the `test-pr-workflow` branch, using  following commands:
```bash
$ git add .
$ git commit -m "Added third public subnet to VPC, RouteTable, NACL, LoadBalancer and ASG"
$ git push --set-upstream origin test-pr-workflow
``` 
</br> 

**Output :** 

```bash
$ git status
On branch test-pr-workflow
Changes not staged for commit:
  (use "git add <file>..." to update what will be committed)
  (use "git restore <file>..." to discard changes in working directory)
        modified:   VPC_AutoScaling_With_Public_IPs.json

no changes added to commit (use "git add" and/or "git commit -a")

$ git add .
$ git commit -m "Added third public subnet to VPC, RouteTable, NACL, LoadBalancer and ASG"
[test-pr-workflow e1a1d0e] Added third public subnet to VPC, RouteTable, NACL, LoadBalancer and ASG
 1 file changed, 33 insertions(+), 4 deletions(-)

$ git push --set-upstream origin test-pr-workflow
Enumerating objects: 5, done.
Counting objects: 100% (5/5), done.
Delta compression using up to 2 threads
Compressing objects: 100% (3/3), done.
Writing objects: 100% (3/3), 467 bytes | 467.00 KiB/s, done.
Total 3 (delta 2), reused 0 (delta 0), pack-reused 0
remote: Validating objects: 100%
To https://git.us-west-2.codecatalyst.aws/v1/CloudFormation-CodeCatalyst/ThreeTierApp/3-tier-app
 * [new branch]      test-pr-workflow -> test-pr-workflow
branch 'test-pr-workflow' set up to track 'origin/test-pr-workflow'.

```
</br>
 
In the CodeCatalyst Console, navigate to `Code` -> `Repository`. You can see the 2 branches `main` and `test-pr-workflow`.

![CodeCatalyst two branches main default and test-pr-workflow](images/cc_branches.png)
</br>
 
## Create Pull Request and merge code
Now that we have all changes in the branch named `test-pr-workflow`, you can ask others to review the changes by creating a pull request. 

Perform following steps to create pull request to compare the changes in the test branch with the main branch. Goto Code -> Pull requests in the CodeCatalyst console. Click on `Create pull request` and enter following details:

- Source repository : `3-tier-app`
- Source branch : `test-pr-workflow`
- Destination branch : `main`
- Pull request title: `Merge new third subnet`
- Pull request description: `New third subnet created and added to VPC, RouteTable, NACL, LoadBalancer, ASG`

![CodeCatalyst Create Pull request Dialog](images/cc_create_pull_request.png)
</br>
 
You can optionally add reviewers to approve/deny the merge.

Note, that our source branch is `test-pr-workflow` and our destination for merge is the `main` branch. Once this PR is created, it will trigger the `PR_Branch_Workflow` that will create a CloudFormation changeset (and not make any deployments!). 

>To see the active run for `PR_Branch_Workflow`, in the CodeCatalyst console, navigate to the `CI/CD` -> `Workflows` page and ensure you select the `test-pr-workflow` branch. By default, the Workflows page always shows the `main` branch. You have to switch branches to see the active workflow in other branches.

</br>

Now you might notice, that this run on `PR_Branch_Workflow` has `failed`.
![CodeCatalyst run on PR_Branch_Workflow has failed](images/cc_pr_branch_lint_failed.png)
</br>

If you expand the _**Lint Code Base**_ you will find following :
```LOG
[INFO]   --------------------------------------------
[INFO]   Gathering user validation information...
[INFO]   - Validating ALL files in code base...
[INFO]   ----------------------------------------------
[INFO]   Linting [CLOUDFORMATION] files...
[INFO]   ----------------------------------------------
[INFO]   File:[/github/workspace/VPC_AutoScaling_With_Public_IPs.json]
[ERROR]   Found errors in [cfn-lint] linter!
[ERROR]   Error code: 4. Command output:
------
W7001 Mapping 'AWSInstanceType2NATArch' is defined but not used
/github/workspace/VPC_AutoScaling_With_Public_IPs.json:56:5
------
[INFO]   ----------------------------------------------
[INFO]   The script has completed
[INFO]   ----------------------------------------------
[ERROR]   ERRORS FOUND in CLOUDFORMATION:[1]
[FATAL]   Exiting with errors found!
```
</br>

So, our CloudFormation template did parse through cfn-lint and found one error. We have a mapping resource that is defined but never used anywhere in the template. We should delete this in the template file and push changes to the `test-pr-workflow`

So, back in the Dev Environment on AWS Cloud9  **remove** following block from the CloudFormation template : 

```JSON
    "AWSInstanceType2NATArch" : {
      "t1.micro"    : { "Arch" : "NATHVM64"  },
      "t2.nano"     : { "Arch" : "NATHVM64"  },
      "t2.micro"    : { "Arch" : "NATHVM64"  },
      "t2.small"    : { "Arch" : "NATHVM64"  },
      "t2.medium"   : { "Arch" : "NATHVM64"  },
      "t2.large"    : { "Arch" : "NATHVM64"  },
      "m4.large"    : { "Arch" : "NATHVM64"  },
      "m4.xlarge"   : { "Arch" : "NATHVM64"  },
      "c1.medium"   : { "Arch" : "NATHVM64"  }
    },
```
</br>

Save the file, stage, commit and push the changes to `test-pr-workflow` branch. As this is a revision to the branch, it should automatically trigger the workflow to run again.

```bash
$ git add .
$ git commit -m "Removed unused AWSInstanceType2NATArch mapping"
$ git push --set-upstream origin test-pr-workflow
``` 
</br> 

Output : 
```
$ git add .
$ git commit -m "Removed unused AWSInstanceType2NATArch mapping"
[test-pr-workflow 64a27b5] Removed unused AWSInstanceType2NATArch mapping
 1 file changed, 1 insertion(+), 11 deletions(-)
$ git push  --set-upstream origin test-pr-workflow
Enumerating objects: 5, done.
Counting objects: 100% (5/5), done.
Delta compression using up to 2 threads
Compressing objects: 100% (3/3), done.
Writing objects: 100% (3/3), 319 bytes | 159.00 KiB/s, done.
Total 3 (delta 2), reused 0 (delta 0), pack-reused 0
remote: Validating objects: 100%
To https://git.us-west-2.codecatalyst.aws/v1/CloudFormation-CodeCatalyst/ThreeTierApp/3-tier-app
   1f8e97d..64a27b5  test-pr-workflow -> test-pr-workflow
branch 'test-pr-workflow' set up to track 'origin/test-pr-workflow'.
```
</br>

In your browser, navigate to the `CI/CD` -> `Workflows` page. Make sure you select the `test-pr-workflow` branch. A new run should now be active.

You can confirm the new workflow has run successfully.
![Alt text](images/cc_super_lint_success_1.png)
</br>

If you expand on _**Lint Code Base**_, you will find following text that identifies no errors :
```LOG
[INFO]   --------------------------------------------
[INFO]   Gathering user validation information...
[INFO]   - Validating ALL files in code base...
[INFO]   ----------------------------------------------
[INFO]   Linting [CLOUDFORMATION] files...
[INFO]   ----------------------------------------------
[INFO]   File:[/github/workspace/VPC_AutoScaling_With_Public_IPs.json]
[INFO]   - File:[VPC_AutoScaling_With_Public_IPs.json] was linted
[INFO]   ----------------------------------------------
[INFO]   The script has completed
[INFO]   ----------------------------------------------
[NOTICE]   All file(s) linted successfully with no errors detected
```
</br>

Now, the workflow will proceed to next action `CreateChangeSet`. 

![CodeCatalyst PR Workflow CreateChangeSet Success](images/cc_createchangeset_success.png)
</br>

Once the action is successful, you can goto CloudFormation Console, Changeset tab and verify the changes proposed by the new pull request. 

![Console CloudFormation Changeset ](images/console_cfn_change_set.png)
</br>

A reviewer will confirm that all the actions have run successfully, the changeset is clean. In our case, I am the reviewer so in my browser, I will goto the `Code` -> `Pull Requests`, and then click on `Merge`.

>If there are conflicts, or if the merge can't be completed, the merge button is inactive, and a `Not mergeable` label is displayed. In that case, you must obtain approval from any required approvers, resolve conflicts locally if necessary, and push those changes to the `test-pr-workflow` before you can merge. 

![CodeCatalyst Mergeable request is all green](images/cc_mergeable_request.png)

</br>
At this point you have 2 options for merge strategies. :

1. **Fast forward merge** - Merges the branches and moves the destination branch pointer to the tip of the source branch. This is the default merge strategy in Git. **Select this option** for this blog. 
</br>

2. **Squash and merge** - Combines all commits from the source branch into single merge commit in the destination branch.

You can optionally, delete the source branch after merging this pull request. 
In our case, the source branch is `test-pr-workflow` and I am deleting this branch to keep my branching structure clean and simple. 

![CodeCatalyst Merge Pull request](images/cc_merge_pull_request.png)
</br>
 
Once you click on merge, CodeCatalyst will merge the code changes from `test-pr-workflow` to `main` branch. This will trigger the `Main_Branch_Workflow` and deploy the updated CloudFormation code to the `PreProdEnv`.

You can optionally confirm the newly created subnet in the VPC console.

![AWS Console displaying details of the VPC and new subnet just created](images/console_vpc_view.png)
 
</br>
 

## Cleanup

We have now reached the end of this tutorial, we learned how to create workflows, pull request, how to use actions - to create ChangeSet, to deploy CloudFormation stack and to run cfn-lint on our template before we make infrastructure changes. 
you can further explore the features of CodeCatalyst like inviting team members, or creating issues. If you no longer wish to explore further, then delete all the resources we created here. Cleanup CloudFormation stacks in your AWS account. Open the [AWS CloudFormation console](https://console.aws.amazon.com/cloudformation), delete the `PreProdEnvStack` and `CodeCatalyst-IAM-roles`.

To delete the project we created in CodeCatalyst. In the left-hand navigation, go to `Project settings`, click on `Delete project`, and follow the instructions to delete the project.

Lastly, to delete the CodeCatalyst space, goto [CodeCatalyst dashboard](https://codecatalyst.aws/spaces/), then `Space settings` tab and click on `Delete space`.

</br>

## Conclusion

Congratulations! You've now learned how to deploy Infrastructure as Code using CloudFormation with CodeCatalyst, and can deploy any infrastructure changes using a pull request workflow. If you enjoyed this tutorial, found an issues, or have feedback us, [please send it our way!](https://pulse.buildon.aws/survey/DEM0H5VW)
