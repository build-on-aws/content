---
title: "Amazon CodeCatalyst workflow for AWS CloudFormation PR branch"
description: "Example CodeCatalyst workflow to run CloudFormation plan on a PR branch."
tags:
    - codecatalyst
    - cloudformation
    - ci-cd
    - snippet
    - infrastructure-as-code
    - aws
authorGithubAlias: gaonkarr
authorName: Rohini Gaonkar
date: 2023-05-05
---

| Attributes             |                                                                 |
|------------------------|-----------------------------------------------------------------|
| 💻 AWS experience      | [CloudFormation](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/Welcome.html?sc_channel=el&sc_campaign=devopswave&sc_content=snp_cfn_cc_pr&sc_geo=mult&sc_country=mult&sc_outcome=acq) <br> [CodeCatalyst Workflow](https://docs.aws.amazon.com/codecatalyst/latest/userguide/workflow-reference.html?sc_channel=el&sc_campaign=devopswave&sc_content=snp_cfn_cc_pr&sc_geo=mult&sc_country=mult&sc_outcome=acq) |
| ⏰ Last Updated        | 2023-05-05                                                      |

This snippet shows a [CodeCatalyst](https://codecatalyst.aws/?sc_channel=el&sc_campaign=devopswave&sc_content=snp_cfn_cc_pr&sc_geo=mult&sc_country=mult&sc_outcome=acq) [workflow](https://docs.aws.amazon.com/codecatalyst/latest/userguide/workflow-reference.html?sc_channel=el&sc_campaign=devopswave&sc_content=snp_cfn_cc_pr&sc_geo=mult&sc_country=mult&sc_outcome=acq) that will run [super-linter](https://github.com/marketplace/actions/super-linter) on the CloudFormation template, and then create a changeset, but not apply any changes. It is intended to be used on a PR branch - see [this example of the main branch workflow](../cloudformation-codecatalyst-workflow/).

**Used in:**

* [Build a CI/CD Pipeline to Improve Your IaC with AWS CloudFormation](../../tutorials/build-ci-cd-pipeline-iac-cloudformation)

## Snippet

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
