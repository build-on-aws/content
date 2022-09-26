---
layout: blog.11ty.js
title: Picturesocial - How to analyze images with Machine Learning?
description: Image recognition sounds like some high tech computer science topic, and it is. Fortunately, there are tools that abstract the complexity of creating your own algorithms into a REST API. In this post, you are going to learn how to add image recognition to your Picturesocial app with an API.
tags:
  - ai-ml
  - dotnet
authorGithubAlias: jyapurv
authorName: Jose Yapur
date: 2022-07-11
---

We started this journey with containers, registries, Kubernetes, Terraform, and some other tools that enabled us to deploy our first API, but this journey is just starting. The core of Picturesocial is the capability to add tags automatically based on the pictures uploaded to our social network platform and this is what we are going to learn in this post by using artificial intelligence services with picture and pattern recognition.

## What is Image Detection?

As humans, we are very good at recognizing things we have seen before. You can look at this picture and almost instantly recognize that it shows a cat lying on a laptop with some flowers in the background. If you know a little bit more about cats, maybe you can also tell that this is an adorable Persian cat.
![Picture of a cat laying over a laptop](images/05-01.jpg "Picture of a cat laying over a laptop")
Computers do not possess this innate ability to recognize different things in an image, but they can be trained to do so. [Deep learning](https://en.wikipedia.org/wiki/Deep_learning) is a machine learning technique that can be used to allow computers to recognize objects in images with varying confidence levels. In order for it to work, deep learning requires us to train models with thousands of labeled images: cat photos labeled “cat”, dog photos labeled “dog”, and so on. This can take up a significant amount of data, time and compute resources, making it harder for us to train deep learning models on our own.

Luckily for us, we are able to add image detection capabilities to Picturesocial without having to create, train, or deploy our own machine learning models using simple, easy to use API’s.

## The Solution

On Picturesocial, we will use Amazon Rekognition to automatically tag the images uploaded by our users. This is an artificial intelligence service that requires no deep learning knowledge and will make our application capable of analyzing images with a simple API. To do this, we will use an Amazon Rekognition API called [`DetectLabels`](https://docs.aws.amazon.com/rekognition/latest/APIReference/API_DetectLabels.html) that receives an image as input and outputs a list of labels. A label can be an object, scene, or concept. For example, the cat picture above could contain labels such as `Cat`, `Computer`, `Flower` (objects), `Office` (scene), and `Indoors` (concept).

First, we will send our image to Amazon Rekognition so it can identify different things on it. To do so, we will create a request specifying the Amazon S3 Bucket in which our image is stored and its file name. We also tell the service the maximum number of labels we want to retrieve and the minimum confidence level for each label. The confidence level means how certain Amazon Rekognition is about the label assigned to an image.

**Sample Request**

```
{
    "Image": {
        "S3Object": {
            "Bucket": "Picturesocial",
            "Name": "cat.jpg"
        }
    },
    "MaxLabels": 10,
    "MinConfidence": 75
}
```


Amazon Rekognition will analyze our image and return a response containing a list of labels and the level of confidence for each label. Labels for more common objects will also have a list of instances with the location where that object is located in the image.

**Sample Response**

```
{
    "Labels": [
        {
            "Name": "Laptop",
            "Confidence": 99.94806671142578,
            "Instances": [
                {
                    "BoundingBox": {
                        "Width": 0.7708674073219299,
                        "Height": 0.6782196164131165,
                        "Left": 0.21325060725212097,
                        "Top": 0.32108595967292786
                    },
                    "Confidence": 80.35874938964844
                }
            ]
        },
        {
            "Name": "Cat",
            "Confidence": 92.20580291748047,
            "Instances": [
                {
                    "BoundingBox": {
                        "Width": 0.8352921605110168,
                        "Height": 0.5242066979408264,
                        "Left": 0,
                        "Top": 0.4561519920825958
                    },
                    "Confidence": 92.20580291748047
                }
            ]
        }
    ]
}
```

The image below is an interpretation of these results. Amazon Rekognition was able to identify a laptop and a cat on this image within the bounded areas.
![Picture of a cat laying over a laptop with labels](images/05-02.jpg "Picture of a cat laying over a laptop with labels")
In this post, we are going to develop an API that will be in charge of detecting the relevant attributes, known as labels, of pictures stored on an S3 Bucket using Amazon Rekognition. This API will be created using .NET 6.0 with the Web API Template. Also, we are going to have a method that will receive two parameters: 1) the name of the file and 2) the name of the bucket. But we are going to implement the routing method just to receive the name of the file and set the bucket as default. So, let’s code!

## Prerequisites

* An [AWS Account](https://aws.amazon.com/free/).
* If you are using Linux or macOS, you can continue to the next bullet point. If you are using Microsoft Windows, I suggest you to use [WSL2](https://docs.microsoft.com/en-us/windows/wsl/install).
* Install [Git](https://github.com/git-guides/install-git).
* Install [AWS CLI 2](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html).
* Install [.NET 6](https://dotnet.microsoft.com/en-us/download).

Or

If this is your first time working with AWS CLI or you need a refresher on how to set up your credentials, I suggest you follow this [step-by-step guide of how to configure your local AWS environment](https://aws.amazon.com/es/getting-started/guides/setup-environment/). In this same guide, you can also follow steps to configure AWS Cloud9,  as that will be very helpful if you don’t want to install everything from scratch.

## Walk-through

1. First we are going to create the web API using the .NET CLI. The API name should be specified using the -n parameter, in our case "pictures".

```
dotnet new webapi -n pictures
```

2. Now, we are going to open the newly created project using VS Code. We are going to use the following command from the terminal. This is the cool way but you can always just open the IDE and find the folder :D

```
code pictures/
```

3. Now, if we look at the project structure, you are going to realize that a Default Controller called `WeatherForecastController.cs` is already in place, as well as a `WeatherForecast.cs`

![Picture of an API file structure](images/05-03.jpg "Picture of an API file structure")

4. We are going to rename the controller file as `PictureController.cs` and we’ll delete the “WeatherForecast.cs” class.
5. Now let’s add the Nuggets that we are going to use for this project. In the same terminal that we used to create the web API let's position our cursor in `pictures`

```
cd pictures
```

6. And using .NET CLI we are going to add the following packages, inside the pictures directory.

```
dotnet add package AWSSDK.Rekognition
dotnet add package AWSSDK.SecurityToken
dotnet add package AWSSDK.Core
```

7. Let’s create the Class for handling the lists of labels from the Amazon Rekognition response. We are gonna name it `Labels.cs`.

```
namespace pictures
{
    public class Labels
    {
        public string Name { get; set; } = default!;
        public float Probability { get; set; }
    }
}
```

8. Now, we are going to open `PictureController.cs` and add the package reference on the top. This way, we can use the packages added in the project inside our API.

```
using Microsoft.AspNetCore.Mvc;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Amazon.Rekognition;
using Amazon.Rekognition.Model;
```

9. We are going to create a route for our API Controller, so we can call the API with the following url format `http://url/api/pictures/photo.jpg`.

```
namespace pictures.Controllers;
[ApiController]
[Route("api/[controller]")]
```

10. We have to change the Controller name to this:

```
public class PictureController : ControllerBase
```

* And also define the HTTP Method GET and the route. Also, we are going to create the Method “DetectLabels” that will receive 2 parameters: 1/ file name included extension as String and 2/ bucket name, set as default in the same method as String. We are using an async method as Rekognition will detect labels asynchronously and also we are returning the response as a JSON array of Labels.
* At this point you should create an S3 bucket in the same region that you are using for Amazon Rekognition, in our case is gonna be us-east-1, and you are going to use the name as default in the method definition.

```
[HttpGet("{photo}")]
public async Task<IEnumerable<Labels>> DetectLabels(string photo, string? bucket = "REPLACE-WITH-YOUR-BUCKET-NAME")
{
```

* Now, we are gonna initialize the Amazon Rekognition Client and set the region for us-east-1 as well as initialize the List that will contain the objects of Labels that we are going to use as output.

```
var rekognitionClient = new AmazonRekognitionClient(Amazon.RegionEndpoint.USEast1);
var responseList = new List<Labels>();
```

* We are going to prepare the payload for Amazon Rekognition to detect the labels from images stored on a S3 Bucket, and I will specify that I only need a maximum of 10 Labels per response (MaxLabels) and only the ones that have more than 80% of confidence (MinConfidence)

```
DetectLabelsRequest detectlabelsRequest = new DetectLabelsRequest()
{
    Image = new Image()
    {
        S3Object = new S3Object()
        {
            Name = photo,
            Bucket = bucket
        },
    },
    **MaxLabels** = 10,
    **MinConfidence** = 80F
};
```

* And finally, we are going to send the request asynchronously, and save just the Label name and probability inside our Labels List and finally return the list.

```
var detectLabelsResponse = await rekognitionClient.DetectLabelsAsync(detectlabelsRequest);
foreach (Label label in detectLabelsResponse.Labels)
    responseList.Add(new Labels{
        Name = label.Name,
        Probability = label.Confidence
    });
return responseList;
```

* The final PicturesController.cs should look like this:

```
using Microsoft.AspNetCore.Mvc;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Amazon.Rekognition;
using Amazon.Rekognition.Model;

namespace pictures.Controllers;

[ApiController]
[Route("api/[controller]")]
public class PictureController : ControllerBase
{
    [HttpGet("{photo}")]
    public async Task<IEnumerable<Labels>> DetectLabels(string photo, string? bucket = "")
    {
        var rekognitionClient = new AmazonRekognitionClient(Amazon.RegionEndpoint.USEast1);
        var responseList = new List<Labels>();

        DetectLabelsRequest detectlabelsRequest = new DetectLabelsRequest()
        {
            Image = new Image()
            {
                S3Object = new S3Object()
                {
                    Name = photo,
                    Bucket = bucket
                },
            },
            MaxLabels = 10,
            MinConfidence = 80F
        };
            
        var detectLabelsResponse = await rekognitionClient.DetectLabelsAsync(detectlabelsRequest);
        foreach (Label label in detectLabelsResponse.Labels)
            responseList.Add(new Labels{
                Name = label.Name,
                Probability = label.Confidence
            });
        return responseList;
    }
}
```

* Now we are going to edit the launchSettings.json inside the Properties folder and replace it by the following example. Here we are saying that we are going to use the port 5075 for HTTP only.

```
{
  "$schema": "https://json.schemastore.org/launchsettings.json",
  "iisSettings": {
    "windowsAuthentication": false,
    "anonymousAuthentication": true,
    "iisExpress": {
      "applicationUrl": "http://localhost:40317",
      "sslPort": 44344
    }
  },
  "profiles": {
    "pictures": {
      "commandName": "Project",
      "dotnetRunMessages": true,
      "launchBrowser": true,
      "launchUrl": "swagger",
      "applicationUrl": "http://localhost:5075",
      "environmentVariables": {
        "ASPNETCORE_ENVIRONMENT": "Development"
      }
    },
    "IIS Express": {
      "commandName": "IISExpress",
      "launchBrowser": true,
      "launchUrl": "swagger",
      "environmentVariables": {
        "ASPNETCORE_ENVIRONMENT": "Development"
      }
    }
  }
}
```

* We are gonna save everything and test it by running the following command in the Terminal:

```
dotnet run
```

* You should get something similar to this output, just clic or copy the URL.

```
info: Microsoft.Hosting.Lifetime[0]
Building...
info: Microsoft.Hosting.Lifetime[14]
Now listening on: [http://localhost:5075](http://localhost:5075/)
info: Microsoft.Hosting.Lifetime[0]
Application started. Press Ctrl+C to shut down.
info: Microsoft.Hosting.Lifetime[0]
Hosting environment: Development
```

* And let’s upload a picture into our S3 Bucket, for example in my case I uploaded 2.

![Picture of an S3 bucket console with files](images/05-04.jpg "Picture of an S3 bucket console with files")
* I’m going to compose the URL request using one of my pictures as example and paste it in the browser

```
[http://localhost:5075/api/pictures/1634160049537.jpg](http://localhost:5075/api/pictures/wendy.jpg)
```

* The result should look similar to this:

```
{
"name": "Furniture",
"probability": 99.809166
},
{
"name": "Cat",
"probability": 99.543724
},
{
"name": "Computer Keyboard",
"probability": 99.439415
},
{
"name": "Computer",
"probability": 99.439415
},
{
"name": "Electronics",
"probability": 99.439415
},
{
"name": "Table",
"probability": 98.87616
},
{
"name": "Glasses",
"probability": 98.35254
},
{
"name": "Desk",
"probability": 98.324265
},
{
"name": "Pc",
"probability": 90.02448
},
{
"name": "Monitor",
"probability": 90.019455
}
```

* And we have our hashtags ready for Picturesocial! If you wanna clone the whole API Project you can do it with the following command:

```
[git clone https://github.com/aws-samples/picture-social-sample/](https://github.com/aws-samples/picture-social-sample.git) -b ep5
```

If you get here that means that you are now using Artificial Intelligence services on AWS! In the next post we are going to learn about service integration and access at pod level using Kubernetes and IAM with Open ID Connect and we are going to deploy this API to Kubernetes! 
