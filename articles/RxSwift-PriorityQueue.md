# RxSwift PriorityQueue 优先级队列的实现

在 RxSwift 框架中，在 PriorityQueue.swift 文件中，使用数组实现了一个优先级队列 `PriorityQueue`。

> **优先级队列**（priority queue）是0个或者多个元素的集合，每个元素有一个优先级，可以在集合中查找或删除优先级最高的元素。对优先级队列执行的操作有:
1. 查找。一般情况下，查找操作用来搜索优先权最大的元素。
2. 插入一个新元素。
3. 删除。一般情况下，删除操作用来删除优先权最大的元素。 
对于优先权相同的元素，可按先进先出次序处理或按任意优先权进行。

RxSwift 是通过数组实现`优先级队列`的。在有元素入队列和出队列的之后必须对数组中的元素进行排序，才能在获取队列中优先级最高的元素时非常快速。RxSwift 使用的是`最大堆`（`最小堆`）的排序算法，对数组中的元素进行排序的。

### 堆树
堆树（最大堆或者最小堆）的定义如下：
1. 堆树是一棵完全二叉树；
2. 堆树中某个节点的值总是不大于（或不小于）其子节点的值；
3. 堆树中每个节点的子树都是堆树；

当父节点的值总是大于或等于任何一个子节点的值时为**最大堆**，当父节点的值总是小于或等于任何一个子节点的值时为**最小堆**。

![最大堆示例](https://upload-images.jianshu.io/upload_images/1879951-f25c94f7b0bfc3db.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

![最小堆示例](https://upload-images.jianshu.io/upload_images/1879951-e426e6cb4383bd6e.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

#### 构造最大树
怎样将一个未排序的数组构造成堆树呢？现在以最大堆为例进行讲解（最小堆同理）。    
加入我们拿到的未排序的数组为：
```swift
var numbers = [6, 2, 5, 4, 20, 13, 14, 15, 9, 7]
```
数组对应的完全二叉树如下图所示：

![未排序数组对应的完全二叉树](https://upload-images.jianshu.io/upload_images/1879951-8086d9ed933be99e.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

如果堆树中的每个非子节点的值都大于它的两个（或一个）相近的子节点的值，那么整个堆树就满足了每个节点的值总是不小于其子节点的值。所以构造堆树的基本思路是：**首先找到最后一个节点的父节点，从这个父节点开始调整树，保证父节点的值大于子节点的值。然后从这个父节点继续向前调整树，直到所有的非子节点的值都不小于于它的相邻的子节点的值，这样最大堆就构造完毕了**。

假设树中有n个节点，从0开始给节点编号，到n-1结束，对于编号为i的节点，其父节点为(i-1)/2；左子节点的编号为i*2+1，右子节点的编号为i*2+2。最后一个节点的编号为n-1，其父节点的编号为(n-2)/2，所有从编号为(n-2)/2的节点开始调整树。

如下图所示，最后一个节点为7，其父节点为20，从20这个节点开始构造最大堆；构造完毕之后，转移到下一个父节点，直到所有父节点都构造完毕。
![最大堆构造过程1](https://upload-images.jianshu.io/upload_images/1879951-8089ac2b1aa102ba.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
![最大堆构造过程2](https://upload-images.jianshu.io/upload_images/1879951-f8b95b716850b38a.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

思路已经梳理完成，下面我们看 `RxSwift` 具体是怎样实现的。

在`PriorityQueue`的初始化方法中传入对比两个元素优先级和判断元素是否相等的方法。`_elements`用于保存队列中的元素。 
```swift
struct PriorityQueue<Element> {

    private let _hasHigherPriority: (Element, Element) -> Bool
    private let _isEqual: (Element, Element) -> Bool

    fileprivate var _elements = [Element]()

    init(hasHigherPriority: @escaping (Element, Element) -> Bool, isEqual: @escaping (Element, Element) -> Bool) {
        _hasHigherPriority = hasHigherPriority
        _isEqual = isEqual
    }
}
```

获取优先级最高的元素，即返回 `_elements` 最前的元素：
```
func peek() -> Element? {
    return _elements.first
}
```

有元素进入队列时，首先将元素添加到数组`_elements`的末尾，相当于在堆树的末尾又添加了一个节点，这时需要根据这个节点的优先级和其父节点的优先级调整数组。因为在添加元素之前的树结构已经满足最大堆的要求，所以现在只需要关注最后一个节点和它的父节点的优先级，如果最后一个节点的优先级较高，则将最后一个节点和它的父节点进行调整。以此类推，一直向上调整到树的顶端。
```swift
mutating func enqueue(_ element: Element) {
    _elements.append(element)
    bubbleToHigherPriority(_elements.count - 1)
}

// 从下标为 initialUnbalancedIndex 处向高的优先级处调整元素
private mutating func bubbleToHigherPriority(_ initialUnbalancedIndex: Int) {
    // 确保 initialUnbalancedIndex 在 _elements 的索引范围内
    precondition(initialUnbalancedIndex >= 0)
    precondition(initialUnbalancedIndex < _elements.count)

    var unbalancedIndex = initialUnbalancedIndex

    while unbalancedIndex > 0 {
        // unbalancedIndex 为未排序的索引
        // parentIndex 为未排序节点的父节点的索引
        let parentIndex = (unbalancedIndex - 1) / 2
        guard _hasHigherPriority(_elements[unbalancedIndex], _elements[parentIndex]) else { break }
        #if swift(>=3.2)
        _elements.swapAt(unbalancedIndex, parentIndex)
        #else
        swap(&_elements[unbalancedIndex], &_elements[parentIndex])
        #endif
        unbalancedIndex = parentIndex
    }
}
```

将优先级最高的元素出队列，也就是将数组中的第一个元素移除，同时我们也有可能需要移除数组中的任意一个的元素。进而我们可以将问题归结为：怎样移除指定索引处的元素。

当要移除指定索引的元素时，首先将指定索引处的元素和数组的最后一个元素交换位置，再将最后一个元素移除，这样原本在数组最后的元素移到了指定的索引处，这样有可能破坏了的最大堆的规则，所以要将指定位置的元素根据其优先级向下浮动，让它的子节点中值最大的一个和其交换位置，确保指定索引的优先级大于它所有子节点的优先级，然后将指定索引处的元素根据优先级向上浮动，确保指定索引处的元素优先级小于或等于其父节点的优先级。代码如下：
```
// 优先级最高的元素出队列
mutating func dequeue() -> Element? {
    guard let front = peek() else {
        return nil
    }

    removeAt(0)

    return front
}

// 移除任意一个元素
mutating func remove(_ element: Element) {
    for i in 0 ..< _elements.count {
        if _isEqual(_elements[i], element) {
            removeAt(i)
            return
        }
    }
}

// 移除指定索引的元素
private mutating func removeAt(_ index: Int) {

    let removingLast = index == _elements.count - 1
    if !removingLast {
        #if swift(>=3.2)
        _elements.swapAt(index, _elements.count - 1)
        #else
        swap(&_elements[index], &_elements[_elements.count - 1])
        #endif
    }

    _ = _elements.popLast()

    if !removingLast {
        bubbleToHigherPriority(index)
        bubbleToLowerPriority(index)
    }
}


// 向低优先级冒泡
private mutating func bubbleToLowerPriority(_ initialUnbalancedIndex: Int) {
    precondition(initialUnbalancedIndex >= 0)
    precondition(initialUnbalancedIndex < _elements.count)

    var unbalancedIndex = initialUnbalancedIndex
    while true {
        //
        let leftChildIndex = unbalancedIndex * 2 + 1
        let rightChildIndex = unbalancedIndex * 2 + 2

        var highestPriorityIndex = unbalancedIndex

        if leftChildIndex < _elements.count && _hasHigherPriority(_elements[leftChildIndex], _elements[highestPriorityIndex]) {
            highestPriorityIndex = leftChildIndex
        }

        if rightChildIndex < _elements.count && _hasHigherPriority(_elements[rightChildIndex], _elements[highestPriorityIndex]) {
            highestPriorityIndex = rightChildIndex
        }

        guard highestPriorityIndex != unbalancedIndex else { break }

        #if swift(>=3.2)
        _elements.swapAt(highestPriorityIndex, unbalancedIndex)
        #else
        swap(&_elements[highestPriorityIndex], &_elements[unbalancedIndex])
        #endif
        unbalancedIndex = highestPriorityIndex
    }
}
```
到此，`RxSwift` 的优先级队列 `PriorityQueue` 的所有功能已经实现，它使用最大堆排序，插入和删除元素的时间复杂度都是O(log(n))。



