title: IntelliJ IDEA远程调试Spark应用程序
mathjax: true
tags:
  - Spark
categories:
  - Tools
date: 2018-11-30 23:31:00
keywords:
description:
---
使用IDEA调试spark应用程序，是指使用spark算子编写的driver application。
在开始之前，先介绍下如何使用idea远程debug普通的jar应用。远程debug spark原理是一样的。

<!--more-->

## 远程debug普通的jar应用
先假设远程debug的适用场景是：将应用程序打成jar包，让它运行在服务器上，然后在本地idea里以debug模式去运行这个jar包。希望达到的效果就像在idea里debug本地代码一样：可以断点，可以查看变量值等等。

我们将这个运行在服务器上的jar包称为被调试对象(debuggee)，本地IDEA称为调试者(debugger)。

远程调试有两种模式，或者说两种方式可选：
1. attach模式：先运行debuggee，让其监听某个ip:port，然后等待debugger启动并连接这个端口，然后就可以在debugger上断点调试。
2. listen模式，让debugger监听某个ip:port，然后启动debuggee连接这个端口，接下来在debugger上断点调试。

### attach模式
在这种模式下，先运行debuggee，让其监听端口并等待debugger连接。
在IDEA中的操作如下图：
![](https://upload-images.jianshu.io/upload_images/2268630-8a5e34cbe9b0211c.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

复制`-agentlib:jdwp=transport=dt_socket,server=y,suspend=y,address=5005`,这个是给debuggee的jvm参数。
 - 其中将suspend=n，改成suspend=y，这样debuggee启动后会阻塞住直到debugger连接它
 - address=5005，表示debuggee监听这个端口，也可以指定成address=<ip>:<port>的形式，这里ip是debuggee运行所在的机器的ip
 - 上图中Host， Port应该和上面address中的ip，port一样，debugger会连接这个ip:port
 - transport=dt_socket是debugger和debuggee之间传输协议
 - server=y, 在模式1下这样指定， 表示debuggee作为server等待debugger连接

在IDEA(debugger)里指定好这些之后，接下来就是先运行dubggee
```sh
java -cp ***.jar -agentlib:jdwp=transport=dt_socket,server=y,suspend=y,address=10.9.233.114:5005  class
```
运行后出现下面信息：
```
Listening for transport dt_socket at address: 5005
```
表示debuggee等待连接。
接下来的过程就是在idea里，设置断点，然后像本地debug一样了。

### listen模式
这种模式下debugger监听端口并等待debuggee的连接，所以需要先启动debugger。
在IDEA里的操作如下：
![](https://upload-images.jianshu.io/upload_images/2268630-7e1e8b1f990492b4.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

该模式下先启动debugger，也就是启动idea调试，debugger会监听端口等待debuggee连接。
按照上图复制给debuggee的jvm参数：
```
-agentlib:jdwp=transport=dt_socket,server=n,address=172.16.202.150:5005,suspend=y
```
 - 这里去掉了onthrow=<FQ exception class name>,onuncaught=<y/n> 不知道是干什么的
 - address=ip:5005，该ip为debugger运行地址， debuggee连接该ip:port
 - suspend=y, listen模式下可以去掉
 - server=n， 表示由debuggee发起连接到debugger。

此时debugger先运行并监听端口，接下来运行debuggee就可以了，如下：
```
java -cp ***.jar -agentlib:jdwp=transport=dt_socket,server=n,address=172.16.202.150:5005 class
```

## 调试Spark
Spark按照角色可以分为Master、 Worker、Driver、Executor。其中Master, Worker只有在Standalone部署模式下才有，使用Yarn提交时只有Driver和Executor。使用Spark算子开发的应用提交执行后会都一个Driver和至少一个Executor，Driver充当job manager的角色，负责将RDD DAG划分为stage，创建task，调度task去executor执行等等。executor作为task executor执行算子。

### 调试Driver端相关代码
Spark应用程序都有一个Driver，在--deploy-mode client模式在，Driver在启动程序的机器上运行。如果要调试driver端代码，需要在提交参数中设置driver的调试参数：
```
spark.driver.extraJavaOptions  -agentlib:jdwp=transport=dt_socket,server=y,suspend=y,address=5005
```
这个配置可以放在$SPARK_HOME/conf/spark-defaults.conf 里面；也可以在提交应用作业的时候设置
```
--driver-java-options "-agentlib:jdwp=transport=dt_socket,server=y,suspend=y,address=5005"
```
这样就可以调试Driver相关代码了。

### 调试Executor端相关代码
Driver只是一个job manager的角色，任务的执行（也就是那些spark 算子map, filter...的执行是在executor上执行的），即Spark应用程序的RDD内部计算逻辑都是在executor中完成的，所以如果需要在Executor启动的JVM加入相关的调试参数进行相关代码调试：
```
spark.executor.extraJavaOptions  -agentlib:jdwp=transport=dt_socket,server=y,suspend=y,address=5005
```
这个配置可以放在$SPARK_HOME/conf/spark-defaults.conf 里面；也可以在提交应用作业的时候设置
```
--conf "spark.executor.extraJavaOptions=-agentlib:jdwp=transport=dt_socket,server=y,suspend=y,address=5005"
```
executor对应的main方法所在类是org.apache.spark.executor.CoarseGrainedExecutorBackend。
#### 提交细节
由于一个job 可能有多个executor，而且在集群模式下会分布在不同的节点（服务器）上，不是很好调试。测试环境下应该可以设置为local模式，此时Driver也就是唯一可以启动的Executor。此时同时设置driver和executor调试参数，即可进行executor的调试了。
```sh
spark-submit --class com.zte.vmax.metadata.Coordinator \
             --master local[*] \
             --driver-java-options "-agentlib:jdwp=transport=dt_socket,server=y,suspend=y,address=5005" \
             --driver-memory 4G \
             --executor-memory 10G \
             --conf "spark.executor.extraJavaOptions=-agentlib:jdwp=transport=dt_socket,server=y,suspend=y,address=5005" \
             --files meta_task_2018011019_6725_lte_plan_capacity_addsite_turing36.json \
             --jars lte_plan_capacity_addsite.jar \
             /home/mr/testly/commonjar/metadata-coordinator_2.0.2-r4-SNAPSHOT.jar \
             --config meta_task_2018011019_6725_lte_plan_capacity_addsite_turing36.json \
             capacity.json
```
#### 问题
在调试 Executor 相关代码可能会遇到相关的问题。比如
![](https://upload-images.jianshu.io/upload_images/2268630-59d7be0c2b3b0491.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
此时，需要将该处断点的属性设置为thread：
右键该断点，在弹出窗口中选择Thread
![](https://upload-images.jianshu.io/upload_images/2268630-3a7d98569c78716c.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
或者在debug栏中设置
![](https://upload-images.jianshu.io/upload_images/2268630-36711a66404d4a0b.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)


