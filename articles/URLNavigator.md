# Swift URLNavigator 框架

⛵️ URLNavigator 是 Swift 下一个优雅的 URL 路由。它提供了通过 URL 导航到 view controller 的方式。URL 参数的对应关系通过 `URLNavigator.register(_:_:)` 方法进行设置。

URLNavigator 提供了两种方法来设置 URL 参数的对应关系：`URLNavigable` 和 `URLOpenHandler`。`URLNavigable` 通过自定义的初始化方法进行设置，`URLOpenHandler` 通过一个可执行的闭包进行设置。初始化方法和闭包都接受一个 URL 和占位符值。

## 开始

#### 1. 理解 URL 模式

URL 模式可以包含多个占位符。占位符将会被匹配的 URL 中的值替换。使用 `<` 和 `>` 来设置占位符。占位符的类型可以设置为：`string`(默认), `int`, `float`, 和 `path`。

例如，`myapp://user/<int:id>` 将会和下面的 URL 匹配：

* `myapp://user/123`
* `myapp://user/87`

但是，无法和下面的 URL 配置：

* `myapp://user/devxoul` (类型错误，需要 int)
* `myapp://user/123/posts` (url 的结构不匹配))
* `/user/devxoul` (丢失 scheme)

#### 2. View Controllers 和 URL 打开操作的匹配

URLNavigator 通过 URL 模式来匹配 view controllers 和 URL 的打开操作。下面是使用 view controller 和闭包映射 URL 模式的示例。每个闭包有三个参数：`url`, `values` 和 `context`。

* `url` 是通过 `push()` 或者 `present()` 传递的 URL 参数.
* `values` 是一个包含 URL 占位符的 keys 和 values 的字典.
* `context` 是通过 `push()`, `present()` 或 `open()` 传递的额外值的字典。

```swift
let navigator = Navigator()

// register view controllers
navigator.register("myapp://user/<int:id>") { url, values, context in
  guard let userID = values["id"] as? Int else { return nil }
  return UserViewController(userID: userID)
}
navigator.register("myapp://post/<title>") { url, values, context in
  return storyboard.instantiateViewController(withIdentifier: "PostViewController")
}

// register url open handlers
navigator.handle("myapp://alert") { url, values, context in
  let title = url.queryParameters["title"]
  let message = url.queryParameters["message"]
  presentAlertController(title: title, message: message)
  return true
}
```

#### 3. 弹出方式（Pushing, Presenting）与操作 URLs

URLNavigator 可以通过执行一个带 URLs 参数的闭包来 push 或者 presenet 对应的 view controllers。

在 `push()` 方法中，通过指定 `from` 参数可以设置弹出新 view controller 的 **navigation controller**。同样，在 `present()` 方法中，通过指定 `from` 参数可以设置弹出新 view controller 的 **view controller**。如果设置为 nil，也就是默认值，当前应用程序最顶层的 view controller 将会被用来 push 或 present 新的 view controller。

`present()` 还有一个额外的参数 `wrap`。如果将这个参数设置为 `UINavigationController` 类型，则会用这种类型的导航控制器把要弹出的新的 view controller 包住。这个参数的默认值为 `nil`。

```swift
Navigator.push("myapp://user/123")
Navigator.present("myapp://post/54321", wrap: UINavigationController.self)

Navigator.open("myapp://alert?title=Hello&message=World")
```

## 安装

官方仅提供了通过 CocoaPods 安装的方式。

**Podfile**

```ruby
pod 'URLNavigator'
```

## 示例

示例程序 [点击查看](https://github.com/devxoul/URLNavigator/tree/master/Example).

1. 编译并安装示例 app。
2. 打开 Safari app。
3. 在 URL 栏输入 `navigator://user/devxoul`。
4. 示例程序将会被加载。

## 提示和窍门

#### 初始化 Navigator 实例的时机

1. 定义一个全局的常量:
    
    ```swift
    let navigator = Navigator()
    
    class AppDelegate: UIResponder, UIApplicationDelegate {
      // ...
    }
    ```

2. 向 IoC 容器内注册

    ```swift
    container.register(NavigatorType.self) { _ in Navigator() } // Swinject
    let navigator = container.resolve(NavigatorType.self)!
    ```

3. 在合成根部注册依赖

> Inject dependency from a composition root.


#### 关联 URL 的时机

作者喜欢将 URL 映射关系放到单独的文件中。

```swift
struct URLNavigationMap {
  static func initialize(navigator: NavigatorType) {
    navigator.register("myapp://user/<int:id>") { ... }
    navigator.register("myapp://post/<title>") { ... }
    navigator.handle("myapp://alert") { ... }
  }
}
```

然后在 `AppDelegate` 的 `application:didFinishLaunchingWithOptions:` 方法中调用 `initialize()`。

```swift
@UIApplicationMain
final class AppDelegate: UIResponder, UIApplicationDelegate {
  func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?
  ) -> Bool {
    // Navigator
    URLNavigationMap.initialize(navigator: navigator)
    
    // Do something else...
  }
}
```

#### 实现 AppDelegate 启动选项 URL

如果注册了自定义的 schemes，就可以通过 URLs 来启动我们的 app 了。可以通过实现 `application:didFinishLaunchingWithOptions:` 方法来实现通过 URLs 导航到指定的 view controller。

```swift
func application(
  _ application: UIApplication,
  didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?
) -> Bool {
  // ...
  if let url = launchOptions?[.url] as? URL {
    if let opened = navigator.open(url)
    if !opened {
      navigator.present(url)
    }
  }
  return true
}

```

#### 实现 AppDelegate 打开 URL 的方法

你可能需要实现自定义的 URL 打开处理程序。下面是一个使用 URLNavigator 和其他 URL 打开处理程序的示例：

```swift
func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
  // If you're using Facebook SDK
  let fb = FBSDKApplicationDelegate.sharedInstance()
  if fb.application(application, open: url, sourceApplication: sourceApplication, annotation: annotation) {
    return true
  }

  // URLNavigator Handler
  if navigator.open(url) {
    return true
  }

  // URLNavigator View Controller
  if navigator.present(url, wrap: UINavigationController.self) != nil {
    return true
  }

  return false
}
```

#### 在 Pushing, Presenting 或 Opening 时传入附加值

```swift
let context: [AnyHashable: Any] = [
  "fromViewController": self
]
Navigator.push("myapp://user/10", context: context)
Navigator.present("myapp://user/10", context: context)
Navigator.open("myapp://alert?title=Hi", context: context)
```

#### 定义自定义 URL 值的转换器

你可以自定义给 URL 占位符设置 URL 值的转化器。

例如，占位符 `<region>` 仅能够接受 `["us-west-1", "ap-northeast-2", "eu-west-3"]` 中的字符串。如果传入的参数不包含在这些值中，URL 的参数将无法匹配。

下面是在 `Navigator` 实例的 `[String: URLValueConverter]` 字典中添加一个自定义的值转换器。

```swift
navigator.matcher.valueConverters["region"] = { pathComponents, index in
  let allowedRegions = ["us-west-1", "ap-northeast-2", "eu-west-3"]
  if allowedRegions.contains(pathComponents[index]) {
    return pathComponents[index]
  } else {
    return nil
  }
}
```
通过上面的代码，`myapp://region/<region:_>` 将会匹配下面的 URL:

- `myapp://region/us-west-1`
- `myapp://region/ap-northeast-2`
- `myapp://region/eu-west-3`

但是和下面的 URL 就无法匹配了:
- `myapp://region/ca-central-1`

其他相关信息，可以查看 URL 值的默认转换器的[实现方式](https://github.com/devxoul/URLNavigator/blob/master/Sources/URLMatcher/URLMatcher.swift)

