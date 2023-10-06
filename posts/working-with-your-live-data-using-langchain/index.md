---
title: "Working With Your Live Data Using Langchain"
description: "Use LangChain with Amazon Bedrock and Amazon DynamoDB and to build aplications to keep conversation with LLMs with consistent and engage in a natural dialogue"

tags:
    - ai-ml
    - generative-ai
    - aws
spaces:
    - generative-ai
showInHomeFeed: true
authorGithubAlias: elizabethfuentes12
authorName: Elizabeth Fuentes 
date: 2023-09-06
---

|ToC|
|---|

When building applications leveraging large language models (LLM), providing the full conversation context in each prompt is crucial for coherence and natural dialogue. Rather than treating each user input as an isolated question (Fig 1), the model must understand how it fits into the evolving conversation. 

![Architecture](images/fig_01.png)
<h4 align="center">Fig 1. Single input conversation.</h4> 

Storing every new entry and response in the message(Fig. 2) makes it bigger and requires more memory and processing. Without optimizing the storage of dialogue history using appropriate techniques to balance performance and natural interaction, resources would quickly stagnate.

![Architecture](images/fig_02.png)
<h4 align="center">Fig 2. Conversation with context.</h4> 

In this blog post, I will show you how to use techniques to efficiently provide conversation context to models with [Langchain](https://www.langchain.com/) to create a conversational agent that can engage in natural dialogue, maintain the context of the conversation by appending each generated response into the prompt to inform the next response. This allows us to have extended, coherent conversations with the agent across multiple turns. By the end, you will have the skill to create your own conversational application powered by the latest advances in generative AI.


| Attributes                |                                   |
| ------------------- | -------------------------------------- |
| ✅ AWS Level        | Intermediate - 200                         |
| 🧩 Prerequisites    | - [AWS Account](https://aws.amazon.com/resources/create-account/?sc_channel=el&sc_campaign=devopswave&sc_content=cicdcfnaws&sc_geo=mult&sc_country=mult&sc_outcome=acq) <br>-  [Foundational knowledge of Python](https://catalog.us-east-1.prod.workshops.aws/workshops/3d705026-9edc-40e8-b353-bdabb116c89c/)    |                           |
| 📢 Feedback            | <a href="https://pulse.buildon.aws/survey/DEM0H5VW" target="_blank">Any feedback, issues, or just a</a> 👍 / 👎 ?    |
| ⏰ Last Updated     | 2023-10-21 

## Let’s get started!

### 1 - Install The [Langchain](https://www.langchain.com/) Library:

```python
pip install langchain
````
Once installed, you can include [all these modules](https://python.langchain.com/docs/get_started) to your application.

### 2 - Create the LLM Invocation: 

The invocation is made using [Amazon Bedrock](https://docs.aws.amazon.com/bedrock/latest/userguide/what-is-service.html), a fully managed service that makes base models from Amazon and third-party model providers accessible through an API.

[Anthropic Claude V2 100K](https://www.anthropic.com/index/claude-2) Model is used in this example. 

To use Amazon Bedrock’s capabilities with Langchan import:

```python
from langchain.llms.bedrock import Bedrock
```

Then create the Amazon Bedrock Runtime Client:

```python
bedrock_client = boto3.client(
    service_name='bedrock-runtime'
)
```

> 📚**Note:** Learn more about Amazon Bedrock LangChain [here](https://python.langchain.com/docs/integrations/llms/bedrock), and Amazon Bedrock client [here](https://boto3.amazonaws.com/v1/documentation/api/latest/reference/services/bedrock-runtime.html) and [here](https://boto3.amazonaws.com/v1/documentation/api/latest/reference/services/bedrock.html).

A [Chain](https://python.langchain.com/docs/modules/chains/), the tool to call the components of the aplication, is need it to generate conversation with the model, set `verbose = True` to make debug and see the internal states of the Chain:  

```python
from langchain.chains import ConversationChain
model_parameter = {"temperature": 0.0, "top_p": .5, "max_tokens_to_sample": 2000} #parameters define
llm = Bedrock(model_id="anthropic.claude-v2", model_kwargs=model_parameter,client=bedrock_client) #model define
conversation = ConversationChain(
    llm=llm, verbose=True
)
```

Test the Chain with this line: 

```python
conversation.predict(input="Hello world!")
```

![Amazon Bedrock Chain](images/gif_02.gif)

Additionally, you can invoke the Amazon Bedrock API directly with the [Invoke Model API](https://boto3.amazonaws.com/v1/documentation/api/latest/reference/services/bedrock-runtime/client/invoke_model.html):

```python 
prompt = "Hello world!"
kwargs = {
  "modelId": "ai21.j2-ultra-v1",
  "contentType": "application/json",
  "accept": "*/*",
  "body": "{\"prompt\":\"Human:"+ prompt +"\\nAssistant:\",\"maxTokens\":200,\"temperature\":0.7,\"topP\":1,\"stopSequences\":[],\"countPenalty\":{\"scale\":0},\"presencePenalty\":{\"scale\":0},\"frequencyPenalty\":{\"scale\":0}}"
}
response = bedrock_client.invoke_model(**kwargs)
response_body = json.loads(response.get("body").read())
completetion = response_body.get("completions")[0].get("data").get("text")
completetion

```

![Amazon Bedrock invoke model](images/gif_01.gif)


### 3 - Add Chat Memory To The Chain:

There are different memory type in [LangChain](https://python.langchain.com/docs/modules/memory/types/), but in this blog we are going to review the following:

<table>
<tr>
<th> Memory Type </th> <th> Description </th> <th> Code </th>
</tr>
<tr>
<td><b> ConversationBufferMemory </b></td> 
<td> Using this memory allows you to store all the messages in the conversation. </td>  

<td>

```python
from langchain.memory import ConversationBufferMemory
memory = ConversationBufferMemory(return_messages=True)
```
</td>
</tr>
<tr>
<td><b> ConversationBufferWindowMemory </b></td> 
<td> Limits the dialogue history size to the most recent K interactions. Older interactions are discarded as new ones are added to keep the size fixed at K. </td>  

<td>

```python
from langchain.memory import ConversationBufferWindowMemory
memory = ConversationBufferMemory(k=1,return_messages=True)
```
</td>
</tr>
<tr>
<td><b> ConversationSummaryMemory </b></td> 
<td> This uses a LLM model to created a summary of the conversation and then injected into a prompt, useful for a large conversations. </td>  

<td>

```python
from langchain.memory import ConversationSummaryMemory
memory = ConversationSummaryMemory(llm=llm,return_messages=True)
```
</td>
</tr>

<tr>
<td><b> ConversationSummaryBufferMemory </b></td> 
<td> Use both the buffer and the summary, stores the full recent conversations in a buffer and also compiles older conversations into a summary. </td>  

<td>

```python
from langchain.memory import ConversationSummaryBufferMemory
memory = ConversationSummaryBufferMemory(llm=llm, max_token_limit=10,return_messages=True)
```
</td>
</tr>

<tr>
<td><b> ConversationTokenBufferMemory </b></td> 
<td> Keeps a buffer of recent interactions in memory, and uses token length rather than number of interactions to determine when to flush interactions. </td>  

<td>

```python
from langchain.memory import ConversationTokenBufferMemory
memory = ConversationTokenBufferMemory(llm=llm, max_token_limit=10,return_messages=True)
```
</td>
</tr>

</table>

> 📚**Note:** In all types of memory belong the parameter return_messages=True is present, this to get the history as a list of messages

### 4 - Try it!

To try the memory add as a parameter in the Chain.

```python

#add the memory to the Chain
conversation = ConversationChain(
    llm=llm, verbose=True, memory=memory
)
```
Test the Chain: 

```python
conversation.predict(input="Hi, my name is Elizabeth!")
conversation.predict(input="what's up?")
conversation.predict(input="cool, What is my name?")

memory.load_memory_variables({}) #To print the memory
```

In the following gif you see an example of the ConversationBufferMemory. 

![ConversationBufferMemory](images/gif_03.gif)

Try the differents memories types and check the differences. 

## 5 - Save The Conversation Memory In An Amazon DynamoDB Table.

Do this using the LangChain integration [module](https://python.langchain.com/docs/integrations/memory/aws_dynamodb) with [Amazon DynamoDB](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/Introduction.html)

Following the instructions in the LangChain documentation:

- Create the Amazon DynamoDB: 

```python
# Get the service resource.
dynamodb = boto3.resource("dynamodb")

# Create the DynamoDB table.
table = dynamodb.create_table(
    TableName="SessionTable",
    KeySchema=[{"AttributeName": "SessionId", "KeyType": "HASH"}],
    AttributeDefinitions=[{"AttributeName": "SessionId", "AttributeType": "S"}],
    BillingMode="PAY_PER_REQUEST",
)
```

- Add Chat Memory To The Chain:

```python
from langchain.memory.chat_message_histories import DynamoDBChatMessageHistory
message_history = DynamoDBChatMessageHistory(table_name="SessionTable", session_id="1")
memory = ConversationBufferMemory(
    memory_key="history", chat_memory=message_history, return_messages=True,ai_prefix="A",human_prefix="H"
)
#add the memory to the Chain
conversation = ConversationChain(
    llm=llm, verbose=True, memory=memory
)
```

- Try It!

```python
conversation.predict(input="Hi, my name is Elizabeth!")
conversation.predict(input="what's up?")
conversation.predict(input="cool, What is my name?")

# Print the memory
memory.load_memory_variables({}) 

# Print item count
print(table.item_count)
```

See you have a new record in the DynamoDB table:

![Architecture](images/fig_03.png)
<h4 align="center">Fig 3. New record in the Amazon DynamoDB table.</h4> 

## Conclusion

Thank you for joining me on this journey where you gained the skills necessary to keep conversation with LLMs with consistent and engage in a natural dialogue using the memories module of [Langchain](https://www.langchain.com/), using the Amazon Bedrock API to invoke LLMs models and storing memory: history of conversations in an Amazon DynamoDB. 

Some links for you to continue learning and building:

- [ntegrating Foundation Models into Your Code with Amazon Bedrock](https://www.youtube.com/watch?v=ab1mbj0acDo)

- [Amazon Bedrock Workshop](https://github.com/aws-samples/amazon-bedrock-workshop)

- [AWS Kendra Langchain Extensions](https://github.com/aws-samples/amazon-kendra-langchain-extensions/tree/main)

- [Prompt Engineering Techniques](https://www.promptingguide.ai/techniques). 

- [Learn the fundamentals of generative AI for real-world applications](https://www.deeplearning.ai/courses/generative-ai-with-llms/)

- [LangChain for LLM Application Development](https://www.deeplearning.ai/short-courses/langchain-for-llm-application-development/)

