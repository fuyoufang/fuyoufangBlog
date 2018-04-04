# 线程特有数据(Thread Specific Data)

在单线程程序中，我们经常要使用`全局变量`来实现多个函数间共享数据。在多线程环境下，由于数据空间是共享的，因此全局变量也为所有线程所共有。但有时在应用程序设计中有必要提供`线程私有`的全局变量，仅在某个线程中有效，但可以跨多个函数访问，这样每个线程访问它自己独立的数据空间，而不用担心和其它线程的同步访问。
> 比如：在程序中每个线程都使用同一个指针索引一个链表，并在多个函数内通过指针对链表进行操作，但是每个线程通过指针索引的链表都是自己独有的数据。

## 线程特有数据(Thread Specific Data)

这样在一个线程内部的各个函数都能访问、但其它线程不能访问的变量，我们就需要使用`线程局部静态变量`(Static memory local to a thread) 同时也可称之为`线程特有数据`（Thread-Specific Data 或 TSD），或者`线程局部存储`（Thread-Local Storage 或 TLS）。

`POSIX` 线程库提供了如下 API 来管理线程特有数据（TSD）：

#### 1. 创建 key
```
int pthread_key_create(pthread_key_t *key, void (*destructor)(void *))；
```
第一参数 `key` 指向 `pthread_key_t` 的对象的指针。请**注意**这里 `pthread_key_t` 的对象占用的空间是用户事先分配好的，`pthread_key_create` 不会动态生成 `pthread_key_t` 对象。
第二参数 `desctructor`，如果这个参数不为空，那么当每个线程结束时，系统将调用这个函数来释放绑定在这个键上的内存块。

#### 2. 动态数据初始化
有时我们在线程里初始化时，需要避免重复初始化。我们希望一个线程里只调用 `pthread_key_create` 一次，这时就要使用 `pthread_once`与它配合。

```
int pthread_once(pthread_once_t *once_control, void (*init_routine)(void))；
```
第一个参数 `once_control` 指向一个 `pthread_once_t` 对象，这个对象必须是常量 `PTHREAD_ONCE_INIT`，否则 `pthread_once` 函数会出现不可预料的结果。
第二个参数 `init_routine`，是调用的初始化函数，不能有参数，不能有返回值。
如果成功则返回0，失败返回非0值。

#### 3. 键与线程数据关联
创建完键后，必须将其与线程数据关联起来。关联后也可以获得某一键对应的线程数据。关联键和数据使用的函数为：
```
int pthread_setspecific(pthread_key_t *key, const void *value)；
```
第一参数 `key` 指向键。
第二参数 `value` 是欲关联的数据。
函数成功则返回0，失败返回非0值。

**注意：**用 `pthread_setspecific` 为一个键指定新的线程数据时，并不会主动调用析构函数释放之前的内存，所以调用线程必须自己释放原有的线程数据以回收内存。

#### 4. 获取键管理的线程数据 
获取与某一个键关联的数据使用函数的函数为：
```
void *pthread_getspecific(pthread_key_t *key);
```
参数 `key` 指向键。
如果有与此键对应的数据，则函数返回该数据，否则返回NULL。

#### 5. 删除一个键
删除一个键使用的函数为：
```
int pthread_key_delete(pthread_key_t key);
```
参数 `key` 为要删除的键。
成功则返回0，失败返回非0值。

**注意：**该函数将键设置为可用，以供下一次调用 `pthread_key_create()` 使用。它并不检查当前是否有线程正在使用该键对应的线程数据，所以它并不会触发函数 `pthread_key_create` 中定义的 `destructor` 函数，也就不会释放该键关联的线程数据所占用的内存资源，而且在将 `key` 设置为可用后，在线程退出时也不会再调用析构函数。所以在将 key 设置为可用之前，必须要确定:  
1. 所有线程已经析构 key 对应的线程变量（要么显示析构，要么线程退出）;
2. 不再使用该 key。 这两个条件一般难以确定，所以实际使用时一般也不会将一个 key 设置为可用.

## 线程特有数据(TSD)的实现

在 Linux 中每个进程有一个全局的数组 `__pthread_keys`，数组中存放着 称为 `key` 的结构体，定义类似如下：
```
struct pthread_key_struct {
    uintptr_t seq;
    void (*destructor)(void*);
} __pthread_keys[PTHREAD_KEYS_MAX];
```

![__pthread_keys 数组.png](https://upload-images.jianshu.io/upload_images/1879951-c36d36db3903f3f2.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

在 `key` 结构中 `seq` 为一个序列号，用来作为使用标志指示这个结构在数组中是否正在使用，初始化时被设为0，即表示`不在使用`。`destructor` 用来存放一个析构函数指针。
> 如果 `destructor` 不为空，在线程退出时，将 `key` 对应的 TSD 作为参数调用析构函数，以释放分配的缓存区。

`pthread_create_key` 会从数组中找到一个还未使用的 `key` 元素，将其序列号 `seq` 加1，并记录析构函数地址，并将 `key` 在数组 `__pthread_keys` 中的**下标**作为返回值返回。那么如何判断一个 `key` 正在使用呢？
```
#define KEY_UNUSED(seq) (((seq) & 1) == 0)
```
如果 `key` 的序列号 seq 为偶数则表示未分配，分配时将 seq 加1变成奇数，即表示正在使用。这个操作过程采用原子 CAS 来完成，以保证线程安全。在 `pthread_key_delete()` 时也将序列号 seq 加1，表示可以再被使用，通过序列号机制来保证回收的 `key` 不会被复用（复用 `key` 可能会导致线程在退出时可能会调用错误的析构函数）。但是一直加1会导致序列号回绕，还是会复用 `key`，所以调用 `pthread_create_key` 获取可用的 `key` 时会检查是否有回绕风险，如果有则创建失败。
```
#define KEY_USABLE(seq) (((uintptr_t)(seq)) < ((uintptr_t) ((seq) + 2)))
```

除了进程范围内的 `key` 结构数组外，系统还在进程中维护关于每个线程的控制块 TCB（用于管理寄存器，线程栈等），里面有一个 `pthread_key_data` 类型的数组。这个数组中的元素数量和进程中的 `key` 数组数量相等。`pthread_key_data` 的定义类似如下：
```
struct pthread_key_data {
    uintptr_t seq;
    void* data;
};
```

![线程的控制块 TCB](https://upload-images.jianshu.io/upload_images/1879951-a206c6b0d0e7b6ac.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

根据 `pthread_key_create()` 返回的可用的 `key` 在 `__pthread_keys` 数组中的下标， `pthread_setspecific()` 在 `pthread_key_data` 的数组 中定位相同下标的一个元素 `pthread_key_data`，并设置其序号 seq 设置为对应的 `key` 的序列号，数据指针 `data` 指向设置线程特有数据（TSD）的值。

`pthread_getspecific()` 用于将 `pthread_setspecific()` 设置的 `data` 取出。

![实现线程局部数据的结构图](https://upload-images.jianshu.io/upload_images/1879951-87e7698a238bc500.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)


线程退出时，`pthread_key_data` 中的序号 seq 用于判断该 key 是否仍在使用中（即与在 `__pthread_keys` 中的同一个下标对应的 key 的序列号 seq 是否相同），若是则将 `pthread_key_data` 中 data（即 线程特有数据 TSD）作为参数调用析构函数。

> `pthread_key_delete` 函数会将 key 的序列号 seq 加1，变成奇数（奇数表示该 key 可用），可能会使 key 的 seq 和 `pthread_key_data` 中的序号 seq 不相等，导致 `pthread_key_data` 中的线程私有数据无法释放。所有在通过 `pthread_key_delete` 释放一个 key 时，要保证线程特有数据已经释放。 

由于系统在每个进程中 `pthread_key_t` 类型的数量是有限的，所有在进程中并不能获取无限个 `pthread_key_t` 类型。Linux 中可以通过 PTHREAD_KEY_MAX（定义于 limits.h 文件中）或者系统调用 `sysconf(_SC_THREAD_KEYS_MAX)` 来确定当前系统最多支持多少个 `key`。 Linux 中默认是 1024 个 key，这对大多数程序来书已经够了。如果一个线程中有多个线程局部存储变量（TLS），通常可以将这些变量封装到一个数据结构中，然后使用封装后的数据结构和一个线程局部变量相关联，这样就能减少对键值的使用。


## 参考
https://blog.csdn.net/hustraiet/article/details/9857919
https://blog.csdn.net/hustraiet/article/details/9857919
https://blog.csdn.net/caigen1988/article/details/7901248
http://www.bidutools.com/?p=2443
https://spockwangs.github.io/blog/2017/12/01/thread-local-storage/
https://www.jianshu.com/p/71c2f80d7bd1
https://blog.csdn.net/cywosp/article/details/26469435
http://www.embeddedlinux.org.cn/emblinuxappdev/117.htm  

