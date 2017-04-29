---
title: Idiomatic Rust Libraries
categories:
- rust
- presentation
author: Pascal Hertleif
date: 2017-04-27
# pandoc settings
theme: solarized
progress: true
slideNumber: true
history: true
---

## Hi, I'm Pascal Hertleif

- Web stuff by day, Rust by night!
- Co-organizer of [Rust Cologne]
- {[twitter],[github]}.com/killercup
- Rust-centric blog: [deterministic.space]

[Rust Cologne]: http://rust.cologne/
[twitter]: https://twitter.com/killercup
[github]: https://github.com/killercup
[deterministic.space]: https://deterministic.space/

- - -

This talk is based on my blog post [Elegant Library APIs in Rust][post]
but also takes some inspiration from Brian's [Rust API guidelines][guidelines].

[post]: https://deterministic.space/elegant-apis-in-rust.html
[guidelines]: https://github.com/brson/rust-api-guidelines

<aside class="notes">
I have to warn you: There will be a lot of code. Far too much, actually.
But this is a talk about how to write idiomatic code, so there is no going around it,
short of inventing a new *graphical* pseudo-language.

</aside>

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

<aside class="notes">
Well put, Andrew Hobden!
</aside>

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

### Nice, concise doc tests

Always write them from a user's perspective.

Start code lines with `#` to hide them in rustdoc output

**Pro tip:** Put setup code in a file, then `# include!("src/doctest_helper.rs");`

<aside class="notes">
They are more useful when they can be copy-pasted.

Your user already have setup code, so no need to duplicate this everywhere.

Apropos: I've written about [documentation guidelines](https://deterministic.space/machine-readable-inline-markdown-code-cocumentation.html)

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

## Get more compiler errors!

- `#![deny(warnings, missing_docs)]`
- Use [Clippy]

[Clippy]: https://github.com/Manishearth/rust-clippy

<aside class="notes">
Have you seen how pretty most of the compile errors look? They're really great.
Let's have more of those.

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


# Use the type system, Luke

<aside class="notes">
In Rust, it is _very_ idiomatic to move as many error cases as possible to compile-time.

If you have been using scripting languages a lot, this may seem unfamiliar.
</aside>

- - -

> Make illegal states unrepresentable
>
> -- Haskell mantra

<aside class="notes">
As preferred by that community, the Haskellers puts it in a kinda difficult to read way.

We Rustaceans are more easily hooked by a promise of safety anyway.
</aside>

- - -

> The safest program is the program that doesn't compile
>
> -- ancient Rust proverb
>
> Actually: [Manish on Twitter](https://twitter.com/ManishEarth/status/843248038139195397)

<aside class="notes">
Now *that* I can support! And you can trust him, Maniष Goregaokar knows what he's talking about.

Let's dive into some patterns to make your Rust APIs nicer to use.
</aside>

# Avoid stringly-typed APIs

<aside class="notes">
In dynamically-typed languages, you often use strings as parameters to specify options.
This is not how you do it Rust. Write types instead!

</aside>

- - -

`fn print_in_color(color: &str, text: &str) {}`

. . .

`print_in_color("Foobar", "blue");`

<aside class="notes">
Just a regular function, right?

... oops. Runtime error!
</aside>

- - -

```rust
fn print_in_color(color: Color, text: &str) {}

enum Color { Red, Green, CornflowerBlue }

print_in_color(Green, "lgtm");
```

<aside class="notes">
This is way more idiomatic. Very nice.

Later: `"red".parse::<Color>()?`

</aside>

# Avoid lots of booleans

- - -

`bool` is just

`enum bool { true, false }`

Write your own!

- - -

`enum EnvVars { Clear, Inherit }`

`enum DisplayStyle { Color, Monochrome }`

<aside class="notes">

```rust
fn run(command: &str, clear_env: bool) {}
run("ls -lah", false);
```

becomes

```rust
fn run(command: &str, color: bool) {}
run("ls -lah", EnvVars::Inherit);
```

and

```rust
fn output(text: &str, style: DisplayStyle) {}
output("foo", true);
```

becomes

```rust
fn output(text: &str, style: DisplayStyle) {}
output("foo", DisplayStyle::Color);
```

</aside>

# Builders

- - -

```rust
Command::new("ls").arg("-l")
    .stdin(Stdio::null())
    .stdout(Stdio::inherit())
    .env_clear()
    .spawn()
```

<aside class="notes">
This is using `std::process::Command` to build a subprocess and spawn it.
</aside>

- - -

Builders allow you to

- validate and convert parameters implicitly
- use default values
- keep your internal structure hidden

- - -

Builders are forward compatible:

You can change your struct's field as much as you want

<aside class="notes">
Another example:

In [Diesel PR #868], we wanted to make the `revert_latest_migration` function
work with custom directories. This is a breaking change -- it adds a parameter
to a public function.

My suggestion was to create a `Migration` structure that can only be built by
calling some methods -- a builder, basically -- and add the currently
free-standing functions to it. This way, we can add a lot of new behavior in the
future that may depend on new settings, without breaking backward compatibility.

[Diesel PR #868]: https://github.com/diesel-rs/diesel/pull/868
</aside>


# Make typical conversions easy

- - -

Rust is a pretty concise and expressive language

. . .

...if you implement the right traits


<aside class="notes">
Traits are the basic building block for nice APIs in Rust.

</aside>

- - -

Reduce boilerplate by converting input data

```rust
File::open("foo.txt")
```

Open file at this `Path` (by converting our `&str`)

- - -

Implementing these traits makes it easier to work with your types

```rust
let x: IpAddress = [127, 0, 0, 1].into();
```

<aside class="notes">
Another example:

```rust
use serde_json::Value as Json;

let a = Json::from(42);
let b: Json = "Foobar".into();
```
</aside>

- - -

`std::convert` is your friend

- `AsRef`: Reference to reference conversions
- `From`/`Into`: Value conversions
- `TryFrom`/`TryInto`: Fallible conversions

<aside class="notes">
- A `From` impl implies `Into`
- `Try{From,Into}` are not yet stable

Examples:

- We just saw `impl AsRef<Path> for Path`
- `impl From<[u8; 4]> for IpAddr`

</aside>


# What would std do?

- - -

All the examples we've seen so far are from `std`!

Do it like `std` and people will feel right at home

<aside class="notes">
Rust's std lib is a great resource that every Rust programmer knows

</aside>

- - -

Implement ALL the traits!

> - Debug, (Partial)Ord, (Partial)Eq, Hash
> - Display, Error
> - Default
> - ([Serde]'s Serialize + Deserialize)

[Serde]: http://serde.rs/

- - -

## Goodies: Parse Strings

Get `"foo".parse()` with [FromStr]:

[FromStr]: https://doc.rust-lang.org/nightly/std/str/trait.FromStr.html

```rust
impl FromStr for Validation {
    type Err = ParseValidationError;

    fn from_str(s: &str) -> Result<Self, Self::Err> { }
}
```

<aside class="notes">
One of the lesser known features of std.
You should implement this trait whenever you want to parse a string into a type.

Implemented e.g. for IP address parsing.

Please note that this can fail and you should give it a good, custom error type.

</aside>

## Goodies: Iterator

Let your users iterate over your data types

<aside class="notes">
Iterators are great and many Rustaceans love working with them

Help them by making your data structures implement the Iterator interface!

</aside>


# Session types

- - -

```rust
HttpResponse::new()
.header("Foo", "1")
.header("Bar", "2")
.body("Lorem ipsum")
.header("Baz", "3")
// ^- Error, no such method
```

<aside class="notes">
Let's imagine we're implementing a protocol like HTTP

We first need to write the headers, and then the body of the request

Rust lets us write the implementation in such a way that
after writing the first line of the body you can't call `add_header` any more.

</aside>

- - -

## Implementing Session Types

1. New data type for each state
2. `struct Data<T> { }` + `impl X for Data<Foo> { }` + `impl X for Data<Bar> { }`


# Do we have some more time?

- - -

More time!

More slides!

![](assets/its-happening.gif "It's happening meme gif")


# Iterators

- - -

Iterators are one of Rust's superpowers

Functional programming as a zero-cost abstraction

<aside class="notes">
I'm one of those people who'd rather read

```rust
vec!["foo", "bar"].iter().flat_map(str::chars).any(char::is_whitespace);
```

and who enjoys writing chains of method calls with closures
</aside>

- - -

## `IntoIter` as input

Abstract over collections

Avoid allocations


```rust
fn foo(data: &HashMap<i32, i32>) { }

fn bar<D>(data: D) where
  D: IntoIterator<Item=(i32, i32)> { }
```

<aside class="notes">
This works with

- Other iterators
- HashMaps
- BTreeMap
- LinkedHashMap
- ...
</aside>


## Construct types using FromIterator

The magic behind `.collect()`



# Extension traits

- - -

Write a new trait

- Implement it for types like `Result<YourData>`
- Implement it generically for other traits!


# Example: Validations

`'required|unique:posts|max:255'`

<aside class="notes">
I recently saw this validation definition.
It gets parsed at run-time, which is slow and needs to have unit tests.

This is from [Laravel](https://laravel.com/docs/5.4/validation#validation-quickstart).

Additionally, the syntax for this can be pretty error-prone. Instead of the second pipe I first typed a colon by mistake and it failed silently.
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

struct Table; // somewhere
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

- - -

This way, you can do:

```rust
use std::str::FromStr;

let validations = "max:42|required".parse()?;
```

<aside class="notes">
Type annotations elided. Please use nice error handling.

</aside>


# Thanks!

## Any questions?
