---  
title: "Bash Fundamentals"  
description: "Bash is a nearly ubiquitous shell and programming tool. Here's how to get started with it."
tags:  
  - cloud
  - basics
  - compute
  - scripting
authorGithubAlias: aws-rsavela  
authorName: Russ Savela  
date: 2023-04-17  
---

## Introduction

For most people, computers act as the physical apparatus for using applications, like web browsers or word processors. But if you want to do anything more advanced with your computer, you'll probably use a shell or command interpreter - that is, a program that enables you to interact more directly with your computer's operating system and its services.

Bash is the most commonly encountered shell found on Linux and many other computers. Bash incorporates features from many other shells, and is useful for both interactive use and for creating automation through scripts. It does this by providing built-in commands, and by acting as a facility to launch other programs and use their output.

## Command Line

One common use of Bash is as an interactive command line. In this capacity, Bash allows interaction with the operating system to launch programs, examine and manipulate their output, and alter the behavior of the command line to suit the needs of the user.  

## Redirection

Bash interacts with data sources such as files, but also with the standard input from the command line <stdin>, the standard output to the command line <stdout>, and the destination for errors <stderr>. We can modify this behavior, though, through redirection.

```bash
# stdout - redirection
echo "foo" > foo.txt

# stdout - concatenation
echo "foo" >> foo.txt

# stderr -- since "missing.file.txt" does not exist, an error message
#   that normally would display on the console will be written to foobar.txt
cat missing.file.txt 2> foobar.txt

#
# both stderr and stdout - this syntax is unique to Bash
cat missing.file.txt &> barfoo.txt
cat foobar.txt &>> barfoo.txt
```

## Variables
A variable can be defined just like in a programming language. There are no spaces between the identifier and the assignment operator =, though. The variable must have a preceding $ or ${} encasing it. Variables in Bash aren’t typed, meaning a number or text can be stored in the same variable. This requires some caution on the part of the programmer.

```bash
    MY_VARIABLE="Some text."
    echo ${MY_VARIABLE}
    echo $MY_VARIABLE

    # There are no types for Bash variables, 
    # but the quotes may be ommitted.

    MY_NUMBER=”1”
    echo ${MY_NUMBER}
    MY_NUMBER=1
    echo ${MY_NUMBER}
```
## Built-in Commands

The Bash shell contains several built-in commands. These are desirable as they don't depend on external programs, and are generally faster than creating another process. `let` and `echo` are examples of commands built in to Bash; they don’t run another program.

```bash
FOO=1
BAR=2

let FOOBAR="${FOO} + ${BAR}"

echo "Addition: ${FOOBAR}"

let BARFOO="${FOO} * ${BAR}"

echo "Multiplication: ${FOOBAR}"
```

## Loops and Conditionals

Loops and conditionals in Bash provide for control of script execution similar to that of most programming languages, with some caveats. In the case of for loops, the loop iterates over a list provided at the beginning of the loop.  Behavior similar to a for loop in languages like C can either be accomplished by manually incrementing a variable in a while loop, or by using special Bash syntax in for loop, which isn’t common.

The if conditional in Bash evaluates whether a statement is true, defined in Bash as the value 0.  This is very often in Bash the output of the test command, which is also often used the [ command.  In reality, the number returned any command can be used in an if statement.  The built in variable $? is convenient to use – it contains the return code of the last executed command.

```bash
# for loop - loops over all items in a list
#
for ITEM in 1 2 3; do
    echo ${ITEM}
done

# loop over all items in the current directory
for ITEM in $( ls ); do
    echo ${ITEM}
done


# while 
#
while true
do
    echo "Infinite loop"
    break
done

#
# if and test
#
FOO=2
if [ $FOO -eq 2 ]
then
    echo "FOO equals 2"
else
    echo "FOO does not equal 2"
fi
```

## Shell Functions

Just like in many traditional programming languages, Bash support functions, which are blocks of code that take some number of inputs, and return an output. Functions make Bash scripts easier to read, and also simplify using code in other scripts. Bash scripts can also replace existing commands and modify their behavior – this is generally preferred over the alias command available in many shells. 

In the example below, a function named “error” is defined, which simply prints the variable passed to it, along with the text “ERROR:” preceding it.

```bash
function error {
    # echo an error
    # $0 is the argument
    echo "ERROR: ${1}"
}


error "something did not work"

function max {
    # return the bigger of two arguments
    #
    # Check the number of arguments
    #  -- the “[“ is actually a reference to the command "test" here
    #
    if [  $# -ne 2 ]
    then
        error "incorrect number of arguments"
        return 0
    fi
    #
    if [ ${1}> ${2} ]
    then
        return ${1}
    fi
    return ${2}
}
```

# This returns the bigger number, unless the number of arguments is wrong
max 1 2
echo $_
max 2 1
echo $_
max 1 2 3
echo $_

## Working with External Programs and JSON

A common task in modern cloud environments is working with structured data, often in JSON. Doing this with Bash is greatly simplified by using an external program that is aware of JSON, such as jq.  

In the first example, we start with a list of availability zones, in a JSON structure with a structure similar to this:

```json
    {
    "AvailabilityZones": [
        {
        "State": "available",
        "OptInStatus": "opt-in-not-required",
        "Messages": [],
        "RegionName": "us-east-1",
        "ZoneName": "us-east-1a",

```

To extract the `ZoneName`, we first need to tell `jq` that we would like to examine each of the array items in the `AvailabilityZones` array. We do this with the `.AvailablityZones[]` syntax. After that, we instruct `jq` that we are only looking for the ZoneName attribute. This is specified with `|  {ZoneName}`. The `-r` tells jq not to quote the strings, and  `| join(“”)` removes the JSON formatting, leaving a list of text strings.

```bash
# Example of using jq to parse JSON
#

# enclosing a command in backticks "`" directs 
# the output of the command into a variable
# jq  -- install with 
#   yum install jq 

AZ=$( aws ec2 describe-availability-zones --output json ) 

echo ${AZ} | jq -r '.AvailabilityZones[] | {ZoneName} | join("")'

# 
#  Returns a lot of data on every instance type,
#    
INSTANCE_TYPES=$( aws ec2 describe-instance-types )

echo ${INSTANCE_TYPES} | jq -r '.InstanceTypes | .[] | {InstanceType} | join("")'
```

## Real World AWS EC2 Example

The AWS CloudShell provides a Bash environment to easily try out what we’ve just learned, and look at some real world examples of how Bash can be used to automate some common activities.

Let’s say we want to quickly launch an EC2 instance. Using the AWS Console is an easy way to do this, but it is likely we use some of the same parameters over and over again. It would be nice to encapsulate those in a script, so we don’t need to choose them every time.  

Using what we’ve learned, we can create a script to run in AWS CloudShell like the launch-instance.sh script below. We’ll need to populate this with our SSH key name, Security Group and Subnet ID’s, and check that the AMI exists in the region we are using. The name of the instance we are launching is specified by the INSTANCE_NAME variable, which is taken from the `$1` parameter.  

This script checks the special variable `$#`, which is the number of arguments the script is called with, to make sure a name is given to the instance.

*launch-instance.sh*

```bash
#!/usr/bin/bash
#
# Launch an EC2 instance
#

if [ $# -ne 1 ]
then
        echo "Instance name required."
        exit 1
fi

SSH_KEY="sshkey"
INSTANCE_TYPE="t3.micro"
IMAGE_ID="ami-06e46074ae430fba6"
USER_DATA="user-data.sh"
SECURITY_GROUP="sg-group-id"
SUBNET_ID="subnet-net-id"
INSTANCE_NAME=$1


function ec2_launch {

        aws ec2 run-instances --image-id $1 --count 1 --instance-type $2 --key-name $3 --user-data file://$4 \
                --security-group-id $5 \
                --tag-specifications  "ResourceType=instance,Tags=[{Key=Name,Value=${7}}]" 
 }



 ec2_launch ${IMAGE_ID} ${INSTANCE_TYPE} ${SSH_KEY} ${USER_DATA} ${SECURITY_GROUP} ${SUBNET_ID} ${INSTANCE_NAME}
```

This script also uses another Bash script, the “user-data.sh” file that is passed to the instance when it starts. 

*user-data.sh*
```bash
#!/bin/bash
## example adapted from: https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/user-data.html
yum update -y
amazon-linux-extras install -y lamp-mariadb10.2-php7.2 php7.2
yum install -y httpd mariadb-server
systemctl start httpd
systemctl enable httpd
usermod -a -G apache ec2-user
mkdir /var/www
chown -R ec2-user:apache /var/www
chmod 2775 /var/www
find /var/www -type d -exec chmod 2775 {} \;
find /var/www -type f -exec chmod 0664 {} \;
echo "<?php phpinfo(); ?>" > /var/www/html/phpinfo.php
```


Bash Reference Manual
https://www.gnu.org/savannah-checkouts/gnu/bash/manual/bash.html


