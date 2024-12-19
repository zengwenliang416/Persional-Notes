多继承是为了保证子类能够复用不同父类的方法，使用多继承会产生存在**菱形继承**的问题。`C++`使用虚继承的方式解决菱形继承问题。在现实生活中，我们真正想要使用多继承的情况并不多。因此在`Java`中并不允许多继承，但是`Java`可以通过以多接口的方式实现多继承的功能，即一个子类复用多个父类的方法。当接口中有同名方法时，子类必须重写同名方法。

此外，如果一个类继承了多个父类，那么势必会继承大量的属性和方法，这样会导致类的接口变得十分庞大，难以理解和维护。当尝试去修改父类时，会影响到多个子类，增加了代码的耦合度。

在`Java 8`以前，接口中是不能有方法的实现的。所以一个类同时实现多个接口的话，也不会出现`C++`中的歧义问题。因为所有方法都没有方法体，真正的实现还是在子类中的。但是，Java 8中支持了默认函数（`default method` ），即接口中可以定义一个有方法体的方法了。

而又因为Java支持同时实现多个接口，这就相当于通过`implements`就可以从多个接口中继承到多个方法了，但是，`Java8`中为了避免菱形继承的问题，在实现的多个接口中如果有相同方法，就会要求该类必须重写这个方法。



# 扩展知识

## 目录
- [1. 目录](#目录)
- [2. 菱形继承问题](#菱形继承问题)
    - [2.1 C++中的菱形问题](#c中的菱形问题)
    - [2.2 Java 8中的多继承](#java-8中的多继承)
- [3. 耦合度增加](#耦合度增加)



## 菱形继承问题

假设我们有类`B`和类`C`，它们都继承了相同的类`A`。另外我们还有类`D`，类`D`通过多重继承机制继承了类`B`和类`C`。

```
    类A
   /    \
  /      \
类B      类C
  \      /
   \    /
    类D
```

在上面这个结构中，类`A`是基类，类`B`和类`C`是派生类，而类`D`从类`B`和类`C`继承。如果类`B`和类`C`修改了来自`A`的某个属性或方法，类`D`在调用该属性或方法时，编译器或运行时环境就不清楚应该使用`B`的版本还是`C`的版本，形成了歧义。

### C++中的菱形问题

下面是一个`C++`中的菱形问题例子：

```cpp
# include <iostream>

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

在`Java`中，这个问题通过不允许类多重继承来避免，但可以通过接口实现类似多重继承的效果。当然，如果接口中有相同的默认方法，也需要在实现类中明确指出使用哪个接口中的实现。

`C++`为了解决菱形继承问题，又引入了**虚继承**。

在`C++`中，虚继承是解决菱形问题（或钻石继承问题）的机制。通过虚继承，可以确保被多个类继承的基类只有一个共享的实例。

当两个类（如`B`和`C`）从同一个基类（如`A`）虚继承时，无论这个基类被继承多少次，最终派生类（如`D`）中只包含一个基类`A`的实例。下面的`C++`代码示例展示了虚继承的使用：

```cpp
# include <iostream>

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

所以，在 `Java` 中，不允许“声明多继承”，即一个类不允许继承多个父类。但是 `Java` 允许“实现多继承”，即一个类可以实现多个接口，一个接口也可以继承多个父接口。由于接口只允许有方法声明而不允许有方法实现（`Java 8`之前），这就避免了 `C++` 中多继承的歧义问题。

### Java 8中的多继承

`Java`不支持多继承，但是是支持多实现的，也就是说，同一个类可以同时实现多个接口。

我们知道，在`Java 8`以前，接口中是不能有方法的实现的。所以一个类同时实现多个接口的话，也不会出现`C++`中的歧义问题。因为所有方法都没有方法体，真正的实现还是在子类中的。

那么问题来了。

`Java 8`中支持了默认函数（`default method` ），即接口中可以定义一个有方法体的方法了。

```java
public interface Pet {

    public default void eat(){
        System.out.println("Pet Is Eating");
    }
}
```

而又因为`Java`支持同时实现多个接口，这就相当于通过`implements`就可以从多个接口中继承到多个方法了，这不就是变相支持了多继承么。

那么，`Java`是怎么解决菱形继承问题的呢？我们再定义一个哺乳动物接口，也定义一个`eat`方法。

```java
public interface Mammal {

    public default void eat(){
        System.out.println("Mammal Is Eating");
    }
}
```

然后定义一个`Cat`，让他分别实现两个接口：

```java
public class Cat implements Pet,Mammal {

}
```

这时候，编译期会报错：

`error: class Cat inherits unrelated defaults for eat() from types Mammal and Pet`

这时候，就要求`Cat`类中，必须重写`eat()`方法。

```java
public class Cat implements Pet,Mammal {
    @Override
    public void eat() {
        System.out.println("Cat Is Eating");
    }
}
```

所以可以看到，`Java`并没有帮我们解决多继承的歧义问题，而是把这个问题留给开发人员，通过重写方法的方式自己解决。

## 耦合度增加

由于Java不允许多重继承，在这里使用一个假设性的代码示例来解释如果Java允许多重继承，会发生什么情况。

假设我们有两个父类`ClassA`和`ClassB`，它们都有大量的方法和属性：

```java
class ClassA {
    public void methodA1() { /* ... */ }
    public void methodA2() { /* ... */ }
    // ... 更多方法

    public int propertyA1;
    public int propertyA2;
    // ... 更多属性
}

class ClassB {
    public void methodB1() { /* ... */ }
    public void methodB2() { /* ... */ }
    // ... 更多方法

    public int propertyB1;
    public int propertyB2;
    // ... 更多属性
}
```

现在，我们创建一个类`ClassC`，它假设性地从`ClassA`和`ClassB`中继承：

```java
// 假设的多重继承，在Java中实际上是不允许的
class ClassC extends ClassA, ClassB {
    public void methodC() {
        // ClassC 的特定方法
    }
}
```

在这个假设的多重继承场景中，`ClassC`会继承来自`ClassA`和`ClassB`的所有方法和属性。这导致了几个问题：

1. **接口庞大**：
   类`ClassC`的接口变得非常庞大，它包含了`ClassA`和`ClassB`所有的方法和属性。这使得`ClassC`非常复杂，难以理解和使用。

2. **维护困难**：
   由于`ClassC`依赖于两个父类，任何对`ClassA`或`ClassB`的修改都可能影响到`ClassC`。如果父类中的方法签名发生了变化，或者某些属性被重命名或删除，`ClassC`都需要做出相应的更新。

3. **冲突解决**：
   如果`ClassA`和`ClassB`中有同名的方法或属性，`ClassC`需要有一种机制来解决这些命名冲突。在C++中，这可以通过指定父类的作用域来解决，但Java避免这种问题的方式是根本不允许多重继承。

```java
class ClassC extends ClassA, ClassB {
    public void methodA1() {
        // 需要解决方法冲突，决定使用 ClassA 的 methodA1
        super(ClassA).methodA1();
    }
    // 假设这样的语法存在，在Java中实际上并不支持
}
```

这种情况下的代码耦合度非常高，因为`ClassC`对两个父类都有依赖，修改任何一个父类都可能需要对`ClassC`进行修改。这样的设计使得系统的可维护性降低，同时也降低了代码的稳定性。

在真实的`Java`编程中，我们通常使用接口来实现类似多重继承的效果，并通过设计模式如组合（`Composition`）和接口分离（Interface Segregation）来降低类的复杂性和耦合度。