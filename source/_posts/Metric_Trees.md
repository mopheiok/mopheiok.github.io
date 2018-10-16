title: Metric Trees
author: Mophei
tags:
  - 机器学习
  - 算法
mathjax: true
categories:
  - 算法
date: 2018-10-11 23:35:00
---
Metric tree in an indexing structure that allows for efficient [KNN](http://mlwiki.org/index.php/KNN) search[^1]

Metric tree organizes a set of points hierarchically

*   It's a [binary tree](http://mlwiki.org/index.php/Binary_Search_Trees): nodes = sets of points, root = all points
*   sets across siblings (nodes on the same level) are all disjoint
*   at each internal node all points are partitioned into 2 disjoint sets

<!-- more -->

Notation:

*   let $N(v)$ be all points at node $v$
*   $left(v)$,$right(v)$ - left and right children of $v$

Splitting a node:

*   choose two pivot points $p_l$ and $p_r$ from $N(v)$
*   ideally these points should be selected s.t. the distance between them is largest:
    *   $(p_l,p_r)=\arg \max _{p_l,p_r\in N(v)}\left \| p_1-p_2 \right \|$
    *   but it takes $O(n^2)$(where $n=\left | N(v) \right |$) to find optimal $p_l, p_r$
*   heuristic:
    *   pick a random point $p \in N(v)$
    * then let $p_l$ be point farthest from $p$
    * and then let $p_r$ be point farthest from $p_l$
* once we have $(p_l, p_r)$ we can partition:
    * project all points onto a line $u=p_r-p_l$
    * find the median point $A$ along the line $u$
    * all points on the left of $A$ got to $left(v)$, on the right of $A$ - to $right(v)$
    * by using the median we ensure that the depth of the tree is $O(\log N)$ where $N$ is the total number of data points
    * however finding the median is expensive
* heuristic:
    * can use the mean point as well, i.e. $A=(p_l+p_r)/2$
* let $L$ be a $d-1$ dimensional plane orthogonal to $u$ that goes through $A$
    * this $L$ is a *decision boundary* - we will use it for querying

After metric tree is constructed at each node we have:
* the decision boundary $L$
* a sphere $\mathbb B$ s.t. all points in $N(v)$ are in this sphere
     * let $center(v)$ be the center of $\mathbb B$ and $r(v)$ be the radius
    * so $N(v)\subseteqq \mathbb B(center(v), r(v))$

**MT-DFS($q$)** - the search algorithm
* search in a Metric Tree is a guided [Depth-First Search](http://mlwiki.org/index.php/Depth-First_Search "Depth-First Search")
* the decision boundary $L$ at each node $n$ is used to decide whether to go left or right
    * if $q$ is in the left , then go to $left(v)$, otherwise - to $right(v)$
     * (or can project the query point to $u$, and then check if $q< A$ or not)
* all the time we maintain $x$: nearest neighbor found so far
* let $d=\left \| x-q \right \|$ - distance from best $x$ so far to the query
* we can use $d$ to prune nodes: we can check if node is good or no point can better than $x$
    * no point is better than $x$ if $\left \| center(r)-q \right \|-r(v)\geqslant d$. That means if the hyper-sphere intersects with current candidates sphere（判断超球与当前查询点的超球是否无交集，两球心距离是否大于等两半径和：$\left \| center(v)-q \right \| \geqslant r(v) + \left \| x-q\right \|$，即满足该条件时，两个超球体相交或者相离）

This algorithm is very efficient when dimensionality is $\leqslant 30$
* but slows down when it increases

Observation:
* MT often finds the NN very quickly and then spends 95% of the time verifying that this is the true NN
* can reduce this time with Spill-Tree

[^1]: https://www.quora.com/What-is-a-kd-tree-and-what-is-it-used-for