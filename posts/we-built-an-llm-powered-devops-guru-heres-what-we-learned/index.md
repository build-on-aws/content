---
title: "We Built an LLM-Powered DevOps Guru. Here's What We Learned Along the Way"
description: "A team of AWS applied scientists tried to help DevOps engineers. They learned a lot about large language models as they did."
tags:
  - llms
  - gen-ai
  - generative-ai
  - devops
  - aws
spaces:
  - generative-ai
waves:
  - generative-ai
authorGithubAlias: haywse
authorName: Wooseok Ha
additionalAuthors:
  - authorGithubAlias: Linbo-Liu
    authorName: Linbo Liu
  - authorGithubAlias: behroozomidvar
    authorName: Behrooz Omidvar-Tehrani
  - authorGithubAlias: lukejhuan
    authorName: Luke Huan
date: 2023-12-20
---

|ToC|
|---|

![a human hand reaches toward a robotic hand, which extends from the screen of a computer](images/headerimage.jpeg)

Generative AI has been grabbing headlines for over a year now, but while general large language models (LLMs) are among the most visible implementations of the technology, more specialized implementations have been rapidly changing how developers build and interface with cloud technology on many levels. We are a team of applied scientists at AWS that has been using the incredible power of LLMs to support a particular process: helping DevOps engineers to troubleshoot operational problems more effectively.

While we built [our tool, called DevOps Guru](https://docs.aws.amazon.com/devops-guru/?sc_channel=el&sc_campaign=genaiwave&sc_geo=mult&sc_country=mult&sc_outcome=acq&sc_content=we-built-an-llm-powered-devops-guru-heres-what-we-learned), we learned a great deal about the limitations of LLMs in a DevOps setting, the challenges of knowledge graph construction, and — perhaps most interestingly — the unpredictable nature of prompts. These limitations led us to dive deeper into prompt engineering as a means to circumvent them. In this blog, we share the insights acquired through this exploration and offer practical suggestions for extracting optimized output from LLMs despite these constraints.

## The Project

Over recent months, our science team at DevOps Guru has pursued two primary work streams to leverage the potential of large language models (LLMs) to enhance the user experience in troubleshooting operational issues:

1. Developing an interactive troubleshooting chat system that not only offers root cause analyses and remediation recommendations for operational issues but also allows for an engaging dialogue user interface, enabling users to ask follow-up questions based on initial recommendations and receive responsive feedback.
2. Utilizing LLMs to construct the DevOps operational knowledge graph, a process which involves analyzing vast amount of unstructured textual data to extract SIR (Symptom-Issue-Recommendation) triplets, thus forming a structured representation of DevOps knowledge derived from AWS textual resources.

Through extensive utilization of LLMs in these dual work streams, we encountered certain limitations of LLMs in handling basic prompts as anticipated.

## Defining the Limitations of LLMs in DevOps

DevOps interactive troubleshooting is an automated chat system that can analyze the root cause of a given “insight” and provide remediation recommendations, while allowing users to ask follow-up questions. Because LLMs are trained on large scale datasets and store knowledge in their parametric memory, when tasked with addressing specific questions, such as those related to AWS troubleshooting, an LLM can occasionally generate responses based on "hallucinated" or erroneous knowledge, reducing the reliability of the output.

Through our empirical study, we have found that the foundational LLM supporting DevOps interactive troubleshooting is usually prone to two major limitations: 1) Stochasticity: With exactly identical prompts, the LLM generated different responses with varying quality due to its probabilistic nature and empirical implementation, even when temperature was set to zero. 2) Lack of robustness to the change in the prompt: Minor alteration in the phrasing of a prompt, even those that preserve the semantic intent, can result in different responses with varying quality.

Below we provide specific instances in OpenAI’s GPT-3.5.

### Stochasticity

Stochasticity refers to the variable outputs of an LLM given identical inputs (or prompts). We provided the following prompt to ChatGPT, along with information from the AWS Knowledge Center pages for additional context.

**Prompt:**

> ```
> How do I troubleshoot issues with my Amazon EFS volume mounts in Amazon EKS? Specifically, I'm seeing 'mount.nfs: Connection timed out' error. What is the root cause? Can you recommend an action to resolve the error? Let's think step by step.
> ```

We obtained two different responses over the course of two runs.

**Answer 1:**

`The "mount.nfs: Connection timed out" error can occur when there is an issue with the security group associated with your EFS file system and worker nodes. Here are the steps you can take to troubleshoot and resolve the issue:`

**Answer 2:**

`The "mount.nfs: Connection timed out" error when mounting Amazon EFS volumes in Amazon EKS can have several root causes. Here are some steps you can take to troubleshoot and resolve the issue:`

Answer 1 was able to immediately identify the root cause based on the Knowledge Center page. It provided the correct recommendation in the first place, although later suggested a few irrelevant solutions. Answer 2 failed to provide a precise root cause ("can have several root causes"). It had the correct recommendation in the second place. Given these observations, we consider Answer 1 having much higher quality than Answer 2.

### Robustness 

Robustness, for our purposes, refers to consistent quality of ouput given minor alterations in prompt phrasing - even when those alterations maintain the semantic intent. Below, we provided two nearly identical prompts, which yielded drastically different responses. Although stochasticity can often be the cause of varied responses, we conducted the conversation three times to verify that the differences in quality were not a result of stochasticity.

**Prompt 1:**

`How do I troubleshoot issues with my Amazon EFS volume mounts in Amazon EKS? Specifically, I'm seeing 'mount.nfs: Connection timed out' error. What is the root cause? Can you recommend an action to resolve the error? Only provide me with the most likely root cause. Be specific about your remediation recommendations. Let's think step by step.`

**Prompt 2:**

`How do I troubleshoot issues with my Amazon EFS volume mounts in Amazon EKS? Specifically, I'm seeing 'mount.nfs: Connection timed out' error. What is the root cause? Can you recommend an action to resolve the error? Only provide me with the most likely root cause. Be specific about remediation recommendations. Let's think step by step.`

We found prompt 2 generated a response with higher quality.

**Prompt 1:**

`What actions should I take to perform the recommendations provided in the above conversation?`

**Prompt 2:**

`What action should I take to perform the recommendations provided in the above conversation?`

**Prompt 3:**

`How to perform the recommendations provided in the above conversation?`

We found prompt 2 generated recommendations of better quality.

## Developing Strategies for Leveraging the LLM

Knowledge graph (KG) is a powerful tool for organizing and integrating information about complex datasets. In the DevOps context, knowledge graphs can be leveraged as the foundational infrastructure for retrieving and reasoning over the AWS operational knowledge, thereby creating guidance for the customer, such as DevOps Guru insights. The DevOps Guru KG consists of different types of nodes, including AWS resources (e.g. Elastic Load Balancer, Lambda, ElastiCache), symptoms (e.g. increase in latency, occurrence of the error HTTP 503), and operational issues and recommendations for the symptoms. Given a set of symptoms as input, we retrieve issues and recommendations using SIR traversals (Symptom → Issue → Recommendation). While manually constructing the DevOps knowledge graph from a multitude of sources can pose a significant challenge due to its labor-intensive and time-consuming nature, we leveraged the expressive power of LLMs to automate the process of knowledge extraction and reduce human supervision efforts in constructing the knowledge graph. 

In the process of KG construction, sets of symptoms along with related issues and recommendations are extracted from textual sources, which requires a well-structured chain-of-thought process to achieve high-quality output. Furthermore, the LLM’s output needs to be processed before being stored in the DevOps KG system, often requiring the output to follow a specific format. Below we illustrate instances where the LLM may exhibit limitations when prompted to extract knowledge in the context of DevOps - and what solutions we discovered to ameliorate the challenges.

### Avoid Overloading with Conversation History

When prompting LLMs with a chain-of-thoughts, we provide the model with conversation history. This allows the model to remember the context from our previous conversation and make better inferences for the current query. However, we have found that an excessive amount of conversation history can distract the model, making it difficult to focus on the given query. This can lead to degraded quality of model’s response on knowledge extraction. 

**Prompt:**

`Can you identify the primary root causes related to Replication lag in Amazon ElastiCache Redis? Present this information as an enumerated list, formatted as follows:`

`Example: The primary root causes related to Replication lag in Amazon ElastiCache Redis are:`     
`1. First identified cause`       
`2. Second identified cause`      
`3. ...`

**Answer from the LLM with Overloaded Conversation History:**

`According to the provided context, high replication lag in Amazon ElastiCache Redis is generally a side effect of excessive write activity, network capacity exhaustion, or underlying service degradation. Additionally, synchronization of Redis is initiated during backup, replacement, and scaling events, which is a compute-intensive workload that can cause latencies. It's also important to control the volume of new connections when using the ElastiCache in-transit encryption feature due to the extra time and CPU utilization needed by the TLS handshake.`

**By contrast, here is the answer from the LLM without Overloaded Conversation History:**

`The primary root causes related to Replication lag in Amazon ElastiCache Redis are:`
`1. Excessive write activity: High replication lag is generally a side effect of excessive write activity.`
`2. Network capacity exhaustion: Replication lag can be caused by network exhaustion.`
`3. Underlying service degradation: Replication lag can also be caused by underlying service degradation.`
`4. Full synchronization: Full synchronization is a more complex process, involving the creation of a snapshot on the primary node, and could lead to performance degradation.`
`5. Slow commands: Slow commands can block the Redis engine and cause an increase in the EngineCPUUtilization metric in CloudWatch.`

The above examples suggest that LLMs overloaded with conversation history may not follow the response format as reliably as LLMs that are not overloaded. This indicates the potential influence of the volume of conversation history on the LLM’s ability to accurately respond to prompts. Furthermore, storing excessive conversation history can consume a substantial portion of the available input tokens, limiting the number of tokens available for input prompts including the retrieved documents and user query. This is an example of a token limit error message caused by storing excessive conversation history:

`InvalidRequestError: This model's maximum context length is 4097 tokens. However, your messages resulted in 4164 tokens. Please reduce the length of the messages.`

### Do Not Request Output in JSON Format 

The LLM sometimes makes an error when processing prompts to output response in JSON format. 

**Prompt:**

`Can you identify the primary root causes related to {ops_issue} in Amazon ElastiCache Redis? Present this information in a JSON format, where the key is "root_causes" and the value is a list containing these root causes.`

**Answer:**

`I'm sorry, but the given context does not provide a JSON format with the key "root_causes" and a list of values related to the primary root causes of Replication lag in Amazon ElastiCache Redis. However, based on the context provided, some of the primary root causes of Replication lag in Amazon ElastiCache Redis include excessive write activity, network capacity exhaustion, and underlying service degradation.`

## Developing Best Practices for Prompt Engineering

Our science team made several observations and implemented various solutions to address the limitations outlined above. Below, we detail these findings and the strategies we have devised to mitigate the identified issues:

First, stochasticity shows that even identical prompts could lead to different responses due to the stochastic nature of LLMs. To mitigate this issue, we can leverage customer feedback to refine the effectiveness of the recommendations provided. By recording the utility scores assigned by customers to different suggestions generated from the same prompt, we can prioritize recommendations with higher scores, thus gradually enhancing the utility of the responses over time.

We can address the issue of model robustness by introducing a prompt template that utilizes question calibration. To this end, we can collect best practices for prompt engineering through crowdsourcing, which allows us to construct a database of templates. For each user’s query, we first retrieve the most similar query from the template database and calibrate the question by the template before passing into LLM. Specifically, in Phase I, we extract the most similar query template from our database to align with the user’s initial question. This calibration step serves to reshape the question into a format that can elicit a high-quality response. In Phase II, the revised query is then entered into the LLM, which leverages LLM to generate remediation recommendations. Regarding the prompt templates, we find that:

1. Substituting `how to` with `what action should I take` to tends to yield higher quality response.
2. Incorporating the title of relevant Knowledge Center pages when providing additional context allows elicits responses with more precise insights to be derived from the Knowledge center pages. 
3. By prompting the LLM to `Be specific about the remediation recommendations`, we direct it to provide detailed and actionable insights with more concrete resolutions.

Additionally, it is recommended to avoid overloading an extensive conversation history, as it can potentially hurt the efficiency of the response generation. Moreover, caution is advised when requesting outputs in JSON format, given that it can often diminish the quality of the model’s responses. 

## Conclusion and Discussion of Potential Use Cases

After our experimentation, we arrived at a complicated truth: LLMs offer promise when applied to technical troubleshooting, but they also face limitations. More specifically, the chat system powered by LLMs for interactive troubleshooting enriches the user experience where users can benefit from a root-cause analysis and remediation recommendations; furthermore, it allows for engagement through interactive dialogue which can address follow-up questions. What’s more, the automation of knowledge graph construction through LLMs streamlines knowledge extraction from a vast amount of textual sources, thereby minimizing human effort and enhancing efficiency.

But LLMs often exhibit stochastic behavior, generating varying responses to identical or slightly altered prompts. This inconsistency raises concerns regarding their reliability. Moreover, chain-of-thought prompting presents risks of overloading the system with an extensive conversation history and while utilizing JSON format for output processing seems a reasonable step, it introduces more limitations.

To address these issues, we developed strategies to enable a more reliable and efficient system. Leveraging customer feedback to refine utility scores and employing structured templates for question calibration can introduce stability and enhance the reliability of system responses. Likewise, careful management of conversation history, and improving prompt phrasing for the output format can be a viable solutions to several challenges. 

We believe that our exploration of LLMs extends beyond DevOps, and we recognize its potential applicability across diverse contexts and scenarios - especially when developing LLM-powered chat systems, a prevalent application of LLMs, for various domains. Imagine a chat system designed to address and summarize customer queries on app usage, and to respond to any subsequent questions. Customers’ questions can significantly vary in phrasing, and directly inputting them into LLMs poses a risk, as the stochasticity and robustness issues may degrade the accuracy of responses. This inaccuracy can be particularly detrimental during production, potentially decreasing customer trust and satisfaction.

By analyzing the intent of customer questions and implementing a question calibration, we can anticipate responses of high accuracy from LLMs. But lengthy conversations and extensive customer usage data can easily overload the system’s conversation history. That said, providing the entire conversation history is often unnecessary to generate accurate responses to customer questions. In such cases, we can analyze conversation flows to determine the necessary history to be provided to LLMs for current responses. This not only ensures the system’s efficient operation by preventing it from being overwhelmed with information but also maintains the accuracy and relevance of response, thereby enhancing user experience and trust in the LLM-powered chat system.

Enhancing systems’ robustness and output quality through prompt engineering is a continuous endeavor. It is crucial to experiment with varying prompts to find the anticipated response from LLMs, iterating through different prompt engineering techniques and question calibrations. Resources such as OpenAI’s Best Practices for Prompt Engineering can also be valuable guides in determining the optimal prompts for different use cases. We encourage practitioners to engage in the dynamic area of prompt engineering, leveraging the potentials of LLMs to build a system with better user experiences.
