# Quick Start

Interested in contributing content? Get started quickly:

* [What We're Looking For](#what-were-looking-for)
* [Writing Style](#writing-style)
* [Publishing Process](#publishing-process)
  * [0. Pre-Requisites](#0-prerequisites)
  * [1. Submit a Content Proposal](#1-submit-a-content-proposal)
  * [2. Proposal Review](#2-proposal-review)
  * [3. Write Your First Draft](#3-write-your-first-draft)
  * [4. Submit Pull Request for Review and Publishing](#4-submit-pull-request-for-review-and-publishing)
  * [5. Address Review Feedback](#5-address-review-feedback)
  * [6. Do NOT Share Your Content Yet](#6-do-not-share-your-content-yet)
* [The Legal Details](#the-legal-details)
* [Frequently Asked Questions](#frequently-asked-questions)

## What We're Looking For

:warning: January 27, 2023: Community content contributions are invite-only right now as we gather feedback and refine the publication processes and documentation. Star or watch [this repository](/) for updates as we open this up to more community authors in the coming months.

### Who Writes on BuildOn

We are looking for people with technical knowledge to write about their experiences, share their opinions, and help others in the community. We publish content from authors who want to share their challenges (and helpful hints) to learning a programming language, a dive deep into why it's always DNS, best practices on building microservices architectures, and more.

### What Topics We’re Looking For

Content may be about programming languages (JavaScript, C#, Python, C#, etc), address generic topics about a category (compute, database, machine learning, networking, cloud) or a particular technology (Docker, Javascript, BGP, TLS1.3), or help a builder solve a problem they are facing.

Not sure what to write about? Check out our idea backlog [here](https://github.com/build-on-aws/content/issues?q=is%3Aopen+is%3Aissue+label%3A%22help+wanted%22).

## Writing style

Content is original and has a friendly style. Our content reviewers will help you make sure your content is in this style so you can build trust and rapport with the technical community.

## Republishing content from other platforms

We are accepting limited republishing requests for content from other platforms at this time, please submit [a request](LINK TBD) to republish. Please note that you need to be the original author for the content piece, and if accepted, we will set up a canonical link for the content piece to point to the original location as the source of truth.

### Be You

Content published comes from you, a human, not you, a company. Content that comes from a human will build trust and be more authentic than content that comes from a brand and goes through a PR review. This content will incorporate your personal stories and experiences. Our editorial process focusses on helping you improve the quality of your piece, and not reshaping it.

### Conversational

Our content is conversational, as if you were explaining technical topics to your friend or a colleague.

### Have an Opinion

Share your opinions and back it up with sound reasoning. Not only will this build trust with the reader, but it will help readers make decisions that work best for their situation. It’s okay to say, “I would start with Fargate because X, Y, Z” or “Are you sure you need containers right now?”. Don’t give non-answers like “EKS, ECS, and Fargate all have their strengths and weaknesses” because that is not helpful to the reader.

### Educational and Useful

Readers are looking for content that helps them solve a problem. Your number one job is to help the reader, by providing expert guidance, backed by strong reasoning and a deep understanding of the problem.

### Clear and Concise

Content is focused and doesn't ramble. Each word, each sentence is necessary to get your point across. You choose words that are simple, not clever and avoid cultural idioms. Complex ideas are explained clearly and concisely, using images, illustrations, and examples to get the point across.

### What It Isn't

The content is not your traditional marketing content. It doesn't try to sell readers a product or service and it's not clickbait. Calls-to-action are allowed but content doesn't prioritize them over helping the reader solve a problem.

### Examples

Wondering what type of content fits this content platform? Here are some examples written by the AWS Developer Relations team.

* [What happens when you type a URL into your browser?](https://aws.amazon.com/blogs/mobile/what-happens-when-you-type-a-url-into-your-browser/)
* [Four Reasons Why GraphQL Is The Future](https://www.buildon.aws/posts/four-reasons-why-graphql-is-the-future/)
* [Topic or a Queue - What exactly is Apache Kafka?](https://www.buildon.aws/posts/kafka-topic-or-queue/)
* [10 Ways to Use Serverless Functions](https://dev.to/aws/10-ways-to-use-serverless-functions-bme)
* [Protecting from vulnerabilities in Java: How we managed the log4j crisis](https://medium.com/i-love-my-local-farmer-engineering-blog/protecting-from-vulnerabilities-in-java-how-we-managed-the-log4j-crisis-68d3e90a7586)
* [How to debug machine learning models to catch issues early and often](https://towardsdatascience.com/a-quick-guide-to-managing-machine-learning-experiments-af84da6b060b)

## Publishing Process

### 0. Prerequisites

You'll need to meet the following prerequisites to publish your content:

* Have a [GitHub SSH key](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent) or [personal access token](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token) setup for your GitHub account
* Have a Markdown editor or compatible IDE for writing and previewing your markdown content (e.g. VSCode, IA Writer, Obsidian, IntelliJ, etc.). We recommend installing a plugin / extension for your IDE to help with Markdown & Yaml syntax, as well as a spell checker.

### 1. Submit a Content Proposal

Before writing your content, submit a content proposals as a GitHub Issue in [content](/) repository [here](https://github.com/build-on-aws/content/issues/new?assignees=cherbk&labels=content+proposal&template=content-proposal-template.md).

### 2. Proposal Review

During the proposal review phase, we will look for the following in your proposal:

* ensure content topic aligns with the target audience (fellow builders)
* content topic is educational and useful

When your proposal has been reviewed, a reviewer will label your issue with `accepted`, `change requested`, or `rejected`. Once `accepted`, you can continue to step 3 to Write Your First Draft.

### 3. Write Your First Draft

After your content proposal has been `accepted`, you are ready to start writing. The contribution model used is similar to opensource projects:

1. You create a [fork](https://docs.github.com/en/get-started/quickstart/fork-a-repo) of the `/content` repo into your personal account
2. You create a [branch](https://docs.github.com/en/get-started/quickstart/github-flow#create-a-branch) per content piece
3. When you are ready, create a [Pull Request (PR)](https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/proposing-changes-to-your-work-with-pull-requests/creating-a-pull-request) from that branch.

If you are unfamiliar with this model, we recommend working through the following:

* [Git and GitHub](https://help.github.com/articles/git-and-github-learning-resources/)
* [The official Git Tutorial](http://git-scm.com/docs/gittutorial)
* [Learn Git Branching](https://learngitbranching.js.org/)

Once you have your branch set up, you first need to create the directory and file for your content. The directory name should be a shortened version of what your content is about, and as a sub-directory under `/posts`. The actual content piece is written in [Markdown](https://www.markdownguide.org/basic-syntax/) inside `index.md` - the full location would be `/posts/<title-name-here>/index.md`. The `index.md` file needs to have a section at the start that specifies your title, description, author(s), and tags - this is called the "front matter". You can use the [template](https://github.com/build-on-aws/content/raw/main/templates/post.md) that contains the full instructions, or copy the front matter below to the top of your content `index.md` file:

```yaml
---
title: "What Happens When You Type a URL Into Your Browser"
description: Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.
tags:
  - dns-lookup
  - tcp-connection
  - cdn
authorGithubAlias: jennapederson
authorName: Jenna Pederson
date: 2021-08-26
---
```

While writing your draft, review the [Content Review Checklist](/CONTENT_REVIEW_CHECKLIST.md) to make sure your content addresses these items. Taking care of these items before submitting your content will speed up the time to review. Please also take a look at the [FAQ](/FAQ.md) as we have extended standard Markdown with a number of useful extensions for embedded media, table of content, displaying code, and more.

### 4. Submit Pull Request for Review and Publishing

Once you've written your content, add your content to the branch in your forked copy of `content` in your own account and submit a pull request from that branch. You can do this using the GitHub UI or clone the repo locally. The instructions below are to clone the repo locally.

At the end of these steps, you'll end up with your directory structure looking like this:

```text
content/
├── posts/
│   ├── what-happens-when-you-type-a-url-into-your-browser/
    │   ├── images
    │   │   ├── dig-command-output.png      
    │   ├── index.md
```

Note: If you have a series of posts, refer to the [FAQ](/FAQ.md#i-have-a-series-of-posts-how-do-i-link-them-together) for the layout of the directory structure.

If you already have a fork and have cloned the repo locally, make sure your fork/local clone and main branch are up to date by [syncing your fork in GitHub](sync-fork.png) and doing a `git pull` locally. Then proceed to step 3 below.

1. Fork this [repo](https://github.com/build-on-aws/content/fork) to your own account (it will remain private in your account)
1. Clone your repo locally. i.e. `git clone git@github.com:YOUR_GITHUB_ACCOUNT/content.git`
1. Create a new branch for this piece of content: `git checkout -b my-post`
    1. Each branch/pull request should only contain *one piece of content*, even if you are publishing a series of posts so they can be reviewed and published independently.
1. Inside the `posts` folder, create a folder named for the title of your post. This is called the "slug" and will become the URL of your post i.e. `posts/what-happens-when-you-type-a-url-into-your-browser`
1. Name your main post file `index.md` (created in [Step 3: Write Your First Draft](#3-write-your-first-draft)) and store it in the content folder from the previous step
1. If you have images, create a subfolder folder named `images`
    1. Add any images (`jpg`, `png`, `webp`, `svg`, `gif`) to the `images` folder
1. Commit your changes i.e. `git add posts/what-happens-when-you-type-a-url-into-your-browser; git commit -m "Adding new post"`
1. Push your changes to your fork i.e. `git push origin main`
1. Create a pull request of your changes into the [content repo](https://github.com/build-on-aws/content/)
    1. On the Pulls page of your fork (https://github.com/YOUR_GITHUB_ACCOUNT/content/pulls), select the New Pull Request button
    1. In the Comparing Changes section, make sure the base repository is `build-on-aws/content` with the branch set to `main` and the head repository is `YOUR_GITHUB_ACCOUNT/content` with the branch set to `my-post` as you specified in step 3 above.
    1. Select Create Pull Request button
    1. Add your content title to the pull request and fill out the pull request template
    1. In the side menu, select the Gear icon to add the label `ready for review`

Your content is now submitted and will be queued for review. When a reviewer starts to review your content, they will add the label `review in process`.

#### Example

For a post titled `What Happens When You Type a URL Into Your Browser` which is published at [`https://www.buildon.aws/posts/what-happens-when-you-type-a-url-into-your-browser`](https://www.buildon.aws/posts/what-happens-when-you-type-a-url-into-your-browser) store your files like this:

* Main post file: `/posts/what-happens-when-you-type-a-url-into-your-browser/index.md`
* Images: `/posts/what-happens-when-you-type-a-url-into-your-browser/images/dig-command-output.png`

### 5. Address Review Feedback

 A reviewer will provide feedback or requested/suggested changes in the pull request, label it `changes requested`, and assign it back to you. This review is based on the following:

* Writing style (see [Writing Style](#writing-style))
* Technical accuracy
* Inclusive language
* Adheres to the [Content Checklist](/CONTENT_REVIEW_CHECKLIST.md)

A reviewer may make small changes for you, but for any `changes requested`, you’ll incorporate feedback and requested/suggested changes to your draft, and re-add the `ready for review` label until the pull request is approved by a reviewer. Once it is approved, it will be merged and published.

## The Legal Details

### What's Allowed and What's Not Allowed

We want this to be the best place for hands-on builders to learn about a technology or solve a problem or to contribute content to share their knowledge and help others. If you're trying to market or sell a solution, self-promote, or disparage a person, company, or community not only will it not resonate with readers, but your content will not be published.

### Content Licensing

Any content you contribute and publish will be licensed as CC BY-SA 4.0. You can read the full license terms [here](/LICENSE).

### Code of Conduct

This is a community content platform. To keep it a welcoming, inclusive, and respectful place for everyone, your participation as a contributor must adhere to the [Code of Conduct](/CODE_OF_CONDUCT.md).

## Frequently Asked Questions

Check out the [Frequently Asked Questions](/FAQ.md).
