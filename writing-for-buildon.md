---
layout: blog.11ty.js
title: How to Write for BuildOn
description: This post describes how to publish to this blog step by step
hero: https://images.unsplash.com/photo-1522675378431-f2c7406d4173?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=2000
heroCropMode: bottom
heroColor: dark
tags:
  - tutorial
  - BuildOn
---
# Want to Write for this Blog?
Welcome! Thank you for your interest in contributing to BuildOn. You can have your content published through five simple steps:
## 0. Open a Content Proposal issue
 Open a [Content Proposal issue](https://github.com/nazreen/eureka-content/issues/new?assignees=jennapederson&labels=content+proposal&template=content-proposal-template.md) first. Once your proposal is approved, you can carry on to the next steps.

## 1. Pick a Title, Description, and Hero Image
Open [this GitHub Repository](https://github.com/nazreen/eureka-content) and click "Create new file"

![Screenshot of creating a new file in the repository](/images/create-new-file.png)

Name your file something like `my-first-blog-post/index.md`. Make sure you create a folder and **make sure the file ends in `.md` or else your content will not be processed correctly**. At the top of your file, copy and paste the following lines:

```
---
layout: blog.11ty.js
title: How to Publish Your Content
description: This post describes how to publish to this blog step by step
hero: https://images.unsplash.com/photo-1522675378431-f2c7406d4173?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=2000
heroCropMode: bottom
heroColor: dark
tags:
  - tutorial
  - BuildOn
authorGithubAlias: nazreen
authorName: Nazreen Mohamad
date: 2016-01-31
---
```

This will create a special header for your blog post called the "Front Matter". The Front Matter specifies things like your blog layout, title, description, and banner image. 

- `heroCropMode` determines which part of the image to use. It can be `bottom`, `top`, or `center`
- `heroColor` describes the over all color of your banner image and it can be `light` or `dark`. We will choose a foreground text color to maximize contrast and readability. 
- Try to choose a banner image that has relatively smooth colors and transitions. 
- `tags` help readers to discover posts across the same topics or themes

You can check out the [source code for this blog post](https://github.com/nazreen/eureka-content/blob/fab4a7da656b8a57d966bfed25ff2fd3be07354e/images/index.md) for reference.

## 2. Write your Blog in Markdown

Next, write some Markdown and use the "Preview" button in the editor to preview your work. Here's a handy Markdown cheat sheet: https://www.markdownguide.org/basic-syntax/.

If you don't want to start from scratch, you can copy the Markdown for [the content you're reading right now](https://github.com/nazreen/eureka-content/blob/main/README.md)

![Screenshot of naming and editing a new markdown file](/images/write-markdown.png)

## 3. Create a Pull Request

Once your blog post is ready, scroll to the bottom, write a message and description for your commit, and select "Create a new branch...". Then click "Propose new file"

![Screenshot of proposing a new file](/images/propose-new-file.png)

## 4. Wait for review and publication

Our editors will review your content as soon as possible. If they request any changes, you will be notified via the Pull Request (so make sure you've enabled notifications!). Thank you for your contribution! Take the day off and go pet some animals. 

![Cute puppy](/images/puppy.jpg)
