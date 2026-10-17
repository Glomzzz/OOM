#import "/lib/formal.typ": *

#show: formal-page.with(
  title: [Rust 异步机制：从 Future 到执行器],
  description: [从阻塞与非阻塞 I/O 出发，剖析 Rust 中 Future 与 Waker 的轮询协议、async/await 的状态机编译、Pin 与自引用结构，以及执行器与反应器的协作．],
  date: [2026-10-15],
  author: [哈吉米4],
  parent: "/how/rust/index.typ",
)

在系统编程中，*异步编程*让单个操作系统线程能够交替推进多个处于等待状态的计算任务．
Rust 采用的 `async`／`await` 机制不依赖语言内置的运行时或垃圾回收器，
而是将异步函数在编译期变换为实现了 `Future` 特型的状态机，
并通过 `Pin` 在类型系统层面约束跨挂起点借用带来的自引用结构．

许多介绍异步的文章要么停留在 `tokio::spawn` 的接口用法，
要么直接贴出标准库 `Pin` 与 `RawWakerVTable` 的源码．
前者难以解释为什么没有执行器时 `Future` 一步也不会走、为什么跨 `.await` 持有互斥锁会出问题；
后者则容易让人迷失在指针包装与虚表细节里，看不见每个构造要解决的具体矛盾．

这组文章按照“问题—约束—方案—实现—局限”的线索，把 Rust 的异步机制拆解为五个递进的切面：
为什么需要无栈协程与拉取模型，`Future` 与 `Waker` 如何约定轮询与唤醒，
编译器如何把顺序代码改写为枚举状态机，跨挂起点的借用为什么迫使类型系统引入 `Pin`，
最后执行器与 I/O 反应器怎样把这些部件串成完整的事件循环．

#let async-chapter(slug, open: false) = site-embed(
  "/how/rust/async/" + slug,
  open: open,
  sidebar: "full",
  heading-level: 2,
)

#async-chapter("model.typ", open: true)

#async-chapter("future-and-waker.typ")

#async-chapter("state-machine.typ")

#async-chapter("pin-and-self-reference.typ")

#async-chapter("executor-and-reactor.typ")

#async-chapter("summary.typ")
