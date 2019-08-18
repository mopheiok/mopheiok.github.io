title: 机器学习中的凸优化问题
mathjax: true
author: Mophei
tags:
  - 最优化问题
categories:
  - 机器学习
date: 2019-04-20 15:40:00
keywords:
description:
---
凸优化（convex optimization）是最优化问题中非常重要的一类，也是被研究的很透彻的一类。对于机器学
习来说，如果要优化的问题被证明是凸优化问题，则说明此问题可以被比较好的解决。

# 线性回归

线性回归是最简单的有监督学习算法，它拟合的目标函数是一个线性函数。假设有$N$个训练样本$(x_i, y_i)$ ，其中$x_i$ 为特征向量，$y_i$ 为实数标签值。线性回归的预测函数定义为：
$$
f(x)=w^Tx+b
$$
其中权重向量$W$ 和偏置项$b$ 是训练要确定的参数。定义损失函数为误差平方和的均值：
$$
L=\frac{1}{2N} \sum_{i=1}^N (f(x_i)-y_i)^2
$$
将回归函数代入，可以得到如下的损失函数：
$$
L=\frac{1}{2N} \sum_{i=1}^N (w^Tw_i+b-y_i)^2
$$
如果将权重向量和特征向量进行增广，即将$W$ 和$b$ 进行合并：
$$
\begin{bmatrix}
w,b
\end{bmatrix}\rightarrow w\\
\begin{bmatrix}
x,1
\end{bmatrix}\rightarrow x
$$
目标函数可以简化为：
$$
L=\frac{1}{2N} \sum_{i=1}^N (w^Tx_i-y_i)^2
$$

### 证明目标函数是凸函数

目标函数展开后为：
$$
L=\frac{1}{2N} \sum_{i=1}^N ((w^Tx_i)^2+y_i^2-2y_i w^T x_i)
$$
其二阶偏导数为：
$$
\frac{\partial ^2 L}{\partial w_i \partial w_j} = \frac{1}{N} \sum_{k=1}^N x_{k,i} x_{k,j}
$$
因此它的Hessian矩阵为：
$$
\frac{1}{N} \sum_{k=1}^N
\begin{bmatrix}
x_{k,1}x_{k,1} & \cdots & x_{k,1}x_{k,n}\\ 
\cdots & \cdots & \cdots \\ 
x_{k,n}x_{k,1} & \cdots & x_{k,n}x_{k,n}
\end{bmatrix} = \frac{1}{N}
\begin{bmatrix}
\sum_{k=1}^N x_{k,1}x_{k,1} & \cdots & \sum_{k=1}^N x_{k,1}x_{k,n}\\ 
\cdots & \cdots & \cdots \\ 
\sum_{k=1}^N x_{k,n}x_{k,1} & \cdots & \sum_{k=1}^N x_{k,n}x_{k,n}
\end{bmatrix}
$$
写成矩阵形式为：
$$
\frac{1}{N} \begin{bmatrix}
x_1^T \\
\cdots \\
x_N ^T
\end{bmatrix}
\begin{bmatrix}
x_1 & \cdots & x_N
\end{bmatrix}
= \frac{1}{N} X^TX
$$
其中$X$ 是所有样本的特征向量按照列构成的矩阵。对于任意不为0的向量$x$，有：
$$
x^TX^TXx = (Xx)^T(Xx) \geq 0
$$
因此Hessian矩阵是半正定矩阵，上面的优化问题是一个**不带约束的凸优化问题**。可以用梯度下降法或者牛顿法求解。

## 岭回归

岭回归是加上正则项之后的线性回归。加上$L_2$ 正则化之后，训练时优化的问题变为：
$$
\min_w \sum_{i=1}^N (w^Tx_i -y_i)^2 + \lambda w^Tw
$$
同样的，我们可以证明这个函数的Hessian矩阵半正定，事实上，如果$\lambda > 0$，其为严格正定的。

岭回归问题是一个**不带约束的凸优化问题**

## 支持向量机

支持向量机训练时求解的原问题是：
$$
\min_w \frac{1}{2}w^Tw + C \sum_{i=1}^N \xi _i \\
s.t. \  y_i(w^Tx_i+b) \geq 1-\xi _i \\
\xi _i \geq 0, \ i=1, \cdots, n
$$
不等式约束都是线性的，因此定义的可行域是凸集，另外可以证明目标函数是凸函数，因此这是一个凸优化问题。

通过Lagrange对偶，原问题转换为对偶问题，加上核函数之后的对偶问题为：
$$
\min_\alpha \frac{1}{2}\sum_{i=1}^n \sum_{j=1}^n \alpha_i \alpha_j y_i y_j K(x_i^Tx_j) - \sum_{k=1}^n \alpha_k \\
0 \leq \alpha_i \leq C \\
\sum_{j=1}^n \alpha_j y_j =0
$$
其中等式约束和不等式约束都是线性的，因此可行域是凸集。根据核函数的性质，可以证明目标函数是凸函数。

支持向量机是一个**带约束的凸优化问题**

## Logistic回归

logistic回归（对几率回归）也是一种常用的监督学习算法。加上$L2$ 正则项之后，训练时求解的问题为：
$$
\min_w f(w)=\frac{1}{2}w^Tw + C \sum_{i=1}^n \log (1+e^{-y_iw^Tx_i})
$$
**不带约束的凸优化问题**

## Softmax回归

softmax回归是logistic回归对多分类问题的推广。它在训练时求解的问题为：
$$
L(\theta)=-\sum_{i=1}^n \sum_{j=1}^k 
\begin{pmatrix}
1_{y_i=j} \log \frac{exp(\theta_j^Tx_i)}{\sum_{t=1}^k exp(\theta_t^Tx_i)}
\end{pmatrix}
$$
**不带约束的凸优化问题**



除此之外，机器学习中还有很多问题是凸优化问题。对于凸优化问题，可以使用的求解算法很多，包括最常用的梯度下降法，牛顿法，拟牛顿法等，它们都能保证收敛到全局极小值点。而神经网络训练时优化的目标函数不是凸函数，因此有陷入局部极小值和鞍点的风险。



[1]. [理解凸优化](https://zhuanlan.zhihu.com/p/37108430)