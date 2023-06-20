---
title: "Amazon CodeCatalyst workflow for a PR branch for Terraform using GitHub Actions"
description: "Example CodeCatalyst workflow to run Terraform plan on a PR branch using GitHub Actions."
tags:
    - terraform
    - codecatalyst
    - ci-cd
    - snippets
    - infrastructure-as-code
    - github-actions
    - aws
authorGithubAlias: cobusbernard
authorName: Cobus Bernard
date: 2023-05-05
---

| Attributes             |                                                                 |
|------------------------|-----------------------------------------------------------------|
| 💻 Examples of      | [Hashicorp HCL](https://github.com/hashicorp/hcl) <br> [CodeCatalyst Workflow](https://docs.aws.amazon.com/codecatalyst/latest/userguide/workflow-reference.html?sc_channel=el&sc_campaign=devopswave&sc_content=snp_tf_cc_gh_pr&sc_geo=mult&sc_country=mult&sc_outcome=acq) <br> [GitHub Actions](https://docs.aws.amazon.com/codecatalyst/latest/userguide/github-action-ref.html?sc_channel=el&sc_campaign=devopswave&sc_content=snp_tf_cc_gh_pr&sc_geo=mult&sc_country=mult&sc_outcome=acq)|
| ⏰ Last Updated        | 2023-03-01                                                      |

This snippet shows a [CodeCatalyst](https://codecatalyst.aws/?sc_channel=el&sc_campaign=devopswave&sc_content=snp_tf_cc_gh_pr&sc_geo=mult&sc_country=mult&sc_outcome=acq) [workflow](https://docs.aws.amazon.com/codecatalyst/latest/userguide/workflow-reference.html?sc_channel=el&sc_campaign=devopswave&sc_content=snp_tf_cc_gh_pr&sc_geo=mult&sc_country=mult&sc_outcome=acq) that will run [Terraform](https://terraform.io) `validate` and `plan` to test if the Terraform code is valid on a PR. It is intended to be used on a PR branch - see [this example of the main branch workflow](./terraform-codecatalyst-workflow/). Alternative version using [standard CodeCatalyst workflow](./terraform-codecatalyst-workflow-PR-branch/).

**Used in:**

* [Bootstrapping your Terraform automation with Amazon CodeCatalyst](../../tutorials/bootstrapping-terraform-automation-amazon-codecatalyst)

## Snippet

```yaml
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
            Name: "123456789012"
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
