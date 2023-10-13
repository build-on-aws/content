---
title: Building Rust Applications For AWS Graviton
description: Learn how to migrate a Rust application from x86 based Amazon EC2 Instances to ARM64-based Graviton EC2 Instances in order to achieve both higher application sustainability and lower costs
tags:
  - tutorials
  - graviton
  - rust
  - sustainability
  - cost-optimization
  - deploy
  - migrate
  - arm64
  - ec2
spaces:
  - cost-optimization
waves:
  - cost
authorGithubAlias: DDxPlague
authorName: Tyler Jones
date: 2023-07-20
---

Companies today are making sustainability a key goal for their business in order to improve operational efficiency and drive down cost while also lowering carbon emissions. Achieving these sustainability goals means change across all levels of the business, with application and software development being a key focus. With Rust applications, one of the easiest ways to make progress towards a sustainability goal is to adopt [AWS Graviton instances](https://aws.amazon.com/ec2/graviton/). AWS Graviton processors are designed by AWS to deliver the best price performance for your cloud workloads running in Amazon EC2.

In this tutorial, I will walk through the steps to take an existing application running on x86 instances today and migrate to AWS Graviton powered instances in order to achieve a higher level of sustainability for your Rust application. This guide includes creating AWS resources that you will be charged for.

## What you will learn

- How to build a Rust application for AWS Graviton
- How to port an existing Rust application to AWS Graviton

| Attributes                |                                   |
| ------------------- | -------------------------------------- |
| ✅ AWS Level        | 200 - Intermediate                          |
| ⏱ Time to complete  | 30 minutes                             |
| 💰 Cost to complete | Free when using the AWS Free Tier or USD 2.62      |
| 🧩 Prerequisites    | - [AWS Account](https://docs.aws.amazon.com/accounts/latest/reference/manage-acct-creating.html?sc_channel=el&sc_campaign=costwave&sc_content=building-rust-applications-for-aws-graviton&sc_geo=mult&sc_country=mult&sc_outcome=acq)<br> - [Amazon DynamoDB Table](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/getting-started-step-1.html?sc_channel=el&sc_campaign=costwave&sc_content=building-rust-applications-for-aws-graviton&sc_geo=mult&sc_country=mult&sc_outcome=acq)|
| 💻 Code Sample         | Code sample used in tutorial on [GitHub](https://github.com/build-on-aws/building-rust-applications-for-aws-graviton)                             |
| 📢 Feedback            | <a href="https://pulse.buildon.aws/survey/DEM0H5VW" target="_blank">Any feedback, issues, or just a</a> 👍 / 👎 ?    |
| ⏰ Last Updated     | 2023-07-20                             |

| ToC |
|-----|

## Setup

### IAM and DynamoDB Setup

This tutorial will leverage a DynamoDB table for its datastore. In order to authenticate with DynamoDB IAM credentials must be used. In this tutorial we will be using IAM roles attached to EC2 instances to obtain valid credentials for DynamoDB. To keep the setup simple, I've provided Terraform, CloudFormation, and AWS CLI scripts for you to use. They can all be found in the [infrastructure directory of the git repo](https://github.com/build-on-aws/building-rust-applications-for-aws-graviton/tree/main/infrastructure) we will be using for this tutorial. Pick your favorite tool and deploy the corresponding script. The scripts will create the following resources:

- An IAM Role with the name `rust-link-shortener-ec2-role`
- An IAM Policy that will allow DynamoDB actions
- A DynamoDB table with the name `url_shortener`

### EC2 Setup

To demonstrate how to move a Rust application to AWS Graviton-based Instances, I have built a simple link shortener application in Rust. I’m not a front end developer, so I will be relying on cURL to interact with my application’s APIs. The application is written with the most current release version of Rust at the time of writing, and Rocket 0.5.0-rc3. The application generates a unique 8 character string for each URL that it shortens, and stores the original URL and the 8 character string in a Amazon DynamoDB table. The code is not meant to be used in production and is provided as a sample only.

For this demo, [launch two EC2 instances](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/EC2_GetStarted.html#ec2-launch-instance?sc_channel=el&sc_campaign=costwave&sc_content=building-rust-applications-for-aws-graviton&sc_geo=mult&sc_country=mult&sc_outcome=acq) running Ubuntu 22.04. Be sure to select the `rust-link-shortener-ec2-role` IAM role during setup. Without this role yoru instance will not be able to access DynamoDB. The first instance will be of `c5.xlarge` instance-type, and the second will be of `c6g.xlarge` instance-type. Once they are running, [connect to each instance](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/AccessingInstances.html?sc_channel=el&sc_campaign=costwave&sc_content=building-rust-applications-for-aws-graviton&sc_geo=mult&sc_country=mult&sc_outcome=acq) and install Rust using the following command:

```shell
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
```

Install the `build-essential` package to obtain the necessary compilers and linkers for any of the modules we will be installing later.

```shell
sudo apt update
sudo apt install build-essential
```

### Code Checkout

To checkout the sample project, go to [building-rust-applications-for-aws-graviton](https://github.com/build-on-aws/building-rust-applications-for-aws-graviton) and clone the repository using command below:

```bash
git clone https://github.com/build-on-aws/building-rust-applications-for-aws-graviton
```

Check out the code on both - your x86 instance and your AWS Graviton Instance. You should now have a `rust-link-shortener` directory containing all of the appropriate code.

## Compiling for X86

On your `c5.xlarge` instance, navigate to the `building-rust-applications-for-aws-graviton` directory and run the following command to build the application:

```rust
cargo build --release
```

When the build is finished, you should see output as following:

```shell
Finished release [optimized] target(s) in 2m 41s

real    2m41.674s
user    10m6.078s
sys    0m25.774s
```

Navigate to the `target/release` directory and the `rust-link-shortener` binary will be there ready for launch. To launch it run command `./rust-link-shortener`. The application is configured to run on port 8000 and listen on all interfaces for the purposes of this demo.

## Compiling for AWS Graviton (ARM64)

On your `c6g.xlarge` instance, navigate to the `building-rust-applications-for-aws-graviton` directory and run the following command to build the application:

```rust
cargo build --release
```

When the build is finished, you should see output as following:

```shell
Finished release [optimized] target(s) in 3m 27s

real    3m27.946s
user    12m57.304s
sys    0m26.632s
```

Navigate to the `target/release` directory and the `rust-link-shortener` binary will be there ready for launch. To launch it run command `./rust-link-shortener`. The application is configured to run on port 8000 and listen on all interface for the purposes of this demo.

## Testing the Application

To test the application we will use cURL to make a few example requests and verify our application is working properly. All of the commands below can be run against both the EC2 instances.

### Shortening a URL

The following command will shorten a URL. My instance has an IP address of 10.3.76.37, so I’m using that in my command. Make sure to replace the IP address with the address of your EC2 Instance:

```shell
curl -X POST -d "https://aws.amazon.com/ec2/graviton/" http://10.3.76.37:8000/shorten_url -H 'Content-Type: application/json'
```

You should get output that looks like the following:

```shell
https://myservice.localhost/rlbnDueu
```

The `rlbnDueu` is our application’s identifier for our URL.

### Retrieving Full URL

In order to retrieve the original URL, we will need to make another request to the application and pass this value in to the `get_full_url` API, as shown in the following command.

Replace the shortened URL identifier with the identifier you got from the previous command, and make sure your IP address is correct.

```shell
curl -X GET -d "rlbnDueu" http://10.3.76.37:8000/get_full_url -H 'Content-Type: application/json'
```

You should get output that looks like the following:

```shell
Your full URL is https://aws.amazon.com/ec2/graviton/
```

## Load Testing

Every time you make a software or hardware change you should re-evaluate your existing configuration and assumptions to ensure you are getting the full benefit of your new configuration. While full performance testing and optimization is outside the scope of this blog we have a [comprehensive performance runbook](https://github.com/aws/aws-graviton-getting-started/blob/main/optimizing.md) and [Rust specific page](https://github.com/aws/aws-graviton-getting-started/blob/main/rust.md) in our AWS Graviton Technical Guide and your AWS team is always ready to help with any questions you may have.

Performance testing is key when comparing multiple instance types. In order to compare a `c6g.xlarge` and a `c5.xlarge` instance we will be performing a load test to verify that the application built for Graviton is working as expected. We discuss various load testing methodologies in the [Graviton Technical Guide on GitHub](https://github.com/aws/aws-graviton-getting-started) and recommend using a framework like [wrk2](https://github.com/kinvolk/wrk2). `wrk2` is a  version of `wrk` that is modified to produce a constant throughput load and report accurate latency details across various percentiles. I decided to go ahead and use `wrk2` to test the `shorten_url` function of our application and compare the total requests per second served as well as the average latency at each percentile during our load test. I've kept the load tests simple in this guide to illustrate that testing is important. I'll be running my load tests from a c5.18xlarge instance in the same availability zone as our test instances. I'm using a c5.18xlarge instance because I know it will be able to load test our instances thoroughly because it is a much larger instance size than any of the exampe instances.

### Load Test Setup

The first step is to checkout the [wrk2](https://github.com/kinvolk/wrk2) repository and build it for use.

```shell
git clone git@github.com:kinvolk/wrk2.git
cd wrk2
make
```

Because our `shorten_url` function uses the POST method and requires some data, we need a lua config file to pass to wrk2. My `post.lua` file has the following content:

```yaml
wrk.method = "POST"
wrk.headers["content-type"] = "application/json"
wrk.body = "https://aws.amazon.com/ec2/graviton/"
```

### Running The Load Test

For our example application lets pretend that the application should serve 99.9% of requests in under 65ms. I will then run a load test against each instance to see how many requests per second each instance can handle before this latency threshold is breached. To start with I ran a 5 minute load test against each instance using the following commands. While running each command, make sure your IP address is correct. The `-c` parameter controls how many connections are made during the load test. The `-d` test specifies how long the test should run. The `-L` parameter enables reporting of latency statistics across various percentiles. The `-R` parameter specifies how many requests per second the load test should run with. The `-s` parameter allows us to specify our Lua script we defined above.

```shell
#C5 Instance
./wrk -c120 -t60 -d 5m -L -R 13000 -s ./post.lua http://10.3.71.236:8000/shorten_url

#C6g Instance
./wrk -c120 -t60 -d 5m -L -R 13000 -s ./post.lua http://10.3.69.199:8000/shorten_url
```

While running this command, make sure your IP address is correct.

### Initial Results

|Latency Percentiles |C5.xlarge |C6g.xlarge |
|--- |--- |--- |
|50 |5.16ms |5.26ms |
|75 |5.72ms |5.85ms |
|90 |6.51ms |6.65ms |
|99 |17.82ms |16.94ms |
|99.9 |49.76ms |39.23ms |
|99.99 |79.93ms |66.05ms |
|99.999 |134.27ms |193.66ms |
|100 |167.55ms |333.05ms |

### Driving More Load

So far our initial results look great. Our C5 instance is staying under our threshold and our Graviton instances look like there is enough overhead to take additional traffic without breaching our latency target. Lets push each instance a bit harder and see what happens to our latency target under more load. Lets bump it up to 700 requests per second by adjusting the `-R` parameter to 14000.

```shell
#C5 Instance
./wrk -c120 -t60 -d 5m -L -R 14000 -s ./post.lua http://10.3.71.236:8000/shorten_url

#C6g Instance
./wrk -c120 -t60 -d 5m -L -R 14000 -s ./post.lua http://10.3.69.199:8000/shorten_url
```

|Latency Percentiles |C5.xlarge |C6g.xlarge |
|--- |--- |--- |
|50 |5.47ms |5.48ms |
|75 |6.04ms |6.16ms |
|90 |6.80ms |7.18ms |
|99 |17.15ms |20.66ms |
|99.9 |36.48ms |42.94ms |
|99.99 |56.90ms |205.82ms |
|99.999 |143.74ms |709.12ms |
|100 |168.45ms |966.66ms |

### Pushing Graviton To The Limit

How much more can we push it until they tip over? Lets find out. Increase the load test to 800 requests per second by adjusting the `-R` parameter to 15000.

```shell
#C5 Instance
./wrk -c120 -t60 -d 5m -L -R 15000 -s ./post.lua http://10.3.71.236:8000/shorten_url

#C6g Instance
./wrk -c120 -t60 -d 5m -L -R 15000 -s ./post.lua http://10.3.69.199:8000/shorten_url
```

|Latency Percentiles |C5.xlarge |C6g.xlarge |
|--- |--- |--- |
|50 |5.44s |5.47ms |
|75 |8.00s |6.11ms |
|90 |9.47s |7.08ms |
|99 |11.20s |29.20ms |
|99.9 |12.71s |65.47ms |
|99.99 |13.82s |107.39ms |
|99.999 |13.89s |447.74ms |
|100 |13.90s |571.90ms |

As you can see here, our AWS Graviton powered instance was able to maintain a latency right at our target of 65ms while serving an outstanding 15,000 requests per second. The Intel-powered instances really start to suffer und this much load. AWS Graviton instances deliver up to 40% better price performance for Rust applications while also increasing your Rust application's sustainability by using up to 60% less energy for the same performance than comparable EC2 instances.

## Cleanup

Now that we are done testing, it is time to clean up all the resources we created in this tutorial. Make sure to [terminate any EC2 Instances](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/terminating-instances.html?sc_channel=el&sc_campaign=costwave&sc_content=building-rust-applications-for-aws-graviton&sc_geo=mult&sc_country=mult&sc_outcome=acq) you launched and [delete your DynamoDB table](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/getting-started-step-8.html?sc_channel=el&sc_campaign=costwave&sc_content=building-rust-applications-for-aws-graviton&sc_geo=mult&sc_country=mult&sc_outcome=acq) so you won't incur any additional costs.

## Conclusion

Migrating your Rust applications from x86 EC2 Instances to AWS Graviton powered instances is simple and easy, as shown in this tutorial. Now it is time to try AWS Graviton with your own Rust application!

For common performance considerations and other information, visit our [Graviton Technical Guide](https://github.com/aws/aws-graviton-getting-started/blob/main/rust.md) repository on Github and start migrating your application today.
