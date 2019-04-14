---
author: "Dave Smith"
date: "2019-01-05"
title: "Devlog: Job Systems"
draft: true
tags: ["scala", "devlog"]
categories: ["Game Development", "Game Devlog"]
---

![img](/fppixels/images/wandering-about.gif)

Slightly more than a month after I first said "I'm going to build a job system", I'm relieved to say that its finally working. In the screen capture above the little dude has two possible jobs he/she/it can be doing:

Wandering and Loitering.

## Danger! Rabbit Hole Ahead!

The main reason why building your own game engine is a bad idea (if your aim is to make a game) is very simple: It's a massive time sink that distracts you away from building your game!

An anecdotal example, but this happens all the time:

*Me, posting on Slack:*

>"My character now appears on screen and falls towards the tile map world below - yay progress! Just need to make him stop when he hits the ground. Be right back."

*Me, after two weeks of hard spare-time coding:*

>"...Ok he now stops when he hits the ground..."

The issue is that, if you're like me, then you build things as you need them, and sometimes you suddenly realise that you need a whole heap of things all at once that previously hadn't crossed your mind.

## Conceptual headaches.

![img](/fppixels/images/3-wandering-about.gif)

In the case of the job system the missing functionality was the notion of [sub-systems](https://davesmith00000.github.io/fppixels/posts/2018-12-28-devlog-2-subsystems/). Once sub-system were in though, a new problem emerged: I couldn't work out what "doing work" actually meant.

There are a few components to the job system, but the most revealing one is the `Worker` typeclass:

```scala
trait Worker[Actor, Context] {
  def isJobComplete(actor: Actor): Job => Boolean
  def onJobComplete(actor: Actor, context: Context): Job => JobComplete
  def workOnJob(gameTime: GameTime, actor: Actor, context: Context): Job => (Job, Actor)
  def generateJobs: () => List[Job]
  def canTakeJob: Job => Boolean
}
```

The job system needs an instance of a `Worker` in order to know how work is done and what the consequences of doing the work are. What does it even mean to do work?

```scala
def workOnJob(gameTime: GameTime, actor: Actor, context: Context): Job => (Job, Actor)
```

What the signature above says is:

> A specific type of worker, does work at a certain time, in a certain setting, and doing that work affects both the job and the worker performing the task.

Sounds easy enough but it took an awfully long time to arrive at that understanding.
