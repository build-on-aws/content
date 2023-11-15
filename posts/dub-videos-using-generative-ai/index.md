# Outline blog post about AI and Serverless

## Title: I Built an App to Dub Videos Using AI

Dek: AI tools can feel overwhelming, but they’re basically just new endpoints to call. Here’s what I built to help serve my Spanish-speaking audience.
[Image: AdobeStock_627759652.jpeg](licensed from Adobe Stock)

Twenty years into working as a software developer, the rise of AI — and the headlines about how it might transform the role of the developer — made me anxious. I didn’t want to transition into a machine learning role; I didn’t want to learn how to tune models or build them, how to clean data. I love to build applications!

Don’t get me wrong: I was happy to use AI-based developer tools to improve my productivity as a developer. These tools enable greater efficiency, just like the higher level programming languages that developers began to prefer to machine level programming languages like Assembler. Using Amazon CodeWhisperer, for example, made me 50% more productive, as now I no longer needed to leave the IDE to find answers to my coding questions.

But as I thought about AI more, I realized the opportunity it presents to developers: in this new world, we will need applications that solve new problems. As developers, we are going to get a lot of requests in the future to build apps that can recognize objects in images, that can understand and process natural language, that can create text, music or images, that can make recommendations based on data, that can answer questions, and many other things.

This new technology can feel overwhelming, so as an experiment, I decided to build an application with it — an application that dubs videos from English to Spanish using AI APIs. I learned a lot along the way.

## A Quick Overview of the AI Service Landscape

Before I started building the application, I wanted to understand the kinds of tools that help build AI applications, and there are a surprising number of options in the AI landscape today. AWS, for example, offers many AI managed services, like Amazon Transcribe, Amazon Translate, Amazon Rekogniton, Amazon Polly — to generate audio from text, Amazon Textract, and Amazon Comprehend. In addition, if you are working in a bigger org with an ML team, you can take advantage of the custom-made solutions built in Amazon SageMaker. For a lot of the problems that require Generative AI, AWS offers Amazon Bedrock. 

Amazon Bedrock is a fully managed service that makes Foundational Models (FMs) from leading AI startups and Amazon available via an API, so you can choose from a wide range of FMs to find the model that is best suited for your use case. It is the easiest way to build and scale generative AI applications with FMs. When using Bedrock, you can choose your FM from: Jurassic 2 from AI21 Labs, Claude form Anthropic, Stable Diffusion from Stability AI and Titan and Titan Embeddings from Amazon.

And finally in the AI Landscape we can find all the APIs third party companies offer that provides different models and solutions for specific problems. 
[Image: Screenshot 2023-09-20 at 14.08.23.png]
After analyzing the AI landscape, my first realization was that you mostly just need to know how to call an endpoint. But calling some of these endpoints isn’t as simple as using a REST API. For the Generative AI ones you need to define a prompt.

That’s another skill that to learn: prompt engineering helps you to write prompts to the generative AI endpoints to request the right data. Generative AI endpoints don’t return the same response twice, and fine tuning the prompt to consistently get the right answer in the right format is a critical skill.

Another important skill is how to orchestrate and choreograph the endpoint calling. Usually calling one service is not enough to solve a problem; you need to call 2, 3, or more services and transform the data in between to obtain the expected result. So learning patterns that help you to solve this problem is handy. 

With those basic skills in mind, here’s how I got started building my application.

## Automatic video dubbing using AI

In our everyday work as developer advocates, my colleagues and I create a lot of videos. However, I’m the only Spanish speaker on the team and I want to share as much information as I can with my Spanish community as possible. But I don’t have the time to record all my videos in English and Spanish. So I thought, why not use AI to solve this problem?

The idea is this: a video in English is uploaded to an Amazon S3 bucket, and then automatically it gets dubbed into Spanish and the title, description, and tags for YouTube all get created in Spanish based on the content of the video. And when everything is ready, I receive an email with all the assets.  
[Image: Screenshot 2023-09-20 at 14.19.36.png]
This sounds like a great idea, but after trying this for a while, I realized that this process needed some validations in the middle in order to ensure really good results. Let’s see how this is built using AWS serverless services.

But first you can take a look at this video that should the solution to the problem.
*<cannot upload the video to quip as it is too big → LINK: https://amazon.awsapps.com/workdocs/index.html#/document/dedd369790c883561152cd591eaaf8def6937f324fd8f71f330c0dbfc519fb28>*

### High level architecture

For solving this problem I created 4 state machines using AWS Step Functions. Each state machine solves a specific problem to solve the problem and allows a human to get in the middle of the process to do the validation of the generated assets. 
[Image: Screenshot 2023-09-29 at 11.11.58.png]
Each state machine is triggered when there is a new file in an S3 bucket using an Amazon EventBridge rule, and the state machine stores a file in another S3 bucket and sends an email that the process was completed with a link to the object in S3.

This solution is based on the orchestration and choreography patterns. Orchestration is a pattern that helps you to organize tasks that need to execute in a strict order, and you need to have full control on what is going on in the process, you need to know the state for that process all the time. In orchestration solutions there is a main component that is overseeing the process and controlling the state. To implement this pattern in AWS, one simple solution is to us AWS Step Functions. 

AWS Step Functions is a fully managed service that offers managed state machines. A state machine is a set of discrete computational steps, each step with a defined input and output. The state machine has transitions that are defined based on the data or based in logic built in the state machine. 

When using Step Functions you don’t need to write almost any code, as it supports direct integration with over 200 AWS services. And when these state machine run you can get a detail view of each of the inputs and outputs of each state for each execution of the state machine. 

Let’s look a bit more in detail each of the state machines and check how they are built.

### Transcribe state machine

The first state machine to run is the one that is in charge of transcribing the original video. This state machine as the others, gets triggered when there is a new file in an S3 bucket. Then it calls Amazon Transcribe, an AI service that will do the transcription for us. This process is asynchronous so we add a wait loop in the state machine to wait for the transcription to complete. 

When the transcription is ready, the file gets stored in the correct format in S3 and an email is sent to the end user, to get the validation. Amazon Transcribe is a great service, but in order to get the best end result possible, having a human validate the transcription is very important. 

[Image: Screenshot 2023-10-05 at 16.42.22.png]A couple of things you can see in this state machine that you will also see in the other state machines. 


1. **The state machine is triggered by an event.** It is very simple to define that using EventBridge rules when you create the state machine. Here you can see an example using AWS SAM.

[Image: Screenshot 2023-10-05 at 16.45.53.png]
1. **Most of the logic of this state machine is by calling the AWS Services directly**. This is done by using the direct integration that AWS Step Functions provides with over 200 services. In the following example, you can see how you can start a transcription job directly from the state machine, and you can pass all the parameters. This example is written with Amazon State Language (ASL), the language you use to define state machines. 

```
TranscribeVideo:
    Comment: 'Given the input video starts a transcription job'
    Type: Task
    Next: WaitForTranscribe
    Resource: 'arn:aws:states:::aws-sdk:transcribe:startTranscriptionJob'
    Parameters:
      Media:
        MediaFileUri.$: States.Format('s3://{}/{}', $.detail.bucket.name, $.detail.object.key)
      TranscriptionJobName.$: $$.Execution.Name
      OutputBucketName: ${TranscribedBucket}
      OutputKey.$: States.Format('{}.txt', $.detail.object.key)
      LanguageCode: en-US
```

1. **The use of AWS Step Function intrinsic functions:** Intrinsic functions help you to perform basic data processing operations without using a task. You can manipulate arrays, strings, hashes, create unique Ids, base64 decode or encode and many other operations directly from the state machine. When ever you see the `States.XXX`, this means that an intrinsic function is being used. The following example uses intrinsic functions two times nested, when creating the key for the object to store in S3, it first split a string (`States.StringSplit`) and then it gets the element in the third place (`States.ArrayGetItem`)

```
Store Transcript in S3:
    Type: Task
    Next: FormatURI
    Resource: arn:aws:states:::aws-sdk:s3:putObject
    ResultPath: $.result
    Parameters:
      Bucket: ${TranscribedBucket}
      Key.$: States.ArrayGetItem(States.StringSplit($.TranscriptionJob.Transcript.TranscriptFileUri, '/'),3)
      Body.$: $.transcription.filecontent.results.transcripts[0].transcript
```

### Translate state machine

When the end users uploads a validated transcription file to an S3 bucket then the second state machine starts. This is the translation state machine. This state machine is very similar to the previous one but instead of calling Amazon Transcribe, it calls Amazon Translate. The call here is synchronous that is why the response comes right away to the next step. 

You can see in this state machine that there are some components that are being reutilized, like the SNS topic and the Lambda function that signs the S3 URL.
[Image: Screenshot 2023-10-05 at 16.55.35.png]When this state machines completes, it uploads a translated file to S3 and sends and email to the user to validate the translation

### Dubbing the video

When the user uploads a validated translation, two state machines will get triggered at the same time. One is the state machine that dubs the video and the other one is the one that generate the title, description and tags. The state machine that dubs the videos looks very similar to the previous state machines, the differences are that first it calls asynchronously Amazon Polly to transform the translated text file into audio, and then it calls an AWS Lambda function that will replace the audio track of the original video with the new translated one. 
[Image: Screenshot 2023-10-06 at 10.37.21.png]This Lambda function uses a library called [ffmpeg](https://ffmpeg.org/) to achieve this. And its one of the few functions that you will find in the project. This function takes care of replacing the original audio of the video with the new translated audio from Polly and store it in S3. 

### Generating the assets 

The last state machine is the one that generates the titles, descriptions, and tags of the video. This state machine looks similar than the previous one, but the Lambda function that it contains calls Amazon Bedrock.
[Image: Screenshot 2023-10-06 at 11.37.31.png]Amazon Bedrock is the easiest way to build and scale generate AI applications using foundational models. This Lambda function uses the AWS SDK to call Bedrock and to generate the assets needed to upload this video to social media. 

Using Bedrock from a Lambda function is very simple. The first step is to give permissions to the function to access Bedrock. You can see how the function is defined using AWS SAM.

```
GenerateVideoMetadataFunction:
    Type: AWS::Serverless::Function
    Properties:
      CodeUri: src/
      Handler: index.lambda_handler
      Runtime: python3.9
      MemorySize: 128
      Timeout: 600
      Policies:
        - Statement:
            - Effect: Allow
              Action: 'bedrock:*'
              Resource: '*'
```

Then you can write the function code. This particular function takes as an input the translated transcription of the video, and returns the title, description, and tags based on that information. This function is using the foundational model from AI21 Jurassic Ultra. 

```

import boto3
import json
import os 

bedrock = boto3.client(service_name='bedrock-runtime')

def lambda_handler(event, context):

    key = event['detail']['object']['key']    
    key = key.split('/')[1]

    prompt="Given the transcript provided at the end of the prompt, return a JSON object with the following properties: description, titles, and tags. For the description write a compelling description for a YouTube video, that is maximum two paragraphs long and has good SEO. Don't focus on the person who is mentioned in the video, just focus on the content of the video. The description should be in the same language as the video. For the title, return an array of 5 different title options for this video. For the tags, provide an array of 20 tags for the video. Here is the transcript of the video: {}".format(event['body']['filecontent'])

    body = json.dumps({
        "prompt": prompt,
        "maxTokens": 1525,
        "temperature": 0.7,
        "topP": 1,
        "stopSequences":[],
        "countPenalty":{"scale":0},
        "presencePenalty":{"scale":0},
        "frequencyPenalty":{"scale":0}})
    modelId = 'ai21.j2-ultra-v1'
    accept = 'application/json'
    contentType = 'application/json'

    response = bedrock.invoke_model(body=body, modelId=modelId, accept=accept, contentType=contentType)

    response_body = json.loads(response.get('body').read())
    
    description = json.dumps(response_body.get("completions")[0].get("data").get("text"))

    result = {"key": key, 
              "description": description, 
              "region": os.environ['AWS_REGION']
              }

    return result
```

The parameters and prompts for this function you can test them in the Bedrock playground that makes it super easy to tune the amount of tokens you need, fine tune the prompt to obtain the correct result, and do any extra configuration you need in the call. 

After you have the right settings in the Bedrock playground, you can click the “View API request” button and you will get all the parameters you will need to configure in your API call when writing your function. 
[Image: bedrock-demo.mp4]
## Conclusion

At the end of the day, even the most advanced AI tools are just endpoints. This mindset helped me build an incredibly useful application — not as a ML engineer, but as a software developer!

After this experiment I’m less afraid of the future that AI brings to developers, as these new AI services are just tools to build applications. One interesting thing I noticed is if you provide longer or overly complicated prompts to a generative AI model the results are not great. Therefore when when you use gen AI, you need to make a very clear prompt and that can be used for a specific task. This means that you need to split that long prompt into shorter ones and then chain the results toghether to get best results, this is called prompt chaining. For prompt chaining the orchestration pattern and Step Functions are very useful. 

You can find the code for this application in GitHub and more information regarding building applications with AI in this [link](https://s12d.com/serverlessAI).






EARLIER VERSIONS:

I have 20 years of experience as a developer, and last year when the generative AI boom started I had a lot of thoughts about how relevant my job will be in the next years. There were so many news and headlines about the role of developers with AI, what we would need to learn, and how our jobs will change. All these news made me very anxious and I started thinking and chatting with colleagues about what would be the future of devs and what skills would keep us relevant for the foreseeable future. 

I was very sure that I didn’t want to change my developer career into a ML role, i didn’t want to learn how to tune models or build them, how to clean data. I love building applications.

During this thinking process I realised that there are 2 main things that we need to have in mind as developers. First is to learn how to use all the new AI based Developer tools and then how to build applications that can take advantage of the AI landscape. 

### AI Developer tools

The first thing we need to learn as developers that want to survive in this AI craziness is the new developer tools. These AI based developer tools, helps us to improve our productivity and make us relevant in the software industry. If we don’t learn these tools we will be less productive than our counterparts that are using them. 

I see this trend as when developers starting adopting higher level programming languages instead of machine level programming languages like Assembler. These more modern developers were more productive as they we taking advantage of all the abstractions that these newer programming languages were offering them. 

One example of AI developer tool that I think is a game changer is, Amazon CodeWhisperer. Amazon CodeWhisperer is a AI coding companion that you add to your IDE. CodeWhisperer generates code suggestions based on what you are typing right now, and those suggestions are following the same coding conventions that your previous code has. In addition, CodeWhisperer scan the code for known vulnerabilities and flag code that resembles open-source data. In my experience CodeWhisperer made me 50% more productive, as now I don’t need to leave the IDE to find answers to my coding questions, like how to use some API or how to build some AWS CDK construct. This is a huge advantage in my productivity as now I can use that spare time to complete other tasks. 


### Building apps to solve AI problems

The second problem that developers need to tackle to stay relevant in this new world, is how to build apps that solve AI problems. As developers we are going to get a lot of requests in the future to build apps that can recognize things in images, that can understand and process natural language, that can create text, music or images, that can make recommendations based on data, that can answer questions, or many other things. 

If we think about these kind of applications and what kind of tools we need to build them, today we have a big offerening in the AI landscape. AWS offers many AI managed services, like Amazon Transcribe, Amazon Translate, Amazon Rekogniton, Amazon Polly, to generate audio from text, Amazon Textract, and Amazon Comprehend. In addition if you are working in a bigger org with a ML team you can take advantage of the custom made solutions built in Amazon SageMaker.For a lot of the problems that require Generative AI, AWS offers Amazon Bedrock. 

Amazon Bedrock is a fully managed service that makes Foundational Models (FMs) from leading AI startups and Amazon available via an API, so you can choose from a wide range of FMs to find the model that is best suited for your use case. It is the easiest way to build and scale generative AI applications with FMs. When using Bedrock, you can choose your FM from: Jurassic 2 from AI21 Labs, Claude form Anthropic, Stable Diffusion from Stability AI and Titan and Titan Embeddings from Amazon.

And finally in the AI Landscape we can find all the APIs third party companies offer that provides different models and solutions for specific problems. 



I hope that after reading this article you got inspired to try some AI managed services and to build your own AI applications, because at the end of the day everything is an endpoint. 

Don’t forget to embrace patterns like orchestration and choreography in your applications. Choreography to react to events that are happening in your application, like a new file was uploaded to S3 or an user completed some task. EventBridge rules are great to use for this particular solution, as they can help you to trigger lots of different things when something ocurrs in the system or an application event is raised.

Use orchestration to coordinate tasks that need to occur in a specific order. Try to avoid making overly complex Lambda functions and embrace Step Functions, for this purpose. Step Functions provides a lot of features that will make your application simpler to debug and to maintain in the long run. Use Lambda functions for operations that are very specific to your application, that you cannot achieve from a state machine, or that require a lot of business logic. 

You can find the code for this application in GitHub and more information regarding building applications with AI in this [link](https://s12d.com/serverlessAI).
