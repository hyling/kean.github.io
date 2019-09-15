---
layout: post
title: Let's Build a Regex Engine
subtitle: How to understand the language of <code><\/?[\w\s]*>|<.+[\W]></code>
date: 2019-08-20 9:00:00 +0300
category: programming
tags: programming
permalink: /post/lets-build-regex
uuid: ea30401f-f344-4dcc-830c-d513e2f52193
---

> How to understand the language of <code><\/?[\w\s]*>|<.+[\W]></code>

Ever wondered how regex works under the hood? How does it understand an incantation like `"<\/?[\w\s]*>|<.+[\W]>"` and magically produces a desired result? This series is going to describe exactly how it works and how to implement a feature-rich regex engine.

Now you might be wondering, why would you want to do that? Well, turns out, this is a fantastic learning opportunity. Parsers, compilers, finite automation, graphs, trees, extended grapheme clusters - it has everything! Last but not least, you get a chance to learn regex.

> - [Let's Build a Regex Engine]({{ site.url }}/post/lets-build-regex) (This article)
> - [Regex, Part 1: Grammar]({{ site.url }}/post/regex-grammar)
> - [Regex, Part 2: Parser]({{ site.url }}/post/regex-parser)
> - Regex, Part 3: Compiler
> - Regex, Part 4: Matcher

## Regular Expressions

Regular expression patterns can be as simple as "[`https?`](https://regex101.com/r/z6Lypq/1)" where "`?`" is a Zero or One [Quantifier](https://docs.microsoft.com/en-us/dotnet/standard/base-types/quantifiers-in-regular-expressions) and which matches either `http` or `https`. Or as complex as [this](https://regex101.com/r/95Clhd/1) which supposedly validates an email address, I think:

```
((?:[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*|"(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21\x23-\x5b\x5d-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])*")@(?:(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\[(?:a(?:(2(5[0-5]|[0-4][0-9])|1[0-9][0-9]|[1-9]?[0-9]))\.){3}(?:(2(5[0-5]|[0-4][0-9])|1[0-9][0-9]|[1-9]?[0-9])|[a-z0-9-]*[a-z0-9]:(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21-\x5a\x53-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])+)\])
```

Implementing an engine capable of matching patterns like "`https?`" is easy because you can cut corners. Building one that supports the majority of the features of a modern regex engine is not.

> For a refresher on regex features and syntax check out [this quick reference](https://docs.microsoft.com/en-us/dotnet/standard/base-types/regular-expression-language-quick-reference).

To make it more challenging, I also wanted it to have performance comparable to `NSRegularExpression` which uses [ICU regex engine](http://icu-project.org/apiref/icu4c/uregex_8h_source.html) under the hood. This engine is written in C and is highly optimized.

Do you want to see how it turned out? Take a red pill and I'll show you how deep the rabbit hole goes.

## Overview

There are three main pieces of the puzzle that needs to be solved to make it all work.

### Parser

Regular expressions have complicated syntax with many constructs including recursive ones, like [Capture Groups](https://docs.microsoft.com/en-us/dotnet/standard/base-types/grouping-constructs-in-regular-expressions). The pattern itself is just a raw string. To reason about it, you first need to parse it and create an abstract representation which you can easily manipulate – an [abstract syntax tree](https://en.wikipedia.org/wiki/Abstract_syntax_tree) (AST).

Let's say you have a pattern like this, "`the ((red|blue) pill)`". We want to turn into this:

```swift
– Expression
  – String("the ")
  – Group(index: 1)
    – Expression
      – Group(index: 2)
        – Alternation
          – String("red")
          – String("blue")
      – String(" pill")
```

This is essentially what an abstract syntax tree is. Now this is something we can work with!

Let's also keep additional information around for debugging purposes. This way you will know which part of the pattern each construct represents:

```swift
– Expression ["the ((red|blue) pill)", 0..<21]
  – String("the ") ["the ", 0..<4]
  – Group(index: 1) ["((red|blue) pill)", 4..<21]
    – Expression ["(red|blue) pill", 5..<20]
      – Group(index: 2) ["(red|blue)", 5..<15]
        – Alternation ["red|blue", 6..<14]
          – String("red") ["red", 6..<9]
          – String("blue") ["blue", 10..<14]
      – String(" pill") [" pill", 15..<20]
```

The first part of the series is going to be focused on implementing this parser.

### Compiler

You have an AST, now what? Turns out, every regular expression can be represented using a [finite state machine](https://en.wikipedia.org/wiki/Nondeterministic_finite_automaton). If you are not familiar with state machines, in the simplest form it's a set of *states* and a set of possible *transitions* between them. A pattern like "`ab`" can be represented as a state machine with three states and two transitions:

```
     a        b
(1) ---> (2) ---> (3)
```

You start in state 1. If the next character in the input is "a", you transition to the state 2. Otherwise the input is not accepted, no match found. If the next character is "b", you reach the final, accepting, state 3. Pretty easy so far.

A pattern with a *zero or one* quantifier like "`a?`" is more complicated:

```
     a       
(1) ---> (2)
 |________^
     ε
```

There are now two transitions from state 1. You can reach the final, accepting, state 2 by either consuming character "a" or not consuming any input characters – a so-called *epsilon* transition. Basically, the entire regex is built on these few basic ideas\*.

> \* Unless you start talking about features like [*backreferences*](https://docs.microsoft.com/en-us/dotnet/standard/base-types/backreference-constructs-in-regular-expressions) which can't be represented using only conventional state machines. We will deal with them, but will focus on traditional regular expressions.

A lot of code programmers write every day could be implemented using state machines. But in practice, you rarely need *abstract* ones. You do to implement regex – it is not feasible to manually write a machine for every possible pattern, they should be generated by the engine.

The second part of the series is going to be about state machines and how to represent regex constructs using them.

### Matcher

Let's say you figured out how to parse the pattern, created an AST, and compiled it into a state machine. You have an initial state and a set of transitions from it. How do you execute it against an input string?

Writing a matcher turned out to be the most challenging part. What if the input has 50000 lines of text? What if the expression has nested groups, alternations and quantifiers? What if there are multiple cycles in a state machine? How do you capture groups? What if there are multiple potential matches? How to debug it\*? There are many interesting problems to solve.

> \* When you enter a state of a state machine, you need to be able to tell which part of the pattern it represents. You can do that by keeping "debug symbols" like what Xcode does for Swift code.

I started with a classic [backtracking algorithm](https://en.wikipedia.org/wiki/Backtracking), realized it had limitations and unpredictable performance with potentially exponential complexity, especially on large inputs. Then, I switched to an approach which executes all possible transitions in "parallel". Optimizing ARC turned out to be challenging. It has visible overhead and it's very hard to reason about. I had to drop down to SIL (Swift Intermediate Language) to make sure my changes had a desired effect. But I had a blast profiling and optimizing it!

## What's Next

I hope I got you excited! I think this series is going to be fun and useful, especially if you either don't have a formal CS education or you want a refresher. Or maybe you would like to see the concepts you had learned utilized to solve a challenging real world problem. I will keep it simple, focus on the core principles and how to apply them in practice.

The implementation is [available on GitHub](https://github.com/kean/Regex), and next articles will to appear soon.
