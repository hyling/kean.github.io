---
layout: post
title: "Continuous Integration for Open Source Projects"
description: TBD
date: 2019-11-13 10:00:00 -0500
category: programming
tags: programming
permalink: /post/ci-for-frameworks
uuid: 3826c7ed-4ede-4eee-bbde-69fa0e4e96a5
---

I created my first [framework](https://github.com/kean/DFCache) in 2014. It supported one platform, one package manager, and initially had no unit tests. The latest [Nuke](https://github.com/kean/Nuke) version, on the other hand, supports all four major Apple platforms, three package managers, and multiple major Xcode and Swift versions.

Working on an open-source framework posses a very different set of challenges compared to typical app development. Many frameworks are used by thousands of apps that rely on their quality. Yet there is no dedicated QA team. So how is possible to maintain quality? 

This is a story of how I went from manually testing my frameworks to having hundreds of unit tests and multiple automatic checks running on every change.

<img src="{{ site.url }}/images/posts/ci-for-oss/travis-ci.png">

## What is Continuous Integration

The answer to this question often depends on who you ask. For many people, continuous integration is primarily associated with the tools which enable it. However, the practice comes first.

<blockquote class="quotation">
<p>Continuous Integration is a software development practice where members of a team integrate their work frequently, usually each person integrates at least daily - leading to multiple integrations per day. Each integration is verified by an automated build (including test) to detect integration errors as quickly as possible.</p>
<a href="https://martinfowler.com/articles/continuousIntegration.html"><footer>Martin Fowler</footer></a>
</blockquote>

For me as a developer spending a lot of time working on apps in large (20+ people) and often distributed teams, continuous integration is primarily about the _people_ and the _practices_. It is a way to significantly reduce integration risks. When I think about continuous integration in that context, I think about practices like [trunk-based development]({{ site.url }}/post/trunk-based-development), feature-flags, avoiding long-running feature branches, concurrent development of concequitive releases, automating code reviews.

However, working on open-source frameworks posses a different set of challenges. There are no deadlines, no project resource utilizations, and, paradoxically, there are not a lot of people working on these projects. Take [Alamofire](https://github.com/Alamofire/Alamofire) for example, which is _the most popular_ open-source framework in the Apple ecosystem. Only [two people](https://github.com/Alamofire/Alamofire/graphs/contributors) doing the absolute majority of the work!

So for me as a developer of open-source frameworks, continuous integration is primarily about the tools. I want to be able to quickly test the changes that I make with as many automated tests as possible in as many different environments as possible, including different Xcode versions. In this article, I will primarily focus on the tools, not the practice.

## What Instrument to Choose

Jenkins provides flexibility and scalabiloty. It is also often used on premise.

- Choosing CI instrument
   - depends on what you are building
  - if it's a highly sensitiv codebase, e.g. a banking application, you might want to consider tools on-premise, have a CI team
- for a startup, a paid cloud-based solution can be aceptable
- for open source, I found Travis.CI to work perfectly

[GitHub Actions](https://github.com/features/actions). Some project already switched to it. The core principles are going to be the same.

## Travis.CI

TODO:

- Carthage comes pre-installed

## Jobs

- Infrastructure as Code
- One of the reasons is everything is a separate Job, I want to make it clear what validation failed. For example, a simple solution for SwiftLint would've been to use `swiftlint --strict`. Too slow feedback.
- This is important. Automation is fun, but at the end, it's a reviewer who approves the code. So you don't necessary have to make a binary yes/no decision. What you need to do is surface all of the needed information.
- Some of the ideas is surface changed to critical files. For example, Podfile.lock. Surface changes in unit test coverage (see Codecov).


# Outro

Quality, just like security, is not a binary decision. There are grades. 

 Delivering software is easy, what is hard is maintaining quality and velocity.

<div class="References" markdown="1">

## References

1. Marting Fowler, [**Continous Integration**](https://martinfowler.com/articles/continuousIntegration.html)
2. Paul Duvall, Steve Matyas, and Andrew Glover, [**Continuous Integration: Improving Software Quality and Reducing Risk
**](https://martinfowler.com/books/duvall.html)

<div class="FootnotesSection" markdown="1">

[^1]: TBD