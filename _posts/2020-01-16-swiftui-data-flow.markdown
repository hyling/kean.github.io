---
layout: post
title: "SwiftUI Data Flow"
description: Everything that you need to know about the data flow in SwiftUI
date: 2020-01-16 10:00:00 -0500
category: programming
tags: programming
permalink: /post/swiftui-data-flow
uuid: c5358288-8c59-41e0-a790-521b52f89921
---

<blockquote class="quotation">
<p>SwiftUI is the shortest path to a great app.</p>
<a href="https://developer.apple.com/videos/play/wwdc2019/226/">WWDC 2019</a>
</blockquote>

What makes SwiftUI different from UIKit? One of the primary differences[^1] is that SwiftUI provides a rich set of tools for propagating data changes across the app. This is something that every developer had to come up with on their own in UIKit. Are you going to observe changes to data to refresh the UI (aka *views as a function of state*) or update the UI after performing an update (aka *views as a sequence of events*)? Are you going to set-up bindings using your favorite reactive programming framework or use a target-action mechanism? SwiftUI has answers to all of these questions.

TBD
<!-- {% include ad-hor.html %} -->

## @Published

Let's go over all of the new tools that we have at our disposal. The first and most basic one is [`@Published`](https://developer.apple.com/documentation/combine/published). `@Published` is technically part of the [Combine](https://developer.apple.com/documentation/combine) framework but you don't have to import it because SwiftUI has its `typealias`.

Let's say you are implementing a search functionality for your app, and you defined a view model which you are planning to populate with the search results[^2] and get the UI to update when the results do.

```swift
final class SearchViewModel {
    private(set) var songs: [Song] = []
}
```

Now, how do you propagate the changes to the `songs` array to the view? If you were using [`ReactiveSwift`](https://github.com/ReactiveCocoa/ReactiveSwift)[^3], you would typically use [`Property`](https://github.com/ReactiveCocoa/ReactiveSwift/blob/master/Documentation/ReactivePrimitives.md#property-an-observable-box-that-always-holds-a-value) type to make `songs` property *observable*.

```swift
// ReactiveSwift

final class SearchViewModel {
    private(set) lazy var songs = Property<[Song]>(_songs)
    private let _songs = MutableProperty<[Song]>([])
}
```

This works, but it's not very nice. You have to create[^4] a `MutableProperty` to back a user-facing `Property` to prevent users from modifying it. Fortunately, SwiftUI provides a more elegant solution:

<div class="language-swift highlighter-rouge"><div class="highlight"><pre class="highlight"><code><span class="kd">final</span> <span class="kd">class</span> <span class="kt">SearchViewModel</span> <span class="p">{</span>
    <span class="SwiftUIPostHighlightedCode kd">@Published</span> <span class="kd">private(set)</span> <span class="k">var</span> <span class="nv">songs</span><span class="p">:</span> <span class="p">[</span><span class="kt">Song</span><span class="p">]</span> <span class="o">=</span> <span class="p">[]</span>
<span class="p">}</span>
</code></pre></div></div>

`@Published` is a [Property Wrapper](https://docs.swift.org/swift-book/LanguageGuide/Properties.html#ID617) which creates a Combine `Publisher` to make property observable.

> [**Property Wrappes**](https://docs.swift.org/swift-book/LanguageGuide/Properties.html#ID617)
>
> Property wrappers were introduced in Swift 5.1 to allow users to add additional behavior to properties, like what `lazy` modifier does. You can read more about property wrappers in the [documentation](https://docs.swift.org/swift-book/LanguageGuide/Properties.html#ID617), and the Swift Evolution [proposal](https://github.com/apple/swift-evolution/blob/master/proposals/0258-property-wrappers.md).

The beauty of `@Published` as a property wrapper is that it composes well with the existing Swift access control modifiers. By marking `songs` with `private(set)` we are able to restrict write access to the property.

<div class="language-swift highlighter-rouge"><div class="highlight"><pre class="highlight"><code><span class="kd">final</span> <span class="kd">class</span> <span class="kt">SearchViewModel</span> <span class="p">{</span>
    <span class="kd">@Published</span> <span class="SwiftUIPostHighlightedCode kd">private(set)</span> <span class="k">var</span> <span class="nv">songs</span><span class="p">:</span> <span class="p">[</span><span class="kt">Song</span><span class="p">]</span> <span class="o">=</span> <span class="p">[]</span>
<span class="p">}</span>
</code></pre></div></div>

Another advantage of property wrappers is that to access the current value you can simply write `viewModel.songs` using the basic property syntax. Compare it to `viewModel.songs.value` in ReactiveSwift.

Here is what Apple documentation says about `@Published`:

> Properties annotated with `@Published` contain both the stored value and a publisher which sends any new values after the property value has been sent. New subscribers will receive the current value of the property first. Note that the `@Published` property is class-constrained. Use it with properties of classes, not with non-class types like structures.

Now, what this all means is that by making property `@Published`, you are able to observe the changes made to it.

<div class="SwiftUIExampleWithScreenshot Any-responsiveCard">
    <div class="SwiftUIExampleWithScreenshot_Flex">
        <!-- To the left: title, subtitle, etc -->
        <div class="SwiftUIExampleWithScreenshot_FlexItem SwiftUIExampleWithScreenshot_Left3">
        	There are two ways to acess property wrappers: as a regular property and as a "projection".
        </div>
        <!-- To the right: image -->
        <div class="SwiftUIExampleWithScreenshot_FlexItem SwiftUIExampleWithScreenshot_Right3">
			<img src="{{ site.url }}/images/posts/swiftui-data-flow/published.png">
        </div>
    </div>
</div>

By using `$` you access a *projection* of the property which in case of `@Published` returns a Combine `Publisher`. This is just a regular `Publisher`, no compiler magic in sight.

<div class="language-swift highlighter-rouge"><div class="highlight"><pre class="highlight"><code><span class="kd">@propertyWrapper</span> <span class="kd">public</span> <span class="kd">struct</span> <span class="kt">Published</span><span class="o">&lt;</span><span class="kt">Value</span><span class="o">&gt;</span> <span class="p">{</span>
    <span class="kd">public</span> <span class="kd">init</span><span class="p">(</span><span class="nv">wrappedValue</span><span class="p">:</span> <span class="kt">Value</span><span class="p">)</span>
    <span class="kd">public</span> <span class="kd">init</span><span class="p">(</span><span class="nv">initialValue</span><span class="p">:</span> <span class="kt">Value</span><span class="p">)</span>

    <span class="c1">/// A publisher for properties marked with the `@Published` attribute.</span>
    <span class="kd">public</span> <span class="kd">struct</span> <span class="kt">Publisher</span> <span class="p">:</span> <span class="kt">Combine</span><span class="o">.</span><span class="kt">Publisher</span> <span class="p">{</span>
        <span class="kd">public</span> <span class="kd">typealias</span> <span class="kt">Output</span> <span class="o">=</span> <span class="kt">Value</span>
        <span class="kd">public</span> <span class="kd">typealias</span> <span class="SwiftUIPostHighlightedCode"><span class="kt">Failure</span> <span class="o">=</span> <span class="kt">Never</span></span> <span class="c1">// Never produces an error</span>
        <span class="kd">public</span> <span class="kd">func</span> <span class="n">receive</span><span class="o">&lt;</span><span class="kt">S</span><span class="o">&gt;</span><span class="p">(</span><span class="nv">subscriber</span><span class="p">:</span> <span class="kt">S</span><span class="p">)</span> <span class="k">where</span> <span class="kt">Value</span> <span class="o">==</span> <span class="kt">S</span><span class="o">.</span><span class="kt">Input</span><span class="p">,</span> <span class="kt">S</span> <span class="p">:</span> <span class="kt">Subscriber</span><span class="p">,</span> <span class="kt">S</span><span class="o">.</span><span class="kt">Failure</span> <span class="o">==</span> <span class="kt">Published</span><span class="o">&lt;</span><span class="kt">Value</span><span class="o">&gt;.</span><span class="kt">Publisher</span><span class="o">.</span><span class="kt">Failure</span>
    <span class="p">}</span>

    <span class="c1">/// The property that can be accessed with the `$` syntax and allows access to the `Publisher`</span>
    <span class="kd">public</span> <span class="k">var</span> <span class="SwiftUIPostHighlightedCode"><span class="nv">projectedValue</span><span class="p">:</span> <span class="kt">Published</span><span class="o">&lt;</span><span class="kt">Value</span><span class="o">&gt;.</span><span class="kt">Publisher</span></span> <span class="p">{</span> <span class="k">mutating</span> <span class="k">get</span> <span class="p">}</span>
<span class="p">}</span>
</code></pre></div></div>

Because the `projectedValue` conforms to `Combine.Publisher` protocol, you can use `map`, `sink`, `filter` and other Combine facilities to manipulate it.


<div class="language-swift highlighter-rouge"><div class="highlight"><pre class="highlight"><code><span class="kd">final</span> <span class="kd">class</span> <span class="kt">Player</span> <span class="p">{</span>
    <span class="kd">@Published</span> <span class="k">var</span> <span class="nv">currentSong</span><span class="p">:</span> <span class="kt">Song</span><span class="p">?</span>
<span class="p">}</span>

<span class="n">player</span><span class="o">.</span><span class="SwiftUIPostHighlightedCode"><span class="kt">$</span><span class="kt">currentSong</span></span>
    <span class="o">.</span><span class="nf">compactMap</span> <span class="p">{</span> <span class="nv">$0</span> <span class="p">}</span>
    <span class="o">.</span><span class="nf">filter</span> <span class="p">{</span> <span class="nv">$0</span><span class="o">.</span><span class="kt">style</span> <span class="o">==</span> <span class="kt">.</span><span class="kt">metal</span> <span class="p">}</span>
    <span class="o">.</span><span class="nf">map</span><span class="p">(</span><span class="kt">\</span><span class="kt">.</span><span class="kt">name</span><span class="p">)</span>
    <span class="o">.</span><span class="nf">sink</span> <span class="p">{</span>
        <span class="nf">print</span><span class="p">(</span><span class="s">"Playing: </span><span class="se">\(</span><span class="nv">$0</span><span class="se">)</span><span class="s">"</span><span class="p">)</span>
    <span class="p">}</span>
</code></pre></div></div>

Let's see how it works in action.

```swift
let player = Player()

print("Will subscribe")

player.$currentSong.sink {
    print("Received value: \($0?.name ?? "not playing")")
}

print("Did subscribe")

player.currentSong = Song(name: "Civilization Collapse", style: .metal)
```

```
Will subscribe
Received value: not playing
Did subscrive
Received value: Civilization Collapse
```

The `currentSong` publisher delivers the current value of the property synchronously the moment you subscribe to it.

Great, now we have a way to observe changes to the state. But this is not how you update views in SwiftUI. So what do we do? Welcome to `@ObservedObject`.

## @ObservedObject

We learned about `@Published` and Property Wrappers in general, but it's nearly not enough to know how to update views in SwiftUI.

Let's start with how you would typically *bind* the state to the views using a reactive programming framework like ReactiveSwift. In ReactiveSwift, you either observe the changes and reload the UI, or, in case of simple properties, bind them directly to the UI elements.

<div class="language-swift highlighter-rouge"><div class="highlight"><pre class="highlight"><code><span class="c1">// ReactiveSwift</span><br/><br/><span class="kd">final</span> <span class="kd">class</span> <span class="kt">SearchView</span><span class="p">:</span> <span class="nf">UIView</span> <span class="p">{</span>
    <span class="kd">private</span> <span class="k">let</span> <span class="nv">spinner</span> <span class="o">=</span> <span class="nf">UIActivityIndicatorView</span><span class="p">()</span>
    <span class="kd">private</span> <span class="k">let</span> <span class="nv">tableView</span> <span class="o">=</span> <span class="nf">UITableView</span><span class="p">()</span>

    <span class="kd">init</span><span class="p">(</span><span class="nv">viewModel</span><span class="p">:</span> <span class="kt">SearchViewModel</span><span class="p">)</span> <span class="p">{</span>
        <span class="k">super</span><span class="o">.</span><span class="kd">init</span><span class="p">(</span><span class="nv">frame</span><span class="p">:</span> <span class="o">.</span><span class="n">zero</span><span class="p">)</span>

        <span class="c1">// Unlike RxSwift, there is no `UITableView` binding provided by ReactiveSwift,</span>
        <span class="c1">// so unless you build/add one, you end-up just reloading the table view.</span>
        <span class="n">viewModel</span><span class="o">.</span><span class="kt">users</span><span class="o">.</span><span class="kt">producer</span>
            <span class="o">.</span><span class="kt">take</span><span class="p">(</span><span class="nv">during</span><span class="p">:</span> <span class="kt">reactive</span><span class="o">.</span><span class="kt">lifetime</span><span class="p">)</span>
            <span class="SwiftUIPostHighlightedCode"><span class="o">.</span><span class="kt">startWithValues</span></span> <span class="p">{</span> <span class="p">[</span><span class="k">unowned</span> <span class="k">self</span><span class="p">]</span> <span class="n">_</span> <span class="k">in</span>
                <span class="k">self</span><span class="o">.</span><span class="n">tableView</span><span class="o">.</span><span class="nf">reloadData</span><span class="p">()</span>
            <span class="p">}</span>

        <span class="c1">// You can bind simple properties directly to the UI elements</span>
        <span class="n">spinner</span><span class="o">.</span><span class="kt">reactive</span><span class="o">.</span><span class="kt">isAnimating</span> <span class="SwiftUIPostHighlightedCode"><span class="kt">&lt;~</span></span> <span class="n">viewModel</span><span class="o">.</span><span class="kt">isLoading</span>
    <span class="p">}</span>
<span class="p">}</span>
</code></pre></div></div>

This gets the job done, and in case of `<~` binding in an elegant way – the syntax is minimal, the observation lifetime is automatically taken care of for you. As a result, the views always reflect the latest state of the model – something that SwiftUI also aims at doing. How do you do the same thing in SwiftUI?

To start observing the changes to the model, you use [`@ObservedObject`](https://developer.apple.com/documentation/swiftui/observedobject) property wrapper. And the `@ObservedObject` must be in turn initialized with a value confirming to [`ObservableObject`](https://developer.apple.com/documentation/combine/observableobject) protocol.

<div class="language-swift highlighter-rouge"><div class="highlight"><pre class="highlight"><code><span class="kd">struct</span> <span class="kt">SearchView</span><span class="p">:</span> <span class="nf">View</span> <span class="p">{</span>
    <span class="SwiftUIPostHighlightedCode kd">@ObservedObject</span> <span class="k">var</span> <span class="nv">viewModel</span><span class="p">:</span> <span class="kt">SearchViewModel</span>

    <span class="k">var</span> <span class="nf">body</span><span class="p">:</span> <span class="kd">some</span> <span class="nf">View</span> <span class="p">{</span>
        <span class="nf">List</span><span class="p">(</span><span class="n">viewModel</span><span class="o">.</span><span class="kt">songs</span><span class="p">)</span> <span class="p">{</span>
            <span class="nf">Text</span><span class="p">(</span><span class="nv">$0</span><span class="o">.</span><span class="kt">name</span><span class="p">)</span>
        <span class="p">}</span>
    <span class="p">}</span>
<span class="p">}</span>

<span class="kd">final</span> <span class="kd">class</span> <span class="kt">SearchViewModel</span><span class="p">:</span> <span class="SwiftUIPostHighlightedCode nf">ObservableObject</span> <span class="p">{</span>
    <span class="kd">@Published</span> <span class="kd">private(set)</span> <span class="k">var</span> <span class="nv">songs</span><span class="p">:</span> <span class="p">[</span><span class="kt">Song</span><span class="p">]</span> <span class="o">=</span> <span class="p">[]</span>
<span class="p">}</span>
</code></pre></div></div>

Now every time the `sons` property changes, the `SearchView` is going to be updated. Now, how does any of this actually work?



This is where magic begins 🎩✨.



## @State

[`@State`](https://developer.apple.com/documentation/swiftui/state) is a [Property Wrapper](https://nshipster.com/propertywrapper/).


## ObservableObject and @Published

## @Binding

## @FetchRequest


<div class="References" markdown="1">

## Temp Resources

https://nalexn.github.io/stranger-things-swiftui-state/?utm_source=tw
https://nalexn.github.io/swiftui-observableobject/

## References

- WWDC 2019, [**Testing with Xcode**](https://developer.apple.com/videos/play/wwdc2019/413/)
- WWDC 2018, [**Engineering for Testability**](https://developer.apple.com/videos/play/wwdc2017/414)
- WWDC 2016, [**UI Testing in Xcode**](https://developer.apple.com/videos/play/wwdc2015/406/)
- Martin Fowler (2019), [**Software Testing Guide**](https://martinfowler.com/testing/)

<div class="FootnotesSection" markdown="1">

[^1]: Another one being a completely new layout system which I covered in [one of my previous articles]({{ site.url }}/post/post/swiftui-layout-system).
[^2]: For simpliciy, I'm exposing model objects (`Song`) from the view model. If you are closely following MVVM, you would typically want to to create a separate view model for each song.
[^3]: I'm using ReactiveSwift for comparison with Combine/SwiftUI because I find it be the closest thing to Combine: it has typed errors, is has `Property` type. You don't need to know ReactiveSwift to continue with this article.
[^4]: Property Wrappers are not an exclusive feature of SwiftUI and can be introduced in ReactiveSwift. There is already a [pull request](https://github.com/ReactiveCocoa/ReactiveSwift/pull/762) with a proposed changed. It introduces a new `@Observable` property wrapper. In reality, I think it should completely replace the existing `Property` and `MutableProperty` types.