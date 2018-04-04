# RxSwift Queue 队列的实现


在 RxSwift 的框架中，在 Queue.swift 文件中使用数组实现了一个`队列`（先进先出FIFO）。在操作次数达到 N 时，入栈和出栈的复杂度为 O(1)，获取第一个出栈元素的复杂度也为 O(1)。

下面是根据源码，梳理的实现原理:

在 `Queue` 的内部使用数组 `_storage` 来保存队列中的元素，_storage 的初始容量在 Queue 的初始化方法中传入。

```
init(capacity: Int) {
    _initialCapacity = capacity
    _storage = ContiguousArray<T?>(repeating: nil, count: capacity)
}
```

> 随着元素进队列和出队列，数组 `_storage` 的容量可能会改变，所以用 `_initialCapacity` 来记录数组的初始化容量。


当有元素进入队列时，就从数组 _storage 的索引为 0 处向后保存。入队列的元素保存在数组 _storage 中的索引，使用属性 `_pushNextIndex` 来表示。当有元素出队列时，就从数组 _storage 的索引为 0 处向后获取，使用 `dequeueIndex` 属性来表示首先要出栈的元素在数组 _storage 中的索引。在元素入队列和出队列的过程中，使用属性 `_count`  来记录当前栈中元素的数量。

当有元素入队列时，如果队列中的元素数量 _count 小于数组 _storage 的容量 `_storage.count`，也就是说数组中还有空间可以继续存储新的队列元素。这时如果 _pushNextIndex 小于 _storage.count，则将 _pushNextIndex 不断增加，如果 _pushNextIndex 大于等于 _storage.count，则说明队列中有的元素已经出栈，在数组的开头处空出了位置，则将进入队列的索引 _pushNextIndex 指向数组的索引为 0 处，继续向后添加元素。
所以数组中的元素排布可能为以下两种情况：

- dequeueIndex 在 _pushNextIndex 的左边，dequeueIndex = _pushNextIndex - _count
- dequeueIndex 在 _pushNextIndex 的右边，dequeueIndex = _pushNextIndex + _storage.count - _count

![元素在数组中的分布情况](https://upload-images.jianshu.io/upload_images/1879951-acb2d0a98a323cf6.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

所以 dequeueIndex 可以通过 _pushNextIndex 和 _count  推导出，代码如下：
```
private var dequeueIndex: Int {
    let index = _pushNextIndex - count
    return index < 0 ? index + _storage.count : index
}
```

当有元素进入队列时，如果队列中的元素数量 _count 等于数组 _storage 的容量（_storage.count）时，也就是说数组中已经存满了队列的元素，这时就需要一个更大的数组来存放队列元素。新的数组的容量通过原来数组的容量(数组的容量大于0时)乘以系数 `_resizeFactor` 计算获得。
```
// 元素进入队列的方法
mutating func enqueue(_ element: T) {
    // _storage 存储满了
    if count == _storage.count {
        // 将数组容量扩充至 Swift.max(_storage.count, 1) * _resizeFactor
        resizeTo(Swift.max(_storage.count, 1) * _resizeFactor)
    }
    
    _storage[_pushNextIndex] = element
    _pushNextIndex += 1
    _count += 1
    
    // _pushNextIndex 大于 _storage.count，将 _pushNextIndex 指向数组的开头
    if _pushNextIndex >= _storage.count {
        _pushNextIndex -= _storage.count
    }
}
```

怎样对保存队列元素的数组进行扩容呢？分成两步：
1. 创建一个容量合适的新数组
2. 将原来数组中的元素复制到新的数组中。

创建新的数组简单，我们应该怎样将原来数组中的元素拷贝到新的数组中。我们再次看队列元素在数组中的可能出现的分布情况：

![元素在数组中的分布情况](https://upload-images.jianshu.io/upload_images/1879951-acb2d0a98a323cf6.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

可以将数组中的元素分成两块，第一块是出栈位置 `dequeueIndex` 到数组末尾的元素，第二块是数组开头到队列的结尾的元素。
![第一种情况：这种情况的第二块的元素个数为0。](https://upload-images.jianshu.io/upload_images/1879951-3982c012aa085d68.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

![第二种情况](https://upload-images.jianshu.io/upload_images/1879951-a60a754283441d47.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)


接下来计算两块的元素的数量。计算数组容量和出栈的位置 dequeueIndex 之间的间隔 spaceToEndOfQueue，则第一块的元素个数为 spaceToEndOfQueue 和 _count 中较小的一个，用 countElementsInFirstBatch 表示。第二块的元素个数为元素的个数 _count 减去 countElementsInFirstBatch 的数量，用 numberOfElementsInSecondBatch 表示。
接下来，只需要将第一段内的元素拷贝至新元素的开头，将第二段拷贝至新数组中第一段元素的末尾。

```
// 1.
mutating private func resizeTo(_ size: Int) {
    // 申请新数组
    var newStorage = ContiguousArray<T?>(repeating: nil, count: size)
    // 拷贝原来的元素到新的数组
    let count = _count
    let dequeueIndex = self.dequeueIndex
    let spaceToEndOfQueue = _storage.count - dequeueIndex

    // first batch is from dequeue index to end of array
    // 第一段为 dequeue 的索引到数组的末尾
    let countElementsInFirstBatch = Swift.min(count, spaceToEndOfQueue)
    // second batch is wrapped from start of array to end of queue
    // 第二段为数组的开始到队列的末尾
    let numberOfElementsInSecondBatch = count - countElementsInFirstBatch

    newStorage[0 ..< countElementsInFirstBatch] = _storage[dequeueIndex ..< (dequeueIndex + countElementsInFirstBatch)]
    newStorage[countElementsInFirstBatch ..< (countElementsInFirstBatch + numberOfElementsInSecondBatch)] = _storage[0 ..< numberOfElementsInSecondBatch]
    
    _count = count
    _pushNextIndex = count
    _storage = newStorage
}
```

在元素出队列的过程中，可能会出现数组中的容量远远大于队列中元素的数量，这时为了减少占用的内存空间，则需要缩小数组的大小。所以在有元素出队列时，需要根据条件判断是否需要缩小数组的大小。如果需要调整数组容量，则申请一个新的小容量数组，再将元素拷贝至新的数组中。将数组容量调小的方法和将数组调大的方法相同（都是通过调用 `resizeTo(_)` 方法）。

```
// 出栈
private mutating func dequeueElementOnly() -> T {
    precondition(count > 0)
    
    let index = dequeueIndex

    defer {
        _storage[index] = nil
        _count -= 1
    }

    return _storage[index]!
}

/// Dequeues element or throws an exception in case queue is empty.
///
/// - returns: Dequeued element.
mutating func dequeue() -> T? {
    if self.count == 0 {
        return nil
    }

    defer {
        // 判断是否需要调整数组容量
        let downsizeLimit = _storage.count / (_resizeFactor * _resizeFactor)
        if _count < downsizeLimit && downsizeLimit >= _initialCapacity {
            resizeTo(_storage.count / _resizeFactor)
        }
    }

    return dequeueElementOnly()
}
```


