# 【JAVA基础】String、StringBuilder和StringBuffer的区别——巨详细

## 目录
[1. 目录](#目录)
[2. 源码](#源码)
    [2.1 String](#string)
    [2.2 StringBuilder](#stringbuilder)
    [2.3 StringBuffer](#stringbuffer)
[3. String的“+”操作](#string的操作)
    [3.1 测试demo](#测试demo)
[4. 使用场景](#使用场景)



## 源码

先看看`jdk1.8`中关于`String、StringBuilder和StringBuffer`部分的源码，我们看某个类或者某个属性是否不可变首先要看修饰类的关键字是什么，`final`表示不可改变也不可继承。

### String

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
    
    // 数组最大长度
    private static final int MAX_ARRAY_SIZE = Integer.MAX_VALUE - 8

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
    public void ensureCapacity(int minimumCapacity) {
        if (minimumCapacity > 0)
            ensureCapacityInternal(minimumCapacity);
    }
    
    private void ensureCapacityInternal(int minimumCapacity) {
        // overflow-conscious code
        if (minimumCapacity - value.length > 0) {
            value = Arrays.copyOf(value,
                    newCapacity(minimumCapacity));
        }
    }
    
    private int newCapacity(int minCapacity) {
        // overflow-conscious code
        int newCapacity = (value.length << 1) + 2;
        if (newCapacity - minCapacity < 0) {
            newCapacity = minCapacity;
        }
        return (newCapacity <= 0 || MAX_ARRAY_SIZE - newCapacity < 0)
            ? hugeCapacity(minCapacity)
            : newCapacity;
    }
    
    private int hugeCapacity(int minCapacity) {
        if (Integer.MAX_VALUE - minCapacity < 0) { // overflow
            throw new OutOfMemoryError();
        }
        return (minCapacity > MAX_ARRAY_SIZE)
            ? minCapacity : MAX_ARRAY_SIZE;
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

实际上在`append`的过程中调用的是抽象类`AbstractStringBuilder`中的`append`方法，从这里可以看出`append`方法首先根据这个字符串的长度对当前的字符数组进行扩容，可以看到`StringBuilder`存储字符串类型用的也是`char[] value`，但是这里的修饰符是缺省，因此可以对其进行扩容，即可变。

### StringBuffer

`StringBuffer`和`StringBuilder`的差异不大，唯一的区别就是加上了关键字`synchronized`

```java
 public final class StringBuffer
    extends AbstractStringBuilder
    implements Serializable, CharSequence
{
    ...
    private transient char[] toStringCache;
    ...
    @Override
    public synchronized StringBuffer append(String str) {
        toStringCache = null;
        super.append(str);
        return this;
    }
    ...
}
```

## String的“+”操作

反编译

```
long t1 = System.currentTimeMillis();
String str = "hollis";
for (int i = 0; i < 50000; i++) {
    String s = String.valueOf(i);
    str += s;
}
long t2 = System.currentTimeMillis();
System.out.println("+ cost:" + (t2 - t1));
```

```
long t1 = System.currentTimeMillis();
String str = "hollis";
for(int i = 0; i < 50000; i++)
{
    String s = String.valueOf(i);
    str = (new StringBuilder()).append(str).append(s).toString();
}

long t2 = System.currentTimeMillis();
System.out.println((new StringBuilder()).append("+ cost:").append(t2 - t1).toString());
```

### 测试demo

```java
package org.example;

public class Main {
    public static void main(String[] args) {
        testStringAdd();
        testStringBuilderAdd();
    }

    static void testStringAdd() {
        Runtime runtime = Runtime.getRuntime();

        long usedMemoryBefore = runtime.totalMemory() - runtime.freeMemory();
        long startTime = System.currentTimeMillis();

        String result = "";
        for (int i = 0; i < 10000; i++) {
            result += "some text";
        }

        long endTime = System.currentTimeMillis();
        System.out.println("String concatenation with + operator took: " + (endTime - startTime) + " milliseconds");
        long usedMemoryAfter = runtime.totalMemory() - runtime.freeMemory();
        System.out.println("Memory used for String concatenation: " + (usedMemoryAfter - usedMemoryBefore) + " bytes");
    }

    static void testStringBuilderAdd() {
        Runtime runtime = Runtime.getRuntime();

        long usedMemoryBefore = runtime.totalMemory() - runtime.freeMemory();
        long startTime = System.currentTimeMillis();

        StringBuilder builder = new StringBuilder();
        for (int i = 0; i < 10000; i++) {
            builder.append("some text");
        }

        long endTime = System.currentTimeMillis();
        System.out.println("String concatenation with StringBuilder took: " + (endTime - startTime) + " milliseconds");

        long usedMemoryAfter = runtime.totalMemory() - runtime.freeMemory();
        System.out.println("Memory used for String concatenation: " + (usedMemoryAfter - usedMemoryBefore) + " bytes");
    }
}
```

从控制台上可以看到两者的性能差异十分明显。

```
String concatenation with + operator took: 669 milliseconds
Memory used for String concatenation: 619980944 bytes
String concatenation with StringBuilder took: 0 milliseconds
Memory used for String concatenation: 0 bytes
```

将`testStringAdd`中的`“+”`部分反编译后，得到如下代码：

```
String result = "";
for (int i = 0; i < 10000; i++) {
    result = (new StringBuilder()).append("some text").toString();
}
```

这里可以看出来实际上`“+”`做的操作就是`new StringBuilder()`

## 使用场景

- 如果字符串不需要修改，或者只是偶尔修改，使用`String`。
- 如果在单线程环境中需要频繁修改字符串，使用`StringBuilder`。
- 如果在多线程环境中需要频繁修改字符串，使用`StringBuffer`。