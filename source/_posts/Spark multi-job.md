---
title: Spark多Job并发执行
date: 2018-09-25 22:56:44
tags: [Spark]
mathjax: true
categories: Spark
---
在使用spark处理数据的时候，大多数都是提交一个job执行，然后job内部会根据具体的任务，生成task任务，运行在多个进程中，比如读取的HDFS文件的数据，spark会加载所有的数据，然后根据block个数生成task数目，多个task运行中不同的进程中，是并行的，如果在同一个进程中一个JVM里面有多个task，那么多个task也可以并行，这是常见的使用方式。

<!-- more -->

考虑下面一种场景，在HDFS上某个目录下面有10个文件，我想要同时并行的去统计每个文件的数量，应该怎么做？ 其实spark是支持在一个spark context中可以通过多线程同时提交多个任务运行，然后spark context接到这所有的任务之后，通过中央调度，在来分配执行各个task，最终任务完成程序退出。

下面就来看下如何使用多线程提交任务，可以直接使用new Thread来创建线程提交，但是不建议这么做，推荐的做法是通过Executors线程池来异步管理线程，尤其是在提交的任务比较多的时候用这个会更加方便。

```scala
import java.util.concurrent.{Callable, Executors, Future}

import org.apache.spark.sql.SparkSession

import scala.collection.mutable.ArrayBuffer

object MultiThread {
  def main(args: Array[String]) {

    val spark = SparkSession
      .builder()
      .appName("Spark Multi thread")
      .getOrCreate()

    val sc = spark.sparkContext

    //保存任务返回值
    val list = ArrayBuffer[Future[String]]()
    //并行任务读取的path
    val task_paths = ArrayBuffer[String]()
    task_paths.+=("path1")
    task_paths.+=("path2")
    task_paths.+=("path3")

    //线程数等于path的数量
    val nums_threads = task_paths.length
    //构建线程池
    val executors = Executors.newFixedThreadPool(nums_threads)

    for (i <- 0 until nums_threads) {
      val task = executors.submit(new Callable[String] {
        override def call(): String = {
          val count: Long = sc.textFile(task_paths.apply(i)).count() //获取统计文件数量
          task_paths.apply(i) + " 文件数量： " + count
        }
      })

      list += task //添加集合里面
    }

    executors.shutdown()

    //遍历获取结果
    list.foreach(result => println(result.get()))

    //停止spark
    //    spark.stop()

  }

}

```

参考[Spark如何在一个SparkContext中提交多个任务](https://blog.csdn.net/u010454030/article/details/74353886)
[Spark优化(1)-多Job并发执行](http://blog.51cto.com/10120275/1961130)
