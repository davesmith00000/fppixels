---
author: "Dave Smith"
date: "2018-11-20"
title: A Thundering Herd of Naked Dudes!
draft: false
tags: ["scala", "performance", "indigo"]
categories: ["Game Development"]
---

![img](/fppixels/images/thundering_herd.png)

This is a thundering herd of 5000 naked dudes.**

They are here to complain about the fact that Indigo allocates far too often, causing garbage collections that hurt performance in busy scenes. Unfortunately, while the concerns of the amassed pixelated naturists have been heard and acknowledged ...they'll just have to wait.

Performance is good enough for now, my time is limited, and I'm still collecting data. That said! I'd like to offer an example what direction the data I've collected so far is pointing in:

Indigo's internal reporting system reckons the thundering herd scene causes it to spend its time in roughly these proportions...

```
Model update:         0.11%
View model update:    0.11%
Call view update:     9.18%
Process view:         6.65%
Convert view:         37.58%
Render view:          45.41%
Play audio:           0%
```

I'd hate to jump to any early conclusions, but it may just be possible that the view conversion and rendering stages could use some love.

**Not a real case of [the thundering herd problem](https://en.wikipedia.org/wiki/Thundering_herd_problem) ...but I thought it was funny and the name stuck.
