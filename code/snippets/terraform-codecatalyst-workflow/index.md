---
title: "Amazon CodeCatalyst workflow for Terraform"
description: "Example CodeCatalyst workflow to apply Terraform infrastructure changes."
tags:
    - terraform
    - codecatalyst
    - ci-cd
    - snippet
    - infrastructure-as-code
    - aws
authorGithubAlias: cobusbernard
authorName: Cobus Bernard
date: 2023-05-05
---

| Attributes             |                                                                 |
|------------------------|-----------------------------------------------------------------|
| 💻 Examples of      | [Hashicorp HCL](https://github.com/hashicorp/hcl) <br> [CodeCatalyst Workflow](https://docs.aws.amazon.com/codecatalyst/latest/userguide/workflow-reference.html?sc_channel=el&sc_campaign=devopswave&sc_content=snp_tf_cc&sc_geo=mult&sc_country=mult&sc_outcome=acq) |
| ⏰ Last Updated        | 2023-05-05                                                      |

This snippet shows a [CodeCatalyst](https://codecatalyst.aws/?sc_channel=el&sc_campaign=devopswave&sc_content=snp_tf_cc&sc_geo=mult&sc_country=mult&sc_outcome=acq) [workflow](https://docs.aws.amazon.com/codecatalyst/latest/userguide/workflow-reference.html?sc_channel=el&sc_campaign=devopswave&sc_content=snp_tf_cc&sc_geo=mult&sc_country=mult&sc_outcome=acq) that will run [Terraform](https://terraform.io) to apply infrastructure changes. It uses `validate` and `plan` to test if the Terraform code is valid. It is intended to be used on the `main` branch, and run after merging a PR that has been validated - see [this example of the PR branch workflow](../terraform-codecatalyst-workflow-PR-branch/). Alternative version using [GitHub Actions](../terraform-codecatalyst-github-actions-workflow/).

**Used in:**

* [Bootstrapping your Terraform automation with Amazon CodeCatalyst](../../tutorials/bootstrapping-terraform-automation-amazon-codecatalyst)

## Snippet

```yaml
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
            Name: "123456789012"
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
