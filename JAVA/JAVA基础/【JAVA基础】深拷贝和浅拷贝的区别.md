# 【JAVA基础】深拷贝和浅拷贝的区别

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


        // 更改原始对象中Address对象的city字段
        originalUser.address.city = "Los Angeles";

        // 浅拷贝的User对象的Address引用仍然指向同一个Address对象
        System.out.println(shallowCopyUser.address.city); // 输出 "Los Angeles"

        // 深拷贝的User对象有自己的Address对象
        System.out.println(deepCopyUser.address.city); // 输出 "New York"
    }
}
```

