---
layout: default
title: 博客搭建日志
---

- 布局模板的获取: 自己写网页布局的模板可能需要大量时间和相关知识, 比如我只了解一些html, 但是css就不会了, 我的办法是用github pages提供的模板, 然后修改它给的main.html (我是直接把它做成了layout文件), 就可以得到漂亮的界面了, 还可以利用自己的html知识做一些适当的调整. 当然如果这些你都会,并且有时间的话,自己写是最好了.
- 使用相对路径引用css会出问题: 因为相对路径相对的是当前文件, 不同位置的文件引用同一个文件可能需要用不同的相对路径, 使用完整的url可以简单地解决这个问题. 比如我是用"http://luochen1990.github.io/stylesheets/styles.css"来引用我的css文件的. 这样可能存在 需要多次访问DNS服务器 从而导致访问速度慢 的问题, 最好的解决方案有待研究.
- 默认解释器对中文支持有问题: 列表项标记"- "后面接中文会无法解释为列表项 . 改用设置markdown: rdiscount就好了.
- 图片的储存问题: 我现在用的liquid脚本只能获取 "_posts" 目录下面的.md (或者别的文本类型)文件的列表 , 如果.md文件中引用了图片, 那么存放在哪儿以及如何命名是个问题. 我现在的解决办法是, 将所有post引用的资源(包括图片,pdf等), 存放在 /res 下面, 并且以它们的 hash值(我用的CRC32).后缀 作为文件名. 但是这样做可能存在迁移困难的问题(也许是我想多了).
- 给主页添加搜索框, 可以参考[这里][1], 在[Google的网站站长工具][2]上验证自己是网站所有者出了点小问题.

[1]: http://yysfire.github.io/webdesign/how-to-add-google-custom-search-to-github-pages.html
[2]: https://www.google.com/webmasters/tools

