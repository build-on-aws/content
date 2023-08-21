---
title: "Comprehending Jira Tickets"
description: Exploring AWS Comprehend to gain insights from Jira tickets
tags:
  - aws-comprehend
  - jira
  - 
authorGithubAlias: ahoughro
authorName: Amelia Hough-Ross
date: 2023-07-12
---
ToC
Do you want to quickly gain insights from thousands of Jira Tickets?  What if you could identify popular topics across tickets to provide better FAQs and self-service documentation?  
This post shares the experience of interacting with multiple technologies; Jira API, data cleaning, using S3 with AWS Comprehend, and Athena in order to test the robustness of entity and key phrase comprehension within AWS Comprehend.  Spoiler alert, this effort was not quick; it highlights the challenges of entity recognition when you leverage AWS Comprehend out of the box and don't train your own model.  Using the Jira API is painless, data cleaning is not for the faint of heart.  Natural Language Processing (NLP) is a much harder problem than people let on.  In short, as of this writing, I did not get the result I was looking for from AWS Comprehend and I will continue to work on fine-tuning this approach with future blog posts.  Using this helicopter view of AWS Comprehend is a means to help you get started with your own project.

TITLE: Working with the Jira API
In order to give data to AWS Comprehend, you need to understand the data you wish to process.  In this case, Jira ticket data can be queried from the JIRA API.  The API is well documented and many people query Jira data.  For more information on how best to interact with the Jira API, check out this website: https://developer.atlassian.com/server/jira/platform/rest-apis/

To get started with a query, you need to understand your organization's namespace for how Jira is installed.  For example, http://hostname/rest/api/2/issue/MKY-1 this pulls issue: MKY-1.  For this post, I didn't need to leverage authentication mechanisms.  Work with your Atlassian product owner for more information if you need that option.
In my case, I wanted to pull all issues from within a ticketing queue that lives inside a project.  My query had to be structured like this:
https://YOUR_HOSTNAME/jira/rest/api/2/search?jql=project=YOUR_PROJECTNAME AND component in(YOUR_SUBPROJECT,YOUR_SUBPROJECT, ...,)

The next portion of the query is the data you're looking for.  There are many ways to structure your query to pull out all tickets in a certain date range: created=YOUR_DATERANGE or all tickets up to a certain amount: maxresults=YOUR_MAX, and if you want to only get specific fields to reduce the amount of data cleaning you need to do, you can request just specific fields: fields=key, summary, description are the three I chose to focus on.

The final query I put into the browser returns JSON:
https://YOUR_HOSTNAME/jira/rest/api/2/search?jql=project=YOUR_PROJECT AND component in (YOUR_SUBPROJECT, YOUR_SUBPROJECT) AND created=2021-09-30 ORDER BY Created&maxResults=1650&fields=key, summary, description
(Actual URL: https://YOUR_HOSTNAME/jira/rest/api/2/search?jql=project=YOUR_PROJECT%20AND%20component%20in%20(YOUR_SUBPROJECT,%20YOUR_SUBPROJECT)%20AND%20created%20%3C=%202021-09-30%20ORDER%20BY%20Created&maxResults=1650&fields=key,%20summary,%20description)

The JSON data returned only contains the fields you specified.  If the fields permitted email communication, you will see HTML that if put into AWS Comprehend will be useless.  You want to remove this and provide AWS Comprehend with the cleanest data possible.  To do this, find a great data scientist that is familiar with the pandas library and regular expressions.  My forever friend wrote a script that put the json output from Jira into a pandas data frame and wrote 12 lines of code to handle all the unnecessary stylesheet tags, URLS, images, email signature lines, headings, formatted tables, and sequences of whitespace.  By requesting free-text fields in Jira, you never know what you're going to get.

Data cleaning by far was the hardest part for me because I don't do this as part of my day job.  Luckily, I found a data scientist willing to help me out, and my work was immediately less daunting because AWS Comprehend could analyze only the text I wanted.  AWS Comprehend allows you to create analysis jobs that take data from S3 and runs it through a pre-trained entity or key-phrase identification model.

Review Output in Excel to see the raw data or AWS Athena

In order to run counts of keywords and gain the insights I was after to better construct FAQ documentation I would need confirmation that entity recognition had identified the keywords I expected.  I was surprised, that the name recognition is spot on, but for something like Azure it is identified as a "title" while AWS, Google, and Microsoft are correctly identified as "organization".  This highlights the issue between a machine and a human.  Humans would refer to cloud service providers as AWS, Azure and Google, so this is where I could have missed all Azure keywords assuming they would be categorized as an organization.  So technically, the machine is right, and my interpretation is wrong, but that's what I want to search for, and I would want Azure to be classified in the same way as AWS and Google.

All is not lost, it just highlights the complexities one runs into when specific data is applied to a generic NLP model.  You don't get an easy way to gain insights.  It's a thought intensive review.

Opportunity to talk about the "Score" of the keyword and how you can use that to better identify how well your keywords are classified,,,,,,
(Need more on interacting with Comprehend and Athena)

Where we go from here:

