---
title: "Troubleshooting the ML Commons Plugin"
description: "Learn the tips and tricks about how to troubleshoot the ML Commons Plugin, which is the engine behind the remote models feature."
tags:
  - opensearch
  - ai-ml
  - gen-ai
  - sagemaker
  - bedrock
  - aws
waves:
  - generative-ai
images:
  banner: images/tutorial_banner.png
  thumbnail: images/amazon_opensearch.png
  hero: images/turorial_banner.png
  background: images/turorial_banner.png
authorGithubAlias: riferrei
authorName: Ricardo Ferreira
date: 2023-11-27
---

| ToC |
| --- |

In this series, you have been exploring the remote models feature of OpenSearch. By now, we hope you are aware of its capabilities and are enthusiastic about the incredible possibilities it offers for building. However, it is unrealistic to assume that everything will be perfect. You need to know how to troubleshoot problems that may arise when things don't go as planned.

Here, you will learn a few things about the ML Commons plugin that will help you feel comfortable enough to troubleshoot issues on your own. We hope you won't have to—but as Thor said in the [Thor Ragnarok](https://www.imdb.com/title/tt3501632/) movie: "A wise king never seeks out war. But he must always be ready for it."

## ML Commons plugin must-know settings

If there is one pattern about the adoption of any modern software technology is the fact the most users struggle with problems related to the default values of important settings. Not knowing who they are, not knowing what are their default values, and what is their impact when deploying applications is a source of many problems. With the ML Commons plugin is no different.

You should spend some time knowing what are the settings available in the ML Commons plugin and what are their default values. To query about all the settings from this plugin and retrieve their default values, you can use the following command:

```bash
GET _cluster/settings?include_defaults=true&filter_path=defaults.plugins.ml_commons
```

You should see the following output:

```json
{
  "defaults": {
    "plugins": {
      "ml_commons": {
        "monitoring_request_count": "100",
        "allow_custom_deployment_plan": "false",
        "sync_up_job_interval_in_seconds": "10",
        "ml_task_timeout_in_seconds": "600",
        "task_dispatcher": {
          "eligible_node_role": {
            "local_model": [
              "data",
              "ml"
            ],
            "remote_model": [
              "data",
              "ml"
            ]
          }
        },
        "trusted_url_regex": "^(https?|ftp|file)://[-a-zA-Z0-9+&@#/%?=~_|!:,.;]*[-a-zA-Z0-9+&@#/%=~_|]",
        "rag_pipeline_feature_enabled": "false",
        "task_dispatch_policy": "round_robin",
        "max_ml_task_per_node": "10",
        "exclude_nodes": {
          "_name": ""
        },
        "model_access_control_enabled": "false",
        "native_memory_threshold": "90",
        "model_auto_redeploy": {
          "lifetime_retry_times": "3",
          "enable": "false"
        },
        "jvm_heap_memory_threshold": "85",
        "memory_feature_enabled": "false",
        "only_run_on_ml_node": "true",
        "max_register_model_tasks_per_node": "10",
        "allow_registering_model_via_local_file": "false",
        "update_connector": {
          "enabled": "false"
        },
        "max_model_on_node": "10",
        "trusted_connector_endpoints_regex": [
          """^https://runtime\.sagemaker\..*[a-z0-9-]\.amazonaws\.com/.*$""",
          """^https://api\.openai\.com/.*$""",
          """^https://api\.cohere\.ai/.*$""",
          """^https://bedrock-runtime\..*[a-z0-9-]\.amazonaws\.com/.*$"""
        ],
        "remote_inference": {
          "enabled": "true"
        },
        "connector_access_control_enabled": "false",
        "enable_inhouse_python_model": "false",
        "max_deploy_model_tasks_per_node": "10",
        "allow_registering_model_via_url": "false"
      }
    }
  }
}
```

As you may have noticed; there is a fair amount of settings being used by the ML Commons plugin. Some of them are self-explanatory and I won't go over in detailing all of them. Instead, below, I summarize the top five settings you may want to know in more details.

1. **plugins.ml_commons.only_run_on_ml_node**: this setting dictates whether inferences can be executed in any node or just the ones labeled as ML-enabled. Since it defaults to `true`, it will instruct OpenSearch to run ML tasks in nodes labeled as such, which may be the cause of you not seeing any activity in a cluster that has no ML-nodes in it. Moreover, even if you have some ML-nodes, you may see that your cluster becomes quickly unstable with tasks taking longer to complete, as only a few nodes are doing the job.

2. **plugins.ml_commons.model_access_control_enabled**: models deployed at OpenSearch can be fully controlled with granular roles that you can tie to them. This setting enables that behavior, as opposed to allow anyone to use modes anytime they want. If perhaps you are working with a cluster with this setting enabled, you may know to review if someone didn't associate a role to the model, which may explain why you are getting access errors every time you try to deploy or running predictions with the model.

3. **plugins.ml_commons.native_memory_threshold**: this setting sets an upper bound limit about how much tolerance for the RAM memory (also known as native memory) until it stops allowing tasks to execute. It defaults to 90, which means that if the RAM memory is over 90% of utilization, tasks will stop being executed. For a really busy OpenSearch cluster that also has to serve search requests, this may be something you want to watch out. Similarly, the setting `plugins.ml_commons.jvm_heap_memory_threshold` sets an upper bound limit to the JVM heap memory. Also, remember that the JVM heap may reach this threshold very frequently during peak times. After the garbage collection, the heap memory may shrink back, but it may fill up pretty quickly, causing you to see tasks uncompleted frequently.

4. **plugins.ml_commons.model_auto_redeploy.enable:** As you may have learned at this point, every time you deploy a model, this is executed by a task in the OpenSearch cluster. At any time, the nodes responsible for executing these tasks can fail, and by default, there is no "do it again" according to this setting. Setting this to `true` tells OpenSearch to attempt a redeploy if a model is found not deployed or partially deployed. This may explain why, even after bouncing your cluster, the model still doesn't work. When this setting is set to `true`, you can optionally use the property `plugins.ml_commons.model_auto_redeploy.lifetime_retry_times` to specify how many redeploy attempts should happen.

5. **plugins.ml_commons.trusted_connector_endpoints_regex**: this setting controls which endpoints are allowed to be used to handle inference requests. By default, only a small set of endpoints is on the list. If you ever need to use a custom model, you will need to add your endpoints to this list. Failing to do so may be the reason why your models are shown as deployed, but always fail to handle inference requests. It just means your endpoint is not white-listed.

While the settings discussed above have to do with problems related to the plugin behavior and the problems that may rise for you not knowing them; the `plugins.ml_commons.max_ml_task_per_node` setting is a bit more tricky, as it has to do with resource utilization. Problems related to resource utilization only rise under certain load conditions, thus they are harder to identify and troubleshoot. In a nutshell, this setting controls how many tasks ML-nodes are allowed to execute. For small workloads where there are not a bunch of concurrent tasks being executed, this won't be a problem. However, think about scenarios where you have fewer ML-nodes and they are responsible for handling a considerable amount of tasks.

It may hit the limit imposed by the default value, which is `10`. If you need to scale up more tasks per node, you can increase the value of this setting to something higher. However, there is another trick that you must be aware of. Tasks are executed as threads, and these threads are taken from a pool. Even if you increase the number of tasks that a ML-node can handle, you must ensure the thread pool for specific tasks is large enough to afford the amount of concurrency needed. To query about the thread pools used by the ML Commons plugin, you can use the following command:

```bash
GET _cluster/settings?include_defaults=true&filter_path=defaults.thread_pool.ml_commons
```

You should see the following output:

```json
{
  "defaults": {
    "thread_pool": {
      "ml_commons": {
        "opensearch_ml_deploy": {
          "queue_size": "10",
          "size": "9"
        },
        "opensearch_ml_execute": {
          "queue_size": "10",
          "size": "9"
        },
        "opensearch_ml_register": {
          "queue_size": "10",
          "size": "9"
        },
        "opensearch_ml_train": {
          "queue_size": "10",
          "size": "9"
        },
        "opensearch_ml_predict": {
          "queue_size": "10000",
          "size": "20"
        },
        "opensearch_ml_general": {
          "queue_size": "100",
          "size": "9"
        }
      }
    }
  }
}
```

Make sure to adjust the `size` if needed.

## Profiling your deployed models

In some cases, users may express their dissatisfaction with certain aspects of the application, specifically its rather slow performance. Upon troubleshooting, it has been found that one possible reason for this sluggishness could be the calls made to remote models. A fascinating approach to initiate this investigation is by utilizing the [Profile API](https://opensearch.org/docs/latest/ml-commons-plugin/api/profile/) provided by the ML Commons plugin.

To use the Profile API to investigate the performance of your models, use the following command:

```bash
GET /_plugins/_ml/profile/models
```

You should see an output similar to this:

```json
{
  "nodes": {
    "QIpgbLWFSwyTFtWz5j-OvA": {
      "models": {
        "s_kvA4wBfndRacpb8I1Y": {
          "model_state": "DEPLOYED",
          "predictor": "org.opensearch.ml.engine.algorithms.remote.RemoteModel@687c2ebe",
          "target_worker_nodes": [
            "QIpgbLWFSwyTFtWz5j-OvA"
          ],
          "worker_nodes": [
            "QIpgbLWFSwyTFtWz5j-OvA"
          ],
          "model_inference_stats": {
            "count": 8,
            "max": 2322.292209,
            "min": 469.437416,
            "average": 1250.456260875,
            "p50": 1197.6908130000002,
            "p90": 1667.658159,
            "p99": 2256.828804
          },
          "predict_request_stats": {
            "count": 8,
            "max": 2324.38096,
            "min": 471.412834,
            "average": 1252.4851045,
            "p50": 1199.588,
            "p90": 1669.7088755,
            "p99": 2258.9137515499997
          }
        }
      }
    }
  }
}
```

Note the hierarchical structure of this output. The analysis is broken down on a per-node basis, followed by a per-model basis. Then, for each model, there are two groups: `model_inference_stats` and `predict_request_stats`. The former deals with the actual inferences executed by the remote model, whereas the latter deals with the predictions made to the model. Your troubleshooting exercise should consider the computed values of the metrics for each group, given the amount of requests displayed in the field `count`. It should give a nice idea if the remote models are indeed the culprit.

You may note a possible discrepancy in the value reported by the field `count` and the actual number of requests executed. This may happen because the Profile API monitors the last `100` requests. To change the number of monitoring requests, update the following cluster setting:

```json
PUT _cluster/settings
{
  "persistent" : {
    "plugins.ml_commons.monitoring_request_count" : 1000000 
  }
}
```

## Profiling your search requests

Searching with OpenSearch presents a greater level of complexity compared to querying a relational database. The reason behind this lies in OpenSearch's scalable [shared-nothing architecture](https://en.wikipedia.org/wiki/Shared-nothing_architecture), which distributes documents across various shards. Consequently, when initiating a search request in OpenSearch, the execution process becomes more intricate since one remains unaware of which documents will align with the query and their respective storage locations. This is the reason OpenSearch applies the **query-then-fetch** approach. In a nutshell, here is how it works.

During the initial query phase, the query is distributed to each shard in the index. Every shard then performs the search and generates a queue of matching documents. This query phase helps identify the documents that meet the search criteria. However, we still need to retrieve the actual documents themselves, which is done in the fetch phase. In this phase, the coordinating node determines which documents need to be fetched. These documents may originate from one or multiple shards involved in the original search. The coordinating node sends a request to the relevant shard copy, which then loads the document bodies into the `_source` field. Additionally, if requested, it can also include metadata and search snippet highlighting. Once the coordinating node has gathered all the results, it collects them into a unified response to be sent back to the client.

Executing search requests in OpenSearch can be complicated. It is a complex distributed system, and various parts can fail, become slow, and lead to poor performance. This means you need to have something in your pocket to when issues related to performance occur, and if you integrate remote models with search requests, this can surely occur. For instance, in the part [three](https://quip-amazon.com/fWqGAExYGBoX/Part-3-Authoring-Custom-Connectors-for-OpenSearch) of this series, you saw that you can leverage remote models in conjunction with neural requests to create really amazing content experiences out of your data. If you ever find yourself in a situation where you are suspecting that remote models may be slowing down your searches, you can leverage the [Profile API](https://opensearch.org/docs/latest/api-reference/profile/) to troubleshoot your search requests.

Getting started with the Profile API is quite simple: just add the sentence `"profile": true` to your search body request. For example:

```json
GET /nlp_pqa_2/_search
{
  "profile": true,
  "_source": [ "question" ],
  "size": 30,
  "query": {
    "neural": {
      "question_vector": {
        "query_text": "What is the meaning of life?",
        "model_id": "-OnayIsBvAWGexYmHu8G",
        "k": 30
      }
    }
  }
}
```

You should receive an output similar to this:

```json
{
  "took": 774,
  "timed_out": false,
  "_shards": {
    "total": 5,
    "successful": 5,
    "skipped": 0,
    "failed": 0
  },
  "hits": {
    "total": {
      "value": 4,
      "relation": "eq"
    },
    "max_score": 1,
    "hits": [
      {
        "_index": "nlp_pqa_2",
        "_id": "1",
        "_score": 1,
        "_source": {
          "question": "What is the meaning of life?"
        }
      },
      {
        "_index": "nlp_pqa_2",
        "_id": "3",
        "_score": 0.3856697,
        "_source": {
          "question": "How many legs does an Elephant have?"
        }
      },
      {
        "_index": "nlp_pqa_2",
        "_id": "4",
        "_score": 0.38426778,
        "_source": {
          "question": "How many legs does a Giraffe have?"
        }
      },
      {
        "_index": "nlp_pqa_2",
        "_id": "2",
        "_score": 0.34972358,
        "_source": {
          "question": "Does this work with xbox?"
        }
      }
    ]
  },
  "profile": {
    "shards": [
      {
        "id": "[3mWnAgBCTvO_NM_zp2p_pg][nlp_pqa_2][2]",
        "inbound_network_time_in_millis": 0,
        "outbound_network_time_in_millis": 0,
        "searches": [
          {
            "query": [
              {
                "type": "KNNQuery",
                "description": "",
                "time_in_nanos": 10847,
                "breakdown": {
                  "set_min_competitive_score_count": 0,
                  "match_count": 0,
                  "shallow_advance_count": 0,
                  "set_min_competitive_score": 0,
                  "next_doc": 0,
                  "match": 0,
                  "next_doc_count": 0,
                  "score_count": 0,
                  "compute_max_score_count": 0,
                  "compute_max_score": 0,
                  "advance": 0,
                  "advance_count": 0,
                  "score": 0,
                  "build_scorer_count": 0,
                  "create_weight": 10847,
                  "shallow_advance": 0,
                  "create_weight_count": 1,
                  "build_scorer": 0
                }
              }
            ],
            "rewrite_time": 6965,
            "collector": [
              {
                "name": "SimpleTopScoreDocCollector",
                "reason": "search_top_hits",
                "time_in_nanos": 6605
              }
            ]
          }
        ],
        "aggregations": []
      },
      {
        "id": "[3mWnAgBCTvO_NM_zp2p_pg][nlp_pqa_2][3]",
        "inbound_network_time_in_millis": 0,
        "outbound_network_time_in_millis": 0,
        "searches": [
          {
            "query": [
              {
                "type": "KNNQuery",
                "description": "",
                "time_in_nanos": 79843642,
                "breakdown": {
                  "set_min_competitive_score_count": 0,
                  "match_count": 0,
                  "shallow_advance_count": 0,
                  "set_min_competitive_score": 0,
                  "next_doc": 615,
                  "match": 0,
                  "next_doc_count": 1,
                  "score_count": 1,
                  "compute_max_score_count": 0,
                  "compute_max_score": 0,
                  "advance": 1822,
                  "advance_count": 1,
                  "score": 4185,
                  "build_scorer_count": 2,
                  "create_weight": 10888,
                  "shallow_advance": 0,
                  "create_weight_count": 1,
                  "build_scorer": 79826132
                }
              }
            ],
            "rewrite_time": 2486,
            "collector": [
              {
                "name": "SimpleTopScoreDocCollector",
                "reason": "search_top_hits",
                "time_in_nanos": 40952
              }
            ]
          }
        ],
        "aggregations": []
      },
      {
        "id": "[3mWnAgBCTvO_NM_zp2p_pg][nlp_pqa_2][4]",
        "inbound_network_time_in_millis": 0,
        "outbound_network_time_in_millis": 0,
        "searches": [
          {
            "query": [
              {
                "type": "KNNQuery",
                "description": "",
                "time_in_nanos": 81504014,
                "breakdown": {
                  "set_min_competitive_score_count": 0,
                  "match_count": 0,
                  "shallow_advance_count": 0,
                  "set_min_competitive_score": 0,
                  "next_doc": 1321,
                  "match": 0,
                  "next_doc_count": 1,
                  "score_count": 1,
                  "compute_max_score_count": 0,
                  "compute_max_score": 0,
                  "advance": 435,
                  "advance_count": 1,
                  "score": 16599,
                  "build_scorer_count": 2,
                  "create_weight": 76898,
                  "shallow_advance": 0,
                  "create_weight_count": 1,
                  "build_scorer": 81408761
                }
              }
            ],
            "rewrite_time": 3020,
            "collector": [
              {
                "name": "SimpleTopScoreDocCollector",
                "reason": "search_top_hits",
                "time_in_nanos": 45490
              }
            ]
          }
        ],
        "aggregations": []
      },
      {
        "id": "[BP2uaV4iScmS_zRntM65AQ][nlp_pqa_2][0]",
        "inbound_network_time_in_millis": 1,
        "outbound_network_time_in_millis": 2,
        "searches": [
          {
            "query": [
              {
                "type": "KNNQuery",
                "description": "",
                "time_in_nanos": 102327857,
                "breakdown": {
                  "set_min_competitive_score_count": 0,
                  "match_count": 0,
                  "shallow_advance_count": 0,
                  "set_min_competitive_score": 0,
                  "next_doc": 509,
                  "match": 0,
                  "next_doc_count": 1,
                  "score_count": 1,
                  "compute_max_score_count": 0,
                  "compute_max_score": 0,
                  "advance": 903,
                  "advance_count": 1,
                  "score": 2298,
                  "build_scorer_count": 2,
                  "create_weight": 57221,
                  "shallow_advance": 0,
                  "create_weight_count": 1,
                  "build_scorer": 102266926
                }
              }
            ],
            "rewrite_time": 8032,
            "collector": [
              {
                "name": "SimpleTopScoreDocCollector",
                "reason": "search_top_hits",
                "time_in_nanos": 26020
              }
            ]
          }
        ],
        "aggregations": []
      },
      {
        "id": "[BP2uaV4iScmS_zRntM65AQ][nlp_pqa_2][1]",
        "inbound_network_time_in_millis": 1,
        "outbound_network_time_in_millis": 5,
        "searches": [
          {
            "query": [
              {
                "type": "KNNQuery",
                "description": "",
                "time_in_nanos": 99278876,
                "breakdown": {
                  "set_min_competitive_score_count": 0,
                  "match_count": 0,
                  "shallow_advance_count": 0,
                  "set_min_competitive_score": 0,
                  "next_doc": 1305,
                  "match": 0,
                  "next_doc_count": 1,
                  "score_count": 1,
                  "compute_max_score_count": 0,
                  "compute_max_score": 0,
                  "advance": 1920,
                  "advance_count": 1,
                  "score": 17296,
                  "build_scorer_count": 2,
                  "create_weight": 57394,
                  "shallow_advance": 0,
                  "create_weight_count": 1,
                  "build_scorer": 99200961
                }
              }
            ],
            "rewrite_time": 7244,
            "collector": [
              {
                "name": "SimpleTopScoreDocCollector",
                "reason": "search_top_hits",
                "time_in_nanos": 53085
              }
            ]
          }
        ],
        "aggregations": []
      }
    ]
  }
}
```

Note how the response was returned with an additional field called `profile` containing some interesting data about the execution of individual components of the search request. Analyzing this data allows you to debug slower requests and understand how to improve their performance. The trick here is to cross reference the time taken by the remote models and the time spent in the actual search execution. The time taken by the remote model can be measured with the profile approach from the previous section.

## Not working or not available to you?

There is one troubleshooting technique that must be your first instinct when dealing with problems reported by developers using OpenSearch. Always check the HTTP code returned. As you may know, everything OpenSearch does it provided for developers via REST APIs. For this reason, there will be always an HTTP code for you to check. This is important because depending of the HTTP code returned—you may save hours of troubleshooting just by figuring out that an error may not necessarily be an error.

A good example of this may be situations where a request may look like as failed but in reality; the request was sent from a user that has no permissions for that request. For those requests, if you receive an `401` or `403` HTTP codes—this means that the request is as successful until the point where the user credentials were verified and the user permissions were put in check. This is actually good news since you won't have to investigate the said error. You just need to investigate if the resource being used should or should not be given to the user.

For instance, consider the support provided by the ML Commons plugin to [model access control](https://opensearch.org/docs/latest/ml-commons-plugin/model-access-control/). This may explain why every time a user tries to register a model or deploy it is failing. It may be the case of the model is trying to use a model group whose access model is restricted, or one that is intentionally not visible to you. This may happen because an model group can be created with restricted access to certain users, using organizational conventions called `backend_roles` that prohibit certain users to access it. To illustrate this, see the group `model_group_test` below.

```json
POST /_plugins/_ml/model_groups/_register
{
    "name": "model_group_test",
    "description": "This is an example description",
    "access_mode": "restricted",
    "backend_roles" : ["data_scientists", "administrators"]
}
```

Here, any developer who tries deploying a model belonging to the group model `model_group_test` and not part of the roles `data_scientists` and `admins` won't be able to complete the deployment request successfully.

## Summary

The remote models feature opens up the window to exciting use cases where data can be magnified by the power of ML models and Generative AI. Tied with the simplicity of OpenSearch, you can enable your teams to create cutting-edge applications with very low effort.

I hope you have enjoyed reading this series and please make sure to share this content within your social media circle so others could benefit from the same. If you want to discover more about the amazing world of Generative AI, take a look at [this space](https://community.aws/generative-ai) and don't forget to subscribe to the [AWS Developers YouTube channel](https://www.youtube.com/@awsdevelopers). I'm sure you will be amazed by the new content to come. Finally, [follow me on LinkedIn](https://linkedin.com/in/riferrei) if you want to geek out about technologies in general.


See you, next time!
