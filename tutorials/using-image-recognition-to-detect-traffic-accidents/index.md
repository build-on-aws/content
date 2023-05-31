---
title: "Get Started With Amazon SageMaker Data Wrangler Image Preparation"
description: "Learn how to use Amazon SageMaker Data Wrangler's image preparation feature to process image data while writing minimal code."
tags:
  - amazon-sagemaker-data-wrangler
authorGithubAlias: pechung
authorName: Peter Chung, Munish Dabra
date: 2023-06-01
---

Imagine you’re working with state and local governments to respond as quickly as possible to traffic accidents. You’re working to build a machine learning (ML) model that can identify accidents from traffic footage to dispatch first responders to arrive on site. Your efforts are extremely important as it will save lives!

To do this, you’ll need to prepare lots of images to train and build your ML model. But you’re not too excited about having to write hundreds of lines of code. You’re more familiar working with tabular data and aren’t so comfortable using libraries that process images. Fortunately, Amazon SageMaker Data Wrangler can help. Data Wrangler dramatically reduces the time it takes to aggregate and prepare image data for ML. You can use its single visual interface, to prepare these images without writing a single line of code.

In this tutorial, you will use Amazon SageMaker Data Wrangler to prepare image data for use in an image classification model. Your data preparation tasks will be an essential step toward building a model that can recognize, and subsequently respond to, traffic accidents on the road.

![0-architecture.png](/images/0-architecture.png)

The preceding diagram shows the tutorial's workflow. Once you set up your Amazon SageMaker Studio domain, you will download images of automobile crashes captured from CCTV and upload them into an Amazon S3 bucket. Then you will import these images into Amazon SageMaker Studio to process them.

Why do we need to pre-process images? For the purpose of building an accurate machine learning model, we want to enhance the quality of the images, extract relevant features (like outlines of an automobile), and standardize the data. These are all essential steps to preparing our image data, getting them into a suitable format, and enabling the machine learning model to learn from the data.

For the image preparation steps in Data Wrangler, we'll first handle corrupt or defective images in the dataset. This removes unsuitable images in training our machine learning model. Then we'll enhance the contrast to extract relevant features and resize images to standardize them. Lastly, we'll apply a custom transform to improve the model's ability to detect edges within the images.

Once the transformation steps are complete, we'll export the the prepared images to another Amazon S3 bucket. We'll execute the job to process the images. Lastly, we'll clean up the environment so we don't incur charges after we're done.

## Prerequisites

Before starting this guide, you will need an **AWS account**. If you don't already have an account, follow the [Setting Up Your AWS Environment](https://aws.amazon.com/getting-started/guides/setup-environment/) getting started guide for a quick overview.

## Implementation

### Set Up Your Amazon SageMaker Studio Domain & Dataset

In this tutorial, we will use Amazon SageMaker Studio to access Amazon SageMaker Data Wrangler image preparation and processing.

Amazon SageMaker Studio is an integrated development environment (IDE) that provides a single web-based visual interface where you can access purpose-built tools to perform all machine learning (ML) development steps, from preparing data to building, training, and deploying your ML models.

If you already have a SageMaker Studio domain in the US West (Oregon) Region, follow the SageMaker Studio [set up guide](https://docs.aws.amazon.com/sagemaker/latest/dg/sagemaker-geospatial-roles.html) to attach the required AWS IAM policies to your SageMaker Studio account, then skip Step 1, and proceed directly to Step 2.

If you don't have an existing SageMaker Studio domain, continue with Step 1 to run an AWS CloudFormation template that creates a SageMaker Studio domain and adds the permissions required for the rest of this tutorial.

<ol>
  <li>Choose the [AWS CloudFormation](https://us-west-2.console.aws.amazon.com/cloudformation/home?region=us-west-2#/stacks/quickcreate?templateURL=https://sagemaker-sample-files.s3.amazonaws.com/libraries/sagemaker-user-journey-tutorials/v2/CFN-SM-IM-Lambda-catalog.yaml) stack link. This link opens the AWS CloudFormation console and creates your SageMaker Studio domain and a user named studio-user. It also adds the required permissions to your SageMaker Studio account. In the CloudFormation console, confirm that US West (Oregon) is the Region displayed in the upper right corner. The stack name should be sm-studio-tutorial, and should not be changed. This stack takes about 10 minutes to create all the resources.
  
  This stack assumes that you already have a public VPC set up in your account. If you do not have a public VPC, see [VPC with a single public subnet](https://docs.aws.amazon.com/vpc/latest/userguide/vpc-example-dev-test.html) to learn how to create a public VPC.</li>

    ![1-create-stack](/images/1-create-stack.png)

    ![2-confirm-stack](/images/2-confirm-stack.png)

  <li>When the stack creation has been completed, you can proceed to the next section to set up a SageMaker Studio notebook.</li>

    ![3-confirm-complete](/images/2-confirm-complete.png)

  <li>SageMaker Studio automatically creates an Amazon S3 bucket within the same Region as the Studio domain. Search for “S3” in the Management Console search bar to navigate to Amazon S3.</li>

    ![search-for-s3](/images/search-for-s3.png)

  <li>You will find a bucket with the name **sagemaker-studio-xxxxxxxx**. Select that bucket to upload files.</li>

    ![select-bucket](/images/select-bucket.png)

  <li>Download the files in this [sample dataset](https://www.kaggle.com/datasets/ckay16/accident-detection-from-cctv-footage?resource=download) and unzip the contents. Sample dataset contain CCTV footage data of accidents and non-accidents available from [Kaggle](https://www.kaggle.com/datasets/ckay16/accident-detection-from-cctv-footage). The dataset contains frames captured from YouTube videos of accidents and non-accidents. The images are split into train, test, and validation folders.</li>

  <li>Upload the unzipped contents of the folder by selecting **Add folder**.</li>

    ![upload-files](/images/upload-files.png)
</ol>

### Import Data into a SageMaker Data Wrangler Flow

In this step, you'll initiate a new Data Wrangler flow within the SageMaker Studio domain. You can use this flow to prepare image data without writing code using the Data Wrangler user interface (UI).

<ol>
  <li>Enter **SageMaker Studio** into the console search bar, and then choose **SageMaker Studio**.</li>

    ![4-search-sagemaker](/images/4-search-sagemaker.png)

  <li>Choose US West (Oregon) from the Region dropdown list on the upper right corner of the SageMaker console.</li>

    ![5-select-region](/images/5-select-region.png)

  <li>To launch the app, select **Studio** from the left console and select Open Studio using the studio-user profile.</li>

    ![6-select-domain-user](/images/6-select-domain-user.png)

  <li>The SageMaker Studio Creating application screen will be displayed. The application will take a moment to load.</li>

    ![7-load-sm-studio](/images/7-load-sm-studio.png)
    
  <li>Open the SageMaker Studio interface. On the navigation bar, choose **File, New, Data Wrangler Flow**.</li>

    ![8-create-new-flow](/images/8-create-new-flow.png)

  <li>It will take a moment for Data Wrangler to load. Notice that you can connect Data Wrangler to multiple data sources. In this tutorial, we’ll be using Amazon S3.</li>

    ![9-dw-flow-loading](/images/9-dw-flow-loading.png)
  
  <li>Once Data Wrangler completely loads, you can right-click the flow tab and rename your flow. Rename is as car_creash_detection_data.flow.</li>

    ![10-rename-flow](/images/10-rename-flow.png)

  <li>Select import data to begin loading data in the flow.</li>

    ![11-import-data](/images/11-import-data.png)

  <li>Select Amazon S3 as the data source and navigate to the Amazon S3 bucket containing the image dataset from step 1.</li>

    ![12-select-s3](/images/12-select-s3.png)

  <li>Navigate through the folder prefixes toward the data/train prefixes and select the accident prefix. On the right-hand side, under ‘Details’, choose **image** as the file type. Select **Import**.</li>

    ![13-select-dataset](/images/13-select-dataset.png)

  <li>Data Wrangler only imports 100 random images. After a moment, Data Wrangler will display the images in the UI.</li>

    ![14-import-complete](/images/14-import-complete.png) 
</ol>

### Image Preparation Step: Corrupt Images

In this section, you'll use Amazon SageMaker Data Wrangler built-in transformations to run a series of image transformations steps. This will help you become familiar with Data Wrangler’s image transformation capabilities. Image data transformation is one way to build a more robust model – augmenting your data image not only increases the size of your training set, but also helps the model generalize better.

<ol>
  <li>If you cannot see the option for **Add step**, select the > icon to show transforms</li>

    ![15-show-transforms](/images/15-show-transforms.png)

  <li>Select **Add step** and then **Corrupt image**.</li>

    ![16-corrupt-image](/images/16-corrupt-image.png)

  <li>Set the Corruption set to impulse noise and a severity of 3. Click on **Preview** and then **Add**. </li>

    ![17-corrupt-image-settings](/images/17-corrupt-image-settings.png)

  <li>After a moment the step will complete. Corrupting an image or creating any sort of noise on the image data helps the model predict accurately even when it sees corrupted images in production.</li>

    ![18-corrupt-image-results](/images/18-corrupt-image-results.png)
</ol>

### Image Preparation Step: Enhance Contrast & Resize Images

In this step, you’ll add another built-in transformation to enhance the contrast of the images. 

<ol>
  <li>Select **Add step** to **Enhance image contrast**.</li>

    ![19-enhance-image-contrast](/images/19-enhance-image-contrast.png)

  <li>Choose **Enhance Contrast** > Gamma contrast and set the Gamma to 0.75, and then **Preview** and **Add**.</li>

    ![20-enhance-image-contrast-setting](/images/20-enhance-image-contrast-setting.png)

  <li>Add another step to **Resize image**.</li>

    ![21-resize-image](/images/21-resize-image.png)

  <li>Choose **Resize > Crop** to crop the images by 50 pixels from each size of the images. Select **Preview** to see the changes to the image, then select **Add**. Doing so will essentially resize the images from 720 x 1280 to 620 x 1180.</li>

    ![22-resize-image-crop](/images/22-resize-image-crop.png)

  <li>Select **Add**.</li>
</ol>

### Image Preparation Step: Custom Transform

In this step, we’ll use a custom transformation to finish our image preparation. If you can’t find a built-in transform that meets your needs, then you can use custom transform for your image preparation workflows.

<ol>
  <li>Select **Add step** then **Custom transform**.</li>

    ![23-custom-transform](/images/23-custom-transform.png)    

  <li>Give your custom transform a name like ‘Edge detection’, and select **Python (PySpark)**.</li>

    ![24-custom-transform-pyspark](/images/24-custom-transform-pyspark.png)

  <li>Paste in the below **Python** code into the custom transform code snippet.</li>
    
    # A table with your image data is stored in the `df` variable
    import cv2
    import numpy as np
    from pyspark.sql.functions import column

    def my_transform(image: np.ndarray) -> np.ndarray:
      # To use the code snippet on your image data, modify the following lines within the function
      HYST_THRLD_1, HYST_THRLD_2 = 100, 200
      edges = cv2.Canny(image,HYST_THRLD_1,HYST_THRLD_2)
      return edges

    ![25-python-code](/images/25-python-code.png)

  <li>We’re using the Canny edge detector to better reveal the structure of objects in an image. We do this by detecting the outline of objects within the image. Select **Preview** to see the changes to the image, then select **Add**.</li>

  <li>You should now see all the steps within the image preparation flow.</li>

    ![26-completed-steps](/images/26-completed-steps.png)
</ol>

### Export the Prepared Image Data to Another S3 Bucket

In this step, we’ll add the last step to output the results of our flow to an Amazon S3 bucket.

<ol>
  <li>Select **Data flow** to go back to the flow </li>

    ![27-return-to-data-flow](/images/27-return-to-data-flow.png)

  <li>You can visualize your flow that outlines each of the steps you defined. Select the + icon add the results to a destination in S3.</li>

    ![](/images/.png)

  <li></li>

    ![28-save-to-s3](/images/28-save-to-s3.png)

  <li>Give your dataset a name. Set the file type as image, and provide an Amazon S3 location to save the file(s). Select **Add destination**.</li>

    ![29-saved-to-s3-location](/images/29-saved-to-s3-location.png)
  
  <li>You’ve completed the entire flow from transformation and saving the output to Amazon S3. Now you can **Create job** to run the entire flow from beginning to end.</li>

    ![30-create-job](/images/30-create-job.png)
</ol>

### Create a Data Wrangler job to process images

In this step, we'll run our image processing flow with Data Wrangler and save the results to a designated Amazon S3 bucket.

<ol>
  <li>Create a job by providing a job name. You can leave the other options as blank. Select **Next**.</li>

    ![31-create-job-first-page](/images/31-create-job-first-page.png)

  <li>On the next page, select the instance types and count for SageMaker to spin up on your behalf to run the job. You can change additional configurations, but we’ll use the default.</li>

    ![32-configure-job](/images/32-configure-job.png)

  <li>Finally, select **Create**.</li>

    ![33-job-success](/images/33-job-success.png)

  <li>You can monitor the job from Amazon SageMaker > Processing in AWS console by referring to the processing job name and/or job ARN. Processing job will take around 7 minutes to complete as you are processing the entire data set.</li>

    ![34-monitor](/images/34-monitor.png)

  <li>Once the job completes, you can view the results in the Amazon S3 bucket you specified. </li>

    ![35-results-in-s3](/images/35-results-in-s3.png)
</ol>

**Congratulation! You completed the tutorial to prepare image data using little to no code with Amazon SageMaker Data Wrangler!**

## Clean up your AWS resources

It is a best practice to delete resources that you no longer need so that you don't incur unintended charges.

<ol>
  <li>To delete the S3 bucket, open the Amazon S3 console. On the navigation bar, choose **Buckets, sagemaker-studio-xxxxxxxxx**, and then select the checkbox next to the dataset and the results from the output </li>

  <li>On the **Delete objects** dialog box, verify that you have selected the proper object to delete and enter **permanently delete** into the **Permanently delete** objects confirmation box.</li>

  <li>Once this is complete and the bucket is empty, you can delete the **sagemaker-studio-xxxxxxxxx** bucket by following the same procedure again.</li>

    ![delete-files](/images/delete-files.png)

  <li>The Data Wrangler kernel used for running the flow in this tutorial will accumulate charges until you either stop the kernel or perform the following steps to delete the apps. For more information, see [Shut Down Resources](https://docs.aws.amazon.com/sagemaker/latest/dg/notebooks-run-and-manage-shut-down.html) in the Amazon SageMaker Developer Guide.</li>

  <li>To delete the SageMaker Studio apps, do the following: On the SageMaker console, choose **Domains**, and then choose **StudioDomain**.  From the User profiles list, select **studio-user**, and then delete all the apps listed under Apps by choosing **Delete app**. To delete the JupyterServer, choose **Action**, then choose **Delete**.  Wait until the **Status** changes to **Deleted**.</li>

    ![select-domain](/images/select-domain.png)

    ![delete-apps](/images/delete-apps.png)

  <li>If you used an existing SageMaker Studio domain in Step 1, skip the rest of Step 5 and proceed directly to the conclusion section.</li>

  <li>If you ran the CloudFormation template in Step 1 to create a new SageMaker Studio domain, continue with the following steps to delete the domain, user, and the resources created by the CloudFormation template.</li>

  <li>To open the CloudFormation console, enter CloudFormation into the AWS console search bar, and choose CloudFormation from the search results.</li>

    ![search-cfn](/images/search-cfn.png)  

  <li>Open the CloudFromation console. In the **CloudFormation** pane, choose **Stacks**. From the status dropdown list, select **Active**. Under Stack name, choose **sm-studio-tutorial** to open the stack details page.</li>
  
  <li>On **sm-studio-tutorial** stack details page, choose **Delete** to delete the stack along with the resources it created in Step 1.</li>

    ![delete-cfn](/images/delete-cfn.png)  
</ol>

Congratulations! You have finished the tutorial on prepare image data using Amazon SageMaker Data Wrangler.

In this tutorial, you used Amazon SageMaker Data Wrangler to prepare image data using both built-in and custom transformations. You saved your steps as a Data Wrangler flow and executed the job to save the output to an Amazon S3 bucket.
