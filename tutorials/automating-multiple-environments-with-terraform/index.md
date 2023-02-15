---
title: "Automating multiple environments with Terraform"
description: "How to manage a central main account for shared infrastructure with a dev, test, and prod account with Terraform."
tags:
    - terraform
    - codecatalyst
    - ci-cd
    - tutorial
    - infrastructure-as-code
    - aws
    - github-actions
authorGithubAlias: cobusbernard
authorName: Cobus Bernard
date: 2023-01-31
---

As teams grow, so does the complexity of managing and coordinating changes to the application environment. While having a single account to provision all your infrastructure and deploy all systems works well for a small group of people, you will probably hit a point where there are too many people making changes at the same time to be able to manage it all. Additionally, with all your infrastructure in a single account, it becomes very difficult to apply the principle of least privilege, not to even mention the naming convention of resources. This tutorial will guide you how to split your infrastructure across multiple accounts by creating a `main` account for all common infrastructure shared by all environments (for example: users, build pipeline, build artifacts, etc.), and then an environment account for the three stages of your application: `dev`, `test`, and `prod`. The approach will make use of Terraform, Amazon CodeCatalyst, and assuming IAM roles between these accounts. We will address the following:

* How to split our infrastructure between multiple accounts and code repositories
* How to set up a build and deployment pipeline to manage all changes in the environment account with Terraform
* How to keep `dev`, `test`, and `prod` infrastructure in sync without needed to copy files around

## Table of Contents

| Attributes             |                                                                 |
|------------------------|-----------------------------------------------------------------|
| ✅ AWS experience      | 200 - Intermediate                                              |
| ⏱ Time to complete     | 30 minutes                                                      |
| 💰 Cost to complete    | Free tier eligible                                               |
| 🧩 Prerequisites       | - [AWS Account](https://portal.aws.amazon.com/billing/signup#/start/email)<br>- [CodeCatalyst Account](https://codecatalyst.aws)<br>- [Terraform](https://terraform.io/) 1.3.7+<br>- (Optional) [GitHub](https://github.com) account|
| ⏰ Last Updated        | 2023-02-10                                                      |
| &#x1F4BE; Code         | [Download here the full guide](https://github.com/build-on-aws/manage-multiple-environemnts-with-terraform) |

| ToC |
|-----|

## Setting up a CI/CD pipeline for the Main account

As a first step, we need to set up a CI/CD pipeline for all the shared infrastructure in our `main` account. We will be using the approach from [Terraform bootstrapping tutorial](https://www.buildon.aws/tutorials/bootstrapping-terraform-automation-amazon-codecatalyst/) - we won't be covering any of the details here, just following the steps, if you would like to understand more, we recommend working through that tutorial first. You can continue with this tutorial after finishing the bootstrapping one, just don't follow the cleanup steps - just skip to the [next section](#setting-up-the-new-aws-environment-accounts). Here is a condensed version of all the steps.

To set up our pipeline, make sure you are logged into your AWS and CodeCatalyst accounts to set up our project, environment, repository, and CI/CD pipelines. In CodeCatalyst:

1. Create a new `Project` called `TerraformMultiAccount` using the `Start from scratch` option
1. Create a code repository called `main-infra` in the project, using `Terraform` for the `.gitignore file`
1. Link an AWS account to our project project via the `Environments` section with the name `MainAccount`
1. Create a `dev environment` using `Cloud9`, and cloning the `main-infra` repository using the `main` branch
1. Launch the `dev environment`, and configure the AWS CLI using `aws configure` with the credentials of an IAM user in your AWS account

### Bootstrapping Terraform

We first need to bootstrap Terraform in our account, please follow these steps in your Cloud9 terminal:

```bash
# Install specific Terraform version
TF_VERSION=1.3.7
wget -O terraform.zip https://releases.hashicorp.com/terraform/${TF_VERSION}/terraform_${TF_VERSION}_linux_amd64.zip
unzip terraform.zip
rm terraform.zip
sudo mv terraform /usr/bin/terraform
sudo chmod +x /usr/bin/terraform

# Set up required resources for Terraform to use to bootstrap
cd main-infra
mkdir -p _bootstrap
cd _bootstrap
wget https://raw.githubusercontent.com/build-on-aws/bootstrapping-terraform-automation/main/_bootstrap/codecatalyst/main_branch_iam_role.tf
wget https://raw.githubusercontent.com/build-on-aws/bootstrapping-terraform-automation/main/_bootstrap/codecatalyst/pr_branch_iam_role.tf
wget https://raw.githubusercontent.com/build-on-aws/bootstrapping-terraform-automation/main/_bootstrap/codecatalyst/providers.tf
wget https://raw.githubusercontent.com/build-on-aws/bootstrapping-terraform-automation/main/_bootstrap/codecatalyst/state_file_resources.tf
wget https://raw.githubusercontent.com/build-on-aws/bootstrapping-terraform-automation/main/_bootstrap/codecatalyst/terraform.tf
wget https://raw.githubusercontent.com/build-on-aws/bootstrapping-terraform-automation/main/_bootstrap/codecatalyst/variables.tf
```

Now edit `variables.tf` and change the `state_file_bucket_name` value to a unique value - for this tutorial, we will use `tf-multi-account`. Now run `terraform init` and `terraform apply` to create the state file, lock table, and IAM roles for our CI/CD pipeline. If you would like to use a different AWS region, you can update the `aws_region` variable with the appropriate string. Next, open `terraform.tf` and uncomment the `terraform` block, updating the `bucket` value with your bucket name, and also the `region` if you changed it. Afterwards, run `terraform init -migrate-state` to migrate the state file to the newly create S3 bucket for it.

Next, we need to allow the two new IAM roles access to our CodeCatalyst Space and projects. In your Space, navigate to the `AWS accounts` tab, click your AWS account number, and then on Manage roles from the AWS Management Console. This will open a new tab, select `Add an existing role you have created in IAM`, and select `Main-Branch-Infrastructure` from the dropdown. Click `Add role`. This will take you to a new page with a green `Successfully added IAM role Main-Branch-Infrastructure.` banner at the top. Click on `Add IAM role`, and follow the same process to add the `PR-Branch-Infrastructure` role. Once done, you can close this window and go back to the CodeCatalyst one.

Lastly, we need to create the workflows that will run `terraform plan` for all pull requests (PRs), and then `terraform apply` for any PRs that are merged to the `main` branch. Run the following commands:

```bash
cd ..
mkdir -p .codecatalyst/workflows
cd .codecatalyst/workflows
wget https://raw.githubusercontent.com/build-on-aws/bootstrapping-terraform-automation/main/.codecatalyst/workflows/main_branch.yml
wget https://raw.githubusercontent.com/build-on-aws/bootstrapping-terraform-automation/main/.codecatalyst/workflows/pr_branch.yml
cd ../../
wget https://raw.githubusercontent.com/build-on-aws/bootstrapping-terraform-automation/main/providers.tf
wget https://raw.githubusercontent.com/build-on-aws/bootstrapping-terraform-automation/main/terraform.tf
wget https://raw.githubusercontent.com/build-on-aws/bootstrapping-terraform-automation/main/variables.tf
```

Now edit `.codecatalyst/workflows/main_branch.yml` and `.codecatalyst/workflows/pr_branch.yml`, replacing the `123456789012` AWS account ID with your one, rename the workflows to `MainAccount-PR-Branch` and `MainAccount-Main-Branch`, and rename the `Environment` `Name` field from `TerraformBootstrap` to `MainAccount`. In `terraform.tf`, change the `bucket` value to match your state file bucket created earlier, and optionally `region` if you are using a different region (remember to also edit `variables.tf` to change the region if you do). Finally, we need to commit all the changes:

```bash
git add .
git commit -m "Setting main infra ci-cd workflows"
git push
```

Navigate to `CI/CD` -> `Workflows` and confirm that the `main` branch workflow `MainBranch` is running and completes successfully. We now have the base of our infrastructure automation for a single AWS account. Next, we will set up additional environment accounts.

## Setting up the new AWS environment accounts

Similar to the bootstrapping of the base infrastructure, we need to bootstrap the three new AWS account for our `dev`, `test`, and `prod` environments. We will use extend the infrastructure defined in `_bootstrap` to manage this for us. Since we already have a bucket for storing state files in, we will use the same one, but change the `key` in the `backend` configuration block for our environment accounts to ensure we don't overwrite the current one. As we will be using different AWS accounts, we need a mechanism for our workflows to be able to access them. We will be using the IAM role [assume](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_use.html) functionality. This works by adding a trust policy to the IAM roles in each of the environment accounts by specifying that our `main` account may assume the roles in our environment accounts, and only perform actions as defined by this role. We then add an additional policy to our existing IAM workflow roles in our `main` account allowing them to assume the equivalent role in each environment account. This means that the PR branch role can only assume the PR branch role in each account to prevent accidental infrastructure changes, and similarly the `main` branch role can only assume the equivalent `main` branch role. The diagram below visualizes the process:

![Diagram showing the PR branch IAM role requesting temp credentials, and using them to assume the role in the dev account](./images/main_account_assuming_role_in_dev.png)

We need to create and modify the following resources:

1. **New AWS accounts**: We will create three new accounts using AWS Organizations
1. **New IAM roles**: Provides the roles for our workflow to assume in the environment accounts - one for the `main` branch, one for any pull requests (PRs), with a trust policy for access from our `main` account.
1. **New IAM policies**: Set the boundaries of what the workflow IAM roles may do in the environment account - full admin access for `main` branch allowing creation of infrastructure, `ReadOnly` for the PR branches to allow validating any changes
1. **IAM policies**: One each for the `main` and PR branch roles allowing them to assume the equivalent IAM role in environment accounts
1. **IAM roles**: Add the policy to assume the new environment account IAM roles

To do this, add the following to the `_bootstrap/variables.tf` file to define the three email addresses we will use to create child accounts, and also the name of the IAM role to create to allow access to the account. This IAM role is created in each of the environment accounts with admin permissions, and can be [assumed](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_use.html) from the top-level account. We will be setting up additional IAM roles for our workflows in the environment accounts further down.

> 💡 Tip: You can use `+` in an email address to set up additional, unique email strings that will all be delivered to the same email inbox, e.g. if your email is `john@example.com`, you can use `john+aws-dev@example.com`. This is useful as each AWS account needs a globally unique email address, but managing multiple inboxes can become a problem.

```bash
variable "iam_account_role_name" {
  type    = string
  default = "org-admin"
}

variable "account_emails" {
  type = map(any)
  default = {
    dev : "tf-demo+dev@example.com",
    test : "tf-demo+test@example.com",
    prod : "tf-demo+prod@example.com",
  }
}
```

Create a new file called `_bootstrap/aws_environment_accounts.tf` to create the accounts using AWS Organizations, and also to add them to OUs (Organizational Units) - this is a useful way to organize multiple AWS accounts if you need to apply specific rules to each one. Add the following to the file:

```bash
# Set up the organization
resource "aws_organizations_organization" "org" {
  aws_service_access_principals = [
    "cloudtrail.amazonaws.com",
    "config.amazonaws.com",
    "sso.amazonaws.com",
  ]

  feature_set = "ALL"
}

# Create a new OU for environment accounts
resource "aws_organizations_organizational_unit" "environments" {
  name      = "environments"
  parent_id = aws_organizations_organization.org.roots[0].id
}

# Create a new AWS account called "dev"
resource "aws_organizations_account" "dev" {
  name      = "dev"
  email     = lookup(var.account_emails, "dev")
  role_name = var.iam_account_role_name
  parent_id = aws_organizations_organizational_unit.environments.id

  depends_on = [aws_organizations_organization.org]
}

# Create a new AWS account called "test"
resource "aws_organizations_account" "test" {
  name      = "test"
  email     = lookup(var.account_emails, "test")
  role_name = var.iam_account_role_name
  parent_id = aws_organizations_organizational_unit.environments.id

  depends_on = [aws_organizations_organization.org]
}

# Create a new AWS account called "prod"
resource "aws_organizations_account" "prod" {
  name      = "prod"
  email     = lookup(var.account_emails, "prod")
  role_name = var.iam_account_role_name
  parent_id = aws_organizations_organizational_unit.environments.id

  depends_on = [aws_organizations_organization.org]
}
```

> 💡 Tip: If you are applying this strategy to existing AWS accounts and using the [import](https://developer.hashicorp.com/terraform/cli/import) function of Terraform, take note of the instructions on how to avoid recreating the account when importing in the [resource page](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/organizations_account#import).

Let's look at these changes and then apply them, run the following commands in your CodeCatalyst environment's terminal:

```bash
cd _bootstrap
terraform plan
```

The proposed changes should be similar to this list:

```bash
Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_organizations_account.dev will be created
  + resource "aws_organizations_account" "dev" {
      + arn               = (known after apply)
      + close_on_deletion = false
      + create_govcloud   = false
      + email             = "tf-demo+dev@example.com"
      + govcloud_id       = (known after apply)
      + id                = (known after apply)
      + joined_method     = (known after apply)
      + joined_timestamp  = (known after apply)
      + name              = "dev"
      + parent_id         = (known after apply)
      + role_name         = "org-admin"
      + status            = (known after apply)
      + tags_all          = (known after apply)
    }

  # aws_organizations_account.prod will be created
  + resource "aws_organizations_account" "prod" {
      + arn               = (known after apply)
      + close_on_deletion = false
      + create_govcloud   = false
      + email             = "tf-demo+prod@example.com"
      + govcloud_id       = (known after apply)
      + id                = (known after apply)
      + joined_method     = (known after apply)
      + joined_timestamp  = (known after apply)
      + name              = "prod"
      + parent_id         = (known after apply)
      + role_name         = "org-admin"
      + status            = (known after apply)
      + tags_all          = (known after apply)
    }

  # aws_organizations_account.test will be created
  + resource "aws_organizations_account" "test" {
      + arn               = (known after apply)
      + close_on_deletion = false
      + create_govcloud   = false
      + email             = "tf-demo+test@example.com"
      + govcloud_id       = (known after apply)
      + id                = (known after apply)
      + joined_method     = (known after apply)
      + joined_timestamp  = (known after apply)
      + name              = "test"
      + parent_id         = (known after apply)
      + role_name         = "org-admin"
      + status            = (known after apply)
      + tags_all          = (known after apply)
    }

  # aws_organizations_organization.org will be created
  + resource "aws_organizations_organization" "org" {
      + accounts                      = (known after apply)
      + arn                           = (known after apply)
      + aws_service_access_principals = [
          + "cloudtrail.amazonaws.com",
          + "config.amazonaws.com",
          + "sso.amazonaws.com",
        ]
      + feature_set                   = "ALL"
      + id                            = (known after apply)
      + master_account_arn            = (known after apply)
      + master_account_email          = (known after apply)
      + master_account_id             = (known after apply)
      + non_master_accounts           = (known after apply)
      + roots                         = (known after apply)
    }

  # aws_organizations_organizational_unit.environments will be created
  + resource "aws_organizations_organizational_unit" "environments" {
      + accounts  = (known after apply)
      + arn       = (known after apply)
      + id        = (known after apply)
      + name      = "environments"
      + parent_id = (known after apply)
      + tags_all  = (known after apply)
    }

Plan: 5 to add, 0 to change, 0 to destroy.
```

Now go ahead and apply them with `terraform apply`. During this time, or shortly after, you will start to receive the welcome emails from the new accounts. There will be a mail with the subject `AWS Organizations email verification request` that you need to look out for, and click the `Verify email address` if this is the first time you are using an AWS Organization in your account.

Next, we need to create the IAM roles, and policies in the new accounts, and update our existing IAM roles with additional policies to allow them to assume these new roles in the environment accounts. First, we need to define additional `AWS` providers to allow Terraform to create infrastructure in our accounts. We will use the IAM role created as part of our new account to do this. Add the following to the `_bootstrap/providers.tf` file:

```bash

```