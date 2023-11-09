---
title: "Building LangChain applications with Amazon Bedrock and Go - An introduction"  
description: "How to extend the LangChain Go package to include support for Amazon Bedrock."
tags:  
  - generative-ai
  - ai-ml
  - go
  - amazon-bedrock
  - langchain
spaces:
  - generative-ai
waves:
  - generative-ai
authorGithubAlias: abhirockzz
authorName: Abhishek Gupta
date: 2023-11-08
---

|ToC|
|---|

One of our earlier blog posts discussed the initial steps for [diving into Amazon Bedrock by leveraging the AWS Go SDK](/concepts/amazon-bedrock-golang-getting-started). Subsequently, our second blog post expanded upon this foundation, showcasing [a Serverless Go application designed for image generation with Amazon Bedrock and AWS Lambda](/tutorials/amazon-bedrock-lambda-image-gen-golang).

[Amazon Bedrock](https://docs.aws.amazon.com/bedrock/latest/userguide/what-is-bedrock.html?sc_channel=el&sc_campaign=genaiwave&sc_content=amazon-bedrock-langchaingo&sc_geo=mult&sc_country=mult&sc_outcome=acq) is a fully managed service that makes base models from Amazon and third-party model providers (such as Anthropic, Cohere, and more) accessible through an API. The applications demonstrated in those blog posts accessed Amazon Bedrock APIs directly, thereby avoiding any additional layers of abstraction or frameworks/libraries. This approach is particularly effective for learning and crafting straightforward solutions.

But, developing generative AI applications goes beyond simply using large language models (LLMs) via an API. You need to think about other parts of the solution which include intelligent search (also known as semantic search that often requires specialized data stores), orchestrating sequential workflows (for e.g. invoking another LLM based on the previous LLM response), loading data sources (text, PDF, links etc.) to provide additional context for LLMs, maintaining historical context (for conversational/chatbot/QA solutions) and much more. Implementing these features from scratch can be difficult and time-consuming.

Enter [LangChain](https://www.langchain.com/), a framework that provides off the shelf components to make it easier to build applications with language models. It is supported in multiple programming languages. This obviously includes Python, but also JavaScript, Java and Go.

[langchaingo](https://github.com/tmc/langchaingo) is the LangChain implementation for the Go programming language. This blog post covers how to extend `langchaingo` to use foundation model from Amazon Bedrock.

> The code is available [in this GitHub repository](https://github.com/build-on-aws/langchaingo-amazon-bedrock-llm)

## LangChain modules

One of `LangChain`'s strength is its extensible architecture - the same applies to the `langchaingo` library as well. It supports components/modules, each with interface(s) and multiple implementations. Some of these include:

- [Models](https://github.com/tmc/langchaingo/tree/main/llms) - These are the building blocks that allow LangChain apps to work with multiple language models (such as ones from Amazon Bedrock, OpenAI, etc.). 
- [Chains](https://github.com/tmc/langchaingo/tree/main/chains) - These can be used to create a sequence of calls that combine multiple models and prompts.
- [Vector databases](https://github.com/tmc/langchaingo/tree/main/vectorstores) - They can store unstructured data in the form of vector embedding. At query time, the unstructured query is embedded and semantic/vector search is performed to retrieve the embedding vectors that are 'most similar' to the embedded query.
- [Memory](https://github.com/tmc/langchaingo/tree/main/memory) - This module allows you to persist state between chain or agent calls. By default, chains are stateless, meaning they process each incoming request independently (same goes with LLMs).

This provides ease of use, choice and flexibility while building LangChain powered Go applications. For example, you can change the underlying Vector database in your by swapping the implementation with minimal code changes. Since `langchaingo` provides many large language models implementation - the same applies here as well.

## `langchaingo` implementation for Amazon Bedrock

As mentioned before, Amazon Bedrock process access to [multiple models](https://docs.aws.amazon.com/bedrock/latest/userguide/what-is-bedrock.html#models-supported?sc_channel=el&sc_campaign=genaiwave&sc_content=amazon-bedrock-langchaingo&sc_geo=mult&sc_country=mult&sc_outcome=acq) including Cohere, Anthropic etc. We will cover how to extend Amazon Bedrock to build a plugin for the Anthropic Claude (v2) model, but the guidelines apply to other models as well.

Let's walk through the implementation at a high-level.

Any custom model (LLM) implementation has to satisfy `langchaingo` [LLM](https://pkg.go.dev/github.com/tmc/langchaingo/llms#LLM) and [LanguageModel](https://pkg.go.dev/github.com/tmc/langchaingo/llms#LanguageModel) interfaces. So it implements `Call`, `Generate`, `GeneratePrompt` and `GetNumTokens` functions.

The key part of the implementation is in the [Generate function](https://github.com/build-on-aws/langchaingo-amazon-bedrock-llm/blob/main/claude/llm.go#L88). Here is a breakdown of how it works.

1. The first step is to prepare the JSON payload to be sent to Amazon Bedrock. This contains the prompt/input along with other configuration parameters.

```go
//...
	payload := Request{
		MaxTokensToSample: opts.MaxTokens,
		Temperature:       opts.Temperature,
		TopK:              opts.TopK,
		TopP:              opts.TopP,
		StopSequences:     opts.StopWords,
	}

	if o.useHumanAssistantPrompt {
		payload.Prompt = fmt.Sprintf(claudePromptFormat, prompts[0])
	} else {
 	}

	payloadBytes, err := json.Marshal(payload)
	if err != nil {
		return nil, err
	}
```

It is represented by the [Request struct](https://github.com/build-on-aws/langchaingo-amazon-bedrock-llm/blob/main/claude/model.go#L3) which is marshalled into JSON before being sent to Amazon Bedrock.

```go
type Request struct {
	Prompt            string   `json:"prompt"`
	MaxTokensToSample int      `json:"max_tokens_to_sample"`
	Temperature       float64  `json:"temperature,omitempty"`
	TopP              float64  `json:"top_p,omitempty"`
	TopK              int      `json:"top_k,omitempty"`
	StopSequences     []string `json:"stop_sequences,omitempty"`
}
```

2. Next Amazon Bedrock is invoked with the payload and config parameters. Both synchronous and streaming invocation modes are supported.

> The streaming/async mode will be demonstrated in an example below

```go
//...
	if opts.StreamingFunc != nil {

		resp, err = o.invokeAsyncAndGetResponse(payloadBytes, opts.StreamingFunc)
		if err != nil {
			return nil, err
		}

	} else {
		resp, err = o.invokeAndGetResponse(payloadBytes)
		if err != nil {
			return nil, err
		}
	}
```

This is how the asynchronous invocation path is handled - the first part involves using the [InvokeModelWithResponseStream](https://pkg.go.dev/github.com/aws/aws-sdk-go-v2/service/bedrockruntime#Client.InvokeModelWithResponseStream) function and then handling [InvokeModelWithResponseStreamOutput](https://pkg.go.dev/github.com/aws/aws-sdk-go-v2/service/bedrockruntime#InvokeModelWithResponseStreamOutput) response in the `ProcessStreamingOutput` function.

> You can refer to the details in **Using the Streaming API** section [in this blog post](/concepts/amazon-bedrock-golang-getting-started#using-the-streaming-api).

```go
//...
func (o *LLM) invokeAsyncAndGetResponse(payloadBytes []byte, handler func(ctx context.Context, chunk []byte) error) (Response, error) {

	output, err := o.brc.InvokeModelWithResponseStream(context.Background(), &bedrockruntime.InvokeModelWithResponseStreamInput{
		Body:        payloadBytes,
		ModelId:     aws.String(o.modelID),
		ContentType: aws.String("application/json"),
	})

	if err != nil {
		return Response{}, err
	}

	var resp Response

	resp, err = ProcessStreamingOutput(output, handler)

	if err != nil {
		return Response{}, err
	}

	return resp, nil
}

func ProcessStreamingOutput(output *bedrockruntime.InvokeModelWithResponseStreamOutput, handler func(ctx context.Context, chunk []byte) error) (Response, error) {

	var combinedResult string
	resp := Response{}

	for event := range output.GetStream().Events() {
		switch v := event.(type) {
		case *types.ResponseStreamMemberChunk:

			var resp Response
			err := json.NewDecoder(bytes.NewReader(v.Value.Bytes)).Decode(&resp)
			if err != nil {
				return resp, err
			}

			handler(context.Background(), []byte(resp.Completion))
			combinedResult += resp.Completion

		case *types.UnknownUnionMember:
			fmt.Println("unknown tag:", v.Tag)

		default:
			fmt.Println("union is nil or unknown type")
		}
	}

	resp.Completion = combinedResult

	return resp, nil
}
```

3. Once the request is processed successfully, the JSON response from Amazon Bedrock is converted (un-marshaled) back in the form of a [Response struct](https://github.com/build-on-aws/langchaingo-amazon-bedrock-llm/blob/main/claude/model.go#L12) and a `slice` of [Generation](https://pkg.go.dev/github.com/tmc/langchaingo/llms#Generation) instances as required by the `Generate` function signature.


```go
//...
generations := []*llms.Generation{
	{Text: resp.Completion},
}
```

## Code samples - Use the Amazon Bedrock plugin in LangChain apps

Once the Amazon Bedrock LLM plugin for `langchaingo` has been implemented, using it is as easy as creating a new instance with `claude.New(<supported AWS region>)` and using the `Call` (or `Generate`) function.

Here is an example:

```go
package main

import (
	"context"
	"fmt"
	"log"

	"github.com/build-on-aws/langchaingo-amazon-bedrock-llm/claude"
	"github.com/tmc/langchaingo/llms"
)

func main() {

	llm, err := claude.New("us-east-1")

	input := "Write a program to compute factorial in Go:"
	opt := llms.WithMaxTokens(2048)

	output, err := llm.Call(context.Background(), input, opt)

//....
```

### Prerequisites

Before executing the sample code, clone the GitHub repository and change to the right directory:

```shell
git clone github.com/build-on-aws/langchaingo-amazon-bedrock-llm
cd langchaingo-amazon-bedrock-llm/examples
```

Refer to **Before You Begin** section in [this blog post](/concepts/amazon-bedrock-golang-getting-started#before-you-begin) to complete the prerequisites for running the examples. This includes installing Go, configuring Amazon Bedrock access and providing necessary IAM permissions.

### Run basic examples

This example demonstrates tasks such as code generation, information extraction and question answering. You can refer to the code [here](https://github.com/build-on-aws/langchaingo-amazon-bedrock-llm/blob/main/main.go).

```shell
go run main.go
```

### Run streaming output example

In this example, we pass in the [WithStreamingFunc](https://pkg.go.dev/github.com/tmc/langchaingo/llms#WithStreamingFunc) option to the LLM invocation. This will switch to the streaming invocation mode for Amazon Bedrock.

> You can refer to the code [here](https://github.com/build-on-aws/langchaingo-amazon-bedrock-llm/blob/main/streaming/main.go)

```go
//...
_, err = llm.Call(context.Background(), input, llms.WithMaxTokens(2048), llms.WithTemperature(0.5), llms.WithTopK(250), 
llms.WithStreamingFunc(func(ctx context.Context, chunk []byte) error {
		fmt.Print(string(chunk))
		return nil
}))
```

To run the program:

```shell
go run streaming/main.go
```

## Conclusion

`LangChain` is a powerful and extensible library that allows us to plugin external components as per requirements. This blog demonstrated how to extend `langchaingo` to make sure it works with the Anthropic Claude model available in Amazon Bedrock. You can use the same approach to implement support for other Amazon Bedrock models such as Amazon Titan.

The examples showed how to use simple LangChain apps to using the `Call` function. In future blog posts, I will cover how to use them as part of chains for implementing functionality like chatbot or QA assistant.

Visit the [Generative AI Space](/generative-ai) to learn more!

Until then, happy building!
