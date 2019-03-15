title: 68-95-99.7法则和均方根误差
mathjax: true
author: Mophei
tags: []
categories:
  - Data Science
date: 2019-03-08 00:17:00
keywords:
description:
---
回归问题的典型指标是均方根误差（RMSE）。均方根误差测量的是系统预测误差的标准差。例如，RMSE 等于 50000，意味着，68% 的系统预测值位于实际值的 50000 美元以内，95% 的预测值位于实际值的 100000 美元以内（一个特征通常都符合高斯分布，即满足 “68-95-99.7”规则：大约68%的值落在 1σ 内，95% 的值落在 2σ 内，99.7%的值落在 3σ 内，这里的 σ 等于50000）
![](https://upload-images.jianshu.io/upload_images/2268630-73e7a79b1f400285.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

<!--more-->

$$
Pr(\mu - \sigma \leqslant X \leqslant \mu + \sigma) \approx 0.6827 \\
Pr(\mu - 2\sigma \leqslant X \leqslant \mu + 2\sigma) \approx 0.9545 \\
Pr(\mu - 3\sigma \leqslant X \leqslant \mu + 3\sigma) \approx 0.9973 
$$
In [statistics](https://en.wikipedia.org/wiki/Statistics "Statistics"), the **68–95–99.7 rule**, also known as the **empirical rule**, is a shorthand used to remember the percentage of values that lie within a band around the [mean](https://en.wikipedia.org/wiki/Arithmetic_mean "Arithmetic mean") in a [normal distribution](https://en.wikipedia.org/wiki/Normal_distribution "Normal distribution") with a width of two, four and six [standard deviations](https://en.wikipedia.org/wiki/Standard_deviation "Standard deviation"), respectively; more accurately, 68.27%, 95.45% and 99.73% of the values lie within one, two and three standard deviations of the mean, respectively.

在实际应用上，常考虑一组数据具有近似于正态分布的概率分布。若其假设正确，则约 68% 数值分布在距离平均值有 1 个标准差之内的范围，约 95% 数值分布在距离平均值有 2 个标准差之内的范围，以及约 99.7% 数值分布在距离平均值有 3 个标准差之内的范围。称为 "68-95-99.7法则"或"经验法则".

[68–95–99.7 rule](https://en.wikipedia.org/wiki/68%E2%80%9395%E2%80%9399.7_rule)

