---
title: "Deploy a Cloud Database to Scale a LAMP App"
description: ""
tags:
    - tutorials
    - AWS Lightsale
    - LAMP
    - MySQL
    - scaling
authorGithubAlias: spara
authorName: Sophia Parafina
date: 2023-06-20
---

In previous tutorials you deployed a single application on a VPC. Applications like these are called monolithic applications because all the components are tightly coupled in a single server. Cloud architectures are frequently loosely coupled with application components connected via the network. This tutorial is an update of of a Lightsail workshop.

Unlike the tutorial, and in keeping with conventions of the Practical Cloud Guide. You will complete an updated version of the workshop with the AWS CLI instead of the AWS Lightsail console. You will deploy a monolithic LAMP application and an external relational database, the replace the monolithic app’s database with the external database. In addition, you will scale the application by adding additional servers to a load balancer that distributes requests to the servers.

## What you will learn

- How to deploy a LAMP stack application as a monolith in a single Lightsail instance.
- Re-architect the application by separating the application from the database.
- Scaling and load balancing the LAMP stack.

## Prerequisites

- An AWS Account (if you don't yet have one, you can create one and set up your environment here).
- A Cloud9 environment.



## Module 1: Create a relational database

In this section you’ll deploy a Lightsail database, a managed database service that reduces the complexity of deploying and managing database software. Lightsail manages the underlying infrastructure and database engine while you create and deploy databases and tables running inside the service.

With the Lightsail CLI, create a MySQL 5.7 database (`—relational-database-blueprint-id mysql_5_7`). The point of this lab is to deploy a fault-tolerant and scalable implementation of the web application which requires a High Availability database plan, e.g.,  `—relational-database-bundle-id micro_ha_2_0`. Name the database todo-db (`—relational-database-name todo-db`). 

By default Lightsail will create a strong password for you. However, for this tutorial, keep the password simple (—master-user-password taskstasks) and assign a user name (—master-username dbmasteruser)

```bash
aws lightsail create-relational-database \
--relational-database-name todo-db \
--relational-database-blueprint-id mysql_5_7 \
--relational-database-bundle-id micro_ha_2_0 \
--master-username dbmasteruser \
--master-user-password taskstasks \
--no-publicly-accessible
```

## Module 2: Deploy a Monolithic App

In a monolithic application all the components are in a single VPS. In this example, the components include a MySQL database. a PHP application framework, and the application all hosted in a single Lightsail instance.

![Monolithic application architecture](./images/lamp-architecture-1.jpg)

You will configure the server via the `—user-data` parameter. Previous tutorials used simple commands. This tutorial uses a script that does the following:

- The Bitnami image has a default web page installed which needs to be removed. The script starts by changing into the root directory of the web server (/opt/bitnami/apache2/htdocs) and deleting the existing files
- Next the script clones the application code to render the web front-end from the lab’s Github repo
*- To ensure that the PHP application can write to the settings file (connectvalues.php), the script changes the ownership (chown) on the file to match the account under which the Apache web server runs, as well as ensuring that account can write to the file (via chmod)
- Each Bitnami-based instance generates a unique password for the locally installed MySQL database, this next command in the script opens the settings file and updates it with this password (which can be found at /home/bitnami/bitnami_application_password)
- Finally the script issues a set of SQL commands to MySQL (via the MySQL command line tool) that will initialize the local database

Copy the script and save it to a file named `launch.sh`.

```bash
echo "removing default website"
cd /opt/bitnami/apache2/htdocs
rm -rf *

echo "cloning github repo"
git clone -b loft https://github.com/mikegcoleman/todo-php .

echo "setting ownership on settings file"
chown bitnami:daemon connectvalues.php
chmod 666 connectvalues.php

echo "adding db password to settings file"
sed -i.bak "s/<password>/$(cat /home/bitnami/bitnami_application_password)/;" /opt/bitnami/apache2/htdocs/connectvalues.php

echo "creating tasks database"
cat /home/bitnami/htdocs/data/init.sql | /opt/bitnami/mysql/bin/mysql -u root -p$(cat /home/bitnami/bitnami_application_password)
```

Using the Lightsail CLI, create a VPS with a blueprint for a [LAMP](https://aws.amazon.com/what-is/lamp-stack/) stack. To find blueprints with the CLI, use get-blueprints and filter the results using the linux utility [grep](https://www.gnu.org/software/grep/manual/grep.html).

```bash
aws lightsail get-blueprints | grep lamp
"group": "lamp_8_bitnami",
"blueprintId": "lamp_8_bitnami",
```

Specify the size of the VPS with the `—bundle-id` parameter. Like a blueprint, use the CLI to find a blueprint. Since you will scale the application by adding additional server, use a small VPS. We're using a small VPS bundle that you will clone to scale the application horizontally.

```bash
aws lightsail get-bundles
...
{
            "supportedPlatforms": [
                "LINUX_UNIX"
            ], 
            "name": "Small", 
            "power": 1000, 
            "price": 10.0, 
            "ramSizeInGb": 2.0, 
            "diskSizeInGb": 60, 
            "transferPerMonthInGb": 3072, 
            "cpuCount": 1, 
            "instanceType": "small", 
            "isActive": true, 
            "bundleId": "small_2_0"
        }
```

With the `lamp_8_bitnami` blueprint deploy a `small_2_0` VPS named `PHP-fe-1`.

```bash
aws lightsail create-instances \
--instance-names PHP-fe-1 \
--availability-zone us-west-2a \
--blueprint-id lamp_8_bitnami \
--user-data file://launch.sh \
--bundle-id small_2_0
```

It will take several minutes to instantiate the VPS. When the server is ready verify the connection between the PHP application and the locally-running MySQL database. To find the public IP of your lightsail intance check the card for your instance on the Lightsail console home page or use the Lightsail CLI command `get-instance-access-details`.

> TIP: To find specific values in a JSON file [install jq](https://stedolan.github.io/jq/), a utility for parsing JSON.
`sudo yum install jq -y`

```bash
aws lightsail get-instance-access-details —instance-name PHP-fe-1 | jq .accessDetails.ipAddress
```
Verify the connection between the PHP application and the locally-running MySQL database by opening a browser to `http://<ipAddress>`.

![Verify application is deployed](./images/add-task.jpg)

## Module 3: Replace the database

In this section you will replace the local MySQL instance running in the VPS with a high availability Amazon Relational Database Service database. The application architecture will look like this:

![Re-architecting the monolithic application](./images/lamp-architecture-2.jpg)

Update the application configuration to point to the highly-available Lightsail database. First we will need the address of the high availability database. Use the `get-relational-databases` command to get the a JSON doc describing the instance and filter it with jq.

```bash
sudo yum install jq -y

aws lightsail get-relational-databases | jq .relationalDatabases[].masterEndpoint.address
```
In the ToDo application click **Settings** from the top menu.

![Change database endpoint](./images/todo_settings.jpg)

Paste the endpoint value of your Lightsail database under **DB Hostname**. Enter `dbmasteruser` for the **DB Username**, and `taskstasks` for the **DB Password**. Choose **Save Settings**.

![Change database connection setting](./images/save_settings.jpg)

Test the new database by clicking **List Tasks** in the top menu, there shouldn’t be any tasks to display. Also note at the bottom of the screen it should list your Lightsail database endpoint as value for Database host

If your web app is still showing the previously deployed database (denoted by `localhost` as the database host), you may need to use either a new browser window or an incognito window.

## Module 4: Clone the application

Snapshots are point-in-time copies of instances. Lightsail simplifies creating snapshots of your instances that can be used to backup and restore instances, scale instance sizes up or down, and/or to deploy a new instance. Create a snapshot of the VPS with the `create-instance-snapshot` command.

```bash
aws lightsail create-instance-snapshot \
--instance-snapshot-name PHP-fe-ls-db \
--instance-name PHP-fe-1
```

The status will change to `Snapshotting`, you will need to wait for the process to complete before moving forward. This can take up to 5 minutes. When the snapshot is complete, create two new instances with the `create-instances-from-snapshot`. Note that you can use a list of instance names to create multiple instances.

```bash
aws lightsail create-instances-from-snapshot \
--instance-snapshot-name PHP-fe-ls-db \
--instance-names {PHP-fe-2,PHP-fe-3} \
--availability-zone us-west-2a \
--bundle-id small_2_0
```

Test the public IP of each of the two newly created front end instances in your web browser. Notice that the hostname for that particular web front end instance is listed under your task list, and that it changes based on which instance you are visiting in your web browser

## Module 5: Scale the application

It will take several minutes for all three instances to register their health checks as **Passed** once this has happened, move to the next step. While the instances are starting, create a [load balancer](https://lightsail.aws.amazon.com/ls/docs/en_us/articles/understanding-lightsail-load-balancers) to provide scalability and fault tolerance. Set `—instance-port` to `80` and name the load balancer `todo-lb`.

```bash
aws lightsail create-load-balancer \
--instance-port 80 \
--load-balancer-name todo-lb
```

When the instances are all running, attach them to the load balancer.

```bash
aws lightsail attach-instances-to-load-balancer \
--load-balancer-name todo-lb \
--instance-names {"PHP-fe-1","PHP-fe-2","PHP-fe-3"}
```

Congratulations! You have scaled your application. The application architecture looks like this.

![Scaled application architecture](./images/lamp-architecture-3.jpg)

You can find the address of the load balancer with `get-load-balancer` and filter the response to `dnsName`.

```bash
aws lightsail get-load-balancer —load-balancer-name todo-lb | jq .loadBalancer.dnsName
```

Open a browser to http://<dnsName> to verify that application is working. Refresh the browser window and you will see the Front-end host ip change.

![](./images/scaled-app.png)

## Module 6: Clean up

To prevent additional costs, delete the VPS instances, the snapshot, and the MySQL instance.

```bash
aws lightsail delete-instance --instance-name PHP-fe-1
aws lightsail delete-instance --instance-name PHP-fe-2
aws lightsail delete-instance --instance-name PHP-fe-3
aws lightsail delete-relational-database --relational-database-name todo-db
aws lightsail delete-instance-snapshot --instance-snapshot-name PHP-fe-ls-db
```

## What you accomplished

You’ve taken an application deployed on a single VPS and scaled it by replacing the local database with a high availability database, creating copies of the VPS, and attaching them to a load balancer that distributes the requests among the VPS. The import takeaways are;

- Configure a VPS with a launch script.
- Replace a local database with high availability instance.
- Create a snapshot to clone a VPS.
- Scale an application with a load balancer.

You are well on your way to becoming a cloud engineer.

## What's next

The next section is a departure from deploying applications and databases. You will learn about creating accounts and managing user roles and permissions. Modern enterprises commonly have several environments such as dev, test, and production. Managing multiple environments for an enterprise is a core requirement for a cloud engineer. 