---
title: "Comprehending Jira Tickets"
description: Using AWS Comprehend to gain insights from Jira tickets
tags:
  - aws-comprehend
  - jira
  - 
authorGithubAlias: ahoughro
authorName: Amelia Hough-Ross
date: 2023-07-12
---
ToC
Do you want to gain insights from what users type in the free text form fields of Jira Tickets?  In this case, our Center for Cloud Computing wanted to quickly identify popular topics within our ~3,000 cloud-related tickets to provide better FAQ and self-help guides.  Examples of insights include, how many tickets mention the name of a specific cloud service provider? or what keywords appear across multiple different tickets?  Is it Multi-Factor Authentication (MFA)?, is it a help request for launching a public-facing website? or is it just an attempt at the longest thread?

This tutorial shares my experience interacting with the Jira API, cleaning out unwanted data from emails associated with certain tickets, using S3 with AWS Comprehend and Athena to gather insights.

First, BuzzKill, this process was not quick.  Data Cleaning is not for the faint of heart, and NLP entity recognition is not easy to work with using pre-canned models.  In short, as of this writing, AWS Comprehend is not meeting my goal to quickly and easily feed Jira Ticket data to an existing AWS Comprehend Entity recognition job and gain the insights I was expecting.  This is still an important tutorial to walk through for those getting started and what to keep in mind when pursuing this use case with AWS products.


