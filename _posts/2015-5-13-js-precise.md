---
title: Javascript中对数值取N位有效数字
tags: Javascript, precise, float, 有效数字, 科学计数
layout: default
---

问题
----

问题很简单，就是设计一个函数，给定n和x，返回对浮点数x取n位有效数字的结果。（隐含要求是：返回的结果被打印出来应该是reasonable的）

函数签名如下：

```coffeescript
precise = (n) -> (x) -> x'
```

这个函数的两个参数被我设计成了科里化的形式，因为`precise(n)`返回一个函数，这个函数的语义是“对参数x取n位有效数字”，这个语义还是比较明确的。

实现
----

这个问题首先能想到有三种解决方法，按照解决方案从优到劣依次为：

1. 查Math看有没有内置方法可以直接解决
2. 自己通过数值计算解决
3. 通过先转字符串处理，取到两位有效数字后再转回数值

然后，开始爬坑了：

首先，浏览了一遍Math的API，没有发现可以直接解决问题的东西。

于是，打算自己通过数值计算实现一个，然后，就写了下面的代码：

```coffeescript
precise = (n) -> (x) ->
	r = floor(Math.log10(x))
	a = (10 ** (n - 1 - r))
	floor(x * a) / a
```

[这里可以试运行](http://luochen1990.me/try_coffee?#cHJlY2lzZSA9IChuKSAtPiAoeCkgLT4KCXIgPSBmbG9vcihNYXRoLmxvZzEwKHgpKQoJYSA9ICgxMCAqKiAobiAtIDEgLSByKSkKCWZsb29yKHggKiBhKSAvIGEKCmxvZyAtPiBwcmVjaXNlKDIpKDAuMTIzNDUpCmxvZyAtPiBwcmVjaXNlKDIpKDEuMjM0NSkKbG9nIC0+IHByZWNpc2UoMikoMTIzLjQ1KQoKbG9nIC0+IDEgLyAwLjAwMDAxCiNuIC0gMSAtIHIgPT0gLTUKI2Zsb29yKHggKiBhKSA9PSAxCmxvZyAtPiBwcmVjaXNlKDEpKDEwMDAwMCk=)

但是，发现有些数据打印出的结果会是这样：

```coffeescript
## precise(1)(100000) ==> 99999.99999999999
```

虽然说，数值计算必然会有误差，但是，如果结果是要显示为一个reasonable的数值的话，这种情况还是无法接受。

分析以上代码，发现如果想要结果reasonable的话，依赖这样一个假设：`floor(x * a) / a`（即 整数 / 小数）的结果都是reasonable的。但是我们发现：

```coffeescript
## 1 / 0.00001 ==> 99999.99999999999
```

所以这个假设是不成立的。

然后，尝试把除法改为乘法调整为这个样子：

```coffeescript
precise = (n) -> (x) ->
	r = floor(Math.log10(x))
	a = (10 ** -(n - 1 - r))
	floor(x / a) * a
```

[这里可以试运行](http://luochen1990.me/try_coffee?#cHJlY2lzZSA9IChuKSAtPiAoeCkgLT4KCXIgPSBmbG9vcihNYXRoLmxvZzEwKHgpKQoJYSA9ICgxMCAqKiAtKG4gLSAxIC0gcikpCglmbG9vcih4IC8gYSkgKiBhCgpsb2cgLT4gcHJlY2lzZSgyKSgwLjEyMzQ1KQpsb2cgLT4gcHJlY2lzZSgyKSgxLjIzNDUpCmxvZyAtPiBwcmVjaXNlKDIpKDEyMy40NSkKCmxvZyAtPiBwcmVjaXNlKDEpKDEwMDAwMCkKbG9nIC0+IHByZWNpc2UoMSkoMC4wMDAwMDUyMzQ1KQ==)

虽然上面那个测试样例通过了，但是总觉得这个方法正确的可能性不大，所以又试了很多测试数据，终于被我找到了bug：

```coffeescript
## precise(1)(0.0000052345) ==> 0.0000049999999999999996
```

另外，其中的`floor(Math.log10(x))`这一步其实也是有问题的，[这里做了个测试](http://luochen1990.me/try_coffee?#ZiA9ICh4KSAtPiBmbG9vcihNYXRoLmxvZzEwKHgpKQoKYSA9IG1hcCgoaSkgLT4gMTAgKiogaSkgcmFuZ2UoMzApCmxvZyAtPiBsaXN0IGEKbG9nIGFsbCgoeCkgLT4gMTAgKiogZih4KSA9PSB4KSBhCgpiID0gbWFwKChpKSAtPiAxMCAqKiBpIC0gMWUtMTApIHJhbmdlKDEwKQpsb2cgLT4gbGlzdCBiCmxvZyBsaXN0IG1hcCgoeCkgLT4gMTAgKiogZih4KSA8IHgpIGIK)，测试发现，小于但是十分接近10的整数次幂的数，处理时会出现精度问题。（当然Math.log10还有一些浏览器兼容问题，但都可以解决，问题不大）

最终，发现想通过数值计算实现这个需求似乎走不通，因为不管怎么样，要得到结果最后一步都需要经过浮点数计算，而一旦进行浮点数计算就会产生精度损失，然后就会产生一个unreasonable的结果。

正当我打算走“先转字符串处理”这条路的时候，@文祎骁 同学帮我发现了toPrecision这个好东西，当然用toPrecision也一样。

于是最后这样子就实现了：

```coffeescript
precise = (n) -> (x) ->
	parseFloat x.toPrecision(n)
```

[这里可以试运行](http://luochen1990.me/try_coffee?#cHJlY2lzZSA9IChuKSAtPiAoeCkgLT4KCXBhcnNlRmxvYXQgeC50b1ByZWNpc2lvbihuKQoKbG9nIC0+IHByZWNpc2UoMSkoMTAwMDAwKQpsb2cgLT4gcHJlY2lzZSgxKSgwLjAwMDAwNTIzNDUpCgpsb2cgLT4gcHJlY2lzZSgyKSgwLjEyMzQ1KQpsb2cgLT4gcHJlY2lzZSgyKSgxLjIzNDUpCmxvZyAtPiBwcmVjaXNlKDIpKDEyMy40NSk=)

结论
----

1. Javascript似乎能保证reasonable的数值字面值被解析为浮点数之后，再toString成字符串还是reasonable的；但是不能保证两个reasonable的数值字面值被解析为浮点数之后，进行（加减乘除等）浮点运算的结果，toString成字符串后，仍然是reasonable的。这点比较有意思。
2. 都怪自己看文档不仔细 23333333

