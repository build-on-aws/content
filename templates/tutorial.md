---
title: "<Highlight the core problem being solved, follow PR/marketing guidelines>"
description: "<Two or three sentences describing the problem, the solution, and tools or services used along the way>"
tags:
    - tutorials
    - <tutorials tag is mandatory for tutorials. list any other key terms readers will be searching for using kebab-case, e.g. ci-cd, NOT "ci cd", or "CI-CD">
    - essentials
    - aws
authorGithubAlias: <github alias>
authorName: <FirstName LastName>
date: <YYYY-MM-DD - expected publish date>
---
## Frontmatter Instructions (remove this _Frontmatter Instructions_ section before authoring)

All frontmatter must be in [syntactically correct YAML](https://learnxinyminutes.com/docs/yaml/).

- `title` - the title of your post in quotes, less than 100 characters i.e. "What Happens When You Type a URL Into Your Browser" - Please put this inside double-quotes
- `description` - a description of your post used to surface a short description on the site and for SEO, less than 250 characters - Please put this inside double-quotes
- `tags` - help readers discover posts on the same topics. Use `kebab-case`.
- `authorGithubAlias` - your GitHub username
- `authorName` - how you want your name to display for the author credit of this post
- `date` - date this post is published in `YYYY-MM-DD` format. This does not effect when your post goes live and is purely for display purposes.



<!-- Throughout this template there will be comments like these, please remove them before committing the first version of the content piece. -->

Introduction paragraph to the topic. Describe a real world example to illustrate the problem the reader is facing. Explain why it's a problem. Offer the solution you'll be laying out in this post.

<!-- Recommended to use future tense. e.g. "In this tutorial, I WILL be showing you how to do XYZ."  -->

## What you will learn

- Bullet list
- with what you will
- learn in this tutorial

## Prerequisites

Before starting this tutorial, you will need the following:

 - An AWS Account (if you don't yet have one, you can create one and [set up your environment here](https://aws.amazon.com/getting-started/guides/setup-environment/)).
 - <!-- any other pre-requisites you will need -->

## Sections
<!-- Update with the appropriate values -->
| Attributes                |                                   |
| ------------------- | -------------------------------------- |
| ✅ AWS Level        | 100 - Beginner                          |
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
