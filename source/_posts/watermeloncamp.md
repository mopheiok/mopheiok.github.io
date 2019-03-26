title: 西瓜书训练营
mathjax: true
author: Mophei
tags:
  - 机器学习
categories:
  - 机器学习
date: 2019-03-26 01:02:00
keywords:
description:
---
$$
\begin{equation}
\begin{aligned}
E_\hat{\omega}&=(y-X\hat{\omega})^T (y-X\hat{\omega}) \\
&=(y^T-\hat{\omega}^TX^T) (y-X\hat{\omega})\\
&=y^Ty - y^TX\hat{\omega} - \hat{\omega}^TX^Ty + \hat{\omega}^TX^TX\hat{\omega}
\end{aligned}
\end{equation}
$$



$$
\begin{equation}
\begin{aligned}
\frac {\partial E_\hat{\omega}} {\partial \hat{\omega}}
&=0-(y^TX)^T - X^Ty + [(X^TX)^T + X^TX]\hat{\omega}\\
&=-X^Ty - X^Ty + 2X^TX\hat{\omega}\\
&=2X^T(X\hat{\omega}-y)
\end{aligned}
\end{equation}
$$

> 一般把向量定义为列向量

模型预测值逼近$y$的衍生物。

令$g(\cdot)​$为单调可微函数，则
$$
y= g^{-1}(\omega x+b)
$$
称为**广义线性模型**，其中函数$g(\cdot)$称为联系函数。

若要使用线性模型进行分类任务是，则引入逻辑回归



>输入：训练集 $D=\{ (x_k, y_k) \}_{k=1}^m​$
>
>​	    梯度下降步长 $\alpha$，算法终止距离$\epsilon$
>
>过程：
>
>在$(0,1)​$范围内随机初始化参数$\beta​$
>
>repeat
>
>​	for all $(x_k, y_k) \in D$ do
>
>​		根据当前参数和梯度公式计算当前样本的梯度$\Theta$；
>
>​		根据下降步长计算当前下降距离$\alpha \Theta$：若小于终止距离，则停止，否则下一步
>
>​		更新梯度$\Theta = \Theta - \alpha \Theta$
>
>​	end for
>
>



[1]. [向量微分](https://blog.csdn.net/xidianliutingting/article/details/51673207)