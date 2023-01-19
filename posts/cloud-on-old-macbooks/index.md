---
title: "Running The Cloud on three 2007 Macbooks"
description: Do you have some old computers lying around? Do you want to make them more useful by running containers on them? Maybe even share their resources with your cloud applications? Well in this blog post I explain how I connected three Macbooks from the year 2007 and ran a container based application on them, all while managing them from the cloud.
tags:
  - containers
  - hybrid-cloud
  - ecs
  - docker
  - do-not-run-this-in-prod
authorGithubAlias: darko-mesaros
authorName: Darko Mesaros
date: 2023-01-18
---
# Running The Cloud on three 2008 Macbooks

What you are about to read in this post serves to illustrate some cloud concepts and a way to run a Hybrid Cloud environment with containers. However, the exact way I implemented it should not be replicated in any sort of production environment (if you cherish your sanity). This will make sense in a bit, keep on reading.

## Introduction

Before I get to the core of this idea and how I implemented it, let me first clarify some terms and practices.

### Containers

Just a quick word this. Containers, or more precisely Containerization is application-level virtualization. The reason for this is so that software can be packaged up in these containers and run in isolated “user spaces” called containers!

***But why?***

Because we want to be able to package the entire running environment of a piece of software into a single bundle and run it on many different platform. Be that the cloud or in that laptop right in front of you! *Magic*!

***Couple of Examples:***

At home I am running a few useful bits of software, I got my PiHole (the DNS ad blocker), I got my Home Assistant (smart home wonder), I even got Smokeping (my internet connectivity tracker) all running on a single physical server right in my gaming room. 

Okay … yes "Darko, that is great. Did you just discover the wheel now? Wow, running multiple pieces of software of a single unit of hardware! Wow! Multitasking…" Yeah yeah yeah, I get it, BUT - Sometimes having multiple services running on the same server, can cause issues: Different package version requirements, network port overlap, and and more. This is where containers come in. When I package my applications in these Container bundles with all their requirements, they all run independently of each other on the same hardware! Again … *Magic*! 

On top of that, we also have the ability to build applications, package them up, and ship them to various different system types and it *should* be okay to run! Which is the biggest magic. No more (to an extent) “It worked on my laptop”! A final time … *Magic*!

***Cloud of containers***

In the cloud we use A LOT of containerized applications, especially since the mass proliferation of Microservice architectures. This gives the ability to isolate each one of those microservices onto their own container. Meaning we can now have hundreds of thousands of containers run… oh wait. This is bad, that's a lot of moving things, that is a lot of containers we need to manage, patch, deploy, and maintain. Orchestration and management of all that can be a challenge.

This is why we have container/microservice orchestration engines like Kubernetes, ECS, Hashicorp Nomad, and others. These tools help us a lot, especially in the modern world of “everyone has a bajillon microservices and containers running for apparently no reason”. Hence it is important to set up Your container infrastructure with an orchestration engine in mind.

I wanna quickly talk about what else people have: **COMPUTERS**.

### **Hybrid:**

Hello there you wonderful person at the other end of this discussion. Hi! Do you have computers? Do you have a datacenter? Maybe some computers (which are also called servers) in that datacenter. Maybe they were an amazing investment, a few years back, but now sit there being idle, not doing anything, just costing you money. Why? Because the cloud is great! Yes, you got it all in the cloud now, everything is there - You need storage, click here - storage deployed! You need more servers, run this command - servers available! Everything is an API call away. What a wonderful time to be a developer.

But let's ge back to those servers you have lying around. If only there was a way for you to run your applications on both ends. In the cloud and in your data center. If only there was a special way to package applications so they dont care on what kind of platform they run. If only there was a way to make a containe… oohhh! Let’s talk about Containers and Hybrid infrastructure - that is, how to deploy your containers to both the cloud and your on-prem infrastructure.

To be frank, a lot of people using the cloud are currently or were at some point running some sort of hybrid infrastructure. Meaning that a certain portion of their workload was running in their own data center (or that pesky server under Steve’s desk) and in the cloud. But that usually involved splitting things out, splitting the way we build infrastructure, splitting the way we deploy software. As we could not just use the same tools and orchestrations both on-prem and in the cloud. 

What if I told you, you could.

I want to show you how you can run those amazing containerized applications, on hardware in your living room (or Data center), AND in the cloud! All that by using a wonderful feature of Amazon Elastic Container Service(ECS) - ECS Anywhere.
ECS Anywhere is a service, rather a feature of Amazon ECS (Elastic Container Service) that allows you to bring compute resources from your local on-premises data center to the cloud and run containerized applications on them. All while using the same orchestration platform as you would for the cloud.

What I will show you today in the next few paragraphs, is my ECS cluster running on my desk back home, how it works, how it’s connected, and I set it all up. Let's have a look.

## The Hardware:

My current cluster consists of the following, get ready, this is some real hot hardware… Are you ready? Okay …

**3 x 2007 Intel Macbooks**. Yes. That’s it. They are all having variations of the Core 2 Duo Processor, and between 1GB and 4GB of RAM. They are all part of this ECS Cluster and are able to serve modern applications to the world wide internet(web)! Truly amazing. Now do you understand why I said this is not something you should be doing in a production environment?

### What is running on that hardware?

These Macbooks came with Mac Os X installed on them, and can no longer be updated to the latest version. Well that does not matter, as Mac Os X is not the OS we are gonna use today, rather I will install [Debian Linux]() on them. We can install the latest 64 bit version, as it will easily run on this hardware. The reason I chose Debian over some other distribution is because of its stability, it's ability to run on rather old hardware, and because it is supported out-of-the-box in Amazon ECS Anywhere.

Once Debian is installed, it is time to configure each of these Macbooks with the appropriate settings and connect them to ECS. Now, I can go ahead and SSH into each of them and run through each of the steps individually, but that's not very efficient. Let's do one better - let's manage it with **Ansible**. *Wait what …What is Ansible?!* Okay, let me step back. Instead of manually going to each of my on-prem systems and configuring and installing packages. How about I just write what I want in a bit of code, and let some Python magic happen. 
Ansible, is a wonderful tool that lets you define infrastructure and configuration through code. With Ansible you write things called *Playbooks* and have them describe what your configuratin should look like. What packages need to be installed, what services started, what scripts executed.

### Ansible Setup

This now means that the only manual steps I will be doing on this server will be installing and configuring Ansible. All the rest is done via, well, Ansible. Let me quickly take you through the manual steps:

First off let's install Ansible on Debian:
```bash
# Add the repository to apt
sudo apt-add-repository ppa:ansible/ansible

# Refresh apt index
sudo apt update

# Install the ansible package
sudo apt install ansible
```

Now let's create a local user named `ansible` that will be used by ansible to execute commands:
```bash
# Create a group for the ansible user
sudo /sbin/groupadd ansible

# Create an user ansible and add it to the ansible group
sudo /sbin/useradd -m -g ansible ansible

# Give the ansible user a password
# (this is purely for debugging purposes)
# (please remove the password later on)
sudo passwd ansible
<password-here>
```

And now, we need to give the user ansible, permissions to run `sudo`. By doing this we will permit this user from executing commands with `sudo` without the need for entering passwords. We will do this by adding the following entry to the `/etc/sudoers` file:
```bash
ansible ALL=(ALL) NOPASSWD:ALL
```

We are almost there, one last thing we need to do is go back to our local workstation (the computer where you will manage this from) and copy your local public key to the remote servers (Macbooks). The reason I am doing this is so that if I want to connect to these systems, I do not need to enter the password. This is needed for Ansible, as Ansible does all it's tasks via SSH. To do this it takes a few steps:
```bash
# Create a local ssh key pair if it does not exist
ssh-keygen

# Copy your public key to the remote system
# this step needs to be repeated for all the
# laptops I am configuring
ssh-copy-id ansible@10.0.1.222
```

And now, we are ready for some Ansible magic, and we are one step closer to running ECS Containers on old Macbooks! But before we get to that, let's first deploy our cluster and everything else we need in the cloud.

## The cloud part

### What goes into this

### Connecting the Macbooks to the Cloud

### Deploying Infrastructure

## Back to Ansible

- Running the ansible code and seeing output
- Verify that the macbooks are showing up on ECS

## Conclusion
