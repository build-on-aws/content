---
layout: blog.11ty.js
title: Picturesocial - What’s Kubernetes and Why should I care?
description: Everybody talks about Kubernetes and this episode will help you understand how it works and why should I care about Kubernetes in the first place.
tags:
  - containers
  - ecr
  - docker
  - picturesocial
authorGithubAlias: jyapurv
authorName: Jose Yapur
date: 2022-07-11
---
# Ep1-Picturesocial - How to containerize an App in less than 15 minutes

Containers is undoubtedly a hot topic. Some of us are have been working with these concepts for years, others are just getting started. Either way I would like to be your buddy and guide you through your container journey. Together, in this series, we will build Picturesocial, a new Social Media platform to share photos. As we build it we will make architecture decisions and explore trade-offs. 

But What’s a container? Imagine the living room of your dreams, with a nice painting, confortable sofa for reading or hanging out, a nice coffee table and some pretty lamps. You finally feel like it’s perfect just to realize that you have to move to another apartment and start from scratch.

Now imagine that you design the exact same living room but on one of those big metal cargo containers. That living room can come with you wherever you go, it can be on a ship in the middle of the ocean, on a plane or on a truck crossing the Andes.

A container is exactly that, your application, runtime and file system packaged logically (like your living room on a container) to run in any place that supports containers. I feel particularly excited about Containers because it gives me the flexibility and freedom of run my stuff wherever I want and know it will work without making any change.

When your application is containerized, your dependencies like database or queue manager might not, and that is something you should always consider when you move your container from one environment to another. Is very important to have a place to put your application environment configuration settings like connection strings, time zones and others, that will allow you to persist your configuration from Development to QA and Production or others; so when you swap from QA to Prod you are also sure that you are pointing to the right database or dependency. That way you don’t repeat my mistake of using my dev environment configuration into a high concurrency production website, that made the whole application point to a localhost database and as result the name of all customers and products were the name of my cats.

To start, we are going to learn some basic concepts about Docker containers that will help us a lot on our journey.

* {Image}: This is one of the most important parts of a Container solution because it’s where an application and its state lives. A container image happens when your application together with a Dockerfile is build using the docker daemon that comes when you install Docker on your environment. I always think about an Image as an old fashioned ISO file, where you capture a computer with files, configurations, applications installed, etc. in a simple file that can be used almost everywhere. But compared with an ISO, a container image contain just a small part of the OS components, libraries, runtime and application, and as them they are much smaller in size and compute requirements.
* {Container}: When your Image is deployed and executed, it is called a Container. 
* {Engine}: Your container needs to run somewhere where Docker is installed. They way Docker communicates with the hardware where it is installed is through APIs. Those APIs are part of the Engine. With the Docker Engine, your Container get access to compute power, storage and networking.
* {Registry}: The place where you save your container Images. The registry can be public or private. A registry not only store the latest image, but also the used tags, and some metadata about 1/ when the image was uploaded 2/ who upload the image and 3/ when an image is pulled. That’s why we can’t talk about containers without a registry, even when you work locally, your computer is the registry.

Now that we have some context about containers, we should look at one of the most important pieces: the Dockerfile. For me, the Dockerfile is similar to what I used to do when I was starting my career as an intern. Some of us where in charge of “writing the manual”, yep, that manual that nobody reads and if for some circumstance is needed, it never works. I’ve been a writer and consumer of a manual and the main issue is that is written by humans for humans. Instead a Dockerfile is a manual created by humans for machines, so it must be written very precisely and solves most of the interpretation issues.

```
FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build-env
WORKDIR /app
# Copy everything
COPY . ./
# Restore as distinct layers
RUN dotnet restore
# Build and publish a release
RUN dotnet publish -c Release -o out
# Build runtime image
FROM mcr.microsoft.com/dotnet/aspnet:6.0
WORKDIR /app
COPY --from=build-env /app/out .
EXPOSE 5111
ENV ASPNETCORE_URLS=http://+:5111
ENTRYPOINT ["dotnet", "HelloWorld.dll"]
```

Most Dockerfile start with a FROM statement, used to specify the base image you are using to create your own image, for example imagine you want to create a Container that needs to write a file on an Ubuntu 20.04 instance, then you would use a FROM similar to this:

```
FROM ubuntu:20.04
```

From the example above, we can deduce some basic things about tagging. 1/ ubuntu is the name of the image, we have available millions of images through Docker Hub that are available publicly that we can use to create derivate work or just use them as it. 2/ 20.04 is the version of ubuntu, everything after “:” is the tag of the image, you can use tagging for specify versions of an app, environments, languages, etc. If we check the page of ubuntu image from Docker Hub we can also look at the different available tags to use https://hub.docker.com/_/ubuntu?tab=description

Some other important commands for a Dockerfile are:

**RUN**: used to execute multiple bash commands for preparing your container, for example. You can use RUN multiple times on your Dockerfile.

```
RUN mkdir demo
```

Will create a folder name demo. 

**CMD**: used to execute bash commands but it can only be used once, if you have more than one CMD, the last one will be the only one that gets executed. CMD is only used to provide defaults for your container. For example

```
`CMD ["echo", "Hello World"]`
```

Will print “Hello World” in Docker build time

If you want to know more about the Dockerfile commands this link https://docs.docker.com/engine/reference/builder/#cmd will be very helpful, also if you would like to have samples for almost every single programing language or runtime, take a look here https://docs.docker.com/samples/ . 

I always say that your Dockerfile is like your recipe book, you can reuse them for any similar applications, in my case I will use the same .NET 6 Dockerfile template for all the API’s that I’ll expose on Picturesocial.
Now that we have some context about containers, let’s talk a little bit more about container registry on AWS. You can use Elastic Container Registry or “ECR” for friends, to store your container images with either private or public access. The advantage is that the access to your own images is handled by AWS Identity and Access Management instead of using external credentials. 

Let’s containerize an API and push it to an ECR. Don’t worry, we are in this together.

**Pre-requisites:**

* An AWS Account https://aws.amazon.com/free/
* If you are using Linux of MacOS you can continue to the next bullet point, if you are using Microsoft Windows I suggest you to use WSL2 https://docs.microsoft.com/en-us/windows/wsl/install
* Install Git https://github.com/git-guides/install-git
* Install Docker on your computer https://docs.docker.com/engine/install/
* Install AWS CLI 2 https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html

OR

* If this is your first time working with AWS CLI or you need a refresh on how to set up your credentials, I suggest you to follow this step-by-step of how to configure your local environment https://aws.amazon.com/es/getting-started/guides/setup-environment/ in this same link you can also follow steps to configure Cloud9, that will be very helpful if you don’t want to install everything from scratch.

**Walkthrough:**

In this opportunity we will learn about how to containerize an API developed in C# using .NET 6 that returns the text passed as parameter, this going to be the template that will work for all the API’s of Picturesocial. We are going to containerize this application because we don’t want to change recipes, scripts and dependencies when we go from local to cloud environments or vice versa and we want to maintain consistency across changes in the app. 

I created a repository on Github https://github.com/aws-samples/picture-social-sample with all the code needed to follow this walkthrough, make sure you select branch “ep1” for this

* First, we are going to clone our base repo so we have all the files of this API and also the Dockerfile that we are going to use for create the container image.

```
git clone https://github.com/aws-samples/picture-social-sample --branch ep1
```

* Once cloned let's go to the newly created directory, we are going to make sure that we are always inside this directory for the rest of this walkthrough so the following commands run smoothly.

```
cd picture-social-sample/HelloWorld
```

* Now, before starting with the next steps we are going to check if docker is installed correctly and working, let’s try with the following command and we should get at least Docker version 20.10 as output. 

```
docker --help
```

* If you open the Dockerfile you will find the exact same structure as the one shared in this article, don’t be afraid, change things and play with it, you can play with some of this suggestions:
    * Add a line that will print Hello World in the docker build stage.
        RUN echo “Hello World”
    * Change the WORKDIR from app to api, make sure you change all the references to app in lines 2, 11 and 12.
* Now we are going to build the container image, we use the command `docker build` to specify the action and the parameter `-t` to specify the name of the image, as we learned before the structure of the name is `imageName:tagName` if we don’t specify a tagName it will be created as latest by default, and finally we specify the path where the Dockerfile is located, because it’s in the root of our project, and we are there, we just use a dot.

```
docker build -t helloworld:latest .
```

* Something I learnt while writing this article was that if you are using an Apple MacBook with Apple Silicon, the command for build change a little bit, this way we are telling Docker that we are building an image to be executed on amd64. 

```
docker buildx build —platform=linux/amd64 -t helloworld:latest .
```

* Now, you can run your Container by running `docker run` and using the `-d` parameter to run the container in background and `-p` parameter to map the port. As we can see in our Dockerfile, the container is using the port 5111 and we are mapping the same port for execution. 

```
docker run -d -p 5111:5111 helloworld:latest
```

* After we run this command we can open the browser and type: [http://localhost:5111/api/HelloWorld/johndoe](http://localhost:5111/api/HelloWorld/jhondoe) and we should get a “Hello johndoe” output, you can change Johndoe, from the url, with any value you want and test it. Now that we are printing the expected string our container is running correctly and we can go further and upload it to an ECR.
* Now we are going to create a private container Registry, our own ECR repository named “helloworld”

```
aws ecr create-repository --repository-name helloworld
```

* Let’s find out the fully qualified domain name (FQDN) of our Registry so we can use it in the next steps to mark our image names with the repository name, that way we tell docker that this specific image has to be used for our remote registry instead of the one running in our development environment, for this project we are using `us-east-1` region, so you can change that part of the FQDN. The name is composed as this:

```
[aws account id].dkr.ecr.[aws region].amazonaws.com
#for example for account id: 777777777777 on region: us-east-1
777777777777.dkr.ecr.us-east-1.amazonaws.com
```

* Now that we know the name of our Registry we are going to login into the Docker console, remember to replace the aws account id and region for the one you are using or just copy the FQDN that we got from previous step. When you login into docker you are giving your local environment access to push images into a remote repository like ECR.

```
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin [aws account id].dkr.ecr.[aws region].amazonaws.com
```

* Now we are ready to push our image, but first we are going to change the image name to include the FQDN and then finally push it to ECR.

```
docker tag helloworld:latest [aws account id].dkr.ecr.[aws region].amazonaws.com/helloworld:latest
docker push [aws account id].dkr.ecr.[aws region].amazonaws.com/helloworld:latest
```

If you are reading this far it means you made it! Congratulations, you containerized your very own first application. 

The next article will be focused on learn about Container Orchestrators, specifically Kubernetes, I will try to answer the question: What is and why should I care?
I hope you enjoy this reading!
