---
title: "Exploration and Practice of Serverless Architecture Evolution in Microservices"
description: Using the example of migrating the FreeWhee application, this article provides a practical guide for incrementally transitioning a microservices architecture to serverless on AWS, covering architectural analysis, serverless implementation, dependency management, cost optimization, and monitoring.
tags:
  - tutorials
  - aws
  - Serverless
  - microservices
  - lambda
  - API Gateway
authorGithubAlias: betty714,  lyplb, malphi
authorName: Betty Zheng, Ying Li, malphi
date: 2023-11-09
---


| Attributes             |                                                                 |
|------------------------|-----------------------------------------------------------------|
| ✅ AWS experience      | 300 - Advanced                                              |
| ⏱ Time to complete     | 20 minutes to complete                                                      |
| 💰 Cost to complete    | Free tier eligible                                               |
| 🧩 Prerequisites    | [AWS Lambda](https://aws.amazon.com/lambda/?nc2=h_ql_prod_cp_lbd) |
| 📢 Feedback            | <a href="https://pulse.buildon.aws/survey/DEM0H5VW" target="_blank">Any feedback, issues, or just a</a> 👍 / 👎 ?    |
| ⏰ Last Updated     | 2023-11-09 <as mentioned above>                             |


## Introduce
In today's technology landscape, numerous organizations have shifted their approach from building a single monolithic application to adopting a microservices architecture. This architectural style involves breaking down services into multiple smaller applications that can be developed, designed, and operated independently. These smaller applications collaborate and communicate with each other to deliver a comprehensive service to users. Furthermore, leveraging serverless architectures and serverless computing in the design and deployment of these applications effectively addresses challenges such as high complexity, excessive inter-module dependencies, and limited system scalability typically associated with microservices architecture.

This article will use the AD Debug Service from [Freewheel company](https://www.freewheel.com/) as an example to illustrate the process of transitioning from an existing microservices architecture to a Serverless architecture. The AD Debug Service serves as a tool provided by Freewheel, enabling users to diagnose and gain a comprehensive understanding of the ad server decisions made by Freewheel.

## Background
### Overview of Service Architecture
Freewheel's core business team abandoned the initial approach of building a single, massive monolithic application, instead adopting a microservice architecture, as depicted in the diagram below.

![overview of service architecture](./images/1-overall%20service%20architecture.png)

### Overview of the Service to be Migrated
The Freewheel AD Debug Service utilizes the gRPC framework to develop gRPC APIs, and it also exposes RESTful APIs externally through gRPC-Gateway. The workflow of the AD Debug Service can be summarized as follows, as depicted in the figure below. To facilitate a better understanding of the subsequent migration steps, let's examine the workflow of the AD Debug Service in detail:
1. When a diagnostic request reaches the gRPC-Gateway of the AD Debug Service, it parses the JSON data into Protobuf messages
2. The gRPC-Gateway uses the parsed Protobuf message to make a normal gRPC client request;
3. The gRPC client sends the Protobuf in binary format to the gRPC server
4. The gRPC server handles the request, where the actual business code is executed, and it invokes other microservices (including calling Freewheel's AD Debug Service and obtaining ad decision results) through gRPC or HTTP
5. The gRPC server returns the response in Protobuf binary format to the gRPC client, which parses it into a Protobuf message and returns it to the gRPC-Gateway
6. Finally, the gRPC-Gateway encodes the Protobuf message as JSON and returns it to the original client.

![Service workflow ](./images/2-migration.png)
[resources ](https://grpc.io/blog/coreos/)

From the workflow diagram above, we can see that the AD Debug Service is different from other microservice in that only its RESTful API gets accessed, while its gRPC API is only used to handle HTTP requests. This shows that migrating the AD Debug Service will not affect other gRPC microservice.

## Why Migrating to Serverless
### Problems with Existing microservice
- Coarse Scaling Granularity: The different interfaces of each sub-business in microservices have large differences in QPS and completely different scaling demands. Their upgrade frequencies can also be very different. If we further split the services, the number of microservices will increase by an order of magnitude, which will further increase the infrastructure management burden. 
- High Cost: Each microservice needs to consider redundancy to ensure high availability. As the number of microservice increases, the infrastructure will grow exponentially, but the charging model of cloud services remains unchanged - still charging by resource size and hourly usage. The microservice infrastructure based on containers still has deficiencies in elasticity.
  
### Advantages of Serverless
The server-side application logic implemented by developers (microservice or even smaller services) runs in a stateless, ephemeral container in an event-driven manner. These containers and computing resources are fully managed by the cloud provider, so developers only need to care about and maintain the normal business operations. Other aspects like runtime, containers, operating system, hardware, etc. are handled by the cloud provider. In general, Serverless has the following advantages:
- No Operations: No need to manage server hosts or server processes; monitoring to ensure the service is still running well; automatic system upgrades, including security patches.
- Elastic Scaling: The cloud platform handles load balancing and request routing to efficiently utilize resources, and it automatically scales and configures based on load.
- Pay-per-use: Costs are determined based on actual usage.
- High Availability: Availability redundancy so that a single machine failure does not cause service interruption; implicit high availability.
  
### Why Migrating AD Debug Service
- Use-and-Go: AD Debug Service is a typical use-and-discard business scenario. Its main work is interacting with AD Decision Service to acquire ad serving decision information, and invoking multiple other microservice to obtain relevant business data, compose all the information and return to the frontend customer for display. 
- Query per Month <100K: It receives less than 100,000 requests per month
- Response Duration: Clients do not have high requirements for request response duration, within 60s is acceptable.
- No gRPC Server: No need to provide gRPC service
Therefore, compared to deploying in an EKS Cluster with fixed pod resources, FaaS in Serverless is a more suitable pattern for it.

# Technology Selection
AWS offers a robust and reliable computing infrastructure for Lambda functions, along with streamlined management capabilities. Developers can leverage this infrastructure by organizing their business code into Lambda functions, utilizing the supported runtimes provided by Lambda. In the case of the FreeWheel AD Debug Service, the Go language is utilized. This approach simplifies the development process and allows developers to focus primarily on their business logic while leaving the underlying infrastructure management to AWS.
Currently AWS provides 3 ways to synchronously invoke Lambda:
1. Integration with Lambda using Amazon API Gateway.
2. Integration with Lambda using the Application Load Balancer.
3. Direct use of the Lambda Function URL.
   
## Amazon API Gateway + Lambda
AWS supports the creation of Web APIs with HTTP endpoints for Lambda functions using API Gateway. AWS API Gateway is a fully managed service that helps developers easily create, publish, maintain, monitor, and secure APIs at any scale. With API Gateway, you can construct two types of RESTful APIs: REST APIs and HTTP APIs, and it also supports the creation of WebSocket APIs, enabling clients to connect to applications via HTTP and WebSocket protocols. API Gateway offers advanced features such as authorization and access control, caching, request transformation, and more. The architecture of API Gateway is illustrated in the following diagram:
![Lambda workflow ](./images/lambda%20workflow.png)

## Application Load Balancer + Lambda
Elastic Load Balancing (ELB) supports Lambda functions as targets for Application Load Balancers (ALB). With load balancer rules, HTTP requests are routed to a specific function based on the path or header values. The request is processed, and an HTTP response is returned from the Lambda function.
Setting up the infrastructure requires registering the Lambda function with a Target Group and configuring listener rules in the Application Load Balancer (ALB) to route requests to the Lambda function's Target Group. When the load balancer forwards requests to the Target Group associated with a Lambda function, it triggers the Lambda function and passes the request content in JSON format. This allows the Lambda function to process the request and respond accordingly
Operating at the application layer, the ALB routes HTTP requests to multiple backend resources, including Amazon Lambda functions. ALBs are commonly used to expose a public web endpoint, with its resources hosted within private subnets in an Amazon VPC; they also support private ALBs, which are only accessible from an organization's internal network.
![Load banlancer ](./images/4-ALB%2BLambda.png)

However, using Target Groups comes with certain limitations:
1. The Lambda function and the target group must reside within the same account and the same Region.
2. The maximum size of the request body that can be sent to a Lambda function is 1 MB.
3. The maximum size of the response JSON that a Lambda function can send is 1 MB.
4. WebSocket is not supported.
   
## Lambda Function URL
The Function URL is a dedicated HTTP(S) endpoint for Lambda functions. When a function URL is created, Lambda automatically generates a unique URL endpoint. Once established, this URL endpoint will not change. The function URL supports Cross-Origin Resource Sharing (CORS) configuration options. Additionally, the Function URL can handle responses in two ways: BUFFERED and RESPONSE_STREAM.
- BUFFERED is the default response mode: with this method, the invocation result is only returned upon the completion of the payload, and the response payload is limited to 6 MB.
- The RESPONSE_STREAM method, on the other hand, will stream the response payload back to the client. Streamed response handling can send parts of the response back to the client as soon as they're available. Therefore, we can use the RESPONSE_STREAM method to construct functions that return larger payloads. The soft limit for a response stream payload is 20MB. The bandwidth for the first 6MB of the response has no cap, but the maximum processing rate after exceeding 6MB is 2MBps, and streaming responses will incur additional charges.
  
> **Note**
> Important Considerations for Lambda Function URL Access and Security
> It's crucial to note that the Lambda Function URL is currently accessible only via the public internet, as AWS PrivateLink is not supported as of September 2023. To ensure the security of a Lambda Function URL, there are a couple of options available:
> - AWS_IAM Authorization: One approach is to implement AWS Identity and Access Management (IAM) authorization for the Lambda Function. This allows you to define fine-grained access controls and restrict access to authorized entities only.
> - Resource-Based Policies: Another option is to utilize resource-based policies to enforce safety and access control for the Lambda Function. By configuring these policies, you can define specific permissions and restrictions for different entities interacting with the function.
> By choosing the appropriate authorization mechanism and implementing resource-based policies, you can enhance the security of your Lambda Function URL and ensure that only authorized entities have access to it.

## Comparison of Pros and Cons
Let's briefly compare API gateways, ALBs, and functional URLs in the following ways.

|                                 | API GW                                                       | ALB                                                         | Function URL                                               |
| ------------------------------- | ------------------------------------------------------------ | ----------------------------------------------------------- | ---------------------------------------------------------- |
| Scalable                        | Default 10000 RPS                                            | N/A                                                         | 10 * Lambda's reserved concurrency/sec & Default 10000 RPS |
| Payload Size Limitation         | 10 MB                                                        | 1 MB                                                        | 20 MB                                                      |
| Protocols                       | HTTP/2 (HTTP API, REST API)，WebSockets                     | HTTP/2                                                      | HTTP/2                                                     |
| Router                          | Path/HTTP Method/IP/HTTP Headers. etc.                       | Path/HTTP Method/IP/HTTP Headers etc,and Configurable load ratios | N/A                             |
|  Identity and Access Management | Private & IAM and identity-based polic                       | Private & Support for configuring user authentication by creating authentication actions for listener rules | OpenURL & Authentication and authorization using Amazon IAM and resource-based policies. |
|  Cost                           | Within 3 billion/month: $1.00/million requests & Over3 billion requests/month: $0.90 p/million requests. | 0.0225 USD/hour +（LCU）0.008 USD/hour              | Within 6MB/request: Free & over 6M/request：0.008USD/GB   |
| Monitor & Log                   | CloudTrail / Amazon Config                                   | CloudWatch / CloudTrail / S3 bucket                         | CloudWatch / CloudTrail                                    |


Based on the comparison above, if there are strict payload requirements exceeding 6MB, it is recommended to utilize the RESPONSE_STREAM response mode of the Function URL. However, if private access support is necessary, it is preferable to opt for API Gateway or ALB.
In the case of Freewheel, where stringent security regulations require a unified authentication method for service access, Function URL becomes less desirable. Additionally, considering that the company already has existing instances using ALB, sharing this ALB by simply adding the AD Debug Service's Target Group allows us to avoid time-related costs associated with the ALB itself.
Therefore, for the migration of the AD Debug Service to a Serverless architecture, it has been decided to proceed with the ALB + Lambda approach. This approach leverages the existing ALB infrastructure and provides the necessary private access support, ensuring compliance with security requirements while minimizing additional costs and complexities.

# Code Migration Process
The AD Debug service works as shown in the following diagram: a RESTful request from the client is converted into a gRPC request through the gRPC-Gateway proxy, which then invokes the gRPC client. The client calls the business method and eventually returns a response.
During the migration process, make sure to minimize changes and keep the business logic while replacing the entire section highlighted in blue in the figure below.

![pic5](./images/5-Code%20Migration%20Process.png)
Freewheel already supports the creation of ALB+Lambda through its internal serverless LCDP platform, and this article will demonstrate the whole process through console operation.

![pic6](./images/6-Code%20Migration%20Process2.png)

## Step 1: Create a Lambda Function
1. Open the [Functions page](https://console.aws.amazon.com/lambda/home#/functions) on the Lambda console.
2. Choose "Create function."
3. Select "Author from scratch."
4. Enter the function name: "ad_debug."
5. For Runtime, select `Go 1.x`
6. Under Execution Role, choose "Create a new role with basic Lambda permissions."
After creating an empty Lambda, should to upload and deploy the  package. As mentioned above, the service is based on gRPC, and be keeping the business processing part of the code unchanged. the business processing handler will basically look something like this:

```plain
func (h *BizHandler) BizExec(ctx context.Context, req *proto.BizRequest) (*proto.BizRequestResponse, error) {
   return h.bizDomain.BizExec(ctx, req)
}
```

There are two main areas that need to be addressed now:  how to handle internal routing, and how to manage the conversion between TargetGroup events and proto structures. They specifically related these two aspects to the blue boxes in the diagram above. Similar to a  gRPC-Gateway proxy, we'll create an external Wrapper for each  BizHandler. The responsibilities of this Wrapper include registering the  Handler and transforming the request body.
1. Internal Routing
We utilize the Register method to enlist all the methods' Method, Pattern, and HandleFunc into an array. When a request comes in, we decide which Pattern to invoke by matching the Method and Pattern in the array. The *PathMatchAndParse* function will match the path based on regular expressions, which can be customized according to specific needs; we won't delve into the details here.

```plain
// Register
func (controller *Controller) RegisterEndpoint(method string, pattern string, handleFunc func(ctx context.Context, req *event.ALBTargetGroupRequest) (events.ALBTargetGroupResponse,error)) {
   controller.routes = append(controller.routes, &route{
      pattern:    pattern,
      method:     method,
      handleFunc: handleFunc,
   })
}

// Handle
func (controller *Controller) Handle(ctx context.Context, req *events.ALBTargetGroupRequest) (resp events.ALBTargetGroupResponse, err error) {
   var isMatch = false
   var fn DomainFunc
   for _, route := range controller.routes {
      m, vars, err := PathMatchAndParse(req.Path, route.pattern)
      if err != nil {
         return ResponseInternalServerError()
      }
      if m && req.HTTPMethod == route.method {
         isMatch = true
         fn = route.handleFunc
         break
      }
   }
   if !isMatch {
      return ResponseMethodNotAllowed()
   }
   return fn(ctx, req)
}
```
2. TargetGroup Event to Proto Structures
This part is relatively straightforward and can be directly achieved using the JSONPb from the grpc-gateway package. However, for the process of converting proto structures into JSON to serve as the response body, we can abstract this into a common interceptor:

```plain
var jsonPb = &runtime.JSONPb{}
func Interceptor(ctx context.Context, req *events.ALBTargetGroupRequest, bizHandler func(ctx context.Context, req *events.ALBTargetGroupRequest) (interface{}, error)) (resp events.ALBTargetGroupResponse, err error) {
   res, err := bizHandler(ctx, req)
   if err != nil {
      return
   }
   resBytes, err := jsonPbEmitDefaults.Marshal(res)
   if err != nil {
      return
   }
   resp = events.ALBTargetGroupResponse{
      StatusCode: 200,
      Body:       string(resBytes),
      Headers: map[string]string{
         "Content-Type": "application/json",
      },
   }
   return
}

func BizExec(ctx context.Context, req *events.ALBTargetGroupRequest) (resp interface{}, err error) {
   var adReq proto.BizRequest
   err = jsonPb.Unmarshal([]byte(req.Body), &adReq)
   if err != nil {
      return events.ALBTargetGroupResponse{}, err
   }
   res, err := bizHandler.BizExec(ctx, &adReq)
   if err != nil {
      return events.ALBTargetGroupResponse{}, err
   }
   return bizHandler.BizExec(ctx, &adReq)
}
```
Thus, the final Lambda's main function looks something like this:
```plain
var controller *Controller
func init() {
  controller = NewController()
  
  // Register endpoints
  controller.RegisterEndpoint("POST", "/exec", Interceptor(BizExec))
  controller.RegisterEndpoint(...)
  ...
}

func main() {
   lambda.Start(controller.Handle)
}
```
After completing the body of the Lambda function, we can create a zip package for the Lambda using the following command. Then, select the  previously created Lambda, click on the Code tab, and choose "Upload from .zip file" to deploy it to AWS:

```plain
GOOS=linux GOARCH=amd64 go build -o bin/ad_debug_service main.go
cd bin && zip -r ad_debug_service.zip .
```
## Step 2: Create a Target Group

1. Open the [Amazon EC2 console](https://console.aws.amazon.com/ec2/)
2. In the navigation pane, under LOAD BALANCING, select 'Target Groups'.
3. Click 'Create target group'.
4. For the target type, select 'Lambda function'.
5. In 'Target group name', enter a name for your target group.
6. Click 'Next'.
7. Specify a single Lambda function, which should be the one we created earlier.
8. Click 'Create target group'.
   
## Step 3: Create an ALB and Set Up a Listener

1. Open the [Amazon EC2 console](https://console.aws.amazon.com/ec2/)
2. In the navigation pane, select "Load Balancers"
3. Click "Create Load Balancer" and choose "Application Load Balancer" for the type.
4. For the scheme, select "internal," and ensure the security group (sg) and VPC are consistent with those used for your Lambda function.
5. In the "Listeners" tab, click "Add listener"
6. For the protocol and port, choose "HTTP" and retain the default port.
7. For "Default actions", select "forward" and then pick the target group you created earlier.
8. Click "Add"
## Step 4: Register the ALB with the Gateway
Since the ALB we created is private, to allow external users access, we need to register this ALB's DNS with our outward-facing gateway. This gateway also handles the task of user authentication for us.

# Issues in Code Migration

## Handle Large Payloads

As mentioned above, the AD Debug Service requests information from the AD Decision Service for debugging ad placements, resulting in substantial data returns (typically over 1M). Also, as previously noted, using a Target Group comes with a 1M payload limit. Moreover, we learned that the size of the response body also affects the final cost calculation. So, in dealing with these large payloads (greater than 1M), we discussed several approaches:

### Compression
To reduce the size of the payload, compression is an effective method. For this strategy, we considered compressing payloads from both input and output directions.

#### Compressing the Response Body
The concept of compressing the output is quite common, and our task was to adapt it to the ALB+Lambda model. We continued to use the compression/gzip package that comes with Go, with slight modifications.
Since the Target Group response only supports base64 encoding, we utilized the encoding/base64 package for gzip writing, and it's crucial to set the response body's IsBase64Encoded to true. The compression process can be summarized as:

![pic7](./images/7.png)
We can briefly examine the compression results applied to the AD Debug Service:

| Original Size | Compressed Size | Compression Ratio |
| ------------- | --------------- | ----------------- |
| 419565        | 34640           | 91.74%            |
| 974433        | 155668          | 84.02%            |
| 1052171       | 163136          | 84.50%            |
| 1039205       | 161680          | 84.44%            |
| 3567184       | 483540          | 86.44%            |
| 3262636       | 489972          | 84.98%            |

#### Compression of Request Body
In addition to focusing on the output, we also need to pay attention to the input, i.e., the size of the request body. Especially in AD Debug Service, there are scenarios where files need to be uploaded, so we also applied compression to the request body for file uploads.
On the frontend, we support the uploading of CSV files. So, when uploading a file, we opt to compress the file content. The package used for compression is react-zlib-js. When a file is being uploaded, we create a FileReader to read the file content, then use the gzipSync method from the compression package to gzip-compress the file content, and finally upload the compressed file content to the backend:

```plain
import { gzipSync } from 'react-zlib-js';

const processFileInCompress = (uploadFile File) => {
  const rd = new FileReader();
  rd.readAsBinaryString(uploadFile);
  rd.onload = content => {
    const conRes = content?.target?.result;
    const bf = gzipSync(conRes);
    const gzc = new File([bf], uploadFile.name);
    uploadCompressedFile(gzc);
  };
};
```
On the backend, when we receive the compressed file content, we first need to decompress it. It's important to note that data transmitted via ALB is of the Content-Type *multipart/form-data*, which will be automatically processed with base64 encoding. Therefore, after obtaining the request body, we need to first perform base64 decoding to retrieve the decoded request body, and then proceed with gzip decompression.

### Upload to S3
The method of compression significantly mitigates the 1MB limitation, but it doesn't fundamentally solve the issue. In fact, aside from the compression method mentioned above to address ALB's payload size restrictions, we can also resolve this problem by uploading the request body to S3, having the backend download the request body from S3, as well as uploading the response body to S3, and then having the frontend download the response body from S3.
For instance, in the AD Debug Service, we can upload the AD Decision results, which occupy a significant portion of the response body, to S3. We then return the S3 download link. Afterward, upon receiving the response body, the frontend can download the corresponding content using the S3 link included in the response body.
One important point to note here is the necessity to allow cross-origin access (CORS) for S3. This ensures that the frontend application, hosted on a different domain, can interact with the resources stored in S3 without encountering restrictions imposed by the same-origin policy.

```plain
[
    {
        "AllowedHeaders": [
            "*"
        ],
        "AllowedMethods": [
            "GET"
        ],
        "AllowedOrigins": [
            "*"
        ],
        "ExposeHeaders": []
    }
]
```
## Handle IncomingContext
In the gRPC architecture, the gRPC-gateway proxy uses the *AnnotateContext* method to convert key-value pairs in the request header into metadata in the context, which is then propagated throughout the  various functions of the service. However, ALB does not specially handle request headers, so we need to provide an interceptor in Lambda to  generate a new context based on the request headers.

```plain
func WithIncomingHeaderMatcher(next ALBFunc) ALBFunc {
   return func(ctx context.Context, req events.ALBTargetGroupRequest) (resp events.ALBTargetGroupResponse, err error) {
      m := map[string]string{}
      for k, v := range req.Headers {
         key, t := matcher(k)
         if t {
            m[key] = v
         }
      }
      md := metadata.New(m)
      ctx = metadata.NewIncomingContext(ctx, md)
      return next(ctx, req)
   }
}
```
## Unescape Query String in URL
Similarly, implementing an interceptor to uniformly handle the decoding of query strings in URLs will assist in addressing this requirement. The utilization of the url.QueryUnescape method is necessary for performing decoding operations on the QueryStringParameters within the request.
## Customize Error Response
If we don't process the error from bizHandler, the final error returned in the response body through ALB will be of a plain text type. However, the errors generated in our original model based on grpc-gateway have been processed, meaning the final returned error will also be in JSON format, which is convenient for the frontend to handle. Therefore, to minimize changes and for readability, we can customize the error handling.

```plain
errMsg := fmt.Sprintf("{\"message\": \"%s\"}", err.Error())
return events.ALBTargetGroupResponse{
   StatusCode: 500,
   Headers: map[string]string{
      header.ContentType: "application/json",
   },
   Body: errMsg,
}
```
## Configure Dependency Endpoints
Since we've migrated a microservice that originally belonged to a specific cluster to Lambda, and this service still needs to call other microservice within the original cluster via RESTful methods or gRPC,  we must configure the endpoints of the services being called. Additionally, it's necessary to ensure these microservice can accommodate access from outside the cluster.

# Traffic Migration
After the steps mentioned above, we've successfully migrated the service to AWS Lambda. The next consideration is how to gradually shift traffic to the new Serverless service.
Before actually migrating the traffic, we need to ensure the following components have been successfully transferred.

## Metrics Collection
If the service involves the collection of Prometheus Metrics, and the original gRPC service used a pull method to retrieve metrics values, we must now update to a push method to send metrics to Pushgateway. Then, Prometheus can pulls metrics values from Pushgateway using the pull method.  This change is necessary because Lambda operates on a use-and-terminate model; we cannot ensure that Prometheus can retrieve metrics before Lambda shuts down, so we must adopt an active push update method.
The specific steps for collecting metrics using the push method are as follows:

1. First, we must have our own running Pushgateway, exposing a URL that Lambda can access.
2. Then, in Lambda, we define a pusher from the Prometheus package, using the Pushgateway's URL, a unique name, and the username and password used to access this URL, to initialize this pusher.
3. Initialize a Collector, such as CounterVec.
4. Add the Collector to the pusher.
5. Finally, before Lambda is destroyed, call the pusher.Push() method to push metrics to the gateway.
```plain
var Pusher *push.Pusher
func init() {
   Pusher = push.New(pqmURL, pqmJob).BasicAuth(pqmUser, pqmPasswd).Collector(metricCounter)
}

var metricCounter = prometheus.NewCounterVec(prometheus.CounterOpts{
   Namespace: nameSpace,
   Name:      "metric_name",
   Help:      "Total number of metrics",
},
   []string{"metric_1", "metric_2"},
)

func CollectTotalMetrics(metric1, metric2 string) {
   metricCounter.WithLabelValues(metric1, metric2).Inc()
   if err := Pusher.Push(); err != nil {
      bizlog.Errorf("Push metrics: %v error: %s", metricCounter, err)
   }
}
```
## Logs Collection
The collection of logs can be done directly using AWS's CloudWatch, or it can be done using a custom method. We can use the external extension functionality of Lambda to run the log collection process within an external extension. With the operation of Lambda, the external extension will also start, collecting logs to remote services. As Lambda stops, the external extension will also stop accordingly.

## Traffic Migration

After confirming the above parts, we can start the migration of traffic.  The arrangement of traffic switching must ensure a smooth launch and  controllable risks.

![pic8](./images/8.png)

### Step 1: Dual Writes
First, we need to ensure that all requests return consistent results between the gRPC service and the Serverless service. To achieve this, we need to obtain two sets of response results for the same request. The unique aspect of the AD Debug Service is that responses for the same request may vary at different times. Therefore, we aim to send two requests simultaneously to obtain results from both endpoints as closely as possible to facilitate comparison.
As a result, we have implemented the "dual writes" approach. The client's page still relies on the gRPC version of the AD Debug Service to provide services. However, it simultaneously sends a request to the Serverless side to serve the same request as closely as possible for verification.

### Step 2: Migrate Test Users
Initially, switch all test user traffic to the Serverless service and observe it for a period. This phase helps identify any issues, and if the operation proceeds smoothly, we can proceed to the next stage.

### Step 3: Migrate All Users
Migrate all user traffic to the Serverless service while keeping the gRPC version of the AD Debug Service as a backup. 
During this stage, we implement a new A/B testing strategy. In case of urgent issues, we can switch back to the original service using user parameters controlled by the engineering team.
The entire page defaults to using the Serverless service. However, if someone wants to switch to the original version of the AD Debug Service, they can do so by updating a specific user parameter and then refreshing the page.

### Step 4: Stop the gRPC Version Service

Finally, the gRPC microservice version of the AD Debug Service is taken offline.

# Conclusion

After going through the series of steps outlined above, we successfully migrated the gRPC microservice to a Serverless architecture. Through monitoring over a period of time, we found that the differences in response times were within an acceptable range. Below is a comparison of response times for a specific user's request over nearly 3 days between the Serverless mode (on the left) and the gRPC mode (on the right):

![pic9](./images/7qps2.png)

The P95 response time data is represented in the following graph:

![pic10](./images/8-qps1.png)
It's evident that the Serverless response times may be slightly longer than those of the gRPC service, resulting in a few extra seconds. A significant part of this delay is attributed to the fact that our AD Debug Service makes numerous calls to other services to obtain the required results. Currently, these other services are still hosted within EKS clusters, and the additional time taken for these external service calls naturally contributes to the increased response times compared to the direct gRPC calls within EKS. 

Additionally, the time required for initializing the application during each Lambda startup is quite short, typically completing within 10ms:

![pic11](./images/9-performance.png)

Furthermore, we've monitored the cost comparison during this period, and the results are as follows:

| Time Range               | Serverless Cost | Domain Service Cost | Cost Save |
| ------------------------ | --------------- | ------------------- | --------- |
| 2023/08/01 – 2023/08/31  | $0.168          | $25.2               | 99.3%     |
| 2023/09/01 – 2023/09/30  | $0.160          | $24.4               | 99.3%     |


> **Note**
>Since Freewheel Domain Service is deployed within an EKS cluster, it is  not possible to individually bill each pod. Therefore, the cost estimate  for the AD Debug Service is based on the average cost of pods.
>From the table above, it's evident that the cost has decreased by over 99% after migrating to a Serverless architecture. 


