#import "/lib/formal.typ": *

#show: formal-page.with(
  title: [Future 与 Waker：基于轮询的异步契约],
  description: [剖析标准库中 Future、Poll、Context 与 Waker 的类型定义、轮询协议不变量，以及 RawWaker 手工虚表的零成本擦除机制．],
  date: [2026-10-15],
  author: [哈吉米4],
  parent: "/how/rust/async/index.typ",
)

在 #cite("/how/rust/async/model.typ")[为什么需要异步] 中我们看到，Rust 用“外部主动拉取状态机 + 事件源回调通知重排”代替了层层嵌套的回调闭包．
这套机制在标准库 `core::future` 与 `core::task` 中只占极小的篇幅：
标准库既不包含事件循环，也不包含网络或定时器实现，它只定义了驱动者（执行器）与被驱动者（`Future`）之间的*通信契约*．

= `Future` 与 `Poll` 的定义

打开标准库 `core::future::Future` 与 `core::task::Poll`，核心定义只有十几行：

```rust
pub trait Future {
    type Output;

    fn poll(self: Pin<&mut Self>, cx: &mut Context<'_>) -> Poll<Self::Output>;
}

pub enum Poll<T> {
    Ready(T),
    Pending,
}
```

这里暂时把第一个参数 `self: Pin<&mut Self>` 当作普通的可变借用 `&mut Self` 来读（关于为什么必须用 `Pin` 包装，将在 #cite("/how/rust/async/pin-and-self-reference.typ")[Pin 与自引用结构] 中专门拆解）．
除去 `Pin` 之后，`poll` 的签名表达了一件非常朴素的事：
调用者提供可变借用与任务上下文 `cx`，让状态机尝试往前推进；
状态机要么已经算完并返回 `Poll::Ready(val)`，要么因为等待某个条件而无法继续，返回 `Poll::Pending`．

为什么不能省掉 `cx: &mut Context<'_>`，只让执行器在循环里一遍遍调用 `poll()`？
如果执行器不知道一个返回了 `Pending` 的任务什么时候才会就绪，它就只能采取*忙等待*，在死循环里不停地询问每一个任务“好了吗？”．
这会把 CPU 核心跑满到 $100%$，退化成低效的自旋．

为了避免忙等待，`poll` 协议规定了一条双向契约：

1. *调用者的承诺*：当 `poll` 返回 `Poll::Ready(val)` 后，调用者认为该 `Future` 已完成，*不得*再次对它调用 `poll`（除非该类型额外实现了 `FusedFuture` 并显式允许）．
2. *实现者的承诺*：当 `poll` 返回 `Poll::Pending` 时，该 `Future` *必须*确保已经将 `cx.waker()`（或其克隆）注册到了某个未来会触发的事件源上；当阻挡任务前进的条件解除时，事件源有责任调用该 `Waker` 的 `wake()` 方法，通知执行器“现在值得再 `poll` 我一次了”．

如果一个叶子 `Future` 既返回了 `Poll::Pending`，又没有在任何地方保存或触发 `cx.waker()`，执行器就会把它移出就绪队列并永久挂起——任务会在没有任何报错的情况下“静默死锁”．

= 手写一个叶子 `Future` 与组合子

为了看清 `poll` 是如何一层层传导的，我们不借助 `async`/`await` 语法糖，先手动实现两个 `Future`：
一个是模拟等待倒计时的叶子状态机 `Countdown`，另一个是将结果乘二的外层组合子 `Double<F>`．

```rust
use std::future::Future;
use std::pin::Pin;
use std::task::{Context, Poll};

/// 每次被 poll 时减一，减到 0 时就绪．
pub struct Countdown {
    pub remaining: u32,
}

impl Future for Countdown {
    type Output = u32;

    fn poll(mut self: Pin<&mut Self>, cx: &mut Context<'_>) -> Poll<u32> {
        if self.remaining == 0 {
            Poll::Ready(21)
        } else {
            self.remaining -= 1;
            // 关键：返回 Pending 前必须安排唤醒！
            // 这里演示立即通知执行器下一轮继续 poll 自己；
            // 真实的异步 I/O 会把 cx.waker().clone() 存进反应器．
            cx.waker().wake_by_ref();
            Poll::Pending
        }
    }
}

/// 包装另一个 Future，在其就绪后将输出乘 2．
pub struct Double<F> {
    pub inner: F,
}

impl<F: Future<Output = u32> + Unpin> Future for Double<F> {
    type Output = u32;

    fn poll(mut self: Pin<&mut Self>, cx: &mut Context<'_>) -> Poll<u32> {
        // 向下委托 poll 调用，把同一个 Context 传给内层状态机
        match Pin::new(&mut self.inner).poll(cx) {
            Poll::Ready(val) => Poll::Ready(val * 2),
            Poll::Pending => Poll::Pending,
        }
    }
}
```

注意 `Double::poll` 的写法：它本身并不知道底层到底在等计时器、套接字还是通道，也不需要直接操作 `cx.waker()`；
它只负责把 `cx` 原封不动地透传给内层的 `self.inner.poll(cx)`．
标准库还提供了 `std::task::ready!(expr)` 宏（历史代码中常见 `futures::ready!`），专门用来简化上述 `match` 模式：

```rust
let val = std::task::ready!(Pin::new(&mut self.inner).poll(cx));
Poll::Ready(val * 2)
```

当多层 `Future` 组合在一起时，外层是一个大的结构体，内层是嵌套在其中的字段．
一次顶层的 `poll` 调用，就是沿着这棵结构体树自顶向下的一连串同步方法调用，直到抵达最底层的叶子 `Future`：

#fig({
  import "@preview/fletcher:0.5.8" as fletcher: diagram, node, edge

  let nd(pos, body, tint, width: 42mm) = node(
    pos,
    align(center, body),
    width: width,
    fill: tint.lighten(84%),
    stroke: 0.8pt + tint.darken(15%),
    corner-radius: 4pt,
    inset: 6pt,
  )

  diagram(
    spacing: (26mm, 13mm),
    edge-stroke: 0.8pt,

    nd((0, 0), [*执行器（Executor）* \ 构造 `Context(&waker)`], green),
    nd((0, 1), [*顶层状态机 `Double`* \ `Double::poll(cx)`], orange),
    nd((0, 2), [*叶子状态机 `Countdown`* \ `Countdown::poll(cx)`], orange),
    nd((1.2, 2), [*事件源 / 反应器* \ 保存 `Waker` 副本], blue),

    edge((0, 0), (0, 1), "-|>", label: [`poll(cx)`], bend: -22deg, label-side: right),
    edge((0, 1), (0, 2), "-|>", label: [`poll(cx)`], bend: -22deg, label-side: right),
    edge((0, 2), (1.2, 2), "-|>", label: [`cx.waker().clone()`], label-side: left),
    edge((0, 2), (0, 1), "--|>", label: [`Pending`], bend: -22deg, label-side: right),
    edge((0, 1), (0, 0), "--|>", label: [`Pending`], bend: -22deg, label-side: right),
    edge((1.2, 2), (0, 0), "-|>", label: [事件就绪时调 `wake()`], bend: -28deg, label-side: right),
  )
})

= 为什么 `Waker` 使用手工虚表 `RawWaker`

理解了 `Waker` 的职责后，一个工程问题随之而来：
Rust 生态中有许多不同的执行器——`tokio` 的多线程工作窃取调度器、`async-std`、`smol`，乃至嵌入式芯片上跑在中断里的微型轮询器．
不同执行器里的“任务句柄”长相完全不同：有的指向 `Arc<Task>`，有的只是一个静态数组的下标，有的甚至不需要任何数据指针．
而同一个底层库（比如某个驱动硬件的 `Future`）必须能够在不重新编译、不带执行器泛型参数 `Future<E: Executor>` 的前提下，被任何执行器驱动．

如果在 `Future` 特型上加泛型参数，整个异步生态就会分裂成互不兼容的孤岛；
如果直接把 `Waker` 定义成 `Box<dyn WakeTrait>`，每次克隆 `Waker` 就可能触发一次堆内存分配，或者强制依赖 `alloc` 库（无法用于无堆的裸机 `no_std` 环境）．

为此，标准库在 `core::task` 中采用了一套*手工构造的胖指针（类型擦除虚表）*设计，由 `Waker`、`RawWaker` 与 `RawWakerVTable` 组成：

```rust
pub struct Waker {
    waker: RawWaker,
}

#[derive(PartialEq, Debug)]
pub struct RawWaker {
    data: *const (),
    vtable: &'static RawWakerVTable,
}

pub struct RawWakerVTable {
    clone: unsafe fn(*const ()) -> RawWaker,
    wake: unsafe fn(*const ()),
    wake_by_ref: unsafe fn(*const ()),
    drop: unsafe fn(*const ()),
}
```

`Waker` 在内存中恰好占用两个机器字长（64 位平台上为 16 字节）：
一个擦除了具体类型的裸指针 `data: *const ()`，加上一个指向编译期静态常量表 `RawWakerVTable` 的引用．

#fig({
  import "@preview/fletcher:0.5.8" as fletcher: diagram, node, edge

  let box-nd(pos, body, tint, width: 44mm) = node(
    pos,
    align(left, body),
    width: width,
    fill: tint.lighten(85%),
    stroke: 0.8pt + tint.darken(15%),
    corner-radius: 4pt,
    inset: 6pt,
  )

  diagram(
    spacing: (26mm, 12mm),
    edge-stroke: 0.8pt,

    box-nd((0, 0.55), [
      *栈上的 `Waker`（16 字节）* \
      #line(length: 100%, stroke: 0.5pt + green.darken(20%))
      `data: *const ()` \
      #line(length: 100%, stroke: 0.5pt + green.darken(20%))
      `vtable: &'static RawWakerVTable`
    ], green, width: 52mm),

    box-nd((1, 0), [
      *任务控制块（堆或静态区）* \
      例如 `Arc<Task>` 或位图槽位 \
      引用计数 / 任务状态 / 就绪队列指针
    ], orange, width: 54mm),

    box-nd((1, 1.1), [
      *静态只读区 `RawWakerVTable`* \
      #line(length: 100%, stroke: 0.5pt + blue.darken(20%))
      `clone: fn(*const ()) -> RawWaker` \
      `wake: fn(*const ())` \
      `wake_by_ref: fn(*const ())` \
      `drop: fn(*const ())`
    ], blue, width: 54mm),

    edge((0, 0.55), (1, 0), "-|>", label: [`data` 指向], bend: 12deg, label-side: left),
    edge((0, 0.55), (1, 1.1), "-|>", label: [`vtable` 指向], bend: -12deg, label-side: right),
  )
})

这套四函数虚表精确覆盖了 `Waker` 的全部生命周期操作，且每一项都留有性能空间：

- `clone`：复制一份 `Waker`．若 `data` 底层是 `Arc<Task>`，`clone` 只需调用 `Arc::increment_strong_count` 原地增加原子引用计数，并返回指向同一 `data` 和同一 `vtable` 的新 `RawWaker`，*全程没有新的堆内存分配*；若在裸机上 `data` 只是全局中断标志的地址，`clone` 甚至什么都不用做，直接复制指针即可．
- `wake` 与 `wake_by_ref`：前者按值消耗 `Waker`（可以省去先增引用计数再减引用计数的原子操作），后者通过借用触发唤醒．
- `drop`：`Waker` 析构时调用，例如对底层的 `Arc<Task>` 递减引用计数．

标准库在拥有堆分配器的 `std::task::Wake` 特型中，已经为 `Arc<T: Wake>` 封装好了这套 `RawWakerVTable` 样板代码；
普通编写执行器的人只需为自己的任务结构体实现 `Wake` 特型，再调用 `Waker::from(arc_task)` 即可安全地拿到 `Waker`，无需手写 `unsafe` 裸指针转换．

= 常见陷阱：伪唤醒与 `Waker` 更新

在实际编写底层 `Future` 时，有两个与 `Waker` 相关的边界条件容易出错：

1. *容忍伪唤醒*：
   仅仅因为 `Future::poll` 被再次调用，*不代表*等待的事件一定已经完成．
   比如一个组合子同时等待两个子 `Future`（如 `select!` 或 `join!`），其中左支触发了同一个 `Waker`，执行器会把整个顶层任务重新 `poll` 一遍，此时右支也会跟着被 `poll`，但右支等待的 I/O 根本还没就绪．
   因此，`poll` 的实现必须始终先检查底层资源的真实就绪状态（例如再次尝试非阻塞读取并检查是否仍返回 `WouldBlock`），绝不能假设“第二次进 `poll` 就一定成功”．
2. *替换旧的 `Waker`*：
   一个 `Future` 在两次 `poll` 之间，可能会被迁移到另一个执行器或另一个任务上下文中驱动，导致第二次传入的 `cx.waker()` 与第一次保存的不是同一个唤醒目标．
   如果底层事件源在多次返回 `Pending` 的过程中只保留了第一次 `poll` 时的 `Waker`，后续的唤醒就会发往错误的旧任务．
   正确的做法是在每次返回 `Pending` 前，用最新的 `cx.waker()` 更新已存储的 `Waker`（可借助 `Waker::will_wake` 先检查新旧 `Waker` 是否指向同一目标，避免无谓的原子引用计数更新）：

```rust
if !stored_waker.will_wake(cx.waker()) {
    stored_waker = cx.waker().clone();
}
```

= 练习：轮询协议

#exercise-group(2)[
  #exercise(
    "2.1",
    [诊断“静默挂起”的 `Future`],
    hint: [
      检查当 `self.ready` 为 `false` 时，`BrokenOnce::poll` 是否向 `cx.waker()` 发出了任何通知或将其保存下来．
    ],
    answer: [
      第一次调用 `poll` 时，`self.ready` 被设为 `true` 并返回 `Poll::Pending`，
      但函数既没有调用 `cx.waker().wake_by_ref()`，也没有把 `cx.waker().clone()` 交给任何外部事件源．
      在遵守标准协议的执行器（如 `tokio` 或后文我们将实现的队列执行器）中，执行器收到 `Pending` 后会将任务移出就绪队列，等待 `Waker` 被触发时再将其放回．
      由于没有任何地方会触发这个 `Waker`，该任务永远不会获得第二次 `poll` 的机会，程序会一直挂起（或阻塞在 `block_on` 的条件变量上）．

      修复方法：若本意是“让出一次执行权后立即恢复”（类似 `yield_now`），应在返回 `Poll::Pending` 前加上 `cx.waker().wake_by_ref();`．
    ],
  )[
    阅读下面这个试图“第一次挂起、第二次返回 `42`”的 `Future` 实现，说明把它交给真实执行器运行时会发生什么，并指出原因与修复方式：

    ```rust
    pub struct BrokenOnce {
        pub ready: bool,
    }

    impl Future for BrokenOnce {
        type Output = i32;

        fn poll(mut self: Pin<&mut Self>, _cx: &mut Context<'_>) -> Poll<i32> {
            if self.ready {
                Poll::Ready(42)
            } else {
                self.ready = true;
                Poll::Pending
            }
        }
    }
    ```
  ]

  #exercise(
    "2.2",
    [组合子的 `poll` 次数与唤醒传递],
    hint: [
      沿着 `Double::poll -> Countdown::poll` 逐步追踪每次调用时 `remaining` 的变化和返回值．
    ],
    answer: [
      共需要 *3 次*顶层 `poll` 调用：
      1. 第一次 `poll`：`remaining` 从 `2` 减为 `1`，调用 `wake_by_ref()`，返回 `Poll::Pending`；`Double` 收到 `Pending` 后直接向上返回 `Poll::Pending`．
      2. 第二次 `poll`：`remaining` 从 `1` 减为 `0`，调用 `wake_by_ref()`，返回 `Poll::Pending`；`Double` 向上返回 `Poll::Pending`．
      3. 第三次 `poll`：`remaining == 0`，`Countdown` 返回 `Poll::Ready(21)`；`Double` 将其乘 2，返回 `Poll::Ready(42)`．

      在这个过程中，`Double` 自己完全没有触碰 `cx`，但 `Countdown` 通过透传下来的 `cx` 直接唤醒了顶层任务．
    ],
  )[
    设顶层任务为 `Double { inner: Countdown { remaining: 2 } }`．
    将它交给执行器运行直到完成，顶层的 `Double::poll` 一共会被调用几次？每次返回什么？
  ]
]

#html.nav(class: "chapter-nav", aria-label: "文章导航")[
  #cite("/how/rust/async/model.typ")[← 为什么需要异步：阻塞、回调与无栈协程]
  #cite("/how/rust/async/index.typ")[回到 Rust 异步机制]
  #cite("/how/rust/async/state-machine.typ")[async/await 脱糖：状态机编译 →]
]
