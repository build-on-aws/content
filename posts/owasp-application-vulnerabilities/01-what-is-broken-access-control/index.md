---
title: What is Broken Access Control?
description: Broken Access Control is one of the OWASP Top 10 vulnerabilities and this articles explains what that involves and ways to mitigate it.
tags:
  - owasp
  - network-security
  - application-security
authorGithubAlias: 8carroll
authorName: Brandon Carroll
date: 2022-08-29
movedFrom: posts/owasp-top-10-defined/01-what-is-broken-access-control
---

|ToC|
|---|

This is a 4-part series:

| SeriesToC |
|-----------|

## Overview of Access Control

To understand the workings of a broken access control attack, one must first understand the goal we are trying to achieve through the use of access control. So what is access control and what is our expectation of the mechanism?

> Not every closed door is locked. - Norm Kelly

The easiest analogy for me to convey access control always goes back to a home with a front door. Entering that front door places a person in a trusted position. After all, we don't invite just anyone into our homes. No, we are selective about who gets an invite and for that reason we have a front door. In most cases that door is going to have a lock on it. In some communities, the people who live there are trusting and rarely bolt the lock. This cannot be the case with our networks. Unfortunately as things go, we often find networks that appear to have the front door shut, but are not locked. This can come if the form of a weak password policy, vulnerabilities in the network protocols used for access, or even in the software platform that's being accessed.

Access-control is the formal mechanism to provide trusted access to an organization's technical and business resources. But access control is a much broader topic than can be covered in a single article. There are many types or categories of access control, ranging from Role-based Access Control (RBAC), Rule-based Access Control, Port-based Access Control, and so on. Within access control, there are various phases to provide not only the authentication of the attempting party, but authorization, management, and auditing. Access control failures can occur in any of these types or phases.

## Results of Access Control Failures

The results of an access control failure are often very public. These often expose customer data and personal information. Even more access control failures go unreported. Setting the business results aside, from a pure technical perspective the results of an access control failure involve the exposure of sensitive information to an unauthorized actor, possible insertion of sensitive information into sent data, and an end user executing unwanted actions on a web application that they are authenticated to. This is not an extensive list.

## Notable Common Weakness Enumerations (CWEs)

If you work with web applications and have the responsibility of delivering their services securely, then the [Common Weakness Enumeration (CWE)](https://en.wikipedia.org/wiki/Common_Weakness_Enumeration) is something you should be familiar with. The CWE is a category system for hardware and software weaknesses and vulnerabilities. It is maintained by a community project with the goals of understanding flaws in software and hardware and creating automated tools that can be used to identify, fix, and prevent those flaws.

The following list highlights the three most common CWEs according to the [OWASP Top 10 for 2021](https://owasp.org/Top10/).

- [CWE-200](https://cwe.mitre.org/data/definitions/200.html): Exposure of Sensitive Information to an Unauthorized Actor
- [CWE-201](https://cwe.mitre.org/data/definitions/201.html): Insertion of Sensitive Information Into Sent Data
- [CWE-352](https://cwe.mitre.org/data/definitions/352.html): Cross-Site Request Forgery.

## Simple Example

A simple example can be found on the mitre.org web site, but I'll elaborate on it a bit. In the example below I have established an SSH session to an Amazon EC2 instance using the username `bcarroll` and the ssh key that I have. In this case I know that the username is incorrect. However the response returned with the `Permission denied` message is not indicative of a username problem.

```bash
➜  aws_da_spec_cloud-infra-sec git:(main) ✗ ssh -i "~/.ssh/bc-06272022.pem" bcarroll@ec2-35-171-9-96.compute-1.amazonaws.com
bcarroll@ec2-35-171-9-96.compute-1.amazonaws.com: Permission denied (publickey,gssapi-keyex,gssapi-with-mic).
➜  aws_da_spec_cloud-infra-sec git:(main) ✗    
```

Conversely, if I establish an SSH session to a router in my lab, the response is a bit different. In the following example you see a successful login.

```bash
➜  aws_da_spec_cloud-infra-sec git:(main) ✗ ssh bcarroll@10.0.1.111
password:********
"Login Successful"
/home$ exit
➜  aws_da_spec_cloud-infra-sec git:(main) ✗ 
```

In the next example, the login fails, but I know it's because of the response.

```bash
➜  aws_da_spec_cloud-infra-sec git:(main) ✗ ssh bcarroll@10.0.1.111
password:********
"Login Failed - incorrect password"
➜  aws_da_spec_cloud-infra-sec git:(main) ✗ 
```

And next I try with a different username.

```bash
➜  aws_da_spec_cloud-infra-sec git:(main) ✗ ssh random-user@10.0.1.111
password:********
"Login Failed - unknown username"
➜  aws_da_spec_cloud-infra-sec git:(main) ✗ 
```

This could be considered "Broken Access Control" because the information I provide in response to an unknown user gives enough information for an unauthorized actor to attempt to guess valid users since a valid user will return the `Login Failed - incorrect password` response.

While this is just one example, it iterates the point that Broken Access Control is a much wider topic than can be addressed in a single article.

But with such a wide range of possible vulnerabilities, how does one go about preventing such an attack?

## Prevention

Prevention to Broken Access should be an interactive process where the current security state is compared to latest vulnerability research and updates applied as necessary. In the case of the SSH example above, the solution might be as simple as changing the prompt to be more obscure, stating `Login Failed - incorrect username or password` no matter whether it was a password or username failure. For other vulnerabilities, the solution may become more involved to actually fix the problem. In some cases it may be more convenient to implement a service such as [AWS WAF](https://docs.aws.amazon.com/waf/latest/developerguide/what-is-aws-waf.html) and make use of the free managed rules that protect against some of the OWASP Top 10 vulnerabilities.

## Conclusion

Whatever the case may be, diving into a topic such as this makes it very clear that several factors must be considered when protecting your resources. This underscores the importance to continue to educate yourself in the latest security trends and how each vendor in use recommends they be mitigated through best practices. There will never be a completely secure infrastructure, however following best practices and performing due diligence will help to stay as far ahead as possible in this ever changing landscape.
