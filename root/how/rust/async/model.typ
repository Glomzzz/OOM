#import "/lib/formal.typ": *

#show: formal-page.with(
  title: [为什么需要异步：阻塞、回调与无栈协程],
  description: [比较阻塞线程、回调状态机、有栈协程与无栈协程的资源模型，解释 Rust 选择基于轮询的无栈协程的原因．],
  date: [2026-10-15],
  author: [哈吉米4],
  parent: "/how/rust/async/index.typ",
)

处理高并发 I/O 时，程序的大部分时间都在等待外部事件：
等待网卡收到数据包，等待磁盘完成读取，或者等待定时器到期．
*异步机制*要解决的核心问题是：当一个任务因为等待外部事件而无法继续推进时，
怎样让出当前线程的计算资源，并在事件就绪后准确恢复到挂起前的位置．

= 阻塞线程与协作式切换

最直观的并发模型是“一个连接一个操作系统线程”．
当线程调用阻塞式的 `read` 系统调用而数据尚未到达时，
操作系统内核会将该线程移出运行队列，保存其寄存器与栈指针，再切换到其他就绪线程．

这种抢占式调度的优点是代码保持顺序结构：局部变量留在调用栈上，无需程序员手动管理．
但每个操作系统线程都需要独立的内核对象与固定或按页分配的调用栈（在 Linux 上默认通常为数兆字节，即便只统计实际触碰的物理页，每个活跃栈仍至少占用数千字节），
而且每次上下文切换都要跨越用户态与内核态边界．
当同时维持数万个大多处于空闲等待状态的连接时，内存与调度开销会成为瓶颈．

如果不在内核里挂起线程，而是让同一个线程在用户态交替服务多个任务，
时间轴上的行为就会从“等待时阻塞整个线程”变成“发起非阻塞操作后立即切换到其他就绪任务”：

#fig({
  import "@preview/cetz:0.3.4"
  cetz.canvas(length: 0.9cm, {
    import cetz.draw: *

    // Title labels
    content((-2.6, 3.3), [*阻塞模型（双线程）*])
    content((-2.6, 2.3), [线程 1（任务 A）])
    content((-2.6, 1.4), [线程 2（任务 B）])

    // Thread 1 timeline
    rect((0, 2.05), (2.0, 2.55), fill: blue.lighten(75%), stroke: 0.8pt + blue.darken(20%))
    content((1.0, 2.3), [计算 $A_1$])
    rect((2.0, 2.05), (5.6, 2.55), fill: gray.lighten(80%), stroke: (paint: gray.darken(10%), thickness: 0.8pt, dash: "dashed"))
    content((3.8, 2.3), [内核阻塞等待 I/O])
    rect((5.6, 2.05), (7.6, 2.55), fill: blue.lighten(75%), stroke: 0.8pt + blue.darken(20%))
    content((6.6, 2.3), [计算 $A_2$])

    // Thread 2 timeline
    rect((0.6, 1.15), (2.6, 1.65), fill: orange.lighten(75%), stroke: 0.8pt + orange.darken(20%))
    content((1.6, 1.4), [计算 $B_1$])
    rect((2.6, 1.15), (6.2, 1.65), fill: gray.lighten(80%), stroke: (paint: gray.darken(10%), thickness: 0.8pt, dash: "dashed"))
    content((4.4, 1.4), [内核阻塞等待 I/O])
    rect((6.2, 1.15), (8.2, 1.65), fill: orange.lighten(75%), stroke: 0.8pt + orange.darken(20%))
    content((7.2, 1.4), [计算 $B_2$])

    // Separator
    line((-4.4, 0.55), (10.2, 0.55), stroke: (paint: gray, thickness: 0.6pt, dash: "dotted"))

    // Async single thread
    content((-2.6, -0.1), [*异步模型（单线程）*])
    content((-2.6, -1.0), [工作线程])

    rect((0, -1.25), (2.0, -0.75), fill: blue.lighten(75%), stroke: 0.8pt + blue.darken(20%))
    content((1.0, -1.0), [计算 $A_1$])
    rect((2.0, -1.25), (4.0, -0.75), fill: orange.lighten(75%), stroke: 0.8pt + orange.darken(20%))
    content((3.0, -1.0), [计算 $B_1$])
    rect((4.0, -1.25), (6.0, -0.75), fill: gray.lighten(88%), stroke: (paint: gray, thickness: 0.7pt, dash: "dashed"))
    content((5.0, -1.0), [等待事件])
    rect((6.0, -1.25), (8.0, -0.75), fill: orange.lighten(75%), stroke: 0.8pt + orange.darken(20%))
    content((7.0, -1.0), [计算 $B_2$])
    rect((8.0, -1.25), (10.0, -0.75), fill: blue.lighten(75%), stroke: 0.8pt + blue.darken(20%))
    content((9.0, -1.0), [计算 $A_2$])

    // Axis arrow
    line((0, -2.0), (10.3, -2.0), mark: (end: "stealth"), stroke: 0.8pt)
    content((9.9, -2.4), [时间 $t$])
  })
})

上图中，单线程异步模型不会缩短单次 I/O 等待的物理时长，也不会让 $B_2$ 与 $A_2$ 在同一时刻并行执行；
它省下的是为每个等待中的任务维持独立内核线程与独立调用栈的成本．
要实现这种用户态切换，关键在于：*任务挂起时，原本保存在线程调用栈上的局部变量和执行位置放去哪里？*

= 有栈协程与无栈协程

围绕“执行状态保存在哪里”，程序语言演化出了两条路线：*有栈协程*与*无栈协程*．

*有栈协程*（如 Go 的 goroutine、Erlang 的进程或 C++ 的 fiber）为每个任务分配一块独立的用户态栈．
切换任务时，运行时只需切换栈指针与少量寄存器；
任务可以在任意深度的普通函数调用中直接挂起，因为整条调用链的栈帧都完好地保存在该任务私有的堆内存栈上．

然而，独立栈与系统级语言的约束存在两处冲突：

1. *栈大小的预测难题*：编译器在编译一个模块时，往往无法静态算出某个协程在运行期会调用多深的函数（尤其涉及动态分发或外部函数接口时）．
   如果预先分配固定大小的栈，设得太大浪费内存，设得太小则会栈溢出；
   如果像 Go 那样支持运行时动态扩缩栈或分段栈，则需要运行时介入栈检查，并且在调用 C 语言函数时必须切换到系统栈，还会使指向栈上变量的原始指针在栈搬迁后失效．
2. *零运行时开销的目标*：Rust 需要运行在没有操作系统、甚至没有堆分配器的裸机（`no_std`）环境中．
   强制引入管理用户态栈与调度器的语言级运行时，会违背“不为未使用的抽象付费”的设计约束．

因此，Rust 选择了*无栈协程*：不为任务分配独立的调用栈，
而是由编译器分析函数中哪些局部变量需要跨越*挂起点*（`.await`）存活，
将这些变量连同当前执行位置一起打包成一个普通的 Rust 结构体（状态机）．

#fig({
  import "@preview/fletcher:0.5.8" as fletcher: diagram, node, edge

  let box-node(pos, body, tint, width: 52mm) = node(
    pos,
    align(left, body),
    width: width,
    fill: tint.lighten(85%),
    stroke: 0.8pt + tint.darken(15%),
    corner-radius: 4pt,
    inset: 7pt,
  )

  diagram(
    spacing: (16mm, 8mm),
    edge-stroke: 0.8pt,
    node((0, 0), [*有栈协程（独立用户态栈）*], stroke: none),
    node((1, 0), [*无栈协程（内联状态机）*], stroke: none),

    box-node((0, 1), [
      *调用帧 1*：`read_header` \
      局部变量 `buf`, 返回地址 \
      #line(length: 100%, stroke: 0.5pt + blue.darken(20%))
      *调用帧 2*：`parse_frame` \
      局部变量 `len`, 返回地址 \
      #line(length: 100%, stroke: 0.5pt + blue.darken(20%))
      *预留未用栈空间* \
      （防溢出余量，或需动态扩容）
    ], blue),

    box-node((1, 1), [
      *状态标签*：`State::WaitFrame` \
      #line(length: 100%, stroke: 0.5pt + orange.darken(20%))
      *跨 `.await` 存活的变量*：`len: usize` \
      #line(length: 100%, stroke: 0.5pt + orange.darken(20%))
      *内嵌子状态机*：`fut: ReadExactFut` \
      （大小在编译期精确已知，无预留空洞）
    ], orange),

    node((0, 2), [可在任意深层普通函数内挂起；\ 跨 C 外部函数接口或栈搬迁时需额外处理指针．], width: 54mm, stroke: none),
    node((1, 2), [只能在标记了 `.await` 的位置挂起；\ 状态机可放栈上、静态区或单次 `Box` 分配．], width: 54mm, stroke: none),
  )
})

在无栈协程中，当任务正在执行计算时，它借用当前工作线程的普通系统栈；
一旦遇到需要等待的挂起点，函数就会直接 `return` 返回到调用者手中，
把线程栈清空让给下一个任务，只将跨挂起点存活的状态留在那个编译期大小确定的状态机对象里．

关于早期 Rust 为什么放弃了有栈绿色线程以及分段栈、栈拷贝各自的技术障碍，详见下面的附注：

#statement("note/green-threads-and-stack-management")

= 推送模型与拉取模型

即便同样采用无栈状态机，JavaScript、C\# 等语言与 Rust 在驱动方式上也有区别：
前者采用*推送模型*，而 Rust 采用*拉取模型*．

在 JavaScript 中，调用一个 `async` 函数会立即开始执行函数体，直到遇到第一个 `await`；
同时，底层的事件循环持有挂起时的回调闭包（续延），当 I/O 完成时，运行时主动调用该回调并把结果作为参数*推*进去．
这种模式要求每次挂起时，都能把“下一步要执行的闭包”注册到事件源上，通常伴随着闭包的堆分配与引用计数管理．

Rust 反过来采用了*拉取模型*：
调用 `async fn` 不会执行函数体内的任何一行用户代码，它只是在内存中构造并返回一个处于初始状态的状态机（即实现了 `Future` 的值）．
只有当外部驱动者（通常是执行器，或者外层状态机）主动对它调用 `poll` 方法拉取一次时，它才会往下走一步．

#fig({
  import "@preview/fletcher:0.5.8" as fletcher: diagram, node, edge

  let nd(pos, body, tint, width: 34mm) = node(
    pos,
    align(center, body),
    width: width,
    fill: tint.lighten(84%),
    stroke: 0.8pt + tint.darken(15%),
    corner-radius: 4pt,
    inset: 6pt,
  )

  diagram(
    spacing: (28mm, 12mm),
    edge-stroke: 0.8pt,

    node((0.5, 0), [*推送模型（Callback / Promise）*], stroke: none),
    nd((0, 1), [I/O 事件源], blue),
    nd((1, 1), [持有回调闭包 \ `on_complete(val)`], orange, width: 38mm),
    edge((0, 1), (1, 1), "-|>", label: [就绪时携值调用], label-side: left),

    node((0.5, 2.1), [*拉取模型（Rust Future + Waker）*], stroke: none),
    nd((0, 3), [执行器 \ （Executor）], green),
    nd((1, 3), [异步状态机 \ （`Future`）], orange),
    nd((0.5, 4.3), [I/O 反应器 \ （Reactor）], blue),

    edge((0, 3), (1, 3), "-|>", label: [1. `poll(cx)` 拉取], bend: 22deg, label-side: left),
    edge((1, 3), (0, 3), "--|>", label: [2. `Pending` / `Ready(v)`], bend: 22deg, label-side: left),
    edge((1, 3), (0.5, 4.3), "-|>", label: [3. 注册 `Waker`], label-side: left),
    edge((0.5, 4.3), (0, 3), "-|>", label: [4. `wake()` 通知重排], label-side: left),
  )
})

拉取模型给 Rust 带来了三项直接后果：

1. *组合状态机的零分配内联*：当异步函数 $A$ 调用并 `.await` 异步函数 $B$ 时，$B$ 的状态机可以直接作为字段内联在 $A$ 的状态机枚举中．
   推进 $A$ 时只是普通的方法调用 `b.poll(cx)`，不需要在每一层 `.await` 处动态分配回调闭包．
2. *惰性求值*：如果不把 `Future` 交给执行器或对其 `.await`，它就只是一个静止的结构体，不会产生任何副作用．
3. *同步取消（drop 即取消）*：在推送模型中，任务把回调交给底层 I/O 后，若想取消任务，必须显式传递取消令牌（如 `CancellationToken` 或 `AbortSignal`）去阻止回调生效；
   而在拉取模型中，`Future` 是被执行器持有的被动状态机——只要执行器不再 `poll` 它并直接将其 `drop`，整个状态机树连同其持有的资源就会立即按 Rust 的析构规则释放．

这种设计把“推进状态计算”（`poll`）和“通知状态可推进”（`wake`）拆成了两条正交的通道．
从更宏观的语言设计视角来看，这种将控制流具体化为状态机特型并提供多层级操作方式的手法，贯穿了 Rust 的迭代、错误处理与异步三大机制：

#statement("remark/registers-of-rust-and-control-flow-effects")

下一篇将直接打开标准库中仅有的十余行核心定义，看 `Future` 与 `Waker` 怎样用最少的类型接口定下这条契约．

#html.nav(class: "chapter-nav", aria-label: "文章导航")[
  #cite("/how/rust/async/index.typ")[回到 Rust 异步机制]
  #cite("/how/rust/async/future-and-waker.typ")[Future 与 Waker：基于轮询的异步契约 →]
]
