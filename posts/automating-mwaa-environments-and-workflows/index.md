---
title: "Automate the Provisioning of Your Apache Airflow Environments"
description: "Managing services like Managed Workflows can reduce the complexity of Apache Airflow, but we still need a way to automate how we make Apache Airflow available to users. In this tutorial, you will learn how to reliably and consistently manage your Apache Airflow environments using CodePipelines and AWS CDK."
tags:
    - cicd
    - mwaa
    - aws
    - airflow
    - codepipeline
    - codecommit
    - codebuild
    - cdk

authorGithubAlias: ricsue-aws
authorName: Ricardo Sueiras
date: 2023-04-01
---

Organizations across the globe are striving to provide better service to internal and external stakeholders by enabling various divisions across the enterprise - like customer success, marketing, and finance - to make data-driven decisions. Founded upon DevOps principals, these organizations are increasingly taking a "DataOps" approach to helping them to enable the data driven business.

According to wikipedia: 

> DataOps is a set of practices, processes and technologies that combines an integrated and process-oriented perspective on data with automation and methods from agile software engineering to improve quality, speed, and collaboration and promote a culture of continuous improvement in the area of data analytics.
> 
> [source](https://en.wikipedia.org/wiki/DataOps)

DataOps grew out of frustrations trying to build a scalable, reusable data pipeline in an automated fashion.

> **Additional Reading** You can read more about this in this blog post, [Build a DataOps platform to break silos between engineers and analysts](https://aws.amazon.com/blogs/big-data/build-a-dataops-platform-to-break-silos-between-engineers-and-analysts/) and [Modern data engineering in higher ed: Doing DataOps atop a data lake on AWS](https://aws.amazon.com/blogs/publicsector/modern-data-engineering-higher-ed-dataops-data-lake/)

One of the tools that business has increasingly turned to in the journey to automate and streamline how they are able to extract insights from data is Apache Airflow. Apache Airflow is an open-source orchestration tool used to programmatically create workflows in Python that help you schedule, run, and manage data pipelines within your business. I speak with many customers that have tried and then adopted Apache Airflow because it is a great orchestration tool. As you scale usage and adoption, staying on top of how you manage and make Airflow available to your users can become overwhelming. 

The good news is that we can borrow heavily from modern development techniques, and specifically DevOps, to help us automate many if not most of the activities we need to scale. 

> **DevOps: What is it?**
> 
> DevOps is the combination of cultural philosophies, practices, and tools that increases an organisation’s ability to deliver applications and services at high velocity: evolving and improving products at a faster pace than organisations using traditional software development and infrastructure management processes. This speed enables organisations to better serve their customers and compete more effectively in the market.
> 
> [source](https://aws.amazon.com/devops/what-is-devops/)

## What you will learn

In this tutorial you will learn how you can apply DevOps techniques to help you effortlessly manage your Apache Airflow environments. We will look at some of the common challenges you are likely to encounter, and then look at the use of automation using infrastructure as code to show you how you can address these through automation. You will learn:

- What are the common challenges when scaling Apache Airflow, and how can you address those problems
- How to automate the provisioning of the Apache Airflow infrastructure using AWS CDK
- How to automate the deployment of your workflows and supporting resources

## Sections
<!-- Update with the appropriate values -->
| Info                | Level                                  |
| ------------------- | -------------------------------------- |
| ✅ AWS Level        | Beginner                               |
| ⏱ Time to complete  | 60 minutes                             |
| 💰 Cost to complete | Approx $100     |
| 🧩 Prerequisites    | - This tutorial assumes you have a working knowledge of Apache Airflow<br> - [AWS Account](https://portal.aws.amazon.com/billing/signup#/start/email)<br>- You will need to make sure you have enough capacity to deploy a new VPC - by default, you can deploy 5 VPCs in a region. If you are already at your limit, you will need to increase that limit or clean up one of your existing VPCs <br>- AWS CDK installed and configured (I was using 2.60.0 build 2d40d77)<br>- Access to an AWS region where Managed Workflows for Apache Airflow is supported<br> - git and jq installed<br> - The code has been developed on a Linux machine, and tested/working on a Mac. It should work on a Windows machine with the Windows Subsystem for Linux (WSL) installed although I have not tested this. If you do encounter issues, I recommend that you spin up an Amazon Cloud9 IDE environment and run through the code there.|
| 💻 Code Sample         | Code sample used in tutorial on [GitHub](https://github.com/build-on-aws/automating-mwaa-environments-and-workflows)                             |
| 📢 Feedback            | <a href="https://pulse.buildon.aws/survey/HYUBZ0ZU" target="_blank">Help us improve how we support Open Source at AWS</a>    |
| ⏰ Last Updated     | 2023-03-20                             |

| ToC |
|-----|

---

## Scaling Apache Airflow

Like many open source technologies, there are many ways in which you can configure and deploy Apache Airflow. For some, self managing Apache Airflow is the right path for them to take. For others, the availability of managed services such as Managed Workflows for Apache Airflow (MWAA), has helped reduce the complexity and operation burden for running Apache Airflow, and opened this up for more Builders to start using it.

It is worth spending some time to understand some of the challenges scaling Apache Airflow. So what are some of the challenges? 

* Apache Airflow is a complex technology to manage, with lots of moving parts. Do you have the skills or the desire to want to manage this?
* There is constant innovation within the Apache Airflow community, and your data engineers will want to quickly take advantage of the latest updates. How quickly are you able to release updates and changes to support their need?
* How do you ensure that you can provide the best developer experience and to help minimise the issues with deploying workflows to production?
* Ensuring that you bake security from the beginning, how can you separate concerns and make sure that you minimise the number of secrets that developers need access to?
* Deploying workflows to production can break Apache Airflow, so how do you minimise this?
* New Python libraries are released on a frequent basis, new data tools are also constantly changing. How do you enable these for use within your Apache Airflow environments?

One of the first decisions you have to make is whether you want to use a managed versus self managed Apache Airflow environment. Typically this choice depends on a number of factors based on your particular business or use case. These include:

* whether you need the increase level of access, a greater level of control of the configuration of Apache Airflow
* have the need to have the very latest versions or features of Apache Airflow
* if you have the need to run workflows that use more resources that managed services provide (for example, need significant compute)

> **Total Cost Ownership** One thing to consider when assessing managed vs self managed is the cost of the managed service against the total costs of you having to do the same thing. It is important to assess a true like for like, and we often see just the actual compute and storage resources being compared without all the additional things that you need to make this available.
>

If the answer to these is yes, then it is likely that using a managed service may frustrate you.

**How to navigate this tutorial**

This tutorial will cover how to automate the provisioning of managed and self managed Apache Airflow environments, before looking at how some options to help you improve the developer experience and making it easier to get their workflows into production.

We will start off with how we can automate managed Apache Airflow environments, using Amazon Managed Workflows for Apache Airflow (MWAA). We will look at automating the provisioning of the infrastructure using AWS Cloud Development Kit (AWS CDK). We will then show how to build a pipeline that automates the deployment of your workflow code. Finally, we will provide an end to end example that uses a GitOps approach for managing both the infrastrucutre and workflows via your git repository.

Watch out for the next tutorial, where we will cater for those looking to achieve the same thing with self managed Apache Airflow. In that tutorial we will explore some options you can take, before walking through and building a GitOps approach to running your self managed Apache Airflow environments.


## Automating your Managed Workflow for Apache Airflow environments (MWAA)

**Overview**

MWAA is a fully managed service that allows you to deploy upstream versions of Apache Airflow. In this section we are going to show you how you can deploy MWAA environments using Infrastructure as Code. We will be using AWS CDK as our infrastructure as code tool of choice. The end result will be that you build an Apache Airflow environment on AWS that looks like this:

![MWAA Architecture overview](images/mwaa-architecture-iac.png)

When deploying a MWAA environment it is helpful to understand the key components that we need, to help us understand what we need to automate. When you deploy MWAA, you have to:

* create a VPC into which MWAA resources will be deployed (See the architecture diagram above)
* ensure we have a unique S3 bucket that we can define for our Airflow DAGs folder
* determine whether we want to integrate Airflow Connections and Variables with AWS Secrets Manager
* create our MWAA environment

**Our CDK stack**

We will be using AWS CDK to automate the deployment and configuration of our MWAA environments. As Apache Airflow is a tool for Python developers, we will develop this "stack" (CDK terminology for an application that builds AWS resources) in Python.

> The code is available in the supporting repository - see resources above.

When we look at the code, you will notice that our stack has a number of files and resources:

```
├── app.py
├── cdk.json
├── mwaa_cdk
│   ├── mwaa_cdk_dev_env.py
│   └── mwaa_cdk_vpc.py
└── requirements.txt
```

Our stack contains a number of key elements which we will explore in detail. We want to ensure that we can create code that is re-usable based on different requirements, so we will define configuration parameters to enable that re-use so we can use the code to create multiple environments.

The app.py file is our CDK app entry point, and defines what we will deploy. You will see that we define our AWS environment and region we want to deploy, as well as some MWAA specific parmeters:

```
# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0
#!/usr/bin/env python3

import aws_cdk as cdk 

from mwaa_cdk.mwaa_cdk_vpc import MwaaCdkStackVPC
from mwaa_cdk.mwaa_cdk_dev_env import MwaaCdkStackDevEnv

env_EU=cdk.Environment(region="{AWSREGION}", account="{YOURAWSACCNT")
mwaa_props = {'dagss3location': 'mwaa-094459-devops-demo','mwaa_env' : 'mwaa-devops-demo', 'mwaa_secrets_var':'airflow/variables', 'mwaa_secrets_conn':'airflow/connections'}

app = cdk.App()

mwaa_devopswld_vpc = MwaaCdkStackVPC(
    scope=app,
    id="mwaa-devops-vpc",
    env=env_EU,
    mwaa_props=mwaa_props
)

mwaa_devopswld_env_dev = MwaaCdkStackDevEnv(
    scope=app,
    id="mwaa-devops-dev-environment",
    vpc=mwaa_devopswld_vpc.vpc,
    env=env_EU,
    mwaa_props=mwaa_props
)


app.synth()

```

The parameters we define in this stack are:

* dagss3location - this is the Amazon S3 bucket that MWAA will use for the Airflow DAGs. You will need to ensure that you use something unique or the stack will fail
* mwaa_env - the name of the MWAA environment (that will appear in the AWS console and all cli interactions)

The next two we will see in the next part of the tutorial, so don't worry too much about these for the time being.

* mwaa_secrets_var - this is the prefix you will use to integrate with AWS Secrets Manager for Airflow Variables
* mwaa_secrets_conn - this is the prefix, as the previous, but for Airflow Connections.

There are two stacks that are used to create resources. "MwaaCdkStackVPC" is used to create our VPC resources where we deploy MWAA. "MwaaCdkStackDevEnv" is used to create our MWAA environment. "MwaaCdkStackDevEnv" has a dependency on the VPC resources, so we will deploy this stack first. Let us explore the code:

```

from aws_cdk import (
    aws_ec2 as ec2,
    Stack,
    CfnOutput
)
from constructs import Construct

class MwaaCdkStackVPC(Stack):

    def __init__(self, scope: Construct, id: str, mwaa_props, **kwargs) -> None:
        super().__init__(scope, id, **kwargs)
   
        # Create VPC network

        self.vpc = ec2.Vpc(
            self,
            id="MWAA-DevOpsDemo-ApacheAirflow-VPC",
            ip_addresses=ec2.IpAddresses.cidr("10.192.0.0/16"),
            max_azs=2,
            nat_gateways=1,
            subnet_configuration=[
                ec2.SubnetConfiguration(
                    name="public", cidr_mask=24,
                    reserved=False, subnet_type=ec2.SubnetType.PUBLIC),
                ec2.SubnetConfiguration(
                    name="private", cidr_mask=24,
                    reserved=False, subnet_type=ec2.SubnetType.PRIVATE_WITH_EGRESS)
            ],
            enable_dns_hostnames=True,
            enable_dns_support=True
        )


        CfnOutput(
            self,
            id="VPCId",
            value=self.vpc.vpc_id,
            description="VPC ID",
            export_name=f"{self.region}:{self.account}:{self.stack_name}:vpc-id"
        )
```

We can deploy the VPC by running:

```
cdk deploy mwaa-devops-vpc
```

And in a few moments, it should start deploying. It will take 5-10 minutes to complete.

```
✨  Synthesis time: 8.48s

mwaa-devops-vpc: building assets...

[0%] start: Building 79937fb364dbc1582cf6fdc5a8512d7b7e651a833c551d330d09d80a1bdd7820:704533066374-eu-west-2
[100%] success: Built 79937fb364dbc1582cf6fdc5a8512d7b7e651a833c551d330d09d80a1bdd7820:704533066374-eu-west-2

mwaa-devops-vpc: assets built

mwaa-devops-vpc: deploying... [1/1]
[0%] start: Publishing 79937fb364dbc1582cf6fdc5a8512d7b7e651a833c551d330d09d80a1bdd7820:704533066374-eu-west-2
[100%] success: Published 79937fb364dbc1582cf6fdc5a8512d7b7e651a833c551d330d09d80a1bdd7820:704533066374-eu-west-2
mwaa-devops-vpc: creating CloudFormation changeset...
[██▌·······················································] (1/23)

12:55:43 PM | CREATE_IN_PROGRESS   | AWS::CloudFormation::Stack            | mwaa-devops-vpc
12:55:48 PM | CREATE_IN_PROGRESS   | AWS::EC2::EIP                         | MWAA-DevOpsDemo-Ap.../publicSubnet1/EIP
12:55:48 PM | CREATE_IN_PROGRESS   | AWS::EC2::InternetGateway             | MWAA-DevOpsDemo-ApacheAirflow-VPC/IGW
12:55:49 PM | CREATE_IN_PROGRESS   | AWS::EC2::VPC                         | MWAA-DevOpsDemo-ApacheAirflow-VPC


 ✅  mwaa-devops-vpc

✨  Deployment time: 203.17s

Outputs:
mwaa-devops-vpc.ExportsOutputRefMWAADevOpsDemoApacheAirflowVPC6BCB1144F03B298E = vpc-0fe5d94126e565558
mwaa-devops-vpc.ExportsOutputRefMWAADevOpsDemoApacheAirflowVPCprivateSubnet1Subnet098AE99142C9E55B = subnet-0de1bb9b17a9be64d
mwaa-devops-vpc.ExportsOutputRefMWAADevOpsDemoApacheAirflowVPCprivateSubnet2Subnet49E71BD9F7E4C9D0 = subnet-0faae51f83750269e
mwaa-devops-vpc.VPCId = vpc-0fe5d94126e565558
Stack ARN:
arn:aws:cloudformation:eu-west-2:704533066374:stack/mwaa-devops-vpc/85e737d0-bdb0-11ed-929b-060b1defad6c

✨  Total time: 211.65s
```

We can now look at the MwaaCdkStackDevEnv stack that creates our MWAA environment into the VPC that we just created. The code is documented to help you understand how it works and help you customise it to your own needs. You will notice that we bring in parameters we defined in the "app.py" using ```f"{mwaa_props['dagss3location']```, so you can adjust and tailor this code to your own needs if you wanted to add additional configuration parameters.

First we create and tag our S3 bucket that we will use to store our workflows (the Airflow DAGS folder)

> **Note!** that this code creates an S3 Bucket with the name of the configuration parameter and then appends "-dev", so using our example code the S3 Bucket that would get created is "mwaa-094459-devops-demo-dev"

```
        # Create MWAA S3 Bucket and upload local dags

        s3_tags = {
            'env': f"{mwaa_props['mwaa_env']}-dev",
            'service': 'MWAA Apache AirFlow'
        }

        dags_bucket = s3.Bucket(
            self,
            "mwaa-dags",
            bucket_name=f"{mwaa_props['dagss3location'].lower()}-dev",
            versioned=True,
            block_public_access=s3.BlockPublicAccess.BLOCK_ALL
        )

        for tag in s3_tags:
            Tags.of(dags_bucket).add(tag, s3_tags[tag])

        dags_bucket_arn = dags_bucket.bucket_arn
```

The next section create the various IAM policies needed for MWAA to run. This uses the parameters we have defined, and is scoped down to the minimum permissions required. I will not include the code here as it is verbose, but you can check it out in the code repo.

The next section is also security related, and configures security groups for the various MWAA services to communicate with each other.

The next section defines what logging we want to use when creating our MWAA environment. There is a cost element associated with this, so make sure you think about what is the right level of logging for your particular use case. You can find out more about the different logging levels you can use by checking out the documentation [here](https://docs.aws.amazon.com/cdk/api/v1/python/aws_cdk.aws_mwaa/CfnEnvironment.html#aws_cdk.aws_mwaa.CfnEnvironment.LoggingConfigurationProperty)

```
    # **OPTIONAL** Configure specific MWAA settings - you can externalise these if you want

        logging_configuration = mwaa.CfnEnvironment.LoggingConfigurationProperty(
            dag_processing_logs=mwaa.CfnEnvironment.ModuleLoggingConfigurationProperty(
                enabled=True,
                log_level="INFO"
            ),
            task_logs=mwaa.CfnEnvironment.ModuleLoggingConfigurationProperty(
                enabled=True,
                log_level="INFO"
            ),
            worker_logs=mwaa.CfnEnvironment.ModuleLoggingConfigurationProperty(
                enabled=True,
                log_level="INFO"
            ),
            scheduler_logs=mwaa.CfnEnvironment.ModuleLoggingConfigurationProperty(
                enabled=True,
                log_level="INFO"
            ),
            webserver_logs=mwaa.CfnEnvironment.ModuleLoggingConfigurationProperty(
                enabled=True,
                log_level="INFO"
            )
        )

```

The next section allows us to define some custom Apache Airflow configuration options. These are documented on the MWAA website, but I have included some here so you can get started and tailor to your needs.


```
        options = {
            'core.load_default_connections': False,
            'core.load_examples': False,
            'webserver.dag_default_view': 'tree',
            'webserver.dag_orientation': 'TB'
        }

        tags = {
            'env': f"{mwaa_props['mwaa_env']}-dev",
            'service': 'MWAA Apache AirFlow'
        }
```

The next section create a KMS key and supporting IAM policies to make sure that MWAA encrypts everything.

The final section actually creates our MWAA environment, using all the objects created beforehand. You can tailor this to your needs.

```
        # Create MWAA environment using all the info above

        managed_airflow = mwaa.CfnEnvironment(
            scope=self,
            id='airflow-test-environment-dev',
            name=f"{mwaa_props['mwaa_env']}-dev",
            airflow_configuration_options={'core.default_timezone': 'utc'},
            airflow_version='2.4.3',
            dag_s3_path="dags",
            environment_class='mw1.small',
            execution_role_arn=mwaa_service_role.role_arn,
            kms_key=key.key_arn,
            logging_configuration=logging_configuration,
            max_workers=5,
            network_configuration=network_configuration,
            #plugins_s3_object_version=None,
            #plugins_s3_path=None,
            #requirements_s3_object_version=None,
            #requirements_s3_path=None,
            source_bucket_arn=dags_bucket_arn,
            webserver_access_mode='PUBLIC_ONLY',
            #weekly_maintenance_window_start=None
        )

        managed_airflow.add_override('Properties.AirflowConfigurationOptions', options)
        managed_airflow.add_override('Properties.Tags', tags)
```

Before proceeding you should make sure that the S3 bucket you have selected has not been created and is unique. If the CDK deployment fails, it it typically due to this issue.

We can now deploy MWAA using the following command:

```
cdk deploy mwaa-devops-dev-environment
```

This time you will be prompted to proceed. This is because you are creating IAM Policies and additional security configurations and CDK wants you to make sure that you review these before proceeding. After you have checked it, answer Y to start the deployment

```
(NOTE: There may be security-related changes not in this list. See https://github.com/aws/aws-cdk/issues/1299)

Do you wish to deploy these changes (y/n)? y
mwaa-devops-dev-environment: deploying... [2/2]
[0%] start: Publishing 3474e40ce2d4289e489135153d5803eeddfaf5690820166aa763fe36af91ff54:704533066374-eu-west-2
[0%] start: Publishing 2bc265c5e0569aeb24a6349c15bd54e76e845892376515e036627ab0cc70bb64:704533066374-eu-west-2
[0%] start: Publishing 91ab667f7c88c3b87cf958b7ef4158ef85fb9ba8bd198e5e0e901bb7f904d560:704533066374-eu-west-2
[0%] start: Publishing 928e66c0f69701e1edd93d9283845506b7ca627455684b4d91a8a96f13e187d0:704533066374-eu-west-2
[25%] success: Published 2bc265c5e0569aeb24a6349c15bd54e76e845892376515e036627ab0cc70bb64:704533066374-eu-west-2
[50%] success: Published 91ab667f7c88c3b87cf958b7ef4158ef85fb9ba8bd198e5e0e901bb7f904d560:704533066374-eu-west-2
[75%] success: Published 928e66c0f69701e1edd93d9283845506b7ca627455684b4d91a8a96f13e187d0:704533066374-eu-west-2
[100%] success: Published 3474e40ce2d4289e489135153d5803eeddfaf5690820166aa763fe36af91ff54:704533066374-eu-west-2
mwaa-devops-dev-environment: creating CloudFormation changeset...
[████▏·····················································] (1/14)

1:13:16 PM | CREATE_IN_PROGRESS   | AWS::CloudFormation::Stack     | mwaa-devops-dev-environment
```

This will take between 25-30 minutes, so time to grab that well earned drink. Once it has finished, you should see something like this:

```
 ✅  mwaa-devops-dev-environment

✨  Deployment time: 1659.28s

Outputs:
mwaa-devops-dev-environment.MWAASecurityGroupdev = sg-0f5553f9c1f37d0fe
Stack ARN:
arn:aws:cloudformation:eu-west-2:704533066374:stack/mwaa-devops-dev-environment/88d05bf0-bdda-11ed-b72d-0227f9640b62

✨  Total time: 1670.12s
```
**Checking our environment**

Congratulations, you have automated the deployment of your MWAA environment. This is just the beginning however, and there is more stuff you need to automate so lets look at those next. Before we do that, lets make sure that everything is working ok and check our installation.

We can go to the MWAA console and we should see our new environment listed, together with a link to the web based Apache Airflow UI.

![The Managed Workflows for Apache Airflow console listing our newly created Apache Airflow environment](images/airflowcicd-console.png)

We can also get this via the command line using the following command:

```
aws mwaa get-environment --name {name of the environment created} --region={region} | jq -r '.Environment | .WebserverUrl'
```
which will output the link to the Apache Airflow UI.
```
89ba6225-846e-43e6-8abc-53f43d8ccdc1.c2.eu-west-2.airflow.amazonaws.com
```
When we enter this into a browser, we see the Apache Airflow UI.

![The Apache Airflow UI for our newly created Apache Airflow environment](images/airflowcicd-ui.png)

**Recap and next steps**

In the first part of this tutorial, we looked at how we could use AWS CDK to create a configurable stack that allows us to deploy Apache Airflow environments via the Managed Workflows for Apache Airflow managed service. In the next part, we will build upon this and start to look how we can automate another important part of Apache Airflow - Connections and Variables.

## Automating Connections and Variables

Apache Airflow allows you to store data in its metastore that you can then rely upon when you are writing your workflows. This allows you to parameterise your code and create more re-usable workflows. The two main ways Airflow helps you do this is by storing Variables and Connections. Variables are key pair values that you can then refer to via Airflow code. Connections are used by Operators to abstract connection and authentication details, thus allowing you to separate what the sys admins and security folk know (all the secret stuff that goes into connecting to stuff) versus what your developer need to know (the Connection id). Both Variables and Connections are encrypted in the Airflow metastore.

> **Read more** Check out this detailed post to dive even deeper into this topic - https://dev.to/aws/working-with-parameters-and-variables-in-amazon-managed-workflows-for-apache-airflow-4f5h

The Apache Airflow UI provides a way to store variables and connections details, but ideally you want to provision these in the same way you provision your infrastructure. We can integrate MWAA to use AWS Secrets Manager for this, meaning we can manage all our Variables and Connection information using the same tools we are using to manage MWAA. The way this works is that we define a prefix, we store our Variables and Connections in AWS Secret Manager using that prefix, and then finally, we integrate AWS Secrets Manager into Airflow using the defined prefix, at which point when it looks for Variables and Connections it will do a lookup to AWS Secrets Manager.

**Integrating AWS Secret Manager**

We first have to enable the integration. There are two Airflow configuration settings we need to set. We can adjust our original CDK code and add the following.  You will notice that we are using configuration parameters we define in the app.py to allow us to easily set what we want the prefix to be. We do not want to hard code the prefix for Connections and Variables, so we define some additional configuration parameters in our app.py file that will use "airflow/variables" and "airflow/connections" as the integration points within MWAA


```
     'secrets.backend' : 'airflow.providers.amazon.aws.secrets.secrets_manager.SecretsManagerBackend',
     'secrets.backend_kwargs' : { "connections_prefix" : f"{mwaa_props['mwaa_secrets_conn']}" , "variables_prefix" : f"{mwaa_props['mwaa_secrets_var']}" } ,
                  
```
so the code now looks like

```
        options = {
            'core.load_default_connections': False,
            'core.load_examples': False,
            'webserver.dag_default_view': 'tree',
            'webserver.dag_orientation': 'TB',
            'secrets.backend' : 'airflow.providers.amazon.aws.secrets.secrets_manager.SecretsManagerBackend',
            'secrets.backend_kwargs' : { "connections_prefix" : f"{mwaa_props['mwaa_secrets_conn']}" , "variables_prefix" : f"{mwaa_props['mwaa_secrets_var']}" } ,            
        }
```

> **How does this work?** To define variables or connections that MWAA can use, you create these in AWS Secrets Manager using the prefix you defined. In the above example, we have set these to airflow/variables and airflow/connections. If I create a new secret called "airflow/variable/foo" then from within my Airflow workflows, I can reference the variable as "foo" using Variable.get within our Airflow code.
> **Dive Deeper** Read the blog post from John Jackson that looks at this feature in more detail -> [Move your Apache Airflow connections and variables to AWS Secrets Manager](https://aws.amazon.com/blogs/opensource/move-apache-airflow-connections-variables-aws-secrets-manager/)

If we were to update and redeploy our CDK app, once MWAA had finished updating, the integration will now attempt to access AWS Secrets for this information. This would fail however, as we have not enabled our MWAA environment to access those Secrets in AWS Secrets Manager so we need to modify our CDK app to add some additional permissions:

```
        mwaa_secrets_policy_document = iam.Policy(self, "MWAASecrets", 
                    statements=[
                        iam.PolicyStatement(
                            actions=[
                                "secretsmanager:GetResourcePolicy",
                                "secretsmanager:GetSecretValue",
                                "secretsmanager:DescribeSecret",
                                "secretsmanager:ListSecretVersionIds",
                                "secretsmanager:ListSecrets"
                            ],
                            effect=iam.Effect.ALLOW,
                            resources=[
                                f"arn:aws:secretsmanager:{self.region}:{self.account}:secret:{mwaa_props['mwaa_secrets_var']}*",
                                f"arn:aws:secretsmanager:{self.region}:{self.account}:secret:{mwaa_props['mwaa_secrets_conn']}*",
                                ],
                        ),
                    ]
        )
        mwaa_service_role.attach_inline_policy(mwaa_secrets_policy_document)
```

We can update our environment by running:

```
cdk deploy mwaa-devops-dev-environment
```

And after being prompted to review security changes, CDK will make the changes and MWAA will update. This will take between 20-25 minutes, so grab yourself another cup of tea! When it finishes, you should see something like

```

mwaa-devops-dev-environment: creating CloudFormation changeset...

 ✅  mwaa-devops-dev-environment

✨  Deployment time: 873.73s

Outputs:
mwaa-devops-dev-environment.MWAASecurityGroupdev = sg-0f5553f9c1f37d0fe
Stack ARN:
arn:aws:cloudformation:eu-west-2:704533066374:stack/mwaa-devops-dev-environment/88d05bf0-bdda-11ed-b72d-0227f9640b62

✨  Total time: 883.92s
```

**Testing Variables**

We can now test this by creating some Variables and Connections within AWS Secrets Manager and then creating a sample workflow to see the values presented.

First we will create a new secret, remembering to store this in the same AWS region as where our MWAA environment is deployed. We can do this at the command line using the AWS cli.

```
aws secretsmanager create-secret --name airflow/variables/buildon --description "Build on AWS message" --secret-string "rocks!" --region={your region}"

```

>**Tip!** If you wanted to provide a set of standard Variables or Connections when deploying your MWAA environments, you could add these by updating the CDK app and using the AWS Secrets constructs. **HOWEVER** make sure you understand that if you do this, those values will be visible, so do not share "secrets" that you care about. It is better to deploy and configure these outside of the provisioning of the environment so that these are not stored in plan view.


Now we can create a workflow that tests to see if we can see this value.

```
from datetime import datetime
from airflow import DAG
from airflow.operators.dummy_operator import DummyOperator
from airflow.operators.python_operator import PythonOperator
from airflow.models import Variable

message = Variable.get("buildon", default_var="could not find variable on secret manager")

def print_hello():
 print(message)
 return 'Hello Wolrd'

dag = DAG('hello_world_schedule', description='Hello world example', schedule_interval='0 12 * * *', start_date=datetime(2017, 3, 20), catchup=False)

dummy_operator = DummyOperator(task_id='dummy_task', retries = 3, dag=dag)
hello_operator = PythonOperator(task_id='hello_task', python_callable=print_hello, dag=dag)
dummy_operator >> hello_operator


```

You will notice that we use the standard Airflow way of working with variables (from airflow.models import Variable) and then we just create a new variable within our workflow that grabs the variable we defined in AWS Secrets Manager (/airflow/variables/buildon) but we just refer to it as "buildon"). We also add a default value incase that fails, which can be helpful when troubleshooting issues with this.

```
message = Variable.get("buildon", default_var="could not find variable on secret manager")
```


We deploy this workflow by copying it to the MWAA Dags Folder S3 bucket, and after a few minutes you can enable and then trigger this workflow. When you look at the Log output, you should see something like:


```
[2023-03-09, 08:43:26 UTC] {{taskinstance.py:1383}} INFO - Executing <Task(PythonOperator): hello_task> on 2023-03-09 08:43:18.798898+00:00
[2023-03-09, 08:43:26 UTC] {{standard_task_runner.py:55}} INFO - Started process 1378 to run task
[2023-03-09, 08:43:26 UTC] {{standard_task_runner.py:82}} INFO - Running: ['airflow', 'tasks', 'run', 'hello_world_schedule', 'hello_task', 'manual__2023-03-09T08:43:18.798898+00:00', '--job-id', '5', '--raw', '--subdir', 'DAGS_FOLDER/sample-cdk-dag.py', '--cfg-path', '/tmp/tmpxpdth0nh']
[2023-03-09, 08:43:26 UTC] {{standard_task_runner.py:83}} INFO - Job 5: Subtask hello_task
[2023-03-09, 08:43:27 UTC] {{task_command.py:376}} INFO - Running <TaskInstance: hello_world_schedule.hello_task manual__2023-03-09T08:43:18.798898+00:00 [running]> on host ip-10-192-2-6.eu-west-2.compute.internal
[2023-03-09, 08:43:27 UTC] {{taskinstance.py:1590}} INFO - Exporting the following env vars:
AIRFLOW_CTX_DAG_OWNER=airflow
AIRFLOW_CTX_DAG_ID=hello_world_schedule
AIRFLOW_CTX_TASK_ID=hello_task
AIRFLOW_CTX_EXECUTION_DATE=2023-03-09T08:43:18.798898+00:00
AIRFLOW_CTX_TRY_NUMBER=1
AIRFLOW_CTX_DAG_RUN_ID=manual__2023-03-09T08:43:18.798898+00:00
[2023-03-09, 08:43:27 UTC] {{logging_mixin.py:137}} INFO - rocks!
[2023-03-09, 08:43:27 UTC] {{python.py:177}} INFO - Done. Returned value was: Hello Wolrd
[2023-03-09, 08:43:27 UTC] {{taskinstance.py:1401}} INFO - Marking task as SUCCESS. dag_id=hello_world_schedule, task_id=hello_task, execution_date=20230309T084318, start_date=20230309T084326, end_date=20230309T084327
[2023-03-09, 08:43:27 UTC] {{local_task_job.py:159}} INFO - Task exited with return code 0

```
**Connections**

One area of confusion I have seen is how to handle Connections when they are stored in AWS Secrets Manager. So let us look at that now. If we wanted to create a connection to an Amazon Redshift cluster. From the Apache Airflow UI, we would typically configure this like so:

![example screenshot from apache airflow ui configuring amazon redshift connection](images/airflow-connections-example-redshift.png)

What we would do is store this in AWS Secrets Manager as follows

```
aws secretsmanager create-secret --name airflow/connections/redshift_default --description "Connect to Amazon Redshift Cluster BuildON" --secret-string "Postgres://awsuser:XXXXX@airflow-summit.cq7hpqttbcoc.eu-west-1.redshift.amazonaws.com:5439/mwaa" --region={your region}"

```

When you now reference "redshift_default" as a connection within Apache Airflow, it will use these values. Some Connections require addition information in the Extras field, so how do you add these? Lets say the Connection needed some Extra data, we would add this by appending the extra info with "?{parameter}={value}&{parameter}={value}". Applying this to the above we would create our secret like:


```
aws secretsmanager create-secret --name airflow/connections/redshift_default --description "Connect to Amazon Redshift Cluster BuildON" --secret-string "Postgres://awsuser:XXXXX@airflow-summit.cq7hpqttbcoc.eu-west-1.redshift.amazonaws.com:5439/mwaa?param1=value1&param2=value2" --region={your region}"
```

**Advanced features**

The AWS integration with AWS Secrets Manager is part of the Apache Airflow Amazon Provider package. This package is regularly updated, and provides all the various Airflow Operators that enable you to integrate with AWS services. If you are using a newer version of the Amazon Provider package (version 7.3 or newer) then you can do some additional things when configuring the AWS Secrets Manager, such as:

* configure whether you want to use both Variables and Connections, or just one of them
* allow you to specify regular expressions to combine both native Airflow Variables and Connections (that will be stored in the Airflow metastore), and AWS Secrets Manager

In the following example, Airflow would only do lookups to AWS Secrets Manager for any Connections that were defined as "aws-*", so for example aws-redshift, or aws-athena.

```
[secrets]
backend = airflow.providers.amazon.aws.secrets.secrets_manager.SecretsManagerBackend
backend_kwargs = {
  "connections_prefix": "airflow/connections",
  "connections_lookup_pattern": "^aws-*",
  "profile_name": "default"
}
```

Check out the full details on the Apache Airflow documentation page, [AWS Secrets Manager Backend](https://aws-oss.beachgeek.co.uk/2mo)

**Recap and next steps**

In this part of this tutorial, we looked at how we could automate Variable and Connections within Apache Airflow, and how these are useful in helping us creating re-usable workflows. In the next part of this tutorial, we will look at how we can build an automated pipeline to deliver our workflows into our Apache Airflow environment.

## Building a workflow deployment pipeline

So far we have automated the provisioning of our MWAA environments using AWS CDK, and sh we now have Apache Airflow up and running. In this next part of the tutorial we are going to automate how to deploy our workflows to these environments. Before we do that, a quick recap on how MWAA loads its workflows and supporting resources.

MWAA uses an Amazon S3 bucket as the DAGs Folder. In addition to this, additional libraries are specified in a configuration value which points to a specific version of a requirements.txt file which we upload to an S3 bucket. Finally, if you want to deploy your own custom Airflow plugins, then these also need to be deployed to an S3 bucket and then the MWAA configuration updated.

We will start by creating a simple pipeline that takes our workflows from a git repository hosted on AWS CodeCommit, and then automatically deploys this to our MWAA environment.

**Creating your Pipeline**

We are going to automate the provisioning of our pipeline and all supporting resources. Before we do that, let us consider what we need. In order to create an automated pipeline to deploy our workflows into our MWAA environment, we will:

* need to have a source code repository where our developers will commit their final workflow code
* once we have detected new code in our repository, we want to run some kind of tests
* if our workflow code passess all test, we might want to get a final review/approval before it is pushed to our MWAA environment
* the final step is for the pipeline to deliver the workflow into our MWAA DAGs Folder

We will break this down into a number of steps to make it easier to follow along. If we look at our code repository we can see we have some CDK code which we will use to provision the supporting infrastructure, but we also have our source DAGs that we want to initially populate our MWAA environments with.

```
├── app.py
├── cdk.json
├── mwaa_pipeline
│   ├── MWAAPipeline.py
├── repo
│   └── dags
│       ├── first_bash_copy_file.py
│       └── new_workflow.py
└── requirements.txt
```

Our CDK app is very simple, and contains the initial entry point file where we define configuration values we want to use, and then the code to build the pipeline infrastructure ("MWAAPipeline"). If we look at app.py

```
import aws_cdk as cdk 

from mwaa_pipeline.MWAAPipeline import MWAAPipeline

env=cdk.Environment(region="AWSREGION", account="AWSACCOUNT")
airflow_props = {'code_repo_name': 'mwaa-dags','branch_name' : 'main', 'dags_s3_bucket_name' : 'mwaa-094459-devops-demo-dev'}


app = cdk.App()

mwaa_cicd_pipeline = MWAAPipeline(
    scope=app,
    id="mwaa-pipeline",
    env=env,
    airflow_props=airflow_props
)

app.synth()
```

We can see that we define the following:

* 'code_repo_name' and 'branch_name' which will create an AWS CodeCommit repository,
* 'dags_s3_bucket_name' which is the name of our DAGs Folder for our MWAA environment 


The actual stack itself ("MWAAPipeline") is where we create the CodeCommit repository, and configure our CodePipeline and the CodeBuild steps. If we look at this code we can see we start by creating our code repository for our DAGs

```
        # Setup CodeCommit repo and copy initial files

        dags_bucket = f"{airflow_props['dags_s3_bucket_name']}"
        dags_bucket_arn = s3.Bucket.from_bucket_name(self, "GetDAGSbucket", f"{airflow_props['dags_s3_bucket_name']}").bucket_arn

        repo = codecommit.Repository(
            self,
            "Repository",
            repository_name=f"{airflow_props['code_repo_name']}",
            code=codecommit.Code.from_directory("repo",f"{airflow_props['branch_name']}")
        )
        cdk.CfnOutput(self, "Repository_Name", value=repo.repository_name)
```

We define a CodeBuild task to deploy our DAGs to the S3 DAGs folder that was created when we deployed the MWAA environment. We define an environment variable for the S3 Bucket that will be created in the CodeBuild runner ($BUCKET_NAME) so that we can re-use this pipeline.

```
        deploy = codebuild.Project(
            self,
            "DAGS_Deploy",
            source=codebuild.Source.code_commit(repository=repo, branch_or_ref=f"{airflow_props['branch_name']}"),
            environment=codebuild.BuildEnvironment(compute_type=codebuild.ComputeType.SMALL, privileged=True, build_image=codebuild.LinuxBuildImage.AMAZON_LINUX_2_4),
            environment_variables={"BUCKET_NAME": codebuild.BuildEnvironmentVariable(value=dags_bucket)},
            build_spec=codebuild.BuildSpec.from_object(
                dict(
                    version="0.2",
                    phases={
                        "pre_build": {"commands": ["aws --version", "echo $BUCKET_NAME"]},
                        "build": {"commands": ["cd dags", "aws s3 sync . s3://$BUCKET_NAME/dags/ --delete"]},
                    },
                )
            ),
        )
``` 

You will notice that we are simply using the aws cli to sync the files from the checked out repo to the target S3 bucket. Now if you tried this as it stands it would fail, and that is because CodeBuild needs permissions. We can add those easily enough. We scope the level of access just down to the actual DAGs bucket itself.

```
        deploy.add_to_role_policy(iam.PolicyStatement(
            actions=[
                "s3:*"], 
            effect=iam.Effect.ALLOW,
            resources=[ f"{dags_bucket_arn}", f"{dags_bucket_arn}/*" ],)
            )
```

The final part of the code are the different stages of the pipeline. As this is a very simple pipeline, it only has two stages:

```
        source_output = codepipeline.Artifact()
        deploy_output = codepipeline.Artifact("AirflowImageBuild")

        pipeline = codepipeline.Pipeline(
            self,
            "MWAA_Pipeline"
        )
        
        source_action = codepipeline_actions.CodeCommitSourceAction(
            action_name="CodeCommit",
            repository=repo,
            output=source_output,
            branch=f"{airflow_props['branch_name']}"
        )


        build_action = codepipeline_actions.CodeBuildAction(
            action_name="Build_action",
            input=source_output,
            project=deploy,
            outputs=[deploy_output]
        )
        pipeline.add_stage(
            stage_name="Source",
            actions=[source_action]
        )


        pipeline.add_stage(
            stage_name="Deployment",
            actions=[build_action]
        )
        

```

We can deploy our pipeline using the following command, answering y after reviewing the security information that pops up.

```
cdk deploy mwaa-pipeline
```

After a few minutes, you can check over in the AWS CodePipelines console, and you should now have a new pipeline. This should have executed, and it will most likely be in the process of running. When it finishes, you should now see the two workflow DAGs appear in your Apache Airflow UI. (Note! This could take 4-5 minutes before your MWAA environment picks up these DAGs)

![The Apache Airflow UI showing two DAGs now in the console](images/airflowcicd-pipedags.png)


**Implementing intermediary Step**

The workflow created so far is very simple. Every time a commit is made, the build pipeline will automatically sync this to the MWAA S3 DAGs folder. This might be fine for simple development environments, but you would ideally need to add some additional steps within your build pipeline. For example:

* running tests - you might want to ensure that before deploying the files to the S3 DAGs folder, that you run some basic tests to make sure they are valid and will reduce the likelihood of errors when deployed
* approvals - perhaps you want to implement an additional approval process before deploying to your production environemnts

We can easily add additional steps to achieve these by augmenting our CDK code.

**Adding a testing stage**

It is a good idea to implement some kind of test stage before you deploy your DAGs to your S3 DAGs folder. We will use a very simplified test in this example, but in reality you would need to think about a number of different tests you want to do to ensure you deploy your DAGs reliable into your MWAA environment.

We will use our CodeCommit repository to store any assets we need for running tests - scripts, resource files, binaries.

We can use the existing pipeline we have created and add a new stage where we can execute some testing. To do this we add a new build step where we define what we want to do:

```
        test = codebuild.Project(
            self,
            "DAGS_Test",
            source=codebuild.Source.code_commit(repository=repo, branch_or_ref=f"{airflow_props['branch_name']}"),
            environment=codebuild.BuildEnvironment(compute_type=codebuild.ComputeType.SMALL, privileged=True, build_image=codebuild.LinuxBuildImage.AMAZON_LINUX_2_4),
            environment_variables={"BUCKET_NAME": codebuild.BuildEnvironmentVariable(value=dags_bucket)},
            build_spec=codebuild.BuildSpec.from_object(
                dict(
                    version="0.2",
                    phases={
                        "pre_build": {"commands": ["aws --version", "echo $BUCKET_NAME"]},
                        "build": {"commands": ["echo 'Testing'"]},
                    },
                )
            ),
        )
```

and then we add the stage and modify the existing ones as follows:

```

        source_output = codepipeline.Artifact()
        test_output = codepipeline.Artifact()
        deploy_output = codepipeline.Artifact("AirflowImageBuild")

        pipeline = codepipeline.Pipeline(
            self,
            "MWAA_Pipeline"
        )
        
        source_action = codepipeline_actions.CodeCommitSourceAction(
            action_name="CodeCommit",
            repository=repo,
            output=source_output,
            branch=f"{airflow_props['branch_name']}"
        )

        test_action = codepipeline_actions.CodeBuildAction(
            action_name="Test",
            input=source_output,
            project=test,
            outputs=[test_output]
        )

        build_action = codepipeline_actions.CodeBuildAction(
            action_name="Build_action",
            input=source_output,
            project=deploy,
            outputs=[deploy_output]
        )
        pipeline.add_stage(
            stage_name="Source",
            actions=[source_action]
        )

        pipeline.add_stage(
            stage_name="Testing",
            actions=[test_action]
        )

        pipeline.add_stage(
            stage_name="Deployment",
            actions=[build_action]

        )
```


We can update the pipeline by just redeploying our CDK app

```
cdk deploy mwaa-pipeline
```

And after a few minutes, you should now have a new test stage. In our example we just echo "test" but you would add all the commands you would typically use and define them in this step. You could also include additional resources within the git repository and uses those (for example, unit tests or configuration files for your testing tools) 

**Adding an approval stage**

You may also need to add an approval gate. We can easily add this to our pipeline, and is as simple as adding this code:

```
        approval = pipeline.add_stage(
            stage_name="Approve")
        manual_approval_action = codepipeline_actions.ManualApprovalAction(
            action_name="Approve",
            notification_topic=sns.Topic(self, "Topic"),  # optional
            notify_emails=["YOUR@EMAIL.ADDR"],
            additional_information="additional info")
        approval.add_action(manual_approval_action)

```

You also need to make sure that this step is added BEFORE the deployment stage, so in the final code in the repo we have

```
        pipeline.add_stage(
            stage_name="Testing",
            actions=[test_action]
        )

        approval = pipeline.add_stage(
            stage_name="Approve")
        manual_approval_action = codepipeline_actions.ManualApprovalAction(
            action_name="Approve",
            notification_topic=sns.Topic(self, "Topic"),  # optional
            notify_emails=["YOUR@EMAIL.ADDR"],
            additional_information="additional info")
        approval.add_action(manual_approval_action)

        pipeline.add_stage(
            stage_name="Deployment",
            actions=[build_action]
        )
```

When you redeploy the CDK app using "cdk deploy mwaa-pipeline" you will receive an email to confirm that you are happy to receive notifications from the approval process we have just setup (otherwise you will receive no notifications!).

```
You have chosen to subscribe to the topic: 
arn:aws:sns:eu-west-2:704533066374:mwaa-pipeline-TopicBFC7AF6E-KUjxGcbAFog2

To confirm this subscription, click or visit the link below (If this was in error no action is necessary): 
Confirm subscription

Please do not reply directly to this email. If you wish to remove yourself from receiving all future SNS subscription confirmation requests please send an email to sns-opt-out
```

When you make a change to your workflow code, once your pipeline runs, you will now get an email notification asking you to review and approve the change. Until you do this (click on the Approval link), the DAGs will not get deployed. This is an example mail that I got when using this code:

```
Hello,

The following Approval action is waiting for your response:

--Pipeline Details--

Pipeline name: mwaa-pipeline-MWAAPipeline97839E8E-B58OAGC4ALOT
Stage name: Approve
Action name: Approve
Region: eu-west-2

--Approval Details--

Approve or reject: https://console.aws.amazon.com/codesuite/codepipeline/pipelines/mwaa-pipeline-MWAAPipeline97839E8E-B58OAGC4ALOT/view?region=eu-west-2#/Approve/Approve/approve/a049b46a-56ad-45af-971a-476975a657d7
Additional information: additional info
Deadline: This review request will expire on 2023-03-16T18:56Z

Sincerely,
Amazon Web Services
```

I can use that link which will take me straight to the AWS Console and I can then review and approve if needed.

![sample screen from codepipeline that shows waiting for approval](images/airflowcicd-pipeline-approval.png)

Once we approve, the pipeline will continue and the deployment step will update the DAGs. Congratulations, you have now automated the deployment of your DAGs!


> ### Advanced automation topics
>
>So far we have just scratched the surface of how you can apply DevOps principles to your data pipelines. If you want to dive deeper, there are some additional topics that you can explore to further automate and scale your Apache Airflow workflows.
>
>**Parameters and reusable workflows**
>
>Creating re-usable workflows will help scale how your data pipelines are used. A common technique is to create generic workflows that are driven by parameters, driving up re-use of those workflows. There are many approaches to help you increase the reuse of your workflows, and you can read more about this by checking out this post, [Working with parameters and variables in Amazon Managed Workflows for Apache Airflow](https://dev.to/aws/working-with-parameters-and-variables-in-amazon-managed-workflows-for-apache-airflow-4f5h)
>
>**Using private Python library repositories**
>
>When building your workflows, you will use Python libraries to help you achieve your tasks. For many organisations, using public libraries is a concern and they look to control where those libraries are loaded from. In addition, Development teams are also creating in-house libraries that need to be stored somewhere. Builders often use private repositories to help them solve this. In the post, [Amazon MWAA with AWS CodeArtifact for Python dependencies](https://aws.amazon.com/blogs/opensource/amazon-mwaa-with-aws-codeartifact-for-python-dependencies/), shows you how you how to integrate Amazon MWAA with AWS CodeArtifact for Python dependencies.
>
>
>**Observability - CloudWatch dashboard and metrics**
>
>Read the post, [Automating Amazon CloudWatch dashboards and alarms for Amazon Managed Workflows for Apache Airflow](https://aws.amazon.com/blogs/compute/automating-amazon-cloudwatch-dashboards-and-alarms-for-amazon-managed-workflows-for-apache-airflow/) which provides a solution that automatically detects any deployed Airflow environments associated with the AWS account and then builds a CloudWatch dashboard and some useful alarms for each.
>
>In the post, [Introducing container, database, and queue utilization metrics for the Amazon MWAA environment](https://aws.amazon.com/blogs/compute/introducing-container-database-and-queue-utilization-metrics-for-the-amazon-mwaa-environment/), dives deeper into metrics you can better understand the performance of your Amazon MWAA environment, troubleshoot issues related to capacity, delays, and get insights on right-sizing your Amazon MWAA environment.
>

**Recap and next steps**

In this part of this tutorial, we showed how to build a pipeline to automate the process of delivering your workflows from your developers to your Apache Airflow environments. In the next part of this tutorial, we will bring this all together and look at an end to end fully automated solution for both infrastructure and workflows.

## Building an end to end pipeline

So far we have built a way of automating the deployment of your MWAA environments and implemented a way of automating how to deploy your workflows to your MWAA environments. We will now bring this all together and build a solution that enables a GitOps approach that will automatically provision and update your MWAA environments based on configuration details stored in a git repository, and also deploy your workflows and all associated assets (for example, additional Python libraries you might define in your requirements.txt, or custom plugins you want to use in your workflows)

This is what we will build. There will be two different git repositories used by two different groups of developers. Our MWAA admins who look after the provisioning of the infrastructure (including the deployment of support packages, Python libraries, etc) will manage the MWAA environments using one git repository. Our Airflow developers will create their code in a separate repository. Both groups will interact using git to update and make changes.

![an end to end fully automated gitops pipeline for MWAA](images/airflowcici-end2end.png)

We will use AWS CDK to automate this again. First of all, lets explore the files for this solution. If we look at the expanded file tree, we can see what this looks like.

```
└── cdk-amazon-mwaa-cicd
    ├── app.py
    ├── cdk.json
    ├── setup.py
    ├── mwaairflow
    │   ├── __init__.py
    │   ├── assets
    │   │   ├── plugins
    │   │   │   ├── __init__.py
    │   │   │   ├── operators
    │   │   │   │   ├── __init__.py
    │   │   │   │   └── salesforce_to_s3_operator.py
    │   │   │   └── salesforce_to_s3_plugin.py
    │   │   ├── plugins.zip
    │   │   └── requirements.txt
    │   ├── mwaairflow_stack.py
    │   ├── nested_stacks
    │   │   ├── __init__.py
    │   │   ├── environment.py
    │   │   ├── project.py
    │   │   ├── provisioning.py
    │   │   └── vpc.py
    │   └── project
    │       ├── Makefile
    │       ├── cookiecutter-config-file.yml
    │       ├── dags
    │       │   ├── __init__.py
    │       │   └── example_dag.py
    │       ├── poetry.lock
    │       ├── pyproject.toml
    │       ├── setup.cfg
    │       ├── src
    │       │   ├── __init__.py
    │       │   ├── __main__.py
    │       │   ├── example.py
    │       │   └── py.typed
    │       └── tests
    │           └── test_example
    │               └── test_hello.py
    └── requirements.txt

```
The setup.py is used to initialise Python, and makes sure that all the dependencies for this stack are available.  In our instance, we need the following

```
        "aws-cdk-lib==2.68.0",
        "constructs>=10.0.0,<11.0.0",
        "boto3"
```
The entry point for the CDK app is "app.py", where we define our AWS Account and Region information. We then have a directory called "mwaairflow" which contains a number of key directories:

* assets - this folder contains resources that you want to deploy to your MWAA environment, specifically a requirements.txt file that allows you to amend which Python libraries you want installed and available, and then packages up and deploys a plugin.zip which contains some sample code for custom Airflow operators you might want to use. In this particular example you can see we have custom Salesforce operator
* nested_stacks - this folder contains the CDK code that provisions the VPC infrastructure, then deploys the MWAA environment, and then finally deploys the Pipeline
* project - this folder contains the Airflow workflows that you want to deploy in the DAGs folder. This example provides some additional code around Python linting and testing which you can amend to run before you deploy your workflows

> **Makefile** in our previous pipeline we defined the mechanism to deploy our workflows via the AWS CodeBuild Buildspec file. This time we have created a Make file and within it created a number of different tasks (test, validated, deploy, etc). To deploy our DAGs this time, all we need to do is run a "make deploy $bucket_name=" specifying the target S3 bucket we want to use.

In the previous example where we automated the MWAA environment build, we defined configuration values in our app.py file. This time, we are using a different way of passing in configuration parameters. With AWS CDK you can use the "-- context" when performing the cdk deploy command, to pass in configuration values in a key/value .

```
cdk deploy --context vpcId=vpcid --context envName=mwaademo {cdkstack} 
```

* vpcId  - If you have an existing VPC that meets the MWAA requirements (perhaps you want to deploy multiple MWAA environments in the same VPC for example) you can pass in the VPCId you want to deploy into. For example, you would use --contenxt vpcId=vpc-095deff9b68f4e65f
* cidr - If you want to create a new VPC, you can define your preferred CIDR block using this parameter (otherwise a default value of 172.31.0.0/16 will be used). For example, you would use --context cidr=10.192.0.0/16
* subnetIds	- Is a comma separated list of subnets IDs where the cluster will be deployed. If you do not provide one, it will look for private subnets in the same AZ
* envName - a string that represents the name of your MWAA environment, defaulting to "MwaaEnvironment" if you do not set this. For example, --context envName=MyAirflowEnv
* envTags - allows you to set Tags for the MWAA resources, providing a json expression. For example, you would use --context envTags='{"Environment":"MyEnv","Application":"MyApp","Reason":"Airflow"}'
* environmentClass	- allows you to configure the MWAA Workers size (either mw1.small, mw1.medium, mw1.large, defaulting to mw1.small). For example, --context 	environmentClass=mw1.medium
* maxWorkers	- change the number of MWAA Max Workers, defaulting to 1. For example, --context maxWorkers=2
* webserverAccessMode	- define whether you want a public or private endpoint for your MWAA Environment (using PUBLIC_ONLY or PRIVATE_ONLY).  For example, you would use --context webserverAccessMode=PUBLIC_ONLY mode (private/public)
* secretsBackend	- configure whether you want to integrate with AWS Secrets Manager, using values Airflow or SecretsManager. For example, you would use --context secretsBackend=SecretsManager 

We can see how our CDK app uses this by examining the "mwaairflow_stack" file, which our app.py file calls.

```
        # Try to get Stack params
        self.subnet_ids_list = self.node.try_get_context("subnetIds") or ""
        self.env_name = self.node.try_get_context("envName") or "MwaaEnvironment"
        self.env_tags = self.node.try_get_context("envTags") or {}
        self.env_class = self.node.try_get_context("environmentClass") or "mw1.small"
        self.max_workers = self.node.try_get_context("maxWorkers") or 1
        self.access_mode = (
            self.node.try_get_context("webserverAccessMode") or "PUBLIC_ONLY"
        )
        self.secrets_backend = self.node.try_get_context("secretsBackend")

```

To deploy this stack, we use the following command

```
cdk deploy --context cidr=10.192.0.0/16 --context envName=MWAAe2e --context envTags= '{"Environment":"MWAAe2e","Application":"MyApp","Reason":"Airflow"}'  --context secretsBackend=SecretsManager  --context webserverAccessMode=PUBLIC_ONLY MWAAirflowStack
```

This will take about 25-30 minutes to complete, so grab a cup of your favourite warm beverage. When it finishes, you can see a new MWAA environment appear in the console.

![screenshot of mwaa console showing a new environment](images/airflowcicd-end2endconsole.png)

If we go to AWS CodeCommit, we see we have two repositories: mwaa-provisioning and mwaaproject.

**mwaa-provisioning**

When we look at the source files in this repo, we will see that they are a copy of the stack we used to initially deploy it. 

```
├── app.py
├── cdk.context.json
├── cdk.json
├── mwaairflow
│   ├── __init__.py
│   ├── assets
│   │   ├── plugins
│   │   │   ├── __init__.py
│   │   │   ├── operators
│   │   │   │   ├── __init__.py
│   │   │   │   └── salesforce_to_s3_operator.py
│   │   │   └── salesforce_to_s3_plugin.py
│   │   ├── plugins.zip
│   │   └── requirements.txt
│   ├── mwaairflow_stack.py
│   ├── nested_stacks
│   │   ├── __init__.py
│   │   ├── environment.py
│   │   ├── project.py
│   │   ├── provisioning.py
│   │   └── vpc.py
│   └── project
│       ├── Makefile
│       ├── archive
│       │   ├── code.zip
│       │   └── docker
│       │       ├── Dockerfile
│       │       └── README.md
│       ├── code.zip
│       ├── dags
│       │   ├── __init__.py
│       │   └── example_dag.py
│       ├── poetry.lock
│       ├── pyproject.toml
│       ├── setup.cfg
│       ├── src
│       │   ├── __init__.py
│       │   ├── __main__.py
│       │   ├── example.py
│       │   └── py.typed
│       └── tests
│           └── test_example
│               └── test_hello.py
├── requirements.txt
└── setup.py
```
As a system administrator, if we wanted to update our MWAA environments from a configuration perspective (for example, maybe we wanted to change an Airflow configuration settings, or perhaps change the size of our MWAA Workers, or maybe change logging settings) we just need to check the repo out, make our change to the code ( in our mwaairflow_stack file) and then push the change back to the git repository. This will kick off the AWS CodePipeline and trigger the reconfiguration.

If we wanted to update our Python libraries, or maybe we have been sent some updated plugins we want available on the workers, we do the same thing. We just need to adjust the files in the assets folder, and when we commit this back to the git repository, it will trigger a reconfiguration of our MWAA environment.

In both examples, depending on the change, you may trigger a restart of your MWAA environment so make sure you are aware of this before you kick that off.

Lets do a quick example of making a change. It is a typical operation to update the requirements.txt file to update the Python libraries. We are going to update our MWAA environment to use a later version of the Amazon Provider package. We need to check out the repo, make the change and then commit it back.

```
git clone https://git-codecommit.eu-west-2.amazonaws.com/v1/repos/mwaa-provisioning
cd mwaa-provisioning
vi requirements.txt
```
We update the Amazon Provider package from

```
apache-airflow==2.4.3
apache-airflow-providers-salesforce==5.1.0
apache-airflow-providers-amazon==6.0.0
apache-airflow-providers-postgres==5.2.2
apache-airflow-providers-mongo==3.0.0
```
to
```
apache-airflow==2.4.3
apache-airflow-providers-salesforce==5.1.0
apache-airflow-providers-amazon==7.1.0
apache-airflow-providers-postgres==5.2.2
apache-airflow-providers-mongo==3.0.0
```
We the push this change to the repo

```
git add .
git commit -m "update requirements.txt to update amazon provider to 7.1"
git push
```
And we see that we have kicked off the pipeline

![screenshot of pipeline running](images/airflowcicd-updatereqs.png)

When it is finished, when we go to the MWAA environment we can see that we have a newer file, but the older one is still active.

![screenshot of MWAA environment showing plugin and requirements.txt](images/airflowcicd-reqsupdateconsole.png)


*Updating the requirements.txt*

You may be wondering why the latest requirements.txt has not been set by the MWAA environment. The reason for this is that this is going to trigger an environment restart, and so this is likely something you want to think about before doing. You could automate this, and we would add the following to the deploy part of the CodeBuild deployment stage

```
bucket_name=f"{bucket.bucket_name}"
mwaa_env=f"{env_name}"
latest=$(aws s3api list-object-versions --bucket $bucket_name --prefix requirements/requirements.txt --query 'Versions[?IsLatest].[VersionId]' --output text)
aws mwaa update-environment --name $mwaa_env --requirements-s3-object-version=$latest 
```

>**Tip!** If you wanted to run this separately, just set the bucket_name and mwaa_env variables to suit your environment

This will trigger an environment update, using the latest version of the requirements.txt file.

**mwaaproject**

When we look at the source files in this repo, we will see that they contain files that we can deploy to our Airflow DAGs folder (which for MWAA is an S3 bucket).

```
├── Makefile
├── dags
│   ├── __init__.py
│   └── example_dag.py
├── poetry.lock
├── pyproject.toml
├── setup.cfg
├── src
│   ├── __init__.py
│   ├── __main__.py
│   ├── example.py
│   └── py.typed
└── tests
    └── test_example
        └── test_hello.py
``` 

In our example, we are only using the dags folder to store our workflows. When we add or change our workflows, once these are committed to our git repository, this will trigger the AWS CodePipeline to run the Makefile deploy task, copying the dags folder to our MWAA environment. You can use and adjust this workflow to do more complex workflows, for example, developing support Python resources that you might use within your workflows.

In our example, we are only using the dags folder to store our workflows. When we add or change our workflows, once these are committed to our git repository, this will trigger the AWS CodePipeline to run the Makefile deploy task, copying the dags folder to our MWAA environment. You can use and adjust this workflow to do more complex workflows, for example, developing support Python resources that you might use within your workflows.

We can see this in motion by working through a simple example of adding a new workflow. We first check out the repo locally and add our new workflow file (demo.py) which you can find in the source repository.

```
git clone https://git-codecommit.eu-west-2.amazonaws.com/v1/repos/mwaaproject
cd mwaaproject/dags
cp demo.py .
```

We now commit this back to the repo

```
git add .
git commit -m "new dag - demo.py"
git push
```

Which we can now see triggers our CodePipeline.

![screenshot of AWS CodePipline deploying new DAG](images/airflowcicd-dagpipedeploy.png)

After a few minutes, we can see this has been successful and when we go back to the Apache Airflow UI, we can see our new workflow.

![Screenshot of Apache Airflow UI showing new DAG](images/airflowcicd-demo.png)

>**Check the CodeBuild logs** If you want more details as to what happened during both the environment and workflow pipelines, you can view the logs from the CodeBuild runners.

Congratulations, you have now completed this tutorial in helping you apply DevOps principals to automate how you deliver your MWAA environments, and how you streamline how you deploy your workflows. Before you leave, make sure you clean up you environment so that you do not leave any resources running.

**Cleaning up**

To remove all the resources created following this post, you can use CDK and run the following commands:

To delete the first part of this tutorial, 
```
cdk destroy mwaa-pipeline
cdk destroy mwaa-devops-dev-environment
cdk destroy mwaa-devops-vpc
```

To delete the second part of the tutorila, the end to end stack, 
```
cdk destroy MWAAirflowStack
```

> **Note!** The delete process will fail at some point due to not being able to delete the S3 buckets. You should delete these buckets (Empty and the Delete) and then manually delete the stacks via the CloudFormation console.

### That's all folks!

In this tutorial we looked at some of the challenges automating Apache Airflow, and how we can apply DevOps principals to address those. In this post we looked at how you do that with Amazon's Managed Workflow for Apache Airflow (MWAA), and in the next tutorial post, we will look at how you can do the same but with self managed Apache Airflow environment.

If you enjoyed this tutorial, please let us know how we can better serve open source Builders by <a href="https://pulse.buildon.aws/survey/DEM0H5VW" target="_blank">completing this short survey. </a> Thank you!
