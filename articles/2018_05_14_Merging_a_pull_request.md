# 合并 pull request（Merging a pull request）

> 本文翻译自 GitHub 帮助文档 [Merging a pull request](https://help.github.com/articles/merging-a-pull-request)。

当工作完成之后，就可以将 pull request 合并到上游分支上。任何对仓库有 push 权限的人都可以将其合并。

如果在合并 pull request 时没有任何冲突，你就可以在 GitHub 上直接合并。如果在合并 pull request 时有冲突，或者你想在合并之前先测试一下，你可以先在[本地查看 pull request](https://help.github.com/articles/checking-out-pull-requests-locally/)，然后通过命令行进行合并。

在考虑之后，如果不想把话题分支（pull request 所在的分支）上的改动合并到上游分支上，你可以不做任何合并，直接[关闭 pull request](https://help.github.com/articles/closing-a-pull-request/)。

## 设置审查（Required reviews）
在 pull request 合并到[受保护的分支](https://help.github.com/articles/about-protected-branches/)之前，仓库管理员可以要求必须经过指定数量的有 write 或 admin 权限的人或者特定代码所有者的审查。

当需要审查时，任何有仓库权限的人都可以批准 pull request 的改动。当有具有仓库 write 或 admin 权限的审核员同意修改，并且同意的人数达到指定的数量之后才能将 pull request 进行合并。 关于仓库的权限等级，可以查看[组织中仓库的权限等级](https://help.github.com/articles/repository-permission-levels-for-an-organization/)。如果需要指定代码的所有者进行审查，而且 pull request 改动了指定所有者的代码，则需要该所有者的批准。

如果一个人的改动无法被审查，或者一个 pull request 在审查之后又做了明显的改动，则仓库管理员或者任何有 write 权限的人都可以拒绝审查。更多信息，请看[拒绝 pull request 的审查](https://help.github.com/articles/dismissing-a-pull-request-review/)。

当一个 pull request 满足所有要求的审核之后，如果有其他的 pull requests 的头部分支（header branch）和它指向了相同的提价（commit），并且这些 pull requests 正处于待审核或拒绝审核的状态，这时你依然无法合并。在能够合并之前，需要一个具有 write 或 admin 权限的人审核通过或者拒绝这些阻塞的 pull requests。

## 在 GitHub 上合并一个 pull request 
1. 在你的仓库名称下面，点击 **Pull requests**。
![Pull requests](https://help.github.com/assets/images/help/repository/repo-tabs-pull-requests.png)
3. 在 “Pull Requests” 列表里，点击你想合并的 pull request。
4. 当合并选项在你的仓库中处于可用状态时，你可以：
	- [将所有提交合并到基础分支](https://help.github.com/articles/about-pull-request-merges/)：通过点击 **Merge pull request**。如果没有展示 **Merge pull request** 选项，则点击合并下拉菜单，然后选择 **Create a merge commit**。
	![Merge pull request](https://help.github.com/assets/images/help/pull_requests/pullrequest-mergebutton.png)
	- [压缩合并 pull request 的提交](https://help.github.com/articles/about-pull-request-merges/#squash-and-merge-your-pull-request-commits)：通过合并下拉菜单，选择 **Squash and merge**，然后点击 **Squash and merge** 按钮。
	![Squash and merge](https://help.github.com/assets/images/help/pull_requests/select-squash-and-merge-from-drop-down-menu.png)
	- [将提交单独变基到基础分支上](https://help.github.com/articles/about-pull-request-merges/#rebase-and-merge-your-pull-request-commits)：通过合并下拉菜单，选择 **Rebase and merge**，然后点击 **Rebase and merge** 按钮。
	 ![Rebase and merge](https://help.github.com/assets/images/help/pull_requests/select-rebase-and-merge-from-drop-down-menu.png)
	> 注意：变基合并将会更新提交者信息，并创建新的提交 SHAs。更多的信息，请查看 [pull request 的合并](https://help.github.com/articles/about-pull-request-merges/#rebase-and-merge-your-pull-request-commits)。

4. 如果你在第三步点击了 **Merge pull request** 或者 **Squash and merge**，输入提交信息，或者使用默认的信息，然后在提交信息的输入框下面点击 **Confirm merge** 或者 **Confirm squash and merge** 进行合并。
![pullrequest-commitmessage](https://help.github.com/assets/images/help/pull_requests/merge_box/pullrequest-commitmessage.png)

5. 如果你在第三步点击了 **Rebase and merge**，则点击 **Confirm rebase and merge** 进行合并。
6. 推荐[删除这个分支](https://help.github.com/articles/deleting-and-restoring-branches-in-a-pull-request/)，这可以使仓库的分支列表保持简洁。
 
使用压缩（squashed）或者变基提交（rebased commits）的方式合并 pull requests 时使用 `fast-forward` 选项，其它的则通过使用[ `--no-ff` 选项](https://git-scm.com/docs/git-merge#_fast_forward_merge)进行合并。

你可以在 pull request 或者提交信息中使用关键字来关闭相应的 issues。更多的信息，可以查看[使用关键字关闭 issues](https://help.github.com/articles/closing-issues-using-keywords/)。
