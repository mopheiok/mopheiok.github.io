title: Spark 作业调度
mathjax: true
tags:
  - Spark
categories:
  - Spark
date: 2018-12-02 10:55:00
keywords:
description:
---
当谈及Spark中的调度时，往往容易使人迷惑。是指集群中多个spark运行程序的调度？还是指在一个spark程序内部不同任务的调度？于是，Spark调度可以分为两个层次：Spark应用间的调度和Spark应用内的调度。

<!--more-->


## Spark应用间的调度
Spark提交作业到Yarn上，由Yarn来调度各作业间的关系。Yarn的调度策略可以为FAIR或者FIFO。
在应用间的调度可以进一步分为两层，第一小层是Yarn的队列，第二小层是队列内的调度。Spark作业提交到不同的队列，通过设置不同的minishare、weight等，来实现不同作业调度的优先级，这一点Spark应用跟其他跑在Yarn上的应用没有区别，统一由Yarn公平调度。比较好的做法是每个用户单独一个队列，这种配置FAIR调度就是针对用户的了，可以防止恶意用户提交大量作业导致拖垮所有人的问题。这个配置在hadoop的yarn-site.xml里。
```xml
    <property>
        <name>yarn.resourcemanager.scheduler.class</name>
        <value>org.apache.hadoop.yarn.server.resourcemanager.scheduler.fair.FairScheduler</value>
    </property>
```

## Spark应用内的调度
在指定的Spark应用内即同一个SparkContext实例，多个线程可以并发地提交Spark作业（job）。作业是指由Spark action算子触发的一系列计算任务的集合。Spark调度器是完全线程安全的，并且能够支持Spark应用同时处理多个请求（比如：来自不同用户的查询）。
这里简单列举一些调度管理模块涉及的相关概念：
 - Task（任务）：单个分区数据集上的最小处理流程单元
 - TaskSet（任务集）：由一组关联的，但相互之间没有shuffle依赖关系的任务所组成的任务集。
 - Stage（调度阶段）：一个任务集对应的调度阶段。
 - Job（作业）：由一个RDD Action生成的一个或多个调度阶段所组成的一次计算作业。
 - Application（应用程序）：Spark应用程序，由一个或多个作业组成。

![作业调度相关概念的逻辑关系图](https://upload-images.jianshu.io/upload_images/2268630-cb46001233c46132.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

同一个SparkContext实例内部，可以配置该应用内的多个TaskSetManager间调度为FIFO还是FAIR。以Spark 的Thrift Server为例，考虑一个场景：用户a的作业很大，需要处理上T的数据，并且SQL也非常复杂，而用户b的作业很简单，只是select查看前面几条数据。由于用户a、b都在同一个SparkContext里，所以其调度完全由Spark决定；如果按FIFO的原则，可能用户b要等好一会才能从用户a的牙缝里扣出一点计算资源完成自己的作业，这样对用户b就不是那么友好了。
比较好的做法是配置Spark应用内各个TaskSetManager的调度算法为FAIR，不需要等待用户a的资源，用户b的作业可以尽快得到执行。这里需要注意，FIFO并不是说用户b只能等待用户a所有task执行完毕才能执行，而只是执行的很迟，并且不可预料。从实测情况来看，配置为FIFO，用户b完成时间不一定，一般是4~6s左右；而配置为FAIR，用户b完成时间几乎是不变的，几百毫秒。
应用内调度的配置项在{spark_base_dir}/conf/spark_default.conf: spark.scheduler.mode   FAIR

应用内可以再分两层，第一小层是Pool（资源池）间的公平调度，第二小层是Pool内的。Pool内部调度默认是FIFO的，需要设置{spark_base_dir}/conf/fairscheduler.xml，针对具体的Pool设置调度规则。*所以前面说TaskSetManager间调度不准确，应该是先Pool间再Pool内。*
下面配置default队列为FAIR调度
```xml
<allocations>
  <pool name="default">
    <schedulingMode>FAIR</schedulingMode>
    <weight>1</weight>
    <minShare>3</minShare>
  </pool>
</allocations>
```
其中每个资源池都支持以下3个属性：
 - schedulingMode：可以是FIFO或FAIR，控制资源池内部的作业是如何调度的。
 - weight：控制资源池相对其他资源池，可以分配到资源的比例。默认所有资源池的weight都是1。如果你将某个资源池的weight设为2，那么该资源池中的资源将是其他池子的2倍。如果将weight设得很高，如1000，可以实现资源池之间的调度优先级 – 也就是说，weight=1000的资源池总能立即启动其对应的作业。
 - minShare：除了整体weight之外，每个资源池还能指定一个最小资源分配值（CPU个数），管理员可能会需要这个设置。公平调度器总是会尝试优先满足所有活跃（active）资源池的最小资源分配值，然后再根据各个池子的weight来分配剩下的资源。因此，minShare属性能够确保每个资源池都能至少获得一定量的集群资源。minShare的默认值是0。

综上，如果你想要thriftserver达到SQL级别的公平调度，需要配置三个配置文件：yarn-site.xml、spark-defaults.conf、fairscheduler.xml。由于thriftserver的SQL没有按照不同用户区分多个Pool，所以其实还不算特别完整。

## 示例
Spark可以并行运行多个计算。这可以通过在driver上启动多个线程并在每个线程中发出一组转换来轻松实现。然后，生成的任务将同时运行并共享应用程序的资源。这确保了资源永远不会保持空闲（例如，在等待特定转换的最后任务完成时）。默认情况下，任务以FIFO方式处理（在作业级别），但可以通过使用[应用程序内调度程序](https://spark.apache.org/docs/latest/job-scheduling.html#scheduling-within-an-application)来确保公平性（通过设置`spark.scheduler.mode`为`FAIR`）。然后，期望线程通过将`spark.scheduler.pool`本地属性（使用`SparkContext.setLocalProperty`）设置为适当的池名来设置其调度池。每个池分配的资源由配置`spark.scheduler.allocation.file`设置定义的[XML文件](https://spark.apache.org/docs/latest/job-scheduling.html#configuring-pool-properties)确定（默认情况下，这是`fairscheduler.xml`在Spark的conf文件夹中）。
```scala
import scala.concurrent.ExecutionContext.Implicits.global
import scala.concurrent.duration._
import scala.concurrent.{Await, Future}

val spark = SparkSession
      .builder()
      .appName("Spatial data")
      .enableHiveSupport()
      .getOrCreate()

val sc = spark.sparkContext

sc.setLocalProperty("spark.scheduler.pool", "production")

def input(i: Int) = sc.parallelize(1 to i * 100000)

def serial = (1 to 10).map(i => input(i).reduce(_ + _)).sum

def parallel = (1 to 10).map(i => Future(input(i).reduce(_ + _))).map(Await.result(_, 10.minutes)).sum
```
多线程提交时，并未全部在指定的资源池中执行（原因不确定，需要进一步调研）
![多线程提交](https://upload-images.jianshu.io/upload_images/2268630-afa714a4e5ab62a9.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

The spark context is thread safe, so it's possible to call it from many threads in parallel. (I am doing it in production)

One thing to be aware of, is to limit the number of thread you have running, because:
1. the executor memory is shared between all threads, and you might get OOM or constantly swap in and out memory from the cache
2. the cpu is limited, so having more tasks than core won't have any improvement






[Spark作业调度](http://ifeve.com/spark-schedule/)
[Job Scheduling](https://spark.apache.org/docs/latest/job-scheduling.html)
[Task调度算法，FIFO还是FAIR](https://ieevee.com/tech/2016/07/11/spark-scheduler.html)
[Optimizing Spark jobs for maximum performance](https://michalsenkyr.github.io/2018/01/spark-performance)
[优化Spark作业以获得最佳性能](https://blog.csdn.net/high2011/article/details/84315922)
[Launching Apache Spark SQL jobs from multi-threaded driver](https://stackoverflow.com/questions/47842048/launching-apache-spark-sql-jobs-from-multi-threaded-driver)