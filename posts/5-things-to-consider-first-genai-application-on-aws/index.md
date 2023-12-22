---
title: "5 Things to Consider When Building Your First Generative AI Application On AWS"
description: Does generative AI sound exciting to you? Here are the 5 things you should consider before starting your generative AI journey on AWS.
tags:
  - ai-ml
  - generative-ai
  - amazon-bedrock
  - amazon-sagemaker
  - new-to-aws
authorGithubAlias: ashakdhe
authorName: Arjun Shakdher
additionalAuthors:
  - authorGithubAlias: ztanruan
    authorName: Jin Tan Ruan
date: 2023-11-21
---

Generative AI refers to a category of artificial intelligence (AI) systems and models that are designed to generate content, such as text, images, music, or other forms of data, that is often creative and original. These AI systems use techniques from machine learning and deep learning to produce new content based on patterns and knowledge learned from existing data.

Key application areas of generative AI include but is not limited to:

- Creative media synthesis like images, videos, music, and text
- Data augmentation to increase size of training datasets
- Drug and materials discovery through molecular generation
- Personalization and recommendation by adapting models to user tastes

Generative AI is becoming increasing important for organizations and businesses. Consider the following benefits:

- **Automates creative workflows** - Generative AI can automate time-consuming creative processes like writing, image/video creation, graphic design etc. This makes teams more productive and scalable. For example, instead of manually creating each social media post, AI can instantly generate numerous high-quality options.
- **Customization and personalization** - Generative models can take customer context and preferences to generate personalized content, product recommendations, and customized offerings. This creates more relevant experiences and helps with retention and satisfaction.
- **Data augmentation** - Organizations can use generative AI to synthesize large training datasets for other ML models. This unlocks scenarios where human-labeled data is scarce. For example, generating synthetic patient data to train healthcare AI.
- **New products and services** - Generative AI opens possibilities for entirely new product categories based on AI-generated content like AI art, music, games, and more. These can reach new demographics and revenue streams.
- **Cost reductions** - Synthesized data, content, and assets lower costs compared to human-generated counterparts in many cases. This improves margins and competitiveness.
- **Faster experimentation** - Generative models enable testing and iteration of orders of magnitude more content variations and creative concepts vs human efforts alone. This powers faster innovation.

## #1. Identify Use Cases - Virtual Assistants, Text Summarization & Generation, Search, and Image Generation

Amazon Web Services (AWS) provides a robust array of services tailored for any generative AI endeavor you're considering. Before diving into the development of a generative AI application, it's paramount to delineate its purpose. This means understanding the target audience, the desired user experience, and the core challenges the application seeks to address. From our perspective, the applications of generative AI can be categorized into four key areas:

- **Chatbots**: Imagine a customer support scenario where a user inquires about a product's specifications. Instead of receiving a static, generic response, the user interacts with a GenAI-powered chatbot. This chatbot understands the context, recalls the user's past interactions, preferences, or purchases, and provides a detailed, personalized response. Over time, it adapts, offering proactive solutions and even upselling or cross-selling relevant products.
- **Summarization**: Consider a business analyst who needs to go through hundreds of pages of quarterly reports to extract key insights. Instead of spending hours reading, the analyst uses a GenAI-driven tool which processes these reports and produces concise summaries, highlighting main points, trends, and anomalies, allowing for faster decision-making.
- **Search**: A student researching for a history project enters a vague query about World War II events. Traditional search engines might flood the student with countless web pages. In contrast, a GenAI-enhanced search engine understands the student's intent, filters out irrelevant information, and might even group results by categories like battles, political events, or key figures, making the research process more efficient.
- **Text & Generation**: A digital marketing agency needs to produce weekly blog posts for various clients in diverse industries. Rather than brainstorming from scratch, content creators input a few keywords or topics into a GenAI-powered content generator. The tool then crafts initial drafts, adapts to different writing styles, and ensures the content is relevant to the target audience. This significantly reduces the time spent on content creation and allows for more focus on refinement and strategy. In fact, we used AI to help with this blog and it is a good example of how generative AI can be leveraged for text generation and summarization.

## #2. Data Quality + Quantity

Certainly, data quality and quantity are critical factors in the success of a generative AI application. Here are some key factors to consider when it comes to the quality:

- **Relevance**: Ensure that the data you use for training your generative AI model is relevant to your application. Irrelevant or noisy data can lead to poor model performance.
- **Accuracy**: The data should be accurate and free from errors. Inaccurate data can mislead your model and result in incorrect outputs.
- **Consistency**: Maintain consistency in your data. Inconsistencies in the data can confuse the model and hinder its ability to learn patterns.
- **Bias and Fairness**: Be aware of biases in your data, as they can lead to biased model outputs. Take steps to mitigate bias and ensure fairness in your generative AI system.
- **Annotation and Labeling**: If your application requires labeled data, ensure that the annotations or labels are of high quality and created by experts.
- **Data Preprocessing**: Prepare your data by cleaning and preprocessing it. This might involve text tokenization, image resizing, or other data-specific transformations to make it suitable for training.

Quantity along with quality goes hand in hand. It is important to remember:

- **Sufficient Data**: In most cases, more data is better. Larger datasets allow your model to learn a wider range of patterns and generalize better. However, the required amount of data can vary depending on the complexity of your application.
- **Data Augmentation**: If you have limitations on the quantity of available data, consider data augmentation techniques. These techniques involve generating additional training examples by applying transformations to existing data. For example, you can rotate, crop, or flip images or paraphrase text to create more training samples.
- **Balancing Data**: Ensure that your dataset is balanced, especially if your generative AI application is expected to produce outputs with equal representation across different categories or classes. Imbalanced datasets can lead to biased model outputs.
- **Transfer Learning**: For certain applications, you can leverage pre-trained models. Transfer learning allows you to use models that were trained on massive datasets and fine-tune them with your specific data, often requiring less data for fine-tuning.

High-quality data can compensate for a smaller dataset to some extent, but having both high-quality and a sufficient quantity of data is ideal for training robust generative AI models. It's also important to continuously monitor and update your dataset as your generative AI application evolves and as new data becomes available.

## #3. Research Possible Models - Commercial / Open Source

The next crucial step in building your application is selecting the appropriate model. Your choice between open-source models and commercial offerings will be pivotal. Each has its strengths and limitations. Open-source models often provide flexibility, allowing for customization and adaptability to specific needs. On the other hand, commercial models can offer robust support, frequent updates, and advanced features straight out of the box.

Here are some key factors to think about:

- **Modality** - The type of content you want to generate (text, images, audio, etc) will determine the kinds of models that are appropriate. Different model architectures are designed to work with different modalities.
- **Scale** - The size and complexity of the models required depends on the scope and difficulty of the generative task. Larger datasets and more complex tasks may require larger, more complex models
- **Training Resources** - The time and compute resources (GPUs) required to train models from scratch increases with model size. Pre-trained models reduce this resource requirement.

Your decision should align with your application's requirements, and your budget constraints. By carefully assessing your use case and weighing the pros and cons of each option, you can ensure the optimal foundation for your generative AI project.

## #4. Select The Right AWS Services + Supporting Infrastructure

Building generative AI applications on AWS involves a nuanced approach to selecting the right services that cater to compute power, scalability, storage, and more. Choosing the right approach in machine learning, whether to use managed or unmanaged services, on AWS can significantly impact the development and deployment of your generative AI application. Each approach has its advantages and considerations, and your choice should align with your project's specific needs and your team's expertise.

Managed Services:

- Advantages:
  - Simplicity and ease of use.
  - Built-in scalability and deployment features.
  - Managed algorithms and pre-built models.
  - Monitoring and optimization tools.
- Considerations:
  - Additional cost.
  - Limited flexibility for customization.
  - Learning curve for platform usage.

Unmanaged Services:

- Advantages:
  - Full control and customization.
  - Cost control through resource provisioning.
  - Maximum flexibility.
  - Portability between providers.
- Considerations:
  - Complexity and manual resource management.
  - Maintenance responsibilities.
  - Steeper learning curve for infrastructure.

When developing and deploying generative AI applications, cost and scalability are key considerations. The upfront costs can be substantial, including not just the tech infrastructure, but also data acquisition and model training resources. Scalability needs to be planned both technically and financially. As user demand increases, the application should scale without performance drops or exorbitant costs. Efficient resource management like scalable cloud services can help control expenses while meeting computing needs. You should also consider ongoing training and model update costs to maintain effectiveness and relevance over time. Balancing initial and operational costs against the need for a robust, scalable solution is crucial for the long-term success of a generative AI application.

As an example, [Amazon Bedrock](https://aws.amazon.com/bedrock/?sc_channel=el&sc_campaign=genaiwave&sc_geo=mult&sc_country=mult&sc_outcome=acq&sc_content=genai-5-things) is fully managed service that provides access to foundational models from different providers through an API, while in the other hand [Amazon SageMaker](https://aws.amazon.com/sagemaker/?sc_channel=el&sc_campaign=genaiwave&sc_geo=mult&sc_country=mult&sc_outcome=acq&sc_content=genai-5-things) is a fully managed service that provides the tools that helps data scientists to build, train, and deploy models at scale. This provides more control and customization but it requires additional effort to configure and manage the resources.

Amazon Bedrock

- **Serverless Architecture**: Offers a serverless solution that eliminates the need for managing underlying infrastructure, focusing resources on development.
- **API Access**: Provides quick access to a variety of models from several providers, allowing for rapid testing and integration.
- **Cost-Efficient Scaling**: Implements a pay-per-use model for API calls, optimizing costs for applications with fluctuating inference loads.

Amazon SageMaker

- **Extensive Model Selection**: Features a wide array of foundation models suitable for diverse use cases, with resources available to aid selection and deployment.
- **Deployment and Fine-Tuning**: Supports model deployment as endpoints, along with the capability for model fine-tuning using managed training jobs.
- **Scalable Compute Options**: Offers scalable compute resources, including managed accelerated computing instances, to handle varying demand levels.

For selecting the supporting infrastructure, consider:

- **Scalability**: Services like [AWS Elastic Beanstalk](https://aws.amazon.com/elasticbeanstalk/?sc_channel=el&sc_campaign=genaiwave&sc_geo=mult&sc_country=mult&sc_outcome=acq&sc_content=genai-5-things) or [AWS Fargate](https://aws.amazon.com/fargate/?sc_channel=el&sc_campaign=genaiwave&sc_geo=mult&sc_country=mult&sc_outcome=acq&sc_content=genai-5-things) allow your application to scale automatically. This is crucial for handling variable loads, which is common in AI applications.
- **Storage Solutions**: Your application will likely generate a lot of data. AWS offers several storage services like [S3](https://aws.amazon.com/s3/) for object storage, [EFS](https://aws.amazon.com/efs/?sc_channel=el&sc_campaign=genaiwave&sc_geo=mult&sc_country=mult&sc_outcome=acq&sc_content=genai-5-things) for shared file storage, and [FSx](https://aws.amazon.com/fsx/) for more specific use cases like high-performance computing, which can be important for training data and model storage.
- **Database Services**: AWS has a range of database services such as [DynamoDB](https://aws.amazon.com/dynamodb/?sc_channel=el&sc_campaign=genaiwave&sc_geo=mult&sc_country=mult&sc_outcome=acq&sc_content=genai-5-things) for NoSQL options or [RDS](https://aws.amazon.com/rds/?sc_channel=el&sc_campaign=genaiwave&sc_geo=mult&sc_country=mult&sc_outcome=acq&sc_content=genai-5-things) for SQL databases. The choice depends on whether your application needs quick reads/writes or complex transactions.
- **Security and Compliance**: Ensure that your infrastructure aligns with AWS security best practices. Use services like AWS Identity and Access Management [(IAM)](https://aws.amazon.com/iam/?sc_channel=el&sc_campaign=genaiwave&sc_geo=mult&sc_country=mult&sc_outcome=acq&sc_content=genai-5-things) to control access to resources. Also, make sure to comply with relevant data protection regulations, which AWS services are designed to support.

Choose the approach that aligns with your project's specific needs and the trade-offs between simplicity and flexibility. You can also mix both approaches as needed.

## #5. Ethical & Regulatory

Upholding ethical values must be the highest priority when developing AI application. The well-being of individuals and society should always come before profits or convenience. You must proactively build fairness, transparency, accountability, and privacy into the system. This prevents bias, discrimination, and other harms. While regulatory compliance is mandatory, ethical considerations are paramount. If an action respects human dignity but violates a minor regulation, the spirit of ethics should prevail. With conscientious governance and embedding moral values early in the design process, AI can become a powerful force for good in the world. This thoughtful approach earns public trust and enables sustainable innovation that uplifts humanity. Here are some things to consider:

Ethical considerations:

- **Bias and unfairness**: Generative models can reflect and amplify the biases present in their training data. This can lead to unfair outcomes, especially for marginalized groups. Researchers need to audit the data and models for biases and make sure generative systems do not discriminate unfairly.
- **Manipulation and deception**: Generative techniques can be used to manipulate audio, images, video, text in ways that are hard for people to detect. This can be used to generate synthetic media for malicious deception and manipulation. Researchers need to consider the implications of these techniques and potential countermeasures.
- **Privacy concerns**: Generative models can be trained on personal data which can raise privacy issues, especially if that data is sensitive. Closely guarded data, like medical records, should not be used without users' consent and proper anonymization.
- **Lack of transparency and explainability**: Most generative models are based on complex neural networks that are opaque and hard to explain. It is difficult to understand exactly why they generate the outputs they do. This lack of explainability can be problematic, especially in high-stakes applications. Researchers need to improve the transparency of these models.
- **Openness and oversight**: There needs to be more openness and oversight on the progress of generative research to guide it in a direction aligned with ethics and human values.

Regulatory considerations:

- **Data Protection Laws**: Comply with data protection regulations, such as the General Data Protection Regulation (GDPR) in Europe, which sets strict rules on data handling and user consent.
- **Intellectual Property**: Respect intellectual property rights. Be aware of copyright laws when generating content that might be based on copyrighted material.
- **Content Moderation**: Depending on your application, you may be subject to content moderation regulations, particularly when your AI system generates user-generated content.
- **Accessibility**: Ensure that your generative AI application is accessible to individuals with disabilities, in line with accessibility regulations like the Americans with Disabilities Act (ADA).
- **Export Controls**: Be mindful of export controls and sanctions that may restrict the use and dissemination of certain technologies, especially in international contexts.
- **Industry-Specific Regulations**: Different industries may have specific regulations that pertain to AI applications. For instance, healthcare AI systems must comply with health data privacy laws.
- **Transparency and Accountability**: Some regions and countries are considering regulations that demand transparency and accountability in AI systems, which may include disclosure of automated systems in use.

Your compliance responsibility when using AWS services is determined by the sensitivity of your data, your company's compliance objectives, and applicable laws and regulations. For example, Amazon Bedrock helps you build generative AI applications that support [data security and compliance standards, including GDPR and HIPAA](https://aws.amazon.com/bedrock/security-compliance/?sc_channel=el&sc_campaign=genaiwave&sc_geo=mult&sc_country=mult&sc_outcome=acq&sc_content=genai-5-things).

## Conclusion

It's important to thoroughly plan and test your generative AI application to ensure it meets your project goals and adheres to best practices for responsible AI development. We would be delighted to continue this conversation and make a connection. Please feel free to get in touch with [Arjun](https://www.linkedin.com/in/arjunshakdher/) and [Jin](https://www.linkedin.com/in/ztanruan/) via LinkedIn, send us a message, or come say hello at re:Invent 2023.
