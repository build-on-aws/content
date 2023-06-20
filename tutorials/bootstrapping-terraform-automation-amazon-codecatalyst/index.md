---
title: "Bootstrapping your Terraform automation with Amazon CodeCatalyst"
description: "A walk-through of how to set up Terraform with Amazon CodeCatalyst from scratch to create a CI/CD pipeline for your infrastructure"
tags:
    - terraform
    - codecatalyst
    - ci-cd
    - tutorials
    - infrastructure-as-code
    - aws
    - github-actions
    - devops
spaces:
  - devops
showInHomeFeed: true
authorGithubAlias: cobusbernard
authorName: Cobus Bernard
date: 2023-01-31
---

Terraform is awesome to manage all your infrastructure, but when you have more than one developer trying to make changes to the infrastructure, things can get messy very quickly if there isn't a mechanism ([CI/CD pipeline](/concepts/devops-essentials/#continuous-integration-and-continuous-delivery)) in place to manage it. Without one, making changes to any infrastructure requires coordination and communication, and the challenge quickly scales the more people that are involved with making these changes. Imagine having to run around shouting *"Hey Bob! Hey Jane! You done yet with that DB change? I need to add a new container build job!"*. As Jeff Bezos said:

> ***"Good intentions never work, you need good mechanisms to make anything happen."***

This tutorial will show you how to set up a CI/CD pipeline using Amazon [CodeCatalyst](https://codecatalyst.aws?sc_channel=el&sc_campaign=devopswave&sc_content=cicdctfbtstrpaws&sc_geo=mult&sc_country=mult&sc_outcome=acq) and [Terraform](https://www.terraform.io/). The pipeline will utilize pull requests to submit, test, and review any changes requested to the infrastructure. We will cover the following topics in this tutorial:

- Using S3 as a backend for Terraform [state files](https://developer.hashicorp.com/terraform/language/state), with [DynamoDB for locking](https://developer.hashicorp.com/terraform/language/settings/backends/s3#dynamodb-table-permissions), and encrypting the state file at rest with KMS
- CodeCatalyst to run our CI/CD pipelines to create and update all your infrastructure

## Table of Contents

| Attributes             |                                                                 |
|------------------------|-----------------------------------------------------------------|
| ✅ AWS experience      | 200 - Intermediate                                              |
| ⏱ Time to complete     | 30 minutes                                                      |
| 💰 Cost to complete    | Free tier eligible                                               |
| 🧩 Prerequisites       | - [AWS Account](https://aws.amazon.com/resources/create-account/?sc_channel=el&sc_campaign=devopswave&sc_content=cicdctfbtstrpaws&sc_geo=mult&sc_country=mult&sc_outcome=acq)<br>- [CodeCatalyst Account](https://codecatalyst.aws?sc_channel=el&sc_campaign=devopswave&sc_content=cicdctfbtstrpaws&sc_geo=mult&sc_country=mult&sc_outcome=acq)<br>- [Terraform](https://terraform.io/) 1.3.7+<br>- (Optional) [GitHub](https://github.com) account|
| 💻 Code Sample         | Code sample used in tutorial on [GitHub](https://github.com/build-on-aws/bootstrapping-terraform-automation)                             |
| 📢 Feedback            | <a href="https://pulse.buildon.aws/survey/DEM0H5VW" target="_blank">Any feedback, issues, or just a</a> 👍 / 👎 ?    |
| ⏰ Last Updated        | 2023-02-22                                                      |

| ToC |
|-----|

## Chicken and egg problem

Automating your infrastructure is a great idea, but you need infrastructure to automate your infrastructure. There are three approaches to doing this:

1. Clicking in the console to set everything up, aka ["ClickOps"](https://www.buildon.aws/concepts/devops-essentials/#clickops)
1. Using a CLI to create the resources for you with scripts, ["Procedural"](https://www.buildon.aws/concepts/devops-essentials/#procedural)
1. Using Terraform without storing the state file to bootstrap, then add in the state file configurations to store it

We will be using the 3rd option, have a look at the [Stack Overflow](https://stackoverflow.com/questions/47913041/initial-setup-of-terraform-backend-using-terraform/) discussion around approaches for more details on the trade-offs.
<!-- If you prefer to use the AWS CLI, a [script](https://github.com/build-on-aws/bootstrapping-terraform-automation-for-github-actions/_bootstrap/aws_cli_tf_bootstrap.sh) is also included in the code repo for this tutorial that you can run via [AWS CloudShell](https://docs.aws.amazon.com/cloudshell/latest/userguide/welcome.html?sc_channel=el&sc_campaign=devopswave&sc_content=cicdctfbtstrpaws&sc_geo=mult&sc_country=mult&sc_outcome=acq) in your AWS account see the [bootstrapping with AWS CLI and CloudShell](#bootstrapping-with-aws-cli-and-cloudshell) section further down. -->

## Getting started

Let's get started setting this up! Make sure you are logged into your AWS, and CodeCatalyst accounts in the same browser.

<!-- This guide will use CodeCatalyst Code Repositories, but you can also use GitHub. If you prefer GitHub, see the section on [setting up GitHub repo](#setting-up-dev-environment-with-github-repo) below, then come back to this step. -->

### Setting up a CodeCatalyst Space, Project, Repo, and Environment

Now, let's set up our CodeCatalyst Space and Project. Create a new space by clicking on `Create Space` on the [CodeCatalyst Dashboard](https://codecatalyst.aws?sc_channel=el&sc_campaign=devopswave&sc_content=cicdctfbtstrpaws&sc_geo=mult&sc_country=mult&sc_outcome=acq), add a name (we will use `Terraform CodeCatalyst`), add the AWS Account ID to link to for billing (`111122223333` is a placeholder), you can find your account ID in the top right of your AWS Console, and follow the prompts to link your AWS Account with CodeCatalyst.

![Dialog showing a CodeCatalyst Space after successfully adding an AWS account to it](./images/successful_space_created.png)

Next, we need to create a new Project, click on the `Create Project` button, select `Start from scratch`, and give your project a name - we will use `TerraformCodeCatalyst`.

![Dialog in CodeCatalyst to create a new project from scratch with name "TerraformCodeCatalyst"](./images/codecatalyst_create_project.png)

Now we need to create a new repository for our code. Click `Code` in the left-side navigation menu, then on `Source repositories`, `Add repository` and choose `Create repository`. Set a repository name (we will use `bootstrapping-terraform-automation-for-amazon-codecatalyst` in this tutorial), add a description, and `Terraform` for the `.gitignore file`:

![Dialog for creating a CodeCatalyst repo](./images/create_codecatalyst_repo.png)

<!-- (Optional): If you are using a GitHub repo, open the `Installed extensions` tab, and install the `GitHub repositories` extension by clicking on `Browse Amazon CodeCatalyst catalog` - this will take you through a series of steps to set up access. The next step is to link your AWS Account, and then we are ready to create our first project. -->

Lastly, we need to set up the AWS environment we will use for our workflow. In the left-side navigation menu, click on `CI/CD`, then on `Environments`, and then `Create environment`. Add the `Environment name`, `Description`, choose your AWS account from the dropdown under `AWS account connection`, and click `Create environment`.

![Dialog to create an environment in a CodeCatalyst project](./images/codecatalyst_create_environment.png)

### Setting up a Dev Environment

To start working on our code, we need to set up a development environment, and will be using the built-in ones provided by CodeCatalyst. In the left navigation menu, click on `Dev Environment` under `Code`, then `Create Dev Environment`, select `Cloud9` - this tutorial with use Cloud9. Select `Clone a repository`, select `bootstrapping-terraform-automation-for-amazon-code-catalyst` in the dropdown for `Repository`,  add an `Alias` of `TerraformBootstrap`, and then click the `Create` button.

![Dialog in CodeCatalyst to create a dev environment using a repo hosted by CodeCatalyst](./images/create_dev_environment_codecatalyst_repo.png)

It will take 1 - 2 minutes to provision your development environment, and once done, you will be presented with a welcome screen:

![Cloud9 web based IDE view](./images/cloud9_dev_environment.png)

The version of Terraform may not be the latest, you can check which version is installed by running `terraform --version`. This tutorial uses version 1.3.7, to ensure you are using that version, use the following commands:

🚨 NB: If you are using a local development environment instead of one managed by CodeCatalyst, the architecture / operating system may be different, please see the [downloads](https://developer.hashicorp.com/terraform/downloads) page to download the appropriate version of Terraform.

```bash
TF_VERSION=1.3.7
wget -O terraform.zip https://releases.hashicorp.com/terraform/${TF_VERSION}/terraform_${TF_VERSION}_linux_amd64.zip
unzip terraform.zip
rm terraform.zip
sudo mv terraform /usr/bin/terraform
sudo chmod +x /usr/bin/terraform

# Confirm correct version
terraform --version
```

Lastly, we need to add AWS CLI credentials to our Dev Environment to access resource in our account. It is recommended to not use the root user, if you have not yet set up an IAM user, please do so now by following the [instructions](https://aws.amazon.com/getting-started/guides/setup-environment/module-two/), and make sure to copy the `Access key ID` and `Secret access key` values, then run `aws configure` in the terminal of your dev environment (you can leave the last two default values blank, or enter values you prefer):

```bash
$ aws configure
AWS Access Key ID [None]: AKIAIOSFODNN7EXAMPLE
AWS Secret Access Key [None]: wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
Default region name [None]:
Default output format [None]:
```

You can verify that access is set up correctly by running `aws sts get-caller-identity` in the terminal:

```bash
$ aws sts get-caller-identity
{
    "UserId": "AIDACKCEVSQ6C2EXAMPLE",
    "Account": "111122223333",
    "Arn": "arn:aws:iam::111122223333:user/JaneDoe"
}
```

### Bootstrapping Terraform

Next, we need to add the required infrastructure to our AWS account using Terraform. We will be creating the following resources:

1. **IAM roles**: Provides the role for our workflow to assume in the account - one for the `main` branch, one for any pull requests (PRs).
1. **IAM policies**: Set the boundaries of what the workflow IAM roles may do in our account - full admin access for `main` branch allowing creation of infrastructure, `ReadOnly` for the PR branches to allow validating any changes.
1. **S3 bucket**: An S3 bucket to store our Terraform state file in.
1. **S3 bucket versioning**: Allows keeping backup copies of the Terraform state file each time it changes.
1. **DynamoDB Table**: Used by Terraform to create a lock while running - this prevents multiple CI jobs making changes when run in parallel.
1. **KMS Encryption Key**: (Optional) While the state file is stored in S3, we want to encrypt it while at rest using a KMS key. For this tutorial, we will use the pre-existing `aws/s3` key, if you prefer to use a different KMS key ($1/month/key), there will be a section below to describe how to make changes to do that.

To create all of the required files, you can use the following commands to create the directories, and download the files directly from the sample repository. Run the commands in the root of your cloned git repo via the dev environment terminal:

```bash
cd bootstrapping-terraform-automation-for-amazon-codecatalyst
mkdir -p _bootstrap
cd _bootstrap
wget https://raw.githubusercontent.com/build-on-aws/bootstrapping-terraform-automation/main/_bootstrap/codecatalyst/main_branch_iam_role.tf
wget https://raw.githubusercontent.com/build-on-aws/bootstrapping-terraform-automation/main/_bootstrap/codecatalyst/pr_branch_iam_role.tf
wget https://raw.githubusercontent.com/build-on-aws/bootstrapping-terraform-automation/main/_bootstrap/codecatalyst/providers.tf
wget https://raw.githubusercontent.com/build-on-aws/bootstrapping-terraform-automation/main/_bootstrap/codecatalyst/state_file_resources.tf
wget https://raw.githubusercontent.com/build-on-aws/bootstrapping-terraform-automation/main/_bootstrap/codecatalyst/variables.tf
```

The files created will have the following content:

* variables.tf
    ```terraform
    variable "aws_region" {
      default = "us-east-1"
    }

    variable "state_file_bucket_name" {
      default = "tf-state-files"
    }

    variable "state_file_lock_table_name" {
      default = "TerraformMainStateLock"
    }

    variable "kms_key_alias" {
      default = "Terraform-Main"
    }
    ```
* main_branch_iam_role.tf
    ```terraform
    # Policy allowing the main branch in our repo to assume the role.
    data "aws_iam_policy_document" "main_branch_assume_role_policy" {
      statement {
        actions = ["sts:AssumeRole"]
        principals {
          type        = "Service"
          identifiers = [
            "codecatalyst.amazonaws.com",
            "codecatalyst-runner.amazonaws.com"
          ]
        }
      }
    }

    # Role to allow the main branch to use this AWS account
    resource "aws_iam_role" "main_branch" {
      name               = "Main-Branch-Infrastructure"
      assume_role_policy = data.aws_iam_policy_document.main_branch_assume_role_policy.json
    }

    # Allow role admin rights in the account to create all infra
    resource "aws_iam_role_policy_attachment" "admin_policy_main_branch" {
      role       = aws_iam_role.main_branch.name
      policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
    }

    ```
* pr_branch_iam_role.tf
    ```terraform
    # Policy allowing the PR branches in our repo to assume the role. 
    data "aws_iam_policy_document" "pr_branch_assume_role_policy" {
      statement {
        actions = ["sts:AssumeRole"]
        principals {
          type        = "Service"
          identifiers = [
            "codecatalyst.amazonaws.com",
            "codecatalyst-runner.amazonaws.com"
          ]
        }
      }
    }

    # Role to allow PR branch to use this AWS account
    resource "aws_iam_role" "pr_branch" {
      name               = "PR-Branch-Infrastructure"
      assume_role_policy = data.aws_iam_policy_document.pr_branch_assume_role_policy.json
    }

    # Allow PR Branch read-only access in the account to run `plan`
    resource "aws_iam_role_policy_attachment" "readonly_policy_pr_branch" {
      role       = aws_iam_role.pr_branch.name
      policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
    }

    # Additional policy allowing read and write access to the DynamoDB table
    # to create locks when `plan` is run.
    data "aws_iam_policy_document" "pr_branch_lock_table_access" {
      statement {
        sid    = "DynamoDBIndexAndStreamAccess"
        effect = "Allow"
        actions = [
          "dynamodb:GetShardIterator",
          "dynamodb:Scan",
          "dynamodb:Query",
          "dynamodb:DescribeStream",
          "dynamodb:GetRecords",
          "dynamodb:ListStreams"
        ]
        resources = [
          "arn:aws:dynamodb:${var.aws_region}:${data.aws_caller_identity.current.account_id}:table/${var.state_file_lock_table_name}/index/*",
          "arn:aws:dynamodb:${var.aws_region}:${data.aws_caller_identity.current.account_id}:table/${var.state_file_lock_table_name}/stream/*"
        ]
      }

      statement {
        sid    = "DynamoDBTableAccess"
        effect = "Allow"
        actions = [
          "dynamodb:BatchGetItem",
          "dynamodb:BatchWriteItem",
          "dynamodb:ConditionCheckItem",
          "dynamodb:PutItem",
          "dynamodb:DescribeTable",
          "dynamodb:DeleteItem",
          "dynamodb:GetItem",
          "dynamodb:Scan",
          "dynamodb:Query",
          "dynamodb:UpdateItem"
        ]
        resources = [
          "arn:aws:dynamodb:${var.aws_region}:${data.aws_caller_identity.current.account_id}:table/${var.state_file_lock_table_name}"
        ]
      }

      statement {
        sid    = "DynamoDBDescribeLimitsAccess"
        effect = "Allow"
        actions = [
          "dynamodb:DescribeLimits"
        ]
        resources = [
          "arn:aws:dynamodb:${var.aws_region}:${data.aws_caller_identity.current.account_id}:table/${var.state_file_lock_table_name}",
          "arn:aws:dynamodb:${var.aws_region}:${data.aws_caller_identity.current.account_id}:table/${var.state_file_lock_table_name}/index/*"
        ]
      }

      statement {
        sid    = "KMSS3Acess"
        effect = "Allow"
        actions = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:GenerateDataKey"
        ]
        # NB: While we allow "*" access to all KMS resources, we limit it to only the
        # "alias/s3" default key with the `StringLike` condition.
        resources = ["*"]
        condition {
          test     = "StringLike"
          variable = "kms:RequestAlias"
          values = [
            "alias/s3"
          ]
        }
      }
    }

    # Create a policy that allows reading and writing to the lock table
    resource "aws_iam_policy" "lock_table_policy_pr_branch" {
      name   = "pr_branch_lock_table_access_policy"
      path   = "/"
      policy = data.aws_iam_policy_document.pr_branch_lock_table_access.json
    }

    # Allow PR branch read and write to the lock table for `plan`
    resource "aws_iam_role_policy_attachment" "lock_table_policy_pr_branch" {
      role       = aws_iam_role.pr_branch.name
      policy_arn = aws_iam_policy.lock_table_policy_pr_branch.arn
    }
    ```
* providers.tf
    ```terraform
    # Configuring the AWS provider
    provider "aws" {
      region = var.aws_region
    }

    # Used to retrieve the AWS Account Id
    data "aws_caller_identity" "current" {}
    ```
* state_file_resources.tf
    ```terraform
    # Bucket used to store our state file
    resource "aws_s3_bucket" "state_file" {
      bucket = var.state_file_bucket_name

      lifecycle {
        prevent_destroy = true
      }
    }

    # Enabling bucket versioning to keep backup copies of the state file
    resource "aws_s3_bucket_versioning" "state_file" {
      bucket = aws_s3_bucket.state_file.id

      versioning_configuration {
        status = "Enabled"
      }
    }

    # Table used to store the lock to prevent parallel runs causing issues
    resource "aws_dynamodb_table" "state_file_lock" {
      name           = var.state_file_lock_table_name
      read_capacity  = 5
      write_capacity = 5
      hash_key       = "LockID"

      attribute {
        name = "LockID"
        type = "S"
      }
    }

    ## (Optional) KMS Key and alias to use instead of default `alias/s3` one.
    # resource "aws_kms_key" "terraform" {
    #   description = "Key used for Terraform state files."
    # }

    # resource "aws_kms_alias" "terraform" {
    #   name          = "alias/terraform"
    #   target_key_id = aws_kms_key.terraform.key_id
    # }
    ```

Once done, edit the `_bootstrap/variable.tf` file and update the `state_file_bucket_name` (S3 bucket names are globally unique), and optionally the `state_file_lock_table_name` variables with the values for your S3 bucket name for the state file, DynamoDB table name for locks, and optionally change the `aws_region` if you want to use a different region.

We will now bootstrap our infrastructure (the body of each Terraform resource from the `terraform plan` command has been omitted using `...`):

```bash
terraform init
terraform plan
```

The output should look like:

```bash
$ terraform init

Initializing the backend...

Initializing provider plugins...
- Finding latest version of hashicorp/aws...
- Installing hashicorp/aws v4.53.0...
- Installed hashicorp/aws v4.53.0 (signed by HashiCorp)

Terraform has created a lock file .terraform.lock.hcl to record the provider
selections it made above. Include this file in your version control repository
so that Terraform can guarantee to make the same selections by default when
you run "terraform init" in the future.

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
```

```bash
$ terraform plan
data.aws_caller_identity.current: Reading...
data.aws_iam_policy_document.pr_branch_assume_role_policy: Reading...
data.aws_iam_policy_document.main_branch_assume_role_policy: Reading...
data.aws_iam_policy_document.pr_branch_assume_role_policy: Read complete after 0s [id=2789987180]
data.aws_iam_policy_document.main_branch_assume_role_policy: Read complete after 0s [id=2789987180]
data.aws_caller_identity.current: Read complete after 0s [id=111122223333]
data.aws_iam_policy_document.pr_branch_lock_table_access: Reading...
data.aws_iam_policy_document.pr_branch_lock_table_access: Read complete after 0s [id=813239658]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_dynamodb_table.state_file_lock will be created
  ...
  # aws_iam_policy.lock_table_policy_pr_branch will be created
  ...
  # aws_iam_role.main_branch will be created
  ...
  # aws_iam_role.pr_branch will be created
  ...
  # aws_iam_role_policy_attachment.admin_policy_main_branch will be created
  ...
  # aws_iam_role_policy_attachment.lock_table_policy_pr_branch will be created
  ...
  # aws_iam_role_policy_attachment.readonly_policy_pr_branch will be created
  ...
  # aws_s3_bucket.state_file will be created
  ...
  # aws_s3_bucket_versioning.state_file will be created
  ...

  Plan: 9 to add, 0 to change, 0 to destroy.
```

The `plan` command will output a list of resources to create, and you can take a look at exactly what it will create. Once you are satisfied, run `terraform apply`, and confirm the infrastructure creation.

```bash
$ terraform apply
...
Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

aws_dynamodb_table.state_file_lock: Creating...
aws_iam_role.pr_branch: Creating...
aws_s3_bucket.state_file: Creating...
aws_iam_role.main_branch: Creating...
aws_iam_policy.lock_table_policy_pr_branch: Creating...
aws_iam_policy.lock_table_policy_pr_branch: Creation complete after 1s [id=arn:aws:iam::111122223333:policy/pr_branch_lock_table_access_policy]
aws_iam_role.pr_branch: Creation complete after 1s [id=PR-Branch-Infrastructure]
aws_iam_role.main_branch: Creation complete after 1s [id=Main-Branch-Infrastructure]
aws_iam_role_policy_attachment.lock_table_policy_pr_branch: Creating...
aws_iam_role_policy_attachment.readonly_policy_pr_branch: Creating...
aws_iam_role_policy_attachment.admin_policy_main_branch: Creating...
aws_iam_role_policy_attachment.admin_policy_main_branch: Creation complete after 1s [id=Main-Branch-Infrastructure-20230203124909419300000001]
aws_iam_role_policy_attachment.lock_table_policy_pr_branch: Creation complete after 1s [id=PR-Branch-Infrastructure-20230203124909423900000002]
aws_iam_role_policy_attachment.readonly_policy_pr_branch: Creation complete after 1s [id=PR-Branch-Infrastructure-20230203124909427700000003]
aws_s3_bucket.state_file: Creation complete after 2s [id=ttf-state-files]
aws_s3_bucket_versioning.state_file: Creating...
aws_s3_bucket_versioning.state_file: Creation complete after 1s [id=tf-state-files]
aws_dynamodb_table.state_file_lock: Creation complete after 7s [id=TerraformMainStateLock]

Apply complete! Resources: 9 added, 0 changed, 0 destroyed.
```

Next, we will move the state file we just created with all the details of our infrastructure to our S3 bucket. To do this, we need to configure a Terraform [backend](https://developer.hashicorp.com/terraform/language/settings/backends/configuration) using S3. Create `_bootstrap/terraform.tf` with the following, and update the `bucket` and `region` values with your values:

```terraform
terraform {
  backend "s3" {
    bucket         = "tf-state-files"
    key            = "terraform-bootstrap-state-files/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "TerraformMainStateLock"
    kms_key_id     = "alias/s3" # Optionally change this to the custom KMS alias you created - "alias/terraform"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.33"
    }
  }
  
  required_version = "= 1.3.7"
}
```

It would be easier if we could reference `region` and `state_file_bucket` variables in the Terraform backend configuration, but it [does not allow](https://stackoverflow.com/questions/65838989/variables-may-not-be-used-here-during-terraform-init) any variable / local interpolation.

To migrate the state file to S3, run `terraform init -migrate-state`, and you should see the following output:

```bash
$ terraform init -migrate-state

Initializing the backend...
Do you want to copy existing state to the new backend?
  Pre-existing state was found while migrating the previous "local" backend to the
  newly configured "s3" backend. No existing state was found in the newly
  configured "s3" backend. Do you want to copy this state to the new "s3"
  backend? Enter "yes" to copy and "no" to start with an empty state.

  Enter a value: yes

Releasing state lock. This may take a few moments...

Successfully configured the backend "s3"! Terraform will automatically
use this backend unless the backend configuration changes.

Initializing provider plugins...
- Reusing previous version of hashicorp/aws from the dependency lock file
- Using previously-installed hashicorp/aws v4.53.0

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
```

We are now ready to set up our workflows, but first, let's ensure we commit our changes to our git repo. Run `git add .`, `git commit -m "Terraform bootstrapped"` and `git push`:

```bash
$ git add .
$ git commit -m "Terraform bootstrapped"
[main b05ffa8] Terraform bootstrapped
 10 files changed, 494 insertions(+)
 create mode 100644 _bootstrap/.terraform.lock.hcl
 create mode 100644 _bootstrap/main_branch_iam_role.tf
 create mode 100644 _bootstrap/pr_branch_iam_role.tf
 create mode 100644 _bootstrap/providers.tf
 create mode 100644 _bootstrap/state_file_resources.tf
 create mode 100644 _bootstrap/terraform.tf
 create mode 100644 _bootstrap/variables.tf

$ git push
Enumerating objects: 14, done.
Counting objects: 100% (14/14), done.
Delta compression using up to 2 threads
Compressing objects: 100% (13/13), done.
Writing objects: 100% (13/13), 4.22 KiB | 2.11 MiB/s, done.
Total 13 (delta 2), reused 0 (delta 0), pack-reused 0
remote: Validating objects: 100%
To https://git.us-west-2.codecatalyst.aws/v1/Cobus-AWS/TerraformCodeCatalyst/bootstrapping-terraform-automation-for-amazon-codecatalyst
   fa1b9aa..b05ffa8  main -> main
```

### Setting up workflows

In the previous section, we created two new IAM roles for our workflow, one for the `main` branch with permissions to create resources, and another for all pull requests with read-only permissions. We need to add these to our CodeCatalyst Space. In the top left of the page, click on the Space dropdown, and then click on your Space name. Navigate to the `AWS accounts` tab, click your AWS account number, and then on `Manage roles from the AWS Management Console`. This will open a new tab, select `Add an existing role you have created in IAM`, and select `Main-Branch-Infrastructure` from the dropdown. Click `Add role`:

![Dialog showing configuration to add an existing IAM role to CodeCatalyst.](./images/add_iam_role_to_codecatalyst.png)

This will take you to a new page with a green `Successfully added IAM role Main-Branch-Infrastructure.` banner at the top. Click on `Add IAM role`, and follow the same process to add the `PR-Branch-Infrastructure` role. Once done, you can close this window and go back to the CodeCatalyst one.

The base infrastructure is now in place to allow us to start using our workflow for any future changes to our infrastructure. We need to create a similar Terraform backend configuration for all the resource we will create using our workflow - as mentioned, we are intentionally keeping out bootstrapping infrastructure separate from the day-to-day infrastructure. In the root of the repo, create `terraform.tf`, with the following content - take note that the `key` for the bucket is different from what we used for the bootstrapping infrastructure, and as before, replace the `bucket`, `region`, `dynamodb_table`, and `kms_key_id` with your values:

```terraform
terraform {
  backend "s3" {
    bucket         = "tf-state-files"
    key            = "terraform-state-file/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "TerraformMainStateLock"
    kms_key_id     = "alias/s3" # Optionally change this to the custom KMS alias you created - "alias/terraform"
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.33"
    }
  }

  required_version = "= 1.3.7"
}
```

The `region` set in the above block indicates in which region the S3 bucket was created, not where we will create our resources. We also need to configure the `AWS` provider, and set the `region` to use. Will use a variable for this, you could also hard-code it, but it is more manageable to keep all the variables in a single `variables.tf` file for this purpose. Create `providers.tf` with the following content:

```terraform
# Configuring the AWS provider
provider "aws" {
  region = var.aws_region
}
```

And the `variables.tf` file with (you can change the region here if you want to create resources in a different one):

```terraform
variable "aws_region" {
  default = "us-east-1"
}
```

Now we are ready to create our workflow file. First, we need to create the workflow directory and file:

```bash
cd .. # go to the root folder of the repo
mkdir -p .codecatalyst/workflows
touch .codecatalyst/workflows/main_branch.yml
```

Open `.codecatalyst/workflows/main_branch.yml` in your IDE, and add the following - remember to replace the placeholder AWS account ID `111122223333` with the value of your account, and the IAM role names if you changed them (you can choose between the standard CodeCatalyst workflow, or to use GitHub Actions with CodeCatalyst):

* CodeCatalyst Workflow
    ```yml
    # Adaptation of the https://developer.hashicorp.com/terraform/tutorials/automation/github-actions workflow
    Name: TerraformMainBranch
    SchemaVersion: "1.0"

    Triggers:
      - Type: Push
        Branches:
          - main

    Actions:
      Terraform-Main-Branch-Apply:
        Identifier: aws/build@v1
        Inputs:
          Sources:
            - WorkflowSource
        Environment:
          Connections:
            - Role: Main-Branch-Infrastructure
              Name: "111122223333"
          Name: TerraformBootstrap
        Configuration: 
          Steps:
            - Run: export TF_VERSION=1.3.7 && wget -O terraform.zip "https://releases.hashicorp.com/terraform/${TF_VERSION}/terraform_${TF_VERSION}_linux_amd64.zip"
            - Run: unzip terraform.zip && rm terraform.zip && mv terraform /usr/bin/terraform && chmod +x /usr/bin/terraform
            - Run: terraform fmt -check -no-color
            - Run: terraform init -no-color
            - Run: terraform validate -no-color
            - Run: terraform plan -no-color -input=false
            - Run: terraform apply -auto-approve -no-color -input=false
        Compute:
          Type: EC2
    ```
* CodeCatalyst Workflow using GitHub Actions
    ```yml
    # Adaptation of the https://developer.hashicorp.com/terraform/tutorials/automation/github-actions workflow
    Name: TerraformMainBranch
    SchemaVersion: "1.0"

    Triggers:
      - Type: Push
        Branches:
          - main

    Actions:
      Terraform-Main-Branch-Apply:
        Identifier: aws/github-actions-runner@v1
        Inputs:
          Sources:
            - WorkflowSource
        Environment:
          Connections:
            - Role: Main-Branch-Infrastructure
              Name: "111122223333"
          Name: TerraformBootstrap
        Configuration:
          Steps:
            - name: Setup Terraform
              uses: hashicorp/setup-terraform@v1
              with:
                terraform_version: 1.3.7
            - name: Terraform Format
              run: terraform fmt -check -no-color
            - name: Terraform Init
              run: terraform init -no-color
            - name: Terraform Validate
              run: terraform validate -no-color
            - name: Terraform Plan
              run: terraform plan -no-color -input=false
            - name: Terraform Apply
              run: terraform apply -auto-approve -no-color -input=false
        Compute:
          Type: EC2
    ```

Let's try out our new workflow! First, we need to stage, commit, and push our changes directly to the `main` branch - this is needed as only workflows committed to the repo will be run by CodeCatalyst. Use the following commands:

```bash
git add . -A
git commit -m "Adding main branch workflow"
git push
```

Output:

```bash
$ git add .
$ git commit -m "Adding main branch workflow"
[main 1b88c0f] Adding main branch workflow
 2 files changed, 54 insertions(+)
 create mode 100644 .codecatalyst/workflows/main_branch.yml
 create mode 100644 terraform.tf

$ git push
Enumerating objects: 7, done.
Counting objects: 100% (7/7), done.
Delta compression using up to 2 threads
Compressing objects: 100% (4/4), done.
Writing objects: 100% (6/6), 1.12 KiB | 1.12 MiB/s, done.
Total 6 (delta 0), reused 0 (delta 0), pack-reused 0
remote: Validating objects: 100%
To https://git.us-west-2.codecatalyst.aws/v1/Cobus-AWS/TerraformCodeCatalyst/bootstrapping-terraform-automation-for-amazon-codecatalyst
   b05ffa8..1b88c0f  main -> main
```

In your browser, navigate to the `CI/CD` -> `Workflows` page. You should see the workflow running:

![List of CodeCatalyst workflows, with only a single `TerraformMainBranch` showing](./images/main_branch_workflow.png)

If you click on `Recent runs` to expand it, you will see the details of the currently running job. Click on the job ID (`Run-XXXXX`) to view the different stages of the build:

![Visual view of the build job with different stages in CodeCatalyst workflows](./images/main_branch_workflow_details.png)

### Pull Request Workflow

Now that we have our `main` branch workflow done, it is time to set up the pull request one. The workflow will be very similar as the `main` branch one, with the following difference:

1. A different workflow name - `TerraformPRBranch`
1. We use the `PR-Branch-Infrastructure` IAM role to ensure we cannot make any infrastructure changes in the PR workflow
1. We remove the `terraform apply` step
1. The trigger for the build is for when a PR to the `main` branch is opened or updated (`REVISION`)

Create a new file for the PR workflow as `.codecatalyst/workflows/pr_branch.yml`, and add the following (replacing the placeholder AWS account ID of `111122223333`, and the IAM role name if you changed it) - you can choose between the standard CodeCatalyst workflow, or to use GitHub Actions with CodeCatalyst:

* CodeCatalyst Workflow
    ```yml
    Name: TerraformPRBranch
    SchemaVersion: "1.0"

    Triggers:
      - Type: PULLREQUEST
        Events:
          - OPEN
          - REVISION

    Actions:
      Terraform-PR-Branch-Plan:
        Identifier: aws/build@v1
        Inputs:
          Sources:
            - WorkflowSource
        Environment:
          Connections:
            - Role: PR-Branch-Infrastructure
              Name: "111122223333"
          Name: TerraformBootstrap
        Configuration: 
          Steps:
            - Run: export TF_VERSION=1.3.7 && wget -O terraform.zip "https://releases.hashicorp.com/terraform/${TF_VERSION}/terraform_${TF_VERSION}_linux_amd64.zip"
            - Run: unzip terraform.zip && rm terraform.zip && mv terraform /usr/bin/terraform && chmod +x /usr/bin/terraform
            - Run: terraform fmt -check -no-color
            - Run: terraform init -no-color
            - Run: terraform validate -no-color
            - Run: terraform plan -no-color -input=false
        Compute:
          Type: EC2
    ```
* CodeCatalyst Workflow using GitHub Actions
    ```yml
    # Adaptation of the https://developer.hashicorp.com/terraform/tutorials/automation/github-actions workflow
    Name: TerraformPRBranch
    SchemaVersion: "1.0"

    # Optional - Set automatic triggers.
    Triggers:
      - Type: PULLREQUEST
        Branches:
          - main
        Events:
          - OPEN
          - REVISION

    # Build actions
    Actions:
      Terraform-PR-Branch-Plan:
        Identifier: aws/github-actions-runner@v1
        Inputs:
          Sources:
            - WorkflowSource
        Environment:
          Connections:
            - Role: PR-Branch-Infrastructure
              Name: "111122223333"
          Name: TerraformBootstrap
        Configuration:
          Steps:
            - name: Setup Terraform
              uses: hashicorp/setup-terraform@v1
              with:
                terraform_version: 1.3.7
            - name: Terraform Format
              run: terraform fmt -check -no-color
            - name: Terraform Init
              run: terraform init -no-color
            - name: Terraform Validate
              run: terraform validate -no-color
            - name: Terraform Plan
              run: terraform plan -no-color -input=false
        Compute:
          Type: EC2
    ```

This workflow needs to be added to the `main` branch before it will trigger for a new PR, so let's do that now:

```bash
git add .codecatalyst/workflows/pr_branch.yml
git commit -m "Adding PR branch workflow"
git push
```

This will trigger the `main` branch workflow as we added a change, but without adding any additional Terraform resources, it will not make any changes:

![CodeCatalyst workflows dialog with the new PR workflow added, and the `main` branch workflow showing a second, in-progress build](./images/pr_branch_workflow_added.png)

We will now add an AWS resource via Terraform via a PR. First, we need to create a new branch:

```bash
git checkout -b test-pr-workflow
```

Next, create a new file in the root of the project `vpc.tf` - we will create a VPC that has three public subnets, and the required routing tables. Add the following content to the file:

```terraform
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "CodeCatalyst-Terraform"
  cidr = "10.0.0.0/16"

  azs            = ["${var.aws_region}a", "${var.aws_region}b", "${var.aws_region}c"]
  public_subnets = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = false
  enable_vpn_gateway = false
}
```

We need to commit the change, and push the branch using `--set-upstream origin test-pr-workflow` as the remote branch does not yet exist:

```bash
git add vpc.tf
git commit -m "Adding a VPC with only public subnets"
git push --set-upstream origin test-pr-workflow
```

The output shows that the remote branch has been created, and we pushed changes from our local branch to that one:

```bash
$ git push --set-upstream origin test-pr-workflow

Enumerating objects: 4, done.
Counting objects: 100% (4/4), done.
Delta compression using up to 2 threads
Compressing objects: 100% (3/3), done.
Writing objects: 100% (3/3), 469 bytes | 469.00 KiB/s, done.
Total 3 (delta 1), reused 0 (delta 0), pack-reused 0
remote: Validating objects: 100%
To https://git.us-west-2.codecatalyst.aws/v1/Cobus-AWS/TerraformCodeCatalyst/bootstrapping-terraform-automation-for-amazon-codecatalyst
 * [new branch]      test-pr-workflow -> test-pr-workflow
branch 'test-pr-workflow' set up to track 'origin/test-pr-workflow'.
```

This will not yet trigger a PR branch workflow as we haven't opened the pull request. In CodeCatalyst, navigate to `Code`, then `Pull requests`, and click on `Create pull request`. Select `test-pr-workflow` as the `Source branch`, `main` as the `Destination branch`, and add in a `Pull request title` and `Pull request description`. You can also preview the changes the PR will make on the bottom of the screen:

![CodeCatalyst open new pull request to create a PR from our branch to `main`](./images/open_new_pr.png)

Click `Create`, and then navigate to `CI/CD` -> `Workflows`, and select `All branches` from the dropdown in the top of the `Workflows` menu. After selecting `All branches`, you will see four workflows, the `TerraformMainBranch` and `TerraformPRBranch` ones, and a copy for each of the two branches `main` and `test-pr-workflow`. The `TerraformMainBranch` workflow will have an error with `Workflow is inactive`, which is expected as we limit that workflow to only run on our main branch. Click on the `Recent runs` under the `TerraformPRBranch` workflow for the `test-pr-workflow` branch, and then on `Terraform-PR-Branch-Plan` job to see the details.

![CodeCatalyst view of the TerraformPRBranch workflow, with the steps listed in the side-menu on the right.](./images/pr_workflow_output.png)

By clicking on the `Terraform Plan` step, you will be able to see the proposed infrastructure changes listed in the output. You can now inspect exactly which changes will be made to your infrastructure from this pull request. In you standard day-to-day operations, you would now go back to pull request to decide what action to take. If the proposed changes have been reviewed and approved, you can merge the pull request, or you can start a conversation on the PR to address any issues or concerns. We will now merge this request to roll out this infrastructure in our account by navigating to `Code` -> `Pull requests`, clicking on the `Title` or `ID` of the PR, and then the `Merge` button. You are presented with a choice between a `Fast forward merge`, or a `Squash and merge` option. `Fast forward merge` will take all the commits on the branch and add them sequentially to the `main` branch as if they were done there. For the `Squash merge`, it will combine all the commits on the `test-pr-workflow` branch into a single commit before merging that single commit to `main`. Which one you use will depend on your development approach, for this tutorial, will use the `Fast forward merge` one. You can also select the option to `Delete the source branch after merging this pill request. Source branch: test-pr-workflow`, this will help keep your repository clean from too many branches if they are no longer used. Click on `Merge`, and navigate to `CI/CD` -> `Workflows` to see the new VPC being created. Click on the currently running `TerraformMainBranch` workflow's `Recent runs`, then on the job ID, and then on the 2nd step to see the progress in the right-hand pane. Once the job completes, we can verify that the VPC was created by navigating to the [VPC section of the AWS Console](https://us-east-1.console.aws.amazon.com/vpc/home), a clicking on the `VPC ID` for the VPC with the name `CodeCatalyst-Terraform`. You should see something similar:

![AWS Console displaying details of the VPC just created](./images/console_vpc_view.png)

## Clean up

We have now reached the end of this tutorial, you can either keep the current setup and expand on it, or delete all the resources created if you are not. If you are planning to manage multiple AWS accounts, we recommend reading the [Automating multiple environments with Terraform](/tutorials/automating-multiple-environments-with-terraform) tutorial - it follows directly from this one, and you can leave the resources created in place.

To remove all the resources we created in this project, follow the following steps in your dev environment:

1. Make sure you are on the `main` branch by running `git checkout main` and `git pull` to ensure you have the latest changes, then run `terraform destroy`, and type `yes` to confirm - this will remove the VPC we created
1. To delete all the bootstrapping resourced, first change into the directory by running `cd _bootstrap`. Before we can delete everything, we need to update our S3 state file bucket. We need to change the lifecycle policy to allow the deletion, and add `force_destroy = true` to also delete all the objects in the bucket. Edit `_bootstrap/state_file_resources.tf`, and replace the first `aws_s3_bucket` resource with:
    ```terraform
    # Bucket used to store our state file
    resource "aws_s3_bucket" "state_file" {
      bucket = var.state_file_bucket_name
      force_destroy = true

      lifecycle {
        prevent_destroy = false
      }
    }
    ```
1. Run `terraform apply`, and accept the changes.
1. Now run `terraform destroy`, and accept the changes. This will result in two errors since we are deleting the S3 bucket where it tries to store the updated state file, and also the DynamoDB table Terraform uses to store the lock to prevent parallel runs. The output will look similar to this:
    ```bash
    │ Error: Failed to save state
    │ 
    │ Error saving state: failed to upload state: NoSuchBucket: The specified bucket does not exist
    │       status code: 404, request id: VJDXS21J9YFQ2J5J, host id: aG3pXy1Kfx2jncT1js0iDL5d+5j/rf3mNDVNzRp7aYpa3bCkAIKKJDh8HJQymS2prphHrazmjmo=
    ╵
    ╷
    │ Error: Failed to persist state to backend
    │ 
    │ The error shown above has prevented Terraform from writing the updated state to the configured backend. To allow for recovery, the state has been written to the file "errored.tfstate" in the current working directory.
    │ 
    │ Running "terraform apply" again at this point will create a forked state, making it harder to recover.
    │ 
    │ To retry writing this state, use the following command:
    │     terraform state push errored.tfstate
    │ 
    ╵
    ╷
    │ Error: Error releasing the state lock
    │ 
    │ Error message: failed to retrieve lock info: ResourceNotFoundException: Requested resource not found
    │ 
    │ Terraform acquires a lock when accessing your state to prevent others
    │ running Terraform to potentially modify the state at the same time. An
    │ error occurred while releasing this lock. This could mean that the lock
    │ did or did not release properly. If the lock didn't release properly,
    │ Terraform may not be able to run future commands since it'll appear as if
    │ the lock is held.
    │ 
    │ In this scenario, please call the "force-unlock" command to unlock the
    │ state manually. This is a very dangerous operation since if it is done
    │ erroneously it could result in two people modifying state at the same time.
    │ Only call this command if you're certain that the unlock above failed and
    │ that no one else is holding a lock.
    ```

5. Lastly, we need to delete the project we created in CodeCatalyst. In the left-hand navigation, go to `Project settings`, click on `Delete project`, and follow the instructions to delete the project.

## Conclusion

Congratulations! You've now bootstrapped Terraform with CodeCatalyst, and can deploy any infrastructure changes using a pull request workflow. If you enjoyed this tutorial, found an issues, or have feedback for us, <a href="https://pulse.buildon.aws/survey/DEM0H5VW" target="_blank">please send it our way!</a>

<!-- ## Bootstrapping with AWS CLI and CloudShell -->

<!-- 
## Setting up Dev Environment with GitHub repo

You can also use GitHub for this tutorial, first you will need to create a new repo for our infrastructure using Terraform for the `.gitignore` template, a suitable repo name (we will use `bootstrapping-terraform-automation-amazon-codecatalyst`), and an appropriate license.

![Details to create a new GitHub repo called `bootstrapping-terraform-automation-for-amazon-codecatalyst`, with the Terraform `.gitignore`, and using the `MIT-0` license.](./images/new_github_repo.png)

Next, you will need to set up a development environment, and will be using the built-in ones provided by CodeCatalyst. In your space, click on `Create Dev Environment` under the `Your Dev Environments` section, then select `Cloud9` - this tutorial with use Cloud9. Select `Create an empty Dev Environment`, add an `Alias` of `TerraformBootstrap`, and then click the `Create` button.

![Dialog to create a dev environment, with the `Create an empty Dev Environment` selected, and the `alias` set to `TerraformBootstrap`](./images/create_dev_environment_github_repo.png)

It will take 1 - 2 minutes to provision your development environment, and once done, you will be presented with a welcome screen:

![Cloud9 web based IDE view](./images/cloud9_dev_environment.png)

To access your repository on GitHub, we need to create or add an SSH key pair to our environment. We recommend creating a new key, and adding it to your GitHub account by using `ssh-keygen -t ecdsa -b 521`, using the default location, and adding a passphrase. Use the terminal in the bottom half of the Cloud9 IDE:

```bash
$ ssh-keygen -t ecdsa -b 521
Generating public/private ecdsa key pair.
Enter file in which to save the key (/home/mde-user/.ssh/id_ecdsa): 
Enter passphrase (empty for no passphrase): 
Enter same passphrase again: 
Your identification has been saved in /home/mde-user/.ssh/id_ecdsa.
Your public key has been saved in /home/mde-user/.ssh/id_ecdsa.pub.
The key fingerprint is:
SHA256:qoZsKx9rHD7RHTB3+tYfWWYHWCGLcd03FZhHJ1w58/I mde-user@ip-10-2-124-31.us-west-2.compute.internal
The key's randomart image is:
+---[ECDSA 521]---+
|          . o=B*B|
|    o . .  +.=+B+|
|     + o  . . ..*|
|      o       = o|
|   . . oS.   = + |
|  o . ..o . o   E|
| +.+  ..   . .   |
|. Oo..      .    |
| =++.            |
+----[SHA256]-----+
```

Next, you need to add the SSH key to your GitHub account. Use `cat ~/.ssh/id_ecdsa.pub` to output the public part of the key, highlight it and copy it using `ctrl` + `c` (or `cmd` + `c` on Mac), then add it via [GitHub](https://github.com/settings/ssh/new). It should look like this:

![Dialog on GitHub to add a new SSH key with the name set to `Cloud9`, and the public part of the key pasted in](./images/github_new_ssh_key.png)

Lastly, go back to your new GitHub repo, click on the `Code` button, select `SSH`, and the click on the button of two files next to the string starting with `git@github.com`. The icon should be replace with a green checkmark after you clicked it. Back in your Cloud9 terminal, type `git clone ` (note the space after `clone`), and the paste in the repo location using `ctrl` + `v` (or `cmd` + 'v' on Mac), and press enter.

You are now ready to continue with the tutorial, can go back to [bootstrapping Terraform](#bootstrapping-terraform) now. -->
