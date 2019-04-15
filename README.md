
## 开源协议

zTranslate遵守Apache2.0协议


## 介绍

支持Delphi/Lazarus的form文本内容自动国际化，支持.dfm,.fmx,.lfm

支持delphi/fpc源码自动国际化,支持.pas,.inc,.dpr,.pp

支持c源码自动国际化,支持.c,.cpp,.cc,.cs,.h,.hpp

支持自动化校对

完整自定义翻译内容和可视化翻译操作

支持基于百度翻译引擎的自动化批量翻译

支持将翻译内容导出成文本，并且能接口外包人员做国际化翻译

安全纠错系统，不会破坏源代码

完整的zDB数据库支持系统，能最小化使用百度翻译api频率，能充分节约成本开销

完整的zDB远程更新系统，对百度翻译质量不满意，可以自行修改，支持一键存储和提取


## c++/c/pascal工程已经全部测试完成

已经实测完成翻译1400万代码行的unreal4.0引擎，编译通过

已经实测完成翻译delphi内置的vcl,fmx的全部代码，编译通过

已经实测完成翻译fpc内置的fcl,lcl的全部代码，编译通过

已经实测完成翻译diocp的全部代码，编译通过

已经实测完成翻译crossSocket的全部代码，编译通过

c#工程尚未测试

java工程尚未支持



## 编译

编译zTranslate编译需要zServer4D的主工程支持
 https://github.com/PassByYou888/ZServer4D


[zTranslate编译指南](https://github.com/PassByYou888/zTranslate/blob/master/Document/zTranslate%E7%BC%96%E8%AF%91%E6%8C%87%E5%8D%97.pdf)


已经编好的可执行文件包
 https://github.com/PassByYou888/zTranslate/releases



## 使用

**注意：百度翻译需要修改配置baidu.cfg，打开该文件以后，根据指引操作即可**


[国际化开源项目的操作指南](https://github.com/PassByYou888/zTranslate/blob/master/Document/%E4%BD%BF%E7%94%A8zTranslate%E5%B0%86%E6%9C%AC%E5%9C%9F%E9%A1%B9%E7%9B%AE%E8%87%AA%E5%8A%A8%E6%9B%B4%E6%8D%A2%E4%B8%BA%E5%9B%BD%E9%99%85%E9%A1%B9%E7%9B%AE.pdf)


[校对编辑环境中的Origin Filter和Translateion Filter匹配用法](https://github.com/PassByYou888/zTranslate/blob/master/Document/%E6%A0%A1%E5%AF%B9%E7%BC%96%E8%BE%91%E7%8E%AF%E5%A2%83%E4%B8%AD%E7%9A%84Origin%20Filter%E5%92%8CTranslateion%20Filter%E5%8C%B9%E9%85%8D%E7%94%A8%E6%B3%95.pdf)



## 更新说明

### 2019-4

修复备注文本的编码bug


### 2018-2-18

lazarus的.lfm支持

修正基于utf8的多国语言代码文件支持(日俄韩德法)


### 2018-2-14

新增一个机翻选项：只翻译选中条目，只翻译勾中条目，全部翻译

校对编辑环境中的Origin Filter可以支持:符号，表示只显示勾中条目


### 2018-2-13

新增对支持Unix,Linux中无\r(#13)的换行符的代码支持

在校对编辑器中新增匹配表达式

修正校对编辑器中的Undo功能

在zTranslate的首界面，可以直接添加.dpr

在机翻大工程中，终于可以泡杯茶休息：使用机翻处理大规模工程不会再出现半途任务停止的现象，如果机翻半途任务停止，系统会自动重连，重连以后恢复任务，与手机应用和手游机制一样

在大规模机翻中，使用F12打开的QuickTranslate窗口，可以直接插入翻译队列，不会再发生等待情况

在大规模机翻中，翻译状态条会自动滚屏，黑窗提示会滚出翻译结果



### 2018-2-12 

新增delphi/dfm/fmx支持

修复quick Translate中的fixed不更新cache服务器的问题

全部代码编辑器改用memo来替代原来的synedit



- ** DFM/FMX格式翻译支持 **

![3](https://github.com/PassByYou888/zTranslate/raw/master/3.JPG)


- ** DFM/FMX格式校对工作 **

![2](https://github.com/PassByYou888/zTranslate/raw/master/2.JPG)


- ** c/shaer/cpp/c#支持 **
![4](https://github.com/PassByYou888/zTranslate/raw/master/4.JPG)

- ** 关于 **

![1](https://github.com/PassByYou888/zTranslate/raw/master/1.jpg)


请不要直接联系作者

使用zExpression有疑问请加互助qq群490269542，

by.qq600585
2018-2
