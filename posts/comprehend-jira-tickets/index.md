---
title: "Comprehending Jira Tickets"
description: Exploring AWS Comprehend to gain insights from Jira tickets
tags:
  - aws-comprehend
  - jira
  - data
  - Athena
authorGithubAlias: ahoughro
authorName: Amelia Hough-Ross
date: 2023-07-12
---
ToC
Do you want to quickly gain insights from thousands of Jira Tickets?  What if you could identify popular topics across tickets to provide better FAQs and self-service documentation? 
This post shares an overview of getting started with AWS Comprehend using multiple technologies including the Jira API, data cleaning, S3, and AWS Athena in order to test the robustness of entity and key phrase recognition within AWS Comprehend.  Spoiler alert, this effort was not quick; it highlights the challenges of entity recognition when you leverage AWS Comprehend out of the box and don't train your own model.  Using the Jira API is painless, data cleaning is not for the faint of heart.  Natural Language Processing (NLP) is a much harder problem than people let on.  In short, as of this writing, I did not get the result I was looking for from AWS Comprehend.  There was no "easy button" to quickly identify insights from Jira tickets.  I will continue to investigate and in the meantime, I hope this helicopter view of AWS Comprehend helps you get started with your own projects.  

## What is AWS Comprehend?
AWS Comprehend is a text analysis service based on a natural language processing (NLP) algorithm.  It uses pre-trained deep-learning algorithms to parse through text and then provides an analysis of that text based on your interest in entities (keywords), key phrases, sentiment, personally identifiable information (PII), language identification, and syntax.  For more details check out AWS documentation here: 
https://docs.aws.amazon.com/comprehend/latest/dg/what-is.html

To get started using AWS Comprehend, you need data.  My project focused on insights from Jira ticket data which meant learning about the Jira API.

## Working with the Jira API
In order to give data to AWS Comprehend, you need to understand the data you wish to process.  In this case, Jira ticket data can be queried from the Jira API.  The API is well documented and many people query Jira data.  For more information on how best to interact with the Jira API, check it out here: https://developer.atlassian.com/server/jira/platform/rest-apis/

To get started with a Jira API query, you need your favorite web browser, and you need to understand your organization's namespace for how Jira is installed.  For example, http://hostname/rest/api/2/issue/MKY-1 this pulls issue: MKY-1.  For this post, I didn't need to leverage authentication mechanisms.  Work with your Atlassian product owner for more information if you need that option.  This project leverages the Jira API 2 based on how the licensing works at my organization.

For this ambitious idea, I wanted to pull all issues from within a ticketing queue that lives inside a project.  My query had to be structured like this to get into the right project and right queue:
https://YOUR_HOSTNAME/jira/rest/api/2/search?jql=project=YOUR_PROJECTNAME AND component in(YOUR_SUBPROJECT,YOUR_SUBPROJECT, ...,)

The next portion of the query is the data you're looking for.  When I first started, I pulled all the data.  I took samples of data and dropped it into the AWS Comprehend Analyze option and learned I would be parsing through a lot of useless data that was not a good use of time.  Because I needed targeted data, I began to refine my jira api query to just specific fields like **Key**, **Summary**, and **Description**.

There are many ways to structure your query to get the data you want.  You can pull tickets in a certain date range: created=YOUR_DATERANGE or all tickets up to a certain amount: maxresults=YOUR_MAX, and you can also query for specific fields as I specify in this final query:  
https://YOUR_HOSTNAME/jira/rest/api/2/search?jql=project=YOUR_PROJECT AND component in (YOUR_SUBPROJECT, YOUR_SUBPROJECT) AND created=2021-09-30 ORDER BY Created&maxResults=1650&fields=key, summary, description

(Actual URL: https://YOUR_HOSTNAME/jira/rest/api/2/search?jql=project=YOUR_PROJECT%20AND%20component%20in%20(YOUR_SUBPROJECT,%20YOUR_SUBPROJECT)%20AND%20created%20%3C=%202021-09-30%20ORDER%20BY%20Created&maxResults=1650&fields=key,%20summary,%20description)

## Data Cleaning, Oh My!
The JSON data returned from the Jira API only contains data from fields you specified.  Be aware that if your installation of Jira permits email communication within the ticket, you will see HTML information that distracts from keywords you want to focus on.  Removing as much unnecessary text as possible makes all the difference when using AWS Comprehend.  Comprehend does a great job of identifying every single word, even when you don't want it to.  The cleanest data will provide a more clear understanding of the keywords you are evaluating to understand if Comprehend is right for you.  To do this, find a great data scientist!  One who is familiar with the pandas python library and the use of regular expressions.  My forever friend wrote a script that read the JSON output from Jira and wrote it into a pandas data frame.  Next came 12 lines of code to handle all the unnecessary stylesheet tags, Urls, images, email signature lines, headings, formatted tables, and sequences of whitespace.  By requesting free-text fields in Jira, you never know what you're going to get and AWS Comprehend can be easily filled with unnecessary keywords that distract from the insights you wish to achieve.

## Using AWS Comprehend
AWS Comprehend allows you to complete trial reviews of your data in the console.


create analysis jobs that take data from S3 and run it through a pre-trained entity or key-phrase identification model.  I ran my data through both of these with underwhelming results.

Review Output in Excel to see the raw data or AWS Athena

In order to run counts of keywords and gain the insights I was after to better construct FAQ documentation I would need confirmation that entity recognition had identified the keywords I expected.  I was surprised, that the name recognition is spot on, but for something like Azure it is identified as a "title" while AWS, Google, and Microsoft are correctly identified as "organization".  This highlights the issue between a machine and a human.  Humans would refer to cloud service providers as AWS, Azure and Google, so this is where I could have missed all Azure keywords assuming they would be categorized as an organization.  So technically, the machine is right, and my interpretation is wrong, but that's what I want to search for, and I would want Azure to be classified in the same way as AWS and Google.

All is not lost, it just highlights the complexities one runs into when specific data is applied to a generic NLP model.  You don't get an easy way to gain insights.  It's a thought intensive review.

Opportunity to talk about the "Score" of the keyword and how you can use that to better identify how well your keywords are classified,,,,,,
(Need more on interacting with Comprehend and Athena)

## Next Steps


