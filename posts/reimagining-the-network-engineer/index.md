---

title: re:Imaging the Network Engineer Part 1
description: Today's networks are complex and the demand for network engineers that can understand these complexities are higher than ever. In this post we discuss the skills that network engineers need to know manage the new network. 
tags:
  - network-engineer
  - cloud-networking
authorGithubAlias: @labeveryday
authorName: Du'An Lightfoot 
date: 2022-11-07
---

Over the past 6 years the network engineering industry has been evolving. The introduction of software-defined networking has led to networking gear being more controller and API driven so engineers can manage and deploy their networks programmatically. Because of this network engineers have been learning new skills in automation and devops in order to fulfill the new requirements of an evolving job role.

As much as SDN and automation simplify things. The truth is that network engineering skills are needed today more than ever. Networks today, no longer only exist behind a firewall in our data centers. The complexities of our networks and applications are no longer just north/south and east/west. Applications have their own cluster networks that are managed in services like Kubernetes. Networks are on-premises, in the cloud, being extended to employee’s homes, in space and in the ocean. The complexity has expanded and the skill-set of a network engineer has to expand with it. In the words of my good friend Tim McConnaughy “The new network engineer has to be able to take care of the new network.” So, what is this new network? I

So, after talking to dozens of technical hiring managers and looking at hundreds of job postings there are 3 key skills the re:Imagined network engineer needs. In this blog I will share this list. Feel free to add your own thoughts and opinions as well because I am looking to learn more and to hear your viewpoints.

**Networking**

Becoming a network engineer has never been easy. But the scope of what you needed to know was not as vast as it is now. Today you need to be able to understand things like TCP/IP, VPNs, SDN, and routing better than ever. Applications workflows and services are being tunneled and load balanced globally. And with microservices most of those workflows are ephemeral. So testing is not as simple as asking a customer for a source and destination address and then tracing out the problem. You have to be able to understand how the applications are designed so you can communicate with the developers and product owners. There is some good news. BGP is the routing protocol of the cloud. The bad news is that if you have been avoiding IPv6. The time has come for you to learn!

**The Cloud**

This is not a marketing post trying to get you to learn the cloud or to get you to focus on another certification. I have spoken to two directors at fortune 100 companies that have shared how hard it has been to find network engineers with cloud skills. Know that networking in the cloud is different. You can deploy your own network with the Amazon VPC or you can spin up a managed Kubernetes cluster with Amazon EKS. They both have their own way of networking and they both may need to communicate with each other and your on-premises data center. You as the network engineer will need to understand the networking of these services, the supported hybrid connectivity options to communicate with these services, and the spend for the data transfer of these services. (Spend is a cloud term for cost).

Another point with the cloud is the scale organizations now have at their fingertips. Yes, they can spin up new networks and applications in minutes. But in order for that to happen ip addressing has to be configured, VPNs tunnels have to be up, BGP connections have to be established, and the traffic has to be properly engineered. This may all sound simple, but how will you handle ip address overlaps? What will you do when you need to load balance BGP or influence a desired path? Something else I did not mention is that this is just for 1 cloud. What if your organization has multiple clouds? Handling these challenges are different in the cloud and this is something we will talk about in part 2.

**Tools of a Programmer**

When I got into network engineering I did it because I did not want to code and I avoided Linux for years. You may can still have a great career without those skills, but for the re:Imagined network engineer understanding the current available tools and services is what will set them apart. When managing cloud networks, we are not building VPCs one-by-one. This is great to do while learning. But if have to do this multiple times across multiple regions this could lead to human error and will undoubtedly take a large amount of unnecessary time. There are infrastructure as code tools like Terraform and Cloud formation that will allow you write your desired infrastructure state in code and then deploy it programmatically repeatedly. Outside of just IaC. Let’s say you need to do a packet capture in the cloud. How will do this? If know Linux you could run tcpdump and/or if you have cloud skills you could use a service like VPC Flows to capture header information. Then send the logs to CloudWatch or S3. My point is that you do not need to be a programmer, but knowing the tools that are available and having an understanding of a programming language like python is becoming a requirement.

For those that are new, I understand it can feel overwhelming with the amount of information you have to learn. Know that tech is a journey and you are not alone on this journey. And for my industry vets you may be looking at the industry wondering how to navigate this ever-changing landscape. In part 2 of this series, I plan to detail a roadmap with the skills and resources to help you learn those skills. Looking forward to hearing your thoughts on this post. Please feel free to like, share and leave a comment below.

Peace,