# 【AAS-6329】敏捷版加载不到classpath下的配置文件问题说明

## 问题描述

客户启动应用后，classpath下的配置文件加载失败，debug调试如下：

![image-20240130124108352](./imgs/image-20240130124108352.png)

## 问题原因

出错代码及原因分析如下：

```java
@Override
public InputStream getResourceAsStream(String name) {
    if(ENABLE_JAR_VERIFY) {
        return super.getResourceAsStream(name);
    }
    URL url = getResource(name);
    try {
        if (url == null) {
            return null;
        }
        URLConnection urlc = url.openConnection();
        InputStream is = null;
        if (urlc instanceof JarURLConnection) { // 只有在urlc是jar文件时才对is进行赋值，而用户的配置文件命名为xxx.properties，此时服务器不会为is赋值，导致getResourceAsStream返回值为空。
            JarURLConnection juc = (JarURLConnection) urlc;
            JarFile jar = juc.getJarFile();
            if (null != VERIFY_FIELD) {
                try {
                    VERIFY_FIELD.set(jar, false);
                } catch (IllegalAccessException e) {
                }
            }
            is = urlc.getInputStream();
        }
        return is;
    } catch (IOException e) {
        return null;
    }
}
```

## 实现方案

从上面代码分析是因为`urlc`不为`jar`文件时导致的`is`未被赋值而出现的空指针错误，因此将`is`赋值操作提前，修改代码如下：

```java
@Override
public InputStream getResourceAsStream(String name) {
    if(ENABLE_JAR_VERIFY) {
        return super.getResourceAsStream(name);
    }
    URL url = getResource(name);
    try {
        if (url == null) {
            return null;
        }
        URLConnection urlc = url.openConnection();
        InputStream is = urlc.getInputStream(); // 先进行赋值
        if (urlc instanceof JarURLConnection) {
            JarURLConnection juc = (JarURLConnection) urlc;
            JarFile jar = juc.getJarFile();
            if (null != VERIFY_FIELD) {
                try {
                    VERIFY_FIELD.set(jar, false);
                } catch (IllegalAccessException e) {
                }
            }
        }
        return is;
    } catch (IOException e) {
        return null;
    }
}
```

## 关联影响

修改处仅将`is`的赋值操作提前，而`if`代码块中并没有对`is`的操作，无其他关联影响。