---
title: "Amazon CodeCatalyst workflow for Amazon ECS"
description: "Example CodeCatalyst workflow to deploy CloudFormation infrastructure changes."
tags:
    - codecatalyst
    - ecs
    - ci-cd
    - snippet
    - infrastructure-as-code
    - aws
authorGithubAlias: kowsalyajaganathan
authorName: Kowsalya Jaganathan
date: 2023-05-05
---

| Attributes             |                                                                 |
|------------------------|-----------------------------------------------------------------|
| 💻 Examples of      | [ECS](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/Welcome.html?sc_channel=el&sc_campaign=devopswave&sc_content=snp_ecs_cc&sc_geo=mult&sc_country=mult&sc_outcome=acq) <br> [CodeCatalyst Workflow](https://docs.aws.amazon.com/codecatalyst/latest/userguide/workflow-reference.html?sc_channel=el&sc_campaign=devopswave&sc_content=snp_ecs_cc&sc_geo=mult&sc_country=mult&sc_outcome=acq) |
| ⏰ Last Updated        | 2023-05-05                                                     |

This snippet shows a [CodeCatalyst](https://codecatalyst.aws/?sc_channel=el&sc_campaign=devopswave&sc_content=snp_cfn_cc&sc_geo=mult&sc_country=mult&sc_outcome=acq) [workflow](https://docs.aws.amazon.com/codecatalyst/latest/userguide/workflow-reference.html?sc_channel=el&sc_campaign=devopswave&sc_content=snp_ecs_cc&sc_geo=mult&sc_country=mult&sc_outcome=acq) that will build and publish a container images, and then deploy it to an ECS cluster.

**Used in:**

* [Deploy a Container Web App on Amazon ECS Using Amazon CodeCatalyst](../../tutorials/deploy-webapp-ecs-codecatalyst)

## Snippet

The following values need to replaced in the snippet below:

* `<ECS cluster ARN>`
* `<Account-Id>`
* `<CodeCatalystPreviewDevelopmentAdministrator role>`

```yaml
Name: BuildAndDeployToECS
SchemaVersion: "1.0"

# Optional - Set automatic triggers.
Triggers:
  - Type: Push
    Branches:
      - main

# Required - Define action configurations.
Actions:
  Build_application:
    Identifier: aws/build@v1
    Inputs:
      Sources:
        - WorkflowSource
      Variables:
        - Name: region
          Value: us-west-2
        - Name: registry
          Value: <Account-Id>.dkr.ecr.us-west-2.amazonaws.com
        - Name: image
          Value: my-respository-cdkecsinfrastack
    Outputs:
      AutoDiscoverReports:
        Enabled: false
      Variables:
        - IMAGE
    Compute:
      Type: EC2
    Environment:
      Connections:
        - Role: <CodeCatalystPreviewDevelopmentAdministrator role>
        # Add account id within quotes. Eg: "123456789012"
          Name: "<Account-Id>"
      Name: Non-prod
    Configuration:
      Steps:
        - Run: export account=`aws sts get-caller-identity --output text | awk '{ print $1 }'`
        - Run: aws ecr get-login-password --region ${region} | docker login --username AWS --password-stdin ${registry}
        - Run: docker build -t appimage .
        - Run: docker tag appimage ${registry}/${image}:${WorkflowSource.CommitId}
        - Run: docker push --all-tags ${registry}/${image}
        - Run: export IMAGE=${registry}/${image}:${WorkflowSource.CommitId}
  RenderAmazonECStaskdefinition:
    Identifier: aws/ecs-render-task-definition@v1
    Configuration:
      image: ${Build_application.IMAGE}
      container-name: MyContainer
      task-definition: task.json
    Outputs:
      Artifacts:
        - Name: TaskDefinition
          Files:
            - task-definition*
    DependsOn:
      - Build_application
    Inputs:
      Sources:
        - WorkflowSource
  DeploytoAmazonECS:
    Identifier: aws/ecs-deploy@v1
    Configuration:
      task-definition: /artifacts/DeploytoAmazonECS/TaskDefinition/${RenderAmazonECStaskdefinition.task-definition}
      service: MyWebApp
      cluster: <ECS cluster ARN>
      region: us-west-2
    Compute:
      Type: EC2
      Fleet: Linux.x86-64.Large
    Environment:
      Connections:
        - Role: <CodeCatalystPreviewDevelopmentAdministrator role>
        # Add account id within quotes. Eg: "12345678"
          Name: "<Account Id>"
      Name: Non-Prod
    DependsOn:
      - RenderAmazonECStaskdefinition
    Inputs:
      Artifacts:
        - TaskDefinition
      Sources:
        - WorkflowSource
```
