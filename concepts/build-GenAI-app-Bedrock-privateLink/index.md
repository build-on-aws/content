---
title: "How to build GenAI application using Amazon Bedrock with AWS PrivateLink to protect your data privacy"  
description: "Manage and protect data security and compliance standards."
tags:  
  - Amazon Bedrock
  - GenAI
  - Private Link
  - Data Privacy
authorGithubAlias: Xiaoyuao988
authorName: Xiaoyu Xing
date: 2023-12-20
---

Most would likely agree that **Data Privacy** is an important issue that cannot be overlooked when it comes to data analytics and machine learning. **Generative AI** is making waves, but without proper security control, Generative AI tools could be susceptible to data theft. This could lead to unauthorized access or disclosure of sensitive information, potentially leading to privacy violations and possible misuse of both sensitive personal data or intellectual property.

[Amazon Bedrock](https://aws.amazon.com/bedrock/security-compliance/), a fully managed service, allows you to build generative AI applications that support data security and compliance standards, including **GDPR** and **HIPAA**.

With **Amazon Bedrock**, ***(not limited to)***
* Your **content** (e.g. prompt data, fine-tuning data, vector store data with RAG (***Retrieval Augmented Generation***) etc.) is not shared with a third party model providers (including AWS).
* You can use **AWS PrivateLink** to establish private connectivity between the **Foundation Models (FM)** and on-premises networks or your **AWS VPC (Virtual Private Cloud)**, without exposing your traffic to the **public internet**. (***This blog post's focus***)
* Your data is always **encrypted in transit** (***TLS1.2***) and **at rest**. You can use your own keys or [AWS KMS (Key Management Service)](https://aws.amazon.com/kms/) keys to encrypt the data.
* You can encrypt and store **customized (fine-tuned) models** with a KMS key that's either managed by AWS or by yourself.
  You can further configure VPC for fine-tuning jobs with Bedrock, which prevent the **training data** from being accessible over the internet.
* **Potential misuse** is prevented by [Bedrock abuse detection](https://docs.aws.amazon.com/bedrock/latest/userguide/abuse-detection.html). This feature **automatically** ***(no human review or access to user inputs or model outputs)*** identifies and mitigates potential violations of AWS's [Acceptable Use Policy (AUP)](https://aws.amazon.com/aup/) and [Responsible AI Policy](https://aws.amazon.com/machine-learning/responsible-ai/policy/), or a third party model provider's AUP.

As you can see, Amazon Bedrock provides you comprehensive security and compliance capabilities. Let's dive a bit deeper on using **AWS PrivateLink** to establish private connectivity between your **GenAI application** and the FMs or your fine-tuned models on **Amazon Bedrock**.

## AWS PrivateLink

Privacy breaches on the internet present genuine risks, with [AWS PrivateLink](https://docs.aws.amazon.com/vpc/latest/privatelink/what-is-privatelink.html), you can link your own VPCs, on-premise networks, and supported AWS services (e.g. Amazon Lambda, Amazon Bedrock) privately (private IP) without exposing your data to the public internet.

The figure below shows how AWS PrivateLink works.

**Interface VPC endpoint**, powered by **PrivateLink**, connect you to: 
- other AWS services
- services hosted by AWS Partners
- supported solutions available in AWS Marketplaces
- enterprise applications in another VPC

![How AWS PrivateLink works](images/PrivateLinkHowItWorks.png)

Security benefits of AWS PrivateLink:
- **Regulatory Compliance** (e.g. **HIPAA**, **PCI**) - preventing sensitive data (e.g.PII) from traversing through the internet.
- **Privately access AWS services** - connecting your VPC to AWS services privately. 
You can configure security groups of services (e.g. ***Lambda***) on your VPC to control the access to the corresponding AWS services (e.g. ***Bedrock***) as well.

In addition to the security benefit, AWS PrivateLink also makes it easier to connect AWS services across different AWS accounts and VPCs to simplify your network architecture.

## How To Build a GenAI Application With AWS PrivateLink to Amazon Bedrock

There are many patterns to build up GenAI application with Amazon Bedrock. Let's focus on demonstration of how to establish a private link with Bedrock with ***Amazon Lambda function*** as the key component of a GenAI application.

The figure below shows the reference architecture, where the client can access to the GenAI application via AWS PrivateLink. Client can be on-premise or on AWS VPC (which can be the same or different from where the GenAI application located). Be aware that the GenAI application should be on the **same region** with the connected Amazon Bedrock endpoint. At the time of writing this blog post, Amazon Bedrock is not supported in all the AWS Regions, so remember to check the [supported regions](https://docs.aws.amazon.com/bedrock/latest/userguide/what-is-bedrock.html#bedrock-regions).

![PrivateLink to Bedrock](images/lambda-bedrock-architecture.png)

 One way to build this up is to follow the steps below:

### 1. **Create Lambda Functions as Part of Your GenAI Application Interacting With Foundation Models via Bedrock**

I use this [example](https://github.com/mavi888/sam-bedrock-lambda) as a simplified GenAI application, where Lambda functions interact with Amazon Bedrock to generate text.

![Lambda Function](images/lambda.png)

### 2. **Create VPC with private subnets**

From VPC console:

![VPC-1](images/vpc_1.png)

Configure VPC settings:

![VPC-2](images/vpc_2.png)

**Note:**
  - When creating VPC choose Tenancy with "Default" since Lambda doesn't work with "[Dedicated](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/dedicated-instance.html)" tenancy for now.
    To connect to resources in a dedicated VPC, [peer it to a second VPC with default tenancy](https://aws.amazon.com/premiumsupport/knowledge-center/lambda-dedicated-vpc/).

  - It is a good idea to have at least **2** AZs([Availability Zones](https://aws.amazon.com/about-aws/global-infrastructure/regions_az/)) and **2 subnets** considering **resilience**.

  - You have the option to choose the specific AZs. This is useful since not all AZs support **Bedrock VPC endpoint**. To identify which AZs are in an [**AWS region**](https://aws.amazon.com/about-aws/global-infrastructure/regions_az/) and support Bedrock VPC endpoint, run the following command:

```go
//Replace <region> with your chosen region
 aws ec2 describe-vpc-endpoint-services --service-names com.amazonaws.<region>.bedrock-runtime --region <region>
```

An example of use-east-1 is like this:

![Bedrock-AZ](images/bedrock_az.png)


### 3. **Create a Security Group in the VPC**
   
   [Security Group](https://docs.aws.amazon.com/vpc/latest/userguide/vpc-security-groups.html) controls the traffic that is allowed to reach (***inbound rules***) and leave (***outbound rules***) the resources that it is associated with.
   In this example, create a security group with inbound rule allowing **HTTPS** protocol.
   Limit the source IP addresses if you only need to allow a list of specific IP addresses to access your application.

![SG-1](images/sg_1.png)

Setup inbound and outbound rules:

![SG-2](images/sg_2.png)

   
### 4. **Connect Your Lambda Functions to Your VPC**

Lambda function is by default running on the Lambda service VPC with public internet access. To connect your lambda function to your own VPC, use a [Hyperplane ENI (Elastic Network Interface)](https://docs.aws.amazon.com/lambda/latest/dg/foundation-networking.html#foundation-nw-connecting). Hyperplane ENIs provides NAT capabilities from the Lambda VPC to your account VPC. When creating or updating a Lambda function, Lambda allocates one Hyperplane ENI for each subnet in the function's VPC configuration.

  ***4.1. Before connecting your Lambda function to your VPC, you need to give extra permission to the lambda function's execution role***

  - Get the Lambda function's execution role:

![Lambda-Role-1](images/lambda-role-1.png)


  - [AWS IAM(Identity & Access Management)](https://aws.amazon.com/iam/?nc=sn&loc=0) console, add AWS managed policy - **AWSLambdaVPCAccessExecutionRole**
 
 This role allows Lambda to do the following actions:
  - "logs:CreateLogGroup"
  - "logs:CreateLogStream"
  - "logs:PutLogEvents"
  - "ec2:CreateNetworkInterface"
  - "ec2:DescribeNetworkInterfaces"
  - "ec2:DeleteNetworkInterface"
  - "ec2:AssignPrivateIpAddresses"
  - "ec2:UnassignPrivateIpAddresses"


![Lambda-Role-2](images/lambda-role-2.png)


  ***4.2. Configure Lambda VPC access***
  
  Add the private subnets and security group to the Lambda function's VPC configuration.

![Lambda-VPC](images/lambda-vpc.png)

Now your Lambda function is connected with your VPC. You can repeat the same steps for other Lambda functions.

### 5. **Create a Bedrock VPC Endpoint**

  In order to connect your VPC and Amazon Bedrock service using AWS PrivateLink, you need to create an [**interface VPC endpoint**](https://docs.aws.amazon.com/vpc/latest/privatelink/create-interface-endpoint.html#create-interface-endpoint-aws).

  From VPC console, create an endpoint:

  ![Bedrock-VPC-endpoint-1](images/bedrock-endpoint-1.png)

  Choose [Bedrock VPC endpoints](https://docs.aws.amazon.com/bedrock/latest/userguide/vpc-interface-endpoints.html) as ***"bedrock-runtime"***:

  ![Bedrock-VPC-endpoint-2](images/bedrock-endpoint-2.png)

  Choose VPC and private subnets created in step two:

  ![Bedrock-VPC-endpoint-3](images/bedrock-endpoint-3.png)

  You can further control Bedrock VPC endpoint access via [endpoint policy](https://docs.aws.amazon.com/vpc/latest/privatelink/vpc-endpoints-access.html).

```go
// An example of a custom endpoint policy, which grants access to listed Amazon Bedrock actions for all principals on all resources.
{
   "Statement": [
      {
         "Principal": "*",
         "Effect": "Allow",
         "Action": [
            "bedrock:InvokeModel",
            "bedrock:InvokeModelWithResponseStream"
         ],
         "Resource":"*"
      }
   ]
}
```

Configure endpoint policy:

![Bedrock-VPC-endpoint-policy](images/bedrock-endpoint-policy.png)


### 6. **Test Your GenAI Application With PrivateLink Connection to Amazon Bedrock**

After all the above steps, it is time to test your GenAI application by invoking Lambda functions.

The test can be executed form your client or from a Lambda console:

  ![Test-1](images/test_1.png)

Check the response:

  ![Test-2](images/test_2.png)

Detailed logs from Lambda function's corresponding **CloudWatch logs** are like this. This is useful for troubleshooting.

  ![Test-3](images/test_3.png)


### Summary
This example is focusing on Lambda as GenAI application key component.

If your application uses additional AWS beyond Amazon Lambda--and it interacts with Amazon Bedrock and supports VPC connections--then the same approach described in this blog can also be applied to those services.


## Conclusion

**AWS PrivateLink** is powerful to privately connect your services on VPC with **Amazon Bedrock**.
With AWS PrivateLink, you can further control who can access your application and what actions they can take via Security Group and Endpoint Policy.

Building up your GenAI with **Amazon Bedrock**, your prompts and your data is not used in AWS's first class models or 3rd party models; data remains in the region where they were created; all the customization (fine-tuning model) you do with the model is per customer, per tenant, completely isolated, encrypted, and maintained completely separated from the models themselves.