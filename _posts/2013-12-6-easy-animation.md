---
title: 动画的简单抽象
layout: default
---

这段代码里包含对于动画的一个简单抽象，后面的动画逻辑通过这个抽象实现。在这个抽象里，动画的持续时间，动画的帧率，动画的状态变化，以及状态如何表现为图形，这些方面都是正交的。即：你可以只延长动画的播放持续时间，而不改变动画的帧率等其它属性；或者只改变动画的刷新帧率，而不改变动画播放持续时间等；当然你还可以只改变动画的绘制方式，而不需要改变动画状态的定义等其它属性，等等。

- [测试页面][h1]
- [测试页面2][h2]

[h1]: {{ site.res }}/youwo_wap_t/test.html
[h2]: {{ site.res }}/youwo_wap_t/test2.html

