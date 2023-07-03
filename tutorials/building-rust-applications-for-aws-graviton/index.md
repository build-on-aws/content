---
title: Building Rust Applications For AWS Graviton
description: Learn how to migrate a Rust application from x86 based Amazon EC2 Instances to arm64-based Graviton EC2 Instances
tags:
  - graviton
  - rust
  - sustainability
  - deploy
  - migrate
  - arm64
  - ec2
  - tutorials
  - aws
showInHomeFeed: true
authorGithubAlias: DDxPlague
authorName: Tyler Jones
date: 2023-06-15
---

Companies today are making sustainability a key goal for their business in order to improve operational efficiency and drive down cost while also lowering carbon emissions. Achieving these sustainability goals means change across all levels of the business, with application and software development being a key focus. With Rust applications, one of the easiest ways to make progress towards a sustainability goal is to adopt AWS Graviton instances. In this tutorial I will walk through the steps to take an existing application running on x86 instances today and migrate to AWS Graviton powered instances in order to achieve a higher level of sustainability for your Rust application. This guide includes creating AWS resources that you will be charged for.

## What you will learn

- How to build a Rust application for AWS Graviton
- How to port an existing Rust application to AWS Graviton

| Attributes                |                                   |
| ------------------- | -------------------------------------- |
| ✅ AWS Level        | 200 - Intermediate                          |
| ⏱ Time to complete  | 30 minutes                             |
| 💰 Cost to complete | Free when using the AWS Free Tier or USD 2.62      |
| 🧩 Prerequisites    | - [AWS Account](https://aws.amazon.com/resources/create-account/?sc_channel=el&sc_campaign=tutorial&sc_content=building-rust-applications-for-aws-graviton&sc_geo=mult&sc_country=mult&sc_outcome=acq)<br> - [AWS DynamoDB Table](https://us-west-2.console.aws.amazon.com/dynamodbv2/home?region=us-west-2#dashboard)|
| 💻 Code Sample         | Code sample used in tutorial on [GitHub](https://github.com/build-on-aws/building-rust-applications-for-aws-graviton)                             |
| 📢 Feedback            | <a href="https://pulse.buildon.aws/survey/DEM0H5VW" target="_blank">Any feedback, issues, or just a</a> 👍 / 👎 ?    |
| ⏰ Last Updated     | 2023-06-15                             |

| ToC |
|-----|

## Setup

### EC2 Setup

To demonstrate how to move a Rust application to AWS Graviton Instances I have built a simple link shortener in Rust. I’m not a front end developer, so I’ll be relying on cURL to interact with my application’s APIs. The application is written with the most current release version of Rust at the time of writing, and Rocket 0.5.0-rc3. The application generates a unique 8 character string for each URL that it shortens, and stores the original URL and the 8 character string in a DynamoDB table. The code is not meant to be used in production and is provided as a sample only.

For this demo I’ll be using two EC2 instances running Ubuntu 22.04. The first instance will be a `c5.xlarge` instance, and the second will be a `c6g.xlarge` instance. To get started, log in to each instance and download a copy of the code. To install Rust, use the following command:

```shell
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
```

### Code Checkout

To checkout the example project go to [building-rust-applications-for-aws-graviton](https://github.com/build-on-aws/building-rust-applications-for-aws-graviton) and clone the repository. You should now have a `rust-link-shortener` directory containing all of the appropriate code. Check out the code on both your x86 instance and your AWS Graviton Instance.

```bash
git clone https://github.com/build-on-aws/building-rust-applications-for-aws-graviton
```

### DynamoDB Setup

The link shortener application will leverage DynamoDB as its data store. Our Dynamo table will run in OnDemand mode. Lets create a table called `url_shortener` with a Partition Key of `short_url` for our application to use.

![DynamoDB Setup](images/dynamo-setup.jpg)

Notice we have a Partition Key of **short_url(String)** and a Capacity mode of **On-demand**.

## Compiling for X86

On your `c5.xlarge` instance navigate to the `building-rust-applications-for-aws-graviton` directory and run the following command to build the application:

```rust
cargo build --release
```

When the build is finished, you should see output like the following:

```shell
Finished release [optimized] target(s) in 2m 41s

real    2m41.674s
user    10m6.078s
sys    0m25.774s
```

Navigate to the `target/release` directory and the `rust-link-shortener` binary will be there ready for launch. To launch it run `./rust-link-shortener`. The application is configured to run on port 8000 and listen on all interfaces for the purposes of this demo.

## Compiling for AWS Graviton (arm64)

On your `c6g.xlarge` instance navigate to the `building-rust-applications-for-aws-graviton` directory and run the following command to build the application:

```rust
cargo build --release
```

When the build is finished, you should see output like the following:

```shell
Finished release [optimized] target(s) in 3m 27s

real    3m27.946s
user    12m57.304s
sys    0m26.632s
```

Navigate to the `target/release` directory and the `rust-link-shortener` binary will be there ready for launch. To launch it run `./rust-link-shortener`. The application is configured to run on port 8000 and listen on all interface for the purposes of this demo.

## Testing the Application

To test the application we will use cURL to make a few example requests to verify our application is working properly. All of the commands below can be run against both EC2 instances.

### Shortening a URL

The following command will shorten a URL. My instance has an IP address of 10.3.76.37, so I’m using that in my command. Make sure to replace the IP address with the address of your EC2 Instance.

```shell
curl -X GET -d "https://aws.amazon.com/ec2/graviton/" http://10.3.76.37:8000/shorten_url -H 'Content-Type: application/json'
```

You should get output that looks like the following:

```shell
https://myservice.localhost/rlbnDueu
```

The `rlbnDueu` is our application’s identifier for our URL. In order to retrieve the original URL, we will need to make another request to the application and pass this value in to the `get_full_url` API.

### Retrieving Full URL

To retrieve the original URL run the following command. Replace the shortened URL identifier with the identifier you got from the previous request, and make sure your IP address is correct.

```shell
curl -X GET -d "rlbnDueu" [http://10.3.76.37:8000/get_full_url](http://10.3.76.37:8000/get_full_url) -H 'Content-Type: application/json'```
```

You should get output that looks like the following:

```shell
Your full URL is https://aws.amazon.com/ec2/graviton/
```

## Performance Testing Results

Understanding the request per second each instance could process under heavy load is often a key metric used to evaluate instance and application performance. In order to compare a `c6g.xlarge` and a `c5.xlarge` instances we need to perform a load test. We discuss various load testing methodologies in the Graviton Technical Guide GitHub and recommend using  a framework like [wrk2.](https://github.com/kinvolk/wrk2) I decided to go ahead and use wrk2 to test the `shorten_url` function of our application.

### Load test Setup

Because our `shorten_url` function uses the POST method and requires some data, we need a lua config file to pass to wrk2. My `post.lua` file has the following content:

```yaml
wrk.method = "POST"
wrk.headers["content-type"] = "application/json"
wrk.body = "https://aws.amazon.com/ec2/graviton/"
```

### Running the load test

I ran a 30 minute load test against both instances with the following command:

```shell
wrk -c64 -t30 -d 30m -L -R 90000 -s ./post.lua http://10.3.76.37:8000/shorten_url
```

### Results

|Latency Percentiles |C5.xlarge |C6g.xlarge |
|--- |--- |--- |
|50 |12.83ms |13.44ms |
|75 |19.24ms |19.73ms |
|90 |23.31ms |23.49ms |
|99 |25.76ms |25.76ms |
|99.9 |26.00ms |26.00ms |
|99.99 |26.02ms |26.02ms |
|99.999 |26.02ms |26.02ms |
|100 |26.04ms |26.02ms |

| |C5.xlarge |C6g.xlarge |
|--- |--- |--- |
|Requests/Second |11,947.12 |11,960.24 |
|Total Requests Served |21,504,877 |21,528,469 |

Using the same load test our AWS Graviton powered instance achieved similar request latencies across all percentiles, while serving a large number of requests per second and a larger number of total requests. Our AWS Graviton instance did all of this while being cheaper and consuming less energy. AWS Graviton instances achieve the best price/performance for Rust applications.

## Cleanup

Now that we're finished it's time to clean up all of the resources we created in this tutorial. Make sure to terminate any EC2 Instances you created and delete your DynamoDB table so you won't incur any additional costs.

## Conclusion

Migrating your Rust applications from x86 EC2 Instances to AWS Graviton powered instances is simple and easy as shown in the post above. Now its time to try AWS Graviton with your own Rust application! For common performance considerations and other information, visit our [Graviton Technical Guide](https://github.com/aws/aws-graviton-getting-started/blob/main/rust.md) repository on Github and start migrating your application today.
