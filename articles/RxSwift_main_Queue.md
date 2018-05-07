在开发 iOS 的时候，我们都知道 UI 相关的操作必须放在**主线程**，但是只要放在**主线程**就安全了么？

答案是否定的。在苹果的 MapKit 框架中，一个名为 addOverlay 的方法不仅要放在**主线程**中，而且必须放在**主队列**中。苹果公司的  Developer Technology Support 承认这是一个 bug。

所以在进行 UI 相关的操作时，最安全的方式是在**主线程主队列**中进行。那么应该怎么判断当前是不是主线程主队列呢？

首先我们先分清楚线程和队列的关系。

## 线程和队列
队列不是线程，队列时用来组织任务的，我们将任务添加到队列中，系统会根据资源决定是否创建新的线程去处理队列中的任务。线程的创建、维护和销毁由操作系统来管理。

队列分为两种类型：`串行队列`和`并行队列`。在 iOS 系统中提供了 5 个不同全局队列，分别为：

- 主队列（main queue）
- 4个不同优先级的后台队列，它们的优先级分别为：`High Priority Queue`，`Default Priority Queue`，`Low Priority Queue`，及优先级更低的 `Background Priority Queue`（用于 I/O）。

主队列为`串行队列`，**它内部的任务都会放在主线程中执行**，UI 相关的操作都应该放在该队列中，获取方式：
```
// Object-C
dispatch_get_main_queue()  
```

其他四种不同优先级的全局队列为`并行队列`，获取方式为：
```
// Object-C
dispatch_get_global_queue(long identifier, unsigned long flags);  

```
另外还可以创建`自定义队列`（custom queue）
```
// Object-C
dispatch_queue_t dispatch_queue_create(const char *_Nullable label,
            dispatch_queue_attr_t _Nullable attr);
```

## 判断主队列
每个 APP 只有一个主线程，但是**主线程上可以运行很多不同的队列**，所以如果当前是主线程并不能保证当前为主队列。主队列内部的任务都会放在主线程中执行，所以如果当前队列为主队列，就可以确保任务在主线程主队列中运行。那么我们的问题就归结为怎么判断当前为**主队列**。

### pthread
pthread 是一套通用使用 C 语言编写的多线程的 API，可以在 Unix/Linux/Windows 等系统跨平台使用。常用 API ：

1. 创建一个线程
```
pthread_create( )
```

2. 退出当前线
```
pthread_exit ( )
```

3. 获取主线程 

```
pthread_main_np ( ) :
```
应用 ：
```
if (pthread_main_np()) { 
    // do something in main thread 
} else { 
    // do something in other thread 
}
```
总结：
使用 `pthread` 只能判断当前是不是主线程，而不能判断当前是不是主队列。

### NSThread
NSThread 是一套苹果公司开发的使用 Objective-C 编写的多线程 API，其功能基本类同于 pthread。由于 GCD 本身没有提供判断当前线程是否是主线程的 API，因此我们常常使用 NSThread 中的 API 代替。
常用API :
1. 是否是主线程
```
@property (readonly) BOOL isMainThread
```
2. 取消线程
```
- (void)cancel
```
3. 开始线程
```
- (void)start
```

应用:
```
if ([NSThread isMainThread]) { 
    // do something in main thread 
} else { 
    // do something in other thread 
}
```
总结：
该 API 同样只会检查当前的线程是否是主线程，不能检查是不是主队列。

### 线程关联数据
在 GCD 的 API 中还有通过 `dispatch_queue_set_specific()` 和 `dispatch_get_specific()` 将一个值关联到指定的线程上，下面是常见 API：

1. 获得当前队列，**该方法在 iOS6.0之后已被弃用**。
```
dispatch_get_current_queue()
```

2. 在指定的 queue 上通过 key 管理一个 value。
```
// Object-C
dispatch_queue_set_specific(dispatch_queue_t queue, const void *key,
void *_Nullable context, dispatch_function_t _Nullable destructor);

// Swift
public func setSpecific<T>(key: DispatchSpecificKey<T>, value: T?)
```
参数：

- queue：需要关联的queue，不允许传入NULL。 
- key：唯一的关键字。 
- context：要关联的内容，可以为NULL。
- destructor：释放context的函数，当新的context被设置时，destructor会被调用 

3. 根据指定的 key 取出当前 queue 的关联的 context，如果当前 queue 没有 key 关联的 context，则会从 queue 的 target queue 中获取，如果依然没有，则会返回 NULL。
```
// Object-C
dispatch_get_specific(const void *key)
// Swift
public func getSpecific<T>(key: DispatchSpecificKey<T>) -> T?
```
参数：

- key：唯一的关键字。 

应用：
```
// Object-C
static void *mainQueueKey = "mainQueueKey"; dispatch_queue_set_specific(dispatch_get_main_queue(), mainQueueKey, &mainQueueKey, NULL); 
if (dispatch_get_specific(mainQueueKey)) { 
    // do something in main queue 
} else { 
    // do something in other queue 
}
```

**总结：**

1. 可以实现`主线程`的判断。
1. 在判断是否为主队列之前，必须提前在主队列上设置一个关联的值。
1. 此方法也可以用于判断其他特定的队列。


## RxSwift 的具体实现

下面为 RxSwift 的具体实现代码：
```
extension DispatchQueue {
    // 注意此方法为 static
    private static var token: DispatchSpecificKey<()> = {
        // 初始化一个 key
        let key = DispatchSpecificKey<()>()
        // 在主队列上关联一个空元组
        DispatchQueue.main.setSpecific(key: key, value: ())
        return key
    }()
    
    // 通过队列上是否有绑定 token 对应的值来判断是否为主队列
    static var isMain: Bool {
        return DispatchQueue.getSpecific(key: token) != nil
    }
}
```

## 参考
[iOS判断是否在主线程的正确姿势](https://www.jianshu.com/p/7f68a3d5b07d)
[主线程中也不绝对安全的 UI 操作](http://www.cocoachina.com/ios/20160802/17259.html)