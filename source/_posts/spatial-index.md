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