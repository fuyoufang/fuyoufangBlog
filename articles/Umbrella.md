# Swift Umbrella 框架

[Umbrella](https://github.com/devxoul/Umbrella) 是 Swift 下对**数据分析**的抽象层。作者受启发于 [Moya](https://github.com/Moya/Moya)。

## 为什么使用 Umbrella

---

Umbrella 可以解决下面的问题：

1. 当项目中使用多个数据分析库（SDK）时，则需要在数据统计的地方添加或更改各个框架的设置。而 Umbrella 框架，创建了一个抽象层，对项目中所有应用的数据分析库（SDK）进行了统一的管理，只需要调用一个方法，就可以将事件传递到所有的数据分析库。

2. 常用的数据分析库（SDK），通常会采用字符串来设置统计事件的名称，使用字典来设置事件参数。这种方式无法通过编译器来保证代码的正确性。而 Umbrella 框架，采用了 Enum 枚举的方式标记统计事件，枚举值提供事件的名称和参数。

具体使用方法可以通过 [Github](https://github.com/devxoul/Umbrella) 查看。

## 从 Umbrella 中得到的启发

---

### 在不确定的情况下，操作相应的类

Umbrella 对常见的几种数据分析库进行了封装，当用户在项目中恰好使用这些库时，就可以通过简单的设置完成配置。但是 Umbrella 怎么知道用户会使用哪些数据分析库呢？在不确定的情况下，怎样封装对应的类呢？

Umbrella 使用了运行时的特性，通过字符串记录了常用的数据分析 SDK 中的类名和初始化方法名。如果用户恰好使用了 Umbrella 中内置的几种数据分析 SDK，则可以通过类名和方法名来获取到对应的类和方法。具体实现如下：

```swift
public protocol RuntimeProviderType: ProviderType {
    // 记录数据分析的类名
    var className: String { get }
    // 初始化数据分析实例的方法名（因为有些数据分析全部使用静态方法，并不需要初始化一个实例，所以该属性为 optional）
    var instanceSelectorName: String? { get } // optional
    // 记录分析事件的方法名
    var selectorName: String { get }
}

public extension RuntimeProviderType {
    var cls: NSObject.Type? {
        return NSClassFromString(self.className) as? NSObject.Type
    }
    
    var instanceSelectorName: String? {
        return nil
    }
    
    /*
     * 字符串转化为 类
     * 字符串转化为 Selector
     * 类调用方法生成负责统计的 实例
     */
    var instance: AnyObject? {
        guard let cls = self.cls else { return nil }
        guard let sel = self.instanceSelectorName.flatMap(NSSelectorFromString) else { return nil }
        guard cls.responds(to: sel) else { return nil }
        // takeUnretainedValue 不负责对象的释放
        return cls.perform(sel)?.takeUnretainedValue()
    }
    
    // 统计 Selector
    var selector: Selector {
        return NSSelectorFromString(self.selectorName)
    }
    
    var responds: Bool {
        guard let cls = self.cls else { return false }
        if let instance = self.instance {
            return instance.responds(to: self.selector)
        } else {
            return cls.responds(to: self.selector)
        }
    }
    
    func log(_ eventName: String, parameters: [String: PrimitiveType]?) {
        guard self.responds else { return }
        // 调用两个参数的方法
        if let instance = self.instance {
            _ = instance.perform(self.selector, with: eventName, with: parameters)
        } else {
            _ = self.cls?.perform(self.selector, with: eventName, with: parameters)
        }
    }
}
```

对某个数据分析 SDK 进行封装时，我们只需要创建符合 RuntimeProviderType 的类型就可以了。比如：

```swift
open class AppsFlyerProvider: RuntimeProviderType {
    public let className: String = "AppsFlyerTracker"
    public let instanceSelectorName: String? = "sharedTracker"
    public let selectorName: String = "trackEvent:withValues:"
    
    public init() {
    }
}
```

### 通过 Enum 让代码更可靠

Swift 中 Enum 可以绑定参数，可以拥有方法。我们可以通过这些特性提高代码的可靠性。比如 Umbrella 就通过 Enum 来设置事件统计的名称，并绑定了事件统计的参数。