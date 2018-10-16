title: Spark性能优化
author: Mophei
tags:
  - Spark
categories:
  - Spark
date: 2018-10-13 00:50:00
---
在使用Spark的过程中，我们通常会受限于集群的资源（比如内存、磁盘或者CPU）。为了追求更好的性能，更简洁的Spark代码，可以从以下几个方面进行实践和优化：

 - 充分利用钨丝计划（Tungsten）
 - 分析执行计划
 - 数据管理（比如持久化、广播）
 - 云相关的优化
 
<!--more-->
 
 [1]. [Spark performance tuning from the trenches](https://medium.com/teads-engineering/spark-performance-tuning-from-the-trenches-7cbde521cf60)
 
 [2] [Spark Tuning for Enterprise System Administrators By Anya Bida](https://www.slideshare.net/SparkSummit/spark-tuning-for-enterprise-system-administrators-by-anya-bida)
 
 [3] [Top 5 mistakes when writing Spark applications](https://www.slideshare.net/hadooparchbook/top-5-mistakes-when-writing-spark-applications)
 
 [4] [Cheat Sheet - Spark Performance Tuning](https://www.slideshare.net/manishgforce/spark-performance-tuning)
 
 [5] [Spark Tuning – A Starting Point](https://pcloadletter.wordpress.com/2016/10/26/spark-tuning-a-starting-point/)
