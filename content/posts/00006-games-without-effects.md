---
author: "Dave Smith"
date: "2018-12-23"
title: Building Games Without Effects
draft: false
tags: ["scala", "indigo"]
categories: ["Indigo Game Engine Design"]
---

## TL;DR:

Indigo does not [generally] have any Monads or Functors exposed on it's APIs. This is intentional since you're not allowed to error and everything is synchronous.

## Monads that power the internet

As I suspect is the case with the majority of Scala developers, my day job is largely about server side programming, building microservices and the like.

In the context of server-side programming you simply cannot move for Monads. To clarify though: I don’t really mean Monads, what I really mean is effectful types. They could also be Functors or Applicatives for instance, but usually people talk about Monads and effect types interchangeably, so forgive me if you find that inaccurate.

Two of the common effects people often try to model are:

1. Working in a context with the possibility of an error e.g. using `Option`, `Either`, or `Try`
2. Working in the context of concurrency / latency e.g. with `Future`, `Task`, or `IO`

Here is an example from the [Http4s 0.18 docs](https://http4s.org/v0.18/dsl/) that is talking about how Http4s describes / models routing as a function:

>Recall from earlier that an `HttpRoutes[F]` is just a type alias for `Kleisli[OptionT[F, ?], Request[F], Response[F]]`.

So that’s:

1. A `Kleisli` - the monad compositor, used to glue routes together - of...
2. An `OptionT` - a monad transformer on `Option` denoting that there may not be a matching route (a kind of error) in the context of `F` (more on that later)...
3. Of a `Request[F]` and a `Response[F]` where Request and Response are not themselves Monads...
4.  But what about that `F`? Well, because of it’s position in the Monad Transformer, we know:
    - The `F` type is going to be a higher kinded type, some sort of Functor.
    - Moreover, it’s in a *Monad* transformer so I think its safe to go right ahead and assume that not only is `F` a Functor, but it’s also a Monad.
    - The `F` type is there to grant some sort of effectual context, and given that this is an Http service framework, it doesn’t require much imagination to assume that `F` will be handling concurrency and the possibility of errors.

Phew! Quite a lot going on there, but all perfectly reasonable I hope you’ll agree:
You have a bunch of routes to join together and each one may or may not contain a match for the incoming request. They’re likely to perform a concurrent operation like calling another service or accessing a database, while dealing with the fact that errors can happen during such activities.

Key point:
If you agree with the argument in point 4, then we can agree the function signature is forcing us to accept and deal with the fact that F is a Monad that operates in the context of concurrency and errors, and that we the programmer will have to code with the expectation in mind.

## Monads in Indigo

If you boiled down Indigo’s functions to a single basic activity that’s performed every frame, you might be left with something looking like this made up function:

```scala
(GameState, List[GlobalEvent], GameTime) => (GameState, List[GlobalEvents], RenderedView)
```

Which is to say that we take the game state from the last frame, and combine it with a list of stuff that happened during the last frame and the current game time (as all games are time based simulations). The result of merging those things together is an updated game state, a new list of things that happened during this frame, and a rendered view of the game to show back to the player.

No Monads there though. Why not? Surely this is some naive omission in the API design?

### Handle your errors like a grown up

What should happen in a video game when an error is encountered? Depends on the error!

There are really only two error scenarios, and the first is armageddon. If you throw an exception in Indigo, the entire game will simply halt. It’s blue screen of death time, and the reason for that design choice is that this isn’t how you should be handling errors, so we assume that an exception is truly exceptional and devastating.

The other error scenario is, for example, an http request to the leaderboard failed. Should the world end? No! You should tell the player that something went wrong, recover, and carry on.

So no Monad’s denoting errors, no automatic recovery on error by the framework. You are not operating in a context where errors are deemed acceptable, and so you don’t get any support for errors in the function signature.

### No concurrency (sort of)

Indigo can be thought of as being entirely synchronous and super predictable.

At the time of writing, we compile to JavaScript in the browser, which means no threads. No threads means no contention, no blocking, no awaiting, no parallelism.

Concurrent actions like Http requests are performed via callbacks that Indigo hides away, so you emit an `HttpRequest` event during one frame, and an `HttpResponse` event comes back at the start of some later frame for you to handle just like any other world event available for you to respond to.

No explicit concurrency means no concurrency monads. You are not operating in a context where concurrency is described or should be used.

## So.. no Monads at all?

Well no. When building a game in Indigo you can use whatever Monads you like, and Indigo itself does use Monads. A few are visible such as the `Future`'s returned on an async config or asset load (yes, I know I said everything was synchronous, in practical terms it is), but most are hidden away. For example, earlier I mentioned that if an exception is thrown the game stops. Well, that’s a series of sequential operations that handles the possibility of an exception occurring and reports what happened, and sure enough in the depths of the engine, there's a Monad doin that.

The important point is that like Http4s, we are trying to drive programmer behaviour by the type signature (I may or may not be succeeding). In the case of Http4s, you *must* acknowledge that errors and concurrency are concerns. In Indigo you *must* not have errors or return anything that you expect to be evaluated or become a real value at some later time.

## Naive?

Quite possibly. At some point I’d like to add support for JVM, WASM and native compile targets. Those platforms are more complex beasts that may add requirements around things like threading, and I imagine that I’ll have to reconsider the use of Monads to capture effects when / if that happens.
