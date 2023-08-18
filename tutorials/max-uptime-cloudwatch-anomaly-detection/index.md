---
title: "How to maximize application uptime using CloudWatch Anomaly Detection"
description: "Use CloudWatch anomaly detection machine learning to ensure application uptime"
tags:
    - tutorials
    - aws
    - list-of-other-tags-as-kebab-case-like-this-with-dashes-separating-and-all-lower-case-like-below
    - tag-1
    - tag-2
authorGithubAlias: jtwardos
authorName: John Twardos (no quotes around)
date: 2023-09-DD (expected publication date)
showInHomeFeed: true
---

Have you ever tried to access your favorite application, and instead you were greeted by an error? As you refresh multiple times, you are left with a feeling of disappointment and decide to move on to something else. That split second of application downtime can result in a lost customer, a missed sale, and ultimately lost revenue. What if there is a way to monitor your application to prevent downtime, and do it in a way that requires minimal setup and ongoing maintenance? 

In this post I will show you how to enable and configure CloudWatch anomaly detection so you can spend more time developing your application and less time on maintenance.

## What you will learn

- How to enable CloudWatch anomaly detection
- How to create alarms and actions in CloudWatch

## Prerequisites

| Attributes                |                                   |
| ------------------- | -------------------------------------- |
| ✅ AWS Level        | Intermediate - 200                         |
| ⏱ Time to complete  | 15 minutes                             |
| 💰 Cost to complete | Free when using the AWS Free Tier or USD 1.01      |
| 🧩 Prerequisites    | - [AWS Account](https://aws.amazon.com/resources/create-account/?sc_channel=el&sc_campaign=devopswave&sc_content=cicdetlsprkaws&sc_geo=mult&sc_country=mult&sc_outcome=acq)<br>- [CodeCatalyst Account](https://codecatalyst.aws?sc_channel=el&sc_campaign=devopswave&sc_content=cicdetlsprkaws&sc_geo=mult&sc_country=mult&sc_outcome=acq) <br> - If you have more than one requirement, add it here using the `<br>` html tag|
| 💻 Code Sample         | Code sample used in tutorial on [GitHub](<link if you have a code sample associated with the post, otherwise delete this line>)                             |
| 📢 Feedback            | <a href="https://pulse.buildon.aws/survey/DEM0H5VW" target="_blank">Any feedback, issues, or just a</a> 👍 / 👎 ?    |
| ⏰ Last Updated     | YYYY-MM-DD                             |

| ToC |
|-----|
<!-- Use the above to auto-generate the table of content. Only build out a manual one if there are too many (sub) sections. -->

---
## <Title of Section 1 - please note that it starts with a double `##`>

From here onwards, split the tutorial into logical sections with a descriptive title. Focus titles on the core action steps in each section.

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
