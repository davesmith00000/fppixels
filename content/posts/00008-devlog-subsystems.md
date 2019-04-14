---
author: "Dave Smith"
date: "2019-01-01"
title: "Devlog: Sub-Systems"
draft: false
tags: ["scala", "devlog", "indigo"]
categories: ["Indigo Game Engine Design", "Game Devlog"]
---

In my first devlog I mentioned the idea of adding sub-systems to Indigo so that I could nicely organise a job system for the game I'm working on.

The sub-systems came together quickly and easily, but the job system is still a work in progress. Since I haven't written for a while though, I thought I'd explain what sub-systems are and how they work.

## Quick Example

![img](/fppixels/images/subsystems-example.gif)

The example above uses two sub-systems:

1. A simple sub-system to count the total points
2. Another called an Automata Farm that handles the animated points that appear when the mouse button is clicked.

I'm not going to talk about the Automata Farm now. It existed long before sub-systems and it's been fun converting it to the new cleaner sub-system approach.

## What makes a Sub-System?

Here is the definition of a `SubSystem`:

```scala
trait SubSystem {
  type EventType

  val eventFilter: GlobalEvent => Option[EventType]

  def update(gameTime: GameTime): EventType => UpdatedSubSystem

  def render(gameTime: GameTime): SceneUpdateFragment

  def report: String
}
```

The interesting thing about sub-systems is that the definition above is really just a cut down version of the functions that make up the entire game engine.

The main game loop essentially has three stages:

1. Update the models
2. Update the view models
3. Present the scene

A sub-system just does 1 and 3, since 2 felt like overkill for what are supposed to be small processes.

During update, the game loop propagates each event from an immutable list of "stuff that happened in the previous frame" to all of the sub-systems and the user defined game functions. Each of those functions results in an `Update<Thing>` type such as the `UpdateSubSystem` above. `UpdateSubSystem` includes the next version of the sub-system (i.e. state that progresses over time) and a list of output events (consequences) that occurred as part of the update process. The state is persisted and the events are queued up ready to be processed on the next frame.

Render (or present - terminology is a bit inconsistent at the moment) is then called everywhere which eventually results in a list of `SceneUpdateFragment`s. Since the fragments are Monoids they are simply folded together to create the final scene to be presented.

Here is our points tracker (the top left bit of the screenshot):

```scala
final case class PointsTrackerSubSystem(points: Int, fontKey: FontKey) extends SubSystem {
  type EventType = PointsTrackerEvent

  val eventFilter: GlobalEvent => Option[PointsTrackerEvent] = {
    case e: PointsTrackerEvent => Option(e)
    case _                     => None
  }

  def update(gameTime: GameTime): PointsTrackerEvent => UpdatedSubSystem = {
    case PointsTrackerEvent.Add(pts) =>
      UpdatedSubSystem(this.copy(points = points + pts))
  }

  def render(gameTime: GameTime): SceneUpdateFragment =
    SceneUpdateFragment.empty
      .addGameLayerNodes(Text(report, 10, 10, 1, fontKey))

  def report: String =
    s"""Points: $points"""
}

sealed trait PointsTrackerEvent extends GlobalEvent with Product with Serializable
object PointsTrackerEvent {
  final case class Add(points: Int) extends PointsTrackerEvent
}
```

In this example the event type didn't need to be an ADT, but I wanted to show the intended usage.

## Integrating a Sub-System

A big part of point of sub-systems is that you set them up, send them events, and let the engine take care of the boring details. The other side is there sub systems are for modelling things that are fairly loosely coupled, components you can write a test in isolation and that you don't want cluttering up your game code. As such, the integration code is very light.

The first thing we have to do is register our sub-systems, like this:

```scala
val subSystems: Set[SubSystem] =
  Set(PointsTrackerSubSystem(0, fontKey))
```

Everything has to be updated, but Indigo takes care of that. The only thing we must do is poke them with relevant events. In this case we send off an "Add 10 points" event.

Note that the "model" of this game is of type `Unit` because there is no model - don't worry about it. Each sub-system *is* it's own model and we're only using sub-systems in this example.

```scala
def update(gameTime: GameTime, model: Unit): GlobalEvent => UpdatedModel[Unit] = {
  case MouseEvent.Click(_, _) =>
    UpdatedModel(()).addGlobalEvents(PointsTrackerEvent.Add(10))

  case _ =>
    UpdatedModel(())
}
```

Likewise, rendering is taken care of because each sub-system is rendered separately in the background and our game only uses sub-systems to do all the presenting.

```scala
def present(gameTime: GameTime, model: Unit, viewModel: Unit, frameInputEvents: FrameInputEvents): SceneUpdateFragment =
    noRender
```

Nice and easy.
