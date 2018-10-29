title: 空间的索引结构
mathjax: true
tags:
  - Tree
categories:
  - 算法
keywords: 'spark,rdd,spatial,空间数据,r树'
description: 利用spark实现R-Tree算法和QuadTree算法，对空间数据构造基于树结构的RDD，支持区域查询（range query）和KNN查询
date: 2018-10-21 19:09:00
---
## 空间查询
 - 最邻近查询：给定一个点或者对象，查询满足条件的最近对象
 - 区域查询：查询全部或者部分落在限定区域内的对象
 ![空间查询.png](https://upload-images.jianshu.io/upload_images/2268630-a855e550029edfd9.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

## 空间索引结构
### 基于空间分割的索引结构
 - Grid-based
 - Quad-tree
 四叉树索引的基本思想是将地理空间递归划分为不同层次的树结构。它将已知范围的空间等分成四个相等的子空间，如此递归下去，直至树的层次达到一定深度或者满足某种要求后停止分割。四叉树的结构比较简单，并且当空间数据对象分布比较均匀时，具有比较高的空间数据插入和查询效率，因此四叉树是GIS中常用的空间索引之一。常规四叉树的结构如图所示，**地理空间对象都存储在叶子节点上，中间节点以及根节点不存储地理空间对象。**
![四叉树示例](https://img-blog.csdn.net/20131005154434687?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvemhvdXh1Z3VhbmcyMzY=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)
四叉树对于区域查询，效率比较高。但如果空间对象分布不均匀，随着地理空间对象的不断插入，四叉树的层次会不断地加深，将形成一棵严重不平衡的四叉树，那么每次查询的深度将大大的增多，从而导致查询效率的急剧下降。

 四叉树结构是自顶向下逐步划分的一种树状的层次结构。传统的四叉树索引存在着以下几个缺点：
1. 空间实体只能存储在叶子节点中，中间节点以及根节点不能存储空间实体信息，随着空间对象的不断插入，最终会导致四叉树树的层次比较深，在进行空间数据窗口查询的时候效率会比较低下。
2. 同一个地理实体在四叉树的分裂过程中极有可能存储在多个节点中，这样就导致了索引存储空间的浪费。
3. 由于地理空间对象可能分布不均衡，这样会导致常规四叉树生成一棵极为不平衡的树，这样也会造成树结构的不平衡以及存储空间的浪费。
 
 相应的改进方法，将地理实体信息存储在完全包含它的最小矩形节点中，不存储在它的父节点中，每个地理实体只在树中存储一次，避免存储空间的浪费。首先生成满四叉树，避免在地理实体插入时需要重新分配内存，加快插入的速度，最后将空的节点所占内存空间释放掉。改进后的四叉树结构如下图所示。四叉树的深度一般取经验值4-7之间为最佳。
![改进的四叉树结构](https://img-blog.csdn.net/20131005154459171?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvemhvdXh1Z3VhbmcyMzY=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)
 - k-D tree
 
### 数据驱动的索引结构
R-Tree
![comparison.png](https://upload-images.jianshu.io/upload_images/2268630-b3a6832de273974b.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
[GeoSpark](http://datasystemslab.github.io/GeoSpark/)
[SpatialSpark](https://github.com/MopheiOK/SpatialSpark)
[SpatialSpark和SparkDistributedMatrix调研小结](https://blog.csdn.net/noshandow/article/details/51462101)
[Spatial Database](https://en.wikipedia.org/wiki/Spatial_database)
[城市计算](https://www.microsoft.com/en-us/research/project/%E5%9F%8E%E5%B8%82%E8%AE%A1%E7%AE%97/)
[轨迹数据挖掘](https://www.microsoft.com/en-us/research/project/trajectory-data-mining/)