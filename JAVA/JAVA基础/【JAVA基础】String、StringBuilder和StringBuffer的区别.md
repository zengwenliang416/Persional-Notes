# 【JAVA基础】String、StringBuilder和StringBuffer的区别

**先给答案**

`String`是不可变的，`StringBuilder`和`StringBuffer`是可变的。而`StringBuffer`是线程安全的，而`StringBuilder`是非线程安全的。

## 源码

### String

先看看`jdk1.8`中关于`String`部分的源码，我们看某个类或者某个属性是否不可变首先要看修饰类的关键字是什么，`final`表示不可改变也不可继承。

```java
public final class String
    implements java.io.Serializable, Comparable<String>, CharSequence {
    // String内部使用char数组来存储数据
    private final char value[];

    // ...
}
```

源码中`String`类和`String`类的值都采用`final`修饰，因此`String`类型是不可变的。

### StringBuilder

```java
public final class StringBuilder
    extends AbstractStringBuilder
    implements java.io.Serializable, CharSequence {

    // StringBuilder内部使用char数组来存储数据
    char[] value;

    // ... 其他方法

    // 示例方法：添加字符串
    public StringBuilder append(String str) {
        // 这里的super指向AbstractStringBuilder类
        super.append(str);
        return this;
    }
    
    // ... 其他方法继续
}

abstract class AbstractStringBuilder {
    char[] value;
    int count;

    // 实际扩展数组和添加内容在这个类中实现
    void expandCapacity(int minimumCapacity) {
        // ... 扩展逻辑
    }

    public AbstractStringBuilder append(String str) {
        if (str == null) {
            // ... 处理null字符串的情况
        }
        int len = str.length();
        ensureCapacityInternal(count + len);
        str.getChars(0, len, value, count);
        count += len;
        return this;
    }
    
    // ... 其他方法
}
```

这里关注一下抽象类AbstractStringBuilder中的append方法，从这里可以看出append方法首先根据这个字符串的长度对当前的字符数组进行扩容，这里需要看到的是

## 使用场景

- 如果字符串不需要修改，或者只是偶尔修改，使用`String`。
- 如果在单线程环境中需要频繁修改字符串，使用`StringBuilder`。
- 如果在多线程环境中需要频繁修改字符串，使用`StringBuffer`。