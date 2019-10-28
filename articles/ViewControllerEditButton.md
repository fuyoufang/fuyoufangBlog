# UIViewController 的 editButtonItem

在 RxSwift 的实例 `TableViewWithEditingCommands` 当中，有下面的代码：

``` swift
override func viewDidLoad() {
    super.viewDidLoad()
    self.navigationItem.rightBarButtonItem = self.editButtonItem
}
```

点击 ViewController 的 editButtonItem 的定义的时候，才发现 UIViewController 的扩展，原来 UIViewController 已经实现了 editButtonItem 的相关实现。

``` swift
extension UIViewController {

    open var isEditing: Bool

    open func setEditing(_ editing: Bool, animated: Bool)

    open var editButtonItem: UIBarButtonItem { get }
}

```

在需求比较简单的时候，就可以直接使用 UIViewController 的这个扩展当中的 editButtonItem。override UIViewController 中的 setEditing 方法，就可获取到编辑状态的更改。

``` swift
class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        debugPrint("\(editing ? "开始编辑" : "结束编辑")")
    }

}

```

| edit | done | 
| :--: | :--: |
| ![1][0]  | ![0][1] |


---

[0]:../images/editButtonItem/editButtonItem_edit.png
[1]:../images/editButtonItem/editButtonItem_done.png
