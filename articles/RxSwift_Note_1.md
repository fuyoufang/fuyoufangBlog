# RxSwift 杂记（1）

## 协议 protocol 背后的 class 
在 RxSwift 中有时会在协议 protocol 后面加上 class 关键字，比如下面的协议：
```
protocol SynchronizedDisposeType : class, Disposable, Lock {
    func _synchronized_dispose()
}

extension SynchronizedDisposeType {
    func synchronizedDispose() {
        lock(); defer { unlock() }
        _synchronized_dispose()
    }
}
```
通过在 protocol 后面加上 class 可以限定该协议只能由类来继承。因为在 swift 中 protocol 可以被除了类以外的其他类型所遵守，比如 struct、enum 这样的类型。
那什么时候需要需要在 protocol 后面加上 class 呢？
当一个类的代理需要遵循某个协议，为了避免循环引用，通常会将类的代理声明为 weak，例如下面的代码：
```
protocol OneClassDelegate {
    func method()
}

class OneClass {
    weak var delegate: OneClassDelegate?
}
```
但是这样的代码是编译不通过的，因为 struct、enum 这样的类型可以遵循协议，但是不可以用 weak 这种 ARC 的内存管理方式修饰。这是就可以在 protocol 后面用 class 修饰。更详细的可以查看王巍的文章 [DELEGATE](http://swifter.tips/delegate/)。

## 协议和扩展协议
为了说明方便，下面一段代码对 RxSwift 的源码进行了变形：
```
protocol SynchronizedDisposeType : class {
    func lock()
    func unlock()
    func _synchronized_dispose()
}

extension SynchronizedDisposeType {
    func synchronizedDispose() {
        lock(); defer { unlock() }
        _synchronized_dispose()
    }
}
```
在 `SynchronizedDisposeType` 协议中，需要通过锁实现一个同步的方法，它不是简单的在 protocol 中定义一个方法，而是在协议中定义了一个在每个单词前面加下划线的方法 `_synchronized_dispose`，并且扩展了一个方法 `synchronizedDispose`，在内部将锁和真正的方法组合了起来。在协议的实现上可以将加锁的过程和真正要实现的方法进行了分离，保证了代码的正确实现；如果有多个类要实现该协议时，减少了在方法前后加锁的重复代码。


## 内联函数
通过 @inline 这个关键字可以声明内联函数，下面是 RxSwift 中一段代码：
```
extension RecursiveLock : Lock {
    @inline(__always)
    final func performLocked(_ action: () -> Void) {
        lock(); defer { unlock() }
        action()
    }
}
```
@inline 的关键字有以下两种用法：
```
// 声明不要将函数编译成内联方式
@inline(never)

// 声明要将函数编译成内联方式
@inline(__always) 
```

## 方法被串行执行的反馈
在多线程的开发中，经常会遇到默写方法必须保证串行执行，可以通过【方法或方法】来达到目的，但是在真正的实现过程中是否真的达到了目的呢？我们需要一种反馈机制，可以确保代码的运行方式和我们的预想一样。

怎样确保一个指定的方法在同一个时间只被调用一次呢？也就是说我们需要确保：

1. 指定的方法在同一个时间内只有一个线程调用，
1. 指定的方法在同一个时间同一个线程上只被调用一次。

在 RxSwift 中实现的思路是这样的，一个类中如果有方法需要被串行执行，则在一个递归锁内用一个 Dictionary 来记录方法当前被哪个线程执行了多少次，Dictionary 中线程为 key，执行次数为 value。如果被一个以上的线程执行，或者在一个线程中被执行的次数多于一次，则抛出异常。

在代码具体实现中，将上述的记录和判断过程封装到     `SynchronizationTracker` 类中，具体代码如下：

```
final class SynchronizationTracker {
    // 递归锁
    private let _lock = RecursiveLock()

    // 同步出错时的错误类型
    public enum SychronizationErrorMessages: String {
        case variable = "..." // 具体信息被删减
        case `default` = "..." // 具体信息被删减
    }
    
    // 用于保存执行情况的 Dictionary
    private var _threads = Dictionary<UnsafeMutableRawPointer, Int>()

    // 同步错误之后的处理
    private func synchronizationError(_ message: String) {
        #if FATAL_SYNCHRONIZATION
            rxFatalError(message)
        #else
            print(message)
        #endif
    }

    // 在同步方法内首先调用该方法用于记录和判断
    func register(synchronizationErrorMessage: SychronizationErrorMessages) {

        _lock.lock(); defer { _lock.unlock() }

        // 获取当前线程的指针
        let pointer = Unmanaged.passUnretained(Thread.current).toOpaque()
        // 当前线程中调用（注册）的次数
        let count = (_threads[pointer] ?? 0) + 1
        
        // 检测是否同时被多个线程执行
        if count > 1 {
            synchronizationError("error")
        }
        
        _threads[pointer] = count

        if _threads.count > 1 {
            synchronizationError("error")
        }
    }

    // 在同步方法内结束执行前清除记录（清除注册信息）
    func unregister() {
        _lock.lock(); defer { _lock.unlock() }
        let pointer = Unmanaged.passUnretained(Thread.current).toOpaque()
        _threads[pointer] = (_threads[pointer] ?? 1) - 1
        if _threads[pointer] == 0 {
            _threads[pointer] = nil
        }
    }
}
```


## 多线程下的 BOOL
我们经常用 BOOL 来表示 true 和 false，在多线程环境下又需要考虑并发的问题，所以在设置和读取 BOOL 值的时候就需要考虑用锁了，但是同时又带来了性能的损失。有没有代替方案呢？ RxSwift 使用了一个 Int32 值，并以原子操作的方式对 Int32 值进行修改，确保了线程安全，又不损失性能。

原子操作 Int32 类型的主要方法有：
1. 对比并交换 Int32 值。如果 __theValue 指向的内存值和 __oldValue 相等，则修改为 __newValue 值。
```
public func OSAtomicCompareAndSwap32Barrier(_ __oldValue: Int32, _ __newValue: Int32, _ __theValue: UnsafeMutablePointer<Int32>!) -> Bool
```

1. 将 __theValue 指向的内存值进行加1操作
```
public func OSAtomicIncrement32Barrier(_ __theValue: UnsafeMutablePointer<Int32>!) -> Int32
```

1. 将 __theValue 指向的内存值进行减1操作
```
public func OSAtomicDecrement32Barrier(_ __theValue: UnsafeMutablePointer<Int32>!) -> Int32
```

1. 或操作
```
public func OSAtomicOr32OrigBarrier(_ __theMask: UInt32, _ __theValue: UnsafeMutablePointer<UInt32>!) -> Int32
```

1. 异或操作
```
public func OSAtomicXor32OrigBarrier(_ __theMask: UInt32, _ __theValue: UnsafeMutablePointer<UInt32>!) -> Int32
```

下面 RefCountInnerDisposable 类通过 OSAtomicCompareAndSwap32Barrier 将 _isDisposed 和0做比较来判断 dispose 方法是否调用过。
```
internal final class RefCountInnerDisposable: DisposeBase, Disposable
{
    private let _parent: RefCountDisposable
    // AtomicInt 为 Int32 的别名
    private var _isDisposed: AtomicInt = 0

    init(_ parent: RefCountDisposable)
    {
        _parent = parent
        super.init()
    }

    internal func dispose()
    {
        // 和 0 做对比，来判断是否调用过
        if AtomicCompareAndSwap(0, 1, &_isDisposed) {
            _parent.release()
        }
    }
}

```
