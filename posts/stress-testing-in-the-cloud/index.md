---
title: "Stress Testing in the Cloud"
description: Cloud technology is no longer being viewed as emerging. Factors that include agility, cost efficiency, resilience, and scalability have led to the wide adoption of cloud. With this, ensuring testing methods that are aligned to cloud workloads remains high on the cloud agenda.  
tags:
  - stresstesting
  - performancetesting
  - cloudworkloads
authorGithubAlias: aws-veliswaboya
authorName: Veliswa Boya
date: 2023-08-01
---
![A Bridge](images\bridge.jpeg) In the process of preparing to write this article, I learned a lot about load testing of bridges. Load testing a bridge is performed, among others, to verify satisfactory performance of the bridge in accordance with the design intents.

This article is not about load testing of bridges, nor is it about load testing of applications, but I believe that both these concepts have relevance worthy of a brief exploration.

## Why Software Testing in the Cloud?
Cloud technology is no longer being viewed as emerging. Factors that include agility, cost efficiency, resilience, and scalability have led to the wide adoption of cloud. However, factors such as the regulatory scrutiny of cloud, the need to integrate legacy workloads with cloud-native technologies, and traditional methods being proved to be unsuitable for testing in the cloud, ensuring testing methods that are aligned to cloud workloads remains high on the cloud agenda.

## Performance Testing in the Cloud
Performance testing is an “umbrella” term used to define the practice of evaluating how your system responds and its stability under a particular workload. Types of performance testing include load, latency, stress, soak, spike, scalability, just to name a few. I mentioned load testing at the beginning of this article because oftentimes, load testing is compared, or confused, with stress testing. Stress testing is the topic of discussion in this article.

## Load Testing vs Stress Testing
Going back to the bridge analogy that I mentioned at the beginning of this article, ![Load Testing](images\load.jpeg) load testing measures how your system performs under expected load volumes. If the bridge is designed to handle *x* cars over a long period of time as per its design, load testing a bridge would seek to test if the bridge can indeed handle *x* cars over this extended amount of time. Likewise, if your system is designed to handle an *x* number of users (or transactions per second (TPS)) over a long period of time (usually 2 – 3 days) as per its design, load testing a system would test if the system can handle an *x* number of users over this expected amount of time. Both would place a simulated load or demand on the bridge (or the system) to ensure that stability remains as expected during operation.

On the other hand, ![Stress Testing](images\stress.jpeg) stress testing measures how your system performs under unexpected load volumes, usually over a short duration (1 – 2 hours). With stress testing, you push your system to its limits so that you can find the first bottleneck.
It is important to note that for each of these types of testing, the objectives are different. With load testing, you test to make sure that the system works properly under normal use, and with stress testing, your goal is to figure out what happens when the system is pushed to its limits.

## Types of Stress Testing in the Cloud
[In an old interview by InfoQ](https://www.infoq.com/articles/cockcroft-high-availability/), Adrian Cockroft states that the problem with dependencies between services is that it rapidly gets complicated to keep track of these dependencies. It is therefore important to test that everything works properly under stress, to uncover any “unsafe” dependencies between services. Stress testing is just one of the ways to test these dependencies and there are various types of stress testing include:
### 1. Distributed client-server
 Here you are testing across the whole server and all the clients. ![Communication](images\communication.jpeg) You are essentially **testing communication** between the stress server and the clients. Once contact is made from the stress server, clients are meant to signal back to the stress server. If the signal does not take place, further investigation is conducted. You’d typically perform this kind of test during off-peak hours, to ensure that normal work is not interrupted. Right now, you’re probably wondering how off-peak hours look in the cloud? One of the advantages of deploying your workloads in the cloud is the ability to cost-effectively procure disaster recovery resources. [Disaster recovery is different in the cloud][https://docs.aws.amazon.com/whitepapers/latest/disaster-recovery-workloads-on-aws/disaster-recovery-is-different-in-the-cloud.html], you can recover quickly from a disaster with reduced complexity, and perform repeatable testing which allows you to test more frequently. On AWS, the [Elastic Disaster Recovery service (AWS DRS)](https://aws.amazon.com/disaster-recovery/) removes the requirement to perform distributed stress testing during off-peak hours because DRS helps you perform non-disruptive recovery and failback drills during normal operation.
### 2. Application
The main focus during application stress testing is **on any defects in data locking and performance issues that may be a blocker**. During application stress testing you look at defects that can occur during simultaneous access of the same data by multiple users. Here you look at issues which include slow responses or unexpected delays. Latency and packet loss issues are also identified and addressed during application stress testing. The main goal of application stress testing is to ensure that you deliver a product that is reliable and of high quality.
### 3. Transactional
With transactional stress testing, you’re essentially testing that **the integrity of the data is maintained during an exchange from one application to another**. In addition, you are testing for response times, throughput, and potential security vulnerabilities during this exchange.

## Performing Stress Testing in the Cloud
Running stress testing in the cloud involves a number of steps. Before we look at the steps, it is important to note that stress testing should be repeated as often as possible to get the most accurate results, the environment should stay the same, and use of automated tools is the best way to go about performing stress testing (or any form of testing). Deploying your application in the cloud through the use of containers is one way of ensuring consistency of your runtime engine, dependencies, configuration, and code across all your test environments.

Before you perform your stress test, you prepare for it in the following ways:
### 1. Plan your stress test
This is where you decide on the metrics you want to test. To arrive at these metrics, you work backwards by looking at the business needs or product requirements. Stress testing looks at variations in load such as holidays or end-of-month periods that occur in peak times. Therefore, bear in mind that you are not testing for “normal” load and these metrics should take this into consideration. As an example, an expected load on your system could be 200 users. For stress testing, you test how the system responds to an expected number at peak times, say 400 users. Therefore you plan to test how the system responds to these 400 users, over a 1-hour period as an example.
### 2. Decide on the testing scenario
A key consideration with any form of testing is to start small. With this, you select only one test scenario as a start. If we look at an example of an e-commerce site, you could start by stress testing the **Adding to Cart** workflow. 
### 3. Choose a testing tool
[Apache JMeter is an open source load testing tool][https://www.blazemeter.com/solutions/jmeter] which when used together with its contributor, BlazeMeter, lets you effortlessly run many parallel tests in the cloud provider of your choice (JMeter used on its own, you will need to run your tests sequentially). These tools also integrate into your CI/CD pipeline for shift left agility, provide you with test data and advanced reporting.
### 4. Configure the test script
Once you’ve decided on the testing tool, you build the script in the testing tool. While doing this, you can also create your test data.
### 5. Run the test
Probably the easiest step of them all, most tools let you do this by simply clicking “Run”.
### 6. Monitor results
Once the test has completed, analyze the test results to identify any bottlenecks, latency issues, or any other issues based on the metric you decided on earlier during preparation. 
### 7. Optimize and retest
If you identified any issues during stress testing, fix and repeat the test until the application meets the performance requirements that align to the business needs.

## Tools for Stress Testing in the Cloud
Previously, I mentioned Apache JMeter and BlazeMeter as just some of the few tools for stress testing in the cloud. Here are a few others:
* [NeoLoad](https://www.tricentis.com/products/performance-testing-neoload) - NeoLoad is an automated load and stress testing tool for enterprise organizations who are continuously testing from APIs to applications. This is not an open source tool, but it is popular for its rich set of features, and global support. It has been supporting cloud testing since 2011.
* [LoadRunner](https://www.microfocus.com/en-us/products/loadrunner-cloud/overview) - LoadRunner is a software testing tool from OpenText. LoadRunner can simulate millions of users concurrently using an application. It also supports recording and later analyzing the performance of key components of the application whilst under load. NeoLoad is cloud-compatible.

## Metrics during Stress Testing in the Cloud
Here are just some of the metrics you should measure throughout your stress testing process, I’m aligning metrics to two of the types of stress tests I detailed earlier, for illustration:
* Distributed client-server stress testing
With this stress test, you are testing for communication between servers. Typical metrics to look out for include rounds failure which let you know how many times a round failed, connections failure which is the number of failed connections refused by the client, typically due to a weak signal, and hits failure which is the number of failed attempts. Adjustments to your code will help with fixing these types of failures.
* Application stress testing
With application stress testing, you are testing for performance issues which include unexpected delays (bottlenecks). Typical metrics to look out for include how much time is taken to have the first byte of data returned to you, hit time which is the average amount of time taken to retrieve a page or image, and page time which is how much time is taken to retrieve all of the data on a page.

## Conclusion
Performance testing of any kind goes beyond merely being a technical consideration—it’s also a business requirement and should always be performed with the customer in mind.
In addition to this, the rapid cloud adoption that we are continuing to see necessitates performance testing of these cloud workloads, sometimes due to regulatory requirements and other times due to ensuring that moving these workloads to the cloud results in you continuing to provide great customer experiences. 
It is important to know the types of testing, and particularly how stress testing can support you in achieving all these goals.

## Additional Resources
#### 1. [When to Perform a Stress Test by Grafana Labs](https://k6.io/docs/test-types/stress-testing/)
#### 2. [Performance Testing, Load Testing & Stress Testing Explained](https://www.bmc.com/blogs/load-testing-performance-testing-and-stress-testing-explained/)
#### 3. [Performance Testing vs. Load Testing vs. Stress Testing by BlazeMeter](https://www.blazemeter.com/blog/performance-testing-vs-load-testing-vs-stress-testing)
#### 4. [Software Stress Testing: A Essential Guide for Effective Software Testing](https://testsigma.com/blog/software-stress-testing/#Load_Test_Vs_Stress_Test)
