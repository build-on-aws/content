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

- Bullet list
- with what you will
- learn in this tutorial

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
