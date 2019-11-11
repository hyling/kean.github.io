---
layout: post
title: "SwiftUI Layout System: Bonus Article"
description: TBD
date: 2019-11-01 9:00:00 +0300
category: programming
tags: programming
tools: Xcode 11.2
permalink: /post/swiftui-layout-system-appendix
uuid: 7fe9a643-0373-4614-86c1-423db686fa71
---

In [the previous article]({{ site.url }}/post/swiftui-layout-system), I covered all of the basic things that you need to know about the SwiftUI layout system. If you missed it, I would recommend going through it first. But SwiftUI doesn't end there. There are a ton of fascinating new tools in the layout system. Want to know all about them? Then this article is for you.

## Discovery

The documentation for SwiftUI and the Apple documentation, in general, is [far from perfect](https://twitter.com/mattt/status/1185234430425628672?ref_src=twsrc%5Etfw). However, there are things that I like about SwiftUI documentation.

First, Apple put a lot of effort into creating amazing looking [SwiftUI tutorials](https://developer.apple.com/tutorials/swiftui/tutorials). I learned a lot by going through them. It is a fantastic resource for anyone just starting with SwiftUI or iOS development in general.

<a href="https://developer.apple.com/tutorials/swiftui/tutorials"><img class="Any-vertInsets Any-responsiveCard" src="{{ site.url }}/images/posts/swiftui-layout-bonus/swiftui-layout-tutorial.png"></a>

The tutorials look great, but I would've probably preferred Apple to focus on the core documentation and leave tutorials to the community.

The other thing I would like to mention is the Xcode Library. To open it either select **View / Show Library** or press **Shift + Cmd + L**. Xcode Library is a major part of SwiftUI. It contains not only the UI components, but also all the adjustments that you can make, all grouped and searchable. For example, there is a separate section just for the layout modifiers.

<img src="{{ site.url }}/images/posts/swiftui-layout-bonus/xcode-library.png">

I deeply care about documentation. I spend as much effort on documenting my open-source frameworks, like [Nuke](https://github.com/kean/Nuke), as I do on implementing them. I also tend to be the person who looks after knowledge bases at work.

I think Xcode Library is going to be a major factor in the success of the platform. Currently, it is still lacking information because it pulls data from the same [incomplete](https://twitter.com/mattt/status/1185234430425628672?ref_src=twsrc%5Etfw) Apple documentation. But I can see that with some effort, with more graphics and code samples, Xcode Library can become an indispensable tool for anyone learning SwiftUI.

## Fixed Size

In [the previous article]({{ site.url }}/post/swiftui-layout-system#layout-process), we established that the child always ultimately selects its size. And that is always true, however, the child also takes the size of the parent into the account when determining its size. For example, the width of the [`Text`](https://developer.apple.com/documentation/swiftui/text) component is effectively set by its parent. However, SwiftUI allows you to change this behavior.

TODO: come up with an example for fixed size


TODO: why the change is so fundamental

TODO: position

TODO: min:idela:max:


## Coordinate Space

TODO: https://developer.apple.com/documentation/swiftui/view/3278540-coordinatespace
"No Overview Available"


## Z-Index

TODO: https://developer.apple.com/documentation/swiftui/view/3278679-zindex

## Scale

TODO: https://developer.apple.com/documentation/swiftui/view/3278654-scaledtofill
TODO: aspect ratio


## Alignments

TODO: first base alignment for text

TODO: customizing alignment guide for a single view

Declarative frameworks make easy things easy, but hards things are also possible. Let's say, you want to align views from two different view hierarchies. How do you do that in SwiftUI?

In SwiftUI, you can define your own alignments. It's fairly easy to do.


## Geomerty Reader

https://twitter.com/MengTo/status/1193670809010634752?s=20

## Not Supported

There are still scenarios where SwiftUI won't help you.

SwiftUI isn't a constraint system, it's not a generalized solution, so it has more limitations than Auto Layout. For example, if you want two views to have the same width, you have to bridge to UIKit and use Auto Layout.



<div class="References" markdown="1">

## References

1. WWDC 2019, [**Building Custom Views with SwiftUI**](https://developer.apple.com/videos/play/wwdc2019/237/)

<div class="FootnotesSection" markdown="1">

[^1]: TBD