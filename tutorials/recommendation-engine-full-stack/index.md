---
title: "Build Your Own Recommendation Engine for a Streaming Platform Clone on AWS: A Full Stack Tutorial"
description: "Hands-on tutorial showing how to build a full stack recomemndation engine integrated for a Streaming Platform Clone"
tags:
  - fullstack-machinelearning
  - data-visualization
  - sagemaker
  - kmeans
  - chalice
  - opensource
  - lambda
  - apigateway
  - python
  - tutorials
showInHomeFeed: true
authorGithubAlias: pkamra
authorName: Piyali Kamra
date: 2023-06-26
---

There's a point in every developer's journey when they realize that building machine learning models in isolation isn't enough. They need to integrate those models into their full-stack applications to create real-world value. But when it comes to recommendation engines, that can be easier said than done. The process can be daunting, especially if you're trying to build a streaming platform from scratch. For instance, imagine building a streaming platform lets call it “MyFLix” that provides personalized content recommendations to its users.You need to complete the project quickly, but you don't know where to start.This tutorial will help solve the challenge that developers face when it comes to building recommendation engines and integrating them into their full stack applications. In this tutorial, **you will learn**:

- How to get started with using jupyter notebooks and python code to sanitize your raw data and perform data visualizations 
- How to find relationships between various features in your data set and convert the relevant features into numerical features
- How to scale the numerical features in your raw data to bring all the features on the same scale for comparison purposes
- How to build, train and deploy your custom and native machine learning models on sagemaker.
- How to expose the deployed models as a REST API using AWS Lambda and AWS API Gateway using Open Source Chalice framework (https://github.com/aws/chalice)
- How to integrate the REST API's with a fronting User Interface (In our case this UI will represent our custom streaming platform clone called Myflix but you can use the skills you learn in this tutorial for building your own full stack applications with ML Models)


| Attributes             |                                                                 |
|------------------------|-----------------------------------------------------------------|
| ✅ AWS experience      | 200 - Intermediate                                                        |
| ⏱ Time to complete    | 60 minutes                                                      |
| 💰 Cost to complete    | Free tier eligible                                               |
| 🧩 Prerequisites       | - [AWS Account](https://aws.amazon.com/resources/create-account/?sc_channel=el&sc_campaign=devopswave&sc_content=obsvbltjv&sc_geo=mult&sc_country=mult&sc_outcome=acq)|
| 

| ToC |
|-----|

## Introduction

In this tutorial we will be building a recommendation engine for a streaming platform clone called Myflix. Initially we will go through the process of analyzing, cleaning, and selecting features from our raw movie data, setting the foundation for a robust recommendation engine for our streaming platform clone. Next we will build a custom scaling model to ensure accurate comparisons of our wrangled movie data features. Then we will utilize these scaled values to train and construct our k means clustering algorithm for movie recommendations. Additionally, we will learn how to deploy our models on SageMaker to achieve maximum efficiency. Finally we will build fronting API’s for  our ML models for real time predictions. We will learn how to use the open-source Chalice framework (https://github.com/aws/chalice) as a one click build and deploy tool for building our API’s. Chalice will even expose the API as a lambda and create the API gateway endpoint out of the box with exceptional ease! By the end through this tutorial we would have learnt how to bridge the gap between our ML models and Front end. The skills learnt through this tutorial can be used in to integrate your own full stack applications with API's and ML Models.

### Diagrammatic flow of our entire process
![Shows all the steps involved in doing this tutorial](images/recommendation_flow.png)


## Getting started with the existing code

1. We will use AWS CLI and Cloudformation nested stacks to build the infrastructure resources needed for this tutorial. We can create these resources by downloading the [Cloudformation Templates from this folder](https://github.com/pkamra/recommendation-engine-full-stackapp/tree/main/infrastructure). Here is how I execute the AWS CLI Commands to deploy the Cloudformation Nested stacks. This is how my directory structure looks like after I download the Cloudformation templates:-
```bash
-rw-r--r--     1 XXXXX  XXXX   6582 Jul  5 22:07 customresource-stack.yaml
-rw-r--r--     1 XXXXX  XXXX    269 Jul  7 21:23 glue-stack.yaml
-rw-r--r--     1 XXXXX  XXXX   3091 Jul  4 02:24 instance-stack.yaml
-rw-r--r--     1 XXXXX  XXXX   2550 Jul  7 13:11 main-stack.yaml
-rw-r--r--     1 XXXXX  XXXX   2942 Jul  7 14:09 packaged.yaml
-rw-r--r--     1 XXXXX  XXXX   6438 Jul  5 12:43 sagemaker-stack-working.yaml
-rw-r--r--     1 XXXXX  XXXX   2141 Jul  5 14:45 sagemaker-stack.yaml
-rw-r--r--     1 XXXXX  XXXX   6877 Jul  7 00:57 vpc-stack.yaml
```
2.The below command is used to package the CloudFormation template in "main-stack.yaml" and output the packaged template as "packaged.yaml" to an S3 bucket named "placeholder-cloudformation-s3-bucket" in the "us-east-2" region. Create your own S3 bucket in your account and use it in the command below  
``` bash
aws cloudformation package --template-file main-stack.yaml --output-template packaged.yaml --s3-bucket placeholder-cloudformation-s3-bucket --region us-east-2
```
3. Next use execute the "aws cloudformation deploy" command to deploy the above generated CloudFormation template named package.yaml. To override the default values for the parameters provided in the main-stack.yaml for S3BucketName, SageMakerDomainName, GitHubRepo, VpcStackName, and VpcRegion you can include the --parameter-overrides option followed by the parameter key-value pairs. Here's an example of how it can be done:
```bash
aws cloudformation deploy \
  --template-file <Absolute path>/packaged.yaml \
  --stack-name buildonaws-pk1 \
  --capabilities CAPABILITY_NAMED_IAM \
  --region us-east-2 \
  --parameter-overrides S3BucketName=myfamousbucket \ 
  SageMakerDomainName=mydomain \ 
  GitHubRepo=myrepo \
  VpcStackName=myvpc \
  VpcRegion=us-east-2
```
  Replace the values (myfamousbucket, mydomain, myrepo, myvpc, us-east-2) with your desired default parameter values.

2. Next Login to the AWS console in which the tutorial setup will be done and validate that everything has been created properly. Look at all the Infrastructure resources that have been created for our tutorial. Go to the S3 bucket that has been created as part of this.
3. Take a quick look at the folder structure inside the S3 bucket. Here is how the folder structure should look like :-
![Shows the contents of the S3 bucket created by the Cloudformation template](images/s3bucket_data.png)
4. Now we will click on the Sagamker IDE url and open Sagemker studio where we will analyze our raw movie data , perform visualizations and come up with the right set of features for our movie data set.
5. Once the Sagemaker Studio opens, 
    - Go to File -> New Terminal
    - Execute the following on the terminal to download the python notebook from the S3 bucket. Replace the S3 bucket name with the S3 bucklet name from the Cloudformation Output.
```bash
aws s3 cp s3://awesome2023-xxxxx/python_notebook/AWSWomenInEngineering2023_V3.ipynb .
```
6. Double clicking the Jupyter Notebook will start the kernel. This process takes about 5 mins. The Jupyter notebook has a table of centents at the beginning of the notebook and every cell has detailed explanation of the steps being executed but I will call out some of the important cells of the notebook over here which will help provide an overview of the setup in the Jupyter Notebook. 
    - We start our data preparation process by downloading our data set from S3 and build a pandas data frame to start analyzing the data in cell#5. This is how the initial data structure in the pandas dataframe looks :-
![Initial Data structure when the raw movie data is downloaded](images/rawmovie_initialstructure.png)   
    - In order to find the distribution of the releaseYears for movie we draw a box plot in Cell#10 and to find the Interquartile ranges of the release years we draw a box plot in Cell#11. the Interquartile ranges (IQR) are a statistical measure used in data preparation and analysis to understand the spread and distribution of data. They help identify and analyze the variability within a dataset. The IQR can be used to identify outliers in a dataset. Outliers are data points that fall significantly outside the range of most other data points. By calculating the IQR and applying a threshold, you can identify observations that are potential outliers. On execition of Cell #11 , here is how you can visualize the IQR and the outliers which are then filtered out in the subsequent cells. :-    
![Box Plot showing Interquartile ranges to show outliers](images/boxplot_iqr_outliers.png)   
    - Next in Cell #14 we look at Binning Visualization Technique. By applying binning and creating specific bins or categories for different runtime ranges, we are able to identify movies with runtimes of more than 3 hours as outliers. These movies fall outside the majority of the dataset and represent extreme values. After identifying the outliers, we make the decision to remove movies with runtimes exceeding 3 hours from the dataset. By doing so, we eliminate the influence of these extreme values on the analysis and create a more representative dataset with a narrower range of runtimes. After removing the outliers, we observe a more symmetrical and bell curve-shaped distribution of movie runtimes. :-    
![Binning Visualization for Movie runtime Minutes](images/binning_runtimeminutes.png)   
    - In Cell #16, the genres column from the dataset is transformed into one-hot encoded columns. This process involves splitting the genres by commas, creating unique genre labels, and adding them as new columns to the dataset. Each movie is then assigned a value of 1 or 0 in these new columns based on whether it belongs to that particular genre or not. This transformation allows for easy analysis and modeling based on the presence or absence of specific genres in movies. This how the pandas dataframe look like after one hot encoding is done. :-  
![One Hot Encoding of Movie Genres](images/onehotencoded.png)    
    - Several other filtering, cleanup and removal of unnecessary features are done and finally in Cell # 31, this is how the final list of numerical features look like. Now the features are ready for being used to build our ML Models. :-
![Numerical feature set](images/finalnumericalfeatures.png)   
7. On observing the final features of the raw movie data set, the features such as startYear, runtimeMinutes, averageRating, and numVotes have different magnitudes. When building a movie recommender algorithm, it is essential to scale these features to a common range to ensure fair comparisons and prevent any particular feature from dominating the algorithm's calculations. Using a custom scaling model from the scikit-learn library allows us to normalize the features and bring them within a similar scale. This normalization helps in avoiding biases and ensures that all features contribute equally to the recommendation process, resulting in more accurate and reliable movie recommendations. So in Cell #33 and Cell #34 we build on own custom scaling algorithm with the help of the sckitlearn library and serialize and save the model.joblib locally. Additionally we also save a copy of model.joblib to S3 bucket for use later on. Finally in Cell#36, you can observe how the scaled numerical features look now once they are on the same scale of magnitude. :-  
![Scaled Numerical feature set](images/sklearnscaledvalues.png)  
8. In order to determine the appropriate number of clusters for our movie recommender algorithm, we employ the elbow method. The code snippet provided in Cell#37 demonstrates the process of training a K-means clustering model on our dataset. However, due to the time-consuming nature of the training process, we have commented out the code for quick analysis. To streamline the analysis, we can refer to the output of previous runs, which have been saved in the S3 bucket folder `kmeans_movieoutput/` for the 50 iterations. This allows us to examine the results without retraining the model each time.The purpose of the elbow method is to identify the optimal number of clusters by evaluating the within-cluster sum of squares (WCSS) for different values of k. In this case, k represents the number of clusters. By assessing the WCSS for a range of k values, we can determine the point at which the addition of more clusters provides diminishing returns in terms of reducing the WCSS. To execute the code, we use Amazon SageMaker's KMeans estimator. It performs multiple epochs of training. The training artifacts, including the resulting cluster assignments, are stored in an S3 bucket folder `kmeans_movieoutput/` specified by the output location. By analyzing the output from previous runs, we gain insights into the ideal number of clusters for our movie recommender system, which will help enhance its accuracy and effectiveness. :-  
![Sagemaker Kmeans algorithm](images/kmeans.png)  
9. Next in Cell #38, to determine the appropriate number of clusters for our movie recommender system, we utilize the models generated in the previous step. This code snippet aims to create an elbow graph visualization, which helps us identify the optimal number of clusters based on the distortion metric. :-  
![Elbow Graph visualization to find the optimal number of movie clusters](images/elbow.png)  
10. Next in Cell #40, using the optimal number of clusters (In my case I chose 26 based on the above figure), deploy the Kmeans Model on Sagemaker for real time inferencing.
11. After that in Cell #43 and Cell #44, we augment our raw movie dataset with the correct cluster number. This is how the augment data set now looks with the cluster number. This augmented data set will be used by the REST API's that we will be building in the next steps to retrieve the set of movies given a particular cluster number. :-  
![Augmented Data Set for quick Lookup with my predicted Cluster Number](images/augmented_dateset.png)  
12. Finally I execute a few more cells, to store this augmented information in a Glue Database. The augmented information is stored in parquet file format in the S3 bucket in the `clusteredfinaldata` folder.
13. At this point although the KMeans model is deployed as a sagemaker endpoint, our Custom Scaling Model is still only available locally in our Sagemaker studio environment as a serialized model.joblib. Our next step will be to deploy our custom scaling model inside Sagemaker's Native SKLearn Container. This is one of the ways of implementing Bring Your Own Model (BYOM) on Sagemaker if you want to utilize Sagemaker's Native Containers. Here is a diagrammatic view of the process to deploy a custom scaling model on Sagemaker's SKLearn Container by creating creating a compressed tar.gz file consisting of the model.joblib and an inference.py file and providing these artifacts to create a sagemaker model endpoint and endpoint configuration. :-  
![Augmented Data Set for quick Lookup with my predicted Cluster Number](images/byom.png) 
14. There are various ways to automate these steps, but we will be using a sagemaker migration toolkit from [our GitHub Repository](https://github.com/build-on-aws/recommendation-engine-full-stack) to make this process easy. So lets move on to the next steps.

## Deploying the custom scaling model as a Sagemaker Endpoint
1. Log onto the AWS console of the AWS Account in which you have deployed the Cloudformation templates to build thd resources for this tutorial. Make sure you are in the AWS Region in which you have deployed your stack. Copy the ARN of the Sagemaker IAM Role. We will use it for setting up the sagemaker migration toolkit, since it has the permissions necessary for creating and deploying the Sagemaker Models, Endpoint configurations and Endpoints.In my case my IAM role is in this format - `arn:aws:iam::<ACCOUNT>:role/service-role/AmazonSageMaker-ExecutionRole-XXXXXXX`

2. Now, lets open Cloud 9 via the AWS Console to deploy the Custom scaling model model.joblib. Cloud9 is a browser based Integrated Development environment on AWS which makes Code devlopment super easy. Once you are logged into the AWS Cloud9 Environment, open a new terminal and execute the following command to clone the repository using the main branch.
```bash
git clone https://github.com/build-on-aws/recommendation-engine-full-stack 
sudo yum install git-lfs
cd recommendation-engine-full-stack
git lfs fetch origin main
git lfs pull origin
```
3. This is how my Cloud9 Integrated Development Environment looks like after I clone the github reporsitory.

4. Here are the remaining commands to install the migration toolkit in teh Cloud 9 console which will enable us to package the custom scaling model `model.joblib` and the `inference.py`for inferencing in a format that is compatible with Sagemaker's Native SKLearn container 
```bash
cd recommendation-engine-full-stack/sagemaker-migration-toolkit
pip install wheel
pip setup bdist_wheel
pip install dist/sagemaker_migration_toolkit-0.0.1-py3-none-any.whl
```
5. Next execute the below command to install the sagemaker migration toolkit. Follow steps and enter the  Sagemaker IAM role that you copied above.
```bash
sagemaker_migration-configure --module-name sagemaker_migration.configure
```
6. Next go to the sklearn/testing folder and download the model.joblib from the S3 bucket by executing the command as follows -
```bash
cd testing/sklearn
aws s3 cp s3://<S3 bucket from cloudformation output where all data is stored>/model.joblib ./
```
7. Lets analyze the `inference.py` script inside the `testing/sklearn` folder. This `inference.py` file has the `model_fn` for loading and deserializing the model.joblib. The `input_fn` is the method that we have already modified to receive the content as `application/json` and transform it into a pandas dataframe before sending the data to the `predict_fn` which loads the dataframe into the custom scaling model and once the data is normalized, it is returned back in the correct format bas a json string via the `output_fn`.

8. Inside the `testing/sklearn` folder, execute python test.py as shown below. This will deploy the sagemaker endpoint for the custom scaling model.
```bash
python test.py
```
Here is how the output will lookmlike on the Cloud 9 Console once the custom scaling endpoint is deployed

9. (Optional steps for testing the custom endpoint after deployment). Copy teh sagemaker endpoint from above in the command below and execute to replace the SAGEMAKER-ENDPOINT in localtest.sh file
```bash 
sed -i s@SAGEMAKER-ENDPOINT@xx-xx-xx-xxxx-xx-xx-xx-xx-xx@g localtest.sh
```

10. Next execute the below command and check if you have got responses in a file named prediction_response.json
```bash
sh localtest.sh
```
- You responses should look as follows: -

11. This concludes the deployment of the custom scaling model. Now if you go to the AWS console, you can see that the 2 real time inferencing endpoints for the custom scaling model and the K Means clustering algoritm is now deployed in sagemaker console as follows:-




## Deploying the REST API's fronting the sagemaker model endpoints 
8. Use Cloud 9 to build the REST API's using Chalice 

## Integrate the API's with our fancy UI.
9. Integrate the Local UI with the REST API's.

## Clean up
10. Following command to delete the stack. 

🎥 Here is a video containing a hands-on implementation about this section.


