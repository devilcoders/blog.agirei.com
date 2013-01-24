---
kind: article
title: "Holistic Deployment"
created_at: 2011-02-09 02:14
categories:
  - agile
  - deployment
author_name: Piotr Zolnierek
---
Your agile team has built great software, only to find out it cannot work in production?  

Agile has taken the development community by storm. It has improved our everyday lives. It enables us to build great working software in all kinds of environments.
But for many companies, covering the last mile, bringing an application into production is the biggest obstacle to being truly agile. 
Prescribed processes and skill-sets in operations lag behind a decade.
We have created cross-functional teams, excluding one of the most important aspects of of software - it needs to run in production! 

<!-- more -->

### The Problem
Devs become quicker in delivering releases and new customer value.  
Ops cannot release as often as Devs.  

Devs don't know or understand production infrastructure.  
Devs develop software that _works on my machine_.  

Ops don't do TDD, don't automate. Our sysadmins, cannot write code (messy bash scripts is about the max).  
Ops needs days or even weeks to deploy something to production, because of their own queuing.

Separating Dev and Ops creates a waterfall. If anything breaks, the feedback cycle is long!  

### Conflict of interests
Devs and Ops have been created in most organizations to fulfill a separate role. Devs are designed for change. Ops are designed for preservation.
As the organization matures, each department evolves into it's own direction and have their own goals, sometimes forgetting they both serve the same purpose.

Product Owners want new value asap - on production - that's understood.  
Developers want to release more often.  
Ops want high availability, stability, reliability.

Both Devs and Ops, from their perspective, want the best for the business.
Only, optimizing any subsystem without context, leads to the destabilization of the system as a whole, de facto decreasing overall performance.

Deployment is complex, high risk, error prone and thus holds a risk of destabilization.

### Anti-Patterns
The reasons why Ops departments were created - at least in our case - because there were some anti-patterns which deteriorated our quality and our reputation with customers.

 *  AdHoc Release - Devs would deploy as soon as they made quick fixes to the application.
 *  Production Patching - Sysadmins change configs and other parts directly on production, nobody knows what they changed
 *  Service Monolith - the apps are not modular enough or not modular the way and nobody understood how they work together.
 *  Lack of Automation - the whole deploy process was done manually, every time!
 

### What we need to focus on
It is **not** about bringing agile practices to operations, this is a must anyway. Although Kanban is ideal for that kind of endeavor, 
we do not want only to copy-paste our practices to another department.  

We need to focus on the right effort. We are all connected by one purpose, 
we all need to take have the right mindset to work together on a product as a whole to provide a tremendous customer service.

Thus we need all to keep in mind what is most important:

1. Business Value 
2. Predictability, Repeatable processes
3. Stability, Uptime

### About DevOps
The Devops movement has done a good job to bring out, many of the pain-points of the current sysadmin vs developer silo situation. 
I have been hoping, that admins and ops will someday understand, that they must do more than install software, hardware and search logs.

I kind of like the word Devops.  
To me it means that sysadmins will be more like developers, adhere to the high standards of developers which have evolved over the last years with xp and agile.
It means to me that automated installation will bring us an repeatable process. No repeating mistakes. Identical production servers. No exceptions. 
Setting up new machines will be easy fast thing as bringing new functionality to the software.  
Current Sysadmins must understand, they are like 32bit hardware, to be retired in the near future, unless they adapt and upgrade themselves!

On the other hand, developers must fully acknowledge, that their software is only  if it works in production. 
The Definition of Done has to be extended to "Running of Production". Every sprint.

### Duties
Let's have a look at the responsibilities of our two parties.
Despite that Devops want to include QA into their new movement, 
I will argue that QA is a duty of both Devs and Ops anyway and thus not talk further about it (either it works or it doesn't).

Let's have a look at the duties of the different roles in an organization like mine - [anixe](http://www.anixe.pl)
- where we develop software for e-commerce to run our customers businesses.

Duties of Sysadmins:

 * Systems &amp; Applications Administration
 * Infrastructure Management

Duties of Ops:

 * 24&times;7 Tech Support
 * Deployment
 * Testing &amp; Quality Assurance (QA)

Duties of Dev:

 * Builds &amp; Configuration
 * Release Management
 * Testing &amp; Quality Assurance (QA)
 * Technical Analysis
 * Technical Project Management

What's wrong with this picture?

Sysadmins are responsible for Applications - how could they, if they haven't built them (just assume changes happen fast)  
Ops are responsible for deployment - cool, but if it doesn't work, they're helpless without Devs assistance  
Ops are responsible for Testing - ouch - again, they need to be taught what to test and testing and building is not happening in the same iteration  
Devs don't know what's going on on production  

### Possible Solution for a harmonious together
This is not just one possible solution, there are others as well, but here is a temporary one we might want to try.
In __this__ context, Ops are sysadmins, the rest of Ops should be part of the agile development teams anyway. I just don't see how we could integrate admins, which are specialist and only required "rarely" once a platform is up and running.

Ops provide a cloud-like environment. 
Devs deploy to a transparent cloud-like environment. Devs are responsible for deployment to production!

Cloud-like means, every machine deployed to must be same-same, no matter whether it's test, staging or production.

Ops use an automated, repeatable process for system installation. This means coding skills are required by __every__ team member.
The same clean code, versioning and other practices must be by every team member.

Continuous integration, build, deployment.

Requirements:

 *  all environments are guaranteed to be identical
 *  Devs have _reasonable_ access to the infrastructure
 *  Personal User data must be protected and inaccessible

### How far have we come?
Here at [anixe](http://www.anixe.pl), our current workflow looks as follows. 

 *  Devs develop software, it is unit and integration tested
 *  One some projects: Admins deploy prebuilt packages including the configuration for the target environment. NO manual editing of config files is allowed, every config for every environment is under source control.
  All applications config files are the same. Differences per platform are in a separate configuration file. Database schema changes are bundled in the deploy and run automatically.
  We haven't figured out how to do automatic data migrations, yet.
 *  On other projects: Ops run an automated deploy script (home-made for .net applications), which takes care of everything, handles backups, rollbacks, etc. 
 *  On ruby projects:  We use currently capistrano and Devs deploy themselves. We use here mongo as database, so deployment is easy.
 *  Ops verify if everything went smoothly and notify customers about the outcome
 *  For linux deployments are preparing an installer using [babushka](http://babushka.me), which does test-driven-sysadmin installation.

Generally linux deployment is so much easier, a fully automated and test driven platform installation within a couple of days. The same on Windows took us over a month.

After the separation of Devs and Ops we have developed a new anti-pattern which is over the wall deployment. Devs deliver packages and let Ops do the rest.

Now as we are approaching a new age of automation of deployment, we currently face another anti-pattern, and that is that everybody in the organization wants to use their own set of tools. 
Some use dos-batch programs, some use VB scripts, some bash scripts and so on.

### References
[Agile IT: A Better Approach to Application Development, Deployment, and Management](http://www.enterprisemanagement.com/research/asset.php?id=1569)  
[I Don't Want DevOps. I Want NoOps.](http://blogs.forrester.com/mike_gualtieri/11-02-07-i_dont_want_devops_i_want_noops)  
[What is DevOps?](http://dev2ops.org/blog/2010/2/22/what-is-devops.html)
[The Rise of DevOps](http://somic.org/2010/03/02/the-rise-of-devops/)  
[Organizing a Web Technology Department](http://www.rajiv.com/blog/2009/03/17/technology-department/)
[What DevOps means to me&hellip;](http://www.kartar.net/2010/02/what-devops-means-to-me/)  
[What Is This Devops Thing, Anyway?](http://www.jedi.be/blog/2010/02/12/what-is-this-devops-thing-anyway/)  
[Agile isn't just an application development method](http://www.computerworlduk.com/in-depth/applications/2792/agile-isnt-just-an-application-development-method/)  
[AGILE MANIFESTO CO-AUTHOR ENCOURAGES AGILE OPERATIONS](http://agileoperations.net/index.php?/archives/20-Agile-Manifesto-co-author-encourages-Agile-Operations.html)  
[Deployment management design patterns for DevOps](http://dev2ops.org/blog/2010/2/18/deployment-management-design-patterns-for-devops.html)
[Wikipedia on Devops](http://en.wikipedia.org/wiki/DevOps)

