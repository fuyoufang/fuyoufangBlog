# RxTodo 项目的结构

[RxTodo](https://github.com/devxoul/RxTodo) 是一个 RxSwift 示例项目，该项目简单，从这个项目中可以学习到 RxSwift 在项目中的实际使用。同时，RxTodo 又使用了几个第三方库，可以学习到 RxSwift 和其他框架的配合使用。

首页如下：

![RxTodo](./../images/RxTodo/RxTodo_list.png)


该首页的控制器为 TaskListViewController。

### TaskListViewController

关联的 Reactor 为 TaskListViewReactor 

### TaskListViewReactor

TaskListViewReactor 中的 state 定义如下：

struct State {
    var isEditing: Bool
    var sections: [TaskListSection]
}

isEditing 标记 tableView 的编辑状态，sections 记录 tableView 的 section 的信息。

### TaskListSection    

TaskListSection 是 SectionModel<Void, TaskCellReactor> 的别名。所以 tableViewCell 的 Reactor 是 TaskCellReactor。

### TaskCellReactor 

TaskCellReactor 中的 state 类型为 Task。也就是说 Task 定义了 tableViewCell 的所有 UI 信息。

```
let initialState: Task
```

### Task

Task 的类型为 struct。Task 中定义的属性如下：

```
struct Task: ModelType, Identifiable {   
    var id: String = UUID().uuidString
    var title: String
    var memo: String?
    var isDone: Bool = false
}
```

### TaskCell

TaskCell 和 TaskCellReactor 进行绑定。

```
typealias Reactor = TaskCellReactor
func bind(reactor: Reactor) {
    ****
}

```

## 总结

RxTodo 的列表 view controller 结构如下：

1. 列表 view controller 和一个 Reacter 进行绑定，这个 Reacter 中使用数组存储列表对应的数据，数组中最内层的数据类型为 cell 对应的 Reactor。
1. 列表中的每个 cell 和一个 Reacter 进行绑定，

在 cell 对应的 state 发送改变的时候：

1. 首先 view controller 对应 Reacter 中数组发生更改，导致整个 tableView 进行刷新。
1. 其次，cell 对应 Reacter 发生更改，导致需要重新绑定，这时 cell 将会根据新的 Reactor 的 state 将所有 UI 进行设置。

感觉这种一个属性更改就要导致整个列表刷新的方式效率不高。可能作者是为了演示 RxSwift 的用法，降低代码阅读的难度，才没有更进一步的优化列表的刷新效率。


