title: 【西瓜书训练营】03_决策树
mathjax: true
author: Mophei
tags:
  - 西瓜书
categories:
  - 机器学习
date: 2019-04-01 21:45:00
keywords:
description:
---
决策树的直观认知：一般的，一棵树包括根结点、内部结点和叶子结点。叶结点对应于决策树结果，其他每个结点则对应于一个属性测试；每个结点包含的样本集合根据属性测试的结果被划分到子结点中；根结点包含样本全集。

决策树的生成是一个递归过程。在一次迭代中，生成树核心规则为：从属性集合中选择最优划分属性，然后根据该属性的取值进行划分子集。

## 决策树的生成

### [信息熵](https://mopheiok.github.io/machinelearning/similarity/)

又称为熵(entropy)，在信息论与概率统计中，熵是表示随机变量不确定性的度量。可以用来度量该属性对分支结点不确定性的大小。样本集$D$ 的信息熵为：
$$
Ent(D) = -\sum_{k=1}^n p_k \log _2{p_k}
$$
其中，$n$表示样本集$D$ 的分类数，$p_k$ 为第$k$ 类样本所占的比例

### 信息增益

属性$a$ 对样本集$D$ 的信息增益：
$$
Gain(D, a)=Ent(D)-\sum_{v=1}^V \frac{|D^v|}{|D|}Ent(D^v)
$$
其中，基于属性$a$ 的取值将样本集$D$ 划分为$V$个子集，$|D^v|$ 为第$v$ 个样本子集的元素个数，则$|D^v|/|D|$ 为样本子集的权重。

一般而言，信息增益越大，使用属性$a$ 进行划分获得的不确定性减小越大。ID3(Iterative Dichotomiser, 迭代二分器)决策树学习算法是以信息增益为准则来选择划分属性。

**不足：**信息增益准则对可取值数目较多的属性有所偏好

### 增益率

定义：
$$
Gain\_ratio(D,a)=\frac{Gain(D,a)}{IV(a)}
$$
其中
$$
IV(a)=-\sum_{v=1}^V \frac{|D^v|}{|D|} \log_2{\frac{|D^v|}{|D|}}
$$
称为属性$a$ 的“固有值”（intrinsic value）。属性$a$ 的可能取值数目越多（即$V$ 越大），$IV(a)$ 的值通常会越大。

**不足：**增益率准则对可取数目较少的属性有所偏好

在C4.5决策树算法中使用了一个启发式：**先从候选划分属性中找出信息增益熵高于平均水平的属性，再从中选择增益率最高的**


### 基尼指数

数据集$D$ 的纯度可用基尼值来度量：
$$
\begin{equation}
\begin{aligned}
Gini(D)&=\sum_{k=1}^{|y|} \sum_{k' \neq k} p_k p_{k'}\\
&=1-\sum_{k=1}^{|y|}p_k^2
\end{aligned}
\end{equation}
$$
$Gini(D)$ 反映了从数据集$D$ 中随机抽取*两个样本，其类别标记不一致的概率*。<span style="color:red">**$Gini(D)$ 越小，则数据集$D​$ 的纯度越高。**</span>

```python
def calcGini(dataSet):
  numEntries = len(dataSet)
  labelCounts = {}
  for featVec in dataSet:
    currentLabel = featVec[-1]
    if currentLabel not in labelCounts.keys(): labelCounts[currentLabel] = 0
    labelCounts[currentLabel] += 1
  gini = 1.0
  for key in labelCounts:
    prob = float(labelCounts[key])/numEntries
    gini -= prob * prob
  return gini
```

属性$a$ 的基尼指数定义为：
$$
Gnini\_index(D,a)=\sum_{v=1}^V \frac{|D^v|}{|D|}Gini(D^v)
$$
CART决策树算法使用基尼指数来选择划分属性

## 习题

4.2 试析使用“最小训练误差”作为决策树划分选择准则的缺陷

机器学习过程中，我们希望得到泛化误差小的学习器，这样在新样本上能表现得很好。然而在训练集上做到最小化训练误差时，往往会有过拟合的风险。无论是采用信息增益、增益率还是基尼指数，都会使结点纯度越来越高，也就是最小化训练误差，所以会存在过拟合的风险。