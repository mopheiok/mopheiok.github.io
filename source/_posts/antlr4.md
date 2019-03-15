title: Antlr4应用初探
mathjax: true
author: Mophei
date: 2019-03-08 00:21:08
tags:
categories:
keywords:
description:
---
## 1\. Antlr4是什么？

当我们实现一种语言时，我们需要构建读取句子（sentence）的应用，并对输入中的元素做出反应。如果应用计算或执行句子，我们就叫它**解释器（interpreter）**，包括计算器、配置文件读取器、Python解释器都属于解释器。如果我们将句子转换成另一种语言，我们就叫它**翻译器（translator）**，像Java到C#的翻译器<!--more-->和编译器都属于翻译器。不管事解释器还是翻译器，应用首先都要识别出所有有效的句子、词组、字词组等，识别语言的程序就叫**解析器（parser）或语法分析器（*syntax analyzer*）**。我们学习的终点就是如何实现自己的解析器，去解析我们的目标语言，像DSL语言、配置文件、自定义SQL等待。

### 1.1 元编程

手动编写解析器是非常繁琐的，所以我们有了ANTLR。只需要编写ANTLR的语法文件，描述我们要解析的语言的语法，之后ANTLR就会自动生成能解析这种语言的解析器。也就是说，ANTLR是一种能写出程序的程序。在学习LISP或Ruby的宏时，我们经常能接触到元编程的概念。而用来声明我们语言的ANTLR语言的语法，就是**元语言（*meta language*）**。

### 1.2 解析过程

为了简单起见，我们将解析分为两个阶段，对应我们的大脑读取文字时的过程。当我们读到一个句子时，在第一阶段，大脑会下意识地将字符组成单词，然后像查词典一样识别出它的意思。在第二阶段，大脑会根据已识别的单词去识别句子的结构。第一阶段的过程叫**词法分析（*lexical analysis*）**，对应的分析程序叫*lexer*，负责将符号（token）分组成**符号类（*token class or token type*）**。而第二阶段就是真正的*paser*，默认*ANTLR*会构建出一颗**分析树（*parse tree*）**或叫**语法树（*syntax tree*）**。如下图，就是简单的赋值表达式的解析过程：

![](https://upload-images.jianshu.io/upload_images/2268630-a3ff4fd0afdc538c.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

语法树的叶子是输入*token*，而上级结点是包含其孩子结点的词组名（*phase*），线性的句子其实是语法树的序列化。最终生成语法树的好处是：树形结构易于遍历和处理，并且易被程序员理解，方便了应用代码做进一步处理。

多种解释或翻译的应用代码都可以重用一个解析器。但*ATRLR*也支持像传统解析器生成器那样，将应用处理代码嵌入到语法中。<!--具体什么意思？-->

对于因为计算依赖而需要多趟处理的翻译器来说，语法树非常有用！我们不用多次调用解析器去解析，只需要高效地遍历语法树多次。

## 2\. *ANTLR*在*IDE*中的应用

### 2.1 安装*IDE*插件

这里使用的是Intellij IDEA，所以在Plugins中搜“ANTLR v4 grammar plugin”插件，重启IDEA即可使用。如果想在*IDE*外使用，需要下载*ANTLR*包，是*JAVA*写成的，后面在*IDEA*中的各种操作都可以手动执行命令来完成。

![](https://upload-images.jianshu.io/upload_images/2268630-f777fcf869fcd5a9.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)


### 2.2 动手实现解析器

#### 2.2.1 编写.g4文件

创建一个文件，后缀名是g4，只有这样在文件上点右键才能看到ANTLR插件的菜单。
```
/** 
 * This grammar is called ArrayInit and must match the filename: ArrayInit.g4
 */
grammar ArrayInit;
​
/* ============================================= */
/*  Parser rules start with lowercase letters.   */
/* ============================================= */
​
/** A rule called init that matches comma-separated values between {...}. */
init    : '{' value (',' value)* '}' ; // must match at least one value
​
/** A value can be either a nested array/struct or a simple integer (INT) */
value   : init
 | INT
 ;
​
/* ============================================= */
/*  Lexer rules start with uppercase letters.    */
/* ============================================= */
​
INT : [0-9]+ ; // Define token INT as one or more digits
WS : [ \t\r\n]+ -> skip ; // Define whitespace rule, toss it out
```

#### 2.2.2 自动生成代码

在.g4文件上右键就能看到ANTLR插件的两个菜单，分别用来配置ANTLR生成工具的参数（在命令行中都有对应）和触发生成文件。首先选配置菜单，将目录选择到main/java或者test/java。注意：ANTLR会自动根据Pacakage/namespace的配置，生成包的文件夹，不用预先创建。之后就点击生成菜单，于是就在我们配置的目录下自动生成如图所示代码。

![](https://upload-images.jianshu.io/upload_images/2268630-ee9d5744b8545ea1.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)


### 2.3 构建应用代码

有了生成好的解析器，我们就可以在此基础上构建应用了。

#### 2.3.1 添加运行依赖

在开始编写应用代码之前，我们要引入ANTLR运行依赖。因为我们的解析器其实只是一堆回调hook，真正的通用解析流程实现是在*ANTLR runtime*包中。所以，以sbt为例ANTLR V4的依赖是：

```scala
// https://mvnrepository.com/artifact/org.antlr/antlr4-runtime
libraryDependencies += "org.antlr" % "antlr4-runtime" % "4.7.2"
```

#### 2.3.2 应用代码

我们实现一个Listener完成翻译工作。然后在main()中构建起词法分析器和解析器，已经连接他们的数据流和语法树。

```java
import antlr4.gen.ArrayInitLexer;
import antlr4.gen.ArrayInitParser;
import org.antlr.v4.runtime.ANTLRInputStream;
import org.antlr.v4.runtime.CommonTokenStream;
import org.antlr.v4.runtime.tree.ParseTree;
import org.antlr.v4.runtime.tree.ParseTreeWalker;

public class Main {
    public static void main(String[] args) {

        // String sentence = "{1, {2, 3}, 4}";
        String sentence = "{99, 3, 451}";

        // 1.Lexical analysis 词法分析
        ArrayInitLexer lexer = new ArrayInitLexer(new ANTLRInputStream(sentence));

        CommonTokenStream tokens = new CommonTokenStream(lexer);

        // 2.Syntax analysis 语法分析
        ArrayInitParser parser = new ArrayInitParser(tokens);
        ParseTree tree = parser.init();

        // 3.Application based on Syntax Tree
        ParseTreeWalker walker = new ParseTreeWalker();
        walker.walk(new ShortToUnicodeString(), tree);
        System.out.println();
    }
}
```

ShortToUnicodeString类

```java
import antlr4.gen.ArrayInitBaseListener;
import antlr4.gen.ArrayInitParser;
import com.sun.istack.internal.NotNull;
​
public class ShortToUnicodeString extends ArrayInitBaseListener {
​
 @Override
 public void enterInit(@NotNull ArrayInitParser.InitContext ctx) {
 System.out.print('"');
 }
​
 @Override
 public void exitInit(@NotNull ArrayInitParser.InitContext ctx) {
 System.out.print('"');
 }
​
 @Override
 public void enterValue(@NotNull ArrayInitParser.ValueContext ctx) {
 if (ctx.INT() == null) {
 System.out.print(ctx.INT());
 } else {
 System.out.printf("\\u%04x", Integer.valueOf(ctx.INT().getText()));
 }
 }
}
```

[1]. [Antlr v4入门教程和实例](https://blog.csdn.net/dc_726/article/details/45399371)

[2]. [Spark SQL 中ANTLR4的应用](https://blog.csdn.net/duan_zhihua/article/details/74853103)

[3]. [如何用 ANTLR 4 实现自己的脚本语言？](http://blog.oneapm.com/apm-tech/589.html)
