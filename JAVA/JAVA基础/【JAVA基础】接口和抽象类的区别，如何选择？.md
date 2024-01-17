# 【JAVA基础】接口和抽象类的区别，如何选择？

接口和抽象类是对类的一种抽象定义。接口可以声明方法，而抽象类可以声明并（部分或全部）实现方法。以下是更详细的分析：

### 接口（Interface）

1. **方法定义**：在Java 8之前，接口只能声明方法，不能包含方法实现（即，只有方法签名，没有方法体）。
2. **默认方法**：从Java 8开始，接口可以包含默认方法，这些方法有方法体，可以被实现接口的类直接使用或覆盖。
3. **静态方法**：Java 8还允许接口包含静态方法，这些方法有方法体，不必通过实例来调用。
4. **属性**：接口中可以声明常量（默认为 `public static final`），但不能有实例变量。
5. **实现**：一个类可以实现多个接口。

### 抽象类（Abstract Class）

1. **方法实现**：抽象类可以包含抽象方法（没有方法体的方法）和非抽象方法（有方法体的方法）。
2. **构造函数**：抽象类可以有构造函数，尽管不能直接实例化。
3. **属性**：抽象类可以有实例变量和静态变量。
4. **继承**：一个类只能继承一个抽象类。

### 举例说明

下面通过代码示例来进一步说明接口和抽象类的区别和用法：

```java
// 一个简单的接口，Java 8之前的样式
interface Movable {
    void move(); // 抽象方法，没有方法体
}

// Java 8之后，接口添加默认方法
interface Stoppable {
    default void stop() {
        System.out.println("Stopped");
    }
}

// 抽象类
abstract class Vehicle {
    private int speed;

    // 抽象方法，没有实现
    abstract void accelerate();

    // 非抽象方法，有实现
    void setSpeed(int speed) {
        this.speed = speed;
    }

    // 抽象类可以有构造函数
    public Vehicle() {
        this.speed = 0;
    }
}

// ConcreteClass 继承抽象类，并实现接口
class Car extends Vehicle implements Movable, Stoppable {

    // 实现抽象类的抽象方法
    void accelerate() {
        System.out.println("Car accelerates");
    }

    // 实现接口的抽象方法
    public void move() {
        System.out.println("Car moves");
    }
    
    // 接口的stop()方法已经有默认实现，可以选择不覆盖

}

public class Main {
    public static void main(String[] args) {
        Car car = new Car();
        car.move(); // 输出: Car moves
        car.accelerate(); // 输出: Car accelerates
        car.stop(); // 输出: Stopped
    }
}
```

在这个例子中，`Vehicle`是一个抽象类，它声明了一个抽象方法`accelerate`和一个具体方法`setSpeed`。`Movable`是一个接口，定义了一个方法`move`。而`Stoppable`是Java 8后新增的带有默认方法的接口。`Car`类继承了`Vehicle`抽象类并实现了`Movable`和`Stoppable`接口，它提供了自己的`accelerate`和`move`方法实现，并继承了`Stoppable`的默认`stop`方法实现。

## 总结

接口和抽象类的区别具体可以从JAVA语言的三大特性去考虑：

### 封装

封装特性包含的东西有：方法、属性、构造器（我认为是一种特殊的方法）。

那区别就显而易见了：

接口的方法在JDK8之前都只有方法签名，但是JDK8以及之后的版本都支持了默认方法；在抽象类中抽象方法和具体方法可以并存。
接口在JDK8之前是没有属性的，但是在JDK8之后可以有静态属性；抽象类中可以有常量和变量。
接口是没有构造器的；接口中是有构造器的，但是接口不能被实例化，这里的构造器是为了初始化共享成员变量以及强制初始化操作

### 继承

继承就简单多了：接口多实现（另一种形式的多继承），抽象类单继承。

### 多态

多态特性我认为是针对功能而言的，毕竟多态本身就是为了扩展或者重写父类的方法。
接口的多态是为了制定某种规范，告诉实现类你只能这么去写；但是抽象类的多态则是为了复用代码。

总结来说，一般在实际开发中，我们会先把接口暴露给外部，然后在业务代码中实现接口。如果多个实现类中有相同可复用的代码，则在接口和实现类中间加一层抽象类，将公用部分代码抽出到抽象类中。可以参考下模板方法模式，这是一个很好的理解接口、抽象类和实现类之间关系的设计模式。
