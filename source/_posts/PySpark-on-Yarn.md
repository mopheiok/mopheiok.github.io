title: PySpark on Yarn的相关依赖解决方式
mathjax: true
author: Mophei
date: 2020-05-11 23:49:28
tags:
categories:
keywords:
description:
---
## 背景

Spark on Yarn是将yarn作为Cluster Manager的运行模型，Spark将资源（container）的管理与协调统一交给yarn去处理。

Spark on Yarn分为client、cluster两种模式：

- client模式：Spark程序的Driver/SparkContext实例在用户提交机上，该机器可以位于yarn集群之内或之外，只需要该机器能正常与ResourceManager通信及正确配置HADOOP_CONF_DIR或YARN_CONF_DIR环境变量指向yarn集群。生产环境中，通常提交机不会是yarn集群内部的节点。
- cluster模式：Spark程序的Driver/SparkContext实例位于ApplicationMaster(am)中，am最为一个cotainer可以起在yarn集群中任何一个NodeManager上，默认情况下，需要为所有节点机器准备好Spakr程序需要的所有运行环境。

Python提供了非常丰富的数学运算、机器学习处理库——如numpy、pandas、scipy、sklearn等等。那么如何把利用这些高效库开发的各种算法以PySpark程序跑在Spark集群上呢？

对于scala/java写的Spark程序，我们可以将所依赖的jar一起与main函数所在的主程序打成一个fat jar，通过spark-submit提交后，这些依赖就会通过Yarn的Distribute Cache分发到所有节点支撑运行；对于Python写的Spark程序如果有外部依赖就比较麻烦，因为当前还没有类似java一样的fat jar包。那如何部署Python的这些依赖呢？难道要在所有NodeManager节点上安装所需依赖包么，想想这就是一件非常痛苦的事。

参考官方文档

> For Python, you can use the `--py-files` argument of `spark-submit` to add `.py`, `.zip` or `.egg` files to be distributed with your application. If you depend on multiple Python files we recommend packaging them into a `.zip` or `.egg`.

--py-files 可以解决部分依赖问题，但对于某些场景还是不很不方便，或者不可能实现：

- 依赖太多，包括传递依赖
- Python包在deploy前需要依赖的C代码提前编译
- 基于不同版本的Python的pyspark跑在同一yarn集群上

## 方案

从灵活性的角度来讲，提供一种在运行时创建Python运行及相关依赖的办法。

1. 借助anaconda创建包含依赖的Python环境

   ```shell
   conda create --name py3env_ml --quiet --copy --yes python=3.7 numpy scipy pandas scikit-learn
   ```

   打印信息如下：

   ```
   ## Package Plan ##
   
     environment location: /home/user/anaconda2/envs/py3env_ml
   
     added / updated specs:
       - numpy
       - pandas
       - python=3.7
       - scikit-learn
       - scipy
   
   
   The following NEW packages will be INSTALLED:
   
     _libgcc_mutex      pkgs/main/linux-64::_libgcc_mutex-0.1-main
     blas               pkgs/main/linux-64::blas-1.0-mkl
     ca-certificates    pkgs/main/linux-64::ca-certificates-2020.1.1-0
     certifi            pkgs/main/linux-64::certifi-2020.4.5.1-py37_0
     intel-openmp       pkgs/main/linux-64::intel-openmp-2020.0-166
     joblib             pkgs/main/noarch::joblib-0.14.1-py_0
     ld_impl_linux-64   pkgs/main/linux-64::ld_impl_linux-64-2.33.1-h53a641e_7
     libedit            pkgs/main/linux-64::libedit-3.1.20181209-hc058e9b_0
     libffi             pkgs/main/linux-64::libffi-3.3-he6710b0_1
     libgcc-ng          pkgs/main/linux-64::libgcc-ng-9.1.0-hdf63c60_0
     libgfortran-ng     pkgs/main/linux-64::libgfortran-ng-7.3.0-hdf63c60_0
     libstdcxx-ng       pkgs/main/linux-64::libstdcxx-ng-9.1.0-hdf63c60_0
     mkl                pkgs/main/linux-64::mkl-2020.0-166
     mkl-service        pkgs/main/linux-64::mkl-service-2.3.0-py37he904b0f_0
     mkl_fft            pkgs/main/linux-64::mkl_fft-1.0.15-py37ha843d7b_0
     mkl_random         pkgs/main/linux-64::mkl_random-1.1.0-py37hd6b4f25_0
     ncurses            pkgs/main/linux-64::ncurses-6.2-he6710b0_1
     numpy              pkgs/main/linux-64::numpy-1.18.1-py37h4f9e942_0
     numpy-base         pkgs/main/linux-64::numpy-base-1.18.1-py37hde5b4d6_1
     openssl            pkgs/main/linux-64::openssl-1.1.1g-h7b6447c_0
     pandas             pkgs/main/linux-64::pandas-1.0.3-py37h0573a6f_0
     pip                pkgs/main/linux-64::pip-20.0.2-py37_3
     python             pkgs/main/linux-64::python-3.7.7-hcff3b4d_5
     python-dateutil    pkgs/main/noarch::python-dateutil-2.8.1-py_0
     pytz               pkgs/main/noarch::pytz-2020.1-py_0
     readline           pkgs/main/linux-64::readline-8.0-h7b6447c_0
     scikit-learn       pkgs/main/linux-64::scikit-learn-0.22.1-py37hd81dba3_0
     scipy              pkgs/main/linux-64::scipy-1.4.1-py37h0b6359f_0
     setuptools         pkgs/main/linux-64::setuptools-46.1.3-py37_0
     six                pkgs/main/linux-64::six-1.14.0-py37_0
     sqlite             pkgs/main/linux-64::sqlite-3.31.1-h62c20be_1
     tk                 pkgs/main/linux-64::tk-8.6.8-hbc83047_0
     wheel              pkgs/main/linux-64::wheel-0.34.2-py37_0
     xz                 pkgs/main/linux-64::xz-5.2.5-h7b6447c_0
     zlib               pkgs/main/linux-64::zlib-1.2.11-h7b6447c_3
   ```

   第一次下载上述依赖，根据网络情况可能会比较久，以后就会快很多。

2. 一般情况下，依赖包整个大小还是挺大的，为减小spark分发依赖包时的网络开销，一则最小化依赖，二则可以对依赖环境进行压缩

   ```shell
   zip -r -q -9 py3env_ml.zip ./py3env_ml
   ```

3. 把压缩后的Python环境包put到hdfs上

   ```shell
   hdfs dfs -put py3env_ml.zip /user/envs/
   ```

这样我们就可以通过 `--archives hdfs:///user/envs/py3env_ml.zip#python3env` 的方式将Python环境上传分发到Spark各个进程的working dir。

当然，也可以不上传到hdfs，此时 `--archives path/to/py3env_ml.zip#python3env` 。

## 测试

测试脚本 `coorelations_example.py`

```python
from __future__ import print_function

import numpy as np

from pyspark import SparkContext
from pyspark.mllib.stat import Statistics

if __name__ == "__main__":
    sc = SparkContext(appName="CorrelationsExample")  # SparkContext
    sc.setLogLevel("WARN")

    seriesX = sc.parallelize([1.0, 2.0, 3.0, 3.0, 5.0])  # a series
    # seriesY must have the same number of partitions and cardinality as seriesX
    seriesY = sc.parallelize([11.0, 22.0, 33.0, 33.0, 555.0])

    # Compute the correlation using Pearson's method. Enter "spearman" for Spearman's method.
    # If a method is not specified, Pearson's method will be used by default.
    print("Correlation is: " + str(Statistics.corr(seriesX, seriesY, method="pearson")))

    data = sc.parallelize(
        [np.array([1.0, 10.0, 100.0]), np.array([2.0, 20.0, 200.0]), np.array([5.0, 33.0, 366.0])]
    )  # an RDD of Vectors

    # calculate the correlation matrix using Pearson's method. Use "spearman" for Spearman's method.
    # If a method is not specified, Pearson's method will be used by default.
    print(Statistics.corr(data, method="pearson"))

    sc.stop()
```

### client 模式

```shell
spark-submit --master yarn --deploy-mode client \
--archives hdfs:///user/envs/py3env_ml.zip#python3env \
--conf spark.pyspark.driver.python=/home/amy/anaconda2/envs/py3env_ml/bin/python \
--conf spark.pyspark.python=python3env/py3env_ml/bin/python coorelations_example.py
```

输出结果，成功

```
Correlation is: 0.850028676877
[[ 1.          0.97888347  0.99038957]
 [ 0.97888347  1.          0.99774832]
 [ 0.99038957  0.99774832  1.        ]]
```

### cluster 模式

```shell
spark-submit --master yarn --deploy-mode cluster \
--archives hdfs:///user/envs/py3env_ml.zip#python3env \
--conf spark.yarn.appMasterEnv.PYSPARK_PYTHON=python3env/py3env_ml/bin/python coorelations_example.py
```

输出结果，成功

## 总结

1. 依靠anaconda 创建Python依赖环境
2. 通过 --archives 上传该环境，也等价于 `spark.yarn.dist.archives`
3. cluster模式，通过 `spark.yarn.appMasterEnv.PYSPARK_PYTHON` 指定Python执行目录
4. client模式，通过`spark.pyspark.driver.python` 指定本地driver上的Python执行目录， `spark.pyspark.python` 指定executor上的Python执行目录


[pyspark 原理](https://cwiki.apache.org/confluence/display/SPARK/PySpark+Internals)