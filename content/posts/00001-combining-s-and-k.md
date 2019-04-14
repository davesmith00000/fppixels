---
author: "Dave Smith"
date: "2017-10-27"
title: Combining S and K
draft: false
tags: ["scala", "combinators"]
categories: ["reference"]
---

While attempting to follow an Agda tutorial in Scala ([CS410 2017 Lecture 2 (more Programs and Proofs, introducing "with") - Conor McBride](https://www.youtube.com/watch?v=qcVZxQTouDk)), some understanding of combinators S and K finally began to dawn.

“It is perhaps astonishing that S and K can be composed to produce combinators that are extensionally equal to any lambda term, and therefore, by Church's thesis, to any computable function whatsoever” ~ [Combinatory Logic, Wikipedia 27/10/17](https://en.wikipedia.org/wiki/Combinatory_logic)

Here they are presented in Scala:

```scala
def combinatorK[A, E]: A => E => A =
  a => _ => a

def combinatorS[E, S, T]: (E => S => T) => (E => S) => E => T =
  est => es =>
    (e: E) => est(e)(es(e))
```

Using S and K to build an identity function. Watch the tutorial to find out why `X` and `Any` are needed here:

```scala
def id[X]: X => X =
  combinatorS(combinatorK[X, Any])(combinatorK)
```

Examples:

```scala
combinatorK("Hello")(10)
//res0: String = Hello

combinatorS((_: Int) => (s: String) => s.length > 5)((_: Int).toString)(100010)
//res1: Boolean = true

id(“foo”)
//res2: String = foo
```

...and if you liked that, maybe you should take a peek at [Unlambda](https://en.wikipedia.org/wiki/Unlambda)?
