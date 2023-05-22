---
title: "All the things that Comprehend, Rekognition, Textract, Polly, Transcribe and others do"
description: "AIML like API in your APP."
tags:
    - AIML
authorGithubAlias: elizabethfuentes12
authorName: Elizabeth Fuentes
date: 2023-05-22
---

Suppose we are having coffee ☕ talking about the advances in AIML technology and I tell you: 

- 👩🏻 "We can not only do that, but also add it to your applications as if it were another API call". 

Then you would probably answer: 

- 🧑🏽 "Really? However, before  we can use the API, it is necessary to collect the data, select an ML model that solves the problem, obtain the data, label it, and then train that model. Check if it meets the required needs and if not, make the necessary changes and retrain it, and so on, until it finds what I need to deploy it and create the API", 

and I would answer: 

- 👩🏻 “Friend, that is not necessary, you can have a ready-to-use API that solves your problem".

I tell you how.

AWS has AIML services that take care of the task of collecting data, labeling it, selecting algorithms, training models, deploying it, and delivering AIML as a ready-to-use APIs within the reach of any developer, without having to worry about maintaining the infrastructure and process of AIML.

## How does it work? Just follow 3 simple steps:

1. Define the input, the location of the object in an Amazon S3 bucket or text.
2. Invoke the API using input.
3. Output in json format.


![Diagram AIML like API in your APP"](images/diagram-api-call.png)


## Let's take a look at the APIS

| API Type | How you can do | Service Name | 
-- | -- | --
 🔎 Analysis of images (.png, .jpg) /videos (.mp4) | <ul> <li> Label detection (predefined or custom) </li>  <li> Image propereties and moderation. </li>  <li> Facial detection, comparasion and analysis. </li>  <li> Face search </li>  <li> People paths. </li>  <li> Personal Protective Equipment </li>  <li> Celebrities recognition.  </li>  <li>Text in image </li>  <li> Inappropriate or offensive content </li></ul> | [Amazon Rekognition](https://docs.aws.amazon.com/rekognition/latest/dg/what-is.html)	| 
🔎 Detection and analysis of text in documents (PNG, JPG, PDF or TIFF)	| 	<ul> <li> Processes individual or bundled documents. </li>  <li> Detect typed and handwritten text </li>  <li> Recognize documents, like financial reports, medical records, ID document (drivers licenses and passports)  and tax forms. </li>  <li> Extract text, forms, and tables from documents with structured data. </li></ul> | [Amazon Textract](https://docs.aws.amazon.com/textract/latest/dg/what-is.html) | 
🔎 Natural Language Processing (NLP) and text analysis	| 	Processes documents and extracts information such as: <ul> <li> Entities </li> <li> Events</li>  <li> Key phrases</li>  <li> Dominant language </li> <li> Sntiment</li>  <li> Targeted sentiment </li>  <li>Syntax analysis.</li> <li> Custom classification and entity recognition.</li>  <li> Managing custom models. </li></ul> | [Amazon comprehend](https://docs.aws.amazon.com/es_es/comprehend/latest/dg/what-is.html) | 
🔎 Text to speech | <ul> <li> Supports [multiple languages and includes a variety of lifelike voices](https://docs.aws.amazon.com/polly/latest/dg/voicelist.html).</li> <li>Includes a number of [Neural Text-to-Speech (NTTS) voices](https://docs.aws.amazon.com/polly/latest/dg/NTTS-main.html), delivering ground-breaking improvements in speech quality through a new machine learning approach, thereby offering to customers the most natural and human-like text-to-speech voices posible.</li> <li>[Neural TTS technology also supports a Newscaster speaking style](https://docs.aws.amazon.com/polly/latest/dg/ntts-speakingstyles.html) that is tailored to news narration use cases. </li></ul> | [Amazon Polly](https://docs.aws.amazon.com/polly/latest/dg/what-is.html)  | 
🔎 Speech to Text | <ul> <li> Convert audio ([Supported formats](https://docs.aws.amazon.com/transcribe/latest/dg/how-input.html#how-input-audio)) to text. </li> <li> Transcribe media in real time (streaming) or you can transcribe media files located in an Amazon S3 bucket (batch).</li> <li> Improve accuracy for your specific use case with [language customization](https://docs.aws.amazon.com/transcribe/latest/dg/supported-languages.html), filter content to ensure customer privacy or audience-appropriate language, analyze content in multi-channel audio, partition the speech of individual speakers </li></ul> |  [Amazon Transcribe](https://docs.aws.amazon.com/transcribe/latest/dg/what-is.html) | 
🔎  Translate | Translate unstructured text (UTF-8) documents or to build applications that work in [multiple languages](https://docs.aws.amazon.com/translate/latest/dg/what-is-languages.html) | [Amazon Translate](https://docs.aws.amazon.com/translate/latest/dg/what-is.html)| 

## Use Cases 

- Create subtitles and translate them into the language you want ⏯️ 🍿.

![Create subtitles and translate them into the language you want"](images/create-subtitles-and-translate.png)

1. Upload the .mp4 video to an [Amazon s3 bucket](https://docs.aws.amazon.com/es_es/AmazonS3/latest/userguide/UsingBucket.html).
2. A Lambda Function makes the call to Transcribe API.
3. Subtitles file in the original language are downloaded to S3 Bucket. 
4. A Lambda Function makes the call to Translate API.
5. Subtitles file in the new language is downloaded to S3 Bucket. 

Code to create this solution: repo. 

- Detecting entities and sentiment from a document 🔎 📄.

![Detecting entities and sentiment from a document"](images/detecting-entities-and-sentiment.png)

1. Upload the document (PNG, JPG, PDF or TIFF) to an S3 Bucket.
2. A Lambda Function makes the call to Textract API.
3. With the response from Textract, Lambda Function makes the call to Comprehend API. 
4. A Lambda Function makes the call to the Translate API.
5. The response is saved in an S3 bucket. 

Code to create this solution: repo. 

- Make Polly Talk 🦜

![Make Polly Talk"](images/make-polly-talk.png)

1. From a Jupyter Notebook make the call to Polly API.
2. Polly stores the result in a S3 bucket.
3. Retrieves the audio.


Code to create this solution: repo. 


- Video content moderation ⏯️ 🔫 🚬

![Video content moderation"](images/video-content-moderation.png)

1. Upload the .mp4 video to an [s3 bucket](https://docs.aws.amazon.com/es_es/AmazonS3/latest/userguide/UsingBucket.html).
2. A Lambda Function makes the call to Rekognition API.
3. Once the video review is finished, a new Lambda Function retrieves the result and stores it in an s3 bucket.


Code to create this solution: repo. 


## Conclusion

Now you learned that you can use AIML as an API call to analyze images and videos, detection and analysis of text in scanned documents, analyze text using NLP to extract sentiment from dominant language and much more. In addition to being able to convert text to speech, and vice versa, and a language translator within reach of an API call.

This is just a small part of what you can create by powering AIML applications within the reach of an API call.

