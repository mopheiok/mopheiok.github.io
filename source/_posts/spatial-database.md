title: 空间数据库
mathjax: true
tags:
  - Tree
categories: []
keywords: 'Spark, Gis, Geo, Spatial, 地理数据'
date: 2018-10-18 00:31:00
description:
---
空间数据库是一个被优化的数据库，用于存储和查询代表几何空间对象的数据。多数空间数据库能够支持点、线及多边形这些简单的几何对象。有些空间数据库则可以处理3D、拓扑覆盖、线性网络以及[TIN][1]等更复杂的几何结构[^wikipedia]。
数据库系统使用索引来实现快速查询。普通数据库的索引数据方式在进行空间查询时不够优化，因此空间数据库使用空间索引来加速对数据库的操作。

<!--more-->

除了典型的SQL查询，比如SELECT查询之外，空间数据库可以支持更多的空间操作。以下几种是由Open Geospatial Consortium标准定义的空间数据库操作：
 - 空间测量：计算线的长度，多边形的面积，两个几何对象间的距离等等
 - 空间函数：通过修改已有特征来构造新的几何对象
 - 空间预测：支持几何体之间的空间关系的真或者假查询，比如，两个多边形有重叠或者在打算建填埋场的这个区域的一公里内是否有人居住？
 - 几何构造：在可以定义形状的边或者定点已知的情况下，构造新的几何结构。
 - 查询函数：该查询返回特定信息，比如一个圆中心点的位置
 
## 空间索引
空间索引用于空间数据库的优化查询。 普通的索引类型无法满足空间查询的效率，比如两点的差异有多大，或者某些点是否在这个空间区域范围内等。一般的空间索引包括：
 - Geohash
 - HHCode
 - Grid (spatial index)
 - Z-order (curve)
 - Quadtree
 - Octree
 - UB-tree
 - **R-tree:** 通常是索引空间数据的首选方法。 使用最小边界矩形（MBR）对对象（形状，线和点）进行分组。 对象被添加到索引中的MBR中，这将导致其大小的最小增加。
 - R+ tree
 - R* tree
 - Hilbert R-tree
 - X-tree
 - kd-tree
 - m-tree: 当使用任意度量进行比较时，m树索引可用于有效地解决复杂对象上的相似性查询
 - Point access method
 - Binary space partitioning (BSP-Tree): Subdividing space by hyperplanes.


[^wikipedia]: https://en.wikipedia.org/wiki/Spatial_database

[1]: https://en.wikipedia.org/wiki/Triangulated_irregular_network