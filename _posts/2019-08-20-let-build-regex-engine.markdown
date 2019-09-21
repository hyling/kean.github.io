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
> - [Regex, Part 3: Compiler]({{ site.url }}/post/regex-compiler)
> - Regex, Part 4: Matcher

## Regular Expressions

Regular expression patterns can be as simple as "[`https?`](https://regex101.com/r/z6Lypq/1)" where "`?`" is a Zero or One [Quantifier](https://docs.microsoft.com/en-us/dotnet/standard/base-types/quantifiers-in-regular-expressions) and which matches either `http` or `https`. Or as complex as [this](https://regex101.com/r/95Clhd/1), which supposedly validates an email address, I think:

```
((?:[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*|"(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21\x23-\x5b\x5d-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])*")@(?:(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\[(?:a(?:(2(5[0-5]|[0-4][0-9])|1[0-9][0-9]|[1-9]?[0-9]))\.){3}(?:(2(5[0-5]|[0-4][0-9])|1[0-9][0-9]|[1-9]?[0-9])|[a-z0-9-]*[a-z0-9]:(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21-\x5a\x53-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])+)\])
```

Implementing an engine capable of matching patterns like "`https?`" is easy because you can cut corners. Building one that supports the majority of the features of a modern regex engine is not.

> [**Quick Reference**](https://docs.microsoft.com/en-us/dotnet/standard/base-types/regular-expression-language-quick-reference)
>
> If you are not familiar with regex or need a refresher, I would highly recommend going through this [Quick Reference](https://docs.microsoft.com/en-us/dotnet/standard/base-types/regular-expression-language-quick-reference) or any other tutorial on the subject. There is going to be no introduction into regex in this series! Make sure you are familiar with the basics (character classes, quantifiers, groups) before you continue.

To make it more challenging, I also wanted it to have performance comparable to `NSRegularExpression` which uses [ICU regex engine](http://icu-project.org/apiref/icu4c/uregex_8h_source.html) under the hood. This engine is written in C and is highly optimized.

Do you want to see how it turned out? Take a red pill and I'll show you how deep the rabbit hole goes.

## Overview

There are three main pieces of the puzzle that needs to be solved to make it all work.

### Grammar

Before writing a parser for a regular expression *language*, one needs to define the rules of the language, or *grammar*. This is what [**Regex, Part 1: Grammar**]({{ site.url }}/post/regex-grammar) is about. There will be theory. If you want to jump straight to the good stuff, you can skip it. But there are some concepts introduced in this part which will make it easier to understand the remaining parts.

### Parser

Regular expressions have complicated syntax with many constructs, including recursive ones, like [Capture Groups](https://docs.microsoft.com/en-us/dotnet/standard/base-types/grouping-constructs-in-regular-expressions). The pattern itself is just a raw string. To reason about it, you first need to parse it and create an abstract representation which you can easily manipulate – an [abstract syntax tree](https://en.wikipedia.org/wiki/Abstract_syntax_tree) (AST). [**Regex, Part 2: Parser**]({{ site.url }}/post/regex-parser) will be about parsing regex patterns using Parser Combinators (or *monadic* parsers).

### Compiler

You have an AST, now what? Turns out, every regular expression pattern can be represented using [Finite State Automation](https://en.wikipedia.org/wiki/Nondeterministic_finite_automaton). [**Regex, Part 3: Compiler**]({{ site.url }}/post/regex-compiler) will explain the concept and show how to use it.

### Matcher

Let's say you figured out how to parse the pattern, created an AST, and compiled it into a state machine. You have an initial state and a set of transitions from it. How do you execute it against an input string?

Writing a matcher turned out to be the most challenging part. What if the input has 50000 lines of text? What if the expression has nested groups, alternations and quantifiers? What if there are multiple cycles in a state machine? How do you capture groups? What if there are multiple potential matches? How to debug it? How to optimize it? There are many interesting problems to solve, and we will solve them in **Regex, Part 4: Matcher**, the final article in the series.

## What's Next

I hope I got you excited! I think this series is going to be fun and useful, especially if you either don't have a formal CS education or want a refresher. Or maybe you would like to see the concepts you had learned utilized to solve a challenging real world problem.

The implementation is [available on GitHub](https://github.com/kean/Regex).

<div class="Any-vertInsets">
<a href="{{ site.url }}/post/regex-grammar">
  <div class="PrimaryButton">
    Continue Reading »
  </div>
</a>
</div>
