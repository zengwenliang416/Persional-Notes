---

# 【Ruoyi-Vue-Plus】StreamUtils 使用文档

## 目录

[1. 目录](#目录)

[2. 介绍](#介绍)

[3. 功能概述](#功能概述)

[4. API 使用详解](#api-使用详解)

- [4.1 过滤元素](#过滤元素)

- - [- 应用场景](#应用场景)

- [4.3 查找元素](#查找元素)

- - [- 应用场景](#应用场景-1)

- - [- 应用场景](#应用场景-2)

- [4.6 集合拼接](#集合拼接)

- - [- 应用场景](#应用场景-3)

- - [- 应用场景](#应用场景-4)

- [4.9 排序](#排序)

- - [- 应用场景](#应用场景-5)

- [4.11 集合转换为 Map](#集合转换为-map)

- - [- 应用场景](#应用场景-6)

- - [- 应用场景](#应用场景-7)

- [4.14 集合分组](#集合分组)

- - [- 应用场景](#应用场景-8)

- [4.16 合并两个 Map](#合并两个-map)

- - [- 应用场景](#应用场景-9)

[5. 总结](#总结)



## 介绍

在日常开发中，经常需要对集合进行过滤、排序、分组、映射转换等操作。`StreamUtils` 是一个基于 Java 8 Stream API 的工具类，封装了大量通用功能，同时以较高的可读性和灵活性提升开发效率。

在【Ruoyi-Vue-Plus】框架中，通过 `StreamUtils` 工具，开发者可以高效完成对集合的各种操作，例如过滤、排序、多层分组、数据映射等，避免繁琐的代码重复，提高代码的可维护性。

---

## 功能概述

`StreamUtils` 提供了以下关键功能：

1. **集合过滤**：基于条件筛选集合中的元素。
2. **元素查找**：快速找到集合中第一个或任意一个满足条件的元素。
3. **集合拼接**：将集合转换成字符串，支持自定义分隔符。
4. **集合排序**：对集合元素进行排序，支持自定义比较规则。
5. **集合到 Map 的映射转换**：支持 Key 和 Value 的灵活映射。
6. **集合分组**：对集合进行单层或双层分组，生成嵌套的 Map 结构。
7. **集合类型转换**：支持将集合类型转换为 `List` 或 `Set`。
8. **Map 合并**：将两个 Map 合并为一个，支持自定义合并逻辑。

---

## API 使用详解

### 过滤元素

- **方法**：`filter(Collection<E> collection, Predicate<E> function)`
- **功能**：根据条件过滤集合中的元素。
- **参数**：
  - `collection`：需要过滤的集合。
  - `function`：过滤条件的 `Predicate`。
- **返回值**：过滤后的 `List`。

#### 应用场景

1. **筛选符合条件的订单**  
   在电商系统中，过滤出所有待付款的订单：
   ```java
   List<Order> orders = getAllOrders();
   List<Order> pendingOrders = StreamUtils.filter(orders, order -> "PENDING".equals(order.getStatus()));
   Console.log("Pending Orders: {}", pendingOrders);
   ```

2. **筛选用户年龄在18-30岁的活跃用户**  
   在社交网站中，筛选符合年龄段且活跃的用户：
   ```java
   List<User> users = getAllUsers();
   List<User> activeYoungUsers = StreamUtils.filter(users, user -> user.getAge() >= 18 && user.getAge() <= 30 && user.isActive());
   Console.log("Active Young Users: {}", activeYoungUsers);
   ```

---

### 查找元素

1. **找到第一个匹配的元素**
   - **方法**：`findFirst(Collection<E> collection, Predicate<E> function)`
   - **功能**：返回集合中第一个满足条件的元素。
   - **参数**：
     - `collection`：需要查找的集合。
     - `function`：查找条件的 `Predicate`。
   - **返回值**：满足条件的第一个元素（如果不存在则为 `null`）。

   #### 应用场景
   
   1. **查找第一个VIP用户**  
      在会员系统中，找到用户列表中第一个 VIP 用户：
      ```java
      User vipUser = StreamUtils.findFirst(users, User::isVip);
      Console.log("First VIP User: {}", vipUser);
      ```
   
2. **找到任意一个匹配的元素**
   - **方法**：`findAny(Collection<E> collection, Predicate<E> function)`
   - **功能**：返回集合中任意一个满足条件的元素。
   - **参数**：
     - `collection`：需要查找的集合。
     - `function`：查找条件的 `Predicate`。
   - **返回值**：`Optional` 包装类型，可为空。

   #### 应用场景
   1. **查找任意待处理的工单**  
      随机选择一个待处理工单分配给当前客服：
      ```java
      Optional<Ticket> pendingTicket = StreamUtils.findAny(tickets, ticket -> "PENDING".equals(ticket.getStatus()));
      pendingTicket.ifPresent(ticket -> Console.log("Assigned Ticket: {}", ticket));
      ```

---

### 集合拼接

1. **默认分隔符拼接**
   - **方法**：`join(Collection<E> collection, Function<E, String> function)`
   - **功能**：将集合元素转换为字符串并拼接，默认分隔符为逗号（`,`）。

   #### 应用场景
   1. **拼接用户名称列表用于展示**
      在管理后台，将用户名称拼接成一个字符串：
      ```java
      String userNames = StreamUtils.join(users, User::getName);
      Console.log("User Names: {}", userNames);
      ```

2. **自定义分隔符拼接**
   - **方法**：`join(Collection<E> collection, Function<E, String> function, CharSequence delimiter)`

   #### 应用场景
   1. **拼接商品 SKU 编号用于批量查询**
      ```java
      String skuList = StreamUtils.join(products, Product::getSku, ",");
      Console.log("SKU List: {}", skuList);
      ```

---

### 排序

- **方法**：`sorted(Collection<E> collection, Comparator<E> comparing)`
- **功能**：根据指定规则对集合元素排序。
- **参数**：
  - `collection`：需要排序的集合。
  - `comparing`：排序的 `Comparator`。
- **返回值**：排序后的 `List`。

#### 应用场景

1. **对商品按价格排序**  
   在商城中，按照价格低到高排序展示商品：
   ```java
   List<Product> sortedByPrice = StreamUtils.sorted(products, Comparator.comparingDouble(Product::getPrice));
   Console.log("Sorted Products by Price: {}", sortedByPrice);
   ```

2. **对用户按注册时间排序**
   ```java
   List<User> sortedByRegisterTime = StreamUtils.sorted(users, Comparator.comparing(User::getRegisterTime).reversed());
   Console.log("Sorted Users by Register Time: {}", sortedByRegisterTime);
   ```

---

### 集合转换为 Map

1. **简单映射（Key 为指定字段，Value 为原对象）**
   - **方法**：`toIdentityMap(Collection<V> collection, Function<V, K> key)`

   #### 应用场景
   1. **将用户 ID 映射为用户对象**
      ```java
      Map<Long, User> userMap = StreamUtils.toIdentityMap(users, User::getId);
      Console.log("User Map: {}", userMap);
      ```

2. **复杂映射（Key 和 Value 均自定义规则）**
   - **方法**：`toMap(Collection<E> collection, Function<E, K> key, Function<E, V> value)`

   #### 应用场景
   1. **获取商品 SKU 和库存的映射**
      ```java
      Map<String, Integer> skuStockMap = StreamUtils.toMap(products, Product::getSku, Product::getStock);
      Console.log("SKU to Stock Map: {}", skuStockMap);
      ```

---

### 集合分组

#### 应用场景

1. **按部门分组员工**
   在公司人事管理中，按部门分组：
   ```java
   Map<String, List<Employee>> employeesByDepartment = StreamUtils.groupByKey(employees, Employee::getDepartment);
   Console.log("Employees Grouped by Department: {}", employeesByDepartment);
   ```

---

### 合并两个 Map

#### 应用场景

1. **合并两个数据来源的用户信息**
   ```java
   Map<Long, UserBase> userBaseMap = getUserBaseMap();
   Map<Long, UserExtra> userExtraMap = getUserExtraMap();
   
   Map<Long, CompleteUser> completeUserMap = StreamUtils.merge(
       userBaseMap,
       userExtraMap,
       (base, extra) -> {
           CompleteUser completeUser = new CompleteUser();
           if (base != null) {
               BeanUtil.copyProperties(base, completeUser);
           }
           if (extra != null) {
               BeanUtil.copyProperties(extra, completeUser);
           }
           return completeUser;
       }
   );
   Console.log("Complete User Map: {}", completeUserMap);
   ```

---

## 总结

在实际业务中，`StreamUtils` 提供了丰富的工具方法来处理集合数据，帮助开发者高效实现数据操作与转换，可以极大提升代码的可读性和复用性。