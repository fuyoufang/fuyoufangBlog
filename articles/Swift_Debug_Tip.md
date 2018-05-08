# Swift 调试小技巧

## 调用堆栈
在调试阶段，除了打断点查看当前线程的调用堆栈外，也可以使用 `Thread` 的方法 `callStackSymbols` 来获取当前的调用堆栈符号。例如我们可以用下面的代码打印当前线程的调用堆栈：

```
for stackSymbol in Thread.callStackSymbols {
    print(stackSymbol)
}
```

## 打印当前代码的文件信息
有时候我们不仅需要打印指定的信息，而且需要打印当前文件名，当前方法的信息，如果手动书写这些信息将会非常麻烦，而且随着代码的改动，这些信息可能会频繁的改动。

在 Swift 中，编译器提供了几个编译符号来满足类似的需求，它们是：

| 符号 | 类型 | 描述 |
| -- | -- | -- |
| #file | String | 包含这个符号的文件的路径 | 
| #line | Int | 符号出现处的行号 | 
| #column | Int | 符号出现处的列 | 
| #function | String | 包含这个符号的方法名字 | 

我们可以使用上面的编译符号写一个更好的 print 方法：
```
func printLog<T>(message: T,
                 file: String = #file,
                 method: String = #function,
                 line: Int = #line)
{
    print("\((file as NSString).lastPathComponent)[\(line)], \(method): \(message)")
}
```

对于 log 的输出更多的开发和调试阶段，过多的输出可能对性能有所影响，所以在 Realease 版本中关闭掉向控制台输出也是软件开发中一种常见的做法。通过`条件编译`的方法，我们可以添加条件，并设置合适的编译配置，使 printLog 的内容在 Release 时被去掉，从而成为一个空方法：

```
func printLog<T>(message: T,
                    file: String = #file,
                  method: String = #function,
                    line: Int = #line)
{
    #if DEBUG
    print("\((file as NSString).lastPathComponent)[\(line)], \(method): \(message)")
    #endif
}
```
新版本的 LLVM 编译器在遇到空方法时，会将整个方法去掉，完全不去调用它，从而实现零成本。

## 关键字的使用
在 Swift 语言中，会有一些关键字，比如：do, if, while, for 等等。在编码的时候，我们应该尽量避免使用关键字，但如果我们必须使用 Swift 中的关键字时，可以用反引号（\`）将关键词包住。例如在 RxSwift 中，使用了关键字 `do` 作为方法名，具体定义如下：
```
public func `do`(onError: ((Swift.Error) throws -> Void)? = nil,
             onCompleted: (() throws -> Void)? = nil,
             onSubscribe: (() -> ())? = nil,
             onSubscribed: (() -> ())? = nil,
             onDispose: (() -> ())? = nil)
-> Completable {
    return Completable(raw: primitiveSequence.source.do(
        onError: onError,
        onCompleted: onCompleted,
        onSubscribe: onSubscribe,
        onSubscribed: onSubscribed,
        onDispose: onDispose)
    )
}
```

## 参考：
[LOG 输出](http://swifter.tips/log/)