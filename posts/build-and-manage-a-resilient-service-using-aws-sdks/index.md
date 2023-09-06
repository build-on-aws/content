---
title: "How to Build and Manage a Resilient Service Using Health Checks, Decoupled Dependencies, and Load Balancing using AWS SDKs"
description: "Did you know you can deploy and manage a load-balanced, resilient web service entirely with AWS SDKs?"
tags:
  - ec2
  - auto-scaling
  - load-balancing
  - resilience
  - sdk
  - python
  - aws
authorGithubAlias: Laren-AWS
authorName: Laren Crawford
date: 2023-09-01
---

| ToC |
| --- |

Are you a developer who wants to build and manage a resilient service? Have you worked through tutorials like [Health Checks and Dependencies](https://wellarchitectedlabs.com/reliability/300_labs/300_health_checks_and_dependencies/?sc_channel=el&sc_campaign=resiliencewave&sc_geo=mult&sc_country=mult&sc_outcome=acq&sc_content=build-and-manage-a-resilient-service-using-aws-sdks) and want to accomplish the same thing using code to build and manage your infrastructure? This article and code example show you how to use AWS SDKs to set up a resilient architecture that includes AWS services like Amazon EC2 Auto Scaling and Elastic Load Balancing (ELB). You’ll learn how to write code to monitor your service, manage health checks, and make real-time repairs to make your service more resilient. And you’ll do it all without ever opening the AWS Management Console.

This example is available now in the [AWS SDK Code Example Library](https://docs.aws.amazon.com/code-library/latest/ug/elastic-load-balancing-v2_example_cross_ResilientService_section.html?sc_channel=el&sc_campaign=resiliencewave&sc_geo=mult&sc_country=mult&sc_outcome=acq&sc_content=build-and-manage-a-resilient-service-using-aws-sdks).

### Just want to see the code?

The code for this example is part of a collection of code examples that show you how to use [AWS software development kits (SDKs)](https://aws.amazon.com/what-is/sdk/?sc_channel=el&sc_campaign=datamlwave&sc_geo=mult&sc_country=mult&sc_outcome=acq&sc_content=sagemaker-pipelines) with your development language of choice to work with AWS services and tools. You can download all of the examples, including this one, from the [AWS Code Examples GitHub repository](https://github.com/awsdocs/aws-doc-sdk-examples).

To see the code and follow along with this example, clone the repository and choose your preferred language from the list below. Each language link takes you to a README that includes setup instructions and prerequisites for that specific version.

* [Python](https://github.com/awsdocs/aws-doc-sdk-examples/tree/main/python/cross_service/resilient_service#readme)

## What are we building?  

A web service that returns recommendations of books, movies, and songs. This example takes a phased approach so you can see how the web service evolves as the system becomes more sophisticated in how it responds to various kinds of failures. All resources and components are deployed and managed with AWS SDK code, giving you insight on how to create your own system that can be built in a repeatable manner.

The example is an interactive scenario that you run at a command prompt. It starts by deploying all the resources you need, then moves to a demo phase where failures are simulated and resilient solutions are implemented. By the end of the demo phase, the service has become more resilient and presents a more consistent and positive user experience even when failures occur. Finally, all resources are deleted.

Building a resilient web service involves a number of interconnected parts. The main components use by this this demo are:

* [Amazon EC2 Auto Scaling](https://docs.aws.amazon.com/autoscaling/ec2/userguide/what-is-amazon-ec2-auto-scaling.html?sc_channel=el&sc_campaign=resiliencewave&sc_geo=mult&sc_country=mult&sc_outcome=acq&sc_content=build-and-manage-a-resilient-service-using-aws-sdks) is used to create [Amazon Elastic Compute Cloud (Amazon EC2)](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/concepts.html?sc_channel=el&sc_campaign=resiliencewave&sc_geo=mult&sc_country=mult&sc_outcome=acq&sc_content=build-and-manage-a-resilient-service-using-aws-sdks) instances based on a launch template. The Auto Scaling group ensures that the number of instances is kept in a specified range.
* [Elastic Load Balancing](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/introduction.html?sc_channel=el&sc_campaign=resiliencewave&sc_geo=mult&sc_country=mult&sc_outcome=acq&sc_content=build-and-manage-a-resilient-service-using-aws-sdks) handles HTTP requests, monitors the health of instances in the Auto Scaling group, and distributes requests to healthy instances.
* A Python web server runs on each instance to handle HTTP requests. It responds with recommendations and health checks and takes different actions depending on a set of [AWS Systems Manager](https://docs.aws.amazon.com/systems-manager/latest/userguide/what-is-systems-manager.html?sc_channel=el&sc_campaign=resiliencewave&sc_geo=mult&sc_country=mult&sc_outcome=acq&sc_content=build-and-manage-a-resilient-service-using-aws-sdks) parameters that simulate failures and demonstrate improved resiliency.
* An [Amazon DynamoDB](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/Introduction.html?sc_channel=el&sc_campaign=resiliencewave&sc_geo=mult&sc_country=mult&sc_outcome=acq&sc_content=build-and-manage-a-resilient-service-using-aws-sdks) table simulates a recommendation service that the web server depends on to get recommendations.

## Explore the interactive scenario

The interactive scenario has three main phases: deploy resources, demonstrate resiliency, and destroy resources.

**Note:** This example uses your default VPC and its default security group, which must allow inbound HTTP traffic on port 80 from your computer's IP address. If you prefer, you can create a custom VPC and modify the example code to use your custom VPC instead. Find out more in the [Amazon Virtual Private Cloud User Guide](https://docs.aws.amazon.com/vpc/latest/userguide/what-is-amazon-vpc.html?sc_channel=el&sc_campaign=resiliencewave&sc_geo=mult&sc_country=mult&sc_outcome=acq&sc_content=build-and-manage-a-resilient-service-using-aws-sdks). 

### Deploy resources

The first part of the example sets up basic web servers by deploying the first set of resources:

* The DynamoDB table that is used as a recommendation service. The table is populated with a few initial values.
* An AWS Identity and Access Management (IAM) policy, role, and instance profile that grants permission to each Amazon EC2 instance so that it can access the DynamoDB recommendations table and Systems Manager parameters.
* An Amazon EC2 launch template that specifies how instances are started. The launch template includes a startup Bash script that installs Python packages and starts a Python web server.
* An Auto Scaling group that is configured to ensure that you have three running instances in three Availability Zones.

After this deployment phase, you have three instances, each acting as a web server. Each instance listens for HTTP requests on port 80 and responds with recommendations from the DynamoDB table.

```bash
Creating and populating a DynamoDB table named 'doc-example-recommendation-service'.
INFO: Creating table doc-example-recommendation-service...
INFO: Table doc-example-recommendation-service created.
INFO: Populated table doc-example-recommendation-service with items from ../../../workflows/resilient_service/resources/recommendations.json.
----------------------------------------------------------------------------------------
Creating an EC2 launch template that runs '../../../workflows/resilient_service/resources/server_startup_script.sh' when an instance starts.
This script starts a Python web server defined in the `server.py` script. The web server
listens to HTTP requests on port 80 and responds to requests to '/' and to '/healthcheck'.
For demo purposes, this server is run as the root user. In production, the best practice is to
run a web server, such as Apache, with least-privileged credentials.

The template also defines an IAM policy that each instance uses to assume a role that grants
permissions to access the DynamoDB recommendation table and Systems Manager parameters
that control the flow of the demo.
INFO: Created policy with ARN arn:aws:iam::123456789012:policy/doc-example-resilience-pol.
INFO: Created role doc-example-resilience-role and attached policy arn:aws:iam::123456789012:policy/doc-example-resilience-pol.
INFO: Created profile doc-example-resilience-prof and added role doc-example-resilience-role.
INFO: Created launch template doc-example-resilience-template for AMI ami-04288abc8d2000768 on t3.micro.
----------------------------------------------------------------------------------------
Creating an EC2 Auto Scaling group that maintains three EC2 instances, each in a different
Availability Zone.
INFO: Created EC2 Auto Scaling group doc-example-resilience-template with availability zones ['us-west-2a', 'us-west-2b', 'us-west-2c', 'us-west-2d'].
----------------------------------------------------------------------------------------
At this point, you have EC2 instances created. Once each instance starts, it listens for
HTTP requests. You can see these instances in the console or continue with the demo.
----------------------------------------------------------------------------------------
```

The next phase of the example sets up a load-balanced endpoint by deploying the following resources:

* An ELB target group that is attached to the Auto Scaling group. The target group forwards HTTP requests to instances in the Auto Scaling group on port 80, and is configured to verify the health of instances. To speed up this demo, the health check is configured with shortened times and lower thresholds. In production, you might want to decrease the sensitivity of your health checks to avoid unwanted failures.
* An Application Load Balancer that provides a single endpoint for your users, and a listener that the load balancer uses to distribute requests to the underlying instances.

After this part of the deployment, you have a single endpoint that receives HTTP requests and distributes them to the underlying web servers to get recommendations and health checks.

```bash
Creating an Elastic Load Balancing target group and load balancer. The target group
defines how the load balancer connects to instances. The load balancer provides a
single endpoint where clients connect and dispatches requests to instances in the group.

INFO: Found 4 subnets for the specified zones.
INFO: Created load balancing target group doc-example-resilience-tg.
INFO: Created load balancer doc-example-resilience-lb.
INFO: Waiting for load balancer to be available...
INFO: Load balancer is available!
INFO: Created listener to forward traffic from load balancer doc-example-resilience-lb to target group doc-example-resilience-tg.
INFO: Attached load balancer target group doc-example-resilience-tg to auto scaling group doc-example-resilience-group.
Your load balancer is ready. You can access it by browsing to:

        http://doc-example-resilience-lb-1317068782.us-west-2.elb.amazonaws.com

----------------------------------------------------------------------------------------
```  

### Demonstrate resiliency

This part of the examples toggles different parts of the system by setting Systems Manager parameters that are used by the Python web server to take different actions depending on the parameter values. This creates situations where the web service fails, and shows how using a resilient architecture can keep  the web service running in spite of these failures and improve your customers' experience.

After each update, the demo gives you a chance to send GET requests to the endpoint or to check the health of the instances. Each GET request responds with a recommendation from the DynamoDB table and also includes the instance ID and its Availability Zone so that you can see how the load balancer distributes requests.

The selection screen looks like this:

```bash
----------------------------------------------------------------------------------------

See the current state of the service by selecting one of the following choices:

1. Send a GET request to the load balancer endpoint.
2. Check the health of load balancer targets.
3. Go to the next part of the demo.

Which action would you like to take? 
----------------------------------------------------------------------------------------
```

#### Initial state

At the beginning, the recommendation service successfully responds and all instances are healthy.

```bash
----------------------------------------------------------------------------------------
Request:

GET http://doc-example-resilience-lb-1317068782.us-west-2.elb.amazonaws.com

Response:

200
{'Title': {'S': 'Pride and Prejudice'},
 'Creator': {'S': 'Jane Austen'},
 'MediaType': {'S': 'Book'},
 'ItemId': {'N': '1'},
 'Metadata': {'InstanceId': 'i-05387127cb2ebbea1',
              'AvailabilityZone': 'us-west-2c'}}
----------------------------------------------------------------------------------------
```

```bash
----------------------------------------------------------------------------------------

Checking the health of load balancer targets:

        Target i-02d98d9d0726c4b2d on port 80 is healthy
        Target i-0e4b7104cfaf8e056 on port 80 is healthy
        Target i-05387127cb2ebbea1 on port 80 is healthy
----------------------------------------------------------------------------------------
```

#### Broken dependency

The next phase simulates a broken dependency by setting the table name parameter to a non-existent table name. When the web server tries to get a recommendation, it fails because the table doesn't exist.

```bash
----------------------------------------------------------------------------------------
Request:

GET http://doc-example-resilience-lb-1317068782.us-west-2.elb.amazonaws.com

Response:

502
----------------------------------------------------------------------------------------
```

However, all instances report as healthy because they use shallow health checks, which means that they simply report success under all conditions.

#### Static response

The next phase sets a parameter that instructs the web server to return a static response when it cannot get a recommendation from the recommendation service. This technique lets you decouple your web server response from the failing dependency and return a successful response to your users instead of reporting a failure. The static response is to always suggest the *404 Not Found* coloring book.

```bash
Request:

GET http://doc-example-resilience-lb-1317068782.us-west-2.elb.amazonaws.com

Response:

200
{'MediaType': {'S': 'Book'},
 'ItemId': {'N': '0'},
 'Title': {'S': '404 Not Found: A Coloring Book'},
 'Creator': {'S': 'The Oatmeal'},
 'Metadata': {'InstanceId': 'i-05387127cb2ebbea1',
              'AvailabilityZone': 'us-west-2c'}}
----------------------------------------------------------------------------------------
```

#### Bad credentials

The next phase replaces the credentials on a single instance with credentials that don't allow access to the recommendation service. Now, repeated requests sometimes get a good response and sometimes get the static response, depending on which instance is selected by the load balancer.

For example, the instance on us-west-2a gives real recommendations:

```bash
----------------------------------------------------------------------------------------
Request:

GET http://doc-example-resilience-lb-1317068782.us-west-2.elb.amazonaws.com

Response:

200
{'Title': {'S': 'Delicatessen'},
 'Creator': {'S': 'Jeunet et Caro'},
 'MediaType': {'S': 'Movie'},
 'ItemId': {'N': '1'},
 'Metadata': {'InstanceId': 'i-02d98d9d0726c4b2d',
              'AvailabilityZone': 'us-west-2a'}}
----------------------------------------------------------------------------------------
```

While the instance on us-west-2b gives a static response:

```bash
----------------------------------------------------------------------------------------
Request:

GET http://doc-example-resilience-lb-1317068782.us-west-2.elb.amazonaws.com

Response:

200
{'MediaType': {'S': 'Book'},
 'ItemId': {'N': '0'},
 'Title': {'S': '404 Not Found: A Coloring Book'},
 'Creator': {'S': 'The Oatmeal'},
 'Metadata': {'InstanceId': 'i-0e4b7104cfaf8e056',
              'AvailabilityZone': 'us-west-2b'}}
----------------------------------------------------------------------------------------
```

#### Deep health checks

The next phase sets a parameter that instructs the web server to use a deep health check. This means that the web server returns an error code when it can't connect to the recommendations service. Remember, it takes a minute or two for the load balancer to detect an unhealthy instance because of the threshold configuration, so if you check health right away, the instance might report as healthy.

Note that the deep health check is only for ELB routing and not for Auto Scaling instance health. This kind of deep health check is not recommended for Auto Scaling instance health, because it risks accidental termination of all instances in the Auto Scaling group when a dependent service fails. For a detailed explanation of health checks and their tradeoffs, including use of the heartbeat table pattern to automatically detect and replace failing instances, see [Choosing the right health check with Elastic Load Balancing and EC2 Auto Scaling](https://aws.amazon.com/blogs/networking-and-content-delivery/choosing-the-right-health-check-with-elastic-load-balancing-and-ec2-auto-scaling/).  

The instance with bad credentials reports as unhealthy:

```bash
----------------------------------------------------------------------------------------

Checking the health of load balancer targets:

        Target i-02d98d9d0726c4b2d on port 80 is healthy
        Target i-0e4b7104cfaf8e056 on port 80 is unhealthy
                Target.ResponseCodeMismatch: Health checks failed with these codes: [503]

        Target i-05387127cb2ebbea1 on port 80 is healthy

----------------------------------------------------------------------------------------
```

The load balancer takes unhealthy instances out of its rotation, so now all requests to the endpoint result in good recommendations.

#### Replace the failing instance

This next phase uses an SDK action to terminate the unhealthy instance, at which point Auto Scaling automatically start a new instance. While the old instance is shutting down and the new instance is starting, GET requests to the endpoint continue to return recommendations because the load balancer dispatches requests only to the healthy instances.

While the instances are transitioning, you will see various results from the health check, for example:

```bash
----------------------------------------------------------------------------------------

Checking the health of load balancer targets:

        Target i-02d98d9d0726c4b2d on port 80 is healthy
        Target i-05387127cb2ebbea1 on port 80 is healthy
        Target i-0e4b7104cfaf8e056 on port 80 is draining
                Target.DeregistrationInProgress: Target deregistration is in progress

        Target i-0c8df865e77bbb943 on port 80 is unhealthy
                Target.FailedHealthChecks: Health checks failed

----------------------------------------------------------------------------------------
```

After the new instance starts, it reports as healthy and is again included in the load balancer's rotation.

#### Fail open

This last phase of the example again sets the table name parameter to a non-existent table to simulate a failure of the recommendation service. This causes all instances to report as unhealthy.

```bash
----------------------------------------------------------------------------------------

Checking the health of load balancer targets:

        Target i-02d98d9d0726c4b2d on port 80 is unhealthy
                Target.ResponseCodeMismatch: Health checks failed with these codes: [503]

        Target i-05387127cb2ebbea1 on port 80 is unhealthy
                Target.ResponseCodeMismatch: Health checks failed with these codes: [503]

        Target i-0c8df865e77bbb943 on port 80 is unhealthy
                Target.ResponseCodeMismatch: Health checks failed with these codes: [503]

----------------------------------------------------------------------------------------
```

When all instances in a target group are unhealthy, the load balancer continues to forward requests to them, allowing for a fail open behavior. In this case, because the web server returns a static response, users get a static response instead of a failure code.

```bash
----------------------------------------------------------------------------------------
Request:

GET http://doc-example-resilience-lb-1317068782.us-west-2.elb.amazonaws.com

Response:

200
{'MediaType': {'S': 'Book'},
 'ItemId': {'N': '0'},
 'Title': {'S': '404 Not Found: A Coloring Book'},
 'Creator': {'S': 'The Oatmeal'},
 'Metadata': {'InstanceId': 'i-02d98d9d0726c4b2d',
              'AvailabilityZone': 'us-west-2a'}}
----------------------------------------------------------------------------------------
```

#### Destroy resources

After you're done exploring the resiliency features of the example, you can keep or destroy all the resources that it created. Typically, it's a good practice to destroy the resources, to avoid unwanted charges on your account.

If you answer 'yes', the example deletes all resources and terminates all instances:

```bash
----------------------------------------------------------------------------------------
This concludes the demo of how to build and manage a resilient service.
To keep things tidy and to avoid unwanted charges on your account, we can clean up all AWS resources
that were created for this demo.
Do you want to clean up all demo resources? (y/n) y
INFO: Deleted load balancer doc-example-resilience-lb.
INFO: Waiting for load balancer to be deleted...
INFO: Target group not yet released from load balancer, waiting...
INFO: Deleted load balancing target group doc-example-resilience-tg.
INFO: Stopping i-02d98d9d0726c4b2d.
INFO: Stopping i-05387127cb2ebbea1.
INFO: Stopping i-0c8df865e77bbb943.
INFO: Some instances are still running. Waiting for them to stop...
INFO: Some instances are still running. Waiting for them to stop...
INFO: Some instances are still running. Waiting for them to stop...
INFO: Some instances are still running. Waiting for them to stop...
INFO: Some instances are still running. Waiting for them to stop...
INFO: Some instances are still running. Waiting for them to stop...
INFO: Some instances are still running. Waiting for them to stop...
INFO: Deleted EC2 Auto Scaling group doc-example-resilience-group.
INFO: Deleted instance profile doc-example-resilience-prof.
INFO: Detached and deleted policy doc-example-resilience-pol.
INFO: Deleted role doc-example-resilience-role.
INFO: Launch template doc-example-resilience-template deleted.
INFO: Deleted instance profile doc-example-resilience-bc-prof.
INFO: Detached and deleted policy doc-example-resilience-bc-pol.
INFO: Detached and deleted policy AmazonSSMManagedInstanceCore.
INFO: Deleted role doc-example-resilience-bc-role.
INFO: Deleting table doc-example-recommendation-service...
INFO: Table doc-example-recommendation-service deleted.
----------------------------------------------------------------------------------------
```

## Resiliency and you

Congratulations, you've made it to the end! By following this example, you've learned how to use AWS SDKs to deploy all the resources to build a resilient web service.

* You used a load balancer to let your users target a single endpoint that automatically distributed traffic to web servers running in your target group.
* You used an Auto Scaling group so you could remove unhealthy instances and automatically keep the number of instances within a specified range.
* You decoupled your web server from its dependencies and returned a successful static response even when the underlying service failed.
* You implemented deep health checks to report unhealthy instances to the load balancer so that it dispatched requests only to instances that responded successfully.
* You used a load balancer to let the system fail open when something unexpected went wrong. Your users got a successful static response, buying you time to investigate the root cause and get the system running again.

You can find more details about this example, and the complete code, in the [AWS Code Examples GitHub repository](https://github.com/awsdocs/aws-doc-sdk-examples/tree/main/python/cross_service/resilient_service#readme).

You can explore more AWS code examples in the [Code Library](https://docs.aws.amazon.com/code-library/latest/ug/what-is-code-library.html?sc_channel=el&sc_campaign=resiliencewave&sc_geo=mult&sc_country=mult&sc_outcome=acq&sc_content=build-and-manage-a-resilient-service-using-aws-sdks).

Now go build your own!
