# RxSwift：KVO监听对象属性

在观察某个属性是否变化的时候，采用 KVO 的方式更为简单直接一些。

关于 Swift 的 KVO 使用方法，可以查看[王巍的 KVO](https://swifter.tips/kvo/)

简单来说，在 Swift 中：

- 被观察的属性前需要添加 `@objc dynamic` 标签，
- 被观察的类必须继承 `NSObject`

如果不符合则会发生以下异常：

```
sent to an object that is not KVC-compliant for the "***" property.
```

在 RxSwift 框架下，提供了 `rx.observe` 和 `rx.observeWeakly` 两种方式的课观察序列。

### rx.observe 
rx.observe 是对 KVO 的简单封装，执行效率更高。它要求被观察的属性路径都是使用 strong 修饰的，如果观察使用 weak 修饰的属性，可会发生崩溃。
 
使用 rx.observe 时，需要注意 **循环引用** 的问题。如果一个类观察自己的属性，使用 rx.observe 将会产生 **循环引用** 的问题。

### rx.observeWeakly

rx.observeWeakly 可以处理属性变为空的情况，所有可以用在使用 weak 修饰的属性上。

所有可以使用 rx.observe 的地方，都是使用 rx.observeWeakly。但是，rx.observeWeakly 的性能没有 rx.observe 的高。


下面为采用 RxSwift 框架下的实例：
```
import RxCocoa
import RxSwift

class User: NSObject {
    @objc dynamic var name: String
    
    init(name: String) {
        self.name = name
    }
}

class TestViewController: UIViewController {

    @objc dynamic var message = ""
    var disposeBag = DisposeBag()
    @objc dynamic var user: User = User(name: "fang")
    @objc dynamic var number: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .orange
        
        let interval: DispatchTimeInterval = .seconds(1)
        Observable<Int>
            .interval(interval, scheduler: MainScheduler.instance)
            .subscribe(onNext: { [unowned self] (_) in
                self.number += 1
                self.user.name += "~"
            })
            .disposed(by: disposeBag)
        
        // 监听 number 属性
        self.rx
            .observeWeakly(Int.self, "number")
            .subscribe(onNext: { (message) in
                // 注意： number 为 Int? 类型
                debugPrint(message ?? -1)
            })
            .disposed(by: disposeBag)

        // 监听 user.name 属性
        self.rx
            .observeWeakly(String.self, "user.name")
            .subscribe(onNext: { (name) in
                // 注意： name 为 Sting? 类型
                debugPrint(name ?? "")
            })
            .disposed(by: disposeBag)
        
    }
}

```

### 注意

在实例中，观察 `user.name` 属性时，keypath 中的 `user` 和 `name` 属性都要使用 `@objc dynamic` 进行标记。

> 也就是说 TestViewController 中的 user 属性需要使用 `@objc dynamic` 进行标记，User 类中的 name 属性，也要用 `@objc dynamic` 进行标记。

在实例中，必须使用 `rx.observeWeakly` 进行监听，否则会产生循环应用。


## 其他
> Swift 3 中继承自 NSObject 的类，不需要手动添加 @objc ，编译器会给所有的非 private 的类和成员加上 @objc ， private 接口想要暴露给 Objective-C 需要 @objc 的修饰。Swift4 后继承自 NSObject 的类不再隐式添加 @objc 关键字
