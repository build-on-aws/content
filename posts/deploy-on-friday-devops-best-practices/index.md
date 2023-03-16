---
title: Deploy on Friday! (DevOps best practices)
description: Why not? Learn the best practices from organizations ready to Deploy on Fridays through real-world examples.
tags:
  - devops
  - deploy
  - rollback
  - monitoring
  - observability
  - culture
authorGithubAlias: mfpalla
authorName: Marcelo Palladino
date: 2023-03-15
---

Why not deploy on friday? During my career, I accepted that we didn't deploy on Fridays (or on holiday eves, New Year's Eve, or any other date considered "important") simply because it was **too risky**. Everything seemed to make sense because **I was afraid every time we deployed** , the users felt the problems, **which returned to the team in the form of bugs** , the most experienced people on the team said that it was risky and, many times, the management people **prohibited Deploying** on specific dates, unless it was to put out a fire.

After a while, I understood the value of asking and understanding the "why" and, mainly, the "why not" of each thing.

- Can someone be with us overnight to follow the Deploy?
- Can someone follow the Deploy on Sunday?
- Nobody Deploys on Fridays, agreed?
- We will hold the Deploy process during the last two weeks of the year.
- We will upload all changes accumulated during the first week of January.
- Holiday tomorrow. No Deploys, PLEASE!
- Nobody does Deploy because John had a particular problem and won't be able to accompany us, ok?
- Our biggest customer, PallaCode4Fun, has requested that we do not do any Deploys for the next week.

For each situation, the answers to the "why?" or "why not?" evidence a lack of **technical** capabilities, well-established **processes** , **measurement/evaluation** capabilities, and **cultural** capabilities.

Actions related to these capabilities aim to **mitigate risks** and, as a consequence, reduce the **fear of Deploy** and increase organizational performance. Technical capabilities are by far the most exploited by organizations, especially in the early stages of DevOps adoption. It is possible to invest in automation of the Deploy process to mitigate risks during Deploy, for example. However, if the culture is not aligned or if there is not good communication between people on the teams, it is unlikely that the investment will impact the organization's performance in the long term.

The **fear of Deploy** and its consequences for people and organizations is fundamentally based on **uncertainty** and **lack of knowledge**. By embracing the DevOps culture, organizations must invest in technical capabilities, promote knowledge creation, and develop people and processes to combat uncertainty and lack of knowledge.

In this article, I will share examples of what should be avoided and practices to mitigate the risks and reduce the pain in the Deploy process, which requires technical, cultural, and process capabilities of organizations ready to Deploy on Fridays.

## Keep independent teams

I've heard of a recurring meeting where the goal was to define the order in which teams would make changes to services and the order to deploy in subsequent weeks. It was a synchronization and coordination meeting between the teams, as the structure of the software in relation to the organizational structure did not allow the teams to work independently. To make it worse, some services had yet to be defined owners.

Deploy processes that require synchronization and coordination activities must be identified and avoided, as they slow down teams and increase management costs. In addition, every service must have well-defined owners to avoid the diffusion of responsibility during its life cycle.

## Identify and avoid coupling

It's like a fisherman's story, but it's true, I swear! I once had to coordinate the Deploy of more than 20 services to production only because I added an element to an enumeration in one of those services. There were more than 20 pull requests in different teams and the order was important. A complete nightmare! A change that should have taken a morning took weeks to complete!

That coupling and technical debt issue took a heavy toll and was a source of pain in the Deploy process. We could never do that Deploy on a Friday.

Mapping the coupling (sometimes coupling is inevitable) and identifying the costs related is an activity that must be done continuously, to allow the analysis of cheaper ways of coupling and the design of solutions that avoid and reduce the coupling.

[In this video](https://www.youtube.com/watch?v=esm-1QXtA2Q), Michael Nygard does an excellent job, as always, sharing concepts about coupling, especially considering its inevitability.

## Work in small batches deployed regularly

A team I worked on wasted two weeks trying to stabilize software in January after a release freeze between Christmas and New Year's. The launch freeze was a request from the business area to minimize the risk of customers experiencing a service interruption during such as they said an important time of the year.

January of that year was not a good start to the year for the team and neither for the customers. The business area discovered that there was no single time of year for the customers. The planning for that quarter was compromised due to the unexpected workload, and job satisfaction dropped dramatically during that period.

It's a great example of how **neglecting the technical aspects** of software delivery leads to a **deterioration in the team's ability to evolve the software**.

There is no silver bullet regarding increasing reliability in the Deploy process. However, working in small batches, deployed frequently, rather than large batches, with scheduled deployment is one of the practices that most contribute to reducing Deploy risk.

## Use trunk-based development

Have you ever encountered a repository where it's difficult to determine which branch is in production? I can't remember anything that caused me more uncertainty than the repository for a critical service with multiple open branches that, in theory, were ready for production but which contained several commits not yet deployed.

The main branch of a project should always be in a production-ready state, and the **number of commits undeployed in the main branch should be kept to a minimum**. A code merged into the main branch must have been reviewed, statically analyzed, and tested in an automated way, as we will see next. Furthermore, this code should go to production continuously as quickly as possible with little or no manual intervention. If there are feature branches, they should be removed as part of the merge/deploy process.

[Clare Liguori](https://aws.amazon.com/builders-library/authors/clare-liguori/) addressed this topic in [her article](https://aws.amazon.com/builders-library/cicd-pipeline/) on how Amazon stopped using the release captain role. The article is an excellent story, and it is interesting to note the role that trunk-based development played at that time.

## Encourage thoughtful code reviews

Some of my best learning experiences have come through rigorous code reviews. I can't remember how many times we discovered significant issues during the code review process. Code reviews minimize risk, decrease the uncertainty, improve quality, enable knowledge sharing, and encourage consistent design. They allow people who know more to demonstrate this in practice, transferring tacit knowledge through socialization.

The high bar in the code review has a nice side effect of forcing pull requests to contain good descriptions and comments explaining why the changes are made and describing the expected side effects, if any.

It's an example of a process that depends on a well-established feedback culture in the organization. For instance, team members should feel comfortable denying a large pull request, or pull requests with multiple objectives. No egos are wanted here. People should know the fine line between objectivity and subjectivity and respect personal preferences over their biases about how they would do something. Code reviews should use positive language and focus on knowledge sharing, but they should be thoughtful and technically rigorous.

**Code should only go into production after going through a rigorous review process.**

## Automate deployment processes

I heard about a document created by a development team that basically consisted of a series of manual steps that the operations team should perform as part of the Deploy process. Just imagine the friction of this operation. Now consider the differences between the environments and add a dash of cultural issues. Imagine doing a Deploy like that on Fridays?

**Ideally, there should be no latency involved in the Deploy process, resulting from technical aspects or manual interventions.**

Once a code has been reviewed, the merge to the main branch must trigger the CI/CD pipeline, which must build the software, run automated tests, run static code analysis, run lint checks, apply quality gateways, run security checks, deploy the service to the pre-production environment, run post-deployment tests, and ultimately deploy to production.

[Mark Mansour](https://aws.amazon.com/builders-library/authors/mark-mansour/) wrote about [accelerating with continuous delivery](https://aws.amazon.com/builders-library/going-faster-with-continuous-delivery/) at Amazon and the positive aspects of the practice for the customers and business. In his words "For us, automation is the only way we could have continued to grow our business".

## Rely on reliable automated tests

I once worked on a team whose tests were performed exclusively by people, and the software only went into production after going through one or more people who carried out tests and manual inspections. They are the most well-meaning, stressed-out people I've ever worked with during my career.

In addition to **team burnout** , this job doesn't work because, despite any good intentions, people are not good at performing repetitive tasks. Add to this the fact that the need for changes increases as software becomes relevant. Given the increasing complexity, we have a scenario that makes it difficult to predict the impact of changes through manual testing.

Automated tests running continuously decrease the possibility that changes will negatively impact the software and are vital to increasing confidence in the Deploy process and decreasing Deploy pain.

## Reduce risk using feature flags

Continuously delivering software gradually often means putting incomplete software into production. This way, rather than working in long-term branches until the software is complete, teams should be able to bring software into production piecemeal and control its visibility or impact through features flags. This technique helps teams to work in small batches with low risk.

Sometimes it is desirable to enable certain functionality for a small group of users. This capability is handy to allow teams to quickly learn from users, observe the application and business metrics, and monitor the impact of changes for a small population, reducing risk and reducing the pain in the Deploy process.

In [this video](https://www.youtube.com/watch?v=uouw9QxVrE8) from AWS re:Invent 2022, you can follow Sébastien Stormacq and Olivier Leplus demonstrating how AWS has been using this technique for over a decade and how you can introduce feature flags into your applications.

## Reduce risk using deploy strategies

8 am, the time most of our clients start their operations. I worked in a company as a software engineer, and we've just deployed a critical change to the authentication process for our entire user base. We're happy to finally ship that change, as it was a technical debt payment that will make the software more secure while removing afferent coupling that has long taken us a toll.

8:10 am. No user can authenticate. Chaos is raging in support, and some of the most influential customers directly call the business people (including CTO and CIO). This story is longer than that, but the prologue is this, and it happened. I remember that time and the pain well. It was a nightmare, and a perfect example of how a Deploy made for a reduced number of users (canary release) would have mitigated the Deploy risk, caused less pain, and preserved the organization's reputation. Organizations ready to Deploy on Fridays master the ability to deploy to a small number of users, such as allowing changes to be monitored and observed with low risk, before they impact the entire user base.

## Ensure software is easy to monitor and observe

I heard about a role in an operations team whose primary assignment was to create monitoring dashboards and send messages on the internal communicator to the development teams when something was not right in the view of the person in charge of observing the dashboards. It was something like, "Guys, CPU is at 70%. Do we have a problem here?" It is another edge case (in the real world) highlighting the lack of measurement/evaluation capacity and latent cultural problems.

Despite all the best practices that can be done before Deployment, it is inevitable that, at some point, things will go wrong. At these times, it is necessary for the teams that own the affected services to be activated directly through alarms. Alarms should be tangible from a business perspective rather than just based on infrastructure metrics like CPU and memory. Complex processes can be associated with hundreds of software/hardware components. Good monitoring abstracts complexity in the form of **stability indices** , which are used as the basis for monitoring and alarms.

Each alarm must have an associated playbook, and each playbook may cite one or more tutorials and reference pages. One suggestion is to use the [documentation quadrant](https://www.thoughtworks.com/en-br/radar/techniques/documentation-quadrants) to connect the documentation artifacts so that they are not forgotten and that their consumption is oriented according to some logic. Defining a playbook for an alarm is a way to link documentation from the end to the beginning and an opportunity to transfer tacit knowledge.

In addition to actionable alarms, teams must be able to observe the software **without friction and intermediaries**. Monitoring dashboards with service metrics, business metrics, centralized and structured logs, and traces (including distributed when it makes sense) are essential. The software must be observable, and there must be how-to guides that show how to observe it. The main idea here is that no matter how inexperienced a firefighter is in a given context, it should be able to start fighting the fire, following steps and using the right tools for each case.

## Things will go wrong: Rollback must be possible

Even in applications that follow best practices in organizations ready to Deploy on Fridays, in certain circumstances, there will be unexpected behavior in production, where the only option to re-establish operation will be to rollback the deployment.

To reduce the pain in Deploy, the team must have this technical capacity well developed so that there is the certainty that the reversal of the implantation will not cause more problems for the users. **The software version being deployed must be backward compatible.**

I recommend reading [Sandeep Pokkunuri's](https://aws.amazon.com/builders-library/) excellent article on [ensuring rollback safety during deployments](https://aws.amazon.com/builders-library/ensuring-rollback-safety-during-deployments/) to delve deeper into this subject.

## Conclusion and a note on Heroism

When I started writing this article, I thought of using my own experiences as a consultant and individual contributor to list practices based on the DevOps pillars that I saw as helpful in my day-to-day life as a developer, allowing teams to innovate more quickly and at less risk. This article started with a question. The most productive teams I've ever had the opportunity to work on were those that allowed themselves to question the status quo of their work and environment regularly.

The DevOps pillars provide an excellent way for organizations to set clear directions while building their **technical, cultural, and process capabilities**.

Finally, I want to pay special attention to something I call heroism. **Nothing corrupts the DevOps culture in an organization more than heroism.** A hero does not share information, has difficulty transferring knowledge through socialization, and does not create opportunities for the people around. A hero is only there to be called upon to save the day, whatever its activity. I have spoken a lot about this topic in my presentations in Brazil, and I am surprised by the number of people who say they work with "heroes" in their organizations and identify with the negative aspects of heroism.

Numerous practices can be used to combat heroism, such as pair programming, group programming, monitoring review meetings, game days, group whiteboard sessions, and more. An organization ready to Deploy on Fridays understands that team culture and environment matter more than individual skill. By embracing DevOps culture and encouraging practices that maximize knowledge sharing, **the organization fights heroism in favor of empowered and autonomous teams**.