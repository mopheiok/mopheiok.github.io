title: 02_线性模型
mathjax: true
author: Mophei
tags:

  - 训练营
categories:
  - 机器学习
date: 2019-03-26 01:02:00
keywords:
description:
---
## 线性模型的理论推导

线性模型即
$$
f(x) = \omega_1 x_1 + \omega_2 x_2 + ... +\omega_d x_d +d
$$

### 线性回归

线性模型中，我们试图学得
$$
f(\mathbf{x_i}) = \mathbf{\omega^T x_i} + b_i,\ 使得f(\mathbf{x_i})\simeq y_i
$$
确定 $\hat{\omega}$ 的过程就是使$\mathbf{f(x_i)}$与$y_i$之间的差别最小的过程。其中$\hat{\omega}=(\omega;b)$。均方误差是回归任务中最常用的性能度量，因此基于均方误差最小化来进行模型求解，也就是模型“**最小二乘法**”参数估计。

模型均方误差的矩阵形式：
$$
\begin{equation}
\begin{aligned}
E_\hat{\omega}&=(y-X\hat{\omega})^T (y-X\hat{\omega}) \\
&=(y^T-\hat{\omega}^TX^T) (y-X\hat{\omega})\\
&=y^Ty - y^TX\hat{\omega} - \hat{\omega}^TX^Ty + \hat{\omega}^TX^TX\hat{\omega}
\end{aligned}
\end{equation}
$$

也就是损失函数。则目标函数就是：
$$
\begin{equation}
\begin{aligned}
\mathbf{\hat{\omega}^*} &= \underset{\hat{\omega}}{\arg \min} \ E_{\hat{\omega}}\\
&=\underset{\hat{\omega}}{\arg \min} (\mathbf{(y -X\omega)^T (y -X\omega)})
\end{aligned}
\end{equation}
$$
对$\hat{\omega}$求导得到
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

令导数等于零，当$\mathbf{X^TX}$ 的逆存在时，则有
$$
\mathbf{\hat{\omega}^*} =\mathbf{(X^TX)^{-1}X^Ty}
$$



> 一般把向量定义为列向量

### 广义线性模型

令模型预测值逼近 $y$ 的衍生物。比如说，$\omega^Tx+b = g(y)$，即示例对应输出满足$g(y)$变化，其中$g(\cdot)$为单调可微函数，则

$$
y= g^{-1}(\omega x+b)
$$
称为**广义线性模型**，其中函数$g(\cdot)$称为联系函数。

在形式上仍是线性回归，但实质上已是在求输入空间到输出空间的非线性函数映射。

### 逻辑回归

若要使用线性模型进行分类任务是，则引入逻辑回归。逻辑回归更准确地应该称为“对数几率回归”。在广义线性模型下，令
$$
g^{-1}(\cdot)=\frac{1}{1+e^{-z}}
$$
此时，可以得到
$$
y=\frac{1}{1+e^{-(\omega^Tx+b)}}
$$


则可以推导出
$$
\ln \frac{y}{1-y} = \omega^Tx+b
$$
若将 $y$ 视为样本 $x$ 作为正利的可能性，则 $1-y$ 是其反例可能性，两者的比值称为“几率”(odds)，反映了 $x$ 作为正利的**相对可能性**。

最大似然估计 $\omega ^T$ ，梯度下降法求解。

>输入：训练集 $D=\{ (x_k, y_k) \}_{k=1}^m​$
>
>​	    梯度下降步长 $\alpha​$，算法终止距离$\epsilon​$
>
>过程：
>
>在$(0,1)​$范围内随机初始化参数$\beta​$
>
>repeat
>
>​	for all $(x_k, y_k) \in D$ do
>
>​		根据当前参数和梯度公式计算当前样本的梯度$\theta$；
>
>​		根据下降步长计算当前下降距离$\alpha \theta$：若小于终止距离，则停止，否则下一步
>
>​		更新梯度$\theta = \theta - \alpha \theta$
>
>​	end for
>



## 逻辑回归实战

```python
def gradAscent(dataMatIn, classLabels):
    dataMatrix = np.mat(dataMatIn)             #convert to NumPy matrix
    labelMat = np.mat(classLabels).transpose() #convert to NumPy matrix
    m, n = np.shape(dataMatrix)
    alpha = 0.001
    maxCycles = 500
    weights = np.ones((n, 1))
    for k in range(maxCycles):              #heavy on matrix operations
        h = sigmoid(dataMatrix*weights)     #matrix mult
        error = (labelMat - h)              #vector subtraction
        weights = weights + alpha * dataMatrix.transpose()* error #matrix mult
    return weights
```





[1]. [向量微分](https://blog.csdn.net/xidianliutingting/article/details/51673207)
[2]. [矩阵求导](https://daiwk.github.io/assets/matrix+vector+derivatives+for+machine+learning.pdf)