# 典型回答

因为如果要实现多继承，就会像C++中一样，存在**菱形继承**的问题，C++为了解决菱形继承问题，又引入了**虚继承**。因为支持多继承，引入了菱形继承问题，又因为要解决菱形继承问题，引入了虚继承。而经过分析，人们发现我们其实真正想要使用多继承的情况并不多。所以，在 Java 中，不允许“多继承”，即一个类不允许继承多个父类。

除了菱形的问题，支持多继承复杂度也会增加。一个类继承了多个父类，可能会继承大量的属性和方法，导致类的接口变得庞大、难以理解和维护。此外，在修改一个父类时，可能会影响到多个子类，增加了代码的耦合度。

在Java 8以前，接口中是不能有方法的实现的。所以一个类同时实现多个接口的话，也不会出现C++中的歧义问题。因为所有方法都没有方法体，真正的实现还是在子类中的。但是，Java 8中支持了默认函数（default method ），即接口中可以定义一个有方法体的方法了。

而又因为Java支持同时实现多个接口，这就相当于通过implements就可以从多个接口中继承到多个方法了，但是，Java8中为了避免菱形继承的问题，在实现的多个接口中如果有相同方法，就会要求该类必须重写这个方法。



# 扩展知识

## 菱形继承问题

Java的创始人James Gosling曾经回答过，他表示：

“Java之所以不支持一个类继承多个类，主要是因为在设计之初我们听取了来自C++和Objective-C等阵营的人的意见。因为多继承会产生很多歧义问题。”

Gosling老人家提到的歧义问题，其实是C++因为支持多继承之后带来的菱形继承问题。

假设我们有类B和类C，它们都继承了相同的类A。另外我们还有类D，类D通过多重继承机制继承了类B和类C。

![img](./imgs/1672211742898-80096c34-a056-47fc-bf8b-0f45c4a64498.jpeg)

这时候，因为D同时继承了B和C，并且B和C又同时继承了A，那么，D中就会因为多重继承，继承到两份来自A中的属性和方法。

这时候，在使用D的时候，如果想要调用一个定义在A中的方法时，就会出现歧义。

因为这样的继承关系的形状类似于菱形，因此这个问题被形象地称为菱形继承问题。

### C++中的菱形问题

下面是一个C++中的菱形问题例子：

```cpp
#include <iostream>

class A {
public:
    virtual void doSomething() {
        std::cout << "Doing something in A\n";
    }
};

class B : public A {
public:
    void doSomething() override {
        std::cout << "Doing something in B\n";
    }
};

class C : public A {
public:
    void doSomething() override {
        std::cout << "Doing something in C\n";
    }
};

class D : public B, public C {
    // D现在从两个父类B和C继承了doSomething()方法
};

int main() {
    D d;
    // d.doSomething(); // 这里会引发编译错误，因为编译器不知道应该调用B的doSomething还是C的doSomething
    d.B::doSomething(); // 明确调用B中的doSomething
    d.C::doSomething(); // 明确调用C中的doSomething
    return 0;
}
```

在上面的代码中，类`D`继承自类`B`和类`C`，而这两个类都覆盖了来自类`A`的`doSomething()`方法。在类`D`的实例`d`中调用`doSomething()`方法时，编译器无法决定应该调用`B`的实现还是`C`的实现，因为存在二义性。为了解决这个问题，必须明确指出希望调用哪个父类的方法，如`d.B::doSomething()`或`d.C::doSomething()`。

在Java中，这个问题通过不允许类多重继承来避免，但可以通过接口实现类似多重继承的效果。当然，如果接口中有相同的默认方法，也需要在实现类中明确指出使用哪个接口中的实现。

而C++为了解决菱形继承问题，又引入了**虚继承**。

在C++中，虚继承是解决菱形问题（或钻石继承问题）的机制。通过虚继承，可以确保被多个类继承的基类只有一个共享的实例。

当两个类（如B和C）从同一个基类（如A）虚继承时，无论这个基类被继承多少次，最终派生类（如D）中只包含一个基类A的实例。下面的C++代码示例展示了虚继承的使用：

```cpp
#include <iostream>

class A {
public:
    int value;
    A() : value(1) {}
};

class B : virtual public A {
    // 使用virtual关键字进行虚继承
};

class C : virtual public A {
    // 使用virtual关键字进行虚继承
};

class D : public B, public C {
    // D从B和C继承，B和C都是从A虚继承而来
};

int main() {
    D d;
    d.value = 2; // 正确，无歧义，因为只有一个A的实例
    std::cout << d.value << std::endl; // 输出2

    B b;
    b.value = 3; // 正确，无歧义
    std::cout << b.value << std::endl; // 输出3

    C c;
    c.value = 4; // 正确，无歧义
    std::cout << c.value << std::endl; // 输出4

    return 0;
}
```

在这个例子中，`class B`和`class C`都是通过关键字`virtual`从`class A`那里继承而来的。这意味着在`class D`中，不管通过`B`还是`C`的路径，`A`只有一个实例，从而解决了因多个实例导致的歧义问题。

虚继承通常涉及到一个额外的开销，因为编译器需要维护虚基类的信息，以确保在运行时可以正确地构造和定位虚基类的实例。因此，只有在需要解决菱形问题时才应该使用虚继承。

因为支持多继承，引入了菱形继承问题，又因为要解决菱形继承问题，引入了虚继承。而经过分析，人们发现我们其实真正想要使用多继承的情况并不多。

所以，在 Java 中，不允许“声明多继承”，即一个类不允许继承多个父类。但是 Java 允许“实现多继承”，即一个类可以实现多个接口，一个接口也可以继承多个父接口。由于接口只允许有方法声明而不允许有方法实现（Java 8之前），这就避免了 C++ 中多继承的歧义问题。

## Java 8中的多继承

Java不支持多继承，但是是支持多实现的，也就是说，同一个类可以同时实现多个接口。

我们知道，在Java 8以前，接口中是不能有方法的实现的。所以一个类同时实现多个接口的话，也不会出现C++中的歧义问题。因为所有方法都没有方法体，真正的实现还是在子类中的。

那么问题来了。

Java 8中支持了默认函数（default method ），即接口中可以定义一个有方法体的方法了。

```java
public interface Pet {

    public default void eat(){
        System.out.println("Pet Is Eating");
    }
}
```

而又因为Java支持同时实现多个接口，这就相当于通过implements就可以从多个接口中继承到多个方法了，这不就是变相支持了多继承么。

那么，Java是怎么解决菱形继承问题的呢？我们再定义一个哺乳动物接口，也定义一个eat方法。

```java
public interface Mammal {

    public default void eat(){
        System.out.println("Mammal Is Eating");
    }
}
```

然后定义一个Cat，让他分别实现两个接口：

```java
public class Cat implements Pet,Mammal {

}
```

这时候，编译期会报错：

error: class Cat inherits unrelated defaults for eat() from types Mammal and Pet

这时候，就要求Cat类中，必须重写eat()方法。

```java
public class Cat implements Pet,Mammal {
    @Override
    public void eat() {
        System.out.println("Cat Is Eating");
    }
}
```

所以可以看到，Java并没有帮我们解决多继承的歧义问题，而是把这个问题留给开发人员，通过重写方法的方式自己解决。