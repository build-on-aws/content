---
title: "12 DevOps Best Practices That Make Deploying on Fridays Less Scary"
description: Why not deploy on Fridays? These 12 best practices, each with real-world examples, will help you understand how DevOps culture and practices can collaborate to mitigate risk and reduce the pain of deployment, making it less risky.
tags:
  - devops
authorGithubAlias: mfpalla
authorName: Marcelo Palladino
date: 2023-03-15
---

Why not deploy on a Friday? During my career, I accepted that we didn't deploy on Fridays -- or the day before any "important" day. It makes sense: you don't want your application to break when use will be high and no one is around to fix it. But the longer I worked in some technical and cultural capacities, the clearer it became that the risk of deploying on Fridays was significantly higher because of certain bad Devops practices. Look, deploying code always entails the risk of availability loss, but that risk can be significantly diminished by adopting these 12 best practices.

## Maintain independence between teams

I've been dismayed to see cases where a recurring meeting was required, where the goal was to define the order in which teams would make changes to services and the order to deploy. This happens when the structure of the software in relation to the organizational structure do not allow the teams to work independently.  

Deploy processes that require synchronization and coordination activities must be identified and avoided, as they slow down teams and increase management costs. 

You can learn about real-world teams that enabled independent deployment in a multi-service application reading the Seth Eliot's [article](https://www.buildon.aws/posts/how-amazon-does-devops-in-real-life/). Also, depending on your age, this may be the first time you've heard about pager.

## Identify and avoid coupling

I once had to coordinate the deploy of more than 20 services to production only because I added an element to an enumeration in one of those services. There were more than 20 pull requests in different teams and the order was important. A change that should have taken a morning took weeks to complete.

That coupling and technical debt issue took a heavy toll and was a source of pain in the deploy process. 

Mapping the coupling (even when it's inevitable), and identifying the costs related, is an activity that must be done continuously. This allows the team to be aware of the problem and build solutions to reduce and avoid coupling when possible.

[In this video](https://www.youtube.com/watch?v=esm-1QXtA2Q), Michael Nygard does an excellent job, as always, of sharing concepts about coupling, especially considering its inevitability.

## Work in small batches deployed regularly

A team I worked on wasted two weeks trying to stabilize software in January after a release freeze during December. The launch freeze was a request from the management team to minimize the risk of customers experiencing a service interruption during such, as they said, an "important time" of the year (Christmas and New Year's).

That January was not a good start to the year for the team and neither for the customers. There were so many service disruptions, the planning for that quarter was compromised due to the unexpected workload, and job satisfaction dropped dramatically during that period.

There is no silver bullet regarding increasing reliability in the deployment process. However, working in small batches, deployed frequently, rather than large batches, with scheduled deployment is one of the practices that most contribute to reducing risk, since the smaller the amount of changes, it is easier to map, understand and monitor the possible side effects.

## Use trunk-based development

Have you ever encountered a repository where it's difficult to determine which branch is in production? I can't remember anything that caused me more uncertainty than the repository for a critical service with multiple open branches that, in theory, were ready for production but which contained several commits not yet deployed.

The main branch of a project should always be in a production-ready state. A code merged into the main branch must have been reviewed, statically analyzed, and tested in an automated way, as we will see next. Furthermore, this code should go to production continuously as quickly as possible with little or no manual intervention. If there are feature branches, they should be removed as part of the merge/deploy process.

Clare Liguori addressed this topic in [her article](https://aws.amazon.com/builders-library/cicd-pipeline/) on how Amazon stopped using the release captain role, who was responsible for coordinating the release of code changes for their team’s services and deploying the release to production. It is interesting to note how trunk-based development enabled the improvement of technical capabilities and processes to achieve the objective.

## Encourage thoughtful code reviews

Some of my best learning experiences have come through rigorous code reviews. I can't remember how many times we discovered significant issues during the code review process. Code reviews minimize risk, decrease the uncertainty, improve quality, enable knowledge sharing, and encourage consistent design. They allow people who know more to demonstrate this in practice, transferring tacit knowledge through socialization. Code reviews do take time, and some teams avoid them as a result. But they save time in the long run by ensuring higher quality deployments, fewer rollbacks, and preserving the organization's reputation. 

The high bar in the code review has a nice side effect of forcing pull requests to contain good descriptions and comments explaining why the changes are made and describing the expected side effects, if any. It's an example of a process that depends on a well-established feedback culture in the organization. For instance, team members should feel comfortable denying a large pull request, or pull requests with multiple objectives. No egos are wanted here. **People should know the fine line between objectivity and subjectivity and respect personal preferences over their biases about how they would do something.** Code reviews should use positive language and focus on knowledge sharing, but they should be thoughtful and technically rigorous.

Code should only go into production after going through a rigorous review process.

## Automate deployment processes

I heard about a document created by a development team that basically consisted of a series of manual steps that the operations team should perform to do the entire deployment process. Just imagine the friction of this operation. Now consider the differences between environments and add in a dash of cultural issues. Very, very risky. It doesn't matter if it's Friday or not.

Depending on the case, it is acceptable to have some runbook to do some task during the deployment process. However, ideally, there should be no latency involved in the deploy process, resulting from technical aspects or manual interventions.

Once code has been reviewed, the merge to the main branch must trigger the CI/CD pipeline, which must build the software, run automated tests, run static code analysis, run lint checks, apply quality gateways, run security checks, deploy the service to the pre-production environment, run post-deployment tests, and ultimately deploy to production.

Mark Mansour wrote about [accelerating with continuous delivery](https://aws.amazon.com/builders-library/going-faster-with-continuous-delivery/) at Amazon and the positive aspects of the practice for the customers and business. In his words "For us, automation is the only way we could have continued to grow our business".

## Build reliable automated tests

I once worked on a team whose tests were performed exclusively by people, and the software only went into production after going through one or more people who carried out tests and manual inspections. They were the most well-meaning, stressed-out people I've ever worked with during all my career.

In addition to team burnout, this job doesn't work because, despite any good intentions, people are not good at performing repetitive tasks. Add to this the fact that the need for changes increases as software becomes relevant, increasing complexity, we have a scenario that makes it difficult to predict the impact of changes through manual testing.

Automated tests running continuously decrease the possibility that changes will negatively impact the software and are vital to increasing confidence and decreasing pain in the deployment process.

## Reduce risk using feature flags

Continuously delivering software gradually often means putting incomplete software into production. This way, rather than working in long-term branches until the software is complete, teams should be able to bring software into production little by little and control its visibility or impact through features flags. This technique helps teams to work in small batches with low risk.

Sometimes it is desirable to enable certain functionality for a small group of users. This capability is handy to allow teams to quickly learn from users, observe the application and business metrics, and monitor the impact of changes for a small population, reducing risk and pain in the deployment process.

In [this video](https://www.youtube.com/watch?v=uouw9QxVrE8) from AWS re:Invent 2022, you can follow Sébastien Stormacq and Olivier Leplus demonstrating how AWS has been using this technique for over a decade and how you can introduce feature flags into your applications.

## Reduce risk using canary releases

8 am, the time most of our clients start their operations. I am a software engineer and we've just deployed a critical change to our entire user base. We're happy to finally ship it, as it is a technical debt payment that will make the software better by removing afferent coupling that has long taken us a high toll.

8:10 am. No user can use the platform. Long story short: chaos is raging in support, and some of the most influential customers directly call the business people (including CTO and CIO). It is a nightmare, and a perfect example of how a deploy made for a reduced number of users would have mitigated the deployment risk, caused less pain, and preserved the organization's reputation.

A canary release is a deployment strategy that allows teams release changes to a reduced number of users.
Using this strategy, the team can deploy the new version incrementally, slowly making it visible to new users. This allows gain confidence in the deployment, allowing changes to be monitored and observed with low risk, before they impact the entire user base.

Organizations "ready to deploy on Fridays" master the ability to deploy to a small number of users. 

## Ensure software is easy to monitor and observe

I heard about a role in an operations team whose primary assignment was to create monitoring dashboards and send messages on the internal communicator to the development teams when something was not right in the view of the person in charge of observing the dashboards. It was something like, "Folks, CPU is at 70%. Do we have any problem here?" It is another edge case  highlighting the lack of measurement/evaluation capacity and latent cultural problems.

Despite all the best practices that can be done before deploying, it is inevitable that, at some point, things will go wrong. At these times, it's necessary for the teams that own the affected services to be activated directly through alarms. Alarms should be tangible from a business perspective rather than just based on infrastructure metrics like CPU and memory. Complex processes can be associated with hundreds of software/hardware components. Good monitoring abstracts complexity in the form of **stability indices**, which are used as the basis for monitoring and alarms.

Each alarm must have an associated playbook, and each playbook may link one or more tutorials and reference pages. One suggestion I have is to use the [documentation quadrant](https://www.thoughtworks.com/en-br/radar/techniques/documentation-quadrants) to connect the documentation artifacts so that they are not forgotten, easy to find, and that their consumption is oriented according to some logic. Defining a playbook for an alarm is a way to link documentation from the end to the beginning and an opportunity to transfer tacit knowledge.

In addition to actionable alarms, teams must be able to observe the software without friction and intermediaries. Monitoring dashboards with application metrics, business metrics, centralized and structured logs, and traces (including distributed when it makes sense) are essential. The software must be observable, and there must be how-to guides that show how to observe it. The main idea here is that **no matter how inexperienced a firefighter is in a given context, it should be able to start fighting the fire, following steps and using the right tools.**

## Things will go wrong

Even in applications and organizations that follow best practices, in certain circumstances, there will be unexpected behavior in production, where the only option to re-establish operations will be to roll back the deployment.

The team must be able to clearly identify that the reversal will not cause more problems for users. This technical capability should be developed as much as the capability to deployment. 

I recommend reading Sandeep Pokkunuri's article on [ensuring rollback safety during deployments](https://aws.amazon.com/builders-library/ensuring-rollback-safety-during-deployments/) to delve deeper into this subject.

## Identify and avoid heroism

I want to pay special attention to something I call heroism. **Nothing corrupts the DevOps culture in an organization more than heroism.**

A hero does not share information, has difficulty transferring knowledge through socialization, and does not create opportunities for the people around. A hero is only there to be called upon to save the day, whatever their activity. I have spoken a lot about this topic in my presentations in Brazil, and I am surprised by the number of people who say they work with "heroes" in their organizations and who identify with the negative aspects of heroism.

Numerous practices can be applied to avoid heroism, such as pair programming, MOB programming, monitoring review meetings, game days, group whiteboard sessions, and more. An organization "ready to deploy on Fridays" understands that team culture and environment matter more than individual skill. By embracing DevOps culture and encouraging practices that maximize knowledge sharing, the organization fights heroism in favor of empowered and autonomous teams.

## Conclusion

These best practices will help you avoid pain points that DevOps teams often encounter, but the most fundamental takeaway is that your team has a culture of free inquiry - that everyone feels the freedom to ask simple questions about the process. Ensure that your team has room to question. The most productive teams are those that allowed themselves to question the status quo of their work and environment regularly.

If you're interested in DevOps and want to learn more about how to implement it, check out these articles about it.

- [How to Succeed at DevOps: Wrong Answers Only!](https://www.buildon.aws/posts/devops-wrong-answers-only)
- [Big Trucks, Jackie Chan movies, and millions of cardboard boxes: How Amazon Does DevOps in Real Life](https://www.buildon.aws/posts/how-amazon-does-devops-in-real-life)
- [My CI/CD pipeline is my release captain](https://aws.amazon.com/builders-library/cicd-pipeline/)
- [Going faster with continuous delivery](https://aws.amazon.com/builders-library/going-faster-with-continuous-delivery/)