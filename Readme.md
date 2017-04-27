---
title: Idiomatic Rust Libraries
categories:
- rust
- presentation
author: Pascal Hertleif
date: 2017-03-20
# pandoc settings
theme: solarized
progress: true
slideNumber: true
history: true
---

## Pascal Hertleif

- Web stuff by day, Rust by night!
- Co-organizer of [Rust Cologne]
- {[twitter],[github]}.com/killercup
- Rust-centric blog: [deterministic.space]

[Rust Cologne]: http://rust.cologne/
[twitter]: https://twitter.com/killercup
[github]: https://github.com/killercup
[deterministic.space]: https://deterministic.space/

- - -

This talk is an adaption of my blog post [Elegant Library APIs in Rust][post]
but also takes some inspiration from Brian's [Rust API guidelines][guidelines].

[post]: https://deterministic.space/elegant-apis-in-rust.html
[guidelines]: https://github.com/brson/rust-api-guidelines

# Goals for our libraries

## Easy to use

- Quick to get started with
- Easy to use _correctly_
- Flexible and performant

## Easy to maintain

- Common structures, so code is easy to grasp
- New contributor friendly == Future-self friendly
- Well-tested

- - -

> Working in libraries instead of executables, and focusing on the consumer of your API, helps you write better code.
>
> -- [Andrew on Twitter](https://twitter.com/andrewhobden)

# Some easy things first

<aside class="notes">
Let's warm up with some basics that will make every library nicer.

This is more general advice on how to structure your code, not really on how to write great APIs.
We'll talk about those in a minute, though.

I may be rushing through this section a bit fast, but don't worry,
that's just so we can get to really exciting stuff sooner!
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
Doc tests are *integration* tests that are also code examples your users can easily find.

Use regular tests for weird edge cases.
</aside>

- - -

### Nice, consise doc tests

Always write them from a user's perspective.

Start code lines with `#` to hide them in rustdoc output

**Pro tip:** Put setup code in a file, then `# include!("src/doctest_helper.rs");`

<aside class="notes">
They are more useful when they can be copy-pasted.

Your user already have setup code, so no need to duplicate this everywhere.

*Next step:* Readme-driven development (et.al.) with tango et.al.!
</aside>

- - -

## Directories and files

**Basically:** Follow Cargo's best practices

- `src/lib.rs`,
- `src/main.rs`,
- `src/bin/{name}.rs`
- `tests/`,
- `examples/`,
- `benches/`

<aside class="notes">
When you start a project, you might quickly end up with 1 000 lines in a `lib.rs`

Split this up early

Represent your code's architecture in the file system
</aside>

- - -

## Get _more_ compiler errors!

- `#![deny(warnings, missing_docs)]`
- Use [Clippy]

[Clippy]: https://github.com/Manishearth/rust-clippy

<aside class="notes">
Have you seen how pretty most of the compile errors look? They're really great.

`deny(warnings)` turns warnings into errors

`deny(missing_docs)` makes you write documentation for every *public* item

Clippy has over 100 clever lints that help you make sure your code is great.
E.g., when it sees you wrote a bunch of `match`/`if let` code,
it often suggests you use one of the many methods on Option/Result,
which is more concise and idiomatic.
</aside>


## Keep the API surface small

- Less to learn
- Less to maintain
- Less opportunity to introduce breaking changes

`pub use specific::Thing` is your friend

<aside class="notes">
Maybe this is obvious, but the less public items your API actually has,
the less things you have to worry about when making changes or writing documentation.

It's a good practice to hide implementation details. Be careful with those `pub`s!
</aside>


# Use the Type System, Luke

<aside class="notes">
In Rust, it is _very_ idiomatic to move as many error cases as possible to compile-time.

If you have been using scripting languages a lot, this may seem unfamiliar.
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

## Example: Validations

I recently saw this validation definition:

```php
'required|unique:posts|max:255'
```

It gets parsed at run-time, which is slow and needs to be tested.

<aside class="notes">
This is from [Laravel](https://laravel.com/docs/5.4/validation#validation-quickstart).

Additonally, the syntax for this can be pretty error-prone. Instead of the second pipe I first typed a colon by mistake and it failed silently.
This is the probably the worst possible scenario, as it allowed invalid data to be saved.

Let's see how we can make a nicer version of this in Rust.
</aside>

- - -

We have a list of validation criteria, like this:

```rust
[
  Required,
  Unique(Posts),
  Max(255),
]
```

How can we represent this?

## Using enums

```rust
enum Validation {
  Required,
  Unique(Table),
  Min(u64),
  Max(u64),
}
```

This is nice, but hard to extend.

## Use tuple/unit structs

```rust
struct Required;
struct Unique(Table);
struct Min(u64);
struct Max(u64);
```

- - -

And then, implement a trait like this for each one

```rust
trait Validate {
    fn validate<T>(&self, data: T) -> bool;
}
```

## FromStr

If you want to be able to construct something from user input (a string), impl [FromStr]:

[FromStr]: https://doc.rust-lang.org/nightly/std/str/trait.FromStr.html

```rust
impl FromStr for Vec<Validation> {
    type Err = ParseValidationError;
    fn from_str(s: &str) -> Result<Self, Self::Err> { ... }
}
```

This way, you can do:

```rust
let validations = "max:42|required".parse()?;
```

<aside class="notes">
Type annotations elided. Please use nice error handling.
</aside>

# Builders

# Accept multiple input types

## Conversion traits

- Reduce boilerplate by automatically converting input data

## Cows

# What would std do?

# Iterators

# Extension traits

# Session types

## Dangers: Shitty error messages

```text
// insert diesel error message with invalid filter
```

<aside class="notes">
Example: Diesel

- has traits for query builder things, like `FilterDsl` and `OrderDsl`
- they are implemented for all types with some constraints
- sadly, that means that when you want to use `.filter` with an invalid query, you get an `unknown method filter, note: FilterDsl is implemente for <fuuuuuuuuu>` message
</aside>

# Thanks!

## Any questions?
