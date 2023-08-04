---
title: Combine AWS Batch & Step Functions to create a video processing workflow
description: Want to learn how to build a video transcoding workflow using AWS Step Functions and AWS Batch in 10 minutes? Learn how to create a serverless workflow that performs video transcoding using AWS Step Functions and AWS Batch in 10 minutes.
tags:
    - video processing
    - batch
    - step functions
    - workflow
    - tutorials
    - aws
showInHomeFeed: true
authorGithubAlias: cobusbernard
authorName: Cobus Bernard
date: 2023-07-26
---

Cloud-based video hosting services regularly perform video transcoding and feature extraction on videos uploaded to the cloud. Video processing pipelines often require an elaborate workflow that manages multiple parallel compute jobs and handles exceptions.

In this tutorial, you will create an AWS Step Functions workflow that simulates processing videos that have been uploaded to the cloud. The workflow will process videos by submitting jobs to multi-priority queues on the Amazon Batch service.

The Step Functions workflow will be used to specify dependencies and sequence jobs that are submitted to AWS Batch. In AWS Batch, the user can define the compute environment, queues, and queue priorities. Step Functions workflows can be used to specify how exceptions are handled in the workflow.

*Note: No actual processing will be performed by the workflow. This tutorial is designed to work within the AWS free tier and allow you to experiment with AWS Step Functions and AWS Batch. It is important to follow the tutorial recommendations when configuring the compute environment and to delete all resources after the tutorial is complete to avoid incurring additional costs.*

Here is an example of the AWS Step Functions workflow: 

![AWS Step Functions workflow](./images/6.00.png)

You will learn how to create an AWS Step Functions workflow to simulate video processing, and how to use the AWS Batch service. With AWS Batch, you can define the compute environment, queues, and queue priorities.


## Table of Contents

| Attributes                |                                   |
| ------------------- | -------------------------------------- |
| ✅ AWS Level        | 100 - Beginner                          |
| ⏱ Time to complete  | 10 minutes                             |
| 💰 Cost to complete | Free     |
| 🧩 Prerequisites    | [AWS Account](https://aws.amazon.com/resources/create-account/?sc_channel=el&sc_campaign=devopswave&sc_content=cicdcdkpthnec2aws&sc_geo=mult&sc_country=mult&sc_outcome=acq)                         |
| 📢 Feedback            | <a href="https://pulse.buildon.aws/survey/DEM0H5VW" target="_blank">Any feedback, issues, or just a</a> 👍 / 👎 ?    |
| ⏰ Last Updated     | YYYY-MM-DD                             |


| ToC |
|-----|


## Setting up AWS Batch

First, open a browser and navigate to the [AWS Batch console](https://console.aws.amazon.com/batch/home). If you already have an AWS account, login to the console. Otherwise, create a new AWS account to get started.

The next step is to set up an AWS Batch compute environment. The compute environment specifies the minimum desired and maximum number of CPUs available to run your batch jobs.

First, select `compute environments` from the left-hand panel. You will leave most elements in their default setting and only change a few items:

![Navigate to compute environments](./images/6.01.png)

Now choose `create` as in the following:

![Create compute environment](./images/6.02.png)

Select `Amazon Elastic Compute Cloud (Amazon EC2)` and confirm the change platform in the confirmation message:

![Select Amazon Elastic Compute Cloud (Amazon EC2)](./images/6.03.png)

![Confirm change platform](./images/6.03b.png)

After, insert the `compute environment name` as *StepsBatchTutorial_ComputeEnv* then press `Next`:

![Add name](./images/6.03c.png)

For your compute resources, set the `minimum vCPUs` to `0`, the `desired vCPUs` to `2` and the `maximum vCPUs` to `4`.

You can limit the CPU resources to keep costs down for the purpose of this tutorial. Setting `minimum vCPUs` to `0` will ensure that CPU time is not wasted when there are no active jobs submitted to the queue. The penalty for setting vCPUS to `0` is that when jobs are submitted, if there are inactive vCPUs, there will be a cold start latency when vCPUs are allocated and booted up.

Now, press `Next`: 

![Set vCPU limits](./images/6.04.png)

In `Network configuration`, leave the default configuration as-is and press `Next`:

![Create environment](./images/6.05.png)

Select`create compute environments`. Now you will see the environment created. Once the compute environment creation is complete, the provisioning model will read `EC2`, `Status` will read `VALID`, and the `State` will read `ENABLED`. This may take a few minutes. After, press the refresh icon to refresh the status:

![Create environment](./images/6.06.png)

![See the environment created](./images/6.07.png)

Next, you willcreate two AWS Batch queues with differing priorities.

Begin by choosing `job queues` from the left-hand panel and choose `Create`:

![Navigate to job queues](./images/6.08.png)

Then, select `Amazon Elastic Compute Cloud (Amazon EC2)`.

Enter the `queue name` as *StepsBatchTutorial_HighPriorityQueue*and the `priority` as `10`. Job queues with a higher integer value are given priority for compute resources.

Select the compute environment *StepsBatchTutorial_ComputeEnv* from the drop-down box:

![Select Amazon Elastic Compute Cloud (Amazon EC2)](./images/6.09.png)

Next, press `create job queue`:

![Create high priority queue](./images/6.10.png)

Your queue is created. Now you will create a second queue with a low priority. Repeat the previous steps and enter the `queue name` as *StepsBatchTutorial_LowPriorityQueue*.

Enter the `priority` as `1` and select the compute environment *StepsBatchTutorial_ComputeEnv* from the drop-down box. Press`create job queue`and the two queues are now created:

![Two queues created](./images/6.11.png)

Next, you will set up a job definition to create a series of empty jobs that can be executed as part of a batch job.

Select `job definitions` from the left-hand panel:

![Navigate to job definitions](./images/6.12.png)

After, press `create`:

*Note: For the purpose of this tutorial, we will be using an Amazon Linux container to help illustrate the workflow steps. The container will not perform any real work. When creating a batch environment for your target use-case, you will need to provide a container that can do the processing you require. For more details, refer to [creating a job definition](https://docs.aws.amazon.com/batch/latest/userguide/create-job-definition.html) in the AWS Batch users guide.*

![Create job definition](./images/6.13.png)

Select `Amazon Elastic Compute Cloud (Amazon EC2)` and confirm changing the platform:

![Select Amazon Elastic Compute Cloud (Amazon EC2)](./images/6.14.png)

![Select Amazon Elastic Compute Cloud (Amazon EC2)](./images/6.14b.png)

Enter the `job name` as *StepsBatchTutorial_TranscodeVideo* and then press `Next`:

![Create job definition name](./images/6.15.png)

Now insert the `container` image as *public.ecr.aws/docker/library/amazonlinux:latest* and set the `Bash` command syntax to *echo performing video transcoding job*:

![Set Job definition name and echo ](./images/6.16.png)

Set the `vCPUs` to `2` and the `memory (MiB)` to `1024`:

![Set vCPUs and memory ](./images/6.17.png)

For `linux and logging settings` you can leave the default configuration and choose `Next`:

![Additional configuration](./images/6.18.png)

For `Job definition review`, review the data and select `Create Job Definition`:

![Create job definition](./images/6.19.png)

Repeat these steps and create two more jobs.

For the second job, set the `job name` to *StepsBatchTutorial_ExtractFeatures* and set the `command` to *echo performing video feature extraction*.

For the third job, set the `job name` to *StepsBatchTutorial_ExtractMetadata* and set the `command` to *echo extracting metadata from video*:

![Repeat steps for second and third job](./images/6.20.png)

Now that you’ve set everything up with AWS Batch, next you will create a workflow with a state machine. 


## Creating a workflow with a State Machine

In this step, you will create a State Machine that controls your workflow and call AWS Batch. Workflows describe a process as a series of discrete tasks that can be repeated. You will design your workflow in AWS Step Functions. AWS Step Functions uses state machines to create a workflow. The state machines are coded in [Amazon States Language (ASL)](https://states-language.net/spec.html) in a JSON format.

Open the [AWS Step Functions console](https://console.aws.amazon.com/states/home#/statemachines/create) to create a State Machine. Select `write your workflow in code`:

![Define State Machine](./images/6.21.png)

Replace the contents of the State Machine definition window with the following [Amazon States Language (ASL)](https://states-language.net/spec.html) State Machine definition. Amazon States Language is a JSON-based, structured language used to define your state machine.

This State Machine represents a workflow that performs video processing using a batch. Most of the steps are task states that execute AWS Batch jobs. Task states can also be used to call other AWS services such as Lambda for serverless compute, or SNS to send messages that distribute to other services:

```json
{
  "StartAt": "Extract Metadata",
  "States": {
    "Extract Metadata": {
      "Type": "Task",
      "Resource": "arn:aws:states:::batch:submitJob.sync",
      "Parameters": {
        "JobDefinition": "arn:aws:batch:REGION:112233445566:job-definition/StepsBatchTutorial_ExtractMetadata:1",
        "JobName": "SplitVideo",
        "JobQueue": "arn:aws:batch:REGION:112233445566:job-queue/StepsBatchTutorial_HighPriorityQueue"
      },
      "Next": "Process Video"
    },
    "Process Video": {
      "Type": "Parallel",
      "End": true,
      "Branches": [
        {
          "StartAt": "Extract Features",
          "States": {
            "Extract Features": {
              "Type": "Task",
              "Resource": "arn:aws:states:::batch:submitJob.sync",
              "Parameters": {
                "JobDefinition": "arn:aws:batch:REGION:112233445566:job-definition/StepsBatchTutorial_ExtractFeatures:1",
                "JobName": "ExtractFeatures",
                "JobQueue": "arn:aws:batch:REGION:112233445566:job-queue/StepsBatchTutorial_LowPriorityQueue"
              },
              "End": true
            }
          }
        },
        {
          "StartAt": "Transcode Video",
          "States": {
            "Transcode Video": {
              "Type": "Parallel",
              "End": true,
              "Branches": [
                {
                  "StartAt": "Transcode_4k-1",
                  "States": {
                    "Transcode_4k-1": {
                      "Type": "Task",
                      "Resource": "arn:aws:states:::batch:submitJob.sync",
                      "Parameters": {
                        "JobDefinition": "arn:aws:batch:REGION:112233445566:job-definition/StepsBatchTutorial_TranscodeVideo:1",
                        "JobName": "Transcode_4k-1",
                        "JobQueue": "arn:aws:batch:REGION:112233445566:job-queue/StepsBatchTutorial_HighPriorityQueue"
                      },
                      "Next": "Transcode_4k-2"
                    },
                    "Transcode_4k-2": {
                      "Type": "Task",
                      "Resource": "arn:aws:states:::batch:submitJob.sync",
                      "Parameters": {
                        "JobDefinition": "arn:aws:batch:REGION:112233445566:job-definition/StepsBatchTutorial_TranscodeVideo:1",
                        "JobName": "Transcode_4k-2",
                        "JobQueue": "arn:aws:batch:REGION:112233445566:job-queue/StepsBatchTutorial_LowPriorityQueue"
                      },
                      "End": true
                    }
                  }
                },
                {
                  "StartAt": "Transcode_1080p-1",
                  "States": {
                    "Transcode_1080p-1": {
                      "Type": "Task",
                      "Resource": "arn:aws:states:::batch:submitJob.sync",
                      "Parameters": {
                        "JobDefinition": "arn:aws:batch:REGION:112233445566:job-definition/StepsBatchTutorial_TranscodeVideo:1",
                        "JobName": "Transcode_1080p-1",
                        "JobQueue": "arn:aws:batch:REGION:112233445566:job-queue/StepsBatchTutorial_HighPriorityQueue"
                      },
                      "Next": "Transcode_1080p-2"
                    },
                    "Transcode_1080p-2": {
                      "Type": "Task",
                      "Resource": "arn:aws:states:::batch:submitJob.sync",
                      "Parameters": {
                        "JobDefinition": "arn:aws:batch:REGION:112233445566:job-definition/StepsBatchTutorial_TranscodeVideo:1",
                        "JobName": "Transcode_1080p-2",
                        "JobQueue": "arn:aws:batch:REGION:112233445566:job-queue/StepsBatchTutorial_LowPriorityQueue"
                      },
                      "End": true
                    }
                  }
                },
                {
                  "StartAt": "Transcode_720p-1",
                  "States": {
                    "Transcode_720p-1": {
                      "Type": "Task",
                      "Resource": "arn:aws:states:::batch:submitJob.sync",
                      "Parameters": {
                        "JobDefinition": "arn:aws:batch:REGION:112233445566:job-definition/StepsBatchTutorial_TranscodeVideo:1",
                        "JobName": "Transcode_720p-1",
                        "JobQueue": "arn:aws:batch:REGION:112233445566:job-queue/StepsBatchTutorial_HighPriorityQueue"
                      },
                      "Next": "Transcode_720p-2"
                    },
                    "Transcode_720p-2": {
                      "Type": "Task",
                      "Resource": "arn:aws:states:::batch:submitJob.sync",
                      "Parameters": {
                        "JobDefinition": "arn:aws:batch:REGION:112233445566:job-definition/StepsBatchTutorial_TranscodeVideo:1",
                        "JobName": "Transcode_720p-2",
                        "JobQueue": "arn:aws:batch:REGION:112233445566:job-queue/StepsBatchTutorial_LowPriorityQueue"
                      },
                      "End": true
                    }
                  }
                },
                {
                  "StartAt": "Transcode_480p-1",
                  "States": {
                    "Transcode_480p-1": {
                      "Type": "Task",
                      "Resource": "arn:aws:states:::batch:submitJob.sync",
                      "Parameters": {
                        "JobDefinition": "arn:aws:batch:REGION:112233445566:job-definition/StepsBatchTutorial_TranscodeVideo:1",
                        "JobName": "Transcode_480p-1",
                        "JobQueue": "arn:aws:batch:REGION:112233445566:job-queue/StepsBatchTutorial_HighPriorityQueue"
                      },
                      "Next": "Transcode_480p-2"
                    },
                    "Transcode_480p-2": {
                      "Type": "Task",
                      "Resource": "arn:aws:states:::batch:submitJob.sync",
                      "Parameters": {
                        "JobDefinition": "arn:aws:batch:REGION:112233445566:job-definition/StepsBatchTutorial_TranscodeVideo:1",
                        "JobName": "Transcode_480p-2",
                        "JobQueue": "arn:aws:batch:REGION:112233445566:job-queue/StepsBatchTutorial_LowPriorityQueue"
                      },
                      "End": true
                    }
                  }
                }
              ]
            }
          }
        }
      ]
    }
  }
}
```

![Replace state machine definition](./images/6.22.png)

For each Batch task state, the ARN will need to be updated to match your region and account.The Batch task state has three fields:

- The first is the reference to the job name that will be executed.
- The second is the name that will be assigned for the job.
- The third is the queue where the job will be assigned.

For each Batch Task, replace the following contents:
   
- Insert the region you’re working in for the empty `REGION` field, such as `us-east-1`.
- Insert your AWS account number where the account number values are `112233445566`.

*Note: It’s faster to use a text editor or IDE such as VSCode to do a search and replace. Ensure that all 20 account references in the ARNs are replaced.*

Once you’ve replace these content, press `next`:

![Update region and account number](./images/6.23.png)

In the name text box, name your State Machine *StepsBatchTutorial_VideoWorkflow* and add an IAM role to your workflow. Select `create new role` and name it *StepsBatchTutorial_Role*. Step Functions will analyze your workflow and generate an IAM policy that includes resources used by your workflow.

Select `create state machine` and there should be a green banner indicating your state machine was successfully created:

![Configure name and IAM role](./images/6.24.png)

Now press `create state machine`:

![Create state machine](./images/6.25.png)

Your next step is to exercise the step function workflow that you have built. You will trigger the start of the execution manually. A JSON can be specified to provide input to the Step Functions. Step Functions can also be triggered by a Lambda function or a CloudWatch event.

Begin by selecting `start execution`:

![Select start execution](./images/6.26.png)

In the new execution window, leave the JSON untouched as no input is needed. Then press `start execution`:

![Start execution](./images/6.27.png)

The workflow will begin to execute and jobs are sent to Batch. As the workflow is being executed synchronously, the workflow will wait for each Batch job to complete before moving to the next step:

![Execution running](./images/6.28.png)

Scroll toward the end of the page and there will be the visual workflow. Press the `Transcode_1080p-1` step and view the step details on the right-hand of the page:

![View workflow details](./images/6.29.png)

At the end of the page, view the execution event history. Select `ID 6`,this is where the task has been completed for the first batch job that was submitted.

The step function will pause on the extract metadata state until the batch task completes:

![View execution event history](./images/6.30.png)

You can also view details on the execution of your Batch jobs. Navigate to the Batch service and select `dashboard` from the right-hand column. Your jobs statuses are listed under Job Queues. Press the `refresh` button to view the progression of jobs through your queues.

From the Step Functions console, re-run your state machine multiple times and watch the performance of the batch jobs and queues, alternating between the Step Functions and Batch consoles.

To view details on executed batch jobs, press on one of the job queue numbers under `succeeded`:

![View progression of jobs](./images/6.31.png)

Select one of the `Job IDs` from the list to view more details:

![View job details](./images/6.32.png)

You can view detailed information on the job including start time, completion time, job queue, and the container used.

Scroll to the end of the page and view the CloudWatch Logs.

In CloudWatch Logs, you can view the execution history of the jobs. Notice how the echo statement that you entered for the job has been captured in the log:

![View job execution history](./images/6.33.png)


### Optional workflows

Now is your opportunity to experiment more with the state machine. Return to Step Functions console and edit your state machine code.
Try changing queue priorities and re-executing the state machine:

![Edit your state machine code](./images/6.34.png)

For your second job, replace the `JobDefinition` for `Transcode_4k-1` with *arn:aws:batch:us-west-2:134029540168:job-definition/StepsBatchTutorial_TranscodeVideo_DOES_NOT_EXIST:1*.

Re-execute the state machine and notice how if one parallel batch job fails, then all other parallel jobs will be canceled. In case of  failure, all batch jobs will be removed from the queue.

Introduce failure handling into the state machine. The task state retry field can be used to retry a job more than once. The catch statement can be introduced to perform error handling. For more information, refer to [Amazon States Language error handling](https://docs.aws.amazon.com/step-functions/latest/dg/amazon-states-language-errors.html):

![Replace job definition for transcode 4k-1](./images/6.35.png)

In the next step, you will learn how to properly terminate your resources to avoid incurring additional costs to your account.


## Terminating your resources

In this step, you will terminate your AWS Step Functions and AWS Batch related resources. It’s important to note that terminating resources that are not actively being used reduces costs and is a best practice. Not terminating your resources can result in a charge.

First,delete your step function. Choose services in the AWS Management Console menu, then select `Step Functions`.

In the state machines window, press on the state machine *StepsBatchTutorial_VideoWorkflow* and select `delete`. Confirm the action by selecting `delete state machine` in the dialog box. Your state machine will be deleted in a minute or two once Step Functions has confirmed that any in-process executions have been completed:

![Delete your step function and state machine](./images/6.36.png)

Next, delete your Batch Queues and Compute Environment. Choose `services` in the AWS Management Console menu, then `Batch`. Select `job definitions` from the right-hand side menu.

For each job definition, press on the `job definition name`, select the radial box next to `Revision 1`, and select `actions`, then`deregister`. Your job will be deregistered. You can do this for each of your jobs:

![Delete batch queues and compute environment](./images/6.37.png)

Next, delete your job queues. Select `job queues` from the right-hand menu:

Select the radial box next to the *StepsBatchTutorial_HighPriority* queue and choose`disable`. Once the queue is disabled, re-select the queue and select `delete`:

Repeat this for the *StepsBatchTutorial_LowPriority* queue as well. It may take a minute to finish deleting all your queues:

![Delete job queues](./images/6.38.png)

Now, delete your compute environments. Select `compute environments` from the right-hand menu.

Select the radial box next to the *StepsBatchTutorial_Compute* compute environment queue and choose `disable`. Once the compute environment is disabled, re-select the compute environment and press `delete`. You cannot delete the compute environment until the job queues have finished deleting:

![Delete compute environments](./images/6.39.png)

Lastly, delete your IAM roles. Select `services` in the AWS Management Console menu, then choose `IAM`.

Select `roles` from the right-hand menu and enter *StepsBatchTutorial*.Select the IAM roles that you created for this tutorial, and then click `delete role`. Confirm the deletion by pressing `yes, delete` on the dialog box:

![Delete IAM role](./images/6.40.png)

Your resources have now been successfully terminated. 


## Conclusion

You have now orchestrated a trial video transcoding workflow using AWS Step Functions and AWS Batch. Step Functions is a great fit when you need to conduct complex batch jobs, handle errors, and job failures.
