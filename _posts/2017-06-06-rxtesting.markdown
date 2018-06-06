---
layout: post
title: "RxSwift Testing"
subtitle: "Unit testing paging in a scroll view using <a href='https://github.com/ReactiveX/RxSwift'>RxSwift</a> testing infrastructure - <a href='https://github.com/ReactiveX/RxSwift/blob/master/Documentation/UnitTests.md'>RxTest</a>"
date: 2017-06-06 10:00:00 +0300
category: programming
tags: ios
permalink: /post/rxswift-testing
redirect_from:
    - /blog/rxswift-testing
    - /rxswift-testing
uuid: cdddbe85-b27a-4ba3-8336-340919e3cf04
---

One of my favorite features of RxSwift is its testing infrastructure, RxTest. And it's an undersold one too, it's not even mentioned on a [Why RxSwift](https://github.com/ReactiveX/RxSwift/blob/master/Documentation/Why.md) page. Let's take a look at it on a real-world example - paging in a scroll view.

> Requirements: Xcode 8.3, Swift 3.1, RxSwift 3.5

## Paging

One of the main components responsible for paging in our app is `PagingScrollViewModel` which is defined like this:

```swift
final class PagingScrollViewModel<Page> {

    let pages: Driver<[Page]>
    let indicator: Driver<PagingIndicatorState>

    init(service: PagingService<Page>, retryTap: Driver<Void>, didReachBottom: Driver<Void>)
}

enum PagingIndicatorState {
    case hidden, loading, failed(Error)
}
```

As you can see it is initialized with a paging service and two observable sequences that represent user *input* (`retryTap` and scroll view `didReachBottom`). The *outputs* are two other observable sequences: `pages` and `indicator`.

One of the scenarios that I'd like to capture by unit tests is this:

> When the user scrolls to the bottom of the scroll view automatically start loading the next page and display a footer view with an activity indicator. If the request for the next page fails, show a footer view with an error message and a "Retry" button.

It's a relatively complex scenario which would normally seem hard to test. But it's actually really easy using RxTest. Let's first take a quick look at RxTest and then jump right into the test file.

## RxTest

The main component of RxTest is a `TestScheduler` class. It is a "virtual time scheduler" which allows you to control time. You can use it to:

- Create test observables which emit specific events at specific points in virtual time. For example, you can mock "Retry" button tap like this:

```swift
let retryTap = scheduler.createHotObservable([next(150, ())])
```

- Create test observers which you can subscribe to your actual observables to record all of the events emitted by them:

```swift
let pages = scheduler.record(viewModel.pages)
```

Let's see how it all comes into practice in the actual test case.

## Test Case

```swift
// Create a list of expected events.
// `Recorded` is a simple `time` + `value` struct (RxTest)
// `Event` is a core type in RxSwift that represents a sequence event.
let expectedPages: [Recorded<Event<[String]>>] = [
    next(0, []), // The `Driver` replays the last element on subscribe
    next(25, ["Page1"])
]
let expectedIndicators: [Recorded<Event<PagingIndicatorState>>] = [
    next(0, .loading),
    next(25, .hidden),
    next(150, .loading),
    next(175, .failed("An error has occured"))
]

// Create a virtual time scheduler (RxTest)
let scheduler = TestScheduler(initialClock: 0)

// Create a service mock that returns the first page successfully, but then
// fails loading a second page. It uses a helper function `makeService`
// (which is irrelevant). What is relevant is that each response
// is produced 25 virtual time units after the subscription.
let service = makeService(results: [
    .success((page: "Page1", isFinished: false)),
    .failure(NSError(domain: "Test", code: 0, userInfo: nil))
], scheduler: scheduler)

// Create a "hot" observable which will produce a `didReachBottom`
// event in a specific point in virtual time.
let didReachBottom = scheduler.createHotObservable([next(150, ())])

let vm = PagingScrollViewModel(
    service: service,
    retryTap: .empty(),
    didReachBottom: didReachBottom.asDriver(onErrorJustReturn: ())
)

// This method enables mock test scheduler while testing drivers.
driveOnScheduler(scheduler) {
    let pages = scheduler.record(vm.pages)
    let indicators = scheduler.record(vm.indicator)
    scheduler.start()

    XCTAssertEqual(pages.events, expectedPages)
    XCTAssertEqual(indicators.events, expectedIndicators)

    // Print recorded events to the console.
    print(pages.events)
    print(indicators.events)
}
```

That's it! If you were to run this test case we see the recorded events printed out to the console:

```
pages.events:

next([]) @ 0
next(["Page1"]) @ 25

indicators.events:

next(loading) @ 0
next(none) @ 25
next(loading) @ 150
next(failed("An error has occured")) @ 175
```

This matches the expected events, the test is passed successfully.

The `TestScheduler.record(_:)` is a helper method borrowed from the tests in a RxSwift repo (there are a lot of other goodies too):

```swift
extension TestScheduler {
    /// Creates a `TestableObserver` instance which immediately subscribes
    /// to the `source` and disposes the subscription at virtual time 100000.
    func record<O: ObservableConvertibleType>(_ source: O) -> TestableObserver<O.E> {
        let observer = self.createObserver(O.E.self)
        let disposable = source.asObservable().bind(to: observer)
        self.scheduleAt(100000) {
            disposable.dispose()
        }
        return observer
    }
}
```

## Conclusion

Because RxSwift is such a generic abstraction which provides a unified interface for all kinds of events (user input, async operations, data changing over time) we can also have such a simple yet powerful unified testing infrastructure.

There are other ways to write RxSwift tests one of which is called "[marble tests](https://github.com/ReactiveX/RxSwift/blob/master/Documentation/UnitTests.md#testing-operator-compositions-view-models-components)". The idea is to use "marble notation" to define expected events. There is an example of marble tests in a RxSwift repo.

The downside of this approach is that you have to make sure that everything happens on a `TestScheduler`. And if there is any "uncontrolled" asynchronous code which gets executed as part of your tests then you'll still [end up writing asynchronous tests](http://rx-marin.com/post/rxswift-rxtests-unit-tests-part-2/).

# Links

- [RxSwift](https://github.com/ReactiveX/RxSwift)
- [RxSwift: Unit Tests](https://github.com/ReactiveX/RxSwift/blob/master/Documentation/UnitTests.md)
- [RxJS: Writing Marble Tests](https://github.com/ReactiveX/RxJS/blob/master/doc/writing-marble-tests.md)
