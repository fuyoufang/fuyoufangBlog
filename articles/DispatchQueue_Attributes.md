# DispatchQueue 的属性

在创建队列时可以对队列的属性进行设置，那具体都能设置哪些参数呢？下面看 DispatchQueue 的初始化方法：

```
public convenience init(label: String, qos: DispatchQoS = default, attributes: DispatchQueue.Attributes = default, autoreleaseFrequency: DispatchQueue.AutoreleaseFrequency = default, target: DispatchQueue? = default)
```
> 在初始化方法中，有些参数具有默认值 [default](http://swifter.tips/default-param/)。在 swift 中含有默认参数的方法在生成的调用接口时，会将有默认值的参数设为 default，因为当我们制定一个在编译时就能确定的常量来作为默认参数的取值时，这个取值时隐藏在方法内部，而不应该暴露给其他部分，所以用 default 来表示有默认值。

## 参数

### label
队列的名称，方便调试。一般用 `Bundle Identifier` 类似的命名方式，将域名翻转，例如：`com.xxx.xxx.queue`。

### qos
Quality of Service(服务质量)。队列中在执行时是有优先级的，优先级越高的队列将获得更多的计算资源。优先级从高到底分为下面五种：

- userInteractive
- userInitiated
- default
- utility
- background

qos 的默认值为 `default`。

### attributes

attributes 的类型为[选项集合（option sets）](http://swift.gg/2016/10/25/swift-option-sets/)，包含两个选项:
- concurrent：标识队列为并行队列
- initiallyInactive：标识运行队列中的任务需要手动触发，由队列的 `activate` 方法进行触发。如果未添加此标识，向队列中添加的任务会自动运行。

如果不设置该值，则表示创建`串行队列`。如果希望创建并行队列，并且需要手动触发，则该值需要设置为 `[.concurrent, .initiallyInactive]`，即：
```
var queue: DispatchQueue = DispatchQueue.init(label: "com.xxx.xxx.queue", attributes: [.concurrent, .initiallyInactive])
```

### autoreleaseFrequency
autoreleaseFrequency 的类型为枚举（enum），用来设置负责管理任务内对象生命周期的 `autorelease pool` 的自动释放频率。包含三个类型：

- inherit：继承目标队列的该属性，
- workItem：跟随每个任务的执行周期进行自动创建和释放
- never：不会自动创建 autorelease pool，需要手动管理。

一般采用 `workItem` 行了。如果任务内需要大量重复的创建对象，可以使用 `never` 类型，来手动创建 `aotorelease pool`。

### target
这个参数设置了队列的`目标队列`，即队列中的任务运行时实际所在的队列。目标队列最终约束了队列的优先级等属性。

在程序中手动创建的队列最后都指向了系统自带的`主队列`或`全局并发队列`。

那为什么不直接将任务添加到系统队列中，而是自定义队列呢？这样的好处是可以将任务分组管理。如单独阻塞某个队列中的任务，而不是阻塞系统队列中的全部任务。如果阻塞了系统队列，所有指向它的原队列也就被阻塞。

从 Swift 3 开始，对目标队列的设置进行了约束，只有两种情况可以显示的设置目标队列：
- 在初始化方法中设置目标队列；
- 在初始化方法中，`attributes` 设定为 `initiallyInactive`，在队列调用 `activate()` 之前，可以指定目标队列。

在其他地方都不能再改变目标队列。

## 参考：
[iOS Swift GCD 开发教程](https://juejin.im/post/5acaea17f265da239a601a01#heading-40)



