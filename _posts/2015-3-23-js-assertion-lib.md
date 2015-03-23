---
title: 关于我理想中的断言库
layout: default
tags: Javascript, assert, assertion, AST, CoffeeScript, coffee-mate, macro, lisp
---

写断言语句是程序开发过程中用来保证程序质量的一个常用方法。

比如写上`assert fib(0) == 0 and fib(1) == 1`就可以用来保证你的fib函数的初始值的正确性了。当这些语句执行后被发现其值为假的时候，程序就能打印一些相关信息，比如断言出错的语句在哪一行，这一行的内容是什么，等等。

在Javascript中，很多单元测试框架也依赖这样的断言语句。 但可惜的是，Javascript中并没有一个现成的assert语句，这是件非常恼人的事情。

我的实现
--------

我曾经自己实现过一个断言语句，它现在被包含在[`CoffeeMate`](https://github.com/luochen1990/coffee-mate/wiki)这个库里。这个断言语句其实就是一个名为`assert`的函数，在[`CoffeeScript`](http://coffeescript.org/)里你可以这样使用它：

```coffeescript
assert -> fib(0) is 0 and fib(1) is 1
```

当断言出错的时候它会打印出：
```
Assertion Failed: fib(0) === 0 && fib(1) === 1
```

同时在`CoffeeMate`里实现的，还有`log`函数，它会在你写`log -> 1 + 2`的时候，打印`## 1 + 2 ==> 3`。

实现完这个之后，自己用起来还是很开心的。美中不足的地方仅仅是

1. 打印出的表达式是被编译成js之后的表达式，而非原始的CoffeeScript表达式，这是因为通过`fun.toString()`我只能得到js代码
2. 要求该表达式是简单表达式（即`fun.toString()`是`function(){return ...}`的形式），否则打印效果不理想，常见的情况是`log -> (i*i for i in [1..3])`，这种情况下CoffeeScript会生成一段构建列表的代码来实现列表解析，所以这时候fun.toString()是`function(){... ; return ...}`的形式。

其他人的实现
------------

正当我得意的时候，我发现那些js单元测试框架所用的断言库，干了一些更扯淡的事情：它们定义了一套语法来做这事儿！！

比如，如果你用[`chai`](https://github.com/chaijs/chai)这个断言库，你需要写成这样：

```coffeescript
expect(fib(0)).to.equal(0)
expect(fib(1)).to.equal(1)
```

当然，现在我知道，他们这么干不是完全没有道理的。比如他们可以在断言失败的时候，打印出`fib(0)`和`0`的值，这样你能清楚地知道他们为嘛不相等，比如你能得到类似`expect 0 but got 1`这样的信息。

不过可惜的是，这些断言库仍然不能打印出原始的表达式，于是当你在单元测试代码中写下以下代码的时候，如果其中一句出错，你很难判断究竟是三条断言语句中的那一条出错了。

```coffeescript
describe 'fib', ->
	it 'should have correct start', ->
		expect(fib(0)).to.equal(0)
		expect(fib(1)).to.equal(1)
		expect(fib(2)).to.equal(1)

	it 'should satisfy the recursive property', ->
		expect(fib(3)).to.equal(fib(1) + fib(2))
		expect(fib(4)).to.equal(fib(2) + fib(3))
		expect(fib(10)).to.equal(fib(8) + fib(9))
```

所以为了能清楚地确定错误的位置，你最好在每一个it里只写一个断言语句，于是你要写的测试代码变成了以下。。

```coffeescript
describe 'fib', ->
	describe 'fib should have correct start', ->
		it 'fib(0) === 0', ->
			expect(fib(0)).to.equal(0)
		it 'fib(1) === 1', ->
			expect(fib(1)).to.equal(1)
		it 'fib(2) === 1', ->
			expect(fib(2)).to.equal(1)

	describe 'fib should satisfy the recursive property', ->
		it 'fib(3) === fib(1) + fib(2)', ->
			expect(fib(3)).to.equal(fib(1) + fib(2))
		it 'fib(4) === fib(2) + fib(3)', ->
			expect(fib(4)).to.equal(fib(2) + fib(3))
		it 'fib(5) === fib(3) + fib(4)', ->
			expect(fib(5)).to.equal(fib(3) + fib(4))
```

太可怕了！ 这样写的测试代码，不仅包含了太多冗余（差不多就是每个测试表达式写两遍），而且也失去了`describe`和`it`的语义（你可以看到上面一段测试代码完全是可以念出来并且是可以理解的句子的，而下面这段就不行了）。

我理想中的
----------

理想中的断言库当然应该能够在断言失败的时候打印足够多的信息。更多的信息能让我们更容易捉住bug，省去了我们自己一个个子表达式地log的时间，在更复杂的情况中（依赖环境状态的情况），也省去了我们恢复现场的时间。

想要不分析AST而打印出和chai一样多信息并且同时打印出表达式本身的办法不是没有，比如，写成`assertEq (-> fib(3)), (-> fib(1) + fib(2))`。事实上我还可以定义一些更有意思的东西，比如以haskell中的`on`函数为灵感，我们可以定义一个`assertEqOn`，比如我们可以写`assertEqOn(abs) (-> fib(3)), (-> fib(1) + fib(2))`，`assertEqOn(length) (-> 'abc'), (-> '123')`，`assertEqOn(json) (-> arr), (-> [1, 2])`等等。当然这跟chai的做法也差不太多了，都是要定义一堆比较函数什么的。。

事实上，也许我们debug需要的信息远比这些做法能打印的要多。比如在`assert -> fib(3) == fib(1) + fib(2)`的例子中，在断言失败的时候我们可能需要log的子表达式有：`fib(3)`, `fib(1) + fib(2)`, `fib(1)`, `fib(2)`。也许你会问这样会不会打印得太多了，会不会多到没法看？ 那么在一个更复杂的表达式里，这些子表达式会有多少个呢？ 好吧，你已经看出来了，其实这就是表达式对应的树形结构里所有非根非叶子结点的个数了。所以可以放心，子表达式的个数大约是关于表达式长度线性增长的，不会多到没法看。

所以像诸如chai这样的断言库的做法（也就是写成`expect(fib(3)).to.equal(fib(1) + fib(2))`的样子），仅仅是打印了第一层子树对应的表达式（在以上例子中，就是`fib(3)`和`fib(1) + fib(2)`），而如果你想知道得更多，那它也无能为力了（比如`fib(1)`和`fib(2)`的值就不会被打印出来）。我想强调的是，打印更多的子表达式是很有必要的，在以上例子中，知道`fib(1)`和`fib(2)`各自的值对于debug的确是很有帮助的。

假如我们为了避免分析AST（抽象语法树）而采用了类似chai的做法，那么想要打印出所有子表达式的话，得写成类似`expect(fib(3)).to.equal(fib(1).plus(fib(2)))`这样子才行（其实就是用自定义的函数替代了原始的算符从而可以有办法重新构造出一个树形结构）。关于这个方案，我只想说：太丑了根本没法看！

所以，似乎完美的方案是绕不开分析AST这一步了。如果要分析AST必然会引入一个比较复杂的库来做。在nodejs端不需要考虑体积问题，可是在页面上的话，js的体积和体验是有关的。然后我看了一下用来分析js code获取AST的库。自称tiny & fast的[acorn](https://github.com/marijnh/acorn)也有2800+行代码（101kb）的体积，当然这是并没有做压缩且包含注释的情况，目测压缩之后的代码体积应该在10k~30k之间，还是相当不错（tiny）的了。另外对于断言库的依赖也完全可以在构建期决定，比如在开发时构建包含断言库的版本，在发布时则用`assert = function(){}`来代替。所以结论是，断言库体积的问题不大。

（我们谈到了很多关于“是否要引入一个js语法解析器”的权衡，而在lisp语言中，这种问题是完全不存在的，你要做的仅仅是定义一个宏。。

所以，实现这个理想断言库的大致思路就是：
1. 通过fun.toString()拿到代码，
2. 然后通过acorn拿到代码的AST
3. 然后根据AST求表达式的值，在求值过程中记录每一个子表达式的结果
4. 当整个表达式的结果为false的时候，抛出一个包含完整信息（所有子表达式值）的异常

不过，，不过，，，这难道不是在实现一个js解释器么。。

所以我不打算做这件事了，这已经不是造轮子或不造轮子的问题了。假如要想让一辆车happy地跑起来，我们得为此造一辆汽车。。。那么，这应该不是我们做得不够好，而是汽车本身造得有问题了。。

可以想象在js引擎中实现一个这样的assert并不困难。假如我今天花了大力气折腾出这么一个东西，然后明天js标准里就包含了（老赵的[Wind.js](https://github.com/JeffreyZhao/wind)就是一个例子，其通过hack实现的async, await已经被包含到[ES7](http://es6.ruanyifeng.com/#docs/promise)中），我不会开心的。。。

事实上，即使js引擎不提供这样的一个assert语句，而是提供了一种访问AST的方式（而不是仅仅提供一个fun.toString()这样的玩意），允许用户获取一个函数的AST（比如`fun.toAST()`），并且可以对AST进行求值（比如`evalAST(the_ast_of_fun)`），那么我实现起一个这样的assert也会简单得多得多。。。

（事实上，[python](https://docs.python.org/2/library/ast.html)之类的不少动态语言都提供了访问AST的机制。当然，关于Javascript的AST格式并没有一个标准，所以这事儿实现起来并不容易。。

