# UISearchController 定制UI（Swift）

> 以下内容是在 Swift 4.0，iOS 11 下的运行结果

### 默认样式
初始化一个 UISearchController，并将 searchBar 设置为 tableView 的 headerView 时，如以下代码：
```
let searchController = UISearchController.init(searchResultsController: nil)
tableView.tableHeaderView = searchController.searchBar
```
此时的样式为：

| 默认样式 | 高亮 | 
| :--: | :--: |
| ![1][1]  | ![0][0] |


### 自定义
下面我们通过修改 searchController 的 searchBar 属性来调整样式。

##### 1. searchBarStyle
搜索框样式
```
public enum UISearchBarStyle : UInt {    
    case `default` // 默认样式，和 UISearchBarStyleProminent 一样
    case prominent // 显示背景，常用在my Mail, Messages and Contacts
    case minimal // 不显示背景，系统自带的背景色无效，自定义的有效，常用在Calendar, Notes and Music
}
```
用例：
```
let searchBar = searchController.searchBar
searchBar.searchBarStyle = .default
```

| searchBarStyle | 非活跃 | 活跃 | 
| :--: | :--: | :--: |
| default |  ![][1]  | ![][0] |
| prominent | ![][5]| ![][6] |
| minimal | ![][7] | ![][8] |

##### 2. tintColor
  风格颜色，可用于修改：
  - 输入框的光标颜色
  - 取消按钮字体颜色
  - 选择栏被选中时的颜色

```
let searchBar = searchController.searchBar
searchBar.tintColor = .red
```

|  非活跃 | 活跃  | 
| :--: | :--: |
| ![][1] | ![][2] |


##### 3. barTintColor
搜索框背景颜色

```
let searchBar = searchController.searchBar
searchBar.barTintColor = .orange
```

| 非活跃| 活跃 | 
| :--: | :--: |
| ![][3] | ![][4] |

##### 4. backgroundImage
搜索框背景图片
> `createImage(_:size:)` 方法为创建一个指定颜色，指定 size 的图片。

```
let searchBar = searchController.searchBar
searchBar.backgroundImage = self.createImage(UIColor.red, size: CGSize.init(width: 200, height: 100))
```

| 非活跃 | 活跃 | 
| :--: | :--: |
| ![][21] | ![][22] |

##### 5. 设置（获取）搜索框背景图片

可以通过以下方式设置（获取）搜索框背景图片：

```
// 设置
// Use UIBarMetricsDefaultPrompt to set a separate backgroundImage for a search bar with a prompt
func setBackgroundImage(_ backgroundImage: UIImage?, for barPosition: UIBarPosition, barMetrics: UIBarMetrics) 
// 获取
open func backgroundImage(for barPosition: UIBarPosition, barMetrics: UIBarMetrics) -> UIImage?
```

```
public enum UIBarMetrics : Int {
    case `default`
    case compact
    case defaultPrompt // Applicable only in bars with the prompt property, such as UINavigationBar and UISearchBar
    case compactPrompt

    @available(iOS, introduced: 5.0, deprecated: 8.0, message: "Use UIBarMetricsCompact instead")
    public static var landscapePhone: UIBarMetrics { get }

    @available(iOS, introduced: 7.0, deprecated: 8.0, message: "Use UIBarMetricsCompactPrompt")
    public static var landscapePhonePrompt: UIBarMetrics { get }
}

@available(iOS 7.0, *)
public enum UIBarPosition : Int {
    case any

    case bottom // The bar is at the bottom of its local context, and directional decoration draws accordingly (e.g., shadow above the bar).

    case top // The bar is at the top of its local context, and directional decoration draws accordingly (e.g., shadow below the bar)

    case topAttached // The bar is at the top of the screen (as well as its local context), and its background extends upward—currently only enough for the status bar.
}
```
用例：
```
let searchBar = searchController.searchBar
searchBar.setBackgroundImage(createImage(.blue, size: CGSize.init(width: 20, height: 20)), for: .any, barMetrics: .default)
```
| 默认样式 | 高亮 | 
| :--: | :--: |
| ![][31] | ![][32] |

##### 6. 文本框的背景图片
```
open func setSearchFieldBackgroundImage(_ backgroundImage: UIImage?, for state: UIControlState)

open func searchFieldBackgroundImage(for state: UIControlState) -> UIImage?
```

```
let searchBar = searchController.searchBar
searchBar.setSearchFieldBackgroundImage(createImage(UIColor.yellow, size: CGSize.init(width: 200, height: 40)), for: .normal)
```
| 默认样式 | 高亮 | 
| :--: | :--: |
| ![][35] | ![][36] |

##### 7. barStyle
搜索框风格 barStyle 的类型为 UIBarStyle，定义如下：

```
public enum UIBarStyle : Int {
    case `default`
    case black
}
```
用例：
```
let searchBar = searchController.searchBar
searchBar.barStyle = .black
```

| barStyle | 非活跃 | 活跃 | 
| :--: | :--: | :--: |
| default | ![1][1]  | ![0][0] |
| black | ![9][9] | ![10][10]  |

##### 8. showsBookmarkButton
是否显示搜索框右侧的**图书按钮**。

```
open var showsBookmarkButton: Bool // default is NO
```

| barStyle | 非活跃 | 活跃 | 
| :--: | :--: | :--: |
| false | ![][1]  | ![][0] |
| true | ![][11] | ![][12] |

##### 9. showsCancelButton
是否显示搜索框右侧的**取消按钮**。

```
open var showsCancelButton: Bool // default is NO
```

| showsCancelButton | 默认样式 | 高亮 | 
| :--: | :--: | :--: |
| false | ![][1]  | ![][0] |
| true | ![][13] | ![][14] |

##### 10. showsSearchResultsButton
是否显示搜索框右侧的**搜索结果按钮**：

```
open var showsSearchResultsButton: Bool // default is NO
```
| showsSearchResultsButton | 非活跃 | 活跃 | 
| :--: | :--: | :--: |
| false | ![][1]  | ![][0] |
| true | ![][15] | ![][16] |

##### 11. isSearchResultsButtonSelected
设置搜索结果按钮为选中状态：
```
open var isSearchResultsButtonSelected: Bool // default is NO
```
用例：
```
let searchBar = searchController.searchBar
searchBar.showsSearchResultsButton = true
searchBar.isSearchResultsButtonSelected = true
```
| isSearchResultsButtonSelected | 非活跃 | 活跃 | 
| :--: | :--: | :--: |
| false | ![][15] | ![][16] |
| true | ![][17]  | ![][18] |

##### 12. searchFieldBackgroundPositionAdjustment

设置输入框背景偏移量：
```
open var searchFieldBackgroundPositionAdjustment: UIOffset
```

用例：

```
let searchBar = searchController.searchBar
searchBar.searchFieldBackgroundPositionAdjustment = UIOffset.init(horizontal: 16, vertical: 16)
```

|  | 默认样式 | 高亮 | 
| :--: | :--: | :--: |
| 设置前 | ![][1]  | ![][0] |
| 设置后 | ![][25] | ![][26] |

##### 13. searchTextPositionAdjustment
设置输入框文本偏移量：

```
open var searchTextPositionAdjustment: UIOffset
```

用例：

```
let searchBar = searchController.searchBar
searchBar.searchTextPositionAdjustment = UIOffset.init(horizontal: 16, vertical: 16)
```
|  | 默认样式 | 高亮 | 
| :--: | :--: | :--: |
| 设置前 | ![][1]  | ![][0] |
| 设置后 | ![][27] | ![][28] |

##### 14. 设置（获取）搜索框的图标
可以设置（获取）的搜索框图标包括：
- 搜索图标
- 清除输入的文字的图标
- 图书图标
- 搜索结果列表图标

```
open func setImage(_ iconImage: UIImage?, for icon: UISearchBarIcon, state: UIControlState)

open func image(for icon: UISearchBarIcon, state: UIControlState) -> UIImage?
```
用例：
```
let searchBar = searchController.searchBar
searchBar.showsBookmarkButton = true

let searchImage = self.createImage(.red, size: CGSize.init(width: 20, height: 20))
let clearImage = self.createImage(.yellow, size: CGSize.init(width: 20, height: 20))
let bookmarkImage = self.createImage(.blue, size: CGSize.init(width: 20, height: 20))
let resultsListImage = self.createImage(.orange, size: CGSize.init(width: 20, height: 20))

searchBar.setImage(searchImage, for: .search, state: .normal)
searchBar.setImage(clearImage, for: .clear, state: .normal)
searchBar.setImage(bookmarkImage, for: .bookmark, state: .normal)
searchBar.setImage(resultsListImage, for: .resultsList, state: .normal)
```
| 默认样式 | 高亮输入空白 | 高亮输入内容 | 
| :--: | :--: | :--: |
| ![][37] | ![][38] | ![][39] |

> 搜索结果列表图标在什么条件下会显示呢？我没有试出来。

##### 15. 设置（获取）搜索框的图标的偏移量

除了可以设置（获取） 14 中的图片，还可以设置（获取）的偏移量。

```
open func setPositionAdjustment(_ adjustment: UIOffset, for icon: UISearchBarIcon)

open func positionAdjustment(for icon: UISearchBarIcon) -> UIOffset
```
用例：
```
let searchBar = searchController.searchBar
searchBar.setPositionAdjustment(UIOffset.init(horizontal: 10, vertical: 10), for: .search)
```

| 默认样式 | 高亮 | 
| :--: | :--: | 
| ![][44] | ![][45] |
 
##### 16. 显示（隐藏）取消按钮
可以用以下方法设置显示（隐藏）取消按钮：

```
open func setShowsCancelButton(_ showsCancelButton: Bool, animated: Bool)
```

当我们希望彻底隐藏掉取消按钮的时候，应该怎么做呢？经过测试发现，只有在 `UISearchController` 的 `delegate` 中的 `didPresentSearchController(_)` 实现内调用可以实现隐藏取消按钮。

```
extension ViewController: UISearchControllerDelegate {
    func didPresentSearchController(_ searchController: UISearchController) {
        searchController.searchBar.setShowsCancelButton(false, animated: false)
    }
}
```
效果如下：
![][29]

可以发现取消按钮先显示了一下，然后隐藏了，效果并不理想。如果想彻底隐藏取消按钮，有一种方法是继承 `UISearchController` 和 `UISearchBar` 实现自定义。代码如下：

```
// 自定义 UISearchBar 
class CustomSearchBar: UISearchBar {
    override func layoutSubviews() {
        super.layoutSubviews()
        setShowsCancelButton(false, animated: false)
    }
}

// 自定义 UISearchController
class CustomSearchController: UISearchController {

    lazy var _searchBar: CustomSearchBar = { [unowned self] in
        let result = CustomSearchBar(frame: CGRect.zero)
        result.delegate = self
        return result
    }()
    
    override var searchBar: UISearchBar {
        return _searchBar
    }
}

extension CustomSearchController: UISearchBarDelegate {
    
}
```
使用自定义的 `CustomSearchController` 可以完全隐藏取消按钮，效果如下：
![][30]

##### 17. 设置取消按钮的名称
可以通过以下几个方法修改取消按钮的名称：

**方法一：**
```
let searchBar = searchController.searchBar
searchBar.setValue("Done", forKey:"_cancelButtonText")
```

**方法二：**
```
UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).title = "Done"
```

**方法三：**
```
let searchBar = searchController.searchBar
searchBar.showsCancelButton = true
let cancelButton = searchBar.value(forKey: "cancelButton") as? UIButton
cancelButton?.setTitle("Done", for: .normal)
```
> 注意方法三的设置顺序，需要先设置 showsCancelButton 为 true，这种方式的问题在于 cancelButton 一开始就要被设置为显示。

---

##### 18. 搜索框附属分栏条
在搜索框下面可以显示**搜索框附属分栏条**。
用例：
```
let searchBar = searchController.searchBar
searchBar.showsScopeBar = true
// 选择按钮视图的按钮标题
searchBar.scopeButtonTitles = ["One", "Two", "Three"]
// 选中的选择按钮下标值，默认值为 0，如果超出索引范围则会被忽略
searchBar.selectedScopeButtonIndex = 1
```
| 默认样式 | 高亮 | 
| :--: | :--: |
| ![][19] | ![][20] |

##### 19. 搜索框附属分栏条——背景颜色
可以通过通过 `scopeBarBackgroundImage` 设置搜索框附属分栏条的背景颜色
```
open var scopeBarBackgroundImage: UIImage?
```
用例（注意以下代码的顺序可能会产生不同的效果）：

```
let searchBar = searchController.searchBar
searchBar.showsScopeBar = true
// 选择按钮视图的按钮标题
searchBar.scopeButtonTitles = ["One", "Two", "Three"]
// 选中的选择按钮下标值，默认值为 0，如果超出索引范围则会被忽略
searchBar.selectedScopeButtonIndex = 1
searchBar.scopeBarBackgroundImage = self.createImage(UIColor.yellow, size: CGSize.init(width: 200, height: 100))
```
| 默认样式 | 高亮 | 
| :--: | :--: |
| ![][23] | ![][24] |


##### 20. 搜索框附属分栏条——按钮的背景图片

用以下方法可以设置（获取）搜索框附属分栏条按钮的背景图片：

```
open func setScopeBarButtonBackgroundImage(_ backgroundImage: UIImage?, for state: UIControlState)

open func scopeBarButtonBackgroundImage(for state: UIControlState) -> UIImage?
```
用例：
```
let searchBar = searchController.searchBar
searchBar.showsScopeBar = true
// 选择按钮视图的按钮标题
searchBar.scopeButtonTitles = ["One", "Two", "Three"]
// 选中的选择按钮下标值，默认值为 0，如果超出索引范围则会被忽略
searchBar.selectedScopeButtonIndex = 1
searchBar.scopeBarBackgroundImage = self.createImage(UIColor.yellow, size: CGSize.init(width: 200, height: 100))
searchBar.setScopeBarButtonBackgroundImage(createImage(.orange, size: CGSize.init(width: 20, height: 20)), for: .normal)
```
| 默认样式 | 高亮 | 
| :--: | :--: |
| ![][33] | ![][34] |


##### 21. 搜索框附属分栏条——按钮的分割线图片

可以用以下方法设置（获取）搜索框附属分栏条按钮的分割线图片：

```
open func setScopeBarButtonDividerImage(_ dividerImage: UIImage?, forLeftSegmentState leftState: UIControlState, rightSegmentState rightState: UIControlState)

open func scopeBarButtonDividerImage(forLeftSegmentState leftState: UIControlState, rightSegmentState rightState: UIControlState) -> UIImage?
```
用例：
```
let searchBar = searchController.searchBar
searchBar.showsScopeBar = true
// 选择按钮视图的按钮标题
searchBar.scopeButtonTitles = ["One", "Two", "Three"]
// 选中的选择按钮下标值，默认值为 0，如果超出索引范围则会被忽略
searchBar.selectedScopeButtonIndex = 1
searchBar.setScopeBarButtonDividerImage(createImage(.red, size: CGSize.init(width: 10, height: 20)), forLeftSegmentState: .normal, rightSegmentState: .normal)
```

| 默认样式 | 高亮 | 
| :--: | :--: | 
| ![][40] | ![][41] |

##### 22. 搜索框附属分栏条——按钮的标题样式
可以用以下方法设置（获取）搜索框附属分栏条按钮的标题样式：

```
open func setScopeBarButtonTitleTextAttributes(_ attributes: [String : Any]?, for state: UIControlState)

open func scopeBarButtonTitleTextAttributes(for state: UIControlState) -> [String : Any]?
```
用例：
```
let searchBar = searchController.searchBar
searchBar.showsScopeBar = true
// 选择按钮视图的按钮标题
searchBar.scopeButtonTitles = ["One", "Two", "Three"]
// 选中的选择按钮下标值，默认值为 0，如果超出索引范围则会被忽略
searchBar.selectedScopeButtonIndex = 1
searchBar.setScopeBarButtonTitleTextAttributes([NSAttributedStringKey.font.rawValue : UIFont.systemFont(ofSize: 20), NSAttributedStringKey.foregroundColor.rawValue : UIColor.red], for: .normal)
searchBar.setScopeBarButtonTitleTextAttributes([NSAttributedStringKey.font.rawValue : UIFont.systemFont(ofSize: 24), NSAttributedStringKey.foregroundColor.rawValue : UIColor.yellow], for: .selected)
```

| 默认样式 | 高亮 | 
| :--: | :--: | 
| ![][42] | ![][43] |

--- 
##### 23. 搜索顶部提示
在搜索框顶部可以通知 prompt 设置提示信息。

比如：

```
let searchBar = searchController.searchBar
searchBar.prompt = "非活跃"
```

可以在 searchBar 的代理里修改 prompt 的内容，例如：

```
extension ViewController: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.prompt = "开始编辑"
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.prompt = "取消编辑"
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchBar.prompt = "当前输入:\(searchText)"
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.prompt = "点击取消"
    }
}
```

效果如下

| 非活跃 | 开始编辑 | 输入内 | 取消编辑 | 
| :--: | :--: | :--: | :--: | 
| ![][46] | ![][47] | ![][48] | ![][49] | 

可以发现顶部的提示文字和输入框重合了。所以向下调整一下输入框的偏移量。 
prompt 为空时 searchBar 的高度为 56，不为空时 searchBar 的高度为 75，所以我们将输入框向下调整 19：

```
searchBar.searchFieldBackgroundPositionAdjustment = UIOffset.init(horizontal: 0, vertical: 19)
```

效果如下

| 非活跃 | 开始编辑 | 输入内 | 取消编辑 | 
| :--: | :--: | :--: | :--: | 
| ![][50] | ![][51] | ![][52] | ![][53] | 

可以发现还是有问题：
1. 取消按钮和输入框不在一行上了
2. 如果 prompt 有时有值，有时为空，searchBar 的高度无法灵活改变。

这些问题暂时没有找到解决方案。

##### 其他待解决问题
1. isTranslucent 没有发现效果
2. inputAssistantItem
3. inputAccessoryView
4. 搜索结果列表图标在什么条件下会显示

---

[0]:../images/SearchBar/0.png
[1]:../images/SearchBar/1.png
[2]:../images/SearchBar/2.png
[3]:../images/SearchBar/3.png
[4]:../images/SearchBar/4.png
[5]:../images/SearchBar/5.png
[6]:../images/SearchBar/6.png
[7]:../images/SearchBar/7.png
[8]:../images/SearchBar/8.png
[9]:../images/SearchBar/9.png

[10]:../images/SearchBar/10.png
[11]:../images/SearchBar/11.png
[12]:../images/SearchBar/12.png
[13]:../images/SearchBar/13.png
[14]:../images/SearchBar/14.png
[15]:../images/SearchBar/15.png
[16]:../images/SearchBar/16.png
[17]:../images/SearchBar/17.png
[18]:../images/SearchBar/18.png
[19]:../images/SearchBar/19.png

[20]:../images/SearchBar/20.png
[21]:../images/SearchBar/21.png
[22]:../images/SearchBar/22.png
[23]:../images/SearchBar/23.png
[24]:../images/SearchBar/24.png
[25]:../images/SearchBar/25.png
[26]:../images/SearchBar/26.png
[27]:../images/SearchBar/27.png
[28]:../images/SearchBar/28.png
[29]:../images/SearchBar/29.png

[30]:../images/SearchBar/30.png
[31]:../images/SearchBar/31.png
[32]:../images/SearchBar/32.png
[33]:../images/SearchBar/33.png
[34]:../images/SearchBar/34.png
[35]:../images/SearchBar/35.png
[36]:../images/SearchBar/36.png
[37]:../images/SearchBar/37.png
[38]:../images/SearchBar/38.png
[39]:../images/SearchBar/39.png

[40]:../images/SearchBar/40.png
[41]:../images/SearchBar/41.png
[42]:../images/SearchBar/42.png
[43]:../images/SearchBar/43.png
[44]:../images/SearchBar/44.png
[45]:../images/SearchBar/45.png
[46]:../images/SearchBar/46.png
[47]:../images/SearchBar/47.png
[48]:../images/SearchBar/48.png
[49]:../images/SearchBar/49.png

[50]:../images/SearchBar/50.png
[51]:../images/SearchBar/51.png
[52]:../images/SearchBar/52.png
[53]:../images/SearchBar/53.png















