---
title: "Picturesocial - How to containerize an app in less than 15 minutes"
description: In this post, you're going to learn about the basics of containers, but most importantly how to containerize an app in an easy and reusable way for a modern web application.
tags:
  - containers
  - ecr
  - docker
showInHomeFeed: true
authorGithubAlias: develozombie
authorName: Jose Yapur
date: 2022-10-11
---

|ToC|
|---|

This is an 8-part series about Picturesocial:

| SeriesToC |
|-----------|

Containers is undoubtedly a hot topic. Some of us are have been working with these concepts for years, others are just getting started. Either way, I would like to be your buddy and guide you through your container journey. Together, in this series, we will build Picturesocial, a new Social Media platform to share photos. As we build it, we will make architecture decisions and explore trade-offs.

## What is a container?

But what is a container? Imagine the living room of your dreams, with a nice painting, comfortable sofa for reading or hanging out, a nice coffee table and some pretty lamps. You finally feel like it’s perfect just to realize that you have to move to another apartment and start from scratch.

Now imagine that you design the exact same living room but on one of those big metal cargo containers. That living room can come with you wherever you go, it can be on a ship in the middle of the ocean, on a plane or on a truck crossing the Andes.

A container is exactly that: your application, runtime, and file system packaged logically (like your living room on a container) to run in any place that supports containers. I feel particularly excited about Containers because it gives me the flexibility and freedom to run my stuff wherever I want and know it will work without making any changes.

When your application is containerized, your dependencies like database or queue manager might not be containerized, and that is something you should always consider when you move your container from one environment to another. It is very important to have a place to put your application environment configuration settings like connection strings, time zones and others, that will allow you to persist your configuration from Development to QA and Production or others; so when you swap from QA to Prod you are also sure that you are pointing to the right database or dependency. That way you don’t repeat my mistake of using my dev environment configuration into a high concurrency production website, that made the whole application point to a localhost database and as result, the name of all customers and products were the name of my cats.

To start, we are going to learn some basic concepts about Docker containers that will help us a lot on our journey. Docker lets you deliver software in packages (containers) using operating system-level virtualization.

* **Image** This is one of the most important parts of a container solution because it’s where an application and its state lives. A container image happens when your application together with a Dockerfile is built using the Docker daemon that comes when you install Docker in your environment. I always think about an image as an old fashioned ISO file, where you capture a computer with files, configurations, applications installed, etc. in a simple file that can be used almost everywhere. But compared with an ISO, a container image contains just a small part of the OS components, libraries, runtime and application, and they are much smaller in size and compute requirements.
* **Container** When your image is deployed and executed, it is called a container.
* **Engine** Your container needs to run somewhere where Docker is installed. They way Docker communicates with the hardware where it is installed is through APIs. Those APIs are part of the Docker Engine. With the Docker Engine, your container gets access to compute power, storage and networking.
* **Registry** The place where you save your container images. The registry can be public or private. A registry not only stores the latest image, but also the used tags, and some metadata about 1) when the image was uploaded 2) who uploaded the image and 3) when an image is pulled from the registry. That’s why we can’t talk about containers without a registry. Even when you work locally, your computer is the registry.

## The Dockerfile

Now that we have some context about containers, we should look at one of the most important pieces: the Dockerfile. For me, the Dockerfile is similar to what I used to do when I was starting my career as an intern. Some of us were in charge of "writing the manual." Yep, that manual that nobody reads and if for some reason it is needed, it never works. I’ve been a writer and consumer of a manual and the main issue is that is written by humans for humans. Instead, a Dockerfile is manually created by humans for machines, so it must be written very precisely and solves most of the interpretation issues.

```dockerfile
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

Most Dockerfiles start with a `FROM` statement, used to specify the base image you are using to create your own image. For example, imagine you want to create a container that needs to write a file on an Ubuntu 20.04 instance. Then you would use a `FROM` similar to this:

```dockerfile
FROM ubuntu:20.04
```

From the example above, we can deduce some basic info about tagging:

1. `ubuntu` is the name of the image. We have millions of public images available through Docker Hub that we can use to create derivate work or just use them as it.
2. `20.04` is the version of Ubuntu.
3. Everything after `:` is the tag of the image. You can use tagging for specific versions of an app, environments, languages, etc.

If we check the page of an [Ubuntu image from Docker Hub](https://hub.docker.com/_/ubuntu?tab=description), we can also look at the different tags available.

Some other important commands for a Dockerfile are:

**RUN** `RUN` is used to execute multiple bash commands for preparing your container. You can use RUN multiple times in your Dockerfile.

```dockerfile
RUN mkdir demo
```

This will create a folder named demo.

**CMD** `CMD` is used to execute bash commands but it can only be used once, if you have more than one CMD, the last one will be the only one that gets executed. CMD is only used to provide defaults for your container. For example:

```dockerfile
`CMD ["echo", "Hello World"]`
```

This will print "Hello World" at Docker build time.

Learn more about [Dockerfile commands](https://docs.docker.com/engine/reference/builder/#cmd) or access [samples for almost every single programming language or runtime](https://docs.docker.com/samples/).

I always say that your Dockerfile is like your recipe book. You can reuse them for any similar applications. In my case, I will use the same .NET 6 Dockerfile template for all the APIs that I’ll expose on Picturesocial.

Now that we have some context about containers, let’s cover more about the container registry on AWS. You can use Amazon ECR to store your container images with either private or public access. The advantage is that the access to your own images is handled by AWS IAM instead of using external credentials.

## Containerizing an API and Pushing to ECR

Let’s containerize an API and push it to ECR. Don’t worry, we are in this together.

### Prerequisites

* An [AWS Account](https://aws.amazon.com/free/?sc_channel=el&sc_campaign=post&sc_geo=mult&sc_country=mult&sc_outcome=acq&sc_content=01-how-to-containerize-app-less-than-15-min).
* If you are using Linux or macOS, you can continue to the next bullet point. If you are using Microsoft Windows, I suggest you to use [WSL2](https://docs.microsoft.com/en-us/windows/wsl/install).
* Install [Git](https://github.com/git-guides/install-git).
* Install [Docker](https://docs.docker.com/engine/install/) on your computer.
* Install [AWS CLI 2](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html?sc_channel=el&sc_campaign=post&sc_geo=mult&sc_country=mult&sc_outcome=acq&sc_content=01-how-to-containerize-app-less-than-15-min).

Or

If this is your first time working with AWS CLI or you need a refresher on how to set up your credentials, I suggest you follow this [step-by-step guide of how to configure your local AWS environment](https://aws.amazon.com/es/getting-started/guides/setup-environment/?sc_channel=el&sc_campaign=post&sc_geo=mult&sc_country=mult&sc_outcome=acq&sc_content=01-how-to-containerize-app-less-than-15-min). In this same guide, you can also follow steps to configure AWS Cloud9,  as that will be very helpful if you don’t want to install everything from scratch.

### Walk-through

In this example, we will learn about how to containerize an API developed in C# using .NET 6 that returns the text passed as parameter. This is going to be the template that will work for all of the APIs of Picturesocial. We are going to containerize this application because we don’t want to change recipes, scripts, and dependencies when we go from local to cloud environments or vice versa. We want to maintain consistency across changes in the app.

You can follow along with this walk-through using the "ep1" branch of [this repository](https://github.com/aws-samples/picture-social-sample).

1. First, we are going to clone our base repo so we have all the files of this API and also the Dockerfile that we are going to use to create the container image.

```bash
git clone https://github.com/aws-samples/picture-social-sample --branch ep1
```

2. Once cloned, let's go to the newly created directory. We are going to make sure that we are always inside this directory for the rest of this walk-through so the following commands run smoothly.

```bash
cd picture-social-sample/HelloWorld
```

3. Now, before starting with the next steps, we are going to check if Docker is installed correctly and working. Let’s try the following command. We should get at least Docker version 20.10 as output.

```bash
docker --help
```

4. If you open the Dockerfile, you will find the exact same structure as the one shared in this article. Don’t be afraid to change things and play with it. Here are some suggestions:
    * Add a line that will print Hello World in the docker build stage.
        ```dockerfile
        RUN echo "Hello World"
        ```
    * Change the WORKDIR from `app` to `api`, making sure to change all the references to `app` in the Dockerfile.

5. Now, we are going to build the container image. We use the command `docker build` to specify the action and the parameter `-t` to specify the name of the image. As we learned before, The structure of the name is `imageName:tagName`. If we don’t specify a `tagName`, it will be created as `latest` by default. Finally, we specify the path where the Dockerfile is located. Because it’s in the root of our project, we just use a `.`.

```bash
docker build -t helloworld:latest .
```

6. While writing this, I learned that if you are using an Apple MacBook with Apple Silicon, the command to build changes a little bit. This way, we are telling Docker that we are building an image to be executed on `amd64`.

```bash
docker buildx build —platform=linux/amd64 -t helloworld:latest .
```

7. Now, you can run your container by running `docker run`, using the `-d` parameter to run the container in the background, and `-p` parameter to map the port. As we can see in our Dockerfile, the container is using the port 5111 and we are mapping the same port for execution.

```bash
docker run -d -p 5111:5111 helloworld:latest
```

8. After we run this command, we can open the browser and type: [http://localhost:5111/api/HelloWorld/johndoe](http://localhost:5111/api/HelloWorld/johndoe). We should get a `Hello johndoe` output. You can change `johndoe` in the URL to any value you want and test it. Now that we are printing the expected string, our container is running correctly and we can upload it to ECR.

9. Now, we are going to create a private container registry, our own ECR repository named `helloworld`.

```bash
aws ecr create-repository --repository-name helloworld
```

10. Let’s find out the fully qualified domain name (FQDN) of our registry so we can use it in the next steps to mark our image names with the repository name. That way, we tell docker this specific image has to be used for our remote registry instead of the one running in our development environment. For this project, we are using the `us-east-1` region, so you can change that part of the FQDN. The name is composed like this:

```text
[aws account id].dkr.ecr.[aws region].amazonaws.com
#for example for account id: 777777777777 on region: us-east-1
777777777777.dkr.ecr.us-east-1.amazonaws.com
```

11. Now that we know the name of our registry we are going to login into the Docker console. Remember to replace the AWS account id and region for the one you are using or just copy the FQDN that we got from previous step. When you login into Docker you are giving your local environment access to push images into a remote repository like ECR.

```bash
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin [aws account id].dkr.ecr.[aws region].amazonaws.com
```

12. Finally, before we push our image, we are going to change the image name to include the FQDN and then we'll push it to ECR.

```bash
docker tag helloworld:latest [aws account id].dkr.ecr.[aws region].amazonaws.com/helloworld:latest
docker push [aws account id].dkr.ecr.[aws region].amazonaws.com/helloworld:latest
```

If you read this far, that means you made it. Congratulations! You containerized your very first application.

The next [post](/posts/picturesocial/02-whats-kubernetes-and-why-should-you-care/) will be focused on learning about container orchestrators, specifically Kubernetes. I will answer the question: What is Kubernetes and why should I care?

I hope you enjoyed this reading!
