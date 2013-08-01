---
layout: default
title: 安卓开发日志
---

首先列出了项目开发过程中可能遇到的技术问题, 按照重要程度排序如下:

1. [Activity之间的切换](#1)
2. [过渡动画的添加](#2)
3. [手势识别](#3)
4. [布局覆盖问题](#4)
5. [实现动态加载内容的ListView](#5)
6. [相机API的调用](#6)
7. [相册API的调用](#相册API的调用)
8. [时间, 位置, 天气 信息的获取](#8)
9. [图片滤镜效果的添加](#9)
10. [分享内容到社交网络的接口](#10)

该日志将记录我开发过程中遇到的问题以及相应的解决过程.

<a name=1 />
### Activity之间的切换
   
<a id=2 />
### 过渡动画的添加
   - 写透明度变化动画的demo时, 出现错误提示: 没有alpha这东西.
    - 原因: 设置的最低兼容版本为android2.2, 而我使用了AnimatorInflater.loadAnimator函数, 此函数只支持Android SDK 11+版本
	- 解决: 用AnimationUtils.loadAnimation函数代替, 问题解决
   
### 手势识别 <a name=3 />
   - 尝试写手势缩放demo的过程中, 发现图片无法缩放, 也没有进入OnTouchListener回调函数时的log输出
      - 原因: 图片的xml描述中,没有添加 android:scaleType="matrix" 这个属性, 导致图片无法缩放. 而没有log输出是另有原因
      - 解决: 添加相应属性后图片可以缩放. log不显示的问题将IDE重启后恢复
   - 还有问题?
     - 还有问题?
	 - 还有问题?
   - 还有问题?
   - 还有问题?

<x name=4 />
### 布局覆盖问题
   
### 实现动态加载内容的ListView <x name=5 />
   
<x name=6 > </x>
### 相机API的调用
   
### 相册API的调用
   
### 时间, 位置, 天气 信息的获取
   
### 图片滤镜效果的添加
   
### 分享内容到社交网络的接口

- adfafasfasdfasdf
- adfafasfasdfasdf
- adfafasfasdfasdf
- adfafasfasdfasdf
- adfafasfasdfasdf
- adfafasfasdfasdf
- adfafasfasdfasdf
- adfafasfasdfasdf
- adfafasfasdfasdf
- adfafasfasdfasdf
- adfafasfasdfasdf
- adfafasfasdfasdf
- adfafasfasdfasdf
- adfafasfasdfasdf
- adfafasfasdfasdf
- adfafasfasdfasdf
- adfafasfasdfasdf
- adfafasfasdfasdf
- adfafasfasdfasdf
- adfafasfasdfasdf
- adfafasfasdfasdf
- adfafasfasdfasdf
- adfafasfasdfasdf
- adfafasfasdfasdf
- adfafasfasdfasdf
- adfafasfasdfasdf
- adfafasfasdfasdf
- adfafasfasdfasdf
- adfafasfasdfasdf
- adfafasfasdfasdf
- adfafasfasdfasdf
- adfafasfasdfasdf
- adfafasfasdfasdf
- adfafasfasdfasdf
- adfafasfasdfasdf
- adfafasfasdfasdf
- adfafasfasdfasdf
- adfafasfasdfasdf
- adfafasfasdfasdf
- adfafasfasdfasdf
- adfafasfasdfasdf
- adfafasfasdfasdf
- adfafasfasdfasdf
- adfafasfasdfasdf
- adfafasfasdfasdf
- adfafasfasdfasdf
- adfafasfasdfasdf
- adfafasfasdfasdf
- adfafasfasdfasdf
- adfafasfasdfasdf

