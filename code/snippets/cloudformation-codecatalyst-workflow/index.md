---
title: "Amazon CodeCatalyst workflow for Amazon CloudFormation"
description: "Example CodeCatalyst workflow to deploy CloudFormation infrastructure changes."
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
| 💻 Examples of      | [CloudFormation](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/Welcome.html?sc_channel=el&sc_campaign=devopswave&sc_content=snp_cfn_cc&sc_geo=mult&sc_country=mult&sc_outcome=acq) <br> [CodeCatalyst Workflow](https://docs.aws.amazon.com/codecatalyst/latest/userguide/workflow-reference.html?sc_channel=el&sc_campaign=devopswave&sc_content=snp_cfn_cc&sc_geo=mult&sc_country=mult&sc_outcome=acq) |
| ⏰ Last Updated        | 2023-05-05                                                     |

This snippet shows a [CodeCatalyst](https://codecatalyst.aws/?sc_channel=el&sc_campaign=devopswave&sc_content=snp_cfn_cc&sc_geo=mult&sc_country=mult&sc_outcome=acq) [workflow](https://docs.aws.amazon.com/codecatalyst/latest/userguide/workflow-reference.html?sc_channel=el&sc_campaign=devopswave&sc_content=snp_cfn_cc&sc_geo=mult&sc_country=mult&sc_outcome=acq) that will deploy any changes in the CloudFormation template. It is intended to be used on the `main` branch, and run after merging a PR that has been validated - see [this example of the PR branch workflow](../cloudformation-codecatalyst-workflow-PR-branch/).

**Used in:**

* [Build a CI/CD Pipeline to Improve Your IaC with AWS CloudFormation](../../tutorials/build-ci-cd-pipeline-iac-cloudformation)

## Snippet

```yaml
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
