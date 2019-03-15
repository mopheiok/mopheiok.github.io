title: 快速排序算法
mathjax: true
author: Mophei
tags:
  - 算法
categories:
  - 算法
date: 2019-03-08 00:15:00
keywords:
description:
---
参考[常用排序算法总结（性能+代码）](https://segmentfault.com/a/1190000002595152)

快速排序算法是基于“二分”的思想，其排序过程可由下图体现

![image](https://upload-images.jianshu.io/upload_images/2268630-955a13f974966aa1.gif?imageMogr2/auto-orient/strip) 

<!--more-->

快速排序的每一轮就是将这一轮的基准数归位，直到所有的数都归位为止，排序结束（类似于冒泡算法）。

partition是返回一个基准值的index，index左边都小于该index的数，右边都大于该index的数。

快速排序之所以比较快，因为相比冒泡排序，每次交换是跳跃式的。每次排序的时候设置一个基准点，将小于等于基准点的数全部放到基准点的左边，将大于等于基准点的数全部放到基准点的右边。这样在每次交换的时候就不会像冒泡排序一样每次只能在相邻的数之间进行交换，交换的距离就大的多了。因此总的比较和交换次数就少了，速度自然就提高了。当然在最坏的情况下，仍可能是相邻的两个数进行了交换。因此快速排序的最差时间复杂度和冒泡排序是一样的都是​，它的平均时间复杂度为​。

## 快速排序的优化

1.  **三者取中法**

    由于每次选择基准值都选择最后一个，这就会产生一个问题，那就是可能会造成每次都需要移动，这样会使算法性能很差，趋向于​，所以我们要找出中间位置的值。我们希望基准值能够更接近中间位置的值，所以这里可以每次使用待排序的数列部分的头、尾、中间数，在三个数中取中间大小的那个数作为基准值，然后进行快速排序，这样能够对一些情况进行优化。

2.  **根据规模大小改变算法**

    由于快速排序在数据量较小的情况下，排序性能并没有其他算法好，所以我们可以在待排序的数列分区小于某个值后，采用其他算法进行排序，而不是继续使用快速排序，这时也能得到一定的性能提升。一般这个值可以为5~25，在一些编程语言中使用10或15作为这个量。

3.  **其他分区方案考虑**

    有时，我们选择的基准数在数列中可能存在多个，这时我们可以考虑改变分区的方案，那就是分三个区间，除了小于基准数的区间、大于基准数的区间，我们还可以交换出一个等于基准数的区间，这样我们在之后每次进行递归时，就只递归小于和大于两个部分的区间，对于等于基准数的区间就不用再考虑了。

4.  **并行处理**

    由于快速排序对数组中每一小段范围进行排序，对其他段并没有影响，所以可以采用现在计算机的多线程并行处理来提高效率，这并不算是对算法的优化，只能说是一种对于数量稍微多一些的数据使用快速排序时的一个高效解决方案。


```java
package mophei.algorithm.ch03;

public class Quicksort2 {
    public int partitionByLeft(int[] A, int begin, int end) {
        int left = begin;
        int right = end;

        int pivot = begin;
        int pivotnumber = A[pivot];
        while (left != right) {
            while (A[right] > pivotnumber && left < right) {
                right--;
            } // 在右侧找到第一个不大于基准值的元素
            while (A[left] <= pivotnumber && left < right) {
                left++;
            } // 在左侧找到第一个大于基准值的元素

            swap(A, left, right); // 将找到的小于等于基准值的元素换到左边，大于基准值的元素换到右边
        }

        swap(A, left, pivot);

        return left;
    }

    public int partitionByRight(int[] A, int begin, int end) {
        int left = begin;
        int right = end;

        int pivot = end;
        int pivotNumber = A[pivot];
        while (left != right) {
            /**
             * 从左边先开始遍历，决定相遇时的值是大于基准值
             */
            while (A[left] < pivotNumber && left < right) {
                left++;
            }
            while (A[right] >= pivotNumber && left < right) {
                right--;
            }

            swap(A, left, right);
        }

        swap(A, right, pivot);

        return left;
    }

    public int partition(int[] A, int begin, int end) {
        int pivot = end;
        int pivotNumber = A[pivot];
        for (int i = end; i > -1; i--) {
            if (A[i] > pivotNumber) {
                pivot--;
                swap(A, i, pivot);
            }
        }

        swap(A, end, pivot);

        return pivot;
    }

    private void swap(int[] A, int left, int right) {
        int temp = A[left];
        A[left] = A[right];
        A[right] = temp;
    }

    public void sort(int[] A, int begin, int end) {
        if (begin < end) {
            int q;
            q = partition(A, begin, end);
            sort(A, begin, q - 1);
            sort(A, q + 1, end);
        }
    }

    public static void main(String[] args) {
//        int[] array = {8, 7, 1, 6, 5, 4, 3, 2};
        int[] array = {47, 29, 71, 99, 78, 19, 24, 47};
        Quicksort2 s = new Quicksort2();
        s.sort(array, 0, 7);
        for (int i = 0; i < array.length; i++) {
            System.out.println("output " + array[i]);
        }
    }

}

```
