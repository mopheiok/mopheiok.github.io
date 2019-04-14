title: 【西瓜书训练营】06_支撑向量机
mathjax: true
author: Mophei
tags:
  - 西瓜书
categories:
  - 机器学习
date: 2019-04-09 00:40:00
keywords:
description:
---
## 对SVM整体上的认识

SVM有三宝：间隔、对偶、核技巧

SVM模型的分类

| 模型的核心思想  | 模型用途           |
| --------------- | ------------------ |
| hard-margin svm | 线性可分支持向量机 |
| soft-margin svm | 线性支持向量机     |
| kernel svm      | 非线性支持向量机   |

svm几何上的原理

![2019-04-09_000514.png](https://upload-images.jianshu.io/upload_images/2268630-2b01bda7f5dfddb7.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

能够进行划分的超平面有无数个。然而在这个超平面簇中类似于紫色的那个超平面的泛化能力或者说鲁棒性比较差，比如有一个噪声圆点稍微偏过去一点，那么就会出现分类错误，所以我们需要找到最中间或者说到两边最近点的距离和最大的那个超平面作为分类超平面。

分类模型为$f(x)=sign (w^T x + b)$，其本质上是一个判别模型，与概率没有关系



## 硬间隔SVM
### 硬间隔SVM模型定义

硬间隔SVM又称为最大间隔分类器，则可以定义为

![2019-04-09_002615.png](https://upload-images.jianshu.io/upload_images/2268630-410b85ecf5a3e28f.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

即这个分类器的数学表达是关于$w$ 和$b$ 的函数，满足于蓝色框的限制

那么如何定义margin呢？我们定义margin为样本点到超平面的距离集合中最小的距离

![2019-04-09_003145.png](https://upload-images.jianshu.io/upload_images/2268630-800dc3fd014c088b.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

将margin的定义式代入最大间隔分类器的定义中得到

![2019-04-09_003412.png](https://upload-images.jianshu.io/upload_images/2268630-c52e4de6e1e32c4a.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

到此，我们得到了最大间隔分类器的优化问题（红色阴影部分），即得到目标函数。可以求得最优解$w^*, b^*$。

由此，得到超平面
$$
w^* \cdot x+b^* =0
$$
以及分类模型
$$
f(x)=sign(w^* \cdot x +b^*)
$$