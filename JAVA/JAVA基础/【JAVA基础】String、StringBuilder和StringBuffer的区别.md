# 【JAVA基础】String、StringBuilder和StringBuffer的区别

**先给答案**

`String`是不可变的，`StringBuilder`和`StringBuffer`是可变的。而`StringBuffer`是线程安全的，而`StringBuilder`是非线程安全的。

## 源码

先看看jdk1.8中关于String部分的源码，我们看某个类或者某个属性是否不可变首先要看修饰类的关键字是什么，final表示不可改变也不可继承。

```java
public final class String
    implements java.io.Serializable, Comparable<String>, CharSequence {
    // String内部使用char数组来存储数据
    private final char value[];

    // ...
}
```

源码中String类和String类的值都采用final修饰，因此String类型是不可变的。



## 使用场景

- 如果字符串不需要修改，或者只是偶尔修改，使用`String`。
- 如果在单线程环境中需要频繁修改字符串，使用`StringBuilder`。
- 如果在多线程环境中需要频繁修改字符串，使用`StringBuffer`。