# 同步 fork(Syncing a fork)

> 当我们 fork 一个开源仓库之后，应该怎样将上游的仓库同步到我们的 fork 上呢？
以下文章翻译自 GitHub 的帮助文档 [Syncing a fork](https://help.github.com/articles/syncing-a-fork/)。

同步一个仓库的 fork 可以使它和上游仓库的最新状态保持同步。

在将上游仓库同步到你的 fork 之前，你必须在 Git 上[配置上游仓库的远程站点](https://help.github.com/articles/configuring-a-remote-for-a-fork/)。同步的步骤如下：

1. 打开终端
2. 变更当前路径到你的本地工程
3. 从上游仓库中获取分支和它们各自的 commits。将 `master` 上的 commit 存储在本地分支 `upstream/master` 上。

    ```
    $ git fetch upstream
    remote: Counting objects: 75, done.
    remote: Compressing objects: 100% (53/53), done.
    remote: Total 62 (delta 27), reused 44 (delta 9)
    Unpacking objects: 100% (62/62), done.
    From https://github.com/ORIGINAL_OWNER/ORIGINAL_REPOSITORY
     * [new branch]      master     -> upstream/master
    ```

4. 切换到你 fork 的本地 `master` 分支上，

    ```
    git checkout master
    Switched to branch 'master'
    ```

5. 将 `upstream/master` 上的改动合并到你本地的 `master` 分支上。这将上游仓库同步到你的 fork 的 `master` 分支上，而不会丢失你在本地的修改。
    ```
    git merge upstream/master
    Updating a422352..5fdff0f
    Fast-forward
     README                    |    9 -------
     README.md                 |    7 ++++++
     2 files changed, 7 insertions(+), 9 deletions(-)
     delete mode 100644 README
     create mode 100644 README.md
    ```
    如果你本地没有任何提交，Git 将改为执行 `fast-forward`：
    ```
    git merge upstream/master
    Updating 34e91da..16c56ad
    Fast-forward
     README.md                 |    5 +++--
     1 file changed, 3 insertions(+), 2 deletions(-)
    ```

> 提示：同步你的 fork 仅仅只是更新了本地上对仓库的拷贝。如果要更新 GitHub 上你的 fork，则必须推送这些更改。
