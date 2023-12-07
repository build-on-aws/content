---
title: "Connecting Lightsail to AWS Services"
description: "This posts demonstrates how to connect Lightsail instances to AWS services using VPC Peering."
tags:
    - lightsail
    - vpc-peering
    - rds
authorGithubAlias: spara
authorName: Sophia Parafina
date: 2023-12-07
---

There are situations where you need access to AWS resources that are not in Lightsail, such as files on an EC2 server or the need to connect to an AWS RDS such as PostgreSQL or MariaDB. It is possible to use these resources via VPC (Virtual Private Cloud) peering with a few caveats. This article shows how to configure VPC peering to connect to AWS resources not in Lightsail.

## VPC Peering

A VPC is a virtual network that connects AWS resources to each other. It isolates your infrastructure into a logical grouping to facilitate managing resources. Each AWS region typically has a default account in addition other user created VPCs. VPC peering establishes a network connection between two VPCs. Lightsail is in its own VPC and if you want to access resources outside of Lightsail you can use VPC peering to connect to the [default VPC](https://docs.aws.amazon.com/vpc/latest/userguide/default-vpc.html?sc_channel=el&sc_campaign=post&sc_content=connectinglightsailtoawsservices&sc_geo=mult&sc_country=mult&sc_outcome=acq&sc_publisher=amazon_media&sc_category=lightsail). Lightsail can only create VPC peering with the default VPC for an AWS region.

To establish VPC peering open the [Lightsail console](https://lightsail.aws.amazon.com/ls/webapp/home/instances?sc_channel=el&sc_campaign=post&sc_content=connectinglightsailtoawsservices&sc_geo=mult&sc_country=mult&sc_outcome=acq&sc_publisher=amazon_media&sc_category=lightsail). Choose **Account**.

![Choose Account at the top right of the Lightsail console](./images/vpc-peering-1.png)

Then choose **Account** from the drop down menu.

![Choose Account from the drop down](./images/vpc-peering-2.png)

Next, choose the **Advanced** tab.

![Choose the Advanced tab](./images/vpc-peering-4.png)

Choose the AWS regions where you want to **Enable VPC peering**.

![Choose AWS regions to enable VPC peering](./images/vpc-peering-4.png)

You can confirm if VPC peering was successful by opening the VPC console.

![Open VPC console](./images/peering-1.png)

Choose **Peering connections** in the side menu.

![Choose Peering connections](./images/peering-2.png)

Verify peering connections by examining the Requester VPC and Accepter VPC which should be the default VPC for the chosen region.

![Verify the peering connection](./images/peering-3.png)

## Connecting to an RDS Database

A common scenario is to connect a Lightsail instance to a RDS. To do this, you’ll need the Lightsail instance’s private IP address.

![Get the private IP address of the Lightsail instance](./images/rds-1.png)

Next, open the RDS console. You can use the search bar in the AWS home console.

![Find the RDS console using the search bar](./images/rds-2.png)

Choose **Databases**, then choose the database by selecting the DB Identifier.

![Choose the database](./images/rds-3.png)

To connect to the database, we will need to modify the security group to allow connections from the Lightsail instance. Choose the link to the security group.

![Choose the security group](./images/rds-4.png)

Choose the security group for the database, then choose **Edit inbound rules** under the **Actions** button.

![Choose Actions, then Edid inbound rules](./images/rds-5.png)

Choose **Add rule**, enter the port for MariaDB, the private IP address of the Lightsail instance, and a description. Choose **Save rule**.

![Create an inbound rule for the Lightsai instance](./images/rds-6.png)

The new Inbound rule will be listed for the security group.

![New Inbound rule is listed in the security group](./images/rds-7.png)

## Test the Connection

In this example, he Lightsail instance has the MariaDB client installed. We can use it to test VPC peering by connecting to the database and running SQL commands. Open a terminal on the Lightsail instance.

![Open the Lightsail instance terminal](./images/test-1.png)

In the terminal, connect to the database.

```bash
$ mariadb -h wp-mariadb.c0kabllgdzuf.us-west-2.rds.amazonaws.com -P 3306 -u
```

List the databases on the RDS.

![List the databases in the RDS instance](./images/test-2.png)

List the tables in the acme database.

![List the tables in the acme database](./images/test-3.png)

Query the acme database for employees.

![Query the acme database](./images/test-4.png)

You can now connect any client or application to the database from your Lightsail instance.

## Summary

This article shows that you are not limited to the resources in AWS Lightsail. You can connect and use other AWS resources as long as they are in the default VPC for an AWS region. For example, checkout this [document that shows how to connect a to AWS Elastic File System (EFS)](https://aws.amazon.com/getting-started/hands-on/efs-and-lightsail/?sc_channel=el&sc_campaign=post&sc_content=connectinglightsailtoawsservices&sc_geo=mult&sc_country=mult&sc_outcome=acq&sc_publisher=amazon_media&sc_category=lightsail).


