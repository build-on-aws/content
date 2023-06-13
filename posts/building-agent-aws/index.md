---
title: "Building an AWS Solution Architect Agent with Generative AI"
description: "Tips and guidance on building a Generative AI Agent."
tags:
  - agents
  - python
  - huggingface
  - gen-ai
authorGithubAlias: aws-banjo
authorName: Banjo Obayomi
date: 2023-06-13
---

The advent of Generative AI has paved the way for new automation and efficiency possibilities. This technology allows builders to design intelligent agents capable of executing a wide range of tasks. Among the challenges encountered when building on AWS are understanding best practices, writing code, and creating architectural diagrams. That's where we can build an AWS Solution Architect Agent, powered by Generative AI to fill in the gaps.

## Agent AWS

Agent AWS is an automated, AI-powered agent that uses [HuggingFace Transformers](https://huggingface.co/docs/transformers/en/transformers_agents) paired with numerous different [foundation models](https://docs.aws.amazon.com/sagemaker/latest/dg/jumpstart-foundation-models.html).

The "agent" is essentially a Large Language Model (LLM) with a predefined prompt and access to a specific set of “tools”, which are self-contained functions designed to perform a specific task. For instance, these tools could include a text summarizer or an image generator. Agent AWS leverages custom built tools to query AWS documentation, generate code, and create architectural diagrams.

![Agent AWS generates code](images/code_example.png)

## Building Agent AWS

The following sections elaborates on how Agent AWS was built, focusing on the design process of the agent and tools. It shows how you can harness the potential of Generative AI for developing custom agents.

The GitHub repository with the code can be found [here](https://github.com/aws-banjo/building-aws-agent).

## Agent Prompt

The language model underlying the agent is based on a detailed prompt provided by the user. This prompt helps the model generate suitable responses to user requests.

### Structure of the prompt

The prompt is structured broadly into two parts.
1.	Role: How the agent should behave, explanation of the concept of tools.
2.	Instructions: Provides examples of tasks and their solutions

### Role
To start, the agent is assigned a role to play. In this case the agent is portrayed as an expert AWS Certified Solutions Architect equipped with tools to solve customer problems effectively. The role description is followed by the token <<all_tools>>, which is replaced at runtime with the tools specified by the user.

Here is the full role prompt below

```text
You are an expert AWS Certified Solutions Architect. Your role is to help customers understand best practices on building on AWS. You will generate Python commands using available tools to help will customers solve their problem effectively.

To assist you, you have access to three tools. Each tool has a description that explains its functionality, the inputs it takes, and the outputs it provides.

First, you should explain which tool you'll use to perform the task and why. Then, you'll generate Python code. Python instructions should be simple assignment operations. You can print intermediate results if it's beneficial.
Tools:
<<all_tools>>
```

### Instructions

The Instructions segment starts with a task explaining what the agent intends to accomplish. This is followed by the agent's response on how it will utilize the tools to resolve the customer request. Finally, we provide the code the agent will use to address the user's query. The last example must use <<prompt>> directive to show the model how to respond from a new prompt.

```text
Task: "Help customers understand best practices on building on AWS by using relevant context from the AWS Well-Architected Framework."
I will use the AWS Well-Architected Framework Query Tool because it provides direct access to AWS Well-Architected Framework to extract information.
Answer:
"""py
response = well_architected_tool(query="How can I design secure VPCs?")
print(f"{response}.")
"""

Task: "<<prompt>>"
I will use the following
```
You can view the full prompt [here](https://github.com/aws-banjo/building-aws-agent/blob/main/agent_setup.py#L20-L63).

## Tools

Now that we have defined our agent, the next step is to create the tools for the agent to use. Tools are very simple: they’re a single function, with a name, and a description. The descriptions are used to prompt the agent to complete tasks.

## Creating Custom tools 

For Agent AWS we will create 3 custom tools to respond to customer requests.

1.	AWS Well-Architected Framework Query Tool: This tool will allow your agent to interact directly with the AWS Well-Architected Framework, extracting valuable data to inform architectural decisions.
2.	Code Generation Tool: This tool will generate code from AWS CloudFormation scripts to Python code.
3.	Diagram Creation Tool: This tool will create AWS diagrams.

The process of creating tools is a uniform experience. I will go over how I created the AWS Well-Architected Framework tool in this post. You can view the full code for all the tools [here](https://github.com/aws-banjo/building-aws-agent/blob/main/agent_setup.py#L66-L290).

## Querying the AWS Well-Architected Framework

The first tool we built is capable of querying the AWS Well-Architected Framework. This tool utilizes a vector database to find relevant answers to user questions. For more details on how to build vector database solutions check out my previous [post](https://www.buildon.aws/posts/well-arch-chatbot).

To create a tool that can be used by our agent, we first create a class that inherits from the superclass Tool:

```python
from transformers import Tool

class AWSWellArchTool (Tool):
    pass
```

This class needs the following attributes:

1. name: This is the name of the tool.
2. description: This will be used to populate the prompt of the agent.
3. inputs and outputs: These help the interpreter make educated choices about types. They are both a list of expected values, which can be text, image, or audio.
4. A call method: This contains the inference code.

So, our class now looks like this:

```python
from transformers import Tool

class AWSWellArchTool(Tool):
    name = "well_architected_tool"
    description = "Use this tool for any AWS related question to help customers understand best practices on building on AWS. It will use the relevant context from the AWS Well-Architected Framework to answer the customer's query. The input is the customer's question. The tool returns an answer for the customer using the relevant context."
    inputs = ["text"]
    outputs = ["text"]

    def __call__(self):
        pass 
```

The call method is then filled with the code to do the relevant document search. When the tool is completed, it can be invoked without an agent.

```python
query = "How can I design secure VPCs?"
well_arch_tool = AWSWellArchTool()
well_arch_tool(query)
```

![Agent AWS gets answer to customer question](images/query_example.png)

## Exploring the Agent in Action

After the tools and prompt have been configured, we can finally see what Agent AWS can do. To start the agent we select what LLM to use (StarcoderBase https://huggingface.co/bigcode/starcoderbase for this example) our custom prompt, and additional tools. I also remove the default tools to ensure the agent uses only the custom tools.

```python
import transformers
from transformers import Tool
from transformers.tools import HfAgent

sa_prompt = PROMPT # the prompt is here

# Start Agent
agent = HfAgent("https://api-inference.huggingface.co/models/bigcode/starcoderbase", run_prompt_template=sa_prompt,additional_tools=[code_gen_tool,well_arch_tool])

default_tools = ['document_qa',
 'image_captioner',
 'image_qa',
 'image_segmenter',
 'transcriber',
 'summarizer',
 'text_classifier',
 'text_qa',
 'text_reader',
 'translator',
 'image_transformer',
 'text_downloader',
 'image_generator',
 'video_generator',
]

# Remove default tools
for tool in default_tools:
    try:
        del agent.toolbox[tool]
    except:
        continue
```

With the agent initialized, we can now run commands that invoke the tools. For instance, the command

```python
agent.run("A diagram that shows an s3 bucket connected to a lambda function")
```

This will result in the output from the agent to use the purpose-built tool to solve the customer’s request and return an image.

```python
==Explanation from the agent==
I will use the following
==Code generated by the agent==
architecture_diagram = diagram_creation_tool(query=" A diagram that shows an s3 bucket connected to a lambda function")
==Result==
<class 'PIL.PngImagePlugin.PngImageFile'>
```

![Agent AWS creates a diagram](images/diagram_example.png)

The code for the app is [here](https://github.com/aws-banjo/building-aws-agent/blob/main/agent_aws_st.py).

## Conclusion

Throughout this post, I've taken you through the process of building an AWS Solution Architect Agent, leveraging HuggingFace Transformers and different foundation models for purpose-built tools. The potential of Generative AI Agents is immense and we've just scratched the surface. Agent AWS is just the beginning, and there's much more that can be achieved within the agent/tool framework. Now go build!!!!

## About the Author

Banjo is a Senior Developer Advocate at AWS, where he helps builders get excited about using AWS. Banjo is passionate about operationalizing data and has started a podcast, a meetup, and open-source projects around utilizing data. When not building the next big thing, Banjo likes to relax by playing video games, especially JRPGs, and exploring events happening around him.