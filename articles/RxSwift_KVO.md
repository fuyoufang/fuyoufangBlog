# RxSwift：KVO监听对象属性

在观察某个属性是否变化的时候，采用 KVO 的方式更为简单直接一些。

关于 Swift 的 KVO 使用方法，可以查看[王巍的 KVO](https://swifter.tips/kvo/)

简单来说，在 Swift 中：

- 被观察的属性前需要添加 `@objc` 标签，
- 被观察的类必须继承 `NSObject`

如果不符合则会发生以下异常：

```
sent to an object that is not KVC-compliant for the "***" property.
```

下面为采用 RxSwift 框架下的实例：
```
class User: NSObject {
    @objc dynamic var name: String
    
    init(name: String) {
        self.name = name
    }
}

class ViewController: UIViewController {
    
    var disposeBag = DisposeBag()
    
    @objc dynamic var user: User?
    @objc dynamic var number: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // 监听 number 属性
        self.rx.observe(Int.self, "number")
            .subscribe(onNext: { (number) in
                // 注意： number 为 Int? 类型
                debugPrint("number:\(number ?? 0)")
            }).disposed(by: disposeBag)

        // 监听 user.name 属性
        self.rx.observe(Bool.self, "user.name")
            .subscribe(onNext: { [weak self] (name) in
                // 注意： name 为 Sting? 类型
                print(name)
            })
            .disposed(by: disposeBag)
    }
}
```

在实例中，观察 `user.name` 属性时，keypath 中的 `user` 和 `name` 属性都要使用 `@objc` 进行标记。

> Swift 3 中继承自 NSObject 的类，不需要手动添加 @objc ，编译器会给所有的非 private 的类和成员加上 @objc ， private 接口想要暴露给 Objective-C 需要 @objc 的修饰。Swift4 后继承自 NSObject 的类不再隐式添加 @objc 关键字