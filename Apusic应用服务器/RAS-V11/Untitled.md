



```java
        // Construct the class loader itself
        final URL[] array = set.toArray(new URL[0]);
        if (parent == null) {
            return new URLClassLoader(array);
        } else {
            return new URLClassLoader(array, parent);
        }
```



```java
    if (parent == null) {
        return new URLClassLoader(array);
    } else {
        return new URLClassLoader(array, parent);
    }
```