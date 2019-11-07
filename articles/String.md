# String 的常用操作

### 转为为大写字母

```
var capitalized: String { get }
```

### 字符串转化成 URL
```
public var urlValue: URL? {
    if let url = URL(string: self) {
        return url
    }
    var set = CharacterSet()
    set.formUnion(.urlHostAllowed)
    set.formUnion(.urlPathAllowed)
    set.formUnion(.urlQueryAllowed)
    set.formUnion(.urlFragmentAllowed)
    return self.addingPercentEncoding(withAllowedCharacters: set).flatMap { URL(string: $0) }
}
```