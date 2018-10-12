title: Spark性能优化
author: Mophei
tags: spark
categories: Spark
date: 2018-10-13 00:50:30
---
在使用Spark的过程中，我们通常会受限于集群的资源（比如内存、磁盘或者CPU）。为了追求更好的性能，更简洁的Spark代码，可以从以下几个方面进行实践和优化：

 - 充分利用钨丝计划（Tungsten）
 - 分析执行计划
 - 数据管理（比如持久化、广播）
 - 云相关的优化
 
 
 [1]. [Spark performance tuning from the trenches](https://medium.com/teads-engineering/spark-performance-tuning-from-the-trenches-7cbde521cf60)