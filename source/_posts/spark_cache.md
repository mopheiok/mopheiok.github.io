title: Spark数据持久化与释放
mathjax: true
tags:
  - Spark
categories:
  - Spark
keywords:
  - Spark
  - cache
  - persist
  - unpersist
date: 2018-10-16 22:36:00
description:
---
在日常的Spark应用开发过程中，对多次使用到的数据往往会进行持久化，即将数据从HDFS中加载到内存中，这样在后续应用中不用反复从HDFS中读取数据，可以提升数据加载速度。

<!--more-->

## 持久化cache和persist
### 无效的cache/persist
cache/persist后的rdd，没有使用就unpersist，等于白干!

```scala
val rdd1 = ... // 读取hdfs数据，加载成RDD
rdd1.cache

val rdd2 = rdd1.map(...)
val rdd3 = rdd1.filter(...)

rdd1.unpersist

rdd2.take(10).foreach(println)
rdd3.take(10).foreach(println)
```
上面代码的意图是：既然rdd1会被利用两次，那么就缓存起来，用完后释放内存。问题是，rdd1还没有被复用，就被“释放”了，导致rdd2,rdd3在执行take时，仍然需要从hdfs中加载rdd1,没有到达cache效果。

### 原理

这里要从RDD的操作谈起，RDD的操作分为两类：action和tranformation。区别是tranformation输入RDD，输出RDD，而action输入RDD，输出非RDD。transformation是缓释执行的，action是即刻执行的。上面的代码中，hdfs加载数据，map，filter都是transformation，take是action。所以当rdd1加载时，并没有被调用，直到take调用时，rdd1才会被真正的加载到内存。

cache和unpersisit两个操作比较特殊，他们既不是action也不是transformation。[cache会将标记需要缓存的rdd](https://github.com/apache/spark/blob/b0d884f044fea1c954da77073f3556cd9ab1e922/core/src/main/scala/org/apache/spark/SparkContext.scala#L1306)，真正缓存是在第一次被相关action调用后才缓存；[unpersisit是抹掉该标记，并且立刻释放内存](https://github.com/apache/spark/blob/b0d884f044fea1c954da77073f3556cd9ab1e922/core/src/main/scala/org/apache/spark/SparkContext.scala#L1313)。

所以，综合上面两点，可以发现，在rdd2的take执行之前，rdd1，rdd2均不在内存，但是rdd1被标记和剔除标记，等于没有标记。所以当rdd2执行take时，虽然加载了rdd1，但是并不会缓存。然后，当rdd3执行take时，需要重新加载rdd1，导致rdd1.cache并没有达到应该有的作用，所以，正确的做法是将take提前到unpersist之前，如下：
```scala
val rdd1 = ... // 读取hdfs数据，加载成RDD
rdd1.cache

val rdd2 = rdd1.map(...)
val rdd3 = rdd1.filter(...)

rdd2.take(10).foreach(println)
rdd3.take(10).foreach(println)

rdd1.unpersist
```
这样，rdd2执行take时，会先缓存rdd1，接下来直接rdd3执行take时，直接利用缓存的rdd1，最后，释放掉rdd1。


## 释放被持久化的RDD
```scala
    val spark = SparkSession
      .builder
      .appName("Global Unpersist cached RDD")
      .getOrCreate()

    val sc = spark.sparkContext

    val rdd1 = sc.makeRDD(1 to 100)
    val rdd2 = sc.makeRDD(10 to 1000)
    rdd1.cache.setName("foo")
    rdd2.cache.setName("rdd_2")

    rdd1.count()
    rdd2.count()

    //单独释放一个RDD
    rdd1.unpersist()

    // 获得所有持久化的RDD，并进行指定释放
    val rdds = sc.getPersistentRDDs
    rdds.filter(x => x._2.name.contains("rdd")).foreach(x => x._2.unpersist())
```
[Spark: list all cached RDD names](https://stackoverflow.com/questions/38508577/spark-list-all-cached-rdd-names)
[Spark: unpersist RDDs for which I have lost the reference](https://stackoverflow.com/questions/42072287/spark-unpersist-rdds-for-which-i-have-lost-the-reference)