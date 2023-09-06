---
title: "Vector Databases: Powering the GenAI Revolution"
description: "Vector databases are an unsung hero enabling the hype around generative AI. Learn how vector databases provide the infrastructure for UX like semantic search, accurately customizing LLMs, and why mastering Vector DBs can make you a GenAI trendsetter."
tags:
    - generative-ai
    - ai-ml
    - vector-databases
    - databases
spaces:
    - generative-ai
waves:
  - dataml
  - generative-ai
images:
  banner: 
  hero: 
authorGithubAlias: brookejamieson
authorName: Brooke Jamieson
date: 2023-09-06
showInHomeFeed: true
---
One of the funny things about AI (and emerging tech in general) is that the flashiest new tech isn’t always the most impactful. Often, the real innovation is happening quietly behind the scenes in fields that lots of developers might gloss over because they don’t seem as exciting as the ShinyNewCoolThing™. Developers either want to avoid the hype altogether (so they don’t learn about some of the boring underpinnings), or they’re so deep into the hype they don’t have time to stop and learn about some of the boring underpinnings. This is why the working title for this blog post, about one of the unsung heroes of the current hype, was “Why you should finally learn about Vector Databases for Generative AI”. 

## What are Vector Databases anyway?

Humans are pretty good at understanding the meaning and context of words, but (try as they might), machines can only understand numbers. Consequently, we have to translate information into a format that machines can work with if we want things to work for Machine Learning. Vector embeddings are this ‘translation’ from text, image, audio, and video data to numbers. They take unstructured data, such as words, with all their tricky semantic meanings, and store them in a big space. This space is a [Vector Database](https://community.aws/posts/the-abcs-of-generative-ai#v-is-for-vector-databases), and each data point has its own coordinates.

However, we’re not just talking X and Y coordinates like in 2 dimensional space - there are *many* dimensions. And it’s not just the position of each word in space that is important; it’s the distance from a word to it’s neighbors. The closer two words are in space, the more similar they are, and this is where the magic really happens. 

Vector Databases aren’t just notable for their complexity; they stand out for their transformative potential for [Large Language Models (LLMs)](https://community.aws/posts/the-abcs-of-generative-ai#l-is-for-large-language-models) and other types of [Generative AI](https://community.aws/posts/the-abcs-of-generative-ai#g-is-for-generative-ai). Users can snap photos with their phones and search for similar images. Developers can also harness other AI/ML models to extract metadata from content, which means they can perform hybrid searches on both keywords and vectors. This fusion of semantic understanding refines search results and enhances user experiences by making it easier for humans and computers to interact. 

## 💖 Vector DBs + Gen AI = BFFL 💖

You might be shocked to learn that, in my recent post, “[The ABCs of Generative AI](https://community.aws/posts/the-abcs-of-generative-ai),” G stands for [Generative AI](https://community.aws/posts/the-abcs-of-generative-ai#g-is-for-generative-ai):

>Generative AI is a subset of deep learning, and it's a type of AI that can create new content and ideas, like conversations, stories, images, videos, and music. Like with other types of AI, generative AI is powered by ML models — very large models that are pre-trained on vast corpora of data, and these are commonly referred to as [Foundation Models](https://community.aws/posts/the-abcs-of-generative-ai#f-is-for-foundation-models), or FMs. If you'd like to learn more about Generative AI, I've made [this video](https://www.linkedin.com/feed/update/urn:li:activity:7092570822602575872/) explaining how it fits in with AI more broadly, and I also recommend [Swami & Werner's chat](https://www.youtube.com/watch?v=dBzCGcwYCJo) about Generative AI.


Creating novel user experiences (UX) with Generative AI comes down to being able to access and navigate enormous amounts of data quickly. Vector databases, especially those powered by algorithms like Hierarchical Navigable Small Worlds (HNSW) and Inverted File Index (IVF), provide this infrastructure that helps Generative AI to become the ShinyNewCoolThing™ users have dreamt of. These algorithms allow for efficient nearest-neighbor searches, which are crucial for tasks like semantic search, or generating images from text prompts in GenAI applications. 

Vector Databases can be used in Generative AI applications in a number of ways including storing training data (and allowing for quick retrieval when it’s needed), computing vector representations of data like word or sentence embeddings, and performing similarity search so the GenAI application can find similar data to the data it’s currently processing. This is helpful for Large Language Models, especially when those trying to generate new text similar to an input piece of text. 

However, generative models can sometimes produce inaccurate or even misleading results, called ‘[hallucinations](https://community.aws/posts/the-abcs-of-generative-ai#h-is-for-hallucination)’. This is where Vector Databases can also come in handy. By acting as an external knowledge base, they make sure that Generative AI models like chatbots provide reliable and trustworthy information to users. The symbiotic relationship between GenAI and Vector DBs is setting the stage for the next wave of AI innovations. 

## It’s time to stop putting off learning about Vector Databases!

So, dear reader, let’s have a heart-to-heart. Remember that time you procrastinated on learning that new coding language (cough - Rust) only to find it became the hottest trend in the developer community? Or when you thought containers were just for leftovers, but then Docker happened? Well, Vector Databases are your next “I wish I’d jumped on that sooner” career moment. 

They’re not just a fleeting trend - they’re fundamentally changing how we interact with data and making our applications smarter, faster, and more intuitive. So here’s your nudge (or shove): dive into the world of vector databases! Embrace the knowledge! Be a trend setter! 

To learn more about Vector Databases, I recommend these articles:

* [What is a Vector Database?](https://aws.amazon.com/what-is/vector-databases/)
* [The role of vector datastores in generative AI applications [AWS Database Blog]](https://aws.amazon.com/blogs/database/the-role-of-vector-datastores-in-generative-ai-applications/)
* [Amazon OpenSearch Service’s vector database capabilities explained [AWS Database Blog]](https://aws.amazon.com/blogs/big-data/amazon-opensearch-services-vector-database-capabilities-explained/)
* [Amazon RDS for PostgreSQL now supports pgvector for simplified ML model integration](https://aws.amazon.com/about-aws/whats-new/2023/05/amazon-rds-postgresql-pgvector-ml-model-integration/)
* [Vector engine for Amazon OpenSearch Serverless now in preview](https://aws.amazon.com/about-aws/whats-new/2023/07/vector-engine-amazon-opensearch-serverless-preview/)
* [Amazon Aurora PostgreSQL now supports pgvector for vector storage and similarity search](https://aws.amazon.com/about-aws/whats-new/2023/07/amazon-aurora-postgresql-pgvector-vector-storage-similarity-search/)

If anything, learn about vector databases so you can feel like you know more about GenAI than the person asking you to “just pop an LLM” into your next application. 
