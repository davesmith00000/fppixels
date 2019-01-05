---
author: "Dave Smith"
date: 2019-01-05
title: "Devlog 3: Job Systems"
draft: true
---

![img](/fppixels/images/3-wandering-about.gif)

Slightly more than a month after I first said "I'm going to build a Job system", and they're finally working. In the screen capture above, each little dude has (at the moment) two possible jobs he/she/it can be doing: Wandering and Loitering.

## Danger: Custom Game Engine Ahead!

The main reason why building your own game engine is a bad idea (if your aim is to make a game) is very simple: It's a time sink that distracts you away from building your game.

As an anecdotal example:

Me posting on Slack:
> My character now appears on screen and falls towards the tile map world below - yay!

Two weeks of hard (spare time) coding later I posted:
>...and now the little guy stops when he hits the ground!

What happened for two weeks? Well! My tile map was build on a quad tree data structure and I was missing a few things:

1. I didn't yet have methods to looks up sub grids by bounds
1. I didn't have a representation for rays or line segments
1. Subsequently I also didn't have a way to extract all the grid squares a ray passed through
1. I didn't have a method of doing even simple collision detection (lines, lines + bounds, or bounding boxes)

The issue is that you don't know what's missing from your engine until you need it and it isn't there. Of course, once I had all that stuff making him "land" was a piece of cake.
