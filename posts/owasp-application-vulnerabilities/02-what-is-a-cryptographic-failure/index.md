---
title: What is a Cryptographic Failure?
description: Cryptographic Failures is one of the OWASP Top 10 vulnerabilities and this articles explains what that involves and ways to mitigate it.
tags:
  - owasp
  - network-security
  - application-security
authorGithubAlias: 8carroll
authorName: Brandon Carroll
date: 2022-08-31
movedFrom: posts/owasp-top-10-defined/02-what-is-a-cryptographic-failure
---

|ToC|
|---|

This is a 4-part series:

| SeriesToC |
|-----------|

It’s probably safe to say that organizations should control who can see their data.  I don’t see this as being anything new to people these days.  VPN’s have become commonplace at the office and for remote workers.  The use of HTTPS, HTTP using TLS for data encryption, is the standard amongst the common search engines, social platforms, and most corporate web sites.  HTTPS became the defacto standard in securely processing payment transactions online.  Why?  Because it hides sensitive data like your credit card number and personally identifiable information (PII). So at a very high level, a cryptographic failure is when the mechanisms we depend on to encrypt or hide our data do not function as expected.  There are many ways this can take place and in this article we will cover a few.  Broken or Risky/Weak crypto algorithms, [Common Weakness Enumeration (CWE) 327](https://cwe.mitre.org/data/definitions/327.html) is an example of one of them.

## Notable Common Weakness Enumerations (CWEs)

There are several weaknesses in this area. The following list are notable CWEs.

- [CWE-259: Use of Hard-coded Password](https://cwe.mitre.org/data/definitions/259.html)
- [CWE-327: Broken or Risky Crypto Algorithm](https://cwe.mitre.org/data/definitions/327.html)
- [CWE-331 Insufficient Entropy](https://cwe.mitre.org/data/definitions/331.html)

A key takeaway here is that they are not all the same. If you have a look at the three I have listed here, you'll find that they vary in what makes them a cryptographic failure. Let's begin with the first one, CWE-259.

## CWE-259: Use of Hard-coded Password

CWE-259 is defined as the "Use of Hard-coded Passwords" and upon first look you might wonder what this one has to do with a cryptographic failure. Let's take a journey together in software development. Imagine that we work for an organization that is developing an app and, at some point, a password is needed to connect to a database. One of the developers creates an admin account for the database. The admin account has full permissions. That username and password is then hard coded into your application. Now the app can read the database and nobody will run into issues, Right?

Wrong! It may work for a short time, but if the password is discovered and published publicly then anyone with the password can access the database.

How is this a cryptographic failure? I see two ways. First, the credentials are stored in clear text. The failure is that cryptographic algorithms were not used to store or even communicate sensitive data. And while this example is the storage of a password in data at rest, it becomes data in transit as soon as the password is passed to the database for authentication. In this case, we wonder if encryption is being used on the data.

Another spin on this can be found in the variant [CWE-321, Use of Hard-coded Cryptographic Key](https://cwe.mitre.org/data/definitions/321.html). Let's imagine that encryption is used, but again the developers decide to store the encryption key in the code. Once again we have a huge issue.

Well, this is just one example. Let's look at the second example of a Cryptographic Failure.

## CWE-327: Broken or Risky Crypto Algorithm

The second CWE to examine is number 327, [Broken or Risky Crypto Algorithm](https://cwe.mitre.org/data/definitions/327.html). In the past I had a job teaching how to setup site-to-site VPN. It was a fairly simple process. Create ACLs to match the traffic on both sides. Create an Internet Security Association and Key Management Protocol (ISAKMP) policy and a Transform Set. Tie it all together with a crypto map and attach it to an interface. In configuring this, you had to select an encryption algorithm for the ISAKMP policy as well as in the transform set. The transform set encryption is what was used for the user data to be encrypted. Back then, we had these two options:

1. DES
2. 3DES

Of course, this was prior to AES encryption. Back then, we could really see a difference in performance when using DES. It was much faster. The problem with DES is that it is no longer considered secure. It's inadequacy comes from the fact that it uses a 56-bit key and that's too short. So, our second CWE could be the use of a crypto algorithm that's no longer considered secure. I'll leave you to review other details of the CWE but you should get the point of this one. Let's move on to the last example.

## CWE-331: Insufficient Entropy

In this last of the notable CWEs, we are talking about entropy. In this case we are talking about a lack of randomness in generated data. This could be a userID, a passphrase, or other information that if guessed could expose data. At times a random string is used to generate encryption keys. If the keys are generated from a string that lacks sufficient entropy then it could be guessed and your data can be exposed.

## Prevention

The following is just a few recommended measures you can take to prevent or minimize Cryptographic Failures. 

1. Don't store sensitive data in your code. Take the time to explore ways to securely access credentials. I recommend looking into a Key Management System (KMS).
2. Ensure you are using up-to-date, standard, strong algorithms. If you're using a system that provides the ability to use old algorithms, ensure that they are disabled.
3. Encrypt data at rest using those same up-to-date, standard, strong algorithms mentioned in number two.
4. Encrypt data in transit the same way, using up-to-date, standard, strong algorithms.

## Conclusion
  
This is not meant to be an exhaustive list, but the hope is that it gets you thinking in terms of secure algorithms and non-hard-coded secure information. Following these ideas will get you started, but you should always go through vendor and provider information and follow best practices.
