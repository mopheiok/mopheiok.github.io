title: 经纬度计算距离
mathjax: true
author: Mophei
tags:
  - Spark
categories:
  - Spark
date: 2019-03-22 23:07:00
keywords:
description:
---
根据经纬度计算距离公式
$$
S = 2\cdot R \cdot arcsin \sqrt{sin^2\frac{a}{2} + cos(lat1) \cdot cos(lat2) \cdot sin^2\frac{b}{2}}
$$
其中:

1. `(Lng1, lat1)` 表示A点经纬度对应弧度，`(lng2, lat2)`表示B点经纬度对应弧度；
2. $a=Lat1-Lat2$为两点纬度的弧度之差，$b=Lng1-Lng2$为两点经度的弧度之差；
3. R为地球半径，$R=6378.137km$
4. 公式计算出来的结果单位为千米。若将半径改以米为单位，则计算的结果单位为米；
5. 计算经度与谷歌地图的距离经度差不多，相差范围在0.2米以下
6. 这种计算方式一般都是直线距离

一般地图上显示的左边顺序为：纬度在前（范围-90 ~ 90），经度在后（范围-180 ~ 180）



使用SQL计算距离的代码

```sql
SELECT *,
       6378.138 *1000 * 2 * ASIN(SQRT(POW(SIN((lat1 * PI() / 180 - lat2 * PI() / 180) / 2), 2) + COS(lat1 * PI() / 180) * COS(lat2 * PI() / 180) * POW(SIN((lng1 * PI() / 180 - lng2 * PI() / 180) / 2), 2))) AS distance
FROM distance
ORDER BY distance ASC
```



使用JAVA计算距离的代码

```java
private static final  double EARTH_RADIUS = 6378137;//赤道半径
private static double rad(double d){
    return d * Math.PI / 180.0;
}
public static double GetDistance(double lon1,double lat1,double lon2, double lat2) {
    double radLat1 = rad(lat1);
    double radLat2 = rad(lat2);
    double a = radLat1 - radLat2;
    double b = rad(lon1) - rad(lon2);
    double s = 2 *Math.asin(Math.sqrt(Math.pow(Math.sin(a/2),2)+Math.cos(radLat1)*Math.cos(radLat2)*Math.pow(Math.sin(b/2),2))); 
    s = s * EARTH_RADIUS;    
   return s;//单位米
}
```

