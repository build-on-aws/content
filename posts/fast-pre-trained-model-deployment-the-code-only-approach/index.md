---
title: "Fast Pre-trained Model Deployment - The code only approach"
description: Deploying pre-trained and foundation models quickly, and programmatically, using Amazon SageMaker JumpStart, and the SageMaker SDK.
tags:
  - generative-ai
  - machine-learning
  - artificial-intelligence
spaces:
  - generative-ai
authorGithubAlias: mikegc-aws
authorName: Mike Chambers
date: 2023-08-01
---

For many of us, our ML journeys are stood on the shoulders of giants.  We work with well researched and well understood algorithms such as XGBoost, ResNet and many more.  We deploy pre-trained models like BERT, ResNet50 and others.  And we fine-tune pre-trained generative AI and foundation models like Falcon and Stable Diffusion.  

Collections of algorithms and models are made available via frameworks and platform providers such as PyTorch Hub, Hugging Face and Amazon SageMaker JumpStart.  JumpStart combines pre-trained, open-source models with the Amazon SageMaker environment making it easy to retrain and deploy models quickly into production.

The easiest way to interact with SageMaker JumpStart is through SageMaker Studio.  SageMaker Studio is a web-based integrated development environment (IDE) for ML workloads.  In Studio you can search and browse JumpStart, deploy models with a couple clicks, or open pre-written notebooks to work more directly with an SDK.  

In this post I will explore how to use the SageMaker SDK to programmatically navigate Amazon SageMaker JumpStart, discover available models, train/re-train/fine-tune and optionally deploy to a real-time endpoint or to make batch inference.  This post should apply to any JumpStart model, and show the techniques needed to get up and running quickly, with repeatable code.  While I will outline how to launch models, I will not go into depth on each and every model type.

## The SageMaker SDK

Very nearly everything in AWS is configurable through an API.  To abstract away some of the API "undifferentiated heavy lifting" AWS publishes SDKs, such as the Boto3.  The Boto3 SDK for Python can be used with nearly every AWS service, including SageMaker.  However, in order to help ML Engineers move as quickly as possible, the Amazon SageMaker team publishes another SDK.  The SageMaker SDK wraps common ML tasks such as model training and model inference into higher level constructs, so that ML Engineers can spend more time focusing on ML code.   This post will dive into the SageMaker JumpStart elements of the SageMaker SDK.

To get started with the SageMaker SDK, start up your favorite Python IDE such as SageMaker Studio, or VSCode.  Start a new project, or code file, or notebook, and we will get going...

If you're not using SageMaker Studio, you many need to install the SageMaker SDK.  If you're using `pip` you can install the latest SageMaker SDK as follows:

```python
!pip install sagemaker
```

Next you will need to load the SageMaker libraries.  We will focus on the parts of the SageMaker SDK that interact with JumpStart.  Further down in this post we will see what each of these imports does.

```python
import sagemaker
from sagemaker.jumpstart.notebook_utils import list_jumpstart_models
from sagemaker.jumpstart.filters import And, Or
from sagemaker import image_uris, model_uris, script_uris, hyperparameters
from sagemaker.utils import name_from_base
from sagemaker import get_execution_role
```

We will also add a couple of other libraries for convenience.

```python
import json  # Only used to make dict prints pretty
import boto3 # If this is not installed - pip install boto3
```

## Choosing a model

The `list_jumpstart_models()` JumpStart notebook utility allows us to get a list of all the current JumpStart models.  Let's get them all and count them!

```python
all_models = list_jumpstart_models()

len(all_models)
```

```bash
> 620
```

At the time of writing there are over 600 models, so we will use some filters to focus in on the models we want.  Let's look at the PyTorch models.

```python
filter_value = "framework == pytorch"
filtered_models = list_jumpstart_models(filter=filter_value)

len(filtered_models)
```

```bash
> 52
```

This is a much more manageable list.  Let's take a look.

```python
filtered_models
```

```bash
['pytorch-eqa-bert-base-cased',
 'pytorch-eqa-bert-base-multilingual-cased',
 'pytorch-eqa-bert-base-multilingual-uncased',
 'pytorch-eqa-bert-base-uncased',
...
 'pytorch-od1-fasterrcnn-resnet50-fpn',
 'pytorch-tabtransformerclassification-model',
 'pytorch-tabtransformerregression-model',
 'pytorch-textgeneration1-alexa20b']
```

We can filter down even further, by task.  Let's look for `pytorch` models for image classification (`ic`).

```python
filter_value = And("task == ic", "framework == pytorch")
filtered_models = list_jumpstart_models(filter=filter_value)

filtered_models
```

```bash
['pytorch-ic-alexnet',
 'pytorch-ic-densenet121',
 'pytorch-ic-densenet161',
 'pytorch-ic-densenet169',
 'pytorch-ic-densenet201',
 'pytorch-ic-googlenet',
 'pytorch-ic-mobilenet-v2',
 'pytorch-ic-resnet101',
 'pytorch-ic-resnet152',
 'pytorch-ic-resnet18',
 'pytorch-ic-resnet34',
 'pytorch-ic-resnet50',
 'pytorch-ic-resnext101-32x8d',
 'pytorch-ic-resnext50-32x4d',
 'pytorch-ic-shufflenet-v2-x1-0',
 'pytorch-ic-squeezenet1-0',
 'pytorch-ic-squeezenet1-1',
 'pytorch-ic-vgg11',
 'pytorch-ic-vgg11-bn',
 'pytorch-ic-vgg13',
 'pytorch-ic-vgg13-bn',
 'pytorch-ic-vgg16',
 'pytorch-ic-vgg16-bn',
 'pytorch-ic-vgg19',
 'pytorch-ic-vgg19-bn',
 'pytorch-ic-wide-resnet101-2',
 'pytorch-ic-wide-resnet50-2']
```

Okay, we can see a pattern in the names of the models.  The model framework and the task are the first parts in a '-' concatenated string.  Let's use this to extract lists of all the frameworks and then all the tasks that JumpStart currently supports.  

We can use `all_models` (created above using `list_jumpstart_models()`), and parse it.

```python
# Get a list of frameworks
frameworks = []
for all_model in all_models:
	parts = all_model.split('-')
	if parts[0] not in frameworks:
		frameworks.append(parts[0])

frameworks
```

```bash
['autogluon',
 'catboost',
 'huggingface',
 'lightgbm',
 'model',
 'mxnet',
 'pytorch',
 'sklearn',
 'tensorflow',
 'xgboost']
```

Note:  At the time of writing, there is framework called `model`, if you have a look, they include models from Stability AI and include their famous Stable Diffusion text to image models.  

```python
# Get a list of tasks
tasks = []
for all_model in all_models:
	parts = all_model.split('-')
	if parts[1] not in tasks:
		tasks.append(parts[1])

tasks
```

```bash
['classification',
 'regression',
 'eqa',
 'fillmask',
 'ner',
 'spc',
 'summarization',
 'tc',
 'text2text',
 'textgeneration',
 'translation',
 'txt2img',
 'zstc',
 'inpainting',
 'upscaling',
 'is',
 'od',
 'semseg',
 'tcembedding',
 'ic',
 'od1',
 'tabtransformerclassification',
 'tabtransformerregression',
 'textgeneration1',
 'audioembedding',
 'icembedding']
```

Now let's use what we have so far and select a model that we can work with.  I'm going to filter and find Stable Diffusion text to image models. 

```python
filter_value = And("task == txt2img", "framework == model")
filtered_models = list_jumpstart_models(filter=filter_value)

filtered_models
```

```bash
['model-txt2img-stabilityai-stable-diffusion-v1-4',
 'model-txt2img-stabilityai-stable-diffusion-v1-4-fp16',
 'model-txt2img-stabilityai-stable-diffusion-v2',
 'model-txt2img-stabilityai-stable-diffusion-v2-1-base',
 'model-txt2img-stabilityai-stable-diffusion-v2-fp16']
```

Let's set the model that I will use for the rest of this post in to a variable.  We also set the model_version to the latest.

```python
model_id = 'model-txt2img-stabilityai-stable-diffusion-v2-1-base'    # Replace with the model of your choice.
model_version = "*"                                                  # Latest
```

## Finding a container

Part of SageMaker's value to ML Engineers, is it's ability to automatically manage infrastructure (at scale if required).  At the core of this infrastructure management are Docker containers.  While you can bring your own SageMaker compliant container, often the easiest method is to use one of SageMaker's many pre-built containers, with your own code, or in this case, with JumpStart code.  Each of the models in JumpStart are associated with an AWS pre-built container and one or more code packages for inference and training (when supported).  

Using the SageMaker SDK we can get all the values we need to create a SageMaker Estimator or SageMaker Transformer object which will manage the infrastructure for us.  We need to determine the compatible container URI, the compatible code package URI, and the URI for the model itself, all for the region we are in.  It should be noted that SageMaker is flexible enough for you to replace any or all of these components with your own.  For example, you could write your own inference script to work with the chosen model, you can even download the AWS managed code and make changes to suite your own specific needs.

To get the URIs we need, we must make some decisions.  First we need to decide if we are re-training the model, or making inference - this may influence the code package URI we get.  Then we need to decide what compute resource we are going to use - this will also influence the code package URI we get, as some instances have GPU, indeed some code is not supported without GPU.

Let's make these decisions in the following variables.

```python
scope = 'training'                  # training | inference
instance_type = 'ml.p3.2xlarge'     # https://aws.amazon.com/sagemaker/pricing/instance-types
```

Now we can use the SageMaker JumpStart SDK to get the necessary URIs.

```python
image_uri = image_uris.retrieve(
	region=None,
	framework=None,  # automatically inferred from model_id
	image_scope=scope,
	model_id=model_id,
	model_version=model_version,
	instance_type=instance_type,
)
print("image_uri: {}".format(image_uri))

source_uri = script_uris.retrieve(
	model_id=model_id, model_version=model_version, script_scope=scope
)
print("source_uri: {}".format(source_uri))

model_uri = model_uris.retrieve(
	model_id=model_id, model_version=model_version, model_scope=scope
)
print("model_uri: {}".format(model_uri))
```

```bash
image_uri: 763104351884.dkr.ecr.us-east-1.amazonaws.com/huggingface-pytorch-training:1.10.2-transformers4.17.0-gpu-py38-cu113-ubuntu20.04

source_uri: s3://jumpstart-cache-prod-us-east-1/source-directory-tarballs/stabilityai/transfer_learning/txt2img/prepack/v1.0.3/sourcedir.tar.gz

model_uri: s3://jumpstart-cache-prod-us-east-1/stabilityai-training/train-model-txt2img-stabilityai-stable-diffusion-v2-1-base.tar.gz
```

The `image_uri` is the location in the Amazon Elastic Container Registry for a container image that is compatible with the model we select.

The `source_uri` is the location in S3 of pre-written code to perform inference or training (when supported) as per the scope we selected.  Feel free to download this code, take a look, and even make some changes.  If you do change the code you will need to re-compress (tar.gz) and make it available in an S3 bucket you control.

The `model_uri` is the location in S3 of the model itself.

## Create an Estimator (Training/re-training)

Many of the models in JumpStart are ready to go and could be deployed to solve common problems right away.  But many (not all) of the models can be re-trained or fine-tuned on your own data to make them more specific to your use case.  For example an object detection algorithm that can already detect trucks, could be re-trained to detect your companies trucks vs other trucks.  Re-training doesn't even need to align with the models current capabilities.  In my bid to design a Lego brick sorting machine, I have used generically trained models (ones that can recognise dogs, cats, trucks, and cars etc) to detect Lego bricks.   Re-training is often much much quicker than training a model from scratch.

For this step, SageMaker JumpStart has one more trick up it's sleeve.  We can get a set of training hyperparameter suggestions that go along with our selected model.   We can use these hyperparameters as they are, or use them as a starting point in our training experimentation.

```python
training_hyperparameters = hyperparameters.retrieve_default(
    model_id=model_id, model_version=model_version
)

training_hyperparameters
```

```bash
{'epochs': '20',
 'max_steps': 'None',
 'batch_size': '1',
 'with_prior_preservation': 'False',
 'num_class_images': '100',
 'learning_rate': '2e-06',
 'prior_loss_weight': '1.0',
 'center_crop': 'False',
 'lr_scheduler': 'constant',
 'adam_weight_decay': '0.01',
 'adam_beta1': '0.9',
 'adam_beta2': '0.999',
 'adam_epsilon': '1e-08',
 'gradient_accumulation_steps': '1',
 'max_grad_norm': '1.0',
 'seed': '0'}
```

To re-train a model using SageMaker, we create an Estimator object.  This object can then be used to deploy the infrastructure and manage the training task. 

```python
from sagemaker.estimator import Estimator

aws_role = get_execution_role()
sess = sagemaker.Session()
bucket = sess.default_bucket()

name = name_from_base("jumpstart-{}-{}".format(model_id, scope))

# Create SageMaker Estimator instance
estimator = Estimator(
    role=aws_role,
    image_uri=image_uri,
    source_dir=source_uri,
    model_uri=model_uri,
    # Entry-point present in source_uri, if in doubt, 
    # download the script package and review contents.
    entry_point="train.py",
    instance_count=1,
    instance_type=instance_type,
    max_run=360000,
    hyperparameters=training_hyperparameters,
    output_path=bucket,
    base_job_name=name,
)
```

To kick-off the actual training task we need to format our training data for the model we chose, and place it in an S3 bucket.  I'm not going to list out here all the data formats for all the models.  To discover the format required take a look at the model page from the original provider (e.g. Hugging Face) and/or download the training code to determine what is required.

Once you have your data, and are ready to train your model you can use the following line of code.  Training time depends on the model and size of your training data.  It will take at least a few minutes or hours or days!

```python
estimator.fit({"training": training_dataset_s3_path}, logs=True)
```

Once training is complete, the model will be saved to the output location specified when creating the Estimator, in our case the default bucket for SageMaker in the region we are working in.

## Create a SageMaker Model (for inference)

At inference time, we will need to create a model.  Wait... we already have the URI of the model, why do we need to create one?  Well, in this step we are creating a SageMaker Model object.  This object combines all the URIs we found with some configuration, and gets us ready to deploy the model or create a Transformer (see later - and not the same as a generative AI transformer!).

```python
from sagemaker.estimator import Model
from sagemaker.predictor import Predictor

aws_role = get_execution_role()

name = name_from_base("jumpstart-{}-{}".format(model_id, scope))

# Create the SageMaker model instance
model = Model(
    image_uri=image_uri,
    source_dir=source_uri,
    model_data=model_uri,
    # Entry-point present in source_uri, if in doubt, 
    # download the script package and review contents.
    entry_point="inference.py",
    role=aws_role,
    predictor_cls=Predictor,
    name=name,
)
```

With the model created, we are ready to deploy it to a real-time hosted endpoint or create a batch job to process multiple records.   If we want to process user requests, on demand, and we have no control over when the requests will arrive, such as from a website or app, we would use a realtime endpoint.  If we are processing records that already exist, such as customer records, we might choose to perform a batch job.  With a real-time endpoint we pay while the endpoint hosting instance is up and running.  For a batch job the batch instance is only up while data is being processed, and the instance will terminate when the job is complete.

## Setting up a real-time hosted endpoint

To create an endpoint we call `deploy` on the model object.  We pass in the number of instances we want.  This step will take a few minutes while the infrastructure is deployed.

```python
# Deploy the Model. Note that we need to pass Predictor class when we deploy model through Model class,
# for being able to run inference through the SageMaker API.

model_predictor = model.deploy(
	initial_instance_count=1,
    instance_type=instance_type,
    predictor_cls=Predictor,
    endpoint_name=name,
)
```

### Okay, I've had enough of real-time...

To delete the running endpoint, and delete the model, run the following.

```python
# Delete the SageMaker endpoint
model_predictor.delete_endpoint()
model_predictor.delete_model()
```

If you come to this step some time later, and you've lost the reference to the `model_predictor`, navigate to Amazon SageMaker in the console, click `Inference` from the left hand menu, and use `Models` and `Endpoints` to delete the resources.

## Setting up a batch inference job

To create a batch job, we need to add the batch input data into an S3 bucket.  Then we create a SageMaker Transformer and trigger the batch job as follows.

```python
transformer = model.transformer(instance_count=1, instance_type=instance_type)

transformer.transform(
     "s3://[input_bucket]/input/",
     content_type="application/json" # Example, again look at the inference code to get this value.
)
transformer.wait()
```

### Okay, I've had enough, I won't run another batch job...

To delete the model, run the following.

```python
# Delete the SageMaker endpoint
transformer.delete_model()
```

If this is some time later and you lost the reference to the `transformer`, navigate to Amazon SageMaker in the console, click `Inference` from the left hand menu and use `Models` to delete the resource.

## Conclusion

In this post we have seen how the Amazon SageMaker SDK can be used to search JumpStart and find all the available models.  We have filtered the model list by framework and task.  We then discovered the URIs of all the components we needed to launch training or inference infrastructure.  Finally, while we didn't dive deep into the Estimator, Model and Transformer, we saw how they can be used to manage infrastructure lifecycle for us, so that we can focus on delivering ML value for our projects.

If you have any questions about the topics raised in this post, or would like to see more posts on similar topics, please reach out!
