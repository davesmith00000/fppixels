---
author: "Dave Smith"
date: "2018-12-27"
title: Contravariant Functor Spotting
draft: false
tags: ["scala"]
categories: ["Tutorial"]
---

There are lots of explanations out there on the interwebs about contravariant functors, and perhaps I’m just a bit dim in some regards, but it took me quite a while to get a handle on them.

## Start with Why.

The main issue I have when grappling with some new FP concept is "why". For what do I need this? Most tutorials and discussions satisfy themselves with either a terse showing of this slightly weird function signature:

```scala
def contramap[A, B](fa: F[A])(f: B => A): F[B]

// ..also sometimes (I think more helpfully) rearranged and written as:

def contramap[A, B](f: B => A): F[A] => F[B]
```

"I mean where do you get the `B` from anyway?" I wondered aloud on a number of occasions assuming it worked the way `Functor` worked.

Alternatively, the tutorials give an example of it’s usage, usually by going on about why it’s perfect for implementing `Ordering[T]`. Which is true, but I didn’t find it immediately obvious why!

Oh yeah and everyone will tell you that a Functor is a producer and a Contravariant Functor is a consumer. Ok. Thanks.

What they generally don’t explain is why I would want to do such a thing. That’s a shame, because if you can convey to me the idea of the kind of scenario in which this construct is useful, then I stand a chance of spotting the use case out in the wild.

## A Rule of Thumb.

So here goes nothing, I shall now attempt to describe a general scenario in which contravariant functors are useful:

>A contravariant functor is useful when you need to build an instance of a higherkinded type, such as a typeclass, and the most convenient method of doing that is to base your new typeclass on an existing one, accepting the limits of what that existing version is capable of.

Now armed with that idea, I'll fall back on the `Ordering[T]` example:

1. I want to order a `List[Person]`, which means I need an `Ordering[Person]` instance.
2. There already exists an `Ordering[Int]` instance, it’s part of the standard library.
3. I can *consume* a `Person` to get out some arbitrarily meaningful `Int` to sort against, by making a function `f` that maps `Person => Int` e.g. `person => person.age`
4. It would then be nice if I could *improve* `Ordering[Int]` to *produce* an `Ordering[Person]` instance i.e. `Ordering[Int] => Ordering[Person]` by making use of the `f` function in the previous step.

That "improving" of `Ordering[Int]` to produce `Ordering[Person]` is what `contramap` does. e.g.:

```scala
import scala.language.higherKinds

trait Contravariant[F[_]] {
  def contramap[A, B](fa: F[A])(f: B => A): F[B]
}

case class Person(age: Int, name: String)
object Person {

  // Our aim is to make this:
  // implicit def ordering[A <: Person]: Ordering[A] =
  //   Ordering.by(p => p.age)

  val orderingCV: Contravariant[Ordering] =
    new Contravariant[Ordering] {
      def contramap[A, B](fa: Ordering[A])(f: B => A): Ordering[B] =
        Ordering[B]((b1: B, b2: B) => fa.compare(f(b1), f(b2)))
    }

  implicit val ordering: Ordering[Person] =
    orderingCV.contramap[Int, Person](Ordering.Int)(_.age)

}

List(Person(10, "bob"), Person(2, "Sally")).sorted
// List(Person(2, "Sally"), Person(10, "bob"))

```

## Get the gist?

The thing about the ordering example is that while it feels like an obvious use case... once you see it well... it looks it bit sort of thin.

The way I actually got to grips with this was to work though a different problem entirely, which is available [here in this gist](https://gist.github.com/davesmith00000/db8f066018f048bd9350db1a14004952) if you’re interested.
