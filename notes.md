Rust has been a stable lang for just 2 years, little time to actually develop idioms

- - -

Rust has a few very important concepts/building blocks, _the rest is dioims_!

> Everything is...
>
> * an expression
> * a value
> * a pattern
> * a trait
> * a function
>
> <!--
> It's really common in Rust to hear "we don't have that because everything is (read list)".
>
> This gives Rust code a certain uniformity and shallowness. There's like 5 or 6
> concepts you really need to know, and then everything else is idioms.
> -->
>
> from https://gankro.github.io/talks/swift-kun/#20 or https://raw.githubusercontent.com/Gankro/gankro.github.io/master/talks/swift-kun/index.md

- - -

> Working in libraries instead of executables, and focusing on the consumer of your API, helps you write better code.
>
> https://twitter.com/andrewhobden/status/852561623323729921

- - -

What is good Rust?

- Expressive, static type system
  - Stringly typed no more
  - Prevent wrong things from happening
  - inference
  - overloading?
- Use ownership rules to track resources
- Nice APIs as zero-cost abstractions

---

## Examples

- serde-json api
  - `index() -> Value` never panics
  - `From` and `PartialEq` works for a whole lot of cases
- diesel's query builder
  - good and bad, i.e., type-safe but complicated
  - generic trait impls hard to document
  - session types
- diesel migration api refactoring
- laravel validation api as example for a stringly typed api
  - rewrite it in Rust


- - -

> it is happening

for extra slides


- - -

- API is not surprising
- impl all the std goodies
- _you_ use the type system to the max, not the api users
	- stringly typed no more
	- bool args can often be nicely named enums
	- builder pattern & session type magic
- forward compat
	- very shallow api surface (reexport few things instead of `pub mod all_the_mods`)
	- cargo features for external deps
	- builder pattern instead of pub fields

