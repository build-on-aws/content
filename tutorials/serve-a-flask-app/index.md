---
title: How to Serve a Flask App with Amazon Lightsail Containers
description: Follow this tutorial to learn how to serve a Flask App with Amazon Lightsail Containers. 
tags:
    - flask
    - lightsail
    - docker
    - tutorials
    - aws
    - container
showInHomeFeed: true
authorGithubAlias: cobusbernard
authorName: Cobus Bernard
date: 2023-07-28
---

[Amazon Lightsail](https://aws.amazon.com/lightsail/) is an easy-to-use virtual private server. Lightsail recently launched a [Containers service](https://aws.amazon.com/blogs/aws/lightsail-containers-an-easy-way-to-run-your-containers-in-the-cloud/). Follow this tutorial to learn how to serve a Flask app on Lightsail containers service.

In this tutorial, you will learn how to do the following: 

- Create a Flask application.
- Build a Docker container.
- Create a container service on Lightsail, and then deploy the application.
- Delete a container service.

You can get started with [Amazon Lightsail for free](https://portal.aws.amazon.com/billing/signup?client=lightsail&fid=1A3F6B376ECAC516-2C15C39C5ACECACB&redirect_url=https%3A%2F%2Flightsail.aws.amazon.com%2Fls%2Fsignup#/start). 


## Table of Contents

| Attributes                |                                   |
| ------------------- | -------------------------------------- |
| ✅ AWS Level        | 200 - Intermediate                          |
| ⏱ Time to complete  | 30 minutes                             |
| 💰 Cost to complete | Free |
| 🧩 Prerequisites    | [AWS Account](https://aws.amazon.com/resources/create-account/?sc_channel=el&sc_campaign=devopswave&sc_content=cicdcdkpthnec2aws&sc_geo=mult&sc_country=mult&sc_outcome=acq), [Docker](https://docs.docker.com/engine/install/), [AWS Command Line Interface (CLI)](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html) tool and [Lightsail Control (lightsailctl)](https://lightsail.aws.amazon.com/ls/docs/en_us/articles/amazon-lightsail-install-software) plugin on your system                |
| 📢 Feedback            | <a href="https://pulse.buildon.aws/survey/DEM0H5VW" target="_blank">Any feedback, issues, or just a</a> 👍 / 👎 ?    |
| ⏰ Last Updated     | YYYY-MM-DD                             |


| ToC |
|-----|


## Creating the Flask application

Complete the following steps on your local machine that’s running Docker. These steps walk you through the process of creating the Flask application files.

First, create a new project directory and switch to that directory:

```bash
$ mkdir lightsail-containers-flask && cd lightsail-containers-flask
```

Next, create a new Python file called`app.py`, then edit the file and add the following code.

Note that this minimal Flask application contains a single function `hello_world` that is triggered when the route `/` is requested. When it runs, this application binds to all IPs on the system (`0.0.0.0`) and listens on port `5000`, which is the default Flask port:


```Python
from flask import Flask
app = Flask(__name__)



@app.route('/')
def hello_world():
   return "Hello, World!"



if __name__ == "__main__":
   app.run(host='0.0.0.0', port=5000)
```

Now create a new text file called `requirements.txt`, then edit the file and add the following code. 

Note that `requirements.txt` files are used to specify what Python packages are required by the application. For this minimal Flask application there is only one required package, Flask:

```txt
flask===2.0.0
```

When you’re done, save the file.

Create a new file named `Dockerfile`. Edit the file and add the following command to it. 

The Python alpine image ensures the resulting container is as compact and small as possible. The command to run when the container starts is the same as running from the command line: `python app.py`:

```dockerfile
# Set base image (host OS)
FROM python:3.8-alpine

# By default, listen on port 5000
EXPOSE 5000/tcp


# Set the working directory in the container
WORKDIR /app


# Copy the dependencies file to the working directory
COPY requirements.txt .

# Install any dependencies
RUN pip install -r requirements.txt

# Copy the content of the local src directory to the working directory
COPY app.py .


# Specify the command to run on container start
CMD [ "python", "./app.py" ]
```

After, save the file.

At this point, your directory will contain the following files:

```bash
$ tree
.
├── app.py
├── Dockerfile
└── requirements.txt

0 directories, 3 files
```


## Build your container image

Build the container using Docker. Execute the following command from the same directory as the Dockerfile, which builds a container using the Dockerfile in the current directory and tags the container "flask-container":

```bash
$ docker build -t flask-container .
```

Once the container build is done, test the Flask application locally by running the container:

```bash
$ docker run -p 5000:5000 flask-container
```

The Flask app will run in the container and will be exposed to your local system on port 5000. Browse to http://localhost:5000 or use `curl` from the command line and you will see "Hello, World!":

```bash
$ curl localhost:5000
```

Now that you’ve created your Flask application, now you can proceed to the next step. 


## Creating a container service

Complete the following steps to create the Lightsail container service using the AWS CLI, and then push your local container image to your new container service using the Lightsail control (lightsailctl) plugin.

First, create a Lightsail container service with the [create-container-service](https://awscli.amazonaws.com/v2/documentation/api/latest/reference/lightsail/create-container-service.html) command.

The power and scale parameters specify the capacity of the container service. For a minimal flask app, little capacity is required.

The output of the `create-container-service` command indicates the state of the new service is `"PENDING".` Refer to the second code block to confirm this:

```bash
$ aws lightsail create-container-service --service-name flask-service --power small --scale 1
```

Use the [get-container-services](https://awscli.amazonaws.com/v2/documentation/api/latest/reference/lightsail/get-container-services.html) command to monitor the state of the container as it is being created. You can refer to the third code bloc to confirm this. 

Now wait until the container service state changes to `"READY"` before continuing to the next step. Your container service will become active after a few minutes:

```bash
$ aws lightsail get-container-services --service-name flask-service
```

```json
{
    "containerService": {
        "containerServiceName": "flask-service",
         ...
        "state": "PENDING",
```

Next, push the application container to Lightsail with the `push-container-image` command:

**Note:** the **X** in `":flask-service.flask-container`.* The *X** will be a numeric value. If this is the first time you’ve pushed an image to your container service, this number will be `1`. You will need this number in the next step.

```bash
$ aws lightsail push-container-image --service-name flask-service --label flask-container --image flask-container



...
Refer to this image as ":flask-service.flask-container.X" in deployments.
```

Now that your container service is created, it’s ready to deploy in the next step. 


## Deploying the container

First, create a new file called `containers.json`, thenedit the file and add the following code.

Make sure to replace the **X** in `:flask-service.flask-container.X` with the numeric value from the previous step.

The `containers.json` file describes the settings of the containers that will be launched on the container service. In this instance, the `containers.json` file describes the flask container, the image it will use, and the port it will expose:

```json
{
    "flask": {
        "image": ":flask-service.flask-container.X",
        "ports": {
            "5000": "HTTP"
        }
    }
}
```

When you’re done, save the file. 

Next, create a new file called `public-endpoint.json`, then edit the file and add the following code.

The `public-endpoint.json` file describes the settings of the public endpoint for the container service. In this instance, the `public-endpoint.json` file indicates the flask container will expose port `5000`. Public endpoint settings are only required for services that require public access:

```json
{
    "containerName": "flask",
    "containerPort": 5000
}
```

After you’ve added this code, save the file. 

Now that you’ver created your `containers.json` and `public-endpoint.json` files, your project directory will read like the following code block:

```json
$ tree
.
├── app.py
├── containers.json
├── Dockerfile
├── public-endpoint.json
└── requirements.txt

0 directories, 5 files
```

Next,  deploy the container to the container service with the AWS CLI using the [create-container-service-deployment](https://awscli.amazonaws.com/v2/documentation/api/latest/reference/lightsail/create-container-service-deployment.html) command.

The output of the `create-container-servicedeployment` command indicates that the state of the container service is now `"DEPLOYING"`. As shown in the following second code block:

```bash
$ aws lightsail create-container-service-deployment --service-name flask-service --containers file://containers.json --public-endpoint file://public-endpoint.json
```

```json
{
    "containerServices": [{
        "containerServiceName": "flask-service",
         ...
        "state": "DEPLOYING",
```

Then, use the `[get-container-services]`(https://awscli.amazonaws.com/v2/documentation/api/latest/reference/lightsail/get-container-services.html) command to monitor the state of the container until it changes to `"RUNNING"` before continuing to the next step.

The `get-container-service` command also returns the endpoint URL for container service:

```bash
$ aws lightsail get-container-services --service-name flask-service
```

```json
{
    "containerServices": [{
        "containerServiceName": "flask-service",
         ...
        "state": "RUNNING",
         ...
        "url": "https://flask-service...
```

After the container service state changes to `"RUNNING"`, which typically takes a few minutes, navigate to this URL in your browser to verify your container service is running properly. Your browser will output `"Hello, World!"` as before.

Congratulations. You have successfully deployed a containerized Flask application using Amazon Lightsail containers.


## Cleaning up resources

Complete the following steps to the Lightsail container service that you created as part of this tutorial.

To cleanup and delete Lightsail resources, use the `delete-container-service` command.

The `delete-container-service` removes the container service, any associated container deployments, and container images:

```bash
$ aws lightsail delete-container-service --service-name flask-service
```

You’ve successfully deleted your resources and can avoid incurring any additional charges on your account. 


## Conclusion

You have successfully deployed a containerized Flask application using Amazon Lightsail containers. Amazon Lightsail is a great choice to develop, build, and deploy a variety of applications like WordPress, websites, and blog platforms.
