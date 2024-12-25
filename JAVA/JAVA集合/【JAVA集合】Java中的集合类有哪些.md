# 【JAVA集合】Java中的集合类有哪些

## 目录

[1. 目录](#目录)

[2. 继承关系](#继承关系)

[3. 功能](#功能)

[4. 实现](#实现)



## 继承关系

在 Java 集合框架中，`List`、`Set` 和 `Queue` 都是 `Collection` 接口的扩展，而 `Collection` 接口本身扩展了 `Iterable` 接口。下面是这种继承关系的简要说明：

- **Iterable 接口**：是所有集合框架类的最顶层接口。它允许对象成为 "foreach" 语句的目标，定义了一个返回 `Iterator` 的 `iterator()` 方法，因此所有实现 `Iterable` 的集合类都可以使用迭代器遍历。

- **Collection 接口**：提供了集合的基本功能，如添加元素、删除元素、清空集合、判断集合是否包含某个元素等。它是所有单列集合的根接口，意味着只包含一个元素序列。
  - **List 接口**：它是一个有序集合，可以包含重复元素。它提供了一种维护元素插入顺序的方式，允许基于整数索引访问元素。
  - **Set 接口**：不允许有重复元素的集合。它不保证集合的迭代顺序；特别是，它不保证该顺序恒久不变。
  - **Queue 接口**：提供了在队列两端进行插入、移除和检查操作的集合。队列通常（但不一定）以先进先出（FIFO）的方式排序元素。

由于这种继承关系，所有实现了 `List`、`Set`、`Queue` 接口的类也都继承了 `Collection` 和 `Iterable` 接口的方法，使得它们都是可遍历的，并且可以使用增强的 for 循环（foreach循环）进行遍历。例如：

```java
List<String> list = new ArrayList<>();
list.add("element1");
list.add("element2");
for (String element : list) {
    System.out.println(element);
}

Set<String> set = new HashSet<>();
set.add("element1");
set.add("element2");
for (String element : set) {
    System.out.println(element);
}

Queue<String> queue = new LinkedList<>();
queue.add("element1");
queue.add("element2");
for (String element : queue) {
    System.out.println(element);
}
```

## 功能

1. **List** - List 接口实现的容器确实允许你按照插入顺序访问元素，即可以实现先进先出（FIFO），也可以实现后进先出（LIFO）。然而，它主要是被设计为一个有序集合，其中的元素可以通过索引来精确控制。你可以使用 `ArrayList` 作为动态数组，但如果你想实现栈（后进先出），你可能会选择 `LinkedList` 或 `ArrayDeque`（更推荐使用后者作为栈，因为它更高效）。

2. **Set** - Set 是一个不允许重复元素的集合，因此它确实通过 `equals()` 和 `hashCode()` 方法来检测重复值（对于 `TreeSet`，则是通过 `compareTo()` 或 `Comparator` 来检测）。`Set` 并不保证元素的顺序，`HashSet` 的迭代顺序是不可预测的，而 `LinkedHashSet` 维护了元素的插入顺序，`TreeSet` 则按照元素的自然排序或提供的 `Comparator` 排序。

3. **Map** - Map 是一个键值对的集合，它通过键来唯一地标识值。确实会涉及到键的查询等能力，通常也是通过 `equals()` 和 `hashCode()` 方法来确保键的唯一性（对于 `TreeMap`，则是通过 `compareTo()` 或 `Comparator`）。这意味着 Map 中的每个键最多只能映射到一个值。

要注意的是，虽然 `List` 和 `Set` 都是 `Collection` 的子接口，但 `Map` 并不继承 `Collection` 接口。这表明，虽然 `List` 和 `Set` 共享一系列集合操作，但 `Map` 有其独特的方法集合，与 `Collection` 接口的方法不同。

另外，`Map` 接口的实现有时会提供一组键（`keySet()` 方法），一组值（`values()` 方法），或键-值对的集合视图（`entrySet()` 方法），这些视图都是 `Set`，因为它们都维护了唯一性。

## 实现

您的描述是正确的，从实现角度，Java 集合的不同实现具有不同的性能特点和使用场景：

1. **List 实现**:
   - **ArrayList**：基于**动态数组**实现，提供快速的随机访问和高效的索引操作，但增加和删除元素时可能需要数组复制和移动，尤其是在列表中间的操作。
   - **LinkedList**：基于**双向链表**实现，每个元素都包含了指向前一个和后一个元素的引用，这使得元素的插入和删除操作（尤其是列表的头部和尾部）变得更加快速，但随机访问速度较慢。

2. **Queue 实现**:
   - **PriorityQueue**：基于**优先级堆**实现，元素按照其自然顺序或者构造时提供的 `Comparator` 排序，保证了队列头部始终是最小元素（或根据比较器定义的最高优先级元素）。
   - **ArrayDeque**：基于**数组实现的双端队列**，可以在两端插入或移除元素，常用作栈（LIFO）或队列（FIFO）。

3. **Map 实现**:
   - **HashMap**：基于**哈希表**实现，它存储键值对，通过哈希函数来计算键的存储索引。它允许常数时间的插入和检索操作，假设哈希函数将元素正确分布在桶中。
   - **TreeMap**：基于**红黑树**实现，它根据键的自然顺序或者构造时提供的 `Comparator` 保存键值对。TreeMap 支持顺序访问和相关的排序操作。

每种实现的选择都取决于应用程序的需求。如果需要快速索引访问，那么 `ArrayList` 是一个好选择，如果需要快速插入和删除，`LinkedList` 更加适用。如果需要保持元素的某种顺序，则应该使用 `PriorityQueue` 或 `TreeMap`。对于需要快速查找键对应的值的场景，`HashMap` 往往是更好的选择。但是，如果键值对需要排序，使用 `TreeMap` 是更好的选择。选择正确的集合类型和实现可以显著提高应用程序的性能。