title: Spark Code Segment
mathjax: true
keywords: 'Spark,map,mapPartitions,rangepartitioner,checkpoint,cache,locality level'
description: 在使用Spark过程中的代码片段
tags:
  - Spark
categories:
  - Spark
date: 2018-10-29 22:22:00
---
## RangePartitioner
```scala
private sealed case class Item(value: Int)

val rdd = sc.parallelize(1 to 4500).map(x => (Item(x), Item(x)))
val partitioner = new RangePartitioner(1500, rdd)
partitioner.getPartition(Item(100))
```

## checkpoint
 - spark 里面的 checkpoint 和 cache的区别
There is a significant difference between cache and checkpoint. Cache materializes the RDD and keeps it in memory and/or disk. But the lineage of RDD (that is, seq of operations that generated the RDD) will be remembered, so that if there are node failures and parts of the cached RDDs are lost, they can be regenerated. However, checkpoint saves the RDD to an HDFS file and actually forgets the lineage completely. This is allows long lineages to be truncated and the data to be saved reliably in HDFS (which is naturally fault tolerant by replication).
 - checkpoint 的正确使用姿势
有一点要注意， 因为checkpoint是需要把 job 重新从头算一遍， 最好先cache一下， checkpoint就可以直接保存缓存中的 RDD 了， 就不需要重头计算一遍了， 对性能有极大的提升。使用很简单， 就是设置一下 checkpoint 目录，然后再rdd上调用 checkpoint 方法， action 的时候就对数据进行了 checkpoint
 ```scala
val data = sc.textFile("/tmp/spark/1.data").cache() // 注意要cache 
sc.setCheckpointDir("/tmp/spark/checkpoint")
data.checkpoint  
data.count
```
checkpoint 将 RDD 持久化到 HDFS 或本地文件夹，如果不被手动 remove 掉，是一直存在的，也就是说可以被下一个 driver program 使用。 

## 不同的 Locality Level
 - PROCESS_LOCAL: 数据和 task 在同一个executor jvm 中，最好的就是这种 locality。
 - NODE_LOCAL: 数据在同一个节点上。比如数据在同一个节点的另一个 executor上；或在 HDFS 上，恰好有 block 在同一个节点上。速度比 PROCESS_LOCAL 稍慢，因为数据需要在不同进程之间传递或从文件中读取
 - NO_PREF: 数据从哪里访问都一样快，不需要位置优先
 - RACK_LOCAL: 数据在同一机架的不同节点上。需要通过网络传输数据及文件 IO，比 NODE_LOCAL 慢
 - ANY: 数据在非同一机架的网络上，速度最慢

举个例子， 假如 一个 task 要处理的数据，在上一个 stage 中缓存下来了， 这个 task 期望的 就是以 PROCESS_LOCAL 来运行， 这个时候缓存数据的executor 不巧正在执行 其他的task， 那么我就等一会， 等多长时间呢， spark.locality.wait.process这么长时间， 如果时间超了， executor 还是没有空闲下来， 那么我没有办法， 我就以NODE_LOCAL 来运行 task， 这个时候我想到 同一台机器上其他 executor 上跨jvm 去拉取数据， 如果同一台机器上有其他空闲的 executor 可以满足， 就这么干， 如果没有， 等待 spark.locality.wait.node 时间， 还没有就以更低的 Locality Level 去执行这个 task。

## [查看分区元素数工具](https://dataknocker.github.io/2014/08/29/spark%E6%9F%A5%E7%9C%8B%E5%88%86%E5%8C%BA%E5%85%83%E7%B4%A0%E6%95%B0%E5%B7%A5%E5%85%B7/ "spark查看分区元素数工具")
```scala
import org.apache.spark.SparkContext
import org.apache.spark.rdd.RDD

import scala.reflect.ClassTag

object RDDUtils extends Serializable {
  def getPartitionCounts[T](sc : SparkContext, rdd : RDD[T]) : Array[Long] = {
    sc.runJob(rdd, getIteratorSize _)
  }
  def getIteratorSize[T](iterator: Iterator[T]): Long = {
    var count = 0L
    while (iterator.hasNext) {
      count += 1L
      iterator.next()
    }
    count
  }

  def collectPartitions[T: ClassTag](sc: SparkContext, rdd: RDD[T]): Array[Array[T]] = {
    sc.runJob(rdd, (iter: Iterator[T]) => iter.toArray)
  }
}

val rdd = sc.parallelize(Array(("A",1),("A",1),("A",1),("b",1),("b",1)), 5)
RDDUtils.getPartitionCounts(sc, rdd).foreach(println)
RDDUtils.collectPartitions(sc, rdd)
```

##  [*map* VS *mapPartitions*](http://wanshi.iteye.com/blog/2183906)
`mapPartitions`函数和`map`函数类似，只不过映射函数的参数由RDD中的每一个元素变成了RDD中每一个分区的迭代器。
假设一个rdd有10个元素，分成3个分区。如果使用map方法，map中的输入函数会被调用10次；而使用mapPartitions方法的话，其输入函数会只会被调用3次，每个分区调用1次。
```scala
//生成10个元素3个分区的rdd a，元素值为1~10的整数（1 2 3 4 5 6 7 8 9 10），sc为SparkContext对象
val a = sc.parallelize(1 to 10, 3)
//定义两个输入变换函数，它们的作用均是将rdd a中的元素值翻倍
//map的输入函数，其参数e为rdd元素值   
def myfuncPerElement(e:Int):Int = {
       println("e="+e)
       e*2
  }
 //mapPartitions的输入函数。iter是分区中元素的迭代子，返回类型也要是迭代子
def myfuncPerPartition ( iter : Iterator [Int] ) : Iterator [Int] = {
     println("run in partition")
     var res = for (e <- iter ) yield e*2
      res
}

val b = a.map(myfuncPerElement).collect
val c = a.mapPartitions(myfuncPerPartition).collect
// 可看到打印了3次run in partition，打印了10次e=
```
从输入函数（myfuncPerElement、myfuncPerPartition）层面来看，map是推模式，数据被推到myfuncPerElement中；mapPartitons是拉模式，myfuncPerPartition通过迭代子从分区中拉数据。
这两个方法的另一个区别是在大数据集情况下的资源初始化开销和批处理处理，如果在myfuncPerPartition和myfuncPerElement中都要初始化一个耗时的资源，然后使用，比如数据库连接。在上面的例子中，myfuncPerPartition只需初始化3个资源（3个分区每个1次），而myfuncPerElement要初始化10次（10个元素每个1次），显然在大数据集情况下（数据集中元素个数远大于分区数），mapPartitons的开销要小很多，也便于进行批处理操作。