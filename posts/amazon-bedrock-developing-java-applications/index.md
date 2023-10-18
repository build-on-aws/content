---
title: "Developing Java Applications using Amazon Bedrock"
description: "Learn how to build Java applications that leverage the power of Generative AI foundation models provided by Amazon Bedrock."
tags:
    - bedrock
    - java
    - generative-ai
spaces: 
  - generative-ai
waves: 
  - generative-ai
images:
  banner: images/bedrock-with-java.png
  thumbnail: images/Arch_Amazon-Bedrock_64-5x.png
  hero: images/bedrock-with-java.png
  background: images/bedrock-with-java.png
authorGithubAlias: riferrei
authorName: Ricardo Ferreira
date: 2023-10-18
---

Whenever a developer picks a programming language to work with, it is often a decision set on stone. Truth is, most developers fall in love with a given programming language and rarely need to use another one as they become pretty good in the chosen language. However, there are situations when they need to learn other languages because the type of applications they need to build don't provide good support for their preferred languages. A good example of this is building generative AI applications, which in theory are a simple matter of choosing [Python](https://aws.amazon.com/developer/language/python?sc_channel=el&sc_campaign=genaiwave&sc_content=amazon-bedrock-integrating-foundation-models-into-your-code&sc_geo=mult&sc_country=mult&sc_outcome=acq) as the implementation language.

I used the expression "in theory" purposefully before because with generative AI applications, this doesn't need to be true. Especially if you are using [Amazon Bedrock](https://docs.aws.amazon.com/bedrock/latest/userguide/what-is-service.html?sc_channel=el&sc_campaign=genaiwave&sc_content=amazon-bedrock-integrating-foundation-models-into-your-code&sc_geo=mult&sc_country=mult&sc_outcome=acq) to unlock the power of foundation models (FMs) from Amazon and leading AI startups. With a comprehensive support for different programming languages, Amazon Bedrock allows developers to pick their favorite language to build generative AI applications with ease.

I'm excited to share that with [Java](https://aws.amazon.com/developer/language/java?sc_channel=el&sc_campaign=genaiwave&sc_content=amazon-bedrock-integrating-foundation-models-into-your-code&sc_geo=mult&sc_country=mult&sc_outcome=acq), my favorite programming language, developing generative AI applications using Amazon Bedrock is very easy. In this blog post, I will walk you through in how to get started building Java applications using Amazon Bedrock. All the code from this blog post can be found in [this GitHub repository](https://github.com/build-on-aws/amazon-bedrock-with-builder-and-command-patterns).

## Adding the AWS SDK for Java

The first thing you need to do to start working with Java using Amazon Bedrock is adding the [AWS SDK for Java](https://docs.aws.amazon.com/sdk-for-java/latest/developer-guide/get-started.html?sc_channel=el&sc_campaign=genaiwave&sc_content=amazon-bedrock-integrating-foundation-models-into-your-code&sc_geo=mult&sc_country=mult&sc_outcome=acq) to your project. If you are using Maven, add the packages `bedrock` and `bedrockruntime` to your project as shown below.

```xml
	<dependencies>

		<dependency>
			<groupId>software.amazon.awssdk</groupId>
			<artifactId>bedrock</artifactId>
			<version>2.20.162</version>
		</dependency>

		<dependency>
			<groupId>software.amazon.awssdk</groupId>
			<artifactId>bedrockruntime</artifactId>
			<version>2.20.162</version>
		</dependency>

		<dependency>
			<groupId>org.json</groupId>
			<artifactId>json</artifactId>
			<version>20230227</version>
		</dependency>

	</dependencies>
```

💡 Note that the usage of the dependency `json` is not mandatory. It was added to help with the examples of the following sections—but you are free to use another JSON parser library of your preference. With that done, let's start developing our first example.

## Text Generation with Cohere Command

Our first example will use the [Cohere Command](https://cohere.com/models/command) FM to extract transactional information from a nebulous text. Given a piece of a contract from a music recording agreement, the code will request the FM to detect what is the name of the band whose contract is about. The constants below will be used to store the information about the FM to use and the contract itself.

```java
public class CohereTextGeneration {

    private static final String MODEL_ID = "cohere.command-text-v14";

    private static final String PROMPT = """
            Extract the band name from the contract:

            This Music Recording Agreement ("Agreement") is made effective as of the 13 day of December,
            2021 by and between Good Kid, a Toronto-based musical group (“Artist”) and Universal Music Group,
            a record label with license number 545345 (“Recording Label"). Artist and Recording Label may each
            be referred to in this Agreement individually as a "Party" and collectively as the "Parties."
            Work under this Agreement shall begin on March 15, 2022.
    """;

}
```

The next step is to create an instance of the `BedrockRuntimeClient` class. It allows you to connect with the Amazon Bedrock service and send requests to it.

```java
public class CohereTextGeneration {

    private static final String MODEL_ID = "cohere.command-text-v14";

    private static final String PROMPT = """
            Extract the band name from the contract:

            This Music Recording Agreement ("Agreement") is made effective as of the 13 day of December,
            2021 by and between Good Kid, a Toronto-based musical group (“Artist”) and Universal Music Group,
            a record label with license number 545345 (“Recording Label"). Artist and Recording Label may each
            be referred to in this Agreement individually as a "Party" and collectively as the "Parties."
            Work under this Agreement shall begin on March 15, 2022.
    """;

    public static void main(String... args) throws Exception {

        try (BedrockRuntimeClient bedrockClient = BedrockRuntimeClient.builder()
            .region(Region.US_EAST_1)
            .credentialsProvider(ProfileCredentialsProvider.create())
            .build()) {

        }

    }
    
}
```

Note that the `BedrockRuntimeClient` class implements the `java.lang.AutoCloseable` interface, which means you can control the lifecycle of the instance with a try-with-resources statement. With the instance of the BedrockRuntimeClient created, you must assemble a request to send to the service. This is done in two parts. First, you must create a string with the request body payload that will be used by the service to process the request. Second, you need to include that body payload into a `InvokeModelRequest` object.

```java
public class CohereTextGeneration {

    private static final String MODEL_ID = "cohere.command-text-v14";

    private static final String PROMPT = """
            Extract the band name from the contract:

            This Music Recording Agreement ("Agreement") is made effective as of the 13 day of December,
            2021 by and between Good Kid, a Toronto-based musical group (“Artist”) and Universal Music Group,
            a record label with license number 545345 (“Recording Label"). Artist and Recording Label may each
            be referred to in this Agreement individually as a "Party" and collectively as the "Parties."
            Work under this Agreement shall begin on March 15, 2022.
    """;

    public static void main(String... args) throws Exception {

        try (BedrockRuntimeClient bedrockClient = BedrockRuntimeClient.builder()
            .region(Region.US_EAST_1)
            .credentialsProvider(ProfileCredentialsProvider.create())
            .build()) {

            String bedrockBody = BedrockRequestBody.builder()
                .withModelId(MODEL_ID)
                .withPrompt(PROMPT)
                .withInferenceParameter("temperature", 0.40)
                .withInferenceParameter("p", 0.75)
                .withInferenceParameter("k", 0)
                .withInferenceParameter("max_tokens", 200)
                .build();

            InvokeModelRequest invokeModelRequest = InvokeModelRequest.builder()
                .modelId(MODEL_ID)
                .body(SdkBytes.fromString(bedrockBody, Charset.defaultCharset()))
                .build();

        }

    }
    
}
```

Mind you the usage of the class [BedrockBodyBuilder](https://github.com/build-on-aws/amazon-bedrock-with-builder-and-command-patterns/blob/main/src/main/java/com/amazon/aws/developers/bedrock/util/BedrockRequestBody.java) to create the request for the body payload. This is not part of the AWS SDK for Java, but a helper class to assist in the payload generation. Ultimately, you are required to provide a string containing the exact payload for each foundation model support by Amazon Bedrock. Because this process can be tedious and error-prone, I created this helper class to make your life simpler. The complete implementation of this helper class can be found in [this GitHub repository](https://github.com/build-on-aws/amazon-bedrock-with-builder-and-command-patterns).

Now for the moment you were waiting for: sending the request to Amazon Bedrock, get a response, and process it to find the name of the band from the contract.

```java
public class CohereTextGeneration {

    private static final String MODEL_ID = "cohere.command-text-v14";

    private static final String PROMPT = """
            Extract the band name from the contract:

            This Music Recording Agreement ("Agreement") is made effective as of the 13 day of December,
            2021 by and between Good Kid, a Toronto-based musical group (“Artist”) and Universal Music Group,
            a record label with license number 545345 (“Recording Label"). Artist and Recording Label may each
            be referred to in this Agreement individually as a "Party" and collectively as the "Parties."
            Work under this Agreement shall begin on March 15, 2022.
    """;

    public static void main(String... args) throws Exception {

        try (BedrockRuntimeClient bedrockClient = BedrockRuntimeClient.builder()
            .region(Region.US_EAST_1)
            .credentialsProvider(ProfileCredentialsProvider.create())
            .build()) {

            String bedrockBody = BedrockRequestBody.builder()
                .withModelId(MODEL_ID)
                .withPrompt(PROMPT)
                .withInferenceParameter("temperature", 0.40)
                .withInferenceParameter("p", 0.75)
                .withInferenceParameter("k", 0)
                .withInferenceParameter("max_tokens", 200)
                .build();

            InvokeModelRequest invokeModelRequest = InvokeModelRequest.builder()
                .modelId(MODEL_ID)
                .body(SdkBytes.fromString(bedrockBody, Charset.defaultCharset()))
                .build();

            InvokeModelResponse invokeModelResponse = bedrockClient.invokeModel(invokeModelRequest);
            JSONObject responseAsJson = new JSONObject(invokeModelResponse.body().asUtf8String());

            System.out.println("🤖 Response: ");
            System.out.println(responseAsJson
                .getJSONArray("generations")
                .getJSONObject(0)
                .getString("text"));

        }

    }
    
}
```

Executing this code produces the following output:

```bash
SLF4J: Failed to load class "org.slf4j.impl.StaticLoggerBinder".
SLF4J: Defaulting to no-operation (NOP) logger implementation
SLF4J: See http://www.slf4j.org/codes.html#StaticLoggerBinder for further details.
🤖 Response: 
 Good Kid
```

Pretty neat, right? But hey, the fun doesn't need to stop here. If you want more examples using different FMs, you should watch the video below where I provide examples for [AI21 Labs Jurassic](https://docs.ai21.com/docs/jurassic-2-models) and [Anthropic Claude V2](https://www.anthropic.com/index/claude-2). Moreover, I also show how to invoke Amazon Bedrock using the streaming API, which allows you to access FMs asynchronously and process the responses as they are generated.

https://www.youtube.com/watch?v=Vv2J8N0-eHc

If you want to discover more about the amazing world of generative AI, take a look at [this space](/generative-ai) and don't forget to subscribe to the [AWS Developers YouTube channel](https://www.youtube.com/@awsdevelopers). I'm sure you will be amazed by the new content to come. Finally, [follow me on LinkedIn](https://linkedin.com/in/riferrei) if you want to geek out about technologies in general.

See you, next time!
