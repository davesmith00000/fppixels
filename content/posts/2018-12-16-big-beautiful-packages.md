---
author: "Dave Smith"
date: 2018-12-16
title: Big Beautiful Packages
draft: false
---

## TL;DR:

You can use package objects to alias types making your library's imports easier to work with, aid encapsulation, and act as an interface. Big popular libraries do this, I just hadn’t realised the benefits until recently.

### Authors note:

This post has been sitting in draft for a while. At the time I originally wrote it, I was unreasonably excited about this little trick, but you may find this underwhelming...

Still reading? Well don't say I didn't warn you.

### A nicer editor

It all started with a re-occuring unease I have with how we Scala developers are completely bound to Intellij IDEA. Intellij is amazing of course, but I don't like the non-standard Scala type checker or that it's our only serious choice.

After quite a lot of digging and experimenting with editors, configurations and plugins; I found that for simple creation and editing I actually prefer using Atom (with the SBT plugin, or Metals) to Intellij. Sadly, Atom isn't quite sufficient for all my day to day needs and so I’m sort of alternating between the two.

One problem is that while I personally preferred the code writing experience in Atom; discovery and navigation through unfamiliar / long forgotten project structures without Intellij is rather hard going. That’s not the real killer though. While navigating a local codebase may be hard, finding your way around third party libraries when your editor doesn’t understand the source code is nigh on impossible. This reduces you to doing the unthinkable: Reading the API docs. How tedious.

### Where am I going with this?

One thing that’s always interested me when observing other programmers in their natural habitat, is how much their choice of text editor affects the way they construct and organise code. For example, in general I find people who use IDE’s that make navigation trivial tend to be more liberal and expressive with their package hierarchies than people editing in a terminal based text editor. I’m not saying that’s universally true, just my own observations, but it leads me to a question:

How could targeting users who prefer editors like Atom or VIM affect our library design, specifically the problem of figuring out what imports are needed?

### Package Objects to the rescue!

The solution I’ve come up with for Indigo is to make better use of the package object.

A package object basically lets you import code that’s associated with a whole package, for example, if you had a package structure like `myamazinglib.utils`, then a package object at that level would let you do something like this (...not that you would):

```scala
package myamazinglib.utils {
  implicit def toOption[A](a: A): Option[A] = Option(a)
}
```

Allowing for:

```scala
import myamazinglib.utils._

val maybeMessage: Option[String] = "Hello, World!"
```

Not everyone’s cup of tea I’m sure, but you get the idea.

But I learned a thing! Another handy use for package objects is that you can set aliases. For example:

```scala
package myamazinglib.utils {
  // type only if it is just a trait / type
  type AbstractTool = tooling.AbstractTool

  // type and val if it has members you’d like to access
  type CleverTool = tooling.helpers.CleverTool
  val CleverTool: tooling.helpers.CleverTool.type = tooling.helpers.CleverTool
}
```

And that means you can write code like this:

```scala
import myamazinglib.utils._

val tool: CleverTool = CleverTool(...)
```

Without having to know the entire path to the class! Much better!

But that’s not all: Your packages are now acting like an interface, so if your code moves behind the scenes your users won’t necessarily notice, and you only need to expose the types that people really need via the package object.

Neat! Underwhelming ...but neat!
