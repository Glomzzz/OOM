#import "/lib/formal.typ": *

#show: formal-page.with(
  title: [async/await 脱糖：状态机编译],
  description: [追踪 Rust 编译器怎样按挂起点切分控制流、分析跨挂起点存活变量，并将 async 函数变换为实现了 Future 的枚举状态机．],
  date: [2026-10-15],
  author: [哈吉米4],
  parent: "/how/rust/async/index.typ",
)

在 #cite("/how/rust/async/future-and-waker.typ")[Future 与 Waker] 中，手写一个简单的 `Double` 组合子只需要十几行代码；
但如果一段异步逻辑包含多个顺序步骤、条件分支与循环，且后一步依赖前一步算出的局部变量，手写 `Future` 就会变成繁琐的状态维护工作．
Rust 的 `async` 与 `.await` 正是为消除这种样板代码而设计的*语法糖*：
编译器在后台将看似顺序执行的异步代码块，静态改写为一个实现了 `Future` 的枚举状态机．

= 挂起点如何切分控制流

先看一个具体的异步函数：它接收初始值 `base`，依次等待两个异步计算 `step_one` 和 `step_two`，最后返回累加结果：

```rust
async fn fetch_and_add(base: u32) -> u32 {
    let tmp = base + 1;
    let a = step_one(tmp).await;
    let b = step_two(a).await;
    base + a + b
}
```

在这段代码中，只有两处可能发生挂起：`step_one(tmp).await` 与 `step_two(a).await`．
这两个 `.await` 表达式把整个函数的执行过程切成了三段不间断的同步代码块（加上首尾的未启动状态与已完成状态）：

1. *初始段（从入口到第一个 `.await`）*：接收参数 `base`，计算 `let tmp = base + 1`，构造子状态机 `fut1 = step_one(tmp)`，并立即对其发起第一次 `poll`．
2. *中间段（从第一个 `.await` 恢复到第二个 `.await`）*：当 `fut1` 返回 `Poll::Ready(a)` 时，拿到 `a`，构造第二个子状态机 `fut2 = step_two(a)`，并对其发起 `poll`．
3. *收尾段（从第二个 `.await` 恢复到函数返回）*：当 `fut2` 返回 `Poll::Ready(b)` 时，计算 `base + a + b`，返回 `Poll::Ready(base + a + b)`，并将自身状态标记为已完成．

= 跨挂起点的存活变量分析

要把这三段代码装进一个枚举类型，编译器需要回答一个问题：*每个枚举变体（状态）里需要保存哪些字段？*
答案取决于变量的生命周期是否跨越了 `.await` 挂起点：

- 变量 `tmp` 在第一个 `.await` 之前算出，并在构造 `step_one(tmp)` 时立即按值消耗，第一个 `.await` 之后再也不会用到 `tmp`．
  因此，`tmp` 只需要在执行第一次 `poll` 时暂存在工作线程的普通调用栈上，*不需要*存进状态机结构体里．
- 参数 `base` 从函数入口一直存活到最后一行 `base + a + b`，跨越了两个 `.await` 挂起点，因此必须在状态一与状态二中都保存 `base`．
- 变量 `a` 在第一个 `.await` 结束时产生，在第二个 `.await` 结束后的 `base + a + b` 中还要使用，跨越了第二个 `.await`，因此必须在状态二中保存 `a`．
- 变量 `b` 在第二个 `.await` 结束时产生，并在同一段同步代码中立即用于计算返回值，不跨越任何 `.await`，因此也留在普通线程栈上即可．

把控制流切分与变量存活范围画在同一张图上，就能直接看出状态机每个阶段的内存需求：

#fig({
  import "@preview/fletcher:0.5.8" as fletcher: diagram, node, edge

  let st-node(pos, title, fields, tint, width: 34mm) = node(
    pos,
    align(left)[
      #align(center)[*#title*]
      #v(-4pt)
      #line(length: 100%, stroke: 0.5pt + tint.darken(20%))
      #text(size: 9pt)[#fields]
    ],
    width: width,
    fill: tint.lighten(85%),
    stroke: 0.8pt + tint.darken(15%),
    corner-radius: 4pt,
    inset: 6pt,
  )

  diagram(
    spacing: (18mm, 10mm),
    edge-stroke: 0.8pt,

    st-node((0, 0), [Start], [`base: u32`], gray, width: 26mm),
    st-node((1, 0), [WaitingOne], [`base: u32` \ `fut1: StepOneFut`], blue, width: 34mm),
    st-node((2, 0), [WaitingTwo], [`base: u32` \ `a: u32` \ `fut2: StepTwoFut`], orange, width: 34mm),
    st-node((3, 0), [Done], [（无字段）], green, width: 24mm),

    edge((0, 0), (1, 0), "-|>", label: text(size: 8.5pt)[算 `tmp` \ 造 `fut1`], label-side: left),
    edge((1, 0), (1, 0), "-|>", label: text(size: 8.5pt)[`Pending`], bend: 130deg),
    edge((1, 0), (2, 0), "-|>", label: text(size: 8.5pt)[`Ready(a)` \ 造 `fut2`], label-side: left),
    edge((2, 0), (2, 0), "-|>", label: text(size: 8.5pt)[`Pending`], bend: 130deg),
    edge((2, 0), (3, 0), "-|>", label: text(size: 8.5pt)[`Ready(b)` \ 返回和], label-side: left),
  )
})

= 手工还原编译器生成的状态机

按照上图的四个状态，我们可以把 `fetch_and_add` 脱糖后的等价 Rust 代码完整写出来．
为了聚焦状态转移逻辑，这里假设 `StepOneFut` 与 `StepTwoFut` 均满足 `Unpin`（含跨挂起点借用的非 `Unpin` 情形将在下一篇单独处理）：

```rust
use std::future::Future;
use std::pin::Pin;
use std::task::{Context, Poll};

enum FetchAndAddFuture {
    /// 尚未被 poll 过的初始状态，只保存函数参数
    Start { base: u32 },
    /// 正在等待第一个 .await
    WaitingOne { base: u32, fut1: StepOneFut },
    /// 正在等待第二个 .await
    WaitingTwo { base: u32, a: u32, fut2: StepTwoFut },
    /// 已经返回过 Ready，不可再次 poll
    Done,
}

fn fetch_and_add(base: u32) -> FetchAndAddFuture {
    // 调用 async fn 只是构造初始状态，不执行函数体
    FetchAndAddFuture::Start { base }
}
```

接下来看它的 `Future::poll` 实现．
注意里面使用了一个 `loop` 循环：当 `fut1` 恰好在第一次被 `poll` 时就立刻返回 `Poll::Ready(a)`（例如命中了内存缓存，无需真正等待 I/O），状态机不需要返回到调用者手中，而是可以直接修改自身状态为 `WaitingTwo` 并在同一次 `poll` 调用里顺着 `loop` 继续推进 `fut2`：

```rust
impl Future for FetchAndAddFuture {
    type Output = u32;

    fn poll(mut self: Pin<&mut Self>, cx: &mut Context<'_>) -> Poll<u32> {
        let this = &mut *self;
        loop {
            match this {
                FetchAndAddFuture::Start { base } => {
                    let base = *base;
                    // tmp 只在当前线程栈上存活，不进入枚举字段
                    let tmp = base + 1;
                    let fut1 = step_one(tmp);
                    *this = FetchAndAddFuture::WaitingOne { base, fut1 };
                }
                FetchAndAddFuture::WaitingOne { base, fut1 } => {
                    match Pin::new(fut1).poll(cx) {
                        Poll::Ready(a) => {
                            let base = *base;
                            let fut2 = step_two(a);
                            // 转移到下一状态，通过外层 loop 立即尝试 poll fut2
                            *this = FetchAndAddFuture::WaitingTwo { base, a, fut2 };
                        }
                        Poll::Pending => return Poll::Pending,
                    }
                }
                FetchAndAddFuture::WaitingTwo { base, a, fut2 } => {
                    match Pin::new(fut2).poll(cx) {
                        Poll::Ready(b) => {
                            let result = *base + *a + b;
                            *this = FetchAndAddFuture::Done;
                            return Poll::Ready(result);
                        }
                        Poll::Pending => return Poll::Pending,
                    }
                }
                FetchAndAddFuture::Done => {
                    panic!("async fn polled after completion");
                }
            }
        }
    }
}
```

对照最后那个 `FetchAndAddFuture::Done` 分支：
这正是我们在 #cite("/how/rust/async/future-and-waker.typ")[Future 与 Waker] 中提到的“契约第一条”的代码体现——一旦状态机吐出 `Poll::Ready(result)`，它就会把自身状态覆写为 `Done`；若外部调用者违反协议再次 `poll` 它，状态机就会直接触发 `panic!`．

= 状态机的内存布局与两项工程推论

观察 `FetchAndAddFuture` 这个 `enum` 的定义，Rust 的枚举采用*带标签联合体*布局：
整个状态机在内存中的大小，等于状态标签（`discriminant`）加上*最大那个状态变体*的大小；
不同状态变体（例如 `WaitingOne` 里的 `fut1` 与 `WaitingTwo` 里的 `fut2`）在物理内存上*复用同一块字节区域*．

#fig({
  import "@preview/cetz:0.3.4"
  cetz.canvas(length: 0.9cm, {
    import cetz.draw: *

    content((-2.4, 2.7), [*`Start`*])
    rect((0, 2.3), (1.8, 3.1), fill: gray.lighten(75%), stroke: 0.8pt)
    content((0.9, 2.7), [`tag=0`])
    rect((1.8, 2.3), (3.4, 3.1), fill: blue.lighten(80%), stroke: 0.8pt)
    content((2.6, 2.7), [`base`])
    rect((3.4, 2.3), (10.0, 3.1), fill: gray.lighten(92%), stroke: (paint: gray, thickness: 0.7pt, dash: "dashed"))
    content((6.7, 2.7), [未使用的填充区])

    content((-2.4, 1.4), [*`WaitingOne`*])
    rect((0, 1.0), (1.8, 1.8), fill: gray.lighten(75%), stroke: 0.8pt)
    content((0.9, 1.4), [`tag=1`])
    rect((1.8, 1.0), (3.4, 1.8), fill: blue.lighten(80%), stroke: 0.8pt)
    content((2.6, 1.4), [`base`])
    rect((3.4, 1.0), (7.6, 1.8), fill: orange.lighten(78%), stroke: 0.8pt)
    content((5.5, 1.4), [`fut1: StepOneFut`])
    rect((7.6, 1.0), (10.0, 1.8), fill: gray.lighten(92%), stroke: (paint: gray, thickness: 0.7pt, dash: "dashed"))
    content((8.8, 1.4), [填充])

    content((-2.4, 0.1), [*`WaitingTwo`*])
    rect((0, -0.3), (1.8, 0.5), fill: gray.lighten(75%), stroke: 0.8pt)
    content((0.9, 0.1), [`tag=2`])
    rect((1.8, -0.3), (3.4, 0.5), fill: blue.lighten(80%), stroke: 0.8pt)
    content((2.6, 0.1), [`base`])
    rect((3.4, -0.3), (5.0, 0.5), fill: purple.lighten(80%), stroke: 0.8pt)
    content((4.2, 0.1), [`a`])
    rect((5.0, -0.3), (10.0, 0.5), fill: green.lighten(78%), stroke: 0.8pt)
    content((7.5, 0.1), [`fut2: StepTwoFut`])

    line((0, -0.9), (10.0, -0.9), mark: (start: "stealth", end: "stealth"), stroke: 0.8pt)
    content((5.0, -1.4), [`size_of::<FetchAndAddFuture>()` 由最宽的变体决定])
  })
})

只要记住“异步函数是捕获跨 `.await` 变量的枚举状态机”，日常开发中两个常见的现象就容易理解了：

== 为什么跨 `.await` 的大数组会撑爆状态机大小

如果在异步函数中声明了一个 `let buf = [0u8; 65536];`，并且这个 `buf` 的作用域跨越了某个 `.await` 点，
编译器就必须把这个 64 KB 的数组作为字段直接塞进状态机枚举的变体中．
当外层异步函数层层内联嵌套时，顶层 `Future` 的体积会迅速膨胀到数百 KB，甚至在将其从栈上移动到 `tokio::spawn` 的瞬间引发线程栈溢出．
反之，如果用代码块 `{ let buf = ...; }` 把大变量的作用域限制在两个 `.await` 之间（使其在进入下一个 `.await` 前就析构），或者将其放入堆上的 `Vec<u8>`／`Box<[u8]>`，状态机里就只需要保存几个机器字长的胖指针．

== 为什么跨 `.await` 持有 `MutexGuard` 会破坏 `Send` 或引发死锁

在多线程工作窃取执行器（如 `tokio::spawn`）中，一个任务在挂起前可能运行在线程 1 上，被唤醒后则可能被线程 2 偷走继续执行 `poll`．
因此，`tokio::spawn` 要求传入的顶层 `Future` 满足 `Send`（可以安全地跨线程转移所有权）．

编译器怎样判断 `FetchAndAddFuture` 是否实现 `Send`？
规则直接按结构归纳：*当且仅当状态机中所有状态变体保存的字段类型全都满足 `Send` 时，整个状态机才满足 `Send`*．

标准库的同步互斥锁守卫 `std::sync::MutexGuard<'_, T>` 专门没有实现 `Send`（因为 POSIX 线程库等底层操作系统原语要求加锁与解锁必须在同一个操作系统线程上完成）．
如果你写出如下代码：

```rust
async fn bad_lock(mutex: &std::sync::Mutex<u32>) {
    let mut guard = mutex.lock().unwrap();
    *guard += 1;
    some_io().await; // guard 的作用域若延续到这里，就会进入状态机字段！
}
```

只要 `guard` 跨过了 `some_io().await`，编译器就必须把 `guard: MutexGuard<'_, u32>` 存进 `WaitingIo` 状态变体中，从而直接传染整个状态机，使其失去 `Send`，导致外层的 `tokio::spawn(bad_lock(...))` 编译报错．
即使不报编译错误，在持锁期间 `.await` 挂起也会让当前工作线程在锁未释放的情况下切去运行别的任务；若刚好切到的另一个任务也要获取同一把同步锁，整个工作线程就会当场死锁．
因此，同步锁的守卫应当在 `.await` 之前显式 `drop(guard)`（或用局部代码块括起来），使其完全停留在当前那次 `poll` 的线程栈上，绝不进入状态机字段．

= 练习：状态机大小与字段分析

#exercise-group(2)[
  #exercise(
    "3.1",
    [判断哪些局部变量会进入状态机],
    hint: [
      画出唯一那个 `.await` 的位置，逐一检查每个变量是在 `.await` 之前最后一次使用、之后才定义，还是在 `.await` 前定义且在 `.await` 后仍被读取或析构．
    ],
    answer: [
      唯一需要保存在 `Waiting` 状态变体中的局部变量是 *`x`*（连同正在被等待的子状态机 `work().await`）．
      - `a`：在局部代码块 `{ ... }` 内定义并在 `.await` 之前就已经离开作用域销毁，只在第一次 `poll` 的调用栈上存在，*不进入*状态机．
      - `x`：在 `.await` 之前算出，在 `.await` 之后的 `x + y + z` 中仍要读取，跨越了挂起点，*必须进入*状态机．
      - `y` 与 `z`：都在 `.await` 完成之后才定义并在返回前用完，期间不再经过任何挂起点，只在最后一次 `poll` 的调用栈上存在，*不进入*状态机．
    ],
  )[
    分析下面这段异步函数中，`a`、`x`、`y`、`z` 四个局部变量有哪些会被编译器放进挂起状态的枚举变体字段中：

    ```rust
    async fn compute(input: u64) -> u64 {
        let x = {
            let a = [0u64; 1024];
            input + a[0]
        };
        let y = work().await;
        let z = y * 2;
        x + y + z
    }
    ```
  ]

  #exercise(
    "3.2",
    [为什么直接递归的 `async fn` 无法确定类型大小],
    hint: [
      回想 `Term` 语法树为什么不能直接写 `Succ(Term)` 而必须写 `Succ(Box<Term>)`，再对照 `async fn` 脱糖后的状态机字段．
    ],
    answer: [
      假设 `async fn countdown(n: u32)` 直接在函数体内调用 `countdown(n - 1).await`．
      编译器将其脱糖为状态机类型 `CountdownFuture` 时，在挂起等待递归调用的状态变体里，必须内联保存一个被等待的子状态机字段 `fut: CountdownFuture`．
      这导致 `CountdownFuture` 的定义内部直接包含了未加指针间接层的 `CountdownFuture` 自身，其类型大小满足方程 $S = "tag" + 4 + S$，在编译期无穷大．

      解决方法与递归枚举相同：在递归挂起点处引入堆分配间接层（如 `Box::pin(countdown(n - 1)).await`），使状态机字段里保存的只是一个固定大小的 `Pin<Box<...>>` 指针．
      （注：自 Rust 1.77 起，只要递归调用点明确写出了 `Box::pin(...)` 等指针包装，编译器已支持直接编写递归 `async fn`．）
    ],
  )[
    用本节介绍的状态机内存布局解释：为什么不加 `Box::pin` 的直接递归 `async fn` 会触发编译器的“无限大小类型（recursive `async fn`）”错误？
  ]
]

#html.nav(class: "chapter-nav", aria-label: "文章导航")[
  #cite("/how/rust/async/future-and-waker.typ")[← Future 与 Waker：基于轮询的异步契约]
  #cite("/how/rust/async/index.typ")[回到 Rust 异步机制]
  #cite("/how/rust/async/pin-and-self-reference.typ")[Pin 与自引用结构：为什么状态机不能随便移动 →]
]
