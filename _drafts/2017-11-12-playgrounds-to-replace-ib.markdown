---
layout: post
title:  "Playgrounds to Replace IB"
date:   2017-11-12 10:00:00 +0300
category: programming
tags: ios
permalink: /post/playgrounds-to-replace-ib
uuid: 6009c129-e085-49a0-9639-e37798f91068
---

The only major benefit on Interface Builder is that fact that you can instantly see the changes that you make. Everything else is a burden. You can't reuse styles, you can't create abstactions, it's hard to compose components, clicking menus with a mouse is extremely inefficient, the generated XMLs are not human readable, all the properties and constrains are hidden behind menus, @IBDesignable is broken most of the time. And more importantly, xibs and storyboards become a maintanence hell.

Fortunately, there is a new emerging paradigm for building interfaces which is code with Playgrounds for instant previews. Playgrounds not only have the same benefit of instant previews as IB does, there are even better - they are interactive!

In this article I'm going to demonstrate a Playgrounds which I've used to create a screen for the app and point out each of the benefits that Playgrounds bring to the table.