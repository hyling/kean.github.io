---
layout: post
title: "Regex, Part 2: Parser"
subtitle: TBD
date: 2019-09-15 9:00:00 +0300
category: programming
tags: programming
permalink: /post/regex-parser
uuid: b1b60dba-0872-49ac-9120-dff4f4006f89
---

The key for solving any problem is decomposition. [The grammar](https://kean.github.io/Regex/grammar-diagram.xhtml) defined in [the previous article]({{ site.url }}/post/regex-grammar) is composed of multiple tiny pieces chained together. Now, how do we translate it into code?

## Parsing

Let's start with a relatively simple non-terminal symbol - [Range Quantifier](https://docs.microsoft.com/en-us/dotnet/standard/base-types/quantifiers-in-regular-expressions). There are three possible variants of range quantifiers:

- a<code><b>{</b><i>n</i><b>}</b></code> – matches "a" exactly *n* times
- a<code><b>{</b><i>n</i><b>,}</b></code> – matches "a" at least *n* times
- a<code><b>{</b><i>n</i><b>,</b><i>m</i><b>}</b></code> – matches "a" from *n* to *m* times

This is the grammar for the range quantifier defined [the previous article]({{ site.url }}/post/regex-grammar):

```swift
RangeQuantifier ::= "{" Number ( "," Number? )? "}"
```

<img src="{{ site.url }}/images/posts/regex/grammar_range_quantifier.png" style="max-width:500px;">

### Start with a Function

How do we approach this? Let's start with a function:

```swift
/// Returns a range quantifier and the remaining substring of the match is found.
/// Returns `nil` otherwise.
func parseRangeQuantifier(_ string: Substring) -> (RangeQuantifier, Substring)? {
    fatalError("Not implemented")
}
```

First, let's check whether the first character in the input string is "{":

```swift
func parseRangeQuantifier(_ string: Substring) -> (RangeQuantifier, Substring)? {
    var string = string
    guard string.first == "{" else {
        return nil
    }
    string.removeFirst()

    // ...
}
```

The opening "{" indicates that it is in fact a range quantifier. The next part of the range quantifier is a lower bound which must be a non-negative number.

```swift
func parseRangeQuantifier(_ string: Substring) -> (RangeQuantifier, Substring)? {
    // ...

    var digits = [Character]()
    while let digit = string.first, CharacterSet.decimalDigits.contains(digit) {
        string.removeFirst()
        digits.append(digit)
    }
    guard let lowerBound = Int(String(digits)) else {
        return nil
    }

    // ...
}
```

This already starts becoming unwieldy. And it doesn't look even remotely like the original grammar:

```swift
RangeQuantifier ::= "{" Number ( "," Number? )? "}"
```

The first thing that you could do to improve the implementation is extract some of the parser in their own functions. Let's do just that, we are most likely going to need these parsers later anyway. There are two parsers to extract. The first one parses the passed input string and returns `()` to indicate when the match is found. The second one parses a non-negative number from the input string.

```swift
func parseString(_ prefix: String, _ string: Substring) -> (Void, Substring)? {
    string.hasPrefix(prefix) ? ((), string.dropFirst(prefix.count)) : nil
}

func parseNumber(_ string: Substring) -> (Int, Substring)? {
    var string = string
    var digits = [Character]()
    while let digit = string.popFirst(), CharacterSet.decimalDigits.contains(digit) {
        digits.append(digit)
    }
    guard let number = Int(String(digits)) else {
        return nil
    }
    return (number, string)
}
```

This starts looking better. Now let's try combining these functions together.

```swift
func parseRangeQuantifier(_ string: Substring) -> (RangeQuantifier, Substring)? {
    guard let (_, stringA) = parseString("{", string),
        let (lowerBound, stringB) = parseNumber(stringA) else {
        return nil
    }
    return (RangeQuantifier(lowerBound: lowerBound, upperBound: 0), stringB)
}
```

This definitely works, but it's far from optimal. We had to manually pass the input string from one parser to another. It was tedious to write, and there is a room for error. And, more importantly, we buried the original intent – we expect a "{" followed by a number – under all of these technical details. Yikes! There must be a better way.

### Introducing Parser

Let's go back to the original definition of the range quantifier parser:

```swift
func parseRangeQuantifier(_ string: Substring) throws -> (RangeQuantifier, Substring)?
```

You don't have to look closely to notice that it is almost identical to the other two parser definitions:

```swift
func parseString(_ prefix: String, _ string: Substring) -> (Void, Substring)?
func parseNumber(_ string: Substring) -> (Int, Substring)?
```

There are three instances of the similar pattern. It's time to introduce an abstraction.

```swift
struct Parser<A> {
    /// Parses the given string. Returns the matched element `A` and the
    /// remaining substring if the match is successful. Returns `nil` otherwise.
    let parse: (_ string: Substring) throws -> (A, Substring)?
}
```

> One could start with a generic function, but struct enables more possibilities. For example, you can add extensions to a struct.

Let's define a few parsers, this time starting bottom-up. The first parser will be match the given string (or prefix). The original implementation from `parseString` function will do just fine:

```swift
struct Parsers {}

extension Parsers {
    /// Matches the given string.
    static func string(_ p: String) -> Parser<Void> {
        Parser { str in
            str.hasPrefix(p) ? ((), str.dropFirst(p.count)) : nil
        }
    }
}
```

> I introduced `Parsers` struct to be used as a namespace so that the parser definitions don't pollute the global namespace. I'm going to omit it in the next code samples.

Let's now deal with numbers. I think we can do better than in the original function. What is a number (natural and zero)? It is one or more digits. Let's try to represent this idea as closely to the definition as possible.

Let's start with something as simple as reading a single character from an input string.

```swift
/// Matches any single character.
let char = Parser<Character> { str in
    str.isEmpty ? nil : (str.first!, str.dropFirst()) 
}
```

Now how do we only accept the character if it's a digit?

### Introducing Parser Combinators

Let's introduce a new `filter` method which should be familiar for any developer writing in Swift.

```swift
let digit = char.filter(CharacterSet.decimalDigits.contains)
```

Awesome! But how do we implement `filter`? Simple:

```swift
extension Parser {
    func filter(_ predicate: @escaping (A) -> Bool) -> Parser<A> {
        map { predicate($0) ? $0 : nil }
    }
}
```

The `filter` method takes the current parser and the given predicate as an input and produces a new parser as an output – this is the first **parser combinator** that we encounter, there is going to be many more. If the value passes the `predicate`, it returns a value itself, without modification. If the value doesn't pass the `predicate`, it returns `nil` indicating that the match failed.

You might be wondering, where did `map` come from? We need to implement it, along with `flatMap`.

```swift
extension Parser {
    func map<B>(_ transform: @escaping (A) throws -> B?) -> Parser<B> {
        flatMap { match in
            Parser<B> { str in
                guard let value = try transform(match) else { return nil }
                return (value, str)
            }
        }
    }

    func flatMap<B>(_ transform: @escaping (A) throws -> Parser<B>) -> Parser<B> {
        Parser<B> { str in
            guard let (a, str) = try self.parse(str) else { return nil }
            return try transform(a).parse(str)
        }
    }
}
```

- **`map`** takes a value produced by the given parser and returns a new parser which produces a transformed value
- **`flatMap`** returns a parser which produces the result of the parser returned by the `transform` closure. The `transform` closure is called when the current parser matches a value

These two function a bread and butter of functional programming, or I would say just programming in general nowadays. You can find them everywhere. `Array` has them, `Optional` has them, [`Future`](https://github.com/kean/FutureX) has them, `Combine` and `RxSwift` has them. Now `Parser` has them too making it a proper [functor and monad](https://www.mokacoding.com/blog/functor-applicative-monads-in-pictures).

I know we've already covered a lot of ground but there is a bit more to go through. Bare with me, it's getting easier from this point.

We learned how to parse a digit, but how do we parse one or more of them? It's time to introduce another method, `oneOrMore` and its friend `zeroOrMore`.

```swift
extension Parser {
    /// Matches the given parser zero or more times.
    var zeroOrMore: Parser<[A]> {
        Parser<[A]> { str in
            var str = str
            var matches = [A]()
            while let (match, newStr) = try self.parse(str) {
                matches.append(match)
                str = newStr
            }
            return (matches, str)
        }
    }

    /// Matches the given parser one or more times.
    var oneOrMore: Parser<[A]> {
        zeroOrMore.map { $0.isEmpty ? nil : $0 }
    }
}
```

We now have all the tools to define a number:

```swift
let number = digit.oneOrMore.map { Int(String($0)) }
let digit = char.filter(CharacterSet.decimalDigits.contains)
```

### Bringing Everything Together

We can parse a string, we can parse a number. We should now have everything to parse a range quantifier. There is one last missing piece of the puzzle - `zip`.

```swift
/// Matches only if both of the given parsers produced a result.
func zip<A, B>(_ a: Parser<A>, _ b: Parser<B>) -> Parser<(A, B)> {
    a.flatMap { matchA in b.map { matchB in (matchA, matchB) } }
}

func zip<A, B, C>(_ a: Parser<A>, _ b: Parser<B>, _ c: Parser<C>) -> Parser<(A, B, C)> {
    zip(a, zip(b, c)).map { a, bc in (a, bc.0, bc.1) }
}

// func zip<A, B, C, D>) ...
```

With the addition of `zip` we are finally ready to define the parser:

```swift
let rangeQuantifier = zip(
    string("{"), number, string(","), number, string("}")
).map { _, lowerBound, _, upperBound, _ in
    RangeQuantifier(lowerBound: lowerBound, upperBound: upperBound)
}

rangeQuantifier.parse("{1,3}") // Returns 1...3
rangeQuantifier.parse("{1,3") // Returns nil
```

But what about the requirement where the upper bound could be optional? It's time for another parser combinator - `optional`.

```swift
func optional<A>(_ parser: Parser<A>) -> Parser<A?> {
    Parser<A?> { str -> (A?, Substring)? in // yes, double-optional, zip unwraps it
          guard let match = try parser.parse(str) else {
              return (nil, str) // Return empty match without consuming any characters
          }
          return match
      }
}
```

Let's use `optional` on the left side of the range quantifier:

```swift
let rangeQuantifier = zip(
    string("{"), number, string(","), optional(number), string("}")
).map { _, lowerBound, _, upperBound, _ in
    RangeQuantifier(lowerBound: lowerBound, upperBound: upperBound)
}

rangeQuantifier.parse("{1,3}") // Returns 1...3
rangeQuantifier.parse("{1,3") // Returns nil
rangeQuantifier.parse("{1,}") // Returns 1...
```

Perfect! We've just introduced most of the parser quantifiers that you will ever need and used them to successfully implement a parser for part of the regex grammar. Turns out, you can build the entire regex parser with just these combinators!

The new parser looks perfect. Well, almost perfect. There is always something to improve. I think we could make it even better. Notice how we had to explicitly ignore some of the arguments? This is something that we could also address.

### Tidying Things Up

Please keep in mind that we already have everything to write a complete regex parser. But we are going to be writing and combining *a lot* of these tiny parsers. Every bit of readability counts. Even though the previous range quantifier parser is already looking good, it could be a bit better. Ideally we want it to look just like the original grammar:

```swift
RangeQuantifier ::= "{" Number ( "," Number? )? "}"
```

The first easy win that we can have is by making parser expressible by strings:

```swift
extension Parser: ExpressibleByStringLiteral where A == Void {
    /// ...

    public init(stringLiteral value: String) {
        self = Parsers.string(value)
    }
}
```

We can now remove explicit `string` calls:

```swift
let rangeQuantifier = zip("{", number, ",", optional(number), "}")
    .map { _, lowerBound, _, upperBound, _ in
        RangeQuantifier(lowerBound: lowerBound, upperBound: upperBound)
    }
```

Much better! But we can push it ever further! How? With just these three basic operators:

```swift
infix operator *> : CombinatorPrecedence
infix operator <* : CombinatorPrecedence
infix operator <*> : CombinatorPrecedence

func *> <A, B>(_ lhs: Parser<A>, _ rhs: Parser<B>) -> Parser<B> {
    zip(lhs, rhs).map { $0.1 }
}

func <* <A, B>(_ lhs: Parser<A>, _ rhs: Parser<B>) -> Parser<A> {
    zip(lhs, rhs).map { $0.0 }
}

func <*> <A, B>(_ lhs: Parser<A>, _ rhs: Parser<B>) -> Parser<(A, B)> {
    zip(lhs, rhs)
}

precedencegroup CombinatorPrecedence {
    associativity: left
    higherThan: DefaultPrecedence
}
```

With these operators we can dramatically reduce the amount of the code needed:

```swift
let rangeQuantifier = ("{" *> number <* "," <*> optional(number) <* "{").map(RangeQuantifier.init)
```

Brilliant! This is as close to the original grammar as we can get (we can still push it a little be further but I don't think it's going to be reasonable). I think this is one of the very few cases where the addition of custom operators seem appropriate:

- These operators are going to be used *very* often – every parser is going to use them
- Even if you were to use functions or methods instead, there is no clear way how or name them – how would you name a `zip` which ignores the second parameter?
- There are the new custom operators, we are not overloading the existing ones

Some might argue that these reasons are not valid enough to introduce the operators and this is fine. The original implementation was also clear and quite succinct, especially compared to the very first iteration which didn't use parser combinators at all. I personally think that in this case the use of operators of justified – and there are a lot of examples when they are not!


### Remaining Steps

We haven't added support for the following definition:

- a<code><b>{</b><i>n</i><b>}</b></code> – matches "a" exactly *n* times

I will leave this as an exercise to the reader.

We also allow numbers like "012" or "0012" which is not great, but not terrible. Other [regex parsers](https://regex101.com) also do.

## Theory

Unlike the [previous article]({{ site.url }}/post/regex-grammar), I haven't yet touched any of the theory behind parsing. It is a well-research area. There is a huge taxonomy of parsing techniques. It's impossible to cover all of them in a single article so I'm going to leave this note for additional reading:

> [**Parsing Techniques**](https://dickgrune.com/Books/PTAPG_2nd_Edition/) *(Additional Reading)*
>
> In **top-down parsing** method, the tree is reconstructed from the top downwards. The opposite is **bottom-up parsing** which starts by recognizing the leaf nodes and constructing the tree from the bottom.
>
> **Non-directional** methods construct the parse tree while accessing the input in any order they see fit. This of course requires the entire input to be in memory before parsing can start. **Directional** parsers access the input tokens one by one in order, all the while updating the partial parse tree.
>
> Parsing techniques can also be classified by the search technique. There are in general two methods for solving problems in which there is more than one alternative path in the solution: **depth-first-search** and **breadth-first search**. The former is also associated with **backtracking**. If the grammar is **deterministic** (it doesn't have any alternatives), the parsing can be done using **linear** methods. If the parser a pre-determined **look-ahead** to determine which production to use, it can also be classified as **deterministic**. Different parsing techniques have different **time complexity**.
>
> Parser can be **generated** from the grammar or written by hand.
>
> Each technique is best suited for recognizing a specific type of grammar. You can read all about them in a [Parsing Techniques](https://dickgrune.com/Books/PTAPG_2nd_Edition/) book by Dick Grune and Ceriel J.H. Jacobs which is a definitive resource about parsing.
>
> The method used in this article is called **LL(1)** which is one of the most popular ones. The first "L" stands for "left-to-right, the second "L" for "identifying the leftmost production", aka "top-down", "(1)" stands for "linear" – there is no backtracking or other search technique needed. There is some look-ahead though, so it's actually more precise to classify it as **LL(k)** where "k" is a know constant value (not know to me though because I haven't calculated it).
>
> As you've probably noticed we wrote a parser by hand (we haven't *generated* it) using Parser Combinators technique. However, the final parser got so close to the formal grammar that one could argue that it's closer to generators that to writing parsers by hand. In general, this method is great for writing parsers which recognize simple Context-Free Grammars. The technique that I used is also often associated with the term "recursive descend".
>
> We also didn't keep a **parse tree** around and only kept the semantics. This is something that you might keep an eye for when you write your own parsers.

## Completing the Parser

We wrote the first tiny piece of the regex parser and we just need to [draw the rest of the owl](https://knowyourmeme.com/memes/how-to-draw-an-owl). It's not going to be easy and there are still some more concepts to learn.

### Throwing Errors

If you noticed, the original parser was a throwing function, but we never got a chance to use this property.

```swift
struct Parser<A> {
    let parse: (_ string: Substring) throws -> (A, Substring)?
}
```

You can use it to throw an error if parser enters a state which it can't recover from.

```
extension Parser {
    /// Throws an error with the given message if the parser fails to produce a match.
    func orThrow(_ message: String) -> Parser {
        Parser { str -> (A, Substring)? in
            guard let match = try self.parse(str) else {
                throw ParserError(message, str.index)
            }
            return match
        }
    }
}

let rangeQuantifier = "{" *> number.orThrow("Range quantifier is missing lower bound") <* /* ... */
```

Now if we started parsing a range quantifier, we make sure that we finish. If we don't, we will produce a clear diagnostic message along with the index where the error occurred.

### Choice

If there are multiple potential matches at any given state, we can use `oneOf` function:

```swift
/// Returns the first match or `nil` if no matches are found.
func oneOf<A>(_ parsers: Parser<A>...) -> Parser<A> {
    precondition(!parsers.isEmpty)
    return Parser<A> { str -> (A, Substring)? in
        for parser in parsers {
            if let match = try parser.parse(str) {
                return match
            }
        }
        return nil
    }
}
```

### Recursive Constructs

Some constructs are defined recursively. For example, a group can contain other groups among other subexpressions.

<img src="{{ site.url }}/images/posts/regex/grammar_group.png" style="max-width:500px;">

```swift
Group ::= "(" GroupNonCapturingModifier? Expression ")" Quantifier?
GroupNonCapturingModifier ::= "?:"
```

Fortunately, parser combinators are capable of handling (left) recursion just fine:

```swift
let group = ("(" *> optional("?:") <*> expression <* string(")").orThrow("Unmatched opening parentheses")).map(Group.init)

static let expression = oneOf(match, anchor, lazy(group))
```

> This is a simplified version of the grammar, see [kean/Regex](https://github.com/kean/Regex) for the full version.

There are two things to keep an eye for:

- `expression` parser must stop when it encounters a closing parentheses ")" and by doing that give control back to the `group` parser
- `lazy` function wraps `group` definition into a closure (it's marked with `@autoclosure`), if we don't do that there is going to be a crash in runtime because the `group` constant is indirectly defined using itself – and compiler can't produce a diagnostic for this specific case to warn us

## Efficiency

The method used in this article is called **LL(1)** which is one of the most popular ones.

The first "L" stands for "left-to-right, the second "L" for "identifying the leftmost production", aka "top-down". "(1)" stands for "linear" – there is no backtracking or other search technique needed, the result can be produced in a linear time.

> You can read more about LL(1) and other parsing techniques in ["Parsing Techniques"](https://dickgrune.com/Books/PTAPG_2nd_Edition/)] by Dick Grune and Ceriel J.H. Jacobs.

## Drawbacks

No technology is without drawbacks. It's hard to find many with parser combinators – this a simply but truly powerful concept. The only major drawback that I found with parser combinators is, just like with any other declarative system like SwiftUI, or Auto Layout, or RxSwift, it's easy to read and write, but it might be very hard to debug. You have to understand it fully and know exactly what you are doing. If you make a mistake, debugging it might become a nightmare. Fortunately, the parsers combinators are modular so it's very easy to write unit tests and it's often relatively easy to identify the parser which causes an error. I would imagine that debugging parser combinators is still going to be easier than debugging a parser generated by a sophisticated tool which you don't necessary have a complete understanding of.

## What's Next

Parser combinators (or *monadic* parsers) are a great example of functional programming used to bring practical benefits. The introduced notation makes parsers compact and easy to read to the point that it becomes almost like reading a formal grammar. Parsers can be expressed in a modular way using just a few familiar concepts.

In contrast with parser generators, this method of building parsers is fully extensible. You can use full power of Swift to define special combinators or special parsers of any kind. There is also very little you need to learn before you can start using parser combinators, especially if you are familiar with functional programming.

The code from the article is available in a [playground]({{ site.url }}/playgrounds/parsers.zip). You can find the complete regex parser implementation in [kean/Regex](https://github.com/kean/Regex). With a parser completed, we can now produce a structured representation of the pattern and compile it. This will be the focus on the upcoming article. Stay tuned!

## References

- [Graham Hutton and Erik Meijer, "Monadic Parser Combinators"](http://www.cs.nott.ac.uk/~pszgmh/monparsing.pdf)
- [Point-Free, "Parser Combinators"](https://www.pointfree.co/episodes/ep62-parser-combinators-part-1)
- [Dick Grune, Ceriel J.H. Jacobs, "Parsing Techniques"](https://dickgrune.com/Books/PTAPG_2nd_Edition/)
- [Railroad Diagram Generator](https://www.bottlecaps.de/rr/ui)


- https://softwareengineering.stackexchange.com/questions/338665/when-to-use-a-parser-combinator-when-to-use-a-parser-generator

