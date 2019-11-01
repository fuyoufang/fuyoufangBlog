# Swift ReusableKit 框架

[ReusableKit](https://github.com/devxoul/ReusableKit) 是为 Cocoa 的可重用资源创建的框架。目前支持 `UITableView` 和 `UICollectionView`。

## 概述

在使用可重用资源的时候，通常需要写下面的代码：

```
collectionView.register(UserCell.self, forCellWithReuseIdentifier: "userCell")
collectionView.dequeueReusableCell(withReuseIdentifier: "userCell", for: indexPath) as! UserCell
```

这要求我们保证可重用标记 `ReuseIdentifier` 的唯一性，并且要保证注册和调用的时候的统一。

下面是使用 ReusableKit 框架只有的写法：

```
let reusableUserCell = ReusableCell<UserCell>()
collectionView.register(reusableUserCell)
collectionView.dequeue(reusableUserCell) // UserCell
```

ReusableCell 结构可以自动生成一个 UUID，保证可重用标记的唯一性，并且 ReusableCell 将可重用标记和对应的 cell，进行了绑定。

用下面的初始化方法初始化 ReusableCell 时，可以指定 identifier 和 nib。如果在 nib 中指定了 identifier，初始化方法将会采用指定的 identifier。

```
public init(identifier: String? = nil, nib: UINib? = nil)
```

collectionView 的 `register` 和 `dequeue` 方法由 ReusableKit 扩展而来，在方法内容，就是直接调用的原生的方法：

```
/// Registers a generic cell for use in creating new collection view cells.
public func register<Cell>(_ cell: ReusableCell<Cell>) {
    if let nib = cell.nib {
        self.register(nib, forCellWithReuseIdentifier: cell.identifier)
    } else {
        self.register(Cell.self, forCellWithReuseIdentifier: cell.identifier)
    }
}

/// Returns a generic reusable cell located by its identifier.
public func dequeue<Cell>(_ cell: ReusableCell<Cell>, for indexPath: IndexPath) -> Cell {
    return self.dequeueReusableCell(withReuseIdentifier: cell.identifier, for: indexPath) as! Cell
}
```

## 用法

框架作者建议将可重用的类型定义到一个 enum 或 struct 中的静态常量。下面是作者的示例：

### UITableView

```
// 1. define
enum Reusable {
  static let headerView = ReusableCell<SectionHeaderView>()
  static let userCell = ReusableCell<UserCell>()
}

// 2. register
tableView.register(Reusable.headerView)
tableView.register(Reusable.userCell)

// 3. dequeue
tableView.dequeue(Reusable.headerView, for: indexPath)
tableView.dequeue(Reusable.userCell, for: indexPath)
```


### UICollectionView

```
// 1. define
enum Reusable {
  static let headerView = ReusableCell<SectionHeaderView>()
  static let photoCell = ReusableCell<PhotoCell>()
}

// 2. register
collection.register(Reusable.headerView, kind: .header)
collection.register(Reusable.photoCell)

// 3. dequeue
collection.dequeue(Reusable.headerView, kind: .header, for: indexPath)
collection.dequeue(Reusable.photoCell, for: indexPath)
```

### RxSwift 扩展

ReusableKit 支持 RxSwift 扩展：

```
users // Observable<[String]>
    .bind(to: collectionView.rx.items(Reusable.userCell)) { i, user, cell in
        cell.user = user
    }
```