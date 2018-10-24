title: SpatialSpark源码阅读
mathjax: true
keywords: 'spatial,spark,源码,空间数据,RDD'
description: 基于Spark实现的空间大数据的处理框架，能够完成KNN查询和区域查询（range query）
tags:
  - Spark
  - QuadTree
  - R-Tree
categories:
  - Spark
date: 2018-10-22 21:49:00
---
## 构建spatialRDD
### 基于key-value形式的RDD生成SpatialRDD
类SpatialRDD继承自spark-core的RDD
![spatialRDD.png](https://upload-images.jianshu.io/upload_images/2268630-bd59abb63a940a0c.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
伴生对象SpatialRDD调用updatable函数对k-v RDD进行构造。其中对重复key进行了任意合并，具体怎么实现呢？？？定义了函数z和f，而函数z和f在elems上的应用则是在再次调用的updatable中定义，该现象为[scala高阶函数][1][2]中的一个函数作为另一个函数的参数
```scala
/**
   * Constructs an updatable IndexedRDD from an RDD of pairs, merging duplicate keys arbitrarily. 任意合并重复key怎么体现？？？
   */
def updatable[K: ClassTag, V: ClassTag](elems: RDD[(K, V)]): SpatialRDD[K, V] = updatable[K, V, V](elems, z = (id, a) => a, f = (id, a, b) => b)
 //定义了函数z和f，而函数z和f在elems上的应用则是在updatable中定义，该现象为高阶函数中的一个函数作为另一个函数的参数

 /**
   * Constructs an SpatialRDD from an RDD of pairs.
   * the default partitioner is the quadtree based partioner
   */
def updatable[K: ClassTag, U: ClassTag, V: ClassTag](elems: RDD[(K, V)], z: (K, U) => V, f: (K, V, U) => V): SpatialRDD[K, V] = {
    val elemsPartitioned = elems.partitionBy(new QtreePartitioner(Util.numPartition, Util.sampleRatio, elems))
    val partitions = elemsPartitioned.mapPartitions[SpatialRDDPartition[K, V]](
      iter => Iterator(RtreePartition(iter, z, f)),
      preservesPartitioning = true)
    new SpatialRDD(partitions)
  }
```
在对key-valueRDD进行数据切割的时候，重新定义了一个分区函数QtreePartitioner，类似于spark原生的`HashPatitionner`（哈希分区）和`RangePatitioner`（区域分区），既决定了RDD本身的分区数量，也可以作为其父RDD Shuffle输出（MapOutput）中每个分区进行数据切割的依据。

### 新的分区函数QtreePartitioner
Spark内部提供了`HashPartitioner`和`RangePartitioner`两种分区策略，这两种分区策略在很多情况下都适合我们的场景。但是有些情况下，Spark内部不能符合需求，这时候就可以自定义分区策略。为此，Spark提供了相应的接口，我们只需要扩展`Partitioner`抽象类，然后实现里面的三个方法：
```scala
package org.apache.spark

/**
 * An object that defines how the elements in a key-value pair RDD are partitioned by key.
 * Maps each key to a partition ID, from 0 to `numPartitions - 1`.
 */
abstract class Partitioner extends Serializable {
  def numPartitions: Int
  def getPartition(key: Any): Int
}
```
`def numPartitions: Int`：这个方法需要返回你想要创建分区的个数；
`def getPartition(key: Any): Int`：这个函数需要对输入的key做计算，然后返回该key的分区ID，范围一定是0到`numPartitions-1`；
`equals()`：这个是Java标准的判断相等的函数，之所以要求用户实现这个函数是因为Spark内部会比较两个RDD的分区是否一样。[^Spark自定义分区(Partitioner)]





[^Spark自定义分区(Partitioner)]: https://www.iteblog.com/archives/1368.html

[1]: https://www.ibm.com/developerworks/cn/java/j-lo-funinscala3/index.html
[2]: https://blog.csdn.net/lovehuangjiaju/article/details/47079383