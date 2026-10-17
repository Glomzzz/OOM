#import "/lib/formal.typ": *

#show: formal-page.with(
  title: [总结与延伸阅读],
  description: [串联 Rust 异步机制从编译期变换到运行期调度的全景图，汇总核心术语与延伸资料．],
  date: [2026-10-15],
  author: [哈吉米4],
  parent: "/how/rust/async/index.typ",
)

回顾这五篇文章，Rust 的 `async`／`await` 将*编译期代码变换*、*所有权与类型约束*以及*库级事件循环*三者结合在一起：

1. *资源与模型选择*（#cite("/how/rust/async/model.typ")[为什么需要异步]）：
   为了在不引入强制运行时和动态栈管理的前提下支持高并发等待，Rust 放弃了有栈协程与基于回调推送的模型，选择了*基于轮询拉取的无栈协程*．
   这使得嵌套异步调用能够内联为单一状态机结构体，并以直接 `drop` 状态机的方式免费获得了同步取消能力．
2. *轮询与唤醒契约*（#cite("/how/rust/async/future-and-waker.typ")[Future 与 Waker]）：
   标准库用 `Future::poll` 和 `Poll<T>` 规定了推进状态机的统一接口，用 `Context` 与 `Waker` 解耦了“驱动状态机”和“监听外部事件”．
   `RawWaker` 与 `RawWakerVTable` 通过手工构造的双字长胖指针，在不依赖堆分配和泛型传染的条件下实现了跨执行器的类型擦除．
3. *编译期状态机变换*（#cite("/how/rust/async/state-machine.typ")[async/await 脱糖]）：
   编译器按 `.await` 挂起点切分控制流，分析跨越挂起点存活的局部变量，将顺序代码改写为实现了 `Future` 的带标签联合体（`enum`）．
   理解这一内存布局，就能直接推导状态机的体积变化、递归 `async fn` 的间接层需求，以及跨 `.await` 持有非 `Send` 锁守卫带来的编译错误．
4. *自引用安全边界*（#cite("/how/rust/async/pin-and-self-reference.typ")[Pin 与自引用结构]）：
   当局部变量借用跨越 `.await` 时，状态机内部会出现指向自身其他字段的自引用指针．
   `Pin<P>` 通过在类型层面限制安全代码获取 `!Unpin` 对象的 `&mut T`，阻止了在首次 `poll` 之后通过 `mem::swap` 按位搬移状态机，从而在零运行时开销下守住了内存安全．
5. *运行时事件闭环*（#cite("/how/rust/async/executor-and-reactor.typ")[执行器与反应器]）：
   执行器从就绪队列取出任务并调用 `poll`；叶子 `Future` 遇到 `WouldBlock` 时向反应器注册 `Waker` 并返回 `Pending`；操作系统通过 `epoll`／`kqueue`／`IOCP` 通知反应器事件就绪后，反应器调用 `Waker::wake()` 将任务重新排入执行器队列．

我们可以把从“写下一行 `async fn`”到“在操作系统线程上跑完一次非阻塞 I/O”的全链路浓缩为下面这张全景图：

#fig({
  import "@preview/fletcher:0.5.8" as fletcher: diagram, node, edge

  let box-nd(pos, body, tint, width: 42mm) = node(
    pos,
    align(center, body),
    width: width,
    fill: tint.lighten(84%),
    stroke: 0.8pt + tint.darken(15%),
    corner-radius: 4pt,
    inset: 6pt,
  )

  diagram(
    spacing: (24mm, 13mm),
    edge-stroke: 0.8pt,

    node((0, 0), [*编译期（rustc）*], stroke: none),
    node((1, 0), [*类型与内存边界*], stroke: none),
    node((2, 0), [*运行期（Executor + Reactor）*], stroke: none),

    box-nd((0, 1), [
      *`async fn` 源码* \
      含跨 `.await` 变量与局部借用
    ], purple),

    box-nd((0, 2), [
      *生成枚举状态机* \
      实现 `Future` 与 `!Unpin`
    ], purple),

    box-nd((1, 2), [
      *固定内存地址* \
      `pin!(fut)` 栈固定 \
      或 `Box::pin(fut)` 堆固定
    ], orange),

    box-nd((2, 1), [
      *执行器（Executor）* \
      就绪队列取出 `Task` \
      调用 `Pin::poll(cx)`
    ], green),

    box-nd((2, 2), [
      *反应器（Reactor）* \
      保存 `Waker`，监听 OS 事件 \
      就绪后 `wake()` 重新入队
    ], blue),

    edge((0, 1), (0, 2), "-|>", label: [脱糖变换], label-side: right),
    edge((0, 2), (1, 2), "-|>", label: [构造并固定], label-side: left),
    edge((1, 2), (2, 1), "-|>", label: [`Pin<&mut Self>`], label-side: left),
    edge((2, 1), (2, 2), "-|>", label: [`Pending` + 注册], bend: 24deg, label-side: left),
    edge((2, 2), (2, 1), "-|>", label: [`wake()` 入队], bend: 24deg, label-side: left),
  )
})

= 术语对照

文中出现的英文术语与中文译名，同样收录于全站 #cite("/how/terms.typ")[术语对照] 中：

/ 异步编程: asynchronous programming
/ 绿色线程: green thread
/ 有栈协程: stackful coroutine
/ 无栈协程: stackless coroutine
/ 分段栈: segmented stack
/ 栈拷贝: stack copying
/ 协作式调度: cooperative scheduling
/ 抢占式调度: preemptive scheduling
/ 半协作式取消: semi-cooperative cancellation
/ 取消安全性: cancellation safety
/ 拉取模型: pull-based model
/ 推送模型: push-based model
/ 语域: register
/ 挂起点: suspension point
/ 状态机: state machine
/ 轮询: poll
/ 唤醒器: waker
/ 伪唤醒: spurious wakeup
/ 自引用结构: self-referential struct
/ 地址固定: pinning
/ 固定类型状态: pinned typestate
/ 析构保证: drop guarantee
/ 结构化固定投影: structural pin projection
/ 执行器: executor
/ 反应器: reactor

= 延伸阅读

关于 Rust 异步机制的设计历史、标准库规范与工程实践，可进一步查阅以下资料：

- Without Boats 的个人博客 #link("https://without.boats/")[_Without boats, dreams dry up_]：作为 2017–2019 年间主导 Rust `async`／`await` 与 `Pin` 设计的核心作者，他在博客中系统记录了整套机制的来龙去脉与后续演进思考．其中与本系列直接相关的文章包括：
  - #link("https://without.boats/blog/why-async-rust/")[_Why async Rust?_]：回顾 Rust 1.0 前移除绿色线程的原因、从内部迭代器到外部迭代器的转变如何启发了基于轮询的 `Future`（见 #refer("note/green-threads-and-stack-management")）．
  - #link("https://without.boats/blog/pin/")[_Pin_] 与 #link("https://without.boats/blog/pinned-places/")[_Pinned places_]：解释跨 `.await` 借用如何产生自引用状态机、为什么移动构造函数与 `?Move` 特型在 Rust 中不可行，以及怎样通过“固定位置”（pinned places）消除 `Pin` 作为纯库类型带来的可用性断崖（见 #refer("definition/pinned-typestate") 与 #refer("note/why-not-move-constructors-or-move-trait")）．
  - #link("https://without.boats/blog/the-registers-of-rust/")[_The registers of Rust_] 与 #link("https://without.boats/blog/poll-next/")[_poll_next_]：提出控制流作用的四个语域（核心、消费、组合子、控制流），并从状态机数量、内存固定与动态分发的角度论证为什么 `AsyncIterator` 应当采用 `poll_next` 而非 `async fn next`（见 #refer("remark/registers-of-rust-and-control-flow-effects")）．
  - #link("https://without.boats/blog/asynchronous-clean-up/")[_Asynchronous clean-up_]：剖析半协作式取消、`select!` 循环中的取消安全性陷阱，以及隐式异步析构（`AsyncDrop`）面临的对象安全与类型传染障碍（见 #refer("note/cancellation-safety-and-async-cleanup")）．
- Ralf Jung 的形式化文章 #link("https://www.ralfj.de/blog/2018/04/05/a-formal-look-at-pinning.html")[_A Formal Look at Pinning_]：在 RustBelt 框架下给出独占（owned）、共享（shared）与固定（pinned）三种类型状态及析构保证的形式化刻画．
- Rust 官方工作组维护的 #link("https://rust-lang.github.io/async-book/")[_Asynchronous Programming in Rust_]（《Rust 异步编程》），介绍 `Future`、`Waker`、`Pin` 以及单线程执行器的基础实现．
- 标准库文档中的 #link("https://doc.rust-lang.org/std/pin/index.html")[`std::pin` 模块文档]与 #link("https://doc.rust-lang.org/std/task/index.html")[`std::task` 模块文档]，给出 `Pin` 的析构保证与结构化投影的精确安全条件．
- Phil Oppermann 的 #link("https://os.phil-opp.com/async-await/")[_Writing an OS in Rust: Async/Await_]，展示如何在没有任何操作系统支持的裸机内核中，用硬件中断、无锁队列与 Rust 的 `async`/`await` 搭出一套协作式多任务系统．
- Alice Ryhl 的工程文章 #link("https://ryhl.io/blog/async-what-is-blocking/")[_Async: What is blocking?_]，讨论协作式调度下“阻塞”的定量边界以及 `spawn_blocking` 与 `rayon` 的选型准则．

#html.nav(class: "chapter-nav", aria-label: "文章导航")[
  #cite("/how/rust/async/executor-and-reactor.typ")[← 执行器与反应器：从零拼出异步运行时]
  #cite("/how/rust/async/index.typ")[回到 Rust 异步机制]
]
