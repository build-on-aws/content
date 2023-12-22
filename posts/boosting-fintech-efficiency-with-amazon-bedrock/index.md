---
title: Boosting our fintech efficiency by 50% using generative AI and Amazon Bedrock
description: At LoanOptions.ai, we provide an online platform for business and personal loans. As a fintech startup, a key hurdle is simplifying financial information to provide efficient and positive user experiences. This can be challenging as financial information can often be expansive, complex and difficult to understand without domain expertise. With generative AI, we identify an opportunity to develop a solution. Learn about our journey building an AI application using Amazon Bedrock.
tags:
  - generative-ai
  - bedrock
  - claude
spaces:
  - generative-ai
waves:
  - generative-ai
images:
  banner: images/banner.jpg
  hero: images/banner.jpg
authorGithubAlias: nirlepadhikari
githubUserLabel: community
authorName: Nirlep Adhikhari
additionalAuthors: 
  - authorGithubAlias: wirjo
    authorName: Daniel Wirjo
date: 2023-12-23
---

|ToC|
|---|

## Introduction

At [LoanOptions.ai](https://loanoptions.ai/), we provide an online platform for business and personal loans. As a fintech startup, a key hurdle is simplifying financial information. This is critical in order to provide our commercial teams (brokers) and customers with an efficient and positive user experience. Unfortunately, it can be challenging as financial information can often be expansive, complex and tough to interpret without domain expertise. If you have personal experience applying for a financial product, you may relate to a lengthy, mundane, and overwhelming experience.

With generative AI, we recognise an opportunity to develop a solution to enhance our experience for customers, and boost the efficiency of our commercial teams (brokers). In this post, we will share our journey building a generative AI application on [Amazon Bedrock](https://aws.amazon.com/bedrock/). For this application, we use a [retrieval-augmented generation (RAG) architecture](https://aws.amazon.com/what-is/retrieval-augmented-generation/) for a question-answering (Q&A) chatbot use case.

## Getting started with generative AI
To quickly get started, we search for open-source repositories for reference examples. In particular, examples with key capabilities for our use case, including the ability to process PDF documents, and [memory](https://js.langchain.com/docs/modules/memory/) to remember previous interactions and answer follow up questions. We find [serverless-pdf-chat](https://github.com/aws-samples/serverless-pdf-chat) and [bedrock-claude-chat](https://github.com/aws-samples/bedrock-claude-chat) on aws-samples Github. Given our familiarity with Next.js, we also evaluate [vercel/ai-chatbot](https://github.com/vercel/ai-chatbot). During our research, we discover that these examples and many others, use [LangChain](https://www.langchain.com/). Due to popularity, active contributions by the community and libraries to integrate with many AWS services, we decide to use the framework for our generative AI application. Ultimately, by forking existing open source solutions and adapting it to our use case, we ship a prototype for user feedback within days, even with a small team. 

## Building our knowledge base 
Customizing generative AI models with a knowledge base is critical. For us, this knowledge base consist of information from our comprehensive network of lenders. With each lender, we process a unique and diverse set of policies and loan criteria. This enables us to make data-driven loan decisions. 

To understand the meaning of text data in these documents, we first convert them into vector embeddings. These are simply numerical representation of text that make it meaningful for machine learning, and allow us to perform similarity search. Here, we use [Titan Text Embeddings on Bedrock](https://aws.amazon.com/bedrock/titan/). As documents were authored by different lenders, it is not uncommon that they use different language to describe the same meaning. Fortunately, Titan has been pre-trained with the semantic meaning of text. This enables effective search across a diverse set of documents despite varying semantics. 

These documents were originally sourced from our network of lenders in PDF format. As a result, we build an application that integrates with our existing document management system, based on [Amazon Simple Storage Service (S3)](https://aws.amazon.com/s3/). To cater for updates, each document is versioned and stored with relevant metadata, such as the corresponding lender details for easy filtering. We then process this with a serverless workflow powered by [AWS Lambda](https://aws.amazon.com/pm/lambda/). The workflows includes reading the information, [chunking](https://js.langchain.com/docs/modules/data_connection/document_transformers/) into smaller pieces, and finally converting to vector embeddings. The progress is tracked and visible to our users. With this, they understand the scope of answers provided by the application, including the specific version of policies used. We look forward to trying [Knowledge Bases for Bedrock](https://aws.amazon.com/bedrock/knowledge-bases/) which provide an easier to maintain managed solution in future.  

## Retrieval 
With familiarity with PostgreSQL, we store vector embeddings on [pgvector](https://aws.amazon.com/blogs/database/leverage-pgvector-and-amazon-aurora-postgresql-for-natural-language-processing-chatbots-and-sentiment-analysis/). From there, we use SQL queries to perform similarity search on user prompts. This is as simple as using the `<->` operator for [finding nearest neighbour vectors](https://github.com/pgvector/pgvector?tab=readme-ov-file#querying). Here, search results represent relevant information that form the context in which answers are based on. As documents can be lengthy and were processed in small chunks, only the relevant snippets of information is returned. In future, we aim to experiment with advanced retrieval techniques, augment our knowledge base with structured FAQs, and incorporate entity extraction for more precise answers. 

## Generation
For generation, we use [Claude on Amazon Bedrock](https://aws.amazon.com/bedrock/claude/). With Claude, we benefit from a general-purpose model with efficient question-answering (Q&A) capabilities. Through iteration and [prompt engineering](https://docs.anthropic.com/claude/docs/guide-to-anthropics-prompt-engineering-resources), we see improvements compared to equivalent GPT models in our testing. To test, we use frequently asked queries such as **"Which lenders accept Centrelink income?"** and evaluate their results with human review.

Another critical element is using a [Lambda function for streaming responses](https://www.youtube.com/watch?v=NDtrk9Pm9w0) back to the frontend. Using streaming minimises wait times and users do not have to wait for the entire message to buffer. For a bit of fun, we introduce chatbot personas, including a Pirate, a character from Family Guy, and Batman, with the Family Guy character becoming an instant hit for its informative yet humorous responses. We simply prompt for [roleplay dialogue](https://docs.anthropic.com/claude/docs/roleplay-dialogue) driving engagement and buy-in from our users. To optimise cost and imporove speed for simpler queries, we aim to experiment with smaller models such as Claude Instant. 

## Conclusion
With generative AI, we are able to improve the efficiency of our commercial teams and introduce a more steramlined and personalised customer experience. With our new AI-powered experience, we reduced the average time for loan applications by over 50%, receiving [industry recognition](https://www.fintechaustralia.org.au/newsroom/loanoptionsai-redefines-automation-as-it-launches-lo-30). If you are curious, see [LinkedIn video](https://www.linkedin.com/posts/julianfayad_fintech-fintechnews-ai-activity-7139734849233305600-8myQ).

To achieve this, we leverage a range of capabilities across AWS. This includes access to foundation models on [Bedrock](https://aws.amazon.com/bedrock/), vector capabilities with [pgvector](https://aws.amazon.com/blogs/database/leverage-pgvector-and-amazon-aurora-postgresql-for-natural-language-processing-chatbots-and-sentiment-analysis/), and serverless technologies with [Lambda](https://aws.amazon.com/pm/lambda/). We collaborate with our [account team](https://aws.amazon.com/startups/learn/meet-your-aws-account-team). From obtaining [AWS Activate credits](https://aws.amazon.com/startups/credits) to reduce the cost of experimentation, to accessing generative AI and machine learning experts on [AWS Startup Loft](https://www.aws-startup-lofts.com/). If you are looking to build with generative AI, we hope that this post inspires and accelerates your journey.

To get started with generative AI on AWS, please see resources:

* [Generative AI for Startups](https://aws.amazon.com/startups/generative-ai/)
* [Generative AI on AWS Community](https://community.aws/generative-ai)
* [Patterns for Building Generative AI Applications on Amazon Bedrock](https://community.aws/posts/build-generative-ai-applications-with-amazon-bedrock)
