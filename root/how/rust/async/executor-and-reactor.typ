#import "/lib/formal.typ": *

#show: formal-page.with(
  title: [执行器与反应器：从零拼出异步运行时],
  description: [实现最小可运行的 block_on 与多任务队列执行器，剖析 epoll/kqueue/IOCP 反应器怎样通过 Waker 把操作系统事件接入事件循环．],
  date: [2026-10-15],
  author: [哈吉米4],
  parent: "/how/rust/async/index.typ",
)

至此，我们已经集齐了被动一侧的全部零件：
`async`/`await` 编译出枚举状态机，`Pin` 把状态机安全地固定在内存里，`Future::poll` 与 `Waker` 规定了推进与通知的契约．
但所有这些构造都是*被动的*——如果没有一段主动跑在线程上的循环代码去构造 `Context` 并调用顶层任务的 `poll`，任何 `Future` 都不会往前走哪怕一步．

在异步运行时（如 `tokio` 或 `smol`）中，主动驱动任务的部分分为两个协作角色：
*执行器*负责维护就绪任务队列并调用 `Future::poll`；
*反应器*（在 `tokio` 中常称 I/O 驱动器或时间驱动器）负责向操作系统监听外部事件（如套接字可读、定时器到期），并在事件发生时调用对应任务的 `Waker::wake()`．

= 整套运行时的闭环架构

先把执行器、顶层任务、叶子 `Future` 与反应器摆在同一张架构图里，看一次异步 I/O 从发起、挂起到唤醒恢复的完整轨迹：

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
    spacing: (28mm, 14mm),
    edge-stroke: 0.8pt,

    box-nd((0, 0), [
      *就绪队列（Ready Queue）* \
      存放待执行的 `Arc<Task>`
    ], green, width: 48mm),

    box-nd((1, 0), [
      *执行器工作循环* \
      取出 `Task`，构造 `Waker` \
      调用 `future.poll(&mut cx)`
    ], green, width: 48mm),

    box-nd((1, 1), [
      *异步任务状态机* \
      非阻塞读遇到 `WouldBlock` \
      向反应器登记 `(fd, Waker)`
    ], orange, width: 48mm),

    box-nd((0, 1), [
      *反应器（Reactor）* \
      `epoll_wait` / `kqueue` / 定时器 \
      维护 `token -> Waker` 映射表
    ], blue, width: 48mm),

    edge((0, 0), (1, 0), "-|>", label: [1. `pop_front()`], label-side: left),
    edge((1, 0), (1, 1), "-|>", label: [2. `poll(cx)`], bend: 22deg, label-side: left),
    edge((1, 1), (1, 0), "--|>", label: [4. 返回 `Pending`], bend: 22deg, label-side: left),
    edge((1, 1), (0, 1), "-|>", label: [3. 注册 `cx.waker()`], label-side: left),
    edge((0, 1), (0, 0), "-|>", label: [5. 事件就绪，`wake()` 入队], label-side: left),
  )
})

注意第 4 步与第 5 步之间的状态：
当任务在第 4 步向执行器返回 `Poll::Pending` 后，执行器*不再持有该任务的就绪引用*，也不会把它塞回就绪队列；
此时是谁还抓着这个任务，保证它没被丢掉？
是第 3 步注册进反应器的那个 `Waker`（其内部 `data` 指针持有 `Arc<Task>` 的一份强引用，任务本体则安全地躺在堆上或执行器的任务槽中）！
一旦操作系统通知反应器“网卡数据到了”，反应器在表中查出对应的 `Waker` 并调用 `wake()`，`wake()` 的实现就是把 `Arc<Task>` 重新推回第 1 步的就绪队列．

= 第一步：三十行写出单任务 `block_on`

在写多任务队列之前，我们先写一个最简单的执行器 `block_on<F: Future>(fut: F) -> F::Output`．
它只负责在当前线程上阻塞地驱动单个顶层 `Future` 直到完成：
当 `poll` 返回 `Pending` 时，通过标准库的线程驻留原语 `std::thread::park()` 让当前操作系统线程休眠；
当任何地方调用 `Waker::wake()` 时，通过 `Thread::unpark()` 唤醒该线程继续下一轮 `poll`．

借助 Rust 标准库的 `std::task::Wake` 特型与 `std::pin::pin!` 宏，这个完全符合标准协议的执行器不需要写一行 `unsafe`：

```rust
use std::future::Future;
use std::pin::pin;
use std::sync::Arc;
use std::task::{Context, Poll, Wake, Waker};
use std::thread::{self, Thread};

/// 唤醒器的数据载体：直接保存需要被唤醒的操作系统线程句柄．
struct ThreadNotify {
    thread: Thread,
}

impl Wake for ThreadNotify {
    fn wake(self: Arc<Self>) {
        self.thread.unpark();
    }

    fn wake_by_ref(self: &Arc<Self>) {
        self.thread.unpark();
    }
}

pub fn block_on<F: Future>(fut: F) -> F::Output {
    // 1. 将状态机安全地固定在当前函数栈帧上（零堆分配）
    let mut fut = pin!(fut);

    // 2. 为当前线程创建 Waker 与 Context
    let notify = Arc::new(ThreadNotify {
        thread: thread::current(),
    });
    let waker = Waker::from(notify);
    let mut cx = Context::from_waker(&waker);

    // 3. 循环轮询：未就绪时挂起线程，被 unpark 唤醒后再次轮询
    loop {
        match fut.as_mut().poll(&mut cx) {
            Poll::Ready(output) => return output,
            Poll::Pending => thread::park(),
        }
    }
}
```

这里有一个体现 Rust 并发原语设计的细节：
*如果外部线程在 `fut.as_mut().poll(&mut cx)` 刚刚决定返回 `Pending`、但主线程还没来得及执行到 `thread::park()` 的那几纳秒间隙里，抢先一步调用了 `wake()`（即 `unpark()`），主线程接下来执行 `thread::park()` 会不会永久睡死？*

不会．因为 `std::thread::park` 与 `unpark` 采用的是*单令牌模型*：
每个线程关联一个布尔令牌，提前到达的 `unpark()` 会把令牌设为“可用”；紧接着调用的 `park()` 看到令牌可用，会立即消耗该令牌并直接返回，根本不会进入休眠．

= 第二步：支持 `spawn` 的多任务队列执行器

`block_on` 只能在单条直线上等待一个顶层 `Future`．
如果想在同一个线程上并发跑多个独立的顶层任务，我们就需要引入*任务控制块* `Task` 与*就绪队列*：

```rust
use std::future::Future;
use std::pin::Pin;
use std::sync::{mpsc, Arc, Mutex};
use std::task::{Context, Poll, Wake, Waker};

/// 一个被擦除了具体类型的顶层异步任务．
struct Task {
    /// 用 Mutex 包装以满足 Wake 要求的 Sync；
    /// 单线程执行器中实际上不会发生锁竞争．
    future: Mutex<Option<Pin<Box<dyn Future<Output = ()> + Send>>>>,
    /// 指向执行器就绪队列的发送端，wake() 时将自身送回队列．
    sender: mpsc::Sender<Arc<Task>>,
}

impl Wake for Task {
    fn wake(self: Arc<Self>) {
        let _ = self.sender.send(self.clone());
    }

    fn wake_by_ref(self: &Arc<Self>) {
        let _ = self.sender.send(self.clone());
    }
}
```

看清 `Task::wake` 所做的唯一一件事：*调用 `self.sender.send(self.clone())`，把 `Arc<Task>` 自己塞回执行器的就绪通道里*！
接下来，执行器的主循环只需要不断地从通道接收端取出 `Arc<Task>`，构造指向该 `Task` 的 `Waker`，再对其中的 `Future` 调用一次 `poll`：

```rust
pub struct MiniExecutor {
    receiver: mpsc::Receiver<Arc<Task>>,
    sender: mpsc::Sender<Arc<Task>>,
}

impl MiniExecutor {
    pub fn new() -> Self {
        let (sender, receiver) = mpsc::channel();
        Self { receiver, sender }
    }

    /// 向执行器提交一个新任务：装箱固定并立即送入就绪队列以触发首次 poll．
    pub fn spawn(&self, fut: impl Future<Output = ()> + Send + 'static) {
        let task = Arc::new(Task {
            future: Mutex::new(Some(Box::pin(fut))),
            sender: self.sender.clone(),
        });
        let _ = self.sender.send(task);
    }

    /// 运行就绪队列中的所有任务．
    pub fn run(&self) {
        while let Ok(task) = self.receiver.recv() {
            let mut slot = task.future.lock().unwrap();
            // 取出尚未完成的 Future；若已完成则忽略（防止重复唤醒再次 poll）
            if let Some(mut future) = slot.take() {
                let waker = Waker::from(task.clone());
                let mut cx = Context::from_waker(&waker);

                match future.as_mut().poll(&mut cx) {
                    Poll::Ready(()) => {
                        // 任务完成，不再放回 slot，future 在此处自然析构
                    }
                    Poll::Pending => {
                        // 尚未完成，把固定好的状态机放回槽位，等待未来 wake() 再次入队
                        *slot = Some(future);
                    }
                }
            }
        }
    }
}
```

注意 `slot.take()` 的手法：
由于同一个任务注册出去的多个 `Waker` 可能在任务完成后仍被触发，我们把 `future` 放在 `Option` 里．
当 `poll` 返回 `Poll::Ready(())` 时，我们不再把 `future` 放回 `slot`（使其保持为 `None`）；
这样即便后续还有迟到的伪唤醒把同一个 `Arc<Task>` 再次送进队列，`if let Some(mut future) = slot.take()` 也会直接跳过，严格兑现了“绝不再次 `poll` 已完成的 `Future`”的契约．

= 反应器是如何工作的

有了执行器，最后一块拼图是：当叶子 `Future` 发起网络读写或定时等待时，是谁在背后调用 `waker.wake()`？

以非阻塞 TCP 套接字读取为例：
1. 套接字在创建时被设置为非阻塞模式（`O_NONBLOCK`），并注册到操作系统的多路复用实例中（Linux 上是 `epoll` 或异步完成接口 `io_uring`，macOS/BSD 上是 `kqueue`，Windows 上是 `IOCP`），附带一个唯一标识号 `token`．
2. 当任务调用 `stream.read(&mut buf).await` 时，叶子 `Future` 的 `poll` 方法直接发起一次非阻塞系统调用 `read`．
   - 如果内核缓冲区里已经有数据，`read` 当场把字节拷进 `buf` 并返回字节数，`poll` 直接返回 `Poll::Ready(Ok(n))`，*根本不需要惊动反应器或挂起任务*．
   - 如果内核缓冲区为空，系统调用立即返回 `EAGAIN` / `EWOULDBLOCK`（在 Rust 中对应 `io::ErrorKind::WouldBlock`）．
3. 收到 `WouldBlock` 后，叶子 `Future` 将当前的 `cx.waker().clone()` 登记到反应器的 `token -> Waker` 表中，然后返回 `Poll::Pending`．
4. 当执行器的就绪队列排空、无事可做时，线程进入反应器的 `epoll_wait`（或定时堆等待），让出 CPU 直到内核报告某个 `token` 对应的文件描述符就绪．
5. 反应器遍历内核返回的就绪事件列表，按 `token` 查出先前登记的 `Waker`，逐一调用 `waker.wake()`——这会将对应的 `Arc<Task>` 重新推回执行器的就绪队列，随后下一轮执行循环就会把它们再次 `poll` 起来．

= 协作式调度的约束：不要在异步任务中阻塞线程

看清了“单线程（或少量工作线程）循环 `poll` 就绪任务 + 空闲时交由反应器 `epoll_wait`”的运行机制后，异步编程的核心工程约束也就清楚了：

*异步任务采用的是协作式调度．执行器一旦调用了某个任务的 `future.poll(&mut cx)`，除非这个 `poll` 函数主动返回 `Poll::Pending` 或 `Poll::Ready`，否则执行器无法中途抢占或打断它．*

#fig({
  import "@preview/cetz:0.3.4"
  cetz.canvas(length: 0.9cm, {
    import cetz.draw: *

    content((-2.2, 1.5), [*正常协作*])
    rect((0, 1.15), (1.8, 1.85), fill: blue.lighten(75%), stroke: 0.8pt)
    content((0.9, 1.5), [`poll(A)`])
    rect((1.8, 1.15), (3.6, 1.85), fill: orange.lighten(75%), stroke: 0.8pt)
    content((2.7, 1.5), [`poll(B)`])
    rect((3.6, 1.15), (5.4, 1.85), fill: green.lighten(75%), stroke: 0.8pt)
    content((4.5, 1.5), [`poll(C)`])
    rect((5.4, 1.15), (7.2, 1.85), fill: blue.lighten(75%), stroke: 0.8pt)
    content((6.3, 1.5), [`poll(A)`])
    content((9.2, 1.5), [每次 `poll` 仅耗时微秒级])

    content((-2.2, 0.1), [*阻塞事故*])
    rect((0, -0.25), (1.8, 0.45), fill: blue.lighten(75%), stroke: 0.8pt)
    content((0.9, 0.1), [`poll(A)`])
    rect((1.8, -0.25), (8.2, 0.45), fill: red.lighten(75%), stroke: 0.8pt + red.darken(20%))
    content((5.0, 0.1), [任务 B 调用 `thread::sleep` 或密集计算])
    rect((8.2, -0.25), (10.0, 0.45), fill: green.lighten(75%), stroke: 0.8pt)
    content((9.1, 0.1), [`poll(C)`])

    line((1.8, -0.55), (8.2, -0.55), mark: (start: "stealth", end: "stealth"), stroke: 0.8pt + red.darken(20%))
    content((5.0, -0.95), text(fill: red.darken(20%))[同线程上的任务 A、C 以及反应器全部被卡死饿死！])
  })
})

如果某个任务在 `async fn` 内部调用了阻塞式系统调用（如 `std::thread::sleep`、同步文件读写 `std::fs::read`、阻塞式数据库驱动），或者执行长达数百毫秒的密码学哈希、图像编解码等密集 CPU 计算而不经过任何 `.await`：
当前工作线程就会一直卡在这个任务的 `poll` 调用栈里出不来，既没法去 `poll` 队列里早已就绪的其他成百上千个任务，也没法去驱动反应器处理新的网络事件，导致整个线程上的所有并发任务集体出现尾延迟飙升甚至心跳超时断连．

遇到这类无法避免的同步阻塞或重度 CPU 计算时，应当：
- 对阻塞 I/O，交给运行时专门隔离的阻塞线程池（如 `tokio::task::spawn_blocking`），并通过异步通道或一次性 `oneshot` `Future` 把结果接回异步世界；
- 对重度 CPU 计算，交给并行计算线程池（如 `rayon`），或者在长循环中定期穿插 `tokio::task::yield_now().await`（其内部实现正是在返回 `Pending` 前立刻调用 `cx.waker().wake_by_ref()`，把排在后面的其他任务先让出来跑一轮）．

除了不能阻塞工作线程，协作式挂起与“丢弃即取消”还引出了循环 `select!` 中的取消安全性（cancellation safety）与异步清理（async clean-up）问题：

#statement("note/cancellation-safety-and-async-cleanup")

= 练习：执行器与调度行为

#exercise-group(2)[
  #exercise(
    "5.1",
    [手写 `yield_now()` 异步原语],
    hint: [
      用一个布尔字段记录是否是第一次被 `poll`；第一次返回 `Pending` 前必须自我唤醒，第二次直接返回 `Ready(())`．
    ],
    answer: [
      ```rust
      use std::future::Future;
      use std::pin::Pin;
      use std::task::{Context, Poll};

      pub struct YieldNow {
          yielded: bool,
      }

      pub fn yield_now() -> YieldNow {
          YieldNow { yielded: false }
      }

      impl Future for YieldNow {
          type Output = ();

          fn poll(mut self: Pin<&mut Self>, cx: &mut Context<'_>) -> Poll<()> {
              if self.yielded {
                  Poll::Ready(())
              } else {
                  self.yielded = true;
                  // 自我唤醒，使执行器将当前任务排到就绪队列队尾
                  cx.waker().wake_by_ref();
                  Poll::Pending
              }
          }
      }
      ```

      在我们的 `MiniExecutor` 中，当前任务调用 `yield_now().await` 时，`wake_by_ref()` 会把当前任务追加到 FIFO 通道的队尾，然后 `poll` 返回 `Pending`；
      执行器接着就会先去执行排在通道前面的其他就绪任务，等轮到队尾时再恢复当前任务（第二次 `poll` 进入 `self.yielded == true` 分支并返回 `Ready(())`）．
    ],
  )[
    用本节的知识实现 `pub fn yield_now() -> YieldNow`，使异步任务调用 `yield_now().await` 时能够主动让出一次当前线程的执行权，让就绪队列中的其他任务先运行，随后自己再恢复执行．
  ]

  #exercise(
    "5.2",
    [如果 `MiniExecutor` 忘记在 `spawn` 时入队会怎样],
    hint: [
      回想 Rust 的 `Future` 是惰性的：谁负责触发第一次 `poll` 以注册第一个 `Waker`？
    ],
    answer: [
      如果 `spawn` 只创建了 `Arc<Task>` 却没有将它送入 `self.sender`，那么这个任务连*第一次* `poll` 都不会被调用．
      由于状态机处于初始的 `Start` 状态，它还没有执行到任何内部叶子 `Future`，也没有向任何反应器注册过 `Waker`；
      既然没有注册过 `Waker`，未来也就没有任何外部事件能调用它的 `wake()` 把它送进队列．
      结果是该任务在创建后立刻因为没有任何剩余强引用（或即便保存在某处也无人驱动）而被直接丢弃或永久静默．
    ],
  )[
    在 `MiniExecutor::spawn` 中，为什么要把新创建的 `task` 立即通过 `self.sender.send(task)` 发送到就绪队列里？如果不发送，反应器能唤醒它吗？
  ]
]

#html.nav(class: "chapter-nav", aria-label: "文章导航")[
  #cite("/how/rust/async/pin-and-self-reference.typ")[← Pin 与自引用结构：为什么状态机不能随便移动]
  #cite("/how/rust/async/index.typ")[回到 Rust 异步机制]
  #cite("/how/rust/async/summary.typ")[总结与延伸阅读 →]
]
