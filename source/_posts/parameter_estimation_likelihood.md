title: 参数估计-极大似然估计、极大后验估计、贝叶斯估计
mathjax: true
author: Mophei
tags:
  - 参数估计
categories:
  - 机器学习
date: 2019-03-28 23:30:00
keywords:
description:
---
首先来看下这些问题：

> 机器学习中的有参建模，会面临参数估计的问题，最后一般都会变成一个目标函数的优化问题（可以带或者不带约束条件），那么这个目标函数都是怎么来的？比如，交叉熵损失函数怎么来的<!--什么是交叉熵函数？-->？在逻辑回归中，它的目标函数是怎么来的？

在回答这个问题之前，我们先回顾下极大似然估计、极大后验估计、贝叶斯估计这三种估计方法，并进行梳理、对比和总结。

## 问题引出

假设有一个机器学习问题，输入$x$是一个向量，输出$p(x)$为某一个事件的概率（比如，$x$属于某个类别的概率）。已观测到的数据集$D=(x_1, x_2,...,x_N)$，其中$x_1, x_2,...,x_N$独立同分布。我们将输入$x$所满足的概率分布建模为$p(D, \theta)$，则对新输入的预测为$p(x|D,\theta)$，其中$\theta$是一个向量，表示待确定的所有模型参数。现在的问题就是，如何求解或估计出$\theta$的值？

### 频率学派 $VS $ 贝叶斯学派

对$\theta$的本质的不同认识，将概率统计领域的学者分成了两大派别。

- **频率学派的观点是**，$\theta$是确定的，有一个真实值，我们的目标是找出或者逼近这个真实值。
- **贝叶斯学派的观点是，**$\theta$是不确定的，不存在唯一的真实值，而是服从某一个概率分布。

两个学派长期以来争论不断，但彼此都无法占据上风，后文将对其原因予以说明。基于两个学派对参数本质的不同认识，进而产生了不同的参数估计方法。本文将讨论的三种参数估计方法：

- **极大似然估计：MLE**(Maximum Likelihood Estimation)
- **极大后验估计：MAP**(Maximum A Posterior)
- **贝叶斯估计：BE**(Bayesian Estimation)

在对这三种参数估计方法进行正式讨论之前，我们先对一些基础知识予以简单说明：

> **先验(Prior)：**$p(\theta)​$指在见到数据集$D​$之前，对参数$\theta​$的认知
>
> **似然(Likelihood)：**$\displaystyle{\mathcal{L}}(\theta|D)=p(D|\theta)​$指在给定参数$\theta​$下，数据集$D​$被观测到的概率
>
> **后验(Posterior)：**$p(\theta|D)$，在见到数据集$D$之后，对参数$\theta$的重新认知
>
> **贝叶斯公式：**$p(\theta|D)=\frac{p(D|\theta) \cdot p(\theta)}{p(D)}$

## 极大似然估计：MLE

MLE是频率学家们采用的方法，其思想逻辑是，真实的参数$\theta​$是唯一的，既然数据集$D​$被观测到了，那么真实参数$\theta​$对应的概率分布一定是可以使$D​$出现的概率最大。即：
$$
\begin{equation}
\begin{aligned}
\hat{\theta}_{MLE} &= \underset{\theta}{\arg \max} \ p(D,\theta)\\
&=\underset{\theta}{\arg \max} \ p(x_1,\theta)p(x_2,\theta)...p(x_N,\theta)\\
&=\underset{\theta}{\arg \max} \ \log \prod ^N_{i=1}p(x_i,\theta)\\
&=\underset{\theta}{\arg \min} \ -\log\prod ^N_{i=1}p(x_i,\theta)
\end{aligned}
\end{equation}
$$
最后一行的目标函数，是我们更为常见的形式，即负对数似然。对似然求$\log$是为了防止数值下溢，因为似然是各个样本点处概率乘积的形式，而概率都在0 到1 之间，似然通常会长处计算机的精度范围。另一方面，$\log$是一个凸函数，保证了极大化似然和极大化对数似然是等价的。



## 极大后验估计：MAP

MAP是贝叶斯学派们常用的参数估计方法，其思想逻辑是，最优的参数应该是让后验概率最大。即：
$$
\begin{equation}
\begin{aligned}
\hat{\theta}_{MAP}&=\underset{\theta}{\arg \max} \ p(\theta|D)\\
&=\underset{\theta}{\arg \max} \ \frac{p(D|\theta)p(\theta)}{p(D)}\\
&=\underset{\theta}{\arg \max} \ p(D|\theta)p(\theta)\\
&=\underset{\theta}{\arg \max}\log[p(D|\theta)p(\theta)]\\
&=\underset{\theta}{\arg \min} \ -\log p(D|\theta) -\log p(\theta)
\end{aligned}
\end{equation}
$$
对比MAP和MLE可以发现，两者优化的目标函数只是相差了一个先验。更有趣的是，如果这个先验服从高斯分布的话，MAP将等同于MLE+L2正则。

下面进行具体推导：

假设参数$\theta$服从高斯分布，即
$$
p(\theta)=\frac{1}{\sqrt{2\pi \sigma}}e^{\frac{\theta ^2}{2\sigma_2}}
$$
则有，
$$
\begin{equation}
\begin{aligned}
\hat{\theta}_{MAP}&=\underset{\theta}{\arg\min}-\log p(D|\theta) -\log p(\theta)\\
&=\underset{\theta}{\arg\min}-\log p(D|\theta) +\lambda \left \| \theta \right \|_2^2 \\
&=\hat{\theta}_{MLE} +\lambda\left \| \theta \right \|_2^2
\end{aligned}
\end{equation}
$$
其中，$\lambda​$是一个与$\theta​$无关的常数。



## 贝叶斯估计：BE

损失函数，来衡量参数的估计值和真实值之间的差别。比如，常用的平方误差损失，
$$
L(\theta, \hat{\theta})=(\theta-\hat{\theta})^2
$$
经验风险，表示在后验概率破$p(\theta|D)​$下，用$\hat{\theta}​$作为$\theta​$的估计，索要承担的风险，
$$
R(\hat{\theta}|D)=\int_{\theta}L(\theta|\hat{\theta})p(\theta|D)d\theta
$$
期望风险，是对数据集$D$再取期望，去除数据采集过程的方差所带来的波动
$$
R(\hat{\theta})=\int_DR(\hat{\theta}|D)dD
$$
贝叶斯估计的思路时，在所有$\theta$的估计中，能使期望风险最低的估计，是最优估计，即
$$
\hat{\theta}_{EE}=\underset{\hat{\theta}}{\arg\max}R(\hat{\theta})
$$
实际计算中，如果采用平方误差作为损失函数，用经验风险代替期望风险，则可以得到
$$
\hat{\theta}_{EE}=\int_{\theta}\theta p(\theta |D)d\theta
$$
因此，不同于MLE和MAP选择某一个特定的估计，贝叶斯估计对各个估计值进行了概率加权平均。



举个例子

假设观测到数据集$D=(x_1, x_2, ...,x_N)$，$x_i(i=1,2,...,N)$服从高斯分布$N(\mu, \sigma^2)$，其中方差$\sigma^2$已知，假设$\mu$的先验分布也是高斯分布，为$p(\mu) \sim N(\mu_0, \sigma^2_0)$，求均值$\mu$的MLE、MAP和BE估计。
$$
\begin{equation}
\begin{aligned}
\mathcal L(\mu|D) &= p(D|\mu)\\
&=\prod_{i=1}^N\frac{1}{\sqrt{2\pi}\sigma}\exp(-\frac{(x_i-\mu)^2}{2\sigma^2})\\
&=C_1\exp[-\frac{1}{2\sigma^2} \sum_{i=1}^N(x_i-\mu)^2]\\
&=C_2\exp[-\frac{1}{2\sigma^2}(N\mu^2 - 2\sum_{i=1}^N x_i \mu)]\\
&=C_3 \exp(-\frac{1}{2\sigma^2}(\mu - \frac{1}{N} \sum_{i=1}^N x_i)^2)
\end{aligned}
\end{equation}
$$

$$
\begin{equation}
\begin{aligned}
p(\mu|D)&=\frac{p(D|\mu)p(\mu)}{p(D)}\\
&=C_4 \prod_{i=1}^N \exp(-\frac{(x_i-\mu)^2}{2\sigma^2}) \exp(-\frac{(\mu - \mu_0)^2}{2\sigma^2_0})\\
&=C_5 \exp\{-\frac{1}{2}[(\frac{N}{\sigma^2}+\frac{1}{\sigma^2_0})\mu^2 -2(\frac{1}{\sigma^2} \sum_{i=1}^{N}x_i + \frac{\mu_0}{\sigma^2_0})\mu]\}\\
&=C_6 \exp[-\frac{(\mu-\mu_N)^2}{\sigma^2_N}]
\end{aligned}
\end{equation}
$$

其中，$C_1,C_2,...,C_6​$均为常数，
$$
\begin{equation}
\begin{aligned}
\mu_N&=\frac{N\sigma_0^2}{N\sigma_0^2+\sigma^2}(\frac{1}{N} \sum_{i=1}^Nx_i)+\frac{\sigma^2}{N\sigma^2_0 + \sigma^2}\mu_0\\
\\
\sigma^2_N&=\frac{\sigma_0^2 \sigma^2}{N\sigma_0^2+\sigma^2}
\end{aligned}
\end{equation}
$$
求得$\mu$的MLE、MAP和BE估计分别为，
$$
\begin{equation}
\begin{aligned}
&\hat{\mu}_{MLE}=\underset{\mu}{\arg\max} \ p(D|\mu)=\frac{1}{N} \sum_{i=1}^N x_i\\
\\
&\hat{\mu}_{MAP}=\underset{\mu}{\arg\max} \ p(\mu|D)=\mu_N\\
\\
&\hat{\mu}_{EE}=\int \mu p(\mu|D)d\mu=\mu_N
\end{aligned}
\end{equation}
$$
从以上三个表达式可以的出结论，

- 当$N\rightarrow \infty$时，$\hat{\mu}\_{MAP} \rightarrow \hat{\mu}_{MLE}$。此时，因为观测数据足够多，先验不起作用。
- 当$\sigma^2_0 \rightarrow 0$时，$\mu_N \rightarrow \mu$。此时，先验假设足够强，使高斯分布收敛到一个点上，观测数据不起作用。
- 在$p(\mu|D)$为高斯分布，且采用平方误差时，$\hat{\mu}\_{EE}=\hat{\mu}_{MAP}$。

## 总结

下面简单对MLE、MAP和BE三者进行一个对比总结：

### 各自的缺点

**1) MLE的缺点非常明显，就是在数据量很小的时候，会得出很不可靠的估计**

比如，抛硬币2次全部是正面，MLE会得到正面的概率为1。

还有就是，MLE无法从理论层面说明机器学习目标函数中正则项的来由，而MAP给出了理论解释。

事实上，当初统计学家在回归问题中引入$L2​$正则，只是出于防止矩阵病态造成不可求逆矩阵，后来才发现结果居然更好了。

**2）MAP的缺点是可能带来计算的困难**

因为MAP优化的是先验和似然的乘积（即后验），两个概率分布的乘积形式通常会变得比较复杂。

正因为如此，贝叶斯学派的学者们提出了很多形式的概率分布，称之为共轭分布。

共轭分布的作用是，让先验乘以似然之后，仍然跟先验属于同一种分布，这样就带来了计算上的方便。

但这一点也是频率学派所一直诟病的地方，你们贝叶斯学派选择先验没有任何科学依旧，只是为了方便计算啊。

**3）BE的缺点更明显了，就是计算量过大，因为它要求各个估计的概率加权平均**

在机器学习领域，贝叶斯方法基本等同于“计算量超级大”。不过，有很多近似求解的方法（比如，采样），极大地减小了计算量，拓宽了贝叶斯方法的实际应用范围。

## 三者之间的联系

1. $MAP+高斯先验 = MLE+L2正则$
2. 当样本量越来越大，先验所起的作用也越来越小，最后MAP会趋近于MLE
3. 当先验为均匀分布时，$p(\theta)$为常量，此时MAP与MLE等价。可以理解为这种情况下先验并不能提供任何有价值的信息。
4. MLE最大化的是$p(D,\theta)$，MAP最大化的是$p(\theta|D)$，而BE最大化的是$R(\hat{\theta}|D)$

最后，我们来回答导读中的三个问题，

1）机器学习中的目标函数，代表的是一个信息标准（比如，似然、后验、交叉熵、经验损失等）。

使用什么样的信息标准作为最优化目标，代表了我们不同的追求。

比如，我们希望得到一个光滑的模型，就会对导数加惩罚项；我们希望得到简单的模型，就会对模型复杂度加惩罚项。

2) 交叉熵函数来自于训练数据集上的极大似然估计。

3） 逻辑回归解决的是分类问题，其目标函数就是交叉熵



PS：以上内容转自公众号：大数据与人工智能 [极大似然估计、极大后验估计和贝叶斯估计](https://mp.weixin.qq.com/s/TKPDVbJnPHKI3Yj8Eo027A)



[1]. [Likelihood function](https://en.wikipedia.org/wiki/Likelihood_function)

[2]. [似然函数](https://zh.wikipedia.org/wiki/%E4%BC%BC%E7%84%B6%E5%87%BD%E6%95%B0)

