title: SQL中的变量绑定
mathjax: true
author: Mophei
tags: []
categories:
  - Spark
date: 2019-03-08 00:23:00
keywords:
description:
---
在Spark-sql的使用过程中可能会涉及到变量的设定
<!--more-->

```sql
set hivevar:msg={"message":"2015/12/08 09:14:4",
"client": "10.108.24.253",
"server": "passport.suning.com",
"request": "POST /ids/needVerifyCode HTTP/1.1",
"server": "passport.sing.co",
"version":"1",
"timestamp":"2015-12-08T01:14:43.273Z",
"type":"B2C",
"center":"JSZC",
"system":"WAF",
"clientip":"192.168.61.4",
"host":"wafprdweb03",
"path":"/usr/local/logs/waf.error.log",
"redis":"192.168.24.46"};

select a.* lateral view json_tuple('${hivevar:msg}','server','host', 'version') a as server, host, version; 

-- 动态查询后绑定变量（该执行不生效）
SET hivevar:gridSize = (SELECT max(grid_size) FROM cfg_coverage_threshold);

-- 查询环境中已经存在的变量
SELECT '${hivevar:spark.app.id}';

SELECT '${hivevar:spark.sql.thriftServer.limitCollectNumber}';

-- 查询环境中所有变量
SET;
```
![](https://upload-images.jianshu.io/upload_images/2268630-24813f4527a22da4.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
