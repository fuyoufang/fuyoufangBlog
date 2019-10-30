# Swift Then 框架

[Then](https://github.com/devxoul/Then) 是一个 Swift 初始化器的语法糖，简化了初始化（或者修改属性）的代码量。

Then 框架非常简单，代码量在 60 行左右。

Then 框架对 NSObject 扩展了 `then()` 方法。下面是官方提供的一个示例： 

``` swift
let label = UILabel().then {
    $0.textAlignment = .center
    $0.textColor = .black
    $0.text = "Hello, World!"
}
```

它等价于：

```
let label: UILabel = {
    let label = UILabel()
    label.textAlignment = .center
    label.textColor = .black
    label.text = "Hello, World!"
    return label
}()
```

自定义的类，可以通过扩展 Then 协议，来使用 `then()`:

```
extension MyType: Then {}

let instance = MyType().then {
    $0.really = "awesome!"
}
```

另外还提供了 `do()` 和 `with()`

### do() 

do() 可以代码的键入量

```
let newFrame = oldFrame.with {
    $0.size.width = 200
    $0.size.height = 100
}
newFrame.width // 200
newFrame.height // 100
```

### with() 

with()可以创建新值

```
UserDefaults.standard.do {
    $0.set("devxoul", forKey: "username")
    $0.set("devxoul@gmail.com", forKey: "email")
    $0.synchronize()
}
```

## 总结
Then 框架一共提供了三个方法：

- `then()` 用在初始化，可以减少代码量。
- `do()` 用在设置属性，可以减少代码量。
- `with()` 复制原值，并修改新值的属性，返回修改后的新值。

`do()` 和 `then()` 的区别就是: `do()` 没有返回值，`then()` 将修改后的 self 进行了返回。