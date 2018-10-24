title: 每日一问
mathjax: true
tags: []
categories:
  - Data Science
keywords: 'AI,人工智能,数据分析,数据挖掘,k-means,A/B测试,Boosting,Stacking,时间序列,季节因子,决策树,回归'
description: 温习数据科学（DS）和商务分析（BA）领域常见的问题，希望我们一起思考。欢迎在评论区解答或讨论！
date: 2018-10-16 22:26:00
---
## 2018-10
### 2018-10-18
**Q:** How can you check if a data set or time series is Random?

**A:** To check whether a data set is random or not, use the lag plot. If the lag plot for the given data set does not show any structure then it is random.
[A lag plot checks whether a data set or time series is random or not. Random data should not exhibit any identifiable structure in the lag plot. Non-random structure in the lag plot indicates that the underlying data are not random.](https://www.itl.nist.gov/div898/handbook/eda/section3/lagplot.htm) Several common patterns for lag plots are shown in the examplesbelow.

### 2018-10-19
**Question:** You are working on a time series data set. Your manager has asked you to build a high accuracy model. You start with the decision tree algorithm, since you know it works fairly well on all kinds of data. Later, you tried a time series regression model and got higher accuracy than decision tree model. Can this heppen? Why?

**Answer:** Time series data is known to posses linearity. On the other hand, a decision tree algorithm is known to work best to detect non-linear interactions. The reason why decision tree failed to provide robust predictions because it couldn't map the linear relationship as good as a regression model did. Therefore, we learned that, a linear regression model can provide robust prediction given the data set satisfies its linearity assumptions.

### 2018-10-20
**Question:** What is seasonality in time series modelling?

**Answer:** 
Seasonality in time series occurs when time series shows a repeated pattern over time. E.g., stationary sales decreases during holiday season, air conditioner sales increases during the summers etc. are few examples of seasonality in a time series.
Seasonality makes your time series non-stationary because average value of the variables at different time periods. Differentiating a time series is generally known as the best method of removing seasonality from a time series. Seasonal differencing can be defined as a numerical difference between a particular value and a value with a periodic lag.

### 2018-10-21
**Question:** Give some classification situations where you will use an SVM over a RandomForest Machine Learning algorithm and vice-versa.
**Answer:** 
 1. When the data is outlier free and clean then go for SVM. If your data might contain outliers then Random forest would be the best choice
 2. Generally, SVM consumes more computational power than Random Forest, so if you are constrained with memory go for Random Forest machine learning algorithm.
 3. Random Forest gives you a very good idea of variable importance in your data, so if you want to have variable importance then choose Random Forest machine learning algorithm.
 4. Random Forest machine learning algorithms are preferred for multiclass problems.
 5. SVM is preferred in multi-dimensional problem set - like text classification
 
### 2018-10-22
**Question:** How to define the number of clusters?
**Answer:** The elbow method
This method looks at the percentage of variance explained as a function of the number of clusters: choose a number of clusters so that adding another wouldn’t add significant information to modeling.
![聚类个数.jpg](https://upload-images.jianshu.io/upload_images/2268630-00272b5184274aa8.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
X-means clustering
A variation of k-means clustering that refines cluster assignments by repeatedly attempting optimal subdivision, until a criteria such as AIC or BIC is reached.
Cross Validation
Partition the data into k folds, and each of the folds is set aside at turn as a test set.  A clustering model is then computed on the other k − 1 training sets, and the value of the objective function (for example, the sum of the squared distances to the centroids for k-means) calculated for the test set. Compare the averages of these k values for each alternative number of clusters, and select the number of cluster such that a further increase leads to only a small reduction in the objective function.

Reference: https://en.wikipedia.org/wiki/Determining_the_number_of_clusters_in_a_data_set
### [2018-10-23](https://mp.weixin.qq.com/s/kBcwmqle1OR221I4ONqiRw)
**Question:** A/B测试有什么作用?
**Answer:** 它是对具有两个变量A和B的随机实验的统计假设检验.A / B测试的目标是识别网页的任何变化以最大化或增加收益的结果。 一个例子可以是识别横幅广告的点击率。

### [2018-10-24](https://mp.weixin.qq.com/s/3Rxsv2CLxtrt2GsoabiU3w)
**Question:** 什么是Boosting和Stacking，两者有什么不同?
**Answer:** 
 - Boosting提供预测变量的顺序学习。 第一个预测器是在整个数据集上学习的，而后续的预测器则是基于前一个预测器的结果在训练集上学习的。 它首先对原始数据集进行分类，并为每个观察值赋予相同的权重。 如果使用第一个学习器预测分类错误，那么给予分错类的观察样例更高的权重。 作为一个迭代过程，它继续添加分类器学习器，直到达到模型数量或精度的限制。 Boosting显示出比Bagging更好的预测准确性，但它也倾向于过度拟合训练数据。
 - Stacking 分为两个阶段。 首先，我们使用多个基本分类器来预测类。 其次，将基分类器的预测组合起来作为一个新学习器，以减少泛化错误。
