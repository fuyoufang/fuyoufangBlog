# 处理 UITextInput 的文本中被标记的内容

在 APP 中，经常会遇到需要用户输入文字的地方，比如设置用户名、填写简介、搜索关键字。在这些场景中，又会有进一步的需求：

- 限制用户输入的文本长度
- 根据用户当前输入的文本推荐关键词
- 实时保存用户的输入

当用户使用 iOS 系统自带的键盘输入汉字时，时常会出现输入框中带有被标记（marked）的文本。比如用户想输入 **我最优秀**，界面如下：

![](./../images/UITextInput_mark.png)

这时获取到 UITextInput 的文本内容是：**wo zui you xiu**。

显然这时我们还无法确认用户究竟要输入的文本内容，此时将当前的文本内容进行长度判断，或者进行网络请求都是不恰当的。所以我们要将当前被标记的内容排除掉。

UITextInput 有一个 `markedTextRange` 的属性，官方的注释为：

> If text can be selected, it can be marked. Marked text represents provisionally inserted text that has yet to be confirmed by the user.  It requires unique visual treatment in its display.  If there is any marked text, the selection, whether a caret or an extended range, always resides witihin.
> 
> Setting marked text either replaces the existing marked text or, if none is present, inserts it from the current selection. 

> 如果文本内容可以进行选中，则可以对其进行标记。 **标记的文本** 表示尚未被用户确认之前临时插入的文本。 它需要在屏幕上进行独特的视觉处理。 被标记的文本无论是在中间插入的，还是在后面添加的，它的选中范围都在文本范围之内。
> 
> 如果设置了被标记的文本内容，则将替换当前的被标记的文本，如果不设置，则将被标记的文本直接插入到当前选中的位置。

现在就可以通过 `markedTextRange` 属性将被标记的（Marked）内容移除，获取到用户已经确定好的内容。在 [RxTodo](https://github.com/devxoul/RxTodo) 中采用了下面的实现方法：

```
func nonMarkedText(_ textInput: UITextInput) -> String? {
    let start = textInput.beginningOfDocument
    let end = textInput.endOfDocument
    
    guard let rangeAll = textInput.textRange(from: start, to: end),
        let text = textInput.text(in: rangeAll) else {
            return nil
    }
    
    guard let markedTextRange = textInput.markedTextRange else {
        return text
    }
    
    guard let startRange = textInput.textRange(from: start, to: markedTextRange.start),
        let endRange = textInput.textRange(from: markedTextRange.end, to: end) else {
            return text
    }
    
    return (textInput.text(in: startRange) ?? "") + (textInput.text(in: endRange) ?? "")
}
```

