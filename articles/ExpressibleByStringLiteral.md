# RxTodo

## ExpressibleByStringLiteral 协议

ExpressibleByStringLiteral 协议，表示一个类型可以通过一个字符串来初始化。[官方文档](https://developer.apple.com/documentation/swift/expressiblebystringliteral)

举例来说，String 或者 StaticString 实现了 ExpressibleByStringLiteral 协议，所以，我们可以使用一个任意长的字符串来初始化 String 或者 StaticString。

```
let picnicGuest = "Deserving porcupine"
```

Apple 已经为下面的类实现了 ExpressibleByStringLiteral 协议：

- CSLocalizedString
- NSMutableString
- NSString
- NWEndpoint.Host
- PreviewDevice
- Selector
- StaticString
- String
- Substring
- Target.Dependency
- Version

如果我们想用字符串来初始化一个类型，只需要实现 ExpressibleByStringLiteral 即可。比如我们可以对 Date 进行扩展，实现用一个字符串初始化一个 Date。

```
extension Date: ExpressibleByStringLiteral {
    
    public init(stringLiteral value: String) {
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "YYYY-MM-dd"
        guard let date = dateformatter.date(from: value) else {
            preconditionFailure("This date: \(value) is not invalid")
        }
        self = date
    }
}
```

接下来就可以使用字符串来初始化 Date 了：

```
let date: Date = "1990-01-01"
```

这可以减少初始化代码，但是如果过分使用，又会造成代码阅读难度的提升。

## 其他

类似的还有其他几个协议 
- ExpressibleByUnicodeScalarLiteral 可以使用 Unicode 初始化的类型
- ExpressibleByExtendedGraphemeClusterLiteral 可以使用`单个扩展字素簇的字符串`初始化的类型