# Module 4: Clean Up Your Resources
In this module, you will clean up the resources that you deployed in previous modules

**Time to complete** < 2 minutes

**Module prerequisites**
* AWS account with administrator-level access*
* Recommended browser: The latest version of Chrome or Firefox

    [*]Accounts created within the past 24 hours might not yet have access to the services required for this tutorial.

## Overview
In this last part of the tutorial, you will learn how to remove all the different AWS resources you created earlier. If your account is still on the Free Tier, this would not cost you anything, unless you have other Free Tier resources running already.

## What you will accomplish
In this module, you will:
* Remove AWS resources created with a CDK application

## Implementation
### Cleaning up your AWS environment
The benefit of using AWS CDK for all infrastructure is that cleaning up your AWS environment is easy. 
Run the following command in your terminal inside the CDK application directory:

```bash
cdk destroy
```
You can verify the `CdkPipelineStack` stack was deleted by going to the AWS CloudFormation Management Console.

However, please note this will only destroy resources created by cdk when we run the `cdk deploy` command. It will not destroy the 2 CloudFormation stacks that were deployed by the `Pre-Prod` stage. You have to delete the `Pre-Prod-WebService` manually from the CloudFormation Console or using following command : 
```bash
aws cloudformation delete-stack --stack-name Pre-Prod-WebService
```

If the stack delete fails with error  `Cannot delete entity, must detach all policies first.` Then delete the IAM role (name starts with _Pre-Prod-WebService-MyWebAppawselasticbeanstalkec2-randomstring_) and retry deleting the CloudFormation stack.

You can verify that all the infrastructure was removed by going to the AWS CloudFormation management console, and checking that the three stacks that were created in the previous modules are gone.


## Conclusion
Congratulations! You have finished the Deploy a Web App on AWS Elastic Beanstalk tutorial. Continue your journey with AWS by following the next steps section below.