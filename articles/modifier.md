# Swift 中的修饰符

## @discardableResult
- 描述
当一个方法有返回值时，如果我们没有接收方法的返回值，这是 XCode 我警告我们，如果想消除这个警告，可以在方法前加上 @discardableResult。
- 示例
```
@discardableResult
func increment(number: inout Int) -> Int {
    let old = number
    number += 1
    return old
}

var x = 10
increment(number: &x)
```

## @inline(__always)
- 描述
内联函数，提高代码的执行效率
- 示例
```
@discardableResult
@inline(__always)
func increment(number: inout Int) -> Int {
    let old = number
    number += 1
    return old
}

var x = 10
increment(number: &x)
```

## @available
```
@available(*, deprecated, message: "Use `Element` instead.")
typealias E = Element
```