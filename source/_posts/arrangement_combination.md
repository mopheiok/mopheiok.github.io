title: 排序、组合、阶乘
mathjax: true
author: Mophei
tags: []
categories:
  - 基础数学
date: 2019-03-15 23:11:00
keywords:
description:
---
**排列的问题：**

从n个不同元素中，拿出m个来进行排列，一共有多少种排列方法？

$A_n^m = {\frac {n!}{(n-m)!}}$

A就是Arrangement的缩写。

**组合的问题：**

从n个不同元素中，拿出m个来进行组合，一共有多少种组合方法？

$C_n^m =\frac{A_n^m}{m!}= {\frac {n!}{(n-m)!m!}}$

C就是Combination的缩写。

组合还有一种写法，见下图：

![组合的一种写法](http://upload-images.jianshu.io/upload_images/2268630-1254417eb1c21be3.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

$n,m∈N$；

当 $n<m$ 时，$A = 0$ 并且 $C = 0$；

$A_0^0 = C_0^0 = 0$

排列分顺序，组合不分

**阶乘：**

$n!$ 读作n的阶乘，并定义 $0! = 1$。

$C_n^0 = C_n^n = 1;n \neq 0$

以上排列和组合的问题，是许多现实问题的抽象。
