title: Hexo搭建个人博客
mathjax: true
author: Mophei
tags:
  - git
  - hexo
categories:
  - Tools
date: 2019-03-23 18:12:00
keywords:
description:
---
## 配置Hexo环境
### Ubuntu安装Node.js

安装Node.js v11.x:
```shell
# Using Ubuntu
curl -sL https://deb.nodesource.com/setup_11.x | sudo -E bash -
sudo apt-get install -y nodejs
```

### 安装Hexo
使用npm命令安装Hexo，输入：
```
# 安装Hexo客户端
npm install -g hexo-cli

# 安装Hexo依赖
npm install
```

### 利用 gulp 压缩代码
```
npm install gulp -g
```

### 生成ssh密钥文件：
```
ssh-keygen -t rsa -C "你的GitHub注册邮箱"
```

## 配置简历的PHP环境

安装PHP

    sudo apt-get -y install php7.2
    
     # 如果之前有其他版本PHP，在这边禁用掉
    sudo a2dismod php5
    sudo a2enmod php7.2
    
    # 安装常用扩展
    sudo apt-get -y install php7.2-fpm php7.2-mysql php7.2-curl php7.2-json php7.2-mbstring php7.2-xml php7.2-intl

安装composer

1. 下载composer
       curl -sS https://getcomposer.org/installer | php
2. 安装composer
       /usr/bin/php composer.phar --version
3. 设置全局命令
       sudo mv composer.phar /usr/local/bin/composer
4. 查看是否安装与设置成功
       composer --version

在仓库代码目录下执行composer install配置所需要的依赖

## 安装生成PDF文件的工具 
1.下载最新的包 http://wkhtmltopdf.org/downloads.html

2.安装依赖的组件：
```bash
sudo apt-get install libxfont2 xfonts-encodings xfonts-utils xfonts-base xfonts-75dpi
```
3.安装wkhtmltopdf：

```bash
sudo dpkg -i wkhtmltox-\*.deb
```

4.测试：

```bash
wkhtmltopdf https://baidu.com/ baidu.pdf
```

中文乱码问题——待解决

示例：

    ./bin/md2resume html --template swissen examples/source/sample.md examples/output/
    ./bin/md2resume pdf --template swissen examples/source/sample.md examples/output/





Ubuntu下使用终端卸载软件包

    # 查看已安装的程序
    dpkg --list
    
    # 卸载程序和所有配置文件
    sudo apt-get --purge remove <packagename>
    
    #只卸载程序，保留配置文件
    sudo apt-get remove <packagename>



[1].https://zhuanlan.zhihu.com/p/26625249

[2].https://reuixiy.github.io/technology/computer/computer-aided-art/2017/06/09/hexo-next-optimization.html

[3]. [Install php7.2](https://blog.csdn.net/qq_16885135/article/details/79747045)
[4]. [Install composer](https://blog.csdn.net/meitesiluyuan/article/details/58588963)