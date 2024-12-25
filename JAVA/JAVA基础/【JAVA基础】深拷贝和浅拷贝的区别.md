# 【JAVA基础】深拷贝和浅拷贝的区别

## 目录

[1. 目录](#目录)

[2. 浅拷贝（Shallow Copy）](#浅拷贝shallow-copy)

[3. 深拷贝（Deep Copy）](#深拷贝deep-copy)

[4. 代码示例](#代码示例)

- [4.1 使用`clone()`方法实现深拷贝](#使用clone方法实现深拷贝)

- [4.2 使用构造器实现深拷贝](#使用构造器实现深拷贝)

- [4.3 使用序列化和反序列化实现深拷贝](#使用序列化和反序列化实现深拷贝)

- [4.4 使用第三方库实现深拷贝（如Apache Commons Lang的SerializationUtils）](#使用第三方库实现深拷贝如apache-commons-lang的serializationutils)

- [4.5 拷贝工厂的优缺点](#拷贝工厂的优缺点)



## 浅拷贝（Shallow Copy）

- 浅拷贝仅复制对象的**基本类型字段的值**以及**对象类型字段的引用（即地址）**，但不复制引用指向的对象。
- 浅拷贝的结果是，新对象的基本类型字段是原始对象的**副本**，但是所有的引用类型字段都**指向原始对象中同一个对象**。

## 深拷贝（Deep Copy）

- 深拷贝复制对象的所有字段，无论是基本类型还是引用类型，并为所有引用类型字段创建新对象。
- 深拷贝的结果是创建一个**新的对象**，它是原始对象的完整副本，包括所有嵌套的对象。

## 代码示例

```java
package org.example;

import org.apache.commons.lang3.SerializationUtils;


import com.fasterxml.jackson.databind.ObjectMapper;

import java.io.Serializable;

class Address implements Cloneable, Serializable {
    public Address() {
    }

    String street;
    String city;


    public String getStreet() {
        return street;
    }

    public void setStreet(String street) {
        this.street = street;
    }

    public String getCity() {
        return city;
    }

    public void setCity(String city) {
        this.city = city;
    }

    // 构造方法
    Address(String street, String city) {
        this.street = street;
        this.city = city;
    }

    // 深拷贝构造方法
    public Address(Address otherAddress) {
        this.street = otherAddress.street;
        this.city = otherAddress.city;
    }

    // 拷贝工厂方法
    public static Address newAddressInstance(Address other) {
        return new Address(other.street, other.city);
    }

    @Override
    protected Object clone() throws CloneNotSupportedException {
        return super.clone();
    }
}

class User implements Cloneable, Serializable {
    public User() {
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public Address getAddress() {
        return address;
    }

    public void setAddress(Address address) {
        this.address = address;
    }

    String name;
    Address address;

    User(String name, Address address) {
        this.name = name;
        this.address = address;
    }

    // 深拷贝构造方法
    public User(User otherUser) {
        this.name = otherUser.name;
        this.address = new Address(otherUser.address); // 注意这里调用了Address的深拷贝构造方法
    }

    // 深拷贝方法，利用Jackson序列化和反序列化实现
    public User deepCopy() {
        try {
            ObjectMapper objectMapper = new ObjectMapper();
            String userJson = objectMapper.writeValueAsString(this);
            return objectMapper.readValue(userJson, User.class);
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }

    // 拷贝工厂方法
    public static User newUserInstance(User other) {
        // 对Address对象执行深拷贝
        Address copiedAddress = Address.newAddressInstance(other.address);
        return new User(other.name, copiedAddress);
    }

    @Override
    protected Object clone() throws CloneNotSupportedException {
        return super.clone();
    }
}

public class DeepCopyVsShallowCopy {
    public static void main(String[] args) throws CloneNotSupportedException {
        Address address = new Address("1234 Park Ave", "New York");
        User originalUser = new User("John Doe", address);

        // 浅拷贝
        User shallowCopyUser = originalUser;

        // 1. 重写clone的深拷贝方式
        User deepCopyUser = (User) originalUser.clone();
        deepCopyUser.setAddress((Address) address.clone());
        // 2. 使用构造器进行深拷贝的方式
        deepCopyUser = new User(originalUser); // 使用深拷贝构造方法创建副本
        // 3. 使用序列化实现深拷贝（Jackson）
        deepCopyUser = originalUser.deepCopy(); // 使用Jackson序列化和反序列化创建副本
        // 4. 使用第三方包进行深拷贝
        deepCopyUser = SerializationUtils.clone(originalUser);
        // 5. 拷贝工厂方法进行深拷贝
        deepCopyUser = User.newUserInstance(originalUser);


        // 更改原始对象中Address对象的city字段
        originalUser.address.city = "Los Angeles";

        // 浅拷贝的User对象的Address引用仍然指向同一个Address对象
        System.out.println(shallowCopyUser.address.city); // 输出 "Los Angeles"

        // 深拷贝的User对象有自己的Address对象
        System.out.println(deepCopyUser.address.city); // 输出 "New York"
    }
}
```

### 使用`clone()`方法实现深拷贝

Java语言提供了一个`clone()`方法，它定义在`Object`类中。这个方法可以用来创建对象的一个拷贝。要使用这个方法，类必须实现`Cloneable`接口，然后覆盖`clone()`方法以实现深拷贝。下面是使用`clone()`方法实现深拷贝的优缺点：

**优点**:

- `clone()`方法是Java语言内建的复制机制，无需引入外部库。
- 可以通过覆盖`clone()`方法对拷贝过程进行控制，以实现深拷贝。
- 相对于手动复制构造器，使用`clone()`方法可以避免创建新的构造器。

**缺点**:

- `Cloneable`接口本身不包含任何方法，它是一个标记接口，实现它只是告诉`clone()`方法允许进行字段复制。
- `clone()`方法默认是浅拷贝，必须在覆盖的`clone()`方法内部手动实现所有属性的深拷贝。
- `clone()`方法默认的行为可能会导致复制对象的问题，比如忽略构造函数的执行或不正确处理不可变对象。
- 异常处理可能变得复杂，因为原生的`clone()`方法定义中包含了`CloneNotSupportedException`。
- 使用`clone()`可能会破坏单例模式的对象。
- 编写正确的`clone()`方法需要对对象的结构有深入理解，否则容易出错。

使用`clone()`方法并不是通常推荐的做法，除非你需要满足特定的克隆策略并且愿意接受与之相关的复杂性。Java社区中很多专家，包括Effective Java的作者Joshua Bloch，建议避免使用`clone()`，而是使用其他的复制机制，比如拷贝构造器或者拷贝工厂。

### 使用构造器实现深拷贝

**优点**:

- 易于理解和实现。
- 无需引入第三方库。
- 可以根据需要选择性地复制属性，提供灵活性。

**缺点**:

- 手动编写，容易出错，特别是在对象结构变化时，容易忘记更新深拷贝逻辑。
- 对于拥有复杂结构或多层嵌套的对象，编写和维护成本高。

### 使用序列化和反序列化实现深拷贝

**优点**:

- 一般来说比手动复制更快捷。
- 可以自动处理复杂的对象图，包括循环引用。
- 不需要针对每个类编写深拷贝逻辑。

**缺点**:

- 性能可能不及手动复制，因为序列化和反序列化过程涉及IO操作。
- 要求所有对象以及它们引用的所有对象都必须实现`Serializable`接口。
- 序列化过程可能引入安全问题。

### 使用第三方库实现深拷贝（如Apache Commons Lang的SerializationUtils）

**优点**:

- 使用简单，一行代码实现深拷贝。
- 和手动序列化一样，可以处理复杂的对象图。

**缺点**:

- 性能问题，因为它也是基于序列化和反序列化。
- 对象必须实现`Serializable`接口。
- 引入外部依赖。

### 拷贝工厂的优缺点

**优点**:

- 明确且易于使用，尤其是在API设计中，静态工厂方法通常更可取。
- 不需要实现任何接口，如`Cloneable`。
- 提供更多控制权，可以选择性地深拷贝对象的某些属性。
- 比拷贝构造器更灵活，可以返回任何的子类对象。

**缺点**:

- 需要为每个需要深拷贝的类手动实现拷贝逻辑。
- 对于有很多属性或很多嵌套对象的类，实现起来可能会很繁琐。
- 如果类的属性经常变动，每次变动后都需要更新拷贝工厂方法。