---
title: "Amazon CodeCatalyst workflow for Terraform using GitHub Actions"
description: "Example CodeCatalyst workflow to apply Terraform infrastructure changes using GitHub Actions."
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
| 💻 Examples of      | [Hashicorp HCL](https://github.com/hashicorp/hcl) <br> [CodeCatalyst Workflow](https://docs.aws.amazon.com/codecatalyst/latest/userguide/workflow-reference.html?sc_channel=el&sc_campaign=devopswave&sc_content=snp_tf_cc_gh&sc_geo=mult&sc_country=mult&sc_outcome=acq) <br> [GitHub Actions](https://docs.aws.amazon.com/codecatalyst/latest/userguide/github-action-ref.html?sc_channel=el&sc_campaign=devopswave&sc_content=snp_tf_cc_gh&sc_geo=mult&sc_country=mult&sc_outcome=acq)|
| ⏰ Last Updated        | 2023-05-05                                                  |

This snippet shows a [CodeCatalyst](https://codecatalyst.aws/?sc_channel=el&sc_campaign=devopswave&sc_content=snp_tf_cc_gh&sc_geo=mult&sc_country=mult&sc_outcome=acq) [workflow using GitHub Actions](https://docs.aws.amazon.com/codecatalyst/latest/userguide/github-action-ref.html?sc_channel=el&sc_campaign=devopswave&sc_content=snp_tf_cc_gh&sc_geo=mult&sc_country=mult&sc_outcome=acq) that will run [Terraform](https://terraform.io) to apply infrastructure changes. It uses `validate` and `plan` to test if the Terraform code is valid. It is intended to be used on the `main` branch, and run after merging a PR that has been validated - see [this example of the PR branch workflow](../terraform-codecatalyst-github-actions-workflow-PR-branch/). Alternative version using [standard CodeCatalyst workflow](../terraform-codecatalyst-workflow/).

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
    Identifier: aws/github-actions-runner@v1
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
