# ReactorKit 通过扩展给实例添加实例变量

ReactorKit 中定义了 Reactor 协议，同时对 Reactor 协议进行了扩展。一个类型通过继承 Reactor 协议，就获得了下面几个属性：

- action: ActionSubject<Action> 
- currentState: State
- state: Observable<State>
- scheduler: Scheduler
- disposeBag: DisposeBag


如何通过协议进行扩展，来给继承者添加实例变量呢？

```
// MARK: - Map Tables
private typealias AnyReactor = AnyObject

private enum MapTables {
    static let action = WeakMapTable<AnyReactor, AnyObject>()
    static let currentState = WeakMapTable<AnyReactor, Any>()
    static let state = WeakMapTable<AnyReactor, AnyObject>()
    static let disposeBag = WeakMapTable<AnyReactor, DisposeBag>()
    static let isStubEnabled = WeakMapTable<AnyReactor, Bool>()
    static let stub = WeakMapTable<AnyReactor, AnyObject>()
}
```

通过源码查看，可以发现有一个 MapTables 的枚举类型，里面定义了几个静态常量（static let），每个静态常量都对应了一个扩展的属性，比如 action 静态变量就是为了给继承 Reactor 协议的类型添加 action 属性。

## WeakMapTable 的实现

在 MapTables 中的静态常量的类型为 WeakMapTable。其中，定义了一个 dictionary，将类和扩展得来的属性值进行对应，这样就可以记录每个类对应的扩展的属性值。

WeakMapTable 管理的 dictionary 需要满足下面的条件：

- 条件 1：实例和 dictionary 中的 key 需要一一对应，才能保证在 dictionary 中设置、获取时用到的 key 时同一个。
- 条件 2：key 不能对被扩展的实例进行强引用，否则无法释放被扩展的实例。
- 条件 3：被扩展的实例在释放时，需要通知 dictionary，将相应的 key 进行删除。

下面来看一下 WeakMapTable 是怎么管理 dictionary 的。dictionary 的 key 的类型是 Weak。一个 Weak 实例对别扩展的类进行了弱引用，并保存了类实例的唯一标识的哈希值。

```
// MARK: - Weak

private class Weak<T>: Hashable where T: AnyObject {
    private let objectHashValue: Int
    weak var object: T?
    
    init(_ object: T) {
        // 类实例的唯一标志
        self.objectHashValue = ObjectIdentifier(object).hashValue
        self.object = object
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.objectHashValue)
    }
    
    static func == (lhs: Weak<T>, rhs: Weak<T>) -> Bool {
        return lhs.objectHashValue == rhs.objectHashValue
    }
}
```

这样就满足了[条件 1](#key-的定义) 和[条件 2]((#key-的定义))。

在设置 dictionary 中 key 对应的被扩展的属性值时的方法如下：

```
func setValue(_ value: Value?, forKey key: Key) {
    let weakKey = Weak(key)
    
    self.lock.lock()
    defer {
        self.lock.unlock()
        if value != nil {
            self.installDeallocHook(to: key)
        }
    }
    
    if let value = value {
        self.dictionary[weakKey] = value
    } else {
        self.dictionary.removeValue(forKey: weakKey)
    }
}
```

其中调用了 `installDeallocHook` 方法，其中的参数为被扩展的类，`installDeallocHook` 的实现如下：

```
// MARK: Dealloc Hook

private var deallocHookKey: Void?

private func installDeallocHook(to key: Key) {
    let isInstalled = (objc_getAssociatedObject(key, &deallocHookKey) != nil)
    
    guard !isInstalled else { return }
    
    let weakKey = Weak(key)
    let hook = DeallocHook(handler: { [weak self] in
        self?.lock.lock()
        self?.dictionary.removeValue(forKey: weakKey)
        self?.lock.unlock()
    })

    objc_setAssociatedObject(key, &deallocHookKey, hook, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
}
```

installDeallocHook 方法就是将被扩展的实例关联了一个 DeallocHook 实例变量。DeallocHook 初始化的 handler 是将 Dictionary 中被扩展的实例对应的 key 进行了删除。 

DeallocHook 的定义如下：

```
// MARK: - DeallocHook

private class DeallocHook {
    private let handler: () -> Void
    
    init(handler: @escaping () -> Void) {
        self.handler = handler
    }
    
    deinit {
        self.handler()
    }
}
```
DeallocHook 实例作为被扩展的实例的属性。被扩展的实例在销毁时，DeallocHook 自然也会销毁，这时就会调用 handler。这样就保证的[条件 3](#key-的定义)。

### 总结

WeakMapTable 通过下面的方式来对实例扩展实例变量属性：

1. 定义一个 Dictionary 来保存给实例扩展的属性值。
2. Dictionary 的 key 由实例的唯一标识生成，value 为扩展的属性值。
3. 给被扩展的实例关联一个 DeallocHook 类，当 DeallocHook 类释放时，移除 Dictionary 中对应的 key，从而达到对扩展得来的属性值的释放。


