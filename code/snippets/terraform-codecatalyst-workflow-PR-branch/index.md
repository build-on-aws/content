---
title: "Amazon CodeCatalyst workflow for Terraform for a PR branch"
description: "Example CodeCatalyst workflow to run Terraform plan on a PR branch."
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
| 💻 AWS experience      | [Hashicorp HCL](https://github.com/hashicorp/hcl) <br> [CodeCatalyst Workflow](https://docs.aws.amazon.com/codecatalyst/latest/userguide/workflow-reference.html?sc_channel=el&sc_campaign=devopswave&sc_content=snp_tf_cc_pr&sc_geo=mult&sc_country=mult&sc_outcome=acq) |
| ⏰ Last Updated        | 2023-05-05                                                       |

This snippet shows a [CodeCatalyst](https://codecatalyst.aws?sc_channel=el&sc_campaign=devopswave&sc_content=snp_tf_cc_pr&sc_geo=mult&sc_country=mult&sc_outcome=acq) [workflow](https://docs.aws.amazon.com/codecatalyst/latest/userguide/workflow-reference.html?sc_channel=el&sc_campaign=devopswave&sc_content=snp_tf_cc_pr&sc_geo=mult&sc_country=mult&sc_outcome=acq) that will run [Terraform](https://terraform.io) `validate` and `plan` to test if the Terraform code is valid on a PR. It is intended to be used on a PR branch - see [this example of the main branch workflow](./terraform-codecatalyst-workflow/). Alternative version using [GitHub Actions](./terraform-codecatalyst-github-actions-workflow-PR-branch/).

**Used in:**

* [Bootstrapping your Terraform automation with Amazon CodeCatalyst](../../tutorials/bootstrapping-terraform-automation-amazon-codecatalyst)

## Snippet

```yaml
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
    Compute:
        Type: EC2
```
