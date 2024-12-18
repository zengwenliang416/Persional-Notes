# Java 多线程编程指南

## 目录
- [1. 目录](#目录)
- [2. 一、基础概念](#一基础概念)
    - [进程与线程](#进程与线程)
    - [线程的生命周期](#线程的生命周期)
- [3. 二、线程的创建与使用](#二线程的创建与使用)
    - [创建线程的方式](#创建线程的方式)
    - [线程的基本操作](#线程的基本操作)
- [4. 三、线程同步](#三线程同步)
    - [synchronized 关键字](#synchronized-关键字)
    - [Lock 接口](#lock-接口)
- [5. 四、线程通信](#四线程通信)
    - [wait/notify 机制](#waitnotify-机制)
    - [Condition 接口](#condition-接口)
- [6. 五、线程池](#五线程池)
    - [常用线程池](#常用线程池)
    - [自定义线程池](#自定义线程池)
- [7. 六、并发工具类](#六并发工具类)
    - [CountDownLatch](#countdownlatch)
    - [CyclicBarrier](#cyclicbarrier)
    - [Semaphore](#semaphore)
- [8. 七、线程安全集合](#七线程安全集合)
    - [并发容器](#并发容器)
    - [线程安全的基本类型包装](#线程安全的基本类型包装)
- [9. 八、最佳实践](#八最佳实践)
    - [线程安全编程原则](#线程安全编程原则)
    - [性能优化](#性能优化)
    - [调试与监控](#调试与监控)



## 一、基础概念

### 进程与线程
- **进程**：程序的一次执行，是系统进行资源分配和调度的独立单位
- **线程**：进程的执行单元，是 CPU 调度的基本单位
- **区别**：
  - 进程是资源分配的最小单位，线程是 CPU 调度的最小单位
  - 一个进程可以包含多个线程，线程共享进程的资源
  - 线程创建和销毁的开销比进程小

### 线程的生命周期
1. **新建（New）**：创建线程对象
2. **就绪（Runnable）**：等待 CPU 调度
3. **运行（Running）**：获得 CPU 时间片正在执行
4. **阻塞（Blocked）**：等待 I/O 或同步锁
5. **等待（Waiting）**：等待其他线程的通知
6. **超时等待（Timed Waiting）**：超时等待状态
7. **终止（Terminated）**：线程执行完毕

## 二、线程的创建与使用

### 创建线程的方式

1. **继承 Thread 类**：
```java
public class MyThread extends Thread {
    @Override
    public void run() {
        // 线程执行代码
    }
}
// 使用
MyThread thread = new MyThread();
thread.start();
```

2. **实现 Runnable 接口**：
```java
public class MyRunnable implements Runnable {
    @Override
    public void run() {
        // 线程执行代码
    }
}
// 使用
Thread thread = new Thread(new MyRunnable());
thread.start();
```

3. **实现 Callable 接口**：
```java
public class MyCallable implements Callable<String> {
    @Override
    public String call() throws Exception {
        return "线程执行结果";
    }
}
// 使用
FutureTask<String> future = new FutureTask<>(new MyCallable());
Thread thread = new Thread(future);
thread.start();
String result = future.get(); // 获取返回值
```

4. **使用线程池**：
```java
ExecutorService executor = Executors.newFixedThreadPool(5);
executor.submit(() -> {
    // 线程执行代码
});
```

### 线程的基本操作

1. **启动线程**：
```java
thread.start(); // 启动线程
```

2. **线程休眠**：
```java
Thread.sleep(1000); // 休眠1秒
```

3. **线程中断**：
```java
thread.interrupt(); // 中断线程
```

4. **等待线程结束**：
```java
thread.join(); // 等待线程执行完毕
```

5. **线程优先级**：
```java
thread.setPriority(Thread.MAX_PRIORITY); // 设置优先级
```

## 三、线程同步

### synchronized 关键字

1. **同步方法**：
```java
public synchronized void method() {
    // 同步代码
}
```

2. **同步代码块**：
```java
synchronized (object) {
    // 同步代码
}
```

### Lock 接口

1. **ReentrantLock**：
```java
private Lock lock = new ReentrantLock();

public void method() {
    lock.lock();
    try {
        // 临界区代码
    } finally {
        lock.unlock();
    }
}
```

2. **ReadWriteLock**：
```java
private ReadWriteLock rwLock = new ReentrantReadWriteLock();

public void read() {
    rwLock.readLock().lock();
    try {
        // 读取操作
    } finally {
        rwLock.readLock().unlock();
    }
}

public void write() {
    rwLock.writeLock().lock();
    try {
        // 写入操作
    } finally {
        rwLock.writeLock().unlock();
    }
}
```

## 四、线程通信

### wait/notify 机制

```java
public synchronized void produce() {
    while (isFull()) {
        wait();
    }
    // 生产操作
    notify();
}

public synchronized void consume() {
    while (isEmpty()) {
        wait();
    }
    // 消费操作
    notify();
}
```

### Condition 接口

```java
private Lock lock = new ReentrantLock();
private Condition condition = lock.newCondition();

public void method() {
    lock.lock();
    try {
        while (needWait()) {
            condition.await();
        }
        // 执行操作
        condition.signal();
    } finally {
        lock.unlock();
    }
}
```

## 五、线程池

### 常用线程池

1. **固定大小线程池**：
```java
ExecutorService fixedPool = Executors.newFixedThreadPool(5);
```

2. **缓存线程池**：
```java
ExecutorService cachedPool = Executors.newCachedThreadPool();
```

3. **单线程池**：
```java
ExecutorService singlePool = Executors.newSingleThreadExecutor();
```

4. **调度线程池**：
```java
ScheduledExecutorService scheduledPool = Executors.newScheduledThreadPool(5);
```

### 自定义线程池

```java
ThreadPoolExecutor executor = new ThreadPoolExecutor(
    5,                      // 核心线程数
    10,                     // 最大线程数
    60L,                    // 空闲线程存活时间
    TimeUnit.SECONDS,       // 时间单位
    new LinkedBlockingQueue<>(100), // 工作队列
    Executors.defaultThreadFactory(), // 线程工厂
    new ThreadPoolExecutor.AbortPolicy() // 拒绝策略
);
```

## 六、并发工具类

### CountDownLatch

```java
CountDownLatch latch = new CountDownLatch(3);

// 在线程中
latch.countDown(); // 计数减一

// 在主线程中
latch.await(); // 等待计数为0
```

### CyclicBarrier

```java
CyclicBarrier barrier = new CyclicBarrier(3, () -> {
    // 所有线程到达屏障时执行
});

// 在线程中
barrier.await(); // 等待其他线程
```

### Semaphore

```java
Semaphore semaphore = new Semaphore(5);

// 获取许可
semaphore.acquire();
try {
    // 执行需要控制并发的代码
} finally {
    // 释放许可
    semaphore.release();
}
```

## 七、线程安全集合

### 并发容器

1. **ConcurrentHashMap**：
```java
Map<String, String> map = new ConcurrentHashMap<>();
```

2. **CopyOnWriteArrayList**：
```java
List<String> list = new CopyOnWriteArrayList<>();
```

3. **BlockingQueue**：
```java
BlockingQueue<String> queue = new ArrayBlockingQueue<>(100);
queue.put("element"); // 阻塞式插入
String element = queue.take(); // 阻塞式获取
```

### 线程安全的基本类型包装

1. **AtomicInteger**：
```java
AtomicInteger counter = new AtomicInteger(0);
counter.incrementAndGet(); // 原子递增
```

2. **AtomicReference**：
```java
AtomicReference<User> userRef = new AtomicReference<>();
userRef.compareAndSet(oldUser, newUser); // CAS 操作
```

## 八、最佳实践

### 线程安全编程原则

1. 优先使用不可变对象
2. 使用线程安全的集合类
3. 正确使用同步机制
4. 避免过度同步
5. 合理使用线程池

### 性能优化

1. **减少锁的粒度**：
```java
// 不好的做法
public synchronized void method() {
    // 大量非同步操作
    // 少量需要同步的操作
}

// 好的做法
public void method() {
    // 大量非同步操作
    synchronized(lock) {
        // 少量需要同步的操作
    }
}
```

2. **使用合适的并发工具**：
- 优先使用并发集合而不是同步集合
- 使用 CountDownLatch 而不是 wait/notify
- 使用 ConcurrentHashMap 而不是 Hashtable

3. **避免死锁**：
- 固定加锁顺序
- 使用超时锁
- 使用 tryLock() 方法

### 调试与监控

1. **线程转储**：
```java
Thread.getAllStackTraces().forEach((t, stack) -> {
    System.out.println("Thread: " + t.getName());
    for (StackTraceElement element : stack) {
        System.out.println("\t" + element);
    }
});
```

2. **JMX 监控**：
- 使用 JConsole 或 VisualVM 监控线程状态
- 监控线程池的运行状况

3. **日志记录**：
```java
logger.debug("Thread {} is processing task {}", 
    Thread.currentThread().getName(), taskId);
```
