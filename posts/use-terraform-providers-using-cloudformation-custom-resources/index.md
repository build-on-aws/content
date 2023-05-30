---
title: How to use Terraform providers using AWS CloudFormation custom resources
description: 
tags:
  - Terraform
  - IaC
authorGithubAlias: sohanmaheshwar
authorName: Sohan Maheshwar
date: 2016-01-31
---
When working in large businesses, different engineering teams seek the right balance between standardization and choosing their own tools. For example: A customer who is migrating hundreds of workloads from a legacy datacenter to AWS; where each engineering team could choose Terraform, AWS CloudFormation or AWS CDK. Having thousands of engineers with a variety of tools working on the same IT landscape, introduces challenges and constraints. What if all teams need to work with a legacy application that holds network configuration such as firewalls, DNS records or IP spaces? One approach is to standardize everything across teams, but that would compromise flexibility, agility and speed. At the same time, teams want to automate their infrastructure deployment, without making it complicated, or introducing dependencies. So how would you achieve this?

As you can imagine, this can be quite complicated. This article deconstructs how you can use a feature of CloudFormation called custom resources with Terraform (and potentially other Infrastructure as Code services) to solve this problem of working on a large legacy application, while allowing your engineering teams to choose their own approach to Infrastructure creation. Its important to note that this article is not about deciding between different IaC providers, nor is it a prescriptive guidance to adopt all three the tools. 

For this article, we’re using a fictional legacy application called Unicorn Tracker because who doesn’t love unicorns. Here’s the fictional app’s logo generated using Stable Diffusion

[App logo!](https://raw.githubusercontent.com/sohanmaheshwar/content/main/posts/use-terraform-providers-using-cloudformation-custom-resources/images/unicorntracker3.jpg?token=GHSAT0AAAAAACBD7RSBVDS63LY4OJ4Y2JD2ZBQKIOQ)

Lets dive straight in.  

### AWS Cloud Formation custom resources

AWS CloudFormation is an Infrastructure as Code service that allows you to easily model, provision, and manage AWS and third-party resources. Custom resources enable you to write custom provisioning logic in templates that AWS CloudFormation runs anytime you create, update, or delete stacks. For example, you might want to include resources that aren't available as AWS CloudFormation [resource types](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-template-resource-type-ref.html). You can include those resources by using custom resources. That way you can still manage all your related resources in a single stack.
Basically, they allow you to extend CloudFormation to do things it could not normally do – this includes AWS Resources not supported by CloudFormation and also non-AWS resources (Auth0, Algolia etc.)

#### How do they work?

Any action taken for a custom resource involves three parties.

1. Template developer - Creates a template that includes a custom resource type. The template developer specifies the service token and any input data in the template.
2. Custom resource provider - Owns the custom resource and determines how to handle and respond to requests from AWS CloudFormation. The custom resource provider must provide a service token that the template developer uses. The service token specifies where AWS CloudFormation sends requests to, such as an Amazon SNS topic ARN or an AWS Lambda function ARN
3. AWS CloudFormation - During a stack operation, sends a request to a service token that is specified in the template, and then waits for a response before proceeding with the stack operation.


Here’s a comparison of CloudFormation code and CloudFormation code with custom resources. 

```yaml

Resources:
  Server:
    Type: “AWS:EC2::Instance”
    Properties:
      InstanceType: m1.small
...

```
```yaml
Resources:
  MyCustomResource:
    Type: “Custom::UnicornTracker”
    Properties:
      ServiceToken: 'arn:aws:lambda:us-east..’
...
```

Note the use of the **‘Type’** as “Custom::UnicornTracker” here. 

The custom resource logic is authored in AWS Lambda. AWS CloudFormation executes the custom resource by invoking the AWS Lambda function specified. Here’s the code for our Unicorn Tracker - its a simple CRUD app, that uses crhelper to simplify custom resource creation, and updation. 

```python

import boto3
import botocore.exceptions
from crhelper import CfnResource
import requests
import json
import os

backend_api = os.getenv('UT_ENDPOINT')
helper = CfnResource()

@helper.create
def create(event, _):
    if 'UnicornName' in event['ResourceProperties']:
        response = requests.put(f"{backend_api}/items",
                    json = {'name': event['ResourceProperties']['UnicornName'],
                            'length': 1234})
    else:
        raise ValueError("UnicornName is a required property.")
    res_dict = json.loads(response.json())
    helper.Data["UnicornId"] = res_dict['id']
    return res_dict['id']

@helper.update
def update(event, _):
    # not implemented
    return True

@helper.delete
def delete(event, _):
    id = event['PhysicalResourceId']
    response = requests.delete(f"{backend_api}/items/{id}")

def handler(event, context):
    helper(event, context)

```

You can model this Lambda function in AWS CloudFormation. The ‘Resources’ section has a Lambda Layer that includes any dependencies for the Lambda function. 

```yaml
Transform: AWS::Serverless-2016-10-31
Parameters:
  UnicornTrackerEndpoint:
    Type: String
Resources:
  LambdaLayer:
    Type: AWS::Serverless::LayerVersion
    Properties:
      ContentUri: "lambda_layer/lambda_layer.zip"
  LambdaFunction:
    Type: AWS::Serverless::Function
    Properties:
      FunctionName: CustomUnicornTracker
      Handler: function.handler
      Runtime: python3.9
      CodeUri: lambda/
      Layers:
        - !Ref LambdaLayer
      Environment:
        Variables:
          UT_ENDPOINT: !Ref UnicornTrackerEndpoint
      Policies:
        - AWSLambdaExecute
```

Package and deploy this custom provider first

``` 
$ S3_BUCKET=<some bucketname>
$ UT_ENDPOINT=<the endpoint of the previous step>
$ aws s3 mb s3://${S3_BUCKET}
$ aws cloudformation package \
--template-file template.yml \
--s3-bucket $S3_BUCKET > build.yml
$ aws cloudformation deploy \
--stack-name ut-provider \
--template build.yml \
--parameter-overrides UnicornTrackerEndpoint=${UT_ENDPOINT} \
--capabilities CAPABILITY_IAM
```

Then test the custom provider by deploying a custom resource. 

```
$ aws cloudformation deploy \
    --stack-name ut-cfn-resource \
    --template template.yml
```

### Terraform Providers

Now that we’ve deployed this using AWS CloudFormation, let’s do the same with Terraform (TF). The aim for this section is to do this with a Terraform module instead of adding CloudFormation code inline. 

We first begin by using the Terraform Provider for AWS. Terraform relies on plugins called providers to interact with cloud providers, SaaS providers, and other APIs. If you aren’t familiar with Terraform Providers read this first. 

Here’s the TF code that uses AWS Provider. This code includes the CloudFormation Stack code inline. 

``` tf
provider "aws" {
  region = "eu-west-1"
}

variable "name" {
  type = string
  description = "Enter a name for the Unicorn"
}

data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

resource "aws_cloudformation_stack" "unicorn" {
  name = "ut-tf-resource"

  parameters = {
    UnicornName = var.name
  }

  template_body = <<STACK
{
  "Parameters" : {
    "UnicornName" : {
      "Type" : "String"
    }
  },
  "Resources" : {
    "Unicorn": {
      "Type" : "Custom::Unicorn",
      "Properties" : {
        "ServiceToken" : "arn:aws:lambda:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:function:CustomUnicornTracker",
        "UnicornName": { "Ref": "UnicornName" }
      }
    }
  }
}
STACK
}
```

Deploy the CloudFormation stack from your Terraform template. Our legacy Unicorn Tracker app asks for names and values of Unicorns you want to create or delete. 

```
$ terraform init
$ terraform apply
var.name
  Enter a name for the Unicorn

  Enter a value: <type a name for the unicorn>
...
$ terraform destroy
var.name
  Enter a name for the Unicorn

  Enter a value: <type a name for the unicorn>
```

### TF Modules

For this to work across multiple teams, this TF template needs to be a shared resource. To achieve this in Terraform you can create a TF module. Modules are the main way to package and reuse resource configurations with Terraform. Every Terraform configuration has at least one module, known as its root module, which consists of the resources defined in the .tf files in the main working directory.

#### Creating and sharing a module

The code in the module is the same as the code snippet above. This is the main.tf file in our root module.

```
provider "aws" {
  region = "eu-west-1"
}

variable "name" {
  type = string
  description = "Enter a name for the Unicorn"
}

data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

resource "aws_cloudformation_stack" "unicorn" {
  name = "ut-tf-resource"

  parameters = {
    UnicornName = var.name
  }

  template_body = <<STACK
{
  "Parameters" : {
    "UnicornName" : {
      "Type" : "String"
    }
  },
  "Resources" : {
    "Unicorn": {
      "Type" : "Custom::Unicorn",
      "Properties" : {
        "ServiceToken" : "arn:aws:lambda:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:function:CustomUnicornTracker",
        "UnicornName": { "Ref": "UnicornName" }
      }
    }
  }
}
STACK
```

 #### Share a TF module 

The source code is basically zipped into a location where the users have access. Here we share it on a public Amazon S3 bucket. In this case the S3 URL hosts  tfmodule.zip which is a package that contains main.tf shown above.

```
provider "aws" {}
provider "archive" {}

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "module_src/"
  output_path = "tfmodule.zip"
}

resource "aws_s3_bucket" "bucket" {
  bucket = "abc123-tf-modules"
}

resource "aws_s3_object" "data_zip" {
  bucket = aws_s3_bucket.bucket.id
  key    = data.archive_file.lambda_zip.output_path
  acl    = "public-read"
  source = data.archive_file.lambda_zip.output_path
  etag   = data.archive_file.lambda_zip.output_md5
}

output "url" {
  value = "https://${aws_s3_bucket.bucket.bucket_domain_name}/${aws_s3_object.data_zip.key}"
}

Using a TF module

To use the module in your code, you can reference the location where the module is hosted. Terraform modules can be shared on websites, GitHub, Amazon S3 buckets, and other such locations. 


provider "aws" {}

data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

module "unicorn" {
  source = "https://url.s3.amazonaws.com/tfmodule.zip"

  name = "Andy"
}
```

#### Advantages of this approach


Without the solution described above, teams working on this Unicorn Tracker were running into the following issues (and remember - this is a big legacy engineering project):  

* A change in the Unicorn Tracker codebase could potentially break the code for all users 
* Any changes needed validation from all teams before deployment. This meant reduced agility, and too many dependencies. 
* Every change had to be backwards compatible OR the deployments had to happen simultaneously. 
* Teams had to learn new coding languages to build the glue code. This was slowing down teams and also resulting in less-than-optimal code.


With the implementation of this solution, the problems mentioned above were solved. Teams could deploy changes into the Unicorn Tracker app. If the team was happy with the change, they could just share a new version of the TF module. The users of the new module had to only change the module version number and fix any dependencies.  That’s it!

This solution could be scaled to include other Infrastructure as Code providers as well. A team could just as well use AWS CDK and create a [L2 construct](https://docs.aws.amazon.com/cdk/v2/guide/constructs.html) with the code. A team working on Unicorn Tracker and AWS CDK could then just change the module number, fix dependencies and voila. As you can see the effort for each engineering team is minimal while keep the whole project agile and scalable. 

### Next Steps

The code for the solution above and a step-by-step [can be found here](https://github.com/tfworks/). An exercise for the reader is to achieve the same with a different IaC provider such as AWS CDK. 

This article is based on a talk originally presented at Re:Invent 2022 by Martijn van Dongen, Cloud Evangelist at Schuberg Phillis and Sohan Maheshwar, Senior Developer Advocate at Amazon Web Services. The recording of the talk (includes a demo) can be found here: 

https://www.youtube.com/watch?v=RxTVpqOZ62c
