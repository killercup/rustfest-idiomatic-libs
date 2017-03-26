---
title: Idiomatic Rust Libraries
categories:
- rust
- presentation
# pandoc settings
author: Pascal Hertleif
date: 2017-03-20
theme: solarized
progress: true
slideNumber: true
history: true
---

## Pascal Hertleif

- Web stuff by day, Rust by night!
- Co-organizer of [Rust Cologne]
- {[twitter],[github]}.com/killercup

[Rust Cologne]: http://rust.cologne/
[twitter]: https://twitter.com/killercup
[github]: https://github.com/killercup

- - -

This talk is an adaption of my blog post [Elegant Library APIs in Rust][post]
but also takes some inspiration from Brian's [Rust API guidelines][guidelines].

[post]: https://scribbles.pascalhertleif.de/elegant-apis-in-rust.html
[guidelines]: https://github.com/brson/rust-api-guidelines

# Goals for our libraries

## Easy to use

_ Quick to get started with
- Easy to use _correctly_
- Flexible and performant

## Easy to maintain

- Common structures, so code is easy to grasp
- New contributor friendly == Future-self friendly
- Well-tested

- - -

Often good practices for one are also helpful for the other.

But not always. In those cases, think of your users first.

# Some easy things first

<aside class="notes">
Let's warm up with some basics that will make every library nicer.
</aside>

## Doc tests

Well-documented == Well-tested

```rust
/// Check number for awesomeness
///
/// ```rust
/// assert!(42.is_awesome());
/// ```
```

<aside class="notes">
Doc tests are the tests that also help your users.
</aside>

- - -

#### Show how you want your API to be used

Use regular unit tests for weird edge cases.

Always write them from a user's perspective.

They are more useful when they can be copy-pasted.

- - -

#### Avoid setup code in doc tests

Your user already have setup code

Start code lines with `#` to hide them in Rustdoc output

**Pro tip:** Put setup code in a file, then `# include!("src/doctest_helper.rs");`

- - -

## Directories and files

**Basically:** Follow Cargo's best practices

- `src/lib.rs`, `src/main.rs`, `src/bin/{name}.rs`
- `tests/`, `examples/`, `benches/`

- - -

When you start a project, you might end up with 1000 lines in a `lib.rs`.

Split this up early on to represent your code's architecture in the file system!

- - -

## Get more compiler errors!

- `#![deny(warnings, missing_docs)]`
- Use Clippy

## Readme-driven development (et.al.)

1. Write a nice Readme with code examples that should work.
2. Use [tango] to turn those examples into tests.
3. Write the code to make the tests pass!


# A Great Type System to Utilize

<aside class="notes">
In Rust, it is _very_ idiomatic to move as many error cases as possible to compile-time.

If you have been using scripting languages a lot, this may seem unfamiliar, as they don't really have a "compile time".
</aside>

- - -

> Make illegal states unrepresentable
>
> -- Haskell mantra

> The safest program is the program that doesn't compile
>
> -- ancient Rust proverb
>
> Actually: [Manish on Twitter](https://twitter.com/ManishEarth/status/843248038139195397)

<aside class="notes">
Let's dive into some patterns to make your Rust APIs nicer to use.
</aside>

- - -

# Avoid stringly-typed APIs

## Use enums

## Use tuple/unit structs

# Builders

# Accept multiple input types

## Conversion traits

## Cows

# What would std do?

# Iterators

# Extension traits

# Thanks!

## Any questions?
