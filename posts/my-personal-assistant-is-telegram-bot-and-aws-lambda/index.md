---
layout: blog.11ty.js
title: My Personal Assistant is Telegram Bot (and AWS Lambda)
description: Every developers should have personal (bot) assistant to get things (or boring tasks) done. 
tags:
  - telegram 
  - bot 
  - serverless
authorGithubAlias: donnieprakoso 
authorName: Donnie Prakoso
date: 2022-07-07
---

We often need tools to get things done. As a developer, one of my productivity hacks is to use Telegram bots to help me get things done quickly. From checking the bus schedule for commuting, to image resizing. Most of the small, unpleasant tasks I delegate to the Telegram bot. Simply put, Telegram bot is my personal assistant. 

If that opening line got your interest, this article will provide you the base foundation to build Telegram bot. Plus, with ready-to-deploy codes which you can find on this Github repo.

> You can find the source code in this Github repo: [donnieprakoso/telegram-bot-boilerplate](https://github.com/donnieprakoso/telegram-bot-boilerplate).


Now, let's get more technical. 

To interact with Telegram bots — such as getting messages or photos — we can use the polling method ([getUpdates](https://core.telegram.org/bots/api#getting-updates)) and webhook ([setWebhook](https http://core.telegram.org/bots/api#setwebhook)). Of these two methods, I'm more comfortable using a webhook because I don't have to develop polling mechanisms that use resources inefficiently. With a webhook, if there is a message, Telegram will make a `POST` request to the webhook URL which will trigger our backend to process the request.

![](images/TelegramBot-Page-1.drawio.png)

In this article, I will explain how I built a Telegram bot that integrates with webhooks and serverless APIs. For the serverless API, I will use the Amazon API Gateway integrated with an AWS Lambda function. This article won't explain how I built a bot to notify me about bus schedules or resizing images. However, I will explain the basic concepts using the same source code that I am currently using for all of my bots.

![](images/TelegramBot-Page-2.drawio.png)

Like my other articles, all of the stacks here will use the AWS CDK for provisioning resources so we get a consistent deployment. If you haven't used the AWS CDK, please install the CDK first, and follow the tutorial for bootstrapping.

## Let's Get Started!

### Step 1: Request bot using @BotFather

First, we need to create a bot using [@BotFather](https://t.me/botfather). You need to run the command `/newbot` and follow the instructions from @BotFather to give it a name. Once that's all done, you'll get the URL for the bot you just created as well as a token that you can use to interact with your bot.

![](images/registration-1.png)

After you get the token, keep your token safe and don't share it with anyone for security reasons. We will use Telegram token in the following steps.

### Step 2: Deploy Webhook using Serverless API

In this step we will deploy the serverless API. The output of this step is the API Endpoint URL that we can use to register the webhook for the Telegram bot that we just created. Before we deploy this serverless API stack, let's do a code review so you understand what the CDK app will do.

#### Code Review: SSM Parameter Store

The first thing we need to define in the CDK app is to create resources to store the Telegram token. Of course we want to avoid hard coding in this application. We will use the AWS SSM Parameter Store which we can later retrieve inside the AWS Lambda function. The parameter name that we use is `telegram_token` which you can find in the SSM Parameter Store dashboard, with a dummy value of `TELEGRAM_TOKEN` which we will need to change manually later.

```python
ssm_telegram_token = _ssm.StringParameter(self, id="{}-ssm-telegram-token".format(
    stack_prefix), parameter_name="telegram_token", description="Telegram Bot Token", type=_ssm.ParameterType.STRING, string_value="TELEGRAM_TOKEN")
```

#### Code Review: IAM Roles

The next thing we need to define are the IAM roles that define AWS Lambda access to write log groups with Amazon CloudWatch as well as access to the SSM Parameter Store. For the record, we can grant access to the AWS Lambda function by calling the `.grant_read()` function, but I prefer this approach because I can explicitly implement for [least privilege](https://docs.aws.amazon.com/IAM/latest/UserGuide/best-practices.html#grant-least-privilege.html).

```python
lambda_role = _iam.Role(
    self,
    id='{}-lambda-role'.format(stack_prefix),
    assumed_by=_iam.ServicePrincipal('lambda.amazonaws.com'))

cw_policy_statement = _iam.PolicyStatement(effect=_iam.Effect.ALLOW)
cw_policy_statement.add_actions("logs:CreateLogGroup")
cw_policy_statement.add_actions("logs:CreateLogStream")
cw_policy_statement.add_actions("logs:PutLogEvents")
cw_policy_statement.add_actions("logs:DescribeLogStreams")
cw_policy_statement.add_resources("*")
lambda_role.add_to_policy(cw_policy_statement)

ssm_policy_statement = _iam.PolicyStatement(effect=_iam.Effect.ALLOW)
ssm_policy_statement.add_actions("ssm:DescribeParameters")
ssm_policy_statement.add_actions("ssm:GetParameter")
ssm_policy_statement.add_resources(ssm_telegram_token.parameter_arn)
lambda_role.add_to_policy(ssm_policy_statement)
```

#### Code Review: Define AWS Lambda Function

After that, we will define the AWS Lambda function which is the central point in processing the request. Here, I define some properties for AWS Lambda functions, such as `handler`, `timeout`, `tracing` using AWS X-Ray, and using Python 3.8 `runtime`. For `role`, we will use `lambda_role` which we defined above. Also, for AWS Lambda to be able to get the SSM Parameter Store, we will pass an environment variable called `SSM_TELEGRAM_TOKEN`.

```python
fnLambda_handle = _lambda.Function(
    self,
    "{}-function-telegram".format(stack_prefix),
    code=_lambda.AssetCode("../lambda-functions/webhook"),
    handler="app.handler",
    timeout=core.Duration.seconds(60),
    role=lambda_role,
    tracing=_lambda.Tracing.ACTIVE,
    runtime=_lambda.Runtime.PYTHON_3_8)
fnLambda_handle.add_environment(
    "SSM_TELEGRAM_TOKEN", ssm_telegram_token.parameter_name)
```

*But what about the code for AWS Lambda?*

Here we define `AssetCode` which we can get in `lambda-functions/webhook` folder. There is only 1 main file which is `app.py`, and let's evaluate what this AWS Lambda (`lambda-functions/webhook/app.py`) will do:

The first thing it will do is get the Telegram token for the SSM Parameter Store using string `SSM_TELEGRAM_TOKEN` from the environment variables. To do this, we just need to call `os.getenv("SSM_TELEGRAM_TOKEN")`. The important thing here is how we construct the `TELEGRAM_BASE_URL` variable which is the Telegram endpoint to interact with bots.

```python
# Get SSM Parameter Store for Telegram Token
ssm = boto3.client('ssm')
SSM_TELEGRAM_TOKEN = os.getenv('SSM_TELEGRAM_TOKEN')
TELEGRAM_TOKEN = ssm.get_parameter(Name=SSM_TELEGRAM_TOKEN)[
    "Parameter"]["Value"]
TELEGRAM_BASE_URL = "https://api.telegram.org/bot{}/".format(
    TELEGRAM_TOKEN)
```

Next, we define a function for `send_message`. Here we will pass `chat_ID` so that our `text` message will be sent to the appropriate channel.

```python
def send_message(chat_ID, text):
    data = {"chat_id": chat_ID, "text": text}
    send_message = requests.post("{}{}".format(TELEGRAM_BASE_URL,
                                               "sendMessage"),
                                 data=data)
```

After that, we define the `handler` function which is the main function that will be triggered by AWS Lambda. In the context of my use case, I need to be able to interact with media images as well as text. Therefore, here I define two key properties, namely `text` to be able to parse requests for text messages, and also `photo` to process messages with images.

```python
def handler(event, context):
    try:
        logger.info(event)
        data = json.loads(event['body'])

        if "text" in data["message"]:
            text_to_reply = "Echo: {}".format(data["message"]["text"])
            send_message(data["message"]["chat"]["id"], text_to_reply)
            response = {"statusCode": 200,
                        "body": json.dumps({"message": "success"})}
        elif "photo" in data["message"]:
            text_to_reply = "Received a photo with caption: {}".format(
                data["message"]["caption"]) if "caption" in data["message"] else "Received a photo"
            send_message(data["message"]["chat"]["id"], text_to_reply)
            response = {"statusCode": 200,
                        "body": json.dumps({"message": "success"})}

        return response
    except Exception as e:
        logger.error("Error on processing request: {}".format(e))
        response = {"statusCode": 200,
                    "body": json.dumps({"message": "success"})}
        return response
```

#### Code Review: REST API with Amazon API Gateway

Back to the CDK app, after defining the SSM Parameter Store, IAM, and AWS Lambda, it's time to define the Amazon API Gateway. 

Here I define a REST API — you can use any API type supported by Amazon API Gateway, such as the HTTP API. After that, I defined the integration for AWS Lambda. We also need to define a resource for this API path URI, and by defining `add_resource("telegram")`, Telegram can use our webhook URL at `exampledomain.com/telegram` using the `POST` method.

```python
api = _ag.RestApi(
    self,
    id="{}-api-gateway".format(stack_prefix),
)

int_webhook = _ag.LambdaIntegration(fnLambda_handle)

res_data = api.root.add_resource('telegram')
res_data.add_method('POST', int_webhook)
```        
        
```python
core.CfnOutput(self,
               "{}-output-apiEndpointURL".format(stack_prefix),
               value=api.url,
               export_name="{}-apiEndpointURL".format(stack_prefix))
```

### Step 3: Deployment

To deploy our serverless API stack, you will first need to install all the libraries that will be used by AWS Lambda functions with the following command in the `lambda-functions/webhook` folder:

```bash
pip install -r requirements.txt -t .
```

After that, you can switch to the `cdk` folder, and deploy the serverless API with the following command:

```bash
cdk deploy
```

Once the process is complete, you will get an endpoint URL from the Amazon API Gateway.

### Step 4: Configure Telegram Token

Before we can use the webhook, we need to set up the Telegram token in the SSM Parameter Store. For that we need to do the following steps:

Go to SSM Parameter store [dashboard](https://ap-southeast-1.console.aws.amazon.com/systems-manager/parameters/?tab=Table) and use `telegram_token` as filter.

![](images/ssm-1.png)
Click the `telegram_token` parameter and click the `Edit` button.

![](images/ssm-2.png)
Change the value of `TELEGRAM_TOKEN` to the value of the Telegram token you got.

![](images/ssm-3.png)
### Step 5: Configure the Webhook

After that, all you need to do now is set up your bot using a webhook. For that, you need to open the following URL and replace it with the appropriate variable:

`https://api.telegram.org/bot{TELEGRAM TOKEN}/setWebhook?url={API ENDPOINT URL}`

Change `{TELEGRAM TOKEN}` to your Telegram token. Then, change `{URL API ENDPOINT}` to the URL of Amazon API Gateway and add `/telegram`, for example: `https://XYZ.execute-api.ap-southeast-1.amazonaws.com/prod/telegram `.

After that, you just need to open a browser and enter the URL. If successful, you will get the following response:

![](images/webhook-1.png)

### Step 6: Testing

And that's it! At this stage, you have already done the integration for your Telegram bot and webhook. For testing, please send a message to your bot. You will get an echo response for the `text` message.

![](images/test-1.png)


You can also send a message with a photo, and get a confirmation image received with or without a caption.

![](images/test-2.png)

If you need to view the logs from your AWS Lambda, you can take a detailed look at the Amazon CloudWatch logs. Here's an example display for logs from my serverless API:

![](images/cw-1.png)

### Step 7: Cleaning Up

Don't forget to clean up all the resources by running this following command in `cdk` folder:

```bash
cdk destroy
```

I know that you won't do this when you're building the bot, and just a quick note for you to clean up the resources.

## Conclusion and What's Next?

And that's how you build a personal assistant with Telegram bot. I use this Telegram bot for various needs, and it is very practical because I can interact with the bot either via mobile phone or from the desktop.

But, what's next? From here you have the basic foundation to build your own logic needs. You can modify the text using keywords or use captions for media images. Let me know what you've built in the comment box below!

Happy building! ️
— Donnie
