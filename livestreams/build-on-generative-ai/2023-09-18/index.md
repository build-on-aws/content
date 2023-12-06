---
title: "Mounting S3 buckets to EC2 Instances | S02 E05 | Build On Generative AI"
description: "Getting lots of data to an EC2 instance can be a challenge. Well, let's look into solving this, and attach an S3 Bucket to an EC2 instance so you can get all the training data you need. "
tags:
  - machinelearning
  - s3
  - generative-ai
  - sagemaker
  - aws
  - build-on-live
  - twitch
authorGithubAlias: darko-mesaros
authorName: Darko Mesaros
date: 2023-09-18
spaces:
  - livestreams
---

![Screen recording of running the mountpoint s3 tool](images/mountpoints3.gif "Running it is as simple as this")

In today's session Emily and Darko are joined by Devabrat and John, as we all take a closer look at **Mountpoint S3**. A wonderful little file client for mounting S3 buckets as a local "file system". *Remember* - S3 Buckets are NOT file Systems! 👏 A great use of this tool is being able to use specific EC2 Instances to run Machine Learning training jobs with out the need to copy the data from the S3 bucket to a local disk.

To quickly get started on **Amazon Linux** run the following:

```bash
wget https://s3.amazonaws.com/mountpoint-s3-release/latest/x86_64/mount-s3.rpm
sudo yum install -y ./mount-s3.rpm
```
Then just mount your favorite bucket locally, just make sure you have either an IAM role configured or AWS CLI configured with the appropriate permissions:
```bash
mount-s3 darkos-secret-bucket-files /mnt/cdrom
```

Check out the recording here:

https://www.twitch.tv/videos/1967871463

## Links from today's episode

- [Mountpoint S3 Github](https://github.com/awslabs/mountpoint-s3)
- [Documentation on how to install](https://docs.aws.amazon.com/AmazonS3/latest/userguide/mountpoint-installation.html)

**Reach out to the hosts and guests:**

- Emily: [https://www.linkedin.com/in/emily-webber-921b4969/](https://www.linkedin.com/in/emily-webber-921b4969/) 
- Darko: [https://www.linkedin.com/in/darko-mesaros/](https://www.linkedin.com/in/darko-mesaros/)
