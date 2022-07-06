# Quick Start

Interested in contributing to BuildOn.AWS? Get started quickly: 

* [What We're Looking For](#what-were-looking-for)
* [Writing Style](#writing-style)
* [Publishing Process](#publishing-process)
  * [1. Submit a Content Proposal](#1-submit-a-content-proposal)
  * [2. Proposal Review](#2-proposal-review)
  * [3. Write Your First Draft](#3-write-your-first-draft)
  * [4. Submit Pull Request for Review and Publishing](#4-submit-pull-request-for-review-and-publishing)
  * [5. Share Your Content](#5-share-your-content)
* [The Legal Details](#the-legal-details)
* [Frequently Asked Questions](#frequently-asked-questions)

## What We're Looking For

### Who Writes on BuildOn

We are looking for people with technical knowledge to write about their experiences, share their opinions, and help others in the community. BuildOn.AWS publishes content from authors who want to share their challenges (and helpful hints) to learning a programming language, a dive deep into why it's always DNS, best practices on building microservices architectures and more.

### Who Reads BuildOn

BuildOn.AWS readers are hands-on builders. They personally manipulate code, data, configuration/operations, design architectures, and use APIs, command-line tools, or SDKs to build successful applications. These readers use a range of programming languages, frameworks, tools, and databases.

### What Topics We’re Looking For

Content may be about programming languages (React, Vue.js, CSS…), address generic topics about a category (compute, database, machine learning, networking, cloud) or a particular technology (Docker, Javascript, BGP, TLS1.3), or help a builder solve a problem they are facing.

Not sure what to write about? Check out our idea backlog [here](/contribute).

TODO: Examples to be added

## Writing style

Content on BuildOn.AWS is original content and has a friendly style. Our content reviewers will help you make sure your content is in this style so you can build trust and rapport with the technical community.

### Be You

Content published on BuildOn.AWS comes from you, a human, not you, a company. Content that comes from a human will build trust and be more authentic than content that comes from a brand and goes through a PR review. This content will incorporate your personal stories and experiences.

### Conversational

BuildOn.AWS content is conversational, as if you were explaining technical topics to your friend or a colleague.

### Have an Opinion

Share your opinions and back it up with sound reasoning. Not only will this build trust with the reader, but it will help readers make decisions that work best for their situation. It’s okay to say, “I would start with Fargate because X, Y, Z” or “Are you sure you need containers right now?”. Don’t give non-answers like “EKS, ECS, and Fargate all have their strengths and weaknesses” because that is not helpful to the reader.

### Educational and Useful

Readers are looking for content that helps them solve a problem. Your number one job is to help the reader, by providing expert guidance, backed by strong reasoning and a deep understanding of the problem.

### Clear and Concise

Content is focused and doesn't ramble. Each word, each sentence is necessary to get your point across. You choose words that are simple, not clever and avoid cultural idioms. Complex ideas are explained clearly and concisely, using images, illustrations, and examples to get the point across.

### What It Isn't

BuildOn.AWS content is not your traditional marketing content. It doesn't try to sell readers a product or service and it's not clickbait. Calls-to-action are allowed but content doesn't prioritize them over helping the reader solve a problem.

### Examples

Wondering what type of content fits this content platform? Here are some examples written by the BuildOn.AWS team.

* [What happens when you type a URL into your browser?](https://aws.amazon.com/blogs/mobile/what-happens-when-you-type-a-url-into-your-browser/)
* [10 Ways to Use Serverless Functions](https://dev.to/aws/10-ways-to-use-serverless-functions-bme)
* [Protecting from vulnerabilities in Java: How we managed the log4j crisis](https://medium.com/i-love-my-local-farmer-engineering-blog/protecting-from-vulnerabilities-in-java-how-we-managed-the-log4j-crisis-68d3e90a7586)
* [How to debug machine learning models to catch issues early and often](https://towardsdatascience.com/a-quick-guide-to-managing-machine-learning-experiments-af84da6b060b)

## Publishing Process

### 1. Submit a Content Proposal

Before writing your content, submit a content proposals as a GitHub Issue in the BuildOn.AWS content repository [here](https://github.com/nazreen/eureka-content/issues/new?assignees=jennapederson&labels=content+proposal&template=content-proposal-template.md).

### 2. Proposal Review

During the proposal review phase, we will look for the following in your proposal:

* ensure content topic aligns with the BuildOn.AWS audience
* content topic is educational and useful

When your proposal has been reviewed, a reviewer will label your issue with `accepted`, `change requested`, or `rejected`. Once `accepted`, you can continue to step 3 to Write Your First Draft.

### 3. Write Your First Draft

After your content proposal has been `accepted`, use [this template](/CONTENT_TEMPLATE.md) to write your content in [Markdown](https://www.markdownguide.org/basic-syntax/). You'll update the top portion of the template, the front matter, with the metadata about your post. The front matter specifies things like your blog layout, title, description, and banner image and instructions can be found in the template.

While writing your draft, review the [Content Review Checklist](/CONTENT_REVIEW_CHECKLIST.md) to make sure your content addresses these items. Taking care of these items before submitting your content will speed up the time to review.

### 4. Submit Pull Request for Review and Publishing

Once you've written your content, you'll submit a pull request in the BuildOn.AWS content repository. To do this, you'll

1. Fork this [repo](https://github.com/nazreen/eureka-content/fork)
1. Create a folder named for the slug that will become the URL of your post
1. Name your main post file `index.md` (created in [Step 3: Write Your First Draft](#3-write-your-first-draft)) and store it in the content folder from the previous step
1. Add any secondary Markdown files ending in `.md` in the same folder
1. If you have images, create a subfolder folder named `images`
1. Add any images (`jpg`, `png`, `webp`, `svg`, `gif`) to the `images` folder
1. Commit and push your changes to your fork
1. Create a pull request of your changes into the [content repo](https://github.com/nazreen/eureka-content/)
1. Label it with `ready for review` to have your content draft reviewed
1. Wait for review

#### Example

For a post titled `What Happens When You Type a URL Into Your Browser` which is published at `https://buildon.aws/what-happens-when-you-type-a-url-into-your-browser` store your files like this:

- Main post file: `what-happens-when-you-type-a-url-into-your-browser/index.md`
- Images: `what-happens-when-you-type-a-url-into-your-browser/images/browser-screenshot-1.png`
- Secondary post files (referenced by post): `what-happens-when-you-type-a-url-into-your-browser/another-file.md`

### 5. Address Review Feedback

 A reviewer will provide feedback or requested/suggested changes in the pull request, label it `changes requested`, and assign it back to you within 48 hours. This review is based on the following:

* Writing style (see [Writing Style](#writing-style))
* Format (see [Format](#format))
* Technical accuracy
* Inclusive language
* Adheres to the [Content Guidelines](/CONTENT_GUIDELINES.md)

You’ll incorporate feedback and requested/suggested changes to your draft, adding the `ready for review` label again until the pull request is approved by a reviewer. Once it is approved, it will be merged and published immediately.

### 6. Share Your Content

We encourage you to share your BuildOn content with your social media networks when it is published. We'll also promote content on our social media channels and tag you as the author.

## Format

TODO - maybe move this to it's own page

* Content template to start from
* Images, visuals, illustrations
* Text, code, and images are accessible
* Markdown
    * https://www.markdownguide.org/basic-syntax/
* Length

## The Legal Details

### What's Allowed and What's Not Allowed

We want this to be the best place for hands-on builders to learn about a technology or solve a problem or to contribute content to share their knowledge and help others. If you're trying to market or sell a solution, self-promote, or disparage a person, company, or community not only will it not resonate with readers but your content will not be published. Review the [Content Guidelines](/CONTENT_GUIDELINES.md) to learn more about what's allowed and what's not allowed.

### Content Licensing

Any content you contribute and publish on BuildOn.AWS will be licensed as CC BY 4.0. You can read the full license terms [here](/LICENSE).

### Code of Conduct

BuildOn.AWS is a community content platform. To keep it a welcoming, inclusive, and respectful place for everyone, your participation as a contributor must adhere to the [Code of Conduct](/CODE_OF_CONDUCT.md).

## Frequently Asked Questions

Check out the [Frequently Asked Questions](/FAQ.md).
