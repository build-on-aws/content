---
title: "Build your own AI solution to learn faster using ChatGPT APIs and Open-Source ML models"
description: "A step-by-step guide how to setup a free ML Development environment, analyze YouTube videos with Open-Source ML models and ChatGPT APIs to become faster and more efficient in learning new skills."
tags:
    - tutorials
    - aws
    - generative-ai
    - chatgpt
    -hugging-face
authorGithubAlias: viktoriasemaan
authorName: Viktoria Semaan
date: 2023-07-31 (expected publication date)
---


## Frontmatter Instructions (remove this _Frontmatter Instructions_ section before authoring)

All frontmatter must be in [syntactically correct YAML](https://learnxinyminutes.com/docs/yaml/).

- `title` - the title of your post in quotes, less than 100 characters i.e. "What Happens When You Type a URL Into Your Browser" - Please put this inside double-quotes
- `description` - a description of your post used to surface a short description on the site and for SEO, less than 250 characters - Please put this inside double-quotes
- `tags` - help readers discover posts on the same topics. Use `kebab-case`.
- `authorGithubAlias` - your GitHub username
- `authorName` - how you want your name to display for the author credit of this post
- `date` - date this post is published in `YYYY-MM-DD` format. This does not effect when your post goes live and is purely for display purposes.

Introduction paragraph to the topic. Describe a real world example to illustrate the problem the reader is facing. Explain why it's a problem. Offer the solution you'll be laying out in this post.

<!-- Recommended to use future tense. e.g. "In this tutorial, I WILL be showing you how to do XYZ."  -->

## What you will learn

- How to get started SageMaker Studio Lab
- How to utilize pretrained open-source ML models
- How to use ChatGPT APIs

## Prerequisites

Before starting this tutorial, you will need the following:

 -  Foundational knowledge of Python

<!-- Update with the appropriate values -->
<!-- Please ensure tutorials are flagged as level 200 (intermediate) or higher -->
| Attributes                |                                   |
| ------------------- | -------------------------------------- |
| ✅ AWS Level        | Intermediate - 200                         |
| ⏱ Time to complete  | 30 minutes                             |
| 💰 Cost to complete | Free when using the OpenAI API credit or less than $0.10      |
| 🧩 Prerequisites    | - [SageMaker Studio Lab Account](https://studiolab.sagemaker.aws/)
line>)                             |
| 📢 Feedback            | <a href="https://pulse.buildon.aws/survey/DEM0H5VW" target="_blank">Any feedback, issues, or just a</a> 👍 / 👎 ?    |
| ⏰ Last Updated     | 2023-07-20                             |

| ToC |
|-----|
<!-- Use the above to auto-generate the table of content. Only build out a manual one if there are too many (sub) sections. -->

---
## Intro

When was the last time you had to watch YouTube to learn something? [A 2021 survey](https://www.techsmith.com/blog/video-statistics/) found that most respondents view videos 2-4 times per week and [a 2019 Google study](https://www.thinkwithgoogle.com/marketing-strategies/video/youtube-learning-statistics/) found that 86% of U.S. viewers say they often use YouTube to learn new things.

It comes as no surprise that you can find educational content on pretty much any topic on YouTube. From academic subjects like math and programming to hands-on projects, tutorials, and preparation for professional certifications, it's all there for anyone!

However, it's not perfect. Some videos have too many ad and sponsorship interruptions, some are too slow with lots of talking, while others are too fast, requiring you to pause to make sure you can follow the steps.

Imagine if you could get a concise video summary, review it to determine whether it's worth watching, extract step-by-step guidance so you could easily follow along, and at the end, generate a quiz to test your understanding. Wouldn't that be awesome?

In this tutorial, we will build exactly that!

I will walk you through a step-by-step process on how to configure a free ML development environment using SageMaker Studio Lab, integrate it with open-source ML models from Hugging Face, and use OpenAI's ChatGPT APIs.

You will be able to apply these steps to other use cases by selecting different models or adjusting prompts.


## Solution Overview

This tutorial consists of 4 parts:

* Part 1 - Setup: SageMaker Studio Lab and OpenAI account.
* Part 2 - Creating a ML project and obtaining a video transcript.
* Part 3 - Summarizing and translating a video using ML models from Hugging Face.
* Part 4 - Extracting steps and creating a quiz using ChatGPT APIs.


![Solution Architecture Oveview](images/intro-01.gif)

In Part 1, we will configure 2 prerequisites: accessing the [SageMaker Studio Lab Development](https://aws.amazon.com/sagemaker/studio-lab/) environment and creating [OpenAI API](https://platform.openai.com/docs/api-reference) keys for interaction with ChatGPT. What makes SageMaker Studio Lab special is that it is completely free and separate from an AWS account. If you’re new to machine learning, this free service is a fantastic way to get started. 

In Part 2, you will learn how to get started with a machine learning project that allows you to write code directly from your browser, eliminating the need for a local setup. You will also learn how to run the code on CPU or GPU cloud instances. We will create a notebook, install libraries, and start experimenting.

In Part 3, you will learn how to use Open Source models from the [Hugging Face Hub](https://huggingface.co/models) for inference. We will utilize pretrained sequence-to-sequence models to [summarize](https://huggingface.co/tasks/summarization) YouTube transcripts and [translate](https://huggingface.co/learn/nlp-course/chapter7/4?fw=tf) them to a different language.

In Part 4, we will experiment with ChatGPT APIs. We will discuss prompt engineering and leverage the ChatGPT APIs to generate a step-by-step guide from a YouTube video. Additionally, we will create a quiz to test your understanding of the material.

> Note: We will be using free resources in this tutorial.  The only potential cost that you may incur is for utilizing ChatGPT APIs if you already consumed all free credits and it will be a few cents. When you create an OpenAI account, you will be given $5 to use within the first 3 months.  This is enough to run hundreds of API requests.

Let’s get started!

## Part 1 - Setup: SageMaker Studio Lab and OpenAI account.

To get started, go to the [Studio Lab landing page](https://studiolab.sagemaker.aws/) and click **Request free account**. Fill in the required information in the form and submit your request. You will then receive an email to verify your email address. Follow the instructions in the email to complete this step.

> Please note that your account request needs to be approved before you can register for a Studio Lab account. The review process typically takes up to 5 business days. Once your account request is approved, you will receive an email containing a link to the Studio Lab account registration page. This link will remain active for 7 days after your request is approved, so make sure to submit a new account request within this timeframe if needed.

![SageMaker Studio Lab Sign up](images/part1-01.gif)

To integrate and use Open AI models into your application, you need to register an [OpenAI account](https://platform.openai.com/signup/). Once you have completed the registration and sign-up process, you will need to create an API key. This API key is essential as it enables you to send requests to OpenAI from third-party services.

Navigate to [OpenAI API keys](https://platform.openai.com/account/api-keys) page and click on **Create new secret key**, provide name, copy the key and save it. You won’t be able to access the key again!


> Please note that the ChatGPT API currently offers a $5 credit for new users, allowing you to start experimenting with the API at no cost. This credit is available for use during the first 3 months of your account. After the initial 3-month period, the pricing will transition to a pay-as-you-go model. To get detailed information about the rates and pricing structure, I recommend visiting the pricing page on the OpenAI website.

You can set usage limits and monitor your current usage by visiting the [Usage Limits page](https://platform.openai.com/account/billing/limits). 

![OpenAI API key creation](images/part1-02.jpg)

In this tutorial, we will be utilizing the [GPT-3.5 Turbo](https://platform.openai.com/docs/guides/gpt/chat-completions-api) model. As shown in the table below, API calls for this model are priced at a fraction of a cent. With the free credit of $5, you will be able to run hundreds of experiments at no cost.


┌─────────────┬─────────────────────────┬───────────────────────┬
│ Model       │ Input                   │ Output                │
├─────────────┼───────────────── ───────┼───────────────────────┼
│ 4K context  │ $0.0015 / 1K tokens     │ $0.002 / 1K tokens    │
├─────────────┼─────────────────────────┼───────────────────────┼
│ 16K context │ $0.003 / 1K tokens      │ $0.004 / 1K tokens    │
└─────────────┴─────────────────────────┴───────────────────────┴

*Model*	*Input*	*Output*
4K context	$0.0015 / 1K tokens	$0.002 / 1K tokens
16K context	$0.003 / 1K tokens	$0.004 / 1K tokens

## Part 2 - Creating a ML project and obtaining a video transcript.

Once you have obtained access to the Studio Lab, sing in to [Amazon SageMaker Studio Lab](https://studiolab.sagemaker.aws/).

Under **My Project**, you can select a compute type and start project runtime based on an EC2 instance. Studio Lab provides the option to choose between a CPU (Central Processing Unit) designed for compute intensive algorithms and a GPU (Graphical Processing Unit) which is recommended for deep learning tasks, particularly transformers and computer vision.

We will use the CPU option because it give us 8 hours per day to experiment compared to the GPU option with a 4-hour daily limit. Click **Start runtime**. The click button **Open project**. You may be required to solve a CAPTCHA puzzle when you start runtime.

![Studio Lab - New Project](images/part2-01.jpg)

A project contains files and folders, including Jupyter notebooks. You have full control over the files in your project. The image below shos the Studio Lab Launcher. Click **on default: Python** under Notebook. A new notebook will be created. 

Let’s give a notebook a name and save it. From the Studio Lab menu, choose **File**, choose **Save File As**, and then choose folder and give it name. For example, `learn-with-ai.ipynb`

![Studio Lab - Create Python Notebook](images/part2-01.jpg)


<!-- Recommended to use present tense. e.g. "First off, let's build a simple application."  -->

<!-- Sample Image link with required images/xx.xxx folder structure -->
![This is the alt text for the image](images/where-this-image-is-stored.png)
<!-- Alt text should provide a description of the pertinent details of the image, not just what it is, e.g. "Image of AWS Console" -->

<!-- Sample Image link with a caption below it, using required images/xx.xxx folder structure -->
![This is the alt text for the image with caption](images/where-this-image-is-stored.png "My image caption below")

<!-- Code Blocks -->
Avoid starting and ending the code blocks with blank lines/spaces. Remember to include the language type used when creating code blocks. ` ```javascript `.
For example,

```javascript
this is javascript code
```

If you want to share a code sample file with reader, then you have two options:
- paste the contents with code blocks like mentioned above
- provide link to the file. Use the raw file content option on GitHub (without the token parameter, if repo is private while drafting). It should look like:   
    `https://raw.githubusercontent.com/ORGANIZATION/REPO-NAME/main/FOLDER/FILENAME.EXTENSION`
    Example:
     _You can also copy-paste contents of this file from [here](https://raw.githubusercontent.com/build-on-aws/aws-elastic-beanstalk-cdk-pipelines/main/lib/eb-appln-stack.ts)._


## Clean up

Provide steps to clean up everything provisioned in this tutorial. 

## Conclusion

<!-- Recommended to use past tense. e.g. "And that's it! We just built and deployed that thing together!"  -->

Provide a conclusion paragraph that reiterates what has been accomplished in this tutorial (e.g. turning on versioning), and what its value is for the reader (e.g. protecting against loss of work). If it makes sense, tie this back to the problem you described in the introduction, showing how it could be solved in a real-world situation. 

Identify natural next steps for curious readers, and suggest two or three useful articles based on those next steps.

Also end with this line to ask for feedback:
If you enjoyed this tutorial, found any issues, or have feedback for us, <a href="https://pulse.buildon.aws/survey/DEM0H5VW" target="_blank">please send it our way!</a>
