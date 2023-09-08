---
title: "5 ways to cost optimize your Infrastructure as Code"
description: Learn five code snippets that you can add to your existing AWS CloudFormation templates to prevent cost waste.
tags:
  - cost-optimization
  - finops
  - cloud-financial-management
  - infrastructure-as-code
  - cloudformation
spaces:
  - cost-optimization
waves:
  - cost
authorGithubAlias: awssteph
authorName: Steph Gooch
date: 2023-09-08
---

| ToC |
|-----|

Builders! Have you been asked to increase efficiency in your AWS accounts?

Today, we’ll share five code snippets you can add to your Infrastructure as Code(IaC) to prevent cost waste. For for each code snippet, we will tell you why you need the code, what the change will do, and the code you can copy for AWS CloudFormation template.

* Amazon CloudWatch Log Group Retention
* Amazon Simple Storage Service (Amazon S3) Lifecycle rules for unused objects
* AWS Graviton for AWS Managed Services
* gp3 for Amazon Elastic Block Store (Amazon EBS) volumes
* Amazon Elastic File System (Amazon EFS) Infrequent Access

## Amazon CloudWatch Log Group Retention

When creating resources, such as an AWS Lambda functions, if you do not create an Amazon CloudWatch Log group, AWS will create it for you. When logs are created, the default retention policy is `Never expire` which means you will store, and more importantly, pay for those logs forever! But if you create the CloudWatch log group upon resource provisioning, then you can define the retention period yourself.

This code can be added to your template when you create an AWS lambda function.

```yaml
  LambdaLogGroup:
    Type: AWS::Logs::LogGroup
    Properties:
      LogGroupName: !Sub "/aws/lambda/${LambdaFunctionResource}"
      RetentionInDays: 14
```

Check out [AWS::Logs::LogGroup](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-logs-loggroup.html?sc_channel=el&sc_campaign=costwave&sc_content=5-ways-to-cost-optimize-your-Infrastructure-as-Code&sc_geo=mult&sc_country=mult&sc_outcome=acq) in the Documentation

In the example code above, we have set it to two weeks, but remember this should be configured for your applications run frequency. For example, if you run the AWS Lambda function every hour, then maybe you only need a week’s worth of data. (Please check your company policy on data retention). You can track the impact in [Amazon Cost Explorer](https://us-east-1.console.aws.amazon.com/cost-management/home?region=us-east-1#/cost-explorer?chartStyle=STACK&costAggregate=unBlendedCost&endDate=2023-09-04&excludeForecasting=false&filter=%5B%7B%22dimension%22:%7B%22id%22:%22RecordTypeV2%22,%22displayValue%22:%22Charge%20type%22%7D,%22operator%22:%22EXCLUDES%22,%22values%22:%5B%7B%22value%22:%22Refund%22,%22displayValue%22:%22Refund%22%7D,%7B%22value%22:%22Credit%22,%22displayValue%22:%22Credit%22%7D%5D%7D,%7B%22dimension%22:%7B%22id%22:%22Service%22,%22displayValue%22:%22Service%22%7D,%22operator%22:%22INCLUDES%22,%22values%22:%5B%7B%22value%22:%22AmazonCloudWatch%22,%22displayValue%22:%22CloudWatch%22%7D%5D%7D%5D&futureRelativeRange=CUSTOM&granularity=Daily&groupBy=%5B%22UsageType%22%5D&historicalRelativeRange=CUSTOM&isDefault=true&reportName=New%20cost%20and%20usage%20report&showOnlyUncategorized=false&showOnlyUntagged=false&startDate=2023-08-01&usageAggregate=undefined&useNormalizedUnits=false). Looking at Usage type that is like TimedStorage-ByteHrs when filtered to Amazon CloudWatch Service.

## Amazon Simple Storage Lifecycle rules for unused objects

When storing objects in Amazon S3, there are two overlooked types of objects that could be costing you money, and you aren’t even using them!

* [Delete Markers](https://docs.aws.amazon.com/AmazonS3/latest/userguide/DeleteMarker.html?sc_channel=el&sc_campaign=costwave&sc_content=5-ways-to-cost-optimize-your-Infrastructure-as-Code&sc_geo=mult&sc_country=mult&sc_outcome=acq) - A delete marker in Amazon S3 is a placeholder (or marker) for a versioned object that was requested to be deleted when a bucket has versioning-enabled. The object will not be deleted in this situation, but the delete marker makes Amazon S3 behave as if it is deleted. You can end up storing and paying for hundreds or thousands of previous versions that you thought were deleted.

* [Multi Part Uploads](https://aws.amazon.com/blogs/aws-cloud-financial-management/discovering-and-deleting-incomplete-multipart-uploads-to-lower-amazon-s3-costs/?sc_channel=el&sc_campaign=costwave&sc_content=5-ways-to-cost-optimize-your-Infrastructure-as-Code&sc_geo=mult&sc_country=mult&sc_outcome=acq) (MPUs) - Amazon S3’s multipart upload feature allows you to upload a single object to an S3 bucket as a set of parts.  If the complete multipart upload request isn’t sent successfully, Amazon S3 will not assemble the parts and will not create any object. The parts remain in your Amazon S3 account until the multipart upload completes or is aborted, and you pay for the parts that are stored in Amazon S3.

 This code snippets covers both of the overlooked objects and should be added to your code for Amazon S3 Buckets. Ensure to replace the `mybucket` with your unique bucket name.

```yaml
  S3Bucket:
    Type: 'AWS::S3::Bucket'
    Properties:
      BucketName:"mybucket"
      LifecycleConfiguration:
        Rules:
        - Id: delete-incomplete-mpu-7days
          Prefix: ''
          AbortIncompleteMultipartUpload:
            DaysAfterInitiation: 7
          ExpiredObjectDeleteMarker: True
```

 Check out [ExpiredObjectDeleteMarker](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-properties-s3-bucket-lifecycleconfig-rule.html#cfn-s3-bucket-rule-expiredobjectdeletemarker?sc_channel=el&sc_campaign=costwave&sc_content=5-ways-to-cost-optimize-your-Infrastructure-as-Code&sc_geo=mult&sc_country=mult&sc_outcome=acq)  in the Documentation

Adding the code above to every bucket you deploy will ensure you don’t waste money on storage you are not using. Use [Amazon S3 Lens](https://docs.aws.amazon.com/AmazonS3/latest/userguide/storage-lens-optimize-storage.html#:~:text=performance%20and%20cost.-,Locate,-incomplete%20multipart%20uploads?sc_channel=el&sc_campaign=costwave&sc_content=5-ways-to-cost-optimize-your-Infrastructure-as-Code&sc_geo=mult&sc_country=mult&sc_outcome=acq) enables you to identify these objects so you can add the code snippet and start saving.

## AWS Graviton for Managed Services

AWS Graviton processors are designed by AWS to deliver the best price performance for your cloud workloads. The processors are [available with these managed services](https://github.com/aws/aws-graviton-getting-started/blob/main/managed_services.md) and is a great way to get started with AWS Graviton, where you won’t need to recompile your code.  This change offers a range of price/performance improvements. Below is for AWS Lambda, add two lines to your code and it saves 10%.

This snippet shows the Architecture property you need to add to your AWS Lambda function to use an AWS Graviton processor.

```yaml
  LambdaFunctionResource:
    Type: AWS::Lambda::Function
    Properties:
      FunctionName: MyLambdaFunction
      Description: LambdaFunction of python3.10
      Runtime: python3.10
      Architectures:
           - "arm64"
```

Check out [AWS::Lambda::Function](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-lambda-function.html?sc_channel=el&sc_campaign=costwave&sc_content=5-ways-to-cost-optimize-your-Infrastructure-as-Code&sc_geo=mult&sc_country=mult&sc_outcome=acq) in the Documentation.

## gp3 for Volumes

Amazon Elastic Block Storage gp3 volumes arrived in 2020, and yet we still see customers using gp2 when they could be making a 20% cost saving by changing. Volumes under 1TB can be moved immediately over to gp3 without any downtime or performance impact. Volumes over 1TB should have their [IOPs requirements](https://aws.amazon.com/ebs/pricing/?sc_channel=el&sc_campaign=costwave&sc_content=5-ways-to-cost-optimize-your-Infrastructure-as-Code&sc_geo=mult&sc_country=mult&sc_outcome=acq) reviewed. You can find any volumes that would suit gp3 by using [this query](https://wellarchitectedlabs.com/cost/300_labs/300_cur_queries/queries/cost_optimization/#amazon-ebs-volumes-modernize-gp2-to-gp3) on you AWS Cost & Usage Report.

The below snippet shows the change in volume type to move your volume to gp3.

```yaml
 BlockDeviceMappings: 
  - DeviceName: "/dev/sdm"
    Ebs: 
      VolumeType: "gp3"
      DeleteOnTermination: "true" 
      VolumeSize: "10"
```

Even if you make this change after a volume has been deployed, you will have no down time.

Check out [AWS::EC2::Volume](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-ec2-volume.html?sc_channel=el&sc_campaign=costwave&sc_content=5-ways-to-cost-optimize-your-Infrastructure-as-Code&sc_geo=mult&sc_country=mult&sc_outcome=acq) in the Documentation.

## Amazon Elastic File System Intelligent-Tiering

Intelligent-Tiering uses Lifecycle Management to monitor the access patterns of your workload and automatically transition files that are not accessed.  Files will be moved from performance-optimized storage classes, to their corresponding cost-optimized Infrequent Access (IA) storage class. Take advantage of IA storage pricing that is up to [91% lower than EFS Standard](https://aws.amazon.com/efs/faq/#:~:text=With%20EFS%20Intelligent%2DTiering%2C%20you,not%20for%20repeated%20data%20access?sc_channel=el&sc_campaign=costwave&sc_content=5-ways-to-cost-optimize-your-Infrastructure-as-Code&sc_geo=mult&sc_country=mult&sc_outcome=acq).

This snippet shows the lifecycle policies to add to your EFS resource.

```yaml
  FileSystemResource:
    Type: 'AWS::EFS::FileSystem'
    Properties:
      LifecyclePolicies:
        - TransitionToIA: AFTER_30_DAYS
        - TransitionToPrimaryStorageClass: AFTER_1_ACCESS
```

Check out [AWS::EFS::FileSystem](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-efs-filesystem.html?sc_channel=el&sc_campaign=costwave&sc_content=5-ways-to-cost-optimize-your-Infrastructure-as-Code&sc_geo=mult&sc_country=mult&sc_outcome=acq) in the Documentation.

This code should be deployed for file systems that contain files that are not accessed every day to reduce your storage costs. Review any latency considerations in the [EFS FAQs](https://www.amazonaws.com/efs/faq/?sc_channel=el&sc_campaign=costwave&sc_content=5-ways-to-cost-optimize-your-Infrastructure-as-Code&sc_geo=mult&sc_country=mult&sc_outcome=acq).

## Conclusion

In this blog post, we looked at five code snippets that you can add to your Infrastructure as Code(IaC) to prevent cost waste.

If you are interested in how you can set up a CI/CD pipeline to deploy changes to your CloudFormation stacks, have a look at [this tutorial](/tutorials/build-ci-cd-pipeline-iac-cloudformation).
