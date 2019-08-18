title: 分类场景下的类别不平衡问题
mathjax: true
author: Mophei
tags:
  - 机器学习
categories:
  - 机器学习
date: 2019-03-08 00:11:00
keywords:
description:
---
[https://zhuanlan.zhihu.com/p/32940093](https://zhuanlan.zhihu.com/p/32940093)

[https://blog.csdn.net/heyongluoyao8/article/details/49408131](https://blog.csdn.net/heyongluoyao8/article/details/49408131)

机器学习中常常会遇到数据的**类别不平衡（class imbalance）**，有时也叫数据类别偏斜（class skew）。以常见的二分类问题为例，我们希望预测信用卡用户是否存在欺诈行为。但在历史数据中，存在欺诈行为的比例可能很低（比如0.1%）。在这种情况下，学习出好的分类器是很难，而且在得到的结论往往也很具有迷惑性。比如在诈骗行为预测中，如果我们的分类器**总是**预测一个用户不存在诈骗行为，即预测为反例，那么我们依然有高达99.9%的预测准确率。然而这种结论是没有意义的。那么，在类别不平衡的情况下如何有效的评估分类器呢？这就是我们首先需要研究的问题。

<!--more-->


## 1\. 类别不平衡下的评估问题

对于平衡的数据，我们一般都用准确率（accuracy），也就是`1-误分率`作为一般的评估标准。这种标准的默认假设前提是：“数据是平衡的，正例与反例的重要性一样，二分类的阈值是0.5”。在这种情况下，用准确率来对分类器进行评估是合理的。

当类别不平衡时，准确率就非常具有迷惑性，而且意义不大。以下给出几种主流的评估方法：

*   ROC曲线（receiver operating characteristic curve, 接收者操作特征曲线）是一种常见的替代方法，计算ROC曲线下的面积是一种主流方法

*   Precision-recall curve和ROC有相似的地方，但定义不同，计算此曲线下的面积也是一种方法

*   Precision@n 是另一种方法，特指将分类阈值设定到恰好n个正例时分类器的precision

*   Average precision 也叫做平均精度，主要描述了precision的一般表现，在异常检测中有时候会用

*   直接使用Precision也是一种想法，但此时的假设是分类器的阈值是0.5，因此意义不大

至于哪种方法更好，一般来看我们在极端类别不平衡中更在意“少数的类别”（即需要预测小概率事件的出现），因此ROC不像precision-recall curve那样更具有吸引力<!--为什么该曲线更有优势，其曲线下面积如何计算？？-->。在这种情况下，precision-recall curve不失为一种好的评估标准，相关的分析可以参考[2]。还有一种做法是仅分析ROC曲线左侧的一小部分，从这个角度看和precision-recall cureve有很高的相似性。

同理，因为我们更在意罕见的正例，因此precision尤为重要，因此average precision（macro）也是常见的评估标准。此处需要提醒两点：

1.  没有特殊情况，不要用准确率（accuracy），一般都没有什么帮助

2.  如果使用precision，请注意调整分类阈值，precision@n更有意义

更为一般的分类评估标准，简单的科普可以参考：[如何解释召回率与准确率?](https://www.zhihu.com/question/19645541)

## 2\. 解决类别不平衡中的"奇淫技巧"有什么？

在[1]中介绍了很多比较负载的技巧。结合我的了解举几个简单的例子：

*   对数据进行采用的过程中通过相似性同时生成并插样“少数类别数据”，叫做SMOTE算法

*   对数据先进行聚类，再将大的簇进行随机欠采样或者小的簇进行数据生成<!---具体什么意思，是对所有数据进行聚类还是对大类别数据进行聚类？如果聚类完成，那岂不是就得到了不同类别吗，即大类别，小类别-->

*   把监督学习变为无监督学习，舍弃标签把问题转为一个无监督问题，如异常检测<!--类别不平衡问题的范畴更大，而异常检测只是该问题的一种解决办法-->

*   先对多数类别进行随机的欠采样，并结合boosting算法进行集成学习

科普文[3]中介绍了一部分上面提到的算法，可以进行参考。

## 3\. 简单通用的算法有哪些？

除了第二节中提到的一些看起来略微复杂的算法，最简单算法无外乎三种，在大部分教材中都有涉猎[4]：

*   对较多的那个类别进行欠采样(under-sampling)，舍弃一部分数据，使其与较少类别的数据相当

*   对比较少的类别进行过采样(over-sampling)，重复使用一部分数据，使其与较多类别的数据相当

*   阈值调整(threshold moving)，将原本默认为0.5的阈值调整到`较少类别/(较少类别+较多类别)`即可

当然，第一种和第二种方法都会明显的改变数据分布，我们的训练数据假设不再是真实数据的无偏表述。在第一种方法中，我们浪费了很多数据；而第二种方法中无中生有或重复使用了数据，会导致过拟合的发生。

在欠采样的逻辑中往往会结合集成学习来有效的使用数据：假设正例数据n个，反例数据m个。我们可以通过欠采样，随机无重复的生成$k=m/n$个反例子集，并将每个子集都与相同正例数据合并生成​个新的训练样本<!--这个训练样本中的正例和反例的数据相当-->。我们在​个训练样本上分别训练一个分类器，最终将​个分类器的结果结合起来，比如求平均值或者简单投票。这就是一个简单的思路，也就是Easy Ensemble[5]

然而，这样的过程是需要花时间处理数据和编程的，难度比较大。所以推荐两个简单易行且效果中上 的做法：

*   简单的调整阈值，不对数据进行任何处理。此处特指将分类阈值从0.5调整到正例比例

*   使用现有的集成学习分类，如随机森林或者xgboost，并调整分类阈值

提出这样建议的原因有很多。首先，简单的阈值调整从经验上看往往比过采样和欠采样有效[6]。其次，如果你对统计学知识掌握有限，而且编程能力一般，在集成过程中更容易出错，还不如使用现有的集成学习并调整分类阈值。

## 4\. 一个简单但有效的方案

经过上文的分析，我任务一个比较靠谱的解决方案是：

1.  不对数据进行过采样和欠采样，但使用现有的集成学习模型，如随机森林

2.  输出随机森林的预测概率，调整阈值得到最终结果

3.  选择合适的评估标准，如precision@n

这种方法难度很低，也规避了不少容易出错的地方。我们使用了集成学习降低过拟合风险，使用阈值调整规避和采样问题，同时选择合适的评估手段以防止偏见。而且这些都是现成的模型，5-10行的python代码就可以实现。有兴趣的朋友可以在这个基础上进行更多探索，而把这个结果作为一个基准(baseline)。

当然，更多复杂的操作是可以的，比如[7]就在欠采样集成后使用了逻辑回归作为集成分类器来学习不同子训练集的权重，并通过L1正则自动舍弃掉一部分基学习器。当然，我很怀疑这种结果是否比得上简单的处理模式。

[1] He, H. and Garcia, E.A., 2009\. Learning from imbalanced data. *IEEE Transactions on knowledge and data engineering*, *21*(9), pp.1263-1284.

[2] Davis, J. and Goadrich, M., 2006, June. The relationship between Precision-Recall and ROC curves. In *Proceedings of the 23rd international conference on Machine learning* (pp. 233-240). ACM.

[3] [How to handle Imbalanced Classification Problems in machine learning?](https://www.analyticsvidhya.com/blog/2017/03/imbalanced-classification-problem/)

[4] 周志华。机器学习，清华大学出版社，3.7，2016。

[5] Liu, T.Y., 2009, August. Easyensemble and feature selection for imbalance data sets. In *Bioinformatics, Systems Biology and Intelligent Computing, 2009\. IJCBS'09\. International Joint Conference on* (pp. 517-520). IEEE.

[6] Han, J., Pei, J. and Kamber, M., 2011\. *Data mining: concepts and techniques*. Elsevier.

[7] Micenková, B., McWilliams, B. and Assent, I., 2015\. Learning representations for outlier detection on a budget. *arXiv preprint arXiv:1507.08104*.