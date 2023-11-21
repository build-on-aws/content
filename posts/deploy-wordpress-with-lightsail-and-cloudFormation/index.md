---
title: "Deploy WordPress with Lightsail and CloudFormation"
description: "Introduction to CloudFormation templates to create Lightsail Wordpress instances."
tags:
    - cloudformation
    - lightsail
    - wordpress
authorGithubAlias: spara
authorName: Sophia Parafina
date: 2023-11-21
---

There are many ways to create a WordPress site, either through the Lightsail web console or with the AWS CLI. Another way is to use CloudFormation, an AWS service that sets up resources. CloudFormation works with AWS services, including Lightsail. It uses templates to describe, provision, and configure AWS resources for your application. This article introduces CloudFormation and demonstrates how to create a Lightsail WordPress site with a template.

## CloudFormation

CloudFormation templates describe all the resources and their properties needed to deploy infrastructure for your application. Templates are formatted in either [JSON or YAML](https://aws.amazon.com/compare/the-difference-between-yaml-and-json/?sc_channel=el&sc_campaign=post&sc_content=deploywordpresswithlightsailandcloudformation&sc_geo=mult&sc_country=mult&sc_outcome=acq&sc_publisher=amazon_media&sc_category=lightsail&sc_medium=body), and they can be saved with any file extension such as .json, .yml, or .txt. This article uses YAML for examples. By specifying and configuring multiple resources in a single template, resources are created in a consistent and repeatable way.

The template has multiple sections and `Resources` is the only required section. The `Resources` section specifies the resources and properties to create. [Parameters](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/parameters-section-structure.html?sc_channel=el&sc_campaign=post&sc_content=deploywordpresswithlightsailandcloudformation&sc_geo=mult&sc_country=mult&sc_outcome=acq&sc_publisher=amazon_media&sc_category=lightsail&sc_medium=body) let you use custom values in the template. For example, you can create a parameter for Lightsail Linux instance bundles.

```yaml
Parameters:
  LinuxInstanceBundleParameter:
    Type: String
    Default: small_3_0
    AllowedValues:
      - nano_3_0
      - micro_3_0
      - small_3_0
      - medium_3_0
      - large_3_0
      - xlarge_3_0
      - 2xlarge_3_0
    Description: Enter nano_3_0, micro_3_0, small_3_0, medium_3_0, large_3_0, xlarge_3_0, 2xlarge_3_0. Default is small_3_0, 
```
The `Ref` function returns the value of a parameter. For example, the `LinuxInstanceBundleParameter` is used to set the BundleId property for a Lightsail instance.

```yaml
Resources:
  WordpressInstance:
    Type: AWS::Lightsail::Instance
    Properties:
      BlueprintId: wordpress
      BundleId:
        Ref: LinuxInstanceBundleParameter
      InstanceName: wordpress-cf
```

Templates include [Rules](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/rules-section-structure.html?sc_channel=el&sc_campaign=post&sc_content=deploywordpresswithlightsailandcloudformation&sc_geo=mult&sc_country=mult&sc_outcome=acq&sc_publisher=amazon_media&sc_category=lightsail&sc_medium=body) for validating parameters, [Conditions](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/conditions-section-structure.html?sc_channel=el&sc_campaign=post&sc_content=deploywordpresswithlightsailandcloudformation&sc_geo=mult&sc_country=mult&sc_outcome=acq&sc_publisher=amazon_media&sc_category=lightsail&sc_medium=body) to manage how resources are created, and [Transforms](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/transform-section-structure.html) that specifies how CloudFormation should process the template. Other template sections are described in the [documentation](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/template-anatomy.html?sc_channel=el&sc_campaign=post&sc_content=deploywordpresswithlightsailandcloudformation&sc_geo=mult&sc_country=mult&sc_outcome=acq&sc_publisher=amazon_media&sc_category=lightsail&sc_medium=body).

CloudFormation uses templates to create stacks, which are all the resources defined in the template managed as a single unit. Stacks simplify creating, updating, and deleting resources. A common problem with managing resources is failing to deleting unused resources. You may not remember that they are still running until the next billing cycle. Stacks let you delete resources without having manually find and delete each resource. Note that CloudFormation can only perform service calls based on the account permissions. For example, an account may not have permission to create a Relational Database Service (RDS). If any resource in the template cannot be created, CloudFormation will stop at the error and not create a stack until the error is fixed.

## Deploying WordPress

This template deploys a Lightsail WordPress. Lets look at it step-by-step. The first section is `AWSTemplateFormatVersion` which defines the template version. The next section is `Resources`, where the Wordpress Lightsail instance is defined along with a static IP. A property of the static IP is `AttachedTo` which assigns the static IP to the WordPress instance. The last section is `Output` which returns the static IP using the function `!GetAtt`.

```yaml
AWSTemplateFormatVersion: 2010-09-09
Resources:
  WordpressInstance:
    Type: AWS::Lightsail::Instance
    Properties:
      BlueprintId: wordpress
      BundleId: small_3_0
      InstanceName: wordpress-cf
  StaticIpWp:
    Type: AWS::Lightsail::StaticIp
    Properties:
      AttachedTo: wordpress-cf
      StaticIpName: wordpress-static-ip
 Outputs:
    StaticIpWp:
        Description: The static IP for the instance
        Value: !GetAtt StaticIpWp.IpAddress
```

You can use the CloudFormation web console to create a stack or the AWS CLI as in the example below.

```bash
$ aws cloudformation deploy --template-file ./wordpress-template.json --stack-name lightsail-wordpress
```

To find the static IP with the AWS CLI, use the describe-stacks CloudFormation command.

```bash
$ aws cloudformation describe-stacks --stack-name lightsail-wordpress
```

## Summary

CloudFormation templates are a convenient way to create Lightsail deployments quickly and consistently. You can use either JSON or YAML to create templates. In addition, CloudFormation extends the model to include methods to verify parameters with Rules, control the creation of resource with Conditionals, and the order of execution with Transforms. These extensions enable fine grain control over resource creation. Stacks provide a single way to manage a set of resources as a logical unit. Instead of managing individual resources, you can add, update, or delete some or all of the resources defined in a template. To learn more about CloudFormation, check out the [CloudFormation Getting Started](https://aws.amazon.com/cloudformation/getting-started/?sc_channel=el&sc_campaign=post&sc_content=deploywordpresswithlightsailandcloudformation&sc_geo=mult&sc_country=mult&sc_outcome=acq&sc_publisher=amazon_media&sc_category=lightsail&sc_medium=body).
