---
title: "The ABCs of Generative AI"
description: "Generative AI exploded onto the scene so quickly that many developers haven’t been able to catch up with new technical concepts in Generative AI. Whether you’re a builder without an AI/ML background, or you’re feeling like you’ve “missed the boat,” this glossary is for you!"
tags:
    - generative-ai
    - ai-ml
spaces:
    - generative-ai
waves:
  - dataml
  - generative-ai
images:
  banner: images/ABCsGenAIheader.gif
  hero: images/ABCsGenAIheader.gif
authorGithubAlias: brookejamieson
authorName: Brooke Jamieson
date: 2023-08-17
---

![The ABCs of Generative AI header image](/images/ABCsGenAIheader.gif)

Working in AI and Machine Learning means you’re learning all the time (both on your own, and through models!), so study skills that help you to retain and synthesize new concepts are super important. One of my top strategies for this is making glossaries to organize the definitions I write based on information from different sources, and they really come in handy when it comes to making videos about technical concepts for [Twitter](https://twitter.com/brooke_jamieson), [LinkedIn](https://www.linkedin.com/in/brookejamieson/), or [TikTok](https://www.tiktok.com/@brookebytes). This post started as one of my personal glossaries, which then morphed into a re:Invent talk proposal, but Generative AI is moving so quickly that I couldn’t wait until November to share this! 

Here’s a full list of the ABCs of Generative AI so you can skip ahead: 

* [A is for Attention](#a-is-for-attention)
* [B is for Bedrock](#b-is-for-bedrock)
* [C is for CodeWhisperer](#c-is-for-codewhisperer)
* [D is for Diffusion Models](#d-is-for-diffusion-models)
* [E is for Embeddings](#e-is-for-embeddings)
* [F is for Foundation Models](#f-is-for-foundation-models)
* [G is for Generative AI](#g-is-for-generative-ai)
* [H is for Hallucination](#h-is-for-hallucination)
* [I is for Inferentia and Trainium](#i-is-for-inferentia--trainium)
* [J is for SageMaker Jumpstart](#j-is-for-sagemaker-jumpstart)
* [K is for Kernel Methods](#k-is-for-kernel-methods)
* [L is for Large Language Models](#l-is-for-large-language-models)
* [M is for Model Selection](#m-is-for-model-selection)
* [N is for Neural Network](#n-is-for-neural-network)
* [O is for Optimization](#o-is-for-optimization)
* [P is for Prompt Engineering](#p-is-for-prompt-engineering)
* [Q is for Quantisation](#q-is-for-quantization)
* [R is for Responsibility](#r-is-for-responsibility)
* [S is for SageMaker](#s-is-for-sagemaker)
* [T is for Transformers](#t-is-for-transformers)
* [U is for Unsupervised Learning](#u-is-for-unsupervised-learning)
* [V is for Vector Databases](#v-is-for-vector-databases)
* [W is for Weights](#w-is-for-weights)
* [X is for Explainable AI (XAI)](#x-is-for-explainable-ai-xai)
* [Y is for You Can Build on AWS](#y-is-for-you-can-build-on-aws)
* [Z is for Zero-Shot Learning](#z-is-for-zero-shot-learning)

## A is for Attention

Attention in AI is like shining a spotlight so the model knows what's important and what to pay attention to. In the 2017 paper [Attention Is All You Need](https://arxiv.org/abs/1706.03762), the authors presented a really novel idea that [transformers](#t-is-for-transformers) (which we'll cover later in the alphabet) can effectively process sequential data with attention mechanisms alone, instead of needing traditional recurrent or convolutional [neural networks](#n-is-for-neural-network). This mechanism enables the model to weigh the importance of different pieces of information, and has become a vital component in state-of-the-art [Large Language Models](#l-is-for-large-language-models) for tasks like translation, summarization, and text generation. 

## B is for Bedrock

[Amazon Bedrock](https://aws.amazon.com/bedrock/?sc_channel=el&sc_campaign=datamlwave&sc_geo=mult&sc_country=mult&sc_outcome=acq&sc_content=the-abcs-of-generative-ai) is a fully managed service from AWS that helps you build and scale generative AI applications using [Foundation Models](#f-is-for-foundation-models), or FMs, which we'll come back to later in the alphabet. Amazon Bedrock democratizes access for developers wanting to build with generative AI, and it accelerates development through an API so you don't need to manage infrastructure and you can focus your energy on the experiences you are building for your customers. There are lots of Foundation Models to choose from in Bedrock, and they're not just from Amazon. You'll also get access to FMs from top AI startups like [AI21 Labs](https://www.ai21.com/), [Anthropic](https://www.anthropic.com/), [Cohere](https://cohere.com/), and [Stability AI](https://stability.ai/). Once you've chosen a foundation model to experiment with, you can privately customize it with your own data, and then integrate and deploy them into your applications with other AWS tools you already know and love. 

## C is for CodeWhisperer

[Amazon CodeWhisperer](https://aws.amazon.com/codewhisperer/?trk=a325eb01-2134-4258-a88b-ffc101a7b548&sc_channel=sm) is an AI-powered coding sidekick that uses large language models trained on billions of lines of code (including Amazon and open-source code) to generate precise, secure, and real-time code suggestions, right in your IDE! Write comments in English, and then CodeWhisperer suggests snippets through to full functions in real time, which makes coding much faster - especially when you're working with unfamiliar APIs. For me, it means focusing on my VSCode window instead of having a million tabs open to double check things on the go as I'm coding, which means I can find and stay in my flow state. 

If you’re interested in CodeWhisperer, I’ve made [this video](https://www.youtube.com/watch?v=xVd7PLzjA6A) about how to get the most out of the service, and I also presented [this demo](https://www.youtube.com/watch?v=JwP-Bk8K_cs) at Developer Innovation Day. 

## D is for Diffusion Models

Diffusion models are a type of generative AI model that can create realistic and diverse images or other kinds of data. They're interesting because they work by predicting "noise" and then subtracting this noise from a noisy input to generate a clean output. The process sounds a bit strange, but in practice it is really handy because the model learns what noise is and what the actual content of the data is - like images of objects or characters. 

## E is for Embeddings

Understanding how different concepts are contextually linked or related is a bit of an abstract concept, but it's a crucial piece of the [Generative AI](#g-is-for-generative-ai) puzzle, especially for specialized use cases. Computers don't think in words like humans, so you can encode data as a set of elements, which are each represented as a [vector](#v-is-for-vector-databases). In this case, a vector contains an array of numbers, and these numbers are used to map elements in relation to one another in a multidimensional space. When these vectors have a form of meaning, we call them semantic, and their distance from each other is a way to measure their contextual relationship. These types of vectors, used in this way, are called embeddings.

## F is for Foundation Models

My favorite F word: Foundation Models! Advancements in ML (like the invention of the transformer-based neural network architecture) mean that we now have models that contain billions of parameters or variables. The enormous amount of data these are trained on means they can perform all sorts of tasks and work with lots of different types of data to apply their knowledge to a different contexts. 

However, they're not simple or fast to DIY! Foundation Models are models where the hard work in training has already been done for you, so you can use them out of the box for your use cases, or fine tune them for specific domains. There's so much potential here because they open up the world of opportunities of these powerful models to developers around the world. I like the analogy of standing on the shoulders of giants! The easiest way to build and scale [Generative AI](#g-is-for-generative-ai) applications with FMs is [Amazon Bedrock](#b-is-for-bedrock), which you saw earlier in the alphabet. 

## G is for Generative AI

Generative AI is a subset of deep learning, and it's a type of AI that can create new content and ideas, like conversations, stories, images, videos, and music. Like with other types of AI, generative AI is powered by ML models — very large models that are pre-trained on vast corpora of data, and these are commonly referred to as [Foundation Models](#f-is-for-foundation-models), or FMs. If you'd like to learn more about Generative AI, I've made [this video](https://www.linkedin.com/feed/update/urn:li:activity:7092570822602575872/) explaining how it fits in with AI more broadly, and I also recommend [Swami & Werner's chat](https://www.youtube.com/watch?v=dBzCGcwYCJo) about Generative AI. 

## H is for Hallucination

Generative AI models can sometimes generate content that is false and deliver it with confidence. This is called hallucination, and it can happen in Large Language Models when text is generated that conveys information that doesn't appear in the input information, or when a relationship is communicated in the output that isn't in the input information either. Amazon Science published a great blog post called '[3 questions with Kathleen McKeown: Controlling model hallucinations in natural language generation](https://www.amazon.science/latest-news/3-questions-with-kathleen-mckeown-controlling-model-hallucinations-in-natural-language-generation),' which is a fantastic resource if you'd like to learn more about this topic. 

## I is for Inferentia + Trainium

It's easy to only think about the software elements of generative AI, but hardware makes a difference too! Whether you're building a foundation model from scratch, running a foundation model, or customizing them, you need cost effective infrastructure that is high performance and purpose built for Machine Learning. AWS has made huge strides and investments in custom silicon to lower the cost to run generative AI workloads and train models faster. 

[AWS Inferentia](https://aws.amazon.com/machine-learning/inferentia/?sc_channel=el&sc_campaign=datamlwave&sc_geo=mult&sc_country=mult&sc_outcome=acq&sc_content=the-abcs-of-generative-ai) helps developers run high performance FM inference with up to 40% lower cost per inference over comparable Amazon EC2 Instances, and [AWS Trainium](https://aws.amazon.com/machine-learning/trainium/?sc_channel=el&sc_campaign=datamlwave&sc_geo=mult&sc_country=mult&sc_outcome=acq&sc_content=the-abcs-of-generative-ai) helps developers train faster with up to 50% savings on training costs over comparable Amazon EC2 Instances. 

## J is for SageMaker Jumpstart

[Amazon SageMaker Jumpstart](https://aws.amazon.com/sagemaker/jumpstart/?sc_channel=el&sc_campaign=datamlwave&sc_geo=mult&sc_country=mult&sc_outcome=acq&sc_content=the-abcs-of-generative-ai) is a Machine Learning hub that offers foundation models, prebuilt ML solutions, and built-in algorithms that are fully customizable and can be deployed in a few clicks. Developers can share ML models and notebooks across their organization so building and collaborating is easy, while ensuring user data remains encrypted and doesn't leave your [Virtual Private Cloud (VPC)](https://aws.amazon.com/vpc/?sc_channel=el&sc_campaign=datamlwave&sc_geo=mult&sc_country=mult&sc_outcome=acq&sc_content=the-abcs-of-generative-ai). 

## K is for Kernel Methods

Kernel methods are popular techniques used in Artificial Intelligence and Machine Learning, because they're effective algorithms for pattern analysis, and they deal with transforming data into a higher dimensional space. This sounds a bit confusing, but a kernel is a mathematical function for computing the similarity between two objects, and the crux of Kernel methods is that sometimes it's easier to separate or group data based on their similarities, even if they were difficult to distinguish in the first place. Some interesting papers from Amazon Science that relate to Kernels include '[Empowering parameter-efficient transfer learning by recognizing the kernel structure in attention](https://www.amazon.science/publications/empowering-parameter-efficient-transfer-learning-by-recognizing-the-kernel-structure-in-attention)' and '[More-efficient “kernel methods” dramatically reduce training time for natural-language-understanding systems](https://www.amazon.science/publications/efficient-online-learning-for-mapping-kernels-on-linguistic-structures),' if you'd like to dive deeper into this topic. 

## L is for Large Language Models

Large Language Models or LLMs have been around for a while behind the scenes, but they've become mainstream recently. LLMs are a type of Foundation Model that is pre-trained on massive amounts of data, and they are trained to summarize and translate texts, as well as predict words, which means they can generate sentences that seem similar to how humans talk and write. Something that makes LLMs really fascinating is their ability to do in-context learning, which is where the model can learn to a task if you provide it with a few (or sometimes zero!) good examples. This means the largest of the large language models can perform all sorts of tasks, even if they weren't explicitly trained on these in the first place. 

If you’re interested in LLMs, my colleagues have launched an incredible course in collaboration with Andrew Ng and the team at DeepLearning.AI called ‘[Generative AI with Large Language Models](https://www.deeplearning.ai/courses/generative-ai-with-llms/).’ 

## M is for Model Selection

There are a few key factors that you need to keep in mind when choosing the right foundation model for the job: modalities, task, size, accuracy, ease-of-use, licensing, previous examples, and external benchmarks. It's important: you'll need to understand the different modalities like language and vision, as well as understanding the inputs and outputs of the model so you can really determine the capabilities you have and will need. You'll also need to consider the size of the foundation based on the specific use case you're working towards, as larger models will be more suited to open-ended language generation, but you might not always need the largest model for every task. Once you've chosen a model and started experimenting, it's time to evaluate the use of the foundation model for different downstream tasks, as well as considering licensing and external benchmarks to make sure that you're on the right track. It's also important to recognize the interplay between language and vision in foundation models and how they influence each other's capabilities, especially if you're taking a multimodal approach.

For an in-depth overview of how to choose the right foundation model, see Emily Webber’s great video called [Picking the right foundation model](https://www.youtube.com/watch?v=EVqTWGafpfo), which is part of her Generative AI Foundations on AWS series. 

## N is for Neural Network

Neural Networks are a type of Artificial Intelligence that mimic the human brain’s way of processing information. They use interconnected nodes in layers or “neurons” to learn from data and improve their performance over time. Neural networks allow computers to perform complex tasks like image and text interpretation, so they are essential for image recognition, speech-to-text, natural language processing, and personalized recommendations. They can learn and model complex and nonlinear relationships between input and output data. 

The ‘[What is a Neural Network](https://aws.amazon.com/what-is/neural-network/)’ page in the AWS Cloud Computing Concepts Hub has a great overview if you’d like to learn more. 

## O is for Optimization

In AI/ML, Optimization means fine-tuning models for better performance by adjusting hyperparameters, which are external configuration variables. Hyperparameters, like the number of nodes in a Neural Network or the learning rate, are set before model training begins. Finding the optimal values for these hyperparameters with methods like Bayesian optimization or Grid Search is called hyperparameter tuning, and this process ensure s the model achieves optimal results and accuracy. 
To learn more about hyparameters, visit the ‘[What Is Hyperparameter Tuning?](https://aws.amazon.com/what-is/hyperparameter-tuning/?sc_channel=el&sc_campaign=datamlwave&sc_geo=mult&sc_country=mult&sc_outcome=acq&sc_content=the-abcs-of-generative-ai)’ page in the AWS Cloud Computing Concepts Hub, or dive deeper with the AWS Machine Learning Blog to learn ‘[Hyperparameter optimization for fine-tuning pre-trained transformer models from Hugging Face](https://aws.amazon.com/blogs/machine-learning/hyperparameter-optimization-for-fine-tuning-pre-trained-transformer-models-from-hugging-face/?sc_channel=el&sc_campaign=datamlwave&sc_geo=mult&sc_country=mult&sc_outcome=acq&sc_content=the-abcs-of-generative-ai)’ for a more hands-on and technical overview.

## P is for Prompt Engineering

Prompt Engineering is the process of designing and refining prompts or input stimuli to guide a [Large Language Model](#l-is-for-large-language-models) to generate specific outputs. It involves carefully choosing keywords, providing context, and being specific when shaping the input to guide the model toward desired responses. Prompt Engineering allows you to control a model’s style, tone, and expertise - without resorting to complex customization through fine tuning. By dedicating energy to prompt engineering upfront, the model can generalize and perform well even on unseen or limited data scenarios. 

To learn more about Prompt Engineering Fundamentals, see Mike Chambers’ video ‘[Prompt Engineering and In Context Learning](https://www.youtube.com/watch?v=RIOqmpK5l3k)’ as part of his ‘[Introduction to Large Language Models (LLMs)](https://www.youtube.com/playlist?list=PLDqi6CuDzubzye330jymq3VkwYHvHY-TT)‘ series. 

## Q is for Quantization

>Before I start with this definition - don’t worry if you haven’t heard of Quantization! It’s unlikely you’ll come across the word ‘in the wild,’ but there just aren’t many AI/ML words that start with Q. 

Generally speaking, Quantization involves converting continuous values to discrete values. Continuous values are things you could measure, and can take on any value within an interval (e.g. temperature, which could be 26.31°), and discrete values are things you could count (e.g. number of Cocker Spaniels at the beach). In the context of Machine Learning, Quantization comes into play in [Neural Networks](#n-is-for-neural-network), where it means converting weights and activations to lower-precision values. This is an important process, especially if the model needs to run on a device with limited memory, because it can help to reduce the memory requirement, power consumption, and latency for a Neural Network. 

## R is for Responsibility

Responsibility in AI refers to the mindful and ethical development and application of AI models, focusing on concerns like fairness, toxicity, [hallucinations](#h-is-for-hallucination), privacy, and intellectual property. The complexity of [Generative AI](#g-is-for-generative-ai), which can produce a wide range of content, presents unique challenges in defining and enforcing ethical principles. Strategies to foster responsible AI include careful curation of training data, development of guardrail models to filter unwanted content, and continuous collaboration across domains to ensure AI systems are both innovative, reliable, and respectful for all users. 

Michael Kearns, a professor of computer and information science at the University of Pennsylvania and an Amazon Scholar wrote one of my favorite articles of the year for the Amazon Science blog called ‘[Responsible AI in the generative era](https://www.amazon.science/blog/responsible-ai-in-the-generative-era/?sc_channel=el&sc_campaign=datamlwave&sc_geo=mult&sc_country=mult&sc_outcome=acq&sc_content=the-abcs-of-generative-ai),’ and if you only have time to read one of the resources I’ve linked in this article, choose this one!

## S is for SageMaker

[Amazon SageMaker](https://aws.amazon.com/sagemaker/?sc_channel=el&sc_campaign=datamlwave&sc_geo=mult&sc_country=mult&sc_outcome=acq&sc_content=the-abcs-of-generative-ai) is a fully managed machine learning service from AWS that allows data scientists and developers to easily build, train, and deploy ML models. It offers an integrated Jupyter notebook for data exploration, analysis, and model development without the need to manage servers. SageMaker also provides optimized algorithms and supports custom frameworks, making it a flexible and scalable solution for machine learning tasks. There’s a huge list of features, including [SageMaker Jumpstart](#j-is-for-sagemaker-jumpstart) from earlier in the alphabet, and you can learn more on the [SageMaker product page](https://aws.amazon.com/sagemaker/?sc_channel=el&sc_campaign=datamlwave&sc_geo=mult&sc_country=mult&sc_outcome=acq&sc_content=the-abcs-of-generative-ai) and in the [SageMaker Documentation](https://docs.aws.amazon.com/sagemaker/index.html?sc_channel=el&sc_campaign=datamlwave&sc_geo=mult&sc_country=mult&sc_outcome=acq&sc_content=the-abcs-of-generative-ai).

## T is for Transformers 

Transformers are a groundbreaking technology introduced in the 2017 paper [Attention Is All You Need](https://arxiv.org/abs/1706.03762) (also referenced in [A is for Attention](#a-is-for-attention) at the start of this list). The transformer architecture is a combination of matrix calculations and neural networks with the key ability of applying “attention” to relevant parts of the input data. Transformers allow language models to process data in parallel and consider the entire context of the sentence instead of just the last few words. These characteristics mean Transformers can efficiently process enormous quantities of data, which made them pivotal in advancing [Generative AI](#g-is-for-generative-ai) and forming the basis of [Large Language Models](#l-is-for-large-language-models) that can perform complex tasks. 

To learn more, skip through to the ‘Transformer Architecture’ chapter in Mike Chambers’ video ‘[Generative AI: A Builder’s Guide](https://www.youtube.com/watch?v=j0MKG8W2NVA&list=PLDqi6CuDzubzye330jymq3VkwYHvHY-TT&index=1)’. 

## U is for Unsupervised Learning

Unsupervised Learning is a type of algorithm that trains on unlabelled data, without corresponding output labels. The algorithm is trying to find hidden patterns, relationships, and structures within the data autonomously and without specific guidance on what the outcomes should be. Applications include clustering similar items, like grouping news articles into categories, or detecting anomalies in network traffic signaling a potential security breach. I think of Unsupervised Learning every time I’m in a new city and forget to download maps before I go; I end up exploring on my own and figuring out landmarks, layouts, and patterns of shops in the city myself without a guide. 

Supervised Learning, on the other hand, trains on labelled data where both the input and corresponding output are provided. The model learns to make predictions or decisions based on this input-output pairing and understanding the relationship between the input and desired output. Examples include predicting house prices using features like location and number of rooms, or recognizing handwritten numbers from labeled images of the digits. I remember Supervised Learning as doing homework after seeing the answers - where the questions (input data) and answers (output labels) are provided, so you can study by seeing questions and answers. Once a model (or student) is trained with Supervised Learning, they can make predictions on new unseen data, like taking a test on similar questions. 

Bookmark this page if you’re ever losing track remembering ‘[The Difference Between Supervised and Unsupervised Learning.’](https://aws.amazon.com/compare/the-difference-between-machine-learning-supervised-and-unsupervised/)

## V is for Vector Databases

A Vector Database is a specialized database that allows you to store and retrieve high dimensional vectors representing various types of data. They enable efficient and fast lookup of nearest neighbors in N-dimensional space, making them useful for tasks like semantic search, vector search, and multimodal search. Vector Databases play a crucial role behind the scenes in Generative AI applications by allowing customization of language models, improving accuracy, and providing a foundation for unique user experiences like conversational search or generating images from text prompts. 

The ‘[What is a Vector Database?](https://aws.amazon.com/what-is/vector-databases/?sc_channel=el&sc_campaign=datamlwave&sc_geo=mult&sc_country=mult&sc_outcome=acq&sc_content=the-abcs-of-generative-ai)’ page in the AWS Cloud Computing Concepts Hub has a great overview if you’d like to learn more, and you can dive deeper into Gen AI concepts in the AWS Database blog called ‘[The role of vector datastores in generative AI applications](https://aws.amazon.com/blogs/database/the-role-of-vector-datastores-in-generative-ai-applications/?sc_channel=el&sc_campaign=datamlwave&sc_geo=mult&sc_country=mult&sc_outcome=acq&sc_content=the-abcs-of-generative-ai)’. 

## W is for Weights

Weights are numerical values used within [neural networks](#n-is-for-neural-network) to determine the strength of connections between neurons, particularly in systems like [transformers](#t-is-for-transformers), which were introduced in the 2017 paper ‘[Attention is All You Need](https://arxiv.org/abs/1706.03762).’ These weights play a crucial role in the [attention](#a-is-for-attention) mechanism, because they allow the network to focus on specific parts of the input, enabling the model to generate more contextually relevant outputs. Think of weights as the dials that are fine-tuned during training to help the model understand and process complex relationships and patterns in the data. 

## X is for Explainable AI (XAI)

Explainable AI (often abbreviated as XAI) is essential for building trust and confidence in AI systems, especially when decisions made by AI can have significant consequences. There are two key aspects of explainability: interpretability and explainability. Interpretability means understanding the inner workings of an AI model, like weights and features, to understand how and why predictions are generated. On the other hand, explainability uses model-agnostic methods to describe the behavior of an AI model in human terms, even for “black box” models. Deciding whether to focus on interpretability or explainability depends on the specific use case, data type, and business requirements, and this can involve a trade-off between achieving high performance and maintaining the ability to explain the model’s behavior. 

To understand this concept and any trade-offs in more detail, I recommend the [Amazon AI Fairness and Explainability Whitepaper](https://pages.awscloud.com/rs/112-TZM-766/images/Amazon.AI.Fairness.and.Explainability.Whitepaper.pdf?sc_channel=el&sc_campaign=datamlwave&sc_geo=mult&sc_country=mult&sc_outcome=acq&sc_content=the-abcs-of-generative-ai). Also, learn how Amazon SageMaker Clarify can help to improve your ML models by detecting potential bias and helping to explain the predictions that models make on the [product page](https://aws.amazon.com/sagemaker/clarify/?sc_channel=el&sc_campaign=datamlwave&sc_geo=mult&sc_country=mult&sc_outcome=acq&sc_content=the-abcs-of-generative-ai) or in the [documentation](https://docs.aws.amazon.com/sagemaker/latest/dg/clarify-fairness-and-explainability.html?sc_channel=el&sc_campaign=datamlwave&sc_geo=mult&sc_country=mult&sc_outcome=acq&sc_content=the-abcs-of-generative-ai). 

## Y is for You Can Build on AWS!

I take pride in the fact this is the only letter I couldn’t think of an “actual” machine learning term for, but Amazon has been developing AI & ML technology for over 25 years, so maybe this is an actual ML term after all? Regardless, there’s a reason so many developers choose AWS to build, train, and deploy their AI/ML models. My most liked (and linked) AWS pages about Artificial Intelligence, Machine Learning, and Generative AI are: 

* [Generative AI on AWS](https://aws.amazon.com/generative-ai/?sc_channel=el&sc_campaign=datamlwave&sc_geo=mult&sc_country=mult&sc_outcome=acq&sc_content=the-abcs-of-generative-ai): I work here, and this is still how I get the most up-to-date information about what’s new and what’s next at AWS for Gen AI. This page is constantly updated to keep up with new announcements and releases, so it’s well worth a bookmark. 
* [AWS for Startups | Generative AI](https://aws.amazon.com/startups/generative-ai/?sc_channel=el&sc_campaign=datamlwave&sc_geo=mult&sc_country=mult&sc_outcome=acq&sc_content=the-abcs-of-generative-ai): If you’re a current (or aspiring) startup founder, this page is a one-stop-shop to learn about the resources and tools available to bring the power and promise of Generative AI to your startup with AWS. My colleague Max and their team wrote a great e-book called ‘Generative AI for every startup,’ which is available on this page too. 
* [Generative AI with LLMs | DeepLearning.AI](https://www.deeplearning.ai/courses/generative-ai-with-llms/): This is a fantastic course from my colleagues Mike and Antje, in collaboration with Andrew Ng from DeepLearning.AI, where you’ll learn the fundamentals of how generative AI works, and how to deploy it in real-world applications.
* [Amazon CodeWhisperer](https://aws.amazon.com/codewhisperer/?trk=a325eb01-2134-4258-a88b-ffc101a7b548&sc_channel=sm): If you’re new to AI/ML, there’s going to be a lot of new information for you to take in all at once. Amazon CodeWhisperer (your AI-powered coding sidekick) will free up some of the mental load for you, so you can focus on what you’re building. 
* [Amazon Machine Learning University (MLU) Explain](https://mlu-explain.github.io/): MLU was once Amazon’s internal training program for AI/ML, but it was made public a few years ago, and MLU-Explain remains as one of my favorite AI/ML learning resources of all time. If you’re having trouble understanding some of the big theoretical concepts in ML, these interactive articles will help you to visualize what’s happening behind the scenes. 
* [AWS Certified Machine Learning - Specialty](https://aws.amazon.com/certification/certified-machine-learning-specialty/?sc_channel=el&sc_campaign=datamlwave&sc_geo=mult&sc_country=mult&sc_outcome=acq&sc_content=the-abcs-of-generative-ai): This certification is not easy, but it’s worthwhile! It’s easy to end up with knowledge gaps in your AI/ML education, because there are so many topics to cover. But this certification (and the related learning materials in [AWS Skill Builder](https://skillbuilder.aws/)) will give you a great foundation to work from, and give you the skills to keep building and deploying models on AWS. 

## Z is for Zero-Shot Learning

Zero-Shot Learning is a technique in Machine Learning where a model is trained to make predictions or classifications on data it hasn’t seen during it’s training phase. The concept uses [vectors](#v-is-for-vector-databases) to map inputs, like text or videos, to a semantic space where meanings are clustered. From here, the model can classify or predict based on proximity to known concepts in that space by looking at the distances between vectors. Zero-Shot Learning is useful for areas like Natural Language Processing (NLP), and it provides flexibility and broadens the applications of pre-trained models like [transformers](#t-is-for-transformers) and [foundation models](#f-is-for-foundation-models). 

Learn more about how to perform prompt engineering in zero-shot learning environments in the [Amazon SageMaker Docs](https://docs.aws.amazon.com/sagemaker/latest/dg/jumpstart-foundation-models-customize-prompt-engineering.html?sc_channel=el&sc_campaign=datamlwave&sc_geo=mult&sc_country=mult&sc_outcome=acq&sc_content=the-abcs-of-generative-ai), and learn how to use Zero-Shot learning to [Build a news-based real-time alert system with Twitter, Amazon SageMaker, and Hugging Face on the AWS Machine Learning Blog](https://aws.amazon.com/blogs/machine-learning/build-a-news-based-real-time-alert-system-with-twitter-amazon-sagemaker-and-hugging-face/?sc_channel=el&sc_campaign=datamlwave&sc_geo=mult&sc_country=mult&sc_outcome=acq&sc_content=the-abcs-of-generative-ai).

The ABCs of Generative AI has only scratched the surface with a single term for each letter, but the list of technical terms in AI/ML is vast and ever expanding. There are so many terms and concepts that didn't make it into this initial list, but I'd love to hear them! Dive into the conversation and share the terms you believe deserve a spot using the hashtag #ABCsGenAI on your favorite social media platform.
