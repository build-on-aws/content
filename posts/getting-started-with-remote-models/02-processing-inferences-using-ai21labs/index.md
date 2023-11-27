---
title: "Processing Inferences using AI21 Labs Jurassic 2"
description: "Tutorial about how to implement a remote model that leverages Amazon Bedrock with the foundation model AI21 Labs Jurassic 2."
tags:
  - opensearch
  - ai-ml
  - gen-ai
  - sagemaker
  - bedrock
  - aws
waves:
  - modern-apps
authorGithubAlias: riferrei
authorName: Ricardo Ferreira
date: 2023-11-27
---

| ToC |
| --- |

In the [first part](../01-introduction-opensearch-remote-models/index.md) of this series, you learned the concept of remote models at [OpenSearch](https://opensearch.org/docs/latest/about/) and why they are important. This is a powerful feature that allows you to create AI connectors for ML services like Amazon Sagemaker, Amazon Bedrock, and OpenAI, so your OpenSearch clusters can leverage them while processing data.

In this tutorial, I will walk you through in how to do this with a hands-on example. You will deploy a remote model connected to [Amazon Bedrock](https://docs.aws.amazon.com/bedrock/latest/userguide/what-is-bedrock.html), and using the [AI21 Labs Jurassic 2](https://docs.ai21.com/docs/jurassic-2-models) foundation model. You are going to build a connector blueprint that represents your remote model, will configure it, deploy it, and even practice changing the connector to fine tune their responses.

## Setting up a development OpenSearch cluster

To keep you focused and engaged, this tutorial will assume that you are using a local OpenSearch cluster. Everything you learn here can be used later on with [Amazon OpenSearch](https://docs.aws.amazon.com/opensearch-service/latest/developerguide/gsg.html) clusters. To launch a local OpenSearch cluster, use the Docker Compose available in [this GitHub repository](https://github.com/build-on-aws/getting-started-with-opensearch-remote-models).

1. `git clone https://github.com/build-on-aws/getting-started-with-opensearch-remote-models`
2. `cd getting-started-with-opensearch-remote-models`
3. `docker compose up -d`

This starts two services: an `opensearch` instance, an `opensearch-dashboards` instance. You will use the OpenSearch instance to deploy the remote model and run the inferences. As for the OpenSearch Dashboards instance, you will leverage the feature [Developer Tools](https://opensearch.org/docs/latest/dashboards/dev-tools/index-dev/) as IDE to run commands. Keep in mind that it may take several minutes for the services to start up, as Docker may need to pull their images first from the repositories.

To verify if OpenSearch is up and running, you can go to your browser and point to the following location:

[`http://localhost:9200/_cluster/health`](http://localhost:9200/_cluster/health)

You should see a JSON payload with the following content:

```json
{
  "cluster_name": "opensearch-cluster",
  "**status**": "green",
  "timed_out": false,
  "number_of_nodes": 1,
  "number_of_data_nodes": 1,
  "discovered_master": true,
  "discovered_cluster_manager": true,
  "active_primary_shards": 4,
  "active_shards": 4,
  "relocating_shards": 0,
  "initializing_shards": 0,
  "unassigned_shards": 0,
  "delayed_unassigned_shards": 0,
  "number_of_pending_tasks": 0,
  "number_of_in_flight_fetch": 0,
  "task_max_waiting_in_queue_millis": 0,
  "active_shards_percent_as_number": 100
}
```

If the `status` field is showing as `green`, this means your opensearch cluster is ready for business. Since we will be using the [ML Commons plugin for OpenSearch](https://opensearch.org/docs/latest/ml-commons-plugin/index/), it is important to ensure this plugin is fully initialized before you start sending tasks. To check if the ML Commons plugin is initialized, go to your browser and point to the following location:

http://localhost:9200/.plugins-ml-config

You should see a JSON payload with the following content:

```json
{
  ".plugins-ml-config": {
    "aliases": {},
    "mappings": {
      "_meta": {
        "schema_version": 2
      },
      "properties": {
        "create_time": {
          "type": "date",
          "format": "strict_date_time||epoch_millis"
        },
        "master_key": {
          "type": "keyword"
        }
      }
    },
    "settings": {
      "index": {
        "replication": {
          "type": "DOCUMENT"
        },
        "number_of_shards": "1",
        "auto_expand_replicas": "0-1",
        "provided_name": ".plugins-ml-config",
        "creation_date": "1700085905030",
        "number_of_replicas": "0",
        "uuid": "EO8G2EzqTcepOT8F5BmKoA",
        "version": {
          "created": "136327827"
        }
      }
    }
  }
}
```

This means that the internal index `.plugins-ml-config` has been created, which indicates the plugin is initialized. This should happen relatively fast; but if for some reason you don't see this result right way, try to reload your browser. If you are still unable to see this content, something may be wrong with your OpenSearch cluster. Check the container logs for more details.

Now that you verified everything is working fine with the OpenSearch cluster and the ML Commons plugin, you can prepare your OpenSearch cluster for the remote models' feature. There are specific settings that you must enable in your cluster before proceeding. Go to your browser and point to the following location:

[http://localhost:5601](http://localhost:5601/)

This will open the main page of [OpenSearch Dashboards](https://opensearch.org/docs/latest/dashboards/quickstart/). You will use the feature Dev Tools from OpenSearch Dashboards to run a set of REST API calls against OpenSearch. Alternatively, you can use your own client tool to run these commands—but using Dev Tools will certainly make your life easier. Follow these steps to access the Dev Tools feature.

1. Click on the Dev Tools button.

![opensearch dashboards main page](images/opensearch_dashboards_1.png)

2. With the editor open, try the command `GET _cluster/health` to verify the OpenSearch cluster. To execute the command, leave the line that starts the command selected, and click in the ▶️ execute button.

![opensearch dashboards main page](images/opensearch_dashboards_2.png)

There will have it. Now you can run commands against your OpenSearch cluster with ease. The Dev Tools feature allows you to export and import commands. So everything you will do in this tutorial can be saved into a file and then reused in another OpenSearch cluster, such as a [domain from Amazon OpenSearch](https://docs.aws.amazon.com/opensearch-service/latest/developerguide/gsg.html).

Use the Dev Tools feature to enable the following persistent settings:

```json
PUT /_cluster/settings
{
    "persistent": {
        "plugins.ml_commons.only_run_on_ml_node": false,
        "plugins.ml_commons.update_connector.enabled": true
    }
}
```

Executing this command should produce the following output:

```json
{
  "acknowledged": true,
  "persistent": {
    "plugins": {
      "ml_commons": {
        "only_run_on_ml_node": "false",
        "update_connector": {
          "enabled": "true"
        }
      }
    }
  },
  "transient": {}
}
```

Now let's understand each persistent setting.

With the setting `plugins.ml_commons.only_run_on_ml_node`, you are telling OpenSearch to allow the execution of ML related tasks, such as processing inferences, in any node of the cluster. This is important because remote models execute their inferences in models trained outside OpenSearch. This means that the compute power required to run the inferences won't be from the OpenSearch cluster. By default, this setting is configured to `true`, which means this tutorial would only work if you had configured ML-enabled nodes in your cluster.

Later on in this tutorial, you will see that after deploying the model, a change in the connector blueprint created for AI21 Labs Jurassic 2 will be needed. By default, you are not allowed to change connector blueprints. While this is a good thing for production clusters, during development, ML developers may need to make changes to the connector blueprints, so you need to configure OpenSearch to allow this. For this reason, the `plugins.ml_commons.update_connector.enabled` setting was used.

Your OpenSearch cluster is now ready. Everything done so far was required for you to be able to start what this tutorial really is about: teaching you how to deploy and test remote models. Let's see how this is done in the following sections.

## Creating a remote model group

To work with remote models, each model must belong to a model group. As you learned in the first part of this series, model groups act as containers for deployed models. It gives you a convenient way to find related models. Therefore, before deploying a model, you need to first create a model group if one doesn't exist yet. Create a new model group using the following command:

```json
POST /_plugins/_ml/model_groups/_register
{
    "name": "amazon_bedrock_models",
    "description": "Model group for Amazon Bedrock models"
}
```

You should see a JSON payload with the following content:

```json
{
  "model_group_id": "wiBt1YsBhjmsqc9XKPfL",
  "status": "CREATED"
}
```

Please take a note of the value of the field `model_group_id`. When you register the model later on, you will be required to specify to which model group the model will belong to.

## Creating a connector blueprint

A remote model allows OpenSearch to run inferences in models outside of the cluster via connectors. They are the building blocks that integrate your OpenSearch cluster with AI services such as Amazon Bedrock. To create a connector, an ML developer must first create a connector blueprint. Connector blueprints provide the specification about how the connection with the AI service is established; how the interactions with AI services must be implemented, as well as how to handle the API contract from the remote model.

To create a connector blueprint for Amazon Bedrock using the AI21 Labs Jurassic 2 foundation model, run the following command:

```json
POST /_plugins/_ml/connectors/_create
{
    "name": "Amazon Bedrock",
    "description": "Connector for Amazon Bedrock (AI21 Labs Jurassic 2)",
    "version": 1,
    "protocol": "aws_sigv4",
    "credential": {
        "access_key": "<YOUR AWS ACCESS KEY>",
        "secret_key": "<YOUR AWS SECRET KEY>"
    },
    "parameters": {
        "region": "us-east-1",
        "service_name": "bedrock",
        "model_name": "ai21.j2-mid-v1"
    },
    "actions": [
        {
            "action_type": "predict",
            "method": "POST",
            "headers": {
                "content-type": "application/json"
            },
            "url": "https://bedrock-runtime.${parameters.region}.amazonaws.com/model/${parameters.model_name}/invoke",
            "request_body": "{\"prompt\":\"${parameters.inputs}\",\"maxTokens\":200,\"temperature\":0.7,\"topP\":1,\"stopSequences\":[],\"countPenalty\":{\"scale\":0},\"presencePenalty\":{\"scale\":0},\"frequencyPenalty\":{\"scale\":0}}"
        }
    ]  
}
```

You should see a JSON payload with the following content:

```json
{
  "connector_id": "wyB41YsBhjmsqc9X5_fW"
}
```

Please take a note of the value of the field `connector_id`. When you register the model later on, you will be required to specify which connector blueprint the remote model should use.

Let's understand the connector blueprint created. Within the JSON payload, the fields `protocol` and `credentials` are used to specify how OpenSearch will authenticate with Amazon Bedrock. Make sure to provide an AWS access key and secret key from a user/role that has permissions to invoke Amazon Bedrock. Alternatively, you can also include another field called `session_key` within the `credentials` field to use a session key if needed.

In the actions field, you provided all the information that OpenSearch will use to establish connections with Amazon Bedrock and send requests. Note that the `url` field uses some of the values that you provided in the `parameters` field using the `${value}` expression. This is a handy way for you to reuse a value that may repeat several times throughout the connector blueprint configuration. In the `request_body` field, the value provided adheres with the specification of the AI21 Labs Jurassic 2 foundation model. This is important to know because if you decide to use another foundation model from Amazon Bedrock, you will need to update this field value accordingly. Even better, you can create another connector blueprint in the same model group with a different configuration.

Also, note that if you need to search for a specific connector blueprint by its name, such as the `Amazon Bedrock` created earlier, you can use the following search:

```json
GET /_plugins/_ml/connectors/_search
{
  "query": {
    "match_phrase": {
      "name": "Amazon Bedrock"
    }
  }
}
```

This will allow you to review any configuration made to the connector blueprint. Being a search-based technology, OpenSearch allows you to use the built-in supported searches like [Full-text queries](https://opensearch.org/docs/latest/query-dsl/full-text/index/) to find virtually anything you want.

## Registering and deploying the model

Now that you have created the model group and the connector blueprint, you can finally register and deploy your remote model. To start things off, execute the following command to register the remote model.

```json
POST /_plugins/_ml/models/_register
{
    "name": "ai21.j2-mid-v1",
    "function_name": "remote",
    "model_group_id": "wiBt1YsBhjmsqc9XKPfL",
    "description": "Model for Amazon Bedrock (AI21 Labs Jurassic 2)",
    "connector_id": "wyB41YsBhjmsqc9X5_fW"
}
```

Mind that the fields `model_group_id` and `connector_id` use the values you took note in previous sections. The output of this command should contain the following JSON payload:

```json
{
  "task_id": "xSDN1YsBhjmsqc9X8vdY",
  "status": "CREATED",
  "model_id": "xiDN1YsBhjmsqc9X8vet"
}
```

Please take a note of the value of the field `model_id`. This is your remote model that you will use to run inferences. It may take some time for the remote model to register. In this case, you can use the field `task_id` to follow up about the status of the registering process. Behind the command you just ran, a task was created at OpenSearch in one of its nodes. If you want to check the status of this task, use the following command:

```bash
GET /_plugins/_ml/tasks/xSDN1YsBhjmsqc9X8vdY
```

You should see a JSON payload with the following content:

```json
{
  "model_id": "xiDN1YsBhjmsqc9X8vet",
  "task_type": "REGISTER_MODEL",
  "function_name": "REMOTE",
  "**state**": "COMPLETED",
  "worker_node": [
    "Wy2Qj6mJRbO5O9BHxbnFtw"
  ],
  "create_time": 1700099125847,
  "last_update_time": 1700099125956,
  "is_async": false
}
```

With the output of this command, not only you can retrieve the `model_id` value from the remote model, but you can also check the status of the task with the field state. `COMPLETED` indicates the task has been successfully completed.

Alternatively, you can also check the status of the remote model itself. To check the status of the remote model, use the following command:

```
GET /_plugins/_ml/models/xiDN1YsBhjmsqc9X8vet
```

You should see a JSON payload with the following content:

```json
{
  "name": "ai21.j2-mid-v1",
  "model_group_id": "wiBt1YsBhjmsqc9XKPfL",
  "algorithm": "REMOTE",
  "model_version": "1",
  "description": "Model for Amazon Bedrock (AI21 Labs Jurassic 2)",
  "**model_state**": "REGISTERED",
  "created_time": 1700099125881,
  "last_updated_time": 1700099125881,
  "connector_id": "wyB41YsBhjmsqc9X5_fW"
}
```

Mind the value of the field `model_state`. Right now it is set to `REGISTERED` which means that OpenSearch is aware of this remote model but is not necessarily ready to be used. Let's change this. To deploy the remote model, run the following command:

```bash
POST /_plugins/_ml/models/xiDN1YsBhjmsqc9X8vet/_deploy
```

Executing this command creates a task with OpenSearch to deploy the remote model. This happens in one of the nodes from the cluster. To verify if the command completed, you can verify the status of the model again:

```bash
GET /_plugins/_ml/models/xiDN1YsBhjmsqc9X8vet
```

Will generate an output similar to this:

```json
{
  "name": "ai21.j2-mid-v1",
  "model_group_id": "wiBt1YsBhjmsqc9XKPfL",
  "algorithm": "REMOTE",
  "model_version": "1",
  "description": "Model for Amazon Bedrock (AI21 Labs Jurassic 2)",
  "**model_state**": "DEPLOYED",
  "created_time": 1700099125881,
  "last_updated_time": 1700099683770,
  "last_deployed_time": 1700099683769,
  "planning_worker_node_count": 1,
  "current_worker_node_count": 1,
  "planning_worker_nodes": [
    "Wy2Qj6mJRbO5O9BHxbnFtw"
  ],
  "deploy_to_all_nodes": true,
  "connector_id": "wyB41YsBhjmsqc9X5_fW"
}
```

Note the value of the field `model_state`. This time it says `DEPLOYED` which means that OpenSearch is now both aware of this remote model and ready to allow inferences to be executed. The output now also includes other relevant details such as which nodes from the OpenSearch cluster are being used for planning the execution, as well as how much planning and worker nodes there are. For the usage of the remote model, this information is totally irrelevant. But it is useful for system administrators who want to know a bit better how OpenSearch is scheduling the work of inference executions across the cluster.

Another way to verify if the mode is properly deployed and ready to be used is using OpenSearch Dashboards. If you go to `OpenSearch Plugins` then `Machine Learning`, you will see a table containing all your deployed models. Look for the model named `ai21.j2-mid-v1`.

![opensearch dashboards ml plugin](images/dashboards_ml_plugin.png)

## Testing the remote model with inferences

Now that your remote model is properly deployed, it is time for you to test it. Testing a remote model is the process of running inferences against the model. As a first test, you can ask the model about one of the most asked questions by human beings: what is the meaning of life?

To ask this question, run the following command:

```json
POST /_plugins/_ml/models/xiDN1YsBhjmsqc9X8vet/_predict
{
  "parameters": {
    "inputs": "What is the meaning of life?"
  }
}
```

You should see a JSON payload with a similar content:

```json
{
  "inference_results": [
    {
      "output": [
        {
          "name": "response",
          "dataAsMap": {
            "id": 1234,
            "prompt": {
              "text": "What is the meaning of life?",
              "tokens": [
                {
                  "generatedToken": {
                    "token": "▁What▁is▁the▁meaning",
                    "logprob": -16.23928451538086,
                    "raw_logprob": -16.23928451538086
                  },
                  "topTokens": null,
                  "textRange": {
                    "start": 0,
                    "end": 19
                  }
                },
                {
                  "generatedToken": {
                    "token": "▁of▁life",
                    "logprob": -4.316580772399902,
                    "raw_logprob": -4.316580772399902
                  },
                  "topTokens": null,
                  "textRange": {
                    "start": 19,
                    "end": 27
                  }
                },
                {
                  "generatedToken": {
                    "token": "?",
                    "logprob": -3.9127988815307617,
                    "raw_logprob": -3.9127988815307617
                  },
                  "topTokens": null,
                  "textRange": {
                    "start": 27,
                    "end": 28
                  }
                }
              ]
            },
            "completions": [
              {
                "data": {
                  "text": """
The meaning of life is a question that has puzzled philosophers, theologians, and scientists for centuries. Some people believe that the meaning of life is to seek happiness, fulfillment, and personal growth, while others believe that it is to serve a higher power or to achieve a specific purpose. Ultimately, the meaning of life is a subjective concept that may vary from person to person.""",
                  "tokens": [
                    {
                      "generatedToken": {
                        "token": "<|newline|>",
                        "logprob": -0.00011097769311163574,
                        "raw_logprob": -0.005315219517797232
                      },
                      "topTokens": null,
                      "textRange": {
                        "start": 0,
                        "end": 1
                      }
                    },
                    {
                      "generatedToken": {
                        "token": "▁The▁meaning▁of",
                        "logprob": -0.012226632796227932,
                        "raw_logprob": -0.1309107095003128
                      },
                      "topTokens": null,
                      "textRange": {
                        "start": 1,
                        "end": 15
                      }
                    },
                    {
                      "generatedToken": {
                        "token": "▁life▁is",
                        "logprob": -0.6495042443275452,
                        "raw_logprob": -0.6625908613204956
                      },
                      "topTokens": null,
                      "textRange": {
                        "start": 15,
                        "end": 23
                      }
                    }
                  ]
                },
                "finishReason": {
                  "reason": "endoftext"
                }
              }
            ]
          }
        }
      ],
      "status_code": 200
    }
  ]
}
```

Don't be alarmed by the verbosity of this output. The first thing you should know about this JSON payload is that the actual response from Amazon Bedrock is contained in the field `inference_results[0].output[0].dataAsMap`. Anything before this is a structure that OpenSearch will include as its default response schema. Secondly, the response sent by AI21 Labs Jurassic 2 for the question `What is the meaning of life?` is in the field `completions[0].data.text`.

The complexity of the responses sent by foundation models is something that ML developers—while creating connector blueprints—should be concerned about. As it should be of their interest to create simple and better experiences for their users. To illustrate what could be done for this case, let's see how to update the existing connector blueprint to make the remote model generate a simpler and less verbose response.

## Processing the response generated by the model

To improve the response generated by the model, you need to update the connector blueprint configuration used by the model. Given that you know the ID of the connector, updating its configuration is fairly simple, as long as:

1. Your OpenSearch cluster is configured to allow changes in the connectors.
2. The model using the connector blueprint is under the `UNDEPLOYED` state.

Regarding the first requirement, you have already configured your OpenSearch cluster to allow connector changes, so you don't need to worry about. However, keep in mind that if you ever have to work with an OpenSearch cluster not managed by you, you may need to verify this requirement first.

The second requirement is what right now you need to do something about. Since the model has been deployed, you can't change the connector blueprint. Any attempt to change the connector blueprint while the model is deployed will generate the following JSON output:

```json
{
  "error": {
    "root_cause": [
      {
        "type": "m_l_validation_exception",
        "reason": "1 models are still using this connector, please undeploy the models first: [xiDN1YsBhjmsqc9X8vet]"
      }
    ],
    "type": "m_l_validation_exception",
    "reason": "1 models are still using this connector, please undeploy the models first: [xiDN1YsBhjmsqc9X8vet]"
  },
  "status": 500
}
```

To undeploy the mode, run the following command:

```bash
POST /_plugins/_ml/models/xiDN1YsBhjmsqc9X8vet/_undeploy
```

Now you can update the connector blueprint configuration. What you are going to do is provide a way for the connector to process the response sent by the AI21 Labs Jurassic 2 foundation model. This can be achieved with [custom pre-and-post processing functions](https://opensearch.org/docs/latest/ml-commons-plugin/extensibility/blueprints/#custom-pre--and-post-processing-functions). To illustrate how this works, run the following command:

```json
PUT /_plugins/_ml/connectors/wyB41YsBhjmsqc9X5_fW
{
    "name": "Amazon Bedrock",
    "description": "Connector for Amazon Bedrock (AI21 Labs)",
    "version": 1,
    "protocol": "aws_sigv4",
    "credential": {
        "access_key": "AKIA6D4DPHVYDOGWCNUT",
        "secret_key": "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"
    },
    "parameters": {
        "region": "us-east-1",
        "service_name": "bedrock",
        "model_name": "ai21.j2-mid-v1"
    },
    "actions": [
        {
            "action_type": "predict",
            "method": "POST",
            "headers": {
                "content-type": "application/json"
            },
            "url": "https://bedrock-runtime.${parameters.region}.amazonaws.com/model/${parameters.model_name}/invoke",
            "request_body": "{\"prompt\":\"${parameters.inputs}\",\"maxTokens\":200,\"temperature\":0.7,\"topP\":1,\"stopSequences\":[],\"countPenalty\":{\"scale\":0},\"presencePenalty\":{\"scale\":0},\"frequencyPenalty\":{\"scale\":0}}",
            "post_process_function": "\n  return params['completions'][0].data.text; \n"
        }
    ]
}
```

You should see a JSON payload with the following content:

```json
{
  "_index": ".plugins-ml-connector",
  "_id": "wyB41YsBhjmsqc9X5_fW",
  "_version": 2,
  "result": "updated",
  "_shards": {
    "total": 1,
    "successful": 1,
    "failed": 0
  },
  "_seq_no": 1,
  "_primary_term": 1
}
```

This means that the connector blueprint was updated successfully. Note that within the connector blueprint configuration it was added a new field called `post_process_function`. You can use this field to provide to the configuration a way for you to process the response coming from the remote model. In this new version of the connector blueprint, you have used the [Painless script](https://opensearch.org/docs/latest/api-reference/script-apis/index/) expression `return params['completions'][0].data.text;` to return to the user, the value contained in the JSON Path specified.

With the connector blueprint properly updated, you can re-deploy the model. To deploy the model, run this command again:

```bash
POST /_plugins/_ml/models/xiDN1YsBhjmsqc9X8vet/_deploy
```

Now, go ahead and ask the model again about the meaning of life.

```json
POST /_plugins/_ml/models/xiDN1YsBhjmsqc9X8vet/_predict
{
  "parameters": {
    "inputs": "What is the meaning of life?"
  }
}
```

Once the execution of the inference completes, you will receive a simpler and straightforward response this time:

```json
{
  "inference_results": [
    {
      "output": [
        {
          "name": "response",
          "dataAsMap": {
            "response": """
The meaning of life is a question that has puzzled philosophers and theologians for centuries. Many people believe that the meaning of life is to seek happiness and fulfillment in their relationships, careers, and hobbies. Others believe that the meaning of life is to serve a higher power or to achieve a specific purpose or goal. Ultimately, the meaning of life is a subjective concept that may differ from person to person."""
          }
        }
      ],
      "status_code": 200
    }
  ]
}
```

Very cool, right? Just keep in mind that using pre-and-post processing functions creates a tight coupling between your connector and the API contract used by the remote model. Whenever that API contract changes because the endpoint schema is updated, you will need to update your connector blueprint accordingly.

## Automating steps

By now, you have successfully finished this interactive tutorial and had the opportunity to explore the remote model feature. Throughout the tutorial, you may have observed that the majority of the steps involved executing a series of commands against the OpenSearch cluster. However, this repetitive and manual process can be both tedious and prone to errors. Fortunately, there is a solution. OpenSearch offers RESTful APIs for almost every aspect, allowing you to automate the execution of the following steps programmatically.

![automating steps](images/automating_steps.png)

The tutorial's accompanying GitHub repository includes a [Python code example](https://github.com/build-on-aws/getting-started-with-opensearch-remote-models/blob/main/deploy-remote-model.py) that automates all of these steps for you. To make the code work, you simply need to provide the OpenSearch cluster's endpoint and the AWS credentials that will be utilized to configure the connector. This may be useful when you need to implement new versions of the model whenever updates are made to the connector blueprint specification.

## Summary

In this part of the series, you have learned with a hands-on example how to configure, deploy, and test a remote model based on Amazon Bedrock. You have learned the details to prepare an OpenSearch cluster to use this feature, the steps to configure and update connector blueprints, as well as how to verify the steps along the way. Hopefully, this hands-on experience may have got you excited to try things by yourself. For more examples connecting to remote models hosted on Amazon SageMaker, Amazon Bedrock, and others, see the connector blueprints examples in the [ML Commons repository.](https://github.com/opensearch-project/ml-commons/tree/main/docs/remote_inference_blueprints)

There is one more scenario that I think you should consider. What if you would like to build your own remote model with your dedicated infrastructure? Here, you have learned how to use a known service, such as Amazon Bedrock. But what if you want to integrate your own ML APIs with OpenSearch?

In the [third part](../03-authoring-custom-connectors-opensearch/index.md), you will learn how to use a custom ML API as a remote model. You will learn how to use this remote model in scenarios beyond running inferences, such as integrating the remote model with neural searches. And you will have the chance to practice all of this using an [Amazon OpenSearch](https://docs.aws.amazon.com/opensearch-service/latest/developerguide/gsg.html) domain running on AWS.
