# RxSwift 利用线程特有数据（TSD）解决循环调用的问题

在 `RxSwift` 框架的 `CurrentThreadScheduler.swift` 文件中定义了 `CurrentThreadScheduler` 类，因为需要符合 `ImmediateSchedulerType` 协议，所有实现了下面的方法：
```
public func schedule<StateType>(_ state: StateType, action: @escaping (StateType) -> Disposable) -> Disposable
```
这个方法就是在当前线程中派发一个需要被立即执行的任务，其中

- 参数 state： 任务将被执行的状态
- 参数 action： 被执行的任务
- 返回值：可以取消调度操作的 disposable 类

在需要被执行的 `action` 中，我们依然可以继续调用 `schedule` 方法，继续向当前线程派发一个需要被立即执行的任务。

我们思考一个问题，`action` 在 `schedule` 方法中被执行，如果再在 `action` 中调用 `schedule` 方法，这样会不会造成**循环调用**呢？答案显而易见，这样势必会造成**循环调用**。

为了**避免**循环引用 `RxSwift` 的解决方法是：在 `schedule` 方法中，在执行 `action` 之前，首先判断当前线程中之前是否有调用过 `schedule` 方法，并且还没有执行结束，如果有则先将 `action` 保存到和线程关联的队列中，如果没有则直接执行 `action`，执行结束后查看和线程关联的队列中是否有未执行的 `action`。

那么怎样判读一个线程是否正在执行一个方法呢？这里需要引入**线程特有数据** （`Thread Specific Data` 或 `TSD`）。

在具体分析 RxSwift 的实现之前，可以先了解一下[Swift 中的指针使用](https://onevcat.com/2015/01/swift-pointer/)和[线程特有数据(Thread Specific Data)](https://github.com/FuYouFang/fuyoufangBlog/blob/master/articles/Thread_Specific_Data.md)。

### RxSWift 中的具体实现
#### 获取线程特有数据的 key
在保存线程特有数据（TSD）之前，需要获取线程特有数据的 key。
```
private static var isScheduleRequiredKey: pthread_key_t = { () -> pthread_key_t in
    // 1.分配一个 pthread_key_t 的内存空间，返回指向 pthread_key_t 的指针
    // 这是 key 是一个指向 pthread_key_t 类型的指针
    let key = UnsafeMutablePointer<pthread_key_t>.allocate(capacity: 1)
    defer {
        // 4. 释放保存 pthread_key_t 的空间
        key.deallocate(capacity: 1)
    }

    // 2. 创建线程特有数据的 key 
    guard pthread_key_create(key, nil) == 0 else {
        rxFatalError("isScheduleRequired key creation failed")
    }

    // 3. 返回线程特有数据的 key 
    return key.pointee
}()
```
**注意：**
1. `pthread_key_create` 并不会为线程特有数据的 `key` 申请内存空间，所以我们需要自己申请一个 `pthread_key_t` 的内存空间。
2. 这是一个静态（`static`）的属性，它会保存创建后的线程特有数据的 `key`，所以可以将申请的内存空间进行释放，而不会丢失线程特有数据的 `key`。
> 这里说的线程特有数据的 `key` 和代码中的 `key` 不是一个东西，代码中的 `key` 是一个指针，指针指向的内容为线程特有数据的 `key`。

总结一下获取一个线程特有数据的 `key` 的过程：
1. 分配一个 `pthread_key_t` 的内存空间（线程特有数据的 `key` 的类型）；
2. 调用 `pthread_key_create` 创建线程特有数据的 key，
3. 保存线程特有数据的 key，并释放之前分配的 `pthread_key_t` 的空间释放。

#### 设置线程特有数据
获取到线程特有数据 key 之后，我们就可以设置和读取 key 对应的线程特有数据。
```
/// 返回一个值，用来表示调用者是否必须调用 `schedule` 方法
public static fileprivate(set) var isScheduleRequired: Bool {
    get {
        // 获取线程特有信息
        return pthread_getspecific(CurrentThreadScheduler.isScheduleRequiredKey) == nil
    }
    set(isScheduleRequired) {
        // 设置线程特有信息
        if pthread_setspecific(CurrentThreadScheduler.isScheduleRequiredKey, isScheduleRequired ? nil : scheduleInProgressSentinel) != 0 {
            rxFatalError("pthread_setspecific failed")
        }
    }
}

private static var scheduleInProgressSentinel: UnsafeRawPointer = { () -> UnsafeRawPointer in
    return UnsafeRawPointer(UnsafeMutablePointer<Int>.allocate(capacity: 1))
}()
```
`isScheduleRequired` 就是通过在线程特有数据的 key 设置或清除一个 Int 指针来保存 true 或 false。

#### schedule 方法的实现
下面看 `schedule` 的具体实现：
```
public func schedule<StateType>(_ state: StateType, action: @escaping (StateType) -> Disposable) -> Disposable {
    // 本次调用 schedule 是否需要派发 action
    // 也就是当前线程之前有没有调用过 schedule，并且没有执行完。
    if CurrentThreadScheduler.isScheduleRequired {
        // 修改状态
        CurrentThreadScheduler.isScheduleRequired = false

        // 派发 action
        let disposable = action(state)

        defer {
            CurrentThreadScheduler.isScheduleRequired = true
            CurrentThreadScheduler.queue = nil
        }

        // 查看和当前线程关联的队列 queue 中是否有未派发的 action，如果有则执行
        guard let queue = CurrentThreadScheduler.queue else {
            return disposable
        }

        while let latest = queue.value.dequeue() {
            if latest.isDisposed {
                continue
            }
            latest.invoke()
        }

        return disposable
    }
    
    // 将 action 先保存到和当前线程关联的队列 queue 中
    let existingQueue = CurrentThreadScheduler.queue

    let queue: RxMutableBox<Queue<ScheduledItemType>>
    if let existingQueue = existingQueue {
        queue = existingQueue
    } else {
        queue = RxMutableBox(Queue<ScheduledItemType>(capacity: 1))
        CurrentThreadScheduler.queue = queue
    }

    let scheduledItem = ScheduledItem(action: action, state: state)
    queue.value.enqueue(scheduledItem)

    return scheduledItem
}
```
#### 最终的效果
下面是 `CurrentThreadSchedulerTest` 测试用例当中对 `CurrentThreadScheduler` 的测试，我们看 `schedule` 达到的效果：

```
func testCurrentThreadScheduler_basicScenario() {

    XCTAssertTrue(CurrentThreadScheduler.isScheduleRequired)

    var messages = [Int]()
    _ = CurrentThreadScheduler.instance.schedule(()) { s in
        messages.append(1)
        _ = CurrentThreadScheduler.instance.schedule(()) { s in
            messages.append(3)
            _ = CurrentThreadScheduler.instance.schedule(()) {
                messages.append(5)
                return Disposables.create()
            }
            messages.append(4)
            return Disposables.create()
        }
        messages.append(2)
        return Disposables.create()
    }

    XCTAssertEqual(messages, [1, 2, 3, 4, 5])
}
```
可见在 `schedule` 方法中执行的 `action` 依然可以调用 `schedule` 而不会造成循环调用。





