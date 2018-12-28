---
author: "Dave Smith"
date: 2018-12-28
title: Devlog 2: Sub Systems
draft: true
---

In my previous game devlog I mentioned encoding the idea of subsystems into Indigo so that I could nicely organise a job system for the various actors in the game.

The subsystems came together quickly and easily, the job system is still a work in progress. Since I haven't written for a while though, I thought I'd explain how the subsystems work.

<insert a screenshot of the points tracker working>

Here is the definition of a SubSystem:

```scala
trait SubSystem {
  type Model
  type EventType

  val eventFilter: GlobalEvent => Option[EventType]

  def update(gameTime: GameTime): EventType => UpdatedSubSystem

  def render(gameTime: GameTime): SceneUpdateFragment

  def report: String
}
```

Here's an example:

```scala
final case class PointsTrackerSubSystem(points: Int, fontKey: FontKey) extends SubSystem {
  type Model     = PointsTrackerSubSystem
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

Usage:

No need to explicitly call update, we just need to send it an event and the magic happens:

```scala
def update(gameTime: GameTime, model: Unit): GlobalEvent => UpdatedModel[Unit] = {
  case MouseEvent.Click(_, _) =>
    UpdatedModel(())
      .addGlobalEvents(PointsTrackerEvent.Add(10))

  case _ =>
    UpdatedModel(())
}
```

Rendering is taken care of:

```scala
def present(gameTime: GameTime, model: Unit, viewModel: Unit, frameInputEvents: FrameInputEvents): SceneUpdateFragment =
    noRender
```

Talk about:
- Scaling by composition
- SubSystems as a tiny version of the whole
