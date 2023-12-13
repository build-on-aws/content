---
title: Handling streaming and structured data using Amazon Bedrock
description: At Telescope, we work with financial and brokerage applications to power their rich and intelligent stock discovery experiences. We leverage Anthropic Claude models on Amazon Bedrock for our generative AI capabilities. Learn about our experience using Amazon Bedrock, including working with structured data, designing effective prompts and handling streaming inputs and outputs. 
tags:
  - generative-ai
  - bedrock
  - claude
spaces:
  - generative-ai
waves:
  - generative-ai
images:
  banner: images/cover.jpg
  hero: images/cover.jpg
authorGithubAlias: cobbweb
githubUserLabel: community
authorName: Andrew Bucknall
additionalAuthors: 
  - authorGithubAlias: niccatsmy
    authorName: Nicola Smyth
  - authorGithubAlias: wirjo
    authorName: Daniel Wirjo
date: 2023-12-07
---

|ToC|
|---|

## Introduction

At [Telescope](https://telescope.co/), we work with financial and brokerage applications to power their rich and intelligent stock discovery experiences using AI. To provide these experiences, we needed a large language model (LLM) that is predictable given the financial industry we operate in, provides fast user experiences and has the ability to understand and process structured financial markets data. 

In this blog post, you will learn about our experience adopting [Claude](https://aws.amazon.com/bedrock/claude/) on [Amazon Bedrock](https://aws.amazon.com/bedrock/), how to design effective prompts when handling structured data, and how to handle streaming inputs and outputs to provide fast user experiences. For those adopting Claude models for their generative AI capabilities, it's crucial to understand that creating tailored prompts, rather than reusing ones from other models, is key to fully harnessing the model's capabilities for optimal results and generate consistent responses. 

## Initial impressions

The moment we gained access to Amazon Bedrock from our [AWS account team](https://aws.amazon.com/startups/learn/meet-your-aws-account-team), we eagerly adopted [Claude](https://aws.amazon.com/bedrock/claude/) model. It has been a game-changer, particularly in terms of speed and context window size (as at time of writing, these are 200,000 tokens which equates to about 150,000 words). 

We evaluated a number of models for our use case of providing investment suggestions. The first criteria was predictable results on complex language tasks. This is especially important given the financial industry we operate in. In addition, we operate with vast amounts of structured financial markets data and we needed a model that can process and understand structured data. Furthermore, our product is used by consumer applications where fast user experience is paramount. Therefore, having streaming capabilities is critical. Given the depth of our requests, some can take over 30 seconds to fully complete. Having results returned in chunks as soon as they have been computed matters significantly for the user experiences that we wanted.

## Prompting basics

As a large language model (LLM), Claude is fantastic at processing complex language-based tasks quickly. However, one surprise we encountered was how it processes structured data. To optimize responses, XML tags can be used to identify structured data. At first, moving back to XML felt odd, considering JSON is the standard for modern applications. However, using XML in your prompt context is vital in helping the model understand the structure of your data.

To best illustrate this, let’s start with a simple prompt and tailor it towards a consistent, structured format.

Prompt:

```
Human: Provide me a list of 3 top tech companies that are listed on US stock exchanges. Include their CEO's name and stock ticker.
Assistant:
```

Response:

```
Here are 3 top tech companies listed on US stock exchanges with their CEOs and stock tickers:
1. Apple (AAPL)
- CEO: Tim Cook
2. Microsoft (MSFT) 
- CEO: Satya Nadella
3. Amazon (AMZN)
- CEO: Andy Jassy
```

Great! We’ve got our list of 3 companies. However, there are several issues if we want to automate parsing and use these results to power a user interface. 

Firstly, Claude likes to clarify what its task is. Secondly, there’s a more subtle thing that’s hard to notice; the 
response started with a single space character because our prompt didn’t have one after the `Assistant` section. We can fix both issues in one go by  providing this preamble directly into our prompt:

Prompt:

```
Human: Provide me a list of 3 top tech companies that are listed on US stock exchanges. Include their CEO's name and stock ticker.
Assistant: Here are 3 top tech companies listed on US stock exchanges with their CEOs and stock tickers:
```

Response:

```
1. Apple (AAPL)
CEO: Tim Cook
2. Microsoft (MSFT) 
CEO: Satya Nadella
3. Amazon (AMZN)
CEO: Andy Jassy
```

As you can see, our response is now structured with a numbered list and `CEO:` prefix. If we wanted to parse this into a structured format, we could probably do some string parsing using regular expressions. However, this may be flaky given that each response isn't consistent. Further tweaks to the prompt 
might inadvertently yield more variations in response structure too, breaking our automation. We're going to need a solid data structure, not just loosely 
formatted text.

## Prompting for structured data as XML

Instead, we can ask for a response in XML format. For example:

Prompt:

```
Human: Provide me a list of 3 top tech companies that are listed on US stock exchanges. Include their CEO's name and stock ticker. Respond in XML format.
Assistant: Here are 3 top tech companies listed on US stock exchanges with their CEOs and stock tickers:
```

Response:

```xml
<response>
    <company>
        <name>Apple</name>  
        <ceo>Tim Cook</ceo>
        <ticker>AAPL</ticker>
    </company>
    <company> 
        <name>Microsoft</name>
        <ceo>Satya Nadella</ceo>
        <ticker>MSFT</ticker>
    </company>
    <company>
        <name>Alphabet</name>  
        <ceo>Sundar Pichai</ceo>
        <ticker>GOOG</ticker> 
    </company>
</response>
```

Now, we’re starting to get something more useful to automate! However, something that's not obvious here is that every time you run this, you'll get 
different names for some of the XML tags. This is assuming your temperature is high enough as higher temperature leads to more creative samples and 
more variations in phrasing. For example, I re-ran the same prompt and got tags named `<response>`,  `<companies>` or `<Companies>` so that's still not reliable enough for automation. The final step is to describe the XML structure you want.

Prompt:

```
Human: Provide me a list of 3 top tech companies that are listed on US stock 
exchanges. Include their CEO's name and stock ticker. Respond in XML 
format using this structure:
<list>
  <comp>
    <name>{{COMPANY_NAME}}</name>
    <ceo>{{CEO_NAME}}</ceo>
    <tick>{{TICKER}}</tick>
  </comp>
</list>
Assistant: Here are 3 top tech companies listed on US stock exchanges with 
their CEOs and stock tickers:
```

Response:

```xml
<list>
  <comp>
    <name>Apple</name>  
    <ceo>Tim Cook</ceo>
    <tick>AAPL</tick>
  </comp>
  <comp> 
    <name>Microsoft</name>
    <ceo>Satya Nadella</ceo>
    <tick>MSFT</tick>
  </comp>
  <comp>
    <name>Alphabet</name>
    <ceo>Sundar Pichai</ceo> 
    <tick>GOOGL</tick>
  </comp>
</list>
```

Perfect! Even with a high temperature; you can run this as many times as you want, and you'll always get a consistent XML structure you can parse using standard libraries from the language of your choice. 

## Tips and tricks

There's an obvious downside to using XML: it's verbose. So not only will you consume more tokens (increased costs) but responses also take longer. However, 
for the high reliability requirements of parsing structure responses, this is a worthy trade-off. While I'm no expert on the internal workings of LLMs, but it appears logical that the verbose nature of XML plays to Claude's strengths. 

If you use ask for a JSON formatted response, you notice that Claude will often (but not always) surround the response with markdown-style triple backticks and occasionally get invalid JSON responses too. 

In order to reduce costs, it's worth pointing out that you can use abbreviated XML tag names. In the example above, I asked for each company to be wrapped in `<comp>` tags. It's not huge, but it means 2 or 3 less tokens used per company for the same result. With this in place, each 
company in this XML is only about 2 or 3 tokens bigger than it's JSON equivalent.

Another benefit to using XML is that it's much easier to parse a partially streamed response. Say a user asks for a list of 100 companies, even with Claude’s speedy responses you'd still be looking at a loading spinner for over 60 seconds. 

Instead, by leveraging Bedrock's [InvokeModelWithResponseStream](https://docs.aws.amazon.com/bedrock/latest/APIReference/API_runtime_InvokeModelWithResponseStream.html), you can do an easy string search to look for completed `</comp>` tags as you build up the streamed response, and then parse just that `<comp>` block in a data structure and send it onto the client. This is definitely a crude option, so you may also want to look into your runtime ecosystem to see if there's any partial XML processing libraries available.

## Example: Parsing streamed XML in real time using Go

At Telescope, we've chosen Go as our language for building our API products. This means we have access to Go's excellent standard library which 
supports real-time decoding of streamed XML. Here's a complete example of invoking a streaming chat completion with Amazon Bedrock and parsing the 
stream using Go's built-in xml package.

```go
type PayloadPartContent struct {
    Completion string `json:"completion"`
}
type Company struct {
    Name   string `xml:"name"`
    CEO    string `xml:"ceo"`
    Ticker string `xml:"ticker"`
}
func streamingExample() {
    // Create a bedrockruntime instance to run inferencing with
    bdr := bedrockruntime.New(existingSession)
    // Our example prompt that generates clean & consistent XML output
    prompt := `Human: List 3 leading tech companies that are public on 
United States stock exchanges. Provide the company name, the current 
CEO's name, and their ticker code in this XML format:
<companies>
  <company>
    <name>{{COMPANY_NAME}}</name>
    <ceo>{{CEO_NAME}}</ceo>
    <ticker>{{TICKER}}</ticker>
  </company>
</companies>
Assistant: Here is 3 leading tech companies on US stock exchanges in XML 
format:
`
    // Create a JSON string from our request parameters
    body, _ := json.Marshal(map[string]interface{}{
        "prompt":               prompt,
        "temperature":          0.5,
    })
    xmlWriter := NewStreamingXMLParser()
    // Start the inferencing with Claude V2
    input := &bedrockruntime.InvokeModelWithResponseStreamInput{
        ModelId: aws.String("anthropic.claude-v2"),
        Body:    body,
    }
    var response *bedrockruntime.InvokeModelWithResponseStreamOutput
    response, _ = bdr.InvokeModelWithResponseStream(input)
    // Get the event channel from the response object
    stream := response.GetStream()
    events := stream.Events()
    for event := range events {
        payloadPart, _ := event.(*bedrockruntime.PayloadPart)
        var content PayloadPartContent
        json.Unmarshal(payloadPart.Bytes, &content)
        xmlWriter.Write([]byte(content.Completion))
    }
    xmlWriter.Close()
}
func NewStreamingXMLParser() *io.PipeWriter {
    reader, writer := io.Pipe()
    decoder := xml.NewDecoder(reader)
    // split the decoding off to a goroutine as Pipe read & write are 
synchronous
    go func() {
        for {
            tok, err := decoder.Token()
            if tok == nil || err == io.EOF {
                // end of XML stream
                break
            }
            switch tok.(type) {
            // look for all opening tags in the XML
            case xml.StartElement:
                startElement := tok.(xml.StartElement)
                elementName := startElement.Name.Local
                // if the opening tag a <comp>?
                if elementName == "comp" {
                    var company Company
                    decoder.DecodeElement(&company, &startElement)
                    log.Printf("COMPANY: %s (%s) is run by %s", company.Name, 
company.Ticker, company.CEO)
                }
            }
        }
    }()
    return writer
}
```

## Conclusion

Our journey with Claude on [Amazon Bedrock](https://aws.amazon.com/bedrock/) revealed substantial benefits in designing prompts that maximize the effectiveness. In particular, using XML for structured data for greater accuracy. As essential to provide fast user experiences, we leveraged Bedrock's streaming capabilities. We provided an example of how you can partially parse structured response data and provide this to the user as soon as they are processed.

To learn more about Telescope, visit our [website](https://telescope.co/).

To get started with generative AI on AWS, please see resources:

* [Generative AI on AWS Community](https://community.aws/generative-ai)
* [Patterns for Building Generative AI Applications on Amazon Bedrock](https://community.aws/posts/build-generative-ai-applications-with-amazon-bedrock)
