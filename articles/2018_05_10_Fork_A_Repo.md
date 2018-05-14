# Fork 一个仓库

本文翻译自 GitHub 的帮助文档 [Fork A Repo](https://help.github.com/articles/fork-a-repo/)

## fork 一个仓库

fork 就是复制一个代码仓库。fork 一个代码仓库之后，你就可以任意的尝试去修改代码，而不会影响到源项目。

fork 通常用在你打算修改别人的项目，或者使用别人的项目作为实现自己想法的开端。

#### 修改别人的项目

修改别人项目的一个很好的例子就是修复 bug。当你发现一个 bug 时可以通过 issue 来记录，但是更好的方式是：

1. 拷贝那个项目
2. 将发现的 bug 进行修复
3. 提交一个 pull request 给项目的拥有者

如果项目的拥有者认同你做出的修改，他们可能会将你修复的内容加入原来的项目。

#### 使用别人的项目作为实现自己的想法的开端

开源的核心是我们通过分享代码来创建更好，更可靠的软件。

通过 fork 其他人的项目来创建一个公开的项目时，你需要确保包含一个[许可证文件](https://choosealicense.com/)，来说明你希望项目与其他人共享的方式。

关于开源的更多信息，特别是如何创建并维护一个开源项目，我们创建了[开源指南](https://opensource.guide/)，在创建和维护你的开源项目的仓库时，良好的实践这些建议，将会帮助你创建一个健康的开源社区。

### fork 一个实例仓库

fork 一个仓库仅仅需要两步操作。你可以通过我们创建了一个仓库来练习：

1. 在 GitHub 上，跳转到 [octocat/Spoon-Knife](https://github.com/octocat/Spoon-Knife) 仓库
2. 在页面的右上角，点击 `Fork`.

![右上角的 Fork 按钮](https://user-gold-cdn.xitu.io/2018/5/10/16348e320402416e?w=745&h=116&f=jpeg&s=20445)

就这样，现在你已经 fork 了一份原来 octocat/Spoon-Knife 的仓库。

### Keep your fork synced

当你 fork 一个项目时，可能是想在上游或原仓库的基础上做修改。如果是这种情况，那么定期的将你的 fork 和上游的仓库进行同步将是一个好习惯。你可以通过在命令行上使用 Git 来进行同步。你可以通过刚刚将 octocat/Spoon-Knife  仓库的 fork 来练习设置上游的仓库。

#### 第一步： 设置 Git
如果你从来没有设置过 Git，首先你需要[设置 Git](https://help.github.com/articles/set-up-git/)。同时不要忘记设置 Git 到 GitHub 的[身份验证](https://help.github.com/articles/set-up-git/#next-steps-authenticating-with-github-from-git)。

#### 第二步：在本地克隆你创建的 fork

现在，你已经对 Spoon-Knife 仓库进行了 fork，但是在你的电脑上还没有仓库中的文件。现在，在你的电脑上克隆一份你 fork 的仓库。

1. 在 GitHub 上，跳转到**你 fork 的** Spoon-Knife 的仓库。
2. 在仓库的名称下，点击 **Clone or download**   
    ![lone or download 按钮](https://user-gold-cdn.xitu.io/2018/5/10/16348e3c18ab261b?w=263&h=50&f=png&s=7783)
3. 使用 HTTPs 方式下的克隆，点击图标来拷贝克隆仓库的 URL。
    ![Clone URL button](https://user-gold-cdn.xitu.io/2018/5/10/16348e320419c4df?w=347&h=140&f=png&s=19433)
4. 打开终端
5. 输入 `git clone `，然后粘贴你在第 3 步拷贝的 URL。将下面的 `YOUR-USERNAME` 替换成你的 GitHub 的用户名之后，看起来就一样了:

    ```
    $ git clone https://github.com/YOUR-USERNAME/Spoon-Knife
    ```
6. 按下 Enter，将会创建你本地的克隆。

    ```
    git clone https://github.com/YOUR-USERNAME/Spoon-Knife
    Cloning into `Spoon-Knife`...
    remote: Counting objects: 10, done.
    remote: Compressing objects: 100% (8/8), done.
    remove: Total 10 (delta 1), reused 10 (delta 1)
    Unpacking objects: 100% (10/10), done.
    ```

现在，你有了一份对 Spoon-Knife 仓库 fork 后的本地拷贝。

#### 第三步：配置 Git 来同步你 fork 的源 Spoon-Knife 仓库

当你为修改源仓库而 fork 一个项目时，你可以通过配置 Git 来将上游仓库或者源仓库中修改的内容合并到你 fork 的仓库的本地克隆上。

1. 在 GitHub 上，跳转到 octocat/Spoon-Knife 仓库。
2. 在仓库的名称下面，点击 **Clone or download**。
    ![lone or download 按钮](https://user-gold-cdn.xitu.io/2018/5/10/16348e3c18ab261b?w=263&h=50&f=png&s=7783)
3. 使用 HTTPs 方式下的克隆，点击图标来拷贝克隆仓库的 URL。
    ![Clone URL button](https://user-gold-cdn.xitu.io/2018/5/10/16348e320419c4df?w=347&h=140&f=png&s=19433)
4. 打开终端
5. 改变路径到你在第二步克隆的 fork 的项目文件
    1. 跳转到你的 home 目录，仅需要输入 `cd`，而无需输入更多文字。
    2. 输入 `ls` 来列出当前目录下的文件和文件夹。
    3. 输入 `cd your_listed_directory` 进入列出的目录当中的一个。
    4. 输入 `cd ..` 跳转到上一个目录

6. 输入 `git remote -v` 后点击 Enter，你就会看见你 fork 的仓库配置的远程仓库。
    ```
    $ git remote -v
    origin  https://github.com/YOUR_USERNAME/YOUR_FORK.git (fetch)
    origin  https://github.com/YOUR_USERNAME/YOUR_FORK.git (push)
    ```
    
7. 输入 `git remote add upstream `，然后粘贴你在第二步拷贝的 URL，按 Enter。就像下面一样：
    ```
    $ git remote add upstream https://github.com/octocat/Spoon-Knife.git
    ```
    
8. 为了验证为你的 fork 设置的新的上游仓库，再输入一次 `git remote -v`。你将会看见你的 fork 的 URL 作为 `origin`，源仓库的 URL 作为 `upstream`。

    ```
    $ git remote -v
    origin    https://github.com/YOUR_USERNAME/YOUR_FORK.git (fetch)
    origin    https://github.com/YOUR_USERNAME/YOUR_FORK.git (push)
    upstream  https://github.com/ORIGINAL_OWNER/ORIGINAL_REPOSITORY.git (fetch)
    upstream  https://github.com/ORIGINAL_OWNER/ORIGINAL_REPOSITORY.git (push)
    ```

现在你可以用几个 Git 命令将你的 fork 和上游仓库保持同步。更多的信息，请看同步 fork（[原文](https://help.github.com/articles/syncing-a-fork/)，[译文](./2018_5_10_Syncing_a_fork.md)）。

#### 下一步
你能够对 fork 的修改包括：

1. **创建分支**：你可以在分支上构建新功能或者测试创意，而不会给主工程带来任何风险。
2. **创建 pull requests**：如果你希望将改动回馈到源仓库，可以提交 pull request 向原作者发请求，将你的 fork 合并到他们的仓库。

## 发现更多的仓库去 fork

fork 一个仓库然后开始给项目做贡献。你可以 fork 任何公开的仓库，或者任何你能访问的私有仓库。更多的信息，请看 [About forks](https://help.github.com/articles/about-forks/)。

你可以浏览[探索页](https://github.com/explore)去发现项目，然后给开源的仓库做贡献。更多的信息，请看[Finding open source projects on GitHub](https://help.github.com/articles/finding-open-source-projects-on-github/)。










