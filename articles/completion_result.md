# 处理结果值与结果值的处理

在应用程序中，经常会获取到一个结果值，然后对结果值进行处理。比如：网络请求结束后获取一个结果值，再讲这个结果值进行加工，转化为我们对应的实体类。

通常的写法如下：

```swift
static func request(_ url: URL, completion: ((Data) -> Void)? = nil) {
    URLSession.shared.dataTask(with: url) { data, response, error in
        if let data = data {
            completion?(data)
        }
    }.resume()
}
```

> 为了说明问题，简化了很多代码。

当网络请求获取到结果 data 之后，调用 completion 对 data 进行处理。

能不能更近一步的简化对应的代码呢？在阅读 [URLNavigator](./URLNavigator.md) 框架的时候，学了另一种写法，我们看怎样更进一步简化代码。

```swift
extension Data {
    func apply(_ f: ((Data) throws -> Void)?) rethrows -> Void {
        try f?(self)
    }
}

static func request(_ url: URL, completion: ((Data) -> Void)? = nil) {
    URLSession.shared.dataTask(with: url) { data, response, error in
        data?.apply(completion)
    }.resume()
}
```

首先对 Data 方法进行了扩展。在需要处理 Data 类型的数据时，就可以将处理函数应用到扩展中 `apply` 方法上。达到进一步简化代码的目的。

对比这两种方式，第一种更加的直观，符合编程习惯；第二种可以使代码看起来更加简洁，但是增加了阅读代码的难度。如果处理方法调用次数较多时，不妨试一下。



