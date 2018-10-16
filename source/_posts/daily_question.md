title: 每日一问
mathjax: true
tags: []
categories:
  - Data Science
date: 2018-10-16 22:26:00
keywords:
description:
---
温习数据科学（DS）和商务分析（BA）领域常见的问题，希望我们一起思考。欢迎在评论区解答或讨论！
<!--more-->

**Q:** How can you check if a data set or time series is Random?

**A:** To check whether a data set is random or not, use the lag plot. If the lag plot for the given data set does not show any structure then it is random.
[A lag plot checks whether a data set or time series is random or not. Random data should not exhibit any identifiable structure in the lag plot. Non-random structure in the lag plot indicates that the underlying data are not random.](https://www.itl.nist.gov/div898/handbook/eda/section3/lagplot.htm) Several common patterns for lag plots are shown in the examplesbelow.

**Question:** You are working on a time series data set. Your manager has asked you to build a high accuracy model. You start with the decision tree algorithm, since you know it works fairly well on all kinds of data. Later, you tried a time series regression model and got higher accuracy than decision tree model. Can this heppen? Why?

**Answer:** Time series data is known to posses linearity. On the other hand, a decision tree algorithm is known to work best to detect non-linear interactions. The reason why decision tree failed to provide robust predictions because it couldn't map the linear relationship as good as a regression model did. Therefore, we learned that, a linear regression model can provide robust prediction given the data set satisfies its linearity assumptions.