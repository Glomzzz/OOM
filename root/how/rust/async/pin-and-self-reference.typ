#import "/lib/formal.typ": *

#show: formal-page.with(
  title: [Pin 与自引用结构：为什么状态机不能随便移动],
  description: [从跨挂起点的局部引用出发，图解自引用状态机在按位移动后的悬垂指针问题，并阐明 Pin、Unpin 与结构化投影的安全边界．],
  date: [2026-10-15],
  author: [哈吉米4],
  parent: "/how/rust/async/index.typ",
)

在 #cite("/how/rust/async/state-machine.typ")[async/await 脱糖] 中，我们暂时避开了一种常见写法：
如果在 `.await` 之前获取了一个局部变量的*引用*（`&T` 或 `&mut T`），并在 `.await` 之后继续使用这个引用，编译器生成的状态机会长什么样？
这个问题直接引出了标准库中的 `Pin<P>`．

= 跨挂起点的借用如何产生自引用结构体

看下面这段异步函数：它在局部变量 `buf` 上创建了一个引用 `ptr`，跨越一次 `.await` 后解引用读取该字节：

```rust
async fn self_ref_example() -> u8 {
    let buf = [10u8, 20, 30, 40];
    let ptr: &u8 = &buf[1];
    yield_once().await;
    *ptr
}
```

按照上一篇总结的存活变量规则：
数组 `buf` 在 `.await` 之后还要通过 `ptr` 被读取，因此 `buf` 必须存进 `Waiting` 状态变体；
引用 `ptr` 在 `.await` 之前创建、在 `.await` 之后解引用，因此 `ptr` 也必须存进同一个 `Waiting` 状态变体．

于是，`Waiting` 状态的内存布局变成了：*同一个结构体内部的字段 `ptr`，保存着指向旁边的字段 `buf[1]` 的内存地址*．
这就是*自引用结构*．

= 为什么按位移动会摧毁自引用结构

在 Rust 的基本内存模型中，所有类型默认都是*可按位移动*的：
无论是把一个值按值传给函数、从函数返回，还是在拿到 `&mut T` 时调用 `std::mem::swap(&mut x, &mut y)` 或 `std::mem::replace`，
编译器都只是调用 `memcpy` 把旧地址上的字节原封不动地复制到新地址，并不会通知或修正结构体内部的任何指针字段．

当 `self_ref_example()` 处于未启动的 `Start` 状态时，`buf` 和 `ptr` 都还没有构造，此时无论怎么把状态机搬来搬去都毫无问题．
但一旦第一次调用 `poll` 进入了 `Waiting` 状态，字段 `ptr` 里就已经写死了当时 `buf[1]` 所在的绝对内存地址（比如 `0x1001`）．
如果此时外部代码通过 `&mut SelfRefFuture` 调用 `std::mem::swap`，把这个处于挂起状态的状态机搬到了新地址 `0x2000`：

#fig({
  import "@preview/cetz:0.3.4"
  cetz.canvas(length: 0.9cm, {
    import cetz.draw: *

    // Before move (at 0x1000)
    content((2.6, 4.1), [*移动前（地址 `0x1000`）*])
    rect((0, 2.2), (5.2, 3.4), fill: blue.lighten(88%), stroke: 0.8pt + blue.darken(20%))
    line((1.4, 2.2), (1.4, 3.4), stroke: 0.6pt + blue.darken(20%))
    line((3.3, 2.2), (3.3, 3.4), stroke: 0.6pt + blue.darken(20%))
    content((0.7, 2.8), [`tag`])
    content((2.35, 2.8), [`buf` \ `0x1001`])
    content((4.25, 2.8), [`ptr` \ `0x1001`])

    // Valid internal pointer
    bezier((4.25, 3.4), (2.35, 3.4), (3.8, 4.0), (2.8, 4.0), mark: (end: "stealth"), stroke: 0.9pt + green.darken(20%))

    // Move arrow
    line((5.5, 2.8), (7.5, 2.8), mark: (end: "stealth"), stroke: 1pt)
    content((6.5, 3.25), [`mem::swap`])
    content((6.5, 2.35), [按位复制])

    // After move: old memory at 0x1000 is now invalid/overwritten, new at 0x2000
    content((10.4, 4.1), [*移动后（新地址 `0x2000`）*])
    rect((7.8, 2.2), (13.0, 3.4), fill: orange.lighten(85%), stroke: 0.8pt + orange.darken(20%))
    line((9.2, 2.2), (9.2, 3.4), stroke: 0.6pt + orange.darken(20%))
    line((11.1, 2.2), (11.1, 3.4), stroke: 0.6pt + orange.darken(20%))
    content((8.5, 2.8), [`tag`])
    content((10.15, 2.8), [`buf` \ `0x2001`])
    content((12.05, 2.8), [`ptr` \ `0x1001`])

    // Dangling pointer back to old 0x1001!
    bezier((12.05, 2.2), (2.35, 2.2), (9.5, 0.9), (4.5, 0.9), mark: (end: "stealth"), stroke: (paint: red.darken(10%), thickness: 1pt, dash: "dashed"))
    content((7.2, 0.55), text(fill: red.darken(15%))[`ptr` 仍指向旧地址 `0x1001`（悬垂指针！）])
  })
})

如上图所示，按位复制后，新结构体里的 `buf[1]` 已经搬到了 `0x2001`，但新结构体里的 `ptr` 存的值仍然是 `0x1001`！
等到下一次调用 `poll` 恢复执行 `*ptr` 时，程序就会去读取已经被释放或覆写的旧地址 `0x1001`，造成悬垂指针解引用（use-after-free）．

= `Pin<P>` 的设计：限制拿到 `&mut T`

怎么在编译器不介入运行时重写指针的前提下阻止这场灾难？
关键观察在于：*在安全 Rust 中，要想把一个已经在内存里落脚的值移动走，调用者要么拥有该值的按值所有权 `T`，要么拥有指向它的可变引用 `&mut T`（从而调用 `mem::swap` 或 `mem::replace`）．*

反之，如果一个值已经被放进了某块内存，且此后再也不允许安全代码直接拿到它的 `&mut T`（除非能证明移动它不会破坏任何不变量），那么安全代码就永远无法调用 `mem::swap` 把它从当前内存地址搬走！

这就是 `Pin<P>` 的全部作用．
`Pin<P>` 是一个编译期的零大小包装器，它包装的不是目标值 `T` 本身，而是*指向 `T` 的指针类型 `P`*（例如 `Pin<&mut T>` 或 `Pin<Box<T>>`）：

```rust
#[repr(transparent)]
pub struct Pin<P> {
    pointer: P,
}
```

一旦你把指针 `P`（假设指向目标类型 `T`）放进了 `Pin<P>`，就相当于对编译器立下了一条*地址固定契约*：

*从被固定的这一刻起，直到目标值 `T` 在原地被调用 `Drop::drop` 销毁为止，目标值 `T` 所在的内存字节绝不会被搬移到其他地址，该块内存也绝不会被提前挪作他用．*

为了守护这条契约，当 `T` 可能包含自引用时，`Pin<&mut T>` 的安全接口*故意不提供*获取 `&mut T` 的方法：
想从 `Pin<&mut T>` 中取出裸的 `&mut T`（即 `Pin::get_unchecked_mut`），必须使用 `unsafe`，并由编写者人工保证不会利用这个 `&mut T` 把值移走．

这也是为什么 `Future::poll` 的签名必须写成：

```rust
fn poll(self: Pin<&mut Self>, cx: &mut Context<'_>) -> Poll<Self::Output>;
```

因为只有第一次调用 `poll` 时，状态机才会开始执行函数体并构造内部自引用指针；
将 `poll` 的接收者规定为 `Pin<&mut Self>`，就保证了：*任何想要开始驱动（`poll`）状态机的人，都必须先把状态机固定在某块内存上*，此后再也无法在两次 `poll` 之间用 `mem::swap` 移动它．

下面将上述直觉整理为精确的定义：

#statement("definition/pinned-typestate")

为什么 Rust 没有像 C++ 那样引入移动构造函数、或者把自引用编译成相对偏移量、或者直接加一个 `?Move` 特型？为什么许多开发者觉得 `Pin` 比普通引用难用得多？详见下面的附注：

#statement("note/why-not-move-constructors-or-move-trait")

= `Unpin`：绝大多数类型的通行证

如果所有类型一旦放进 `Pin<&mut T>` 就再也不能安全地拿到 `&mut T`，那么我们在 #cite("/how/rust/async/future-and-waker.typ")[Future 与 Waker] 中手写 `Countdown` 时，为什么可以直接在 `poll(mut self: Pin<&mut Self>, ...)` 里写 `self.remaining -= 1`？

因为 `Countdown` 里只有一个整数 `u32`，根本没有任何自引用指针！
把 `Countdown` 在内存里随便 `mem::swap` 到哪里，它的整数值都完好无损．

为了不限制这些“随便移动也安全”的普通类型，标准库定义了一个自动特型 `Unpin`：

- *绝大多数普通类型自动实现 `Unpin`*：`u32`、`String`、`Vec<T>`、`&mut T`、`Box<T>`，以及完全由 `Unpin` 字段组成的结构体和枚举，全都默认实现 `Unpin`．
- *对实现了 `T: Unpin` 的类型，`Pin<&mut T>` 等同于普通的 `&mut T`*：你可以用安全的 `Pin::new(&mut x)` 随意构造 `Pin<&mut T>`，也可以通过 `DerefMut` 或 `Pin::into_inner` 随时安全地变回 `&mut T`．
- *编译器为 `async` 生成的状态机默认实现 `!Unpin`*（利用内部标记类型 `PhantomPinned`）：因此由 `async fn` 或 `async { ... }` 产生的 `Future` 是真正的受保护对象，不能用 `Pin::new` 直接从普通引用构造．

可以用下面的决策树来理清 `Pin<P>` 与 `T: Unpin` 的关系：

#fig({
  import "@preview/fletcher:0.5.8" as fletcher: diagram, node, edge
  import fletcher.shapes: diamond

  let nd(pos, body, tint, width: 42mm) = node(
    pos,
    align(center, body),
    width: width,
    fill: tint.lighten(85%),
    stroke: 0.8pt + tint.darken(15%),
    corner-radius: 4pt,
    inset: 6pt,
  )

  diagram(
    spacing: (18mm, 10mm),
    edge-stroke: 0.8pt,

    node(
      (0.5, 0),
      align(center)[目标类型 `T` \ 是否实现 `Unpin`？],
      shape: diamond,
      fill: yellow.lighten(80%),
      stroke: 0.8pt + yellow.darken(25%),
      inset: 6pt,
    ),

    nd((0, 1), [
      *`T: Unpin`（普通结构体、整数等）* \
      移动 `T` 不会破坏内部不变量 \
      `Pin::new(&mut t)` 完全安全 \
      可随时通过 `DerefMut` 拿回 `&mut T`
    ], green, width: 48mm),

    nd((1, 1), [
      *`T: !Unpin`（`async` 状态机等）* \
      一旦开始 `poll` 即可能含自引用 \
      禁止安全代码从 `Pin<&mut T>` 取 `&mut T` \
      必须用 `Box::pin(t)` 或 `pin!(t)` 固定
    ], orange, width: 48mm),

    edge((0.5, 0), (0, 1), "-|>", label: [是], label-side: right),
    edge((0.5, 0), (1, 1), "-|>", label: [否], label-side: left),
  )
})

= 怎样在栈上或堆上固定一个 `!Unpin` 的 `Future`

既然 `async` 状态机不满足 `Unpin`，当我们要在自己的代码里手动调用它的 `poll`，或者把它传给要求 `F: Unpin` 的组合子（例如前面我们写的 `Double<F>`）时，怎样把它变成 `Pin`？
标准库提供了两种零 `unsafe` 的标准方式：

1. *堆固定 `Box::pin(fut)`*：
   把状态机移动到堆上新分配的 `Box` 里，并返回 `Pin<Box<F>>`．
   因为值一旦放进堆上的 `Box` 并被 `Pin` 封存，只要不把值从 `Box` 中拆出来，即使 `Pin<Box<F>>` 这个胖指针本身在栈上到处移动，*堆上那块存放状态机的物理地址也始终固定不变*．
   更进一步，对于任意 `F`（哪怕 `F: !Unpin`），*指针类型 `Pin<Box<F>>` 自身始终实现 `Unpin` 且实现 `Future`*！
2. *栈固定 `std::pin::pin!(fut)`*（Rust 1.68 引入）：
   通过局部宏生成的匿名生命周期与同名变量遮蔽，把值藏在当前函数栈帧的一个不可直接访问的临时槽位上，只向后续代码暴露一个 `Pin<&mut F>`．
   由于原来的值变量名已被遮蔽，后续代码在栈帧退栈析构前绝对拿不到原值的移动权，从而在不分配任何堆内存的前提下完成了固定．

```rust
use std::pin::{pin, Pin};
use std::future::Future;

async fn example_task() -> u32 { 42 }

fn drive_examples() {
    // 方式 1：堆上固定，得到 Pin<Box<impl Future>>（可跨函数返回或移动）
    let mut heap_fut: Pin<Box<_>> = Box::pin(example_task());
    let _p1: Pin<&mut _> = heap_fut.as_mut();

    // 方式 2：栈上固定，零堆分配，直接得到 Pin<&mut impl Future>
    let mut stack_fut = pin!(example_task());
    let _p2: Pin<&mut _> = stack_fut.as_mut();
}
```

= 结构化固定投影

最后还有一个编写自定义组合子时经常遇到的问题：
在 #cite("/how/rust/async/future-and-waker.typ")[Future 与 Waker] 的 `Double<F>` 中，我们为了能写 `Pin::new(&mut self.inner).poll(cx)`，加上了 `F: Unpin` 的约束．
如果想要让 `Double<F>` 也能直接内联包装一个 `!Unpin` 的 `async` 状态机 `F`，我们就需要完成一步转换：
*已知外层结构体是固定的 `self: Pin<&mut Double<F>>`，怎样得到内层字段的固定借用 `Pin<&mut F>`？*

从 `Pin<&mut Struct>` 取得字段的 `Pin<&mut Field>` 称为*结构化固定投影*．
这一步在标准库里不能自动发生，因为如果外层结构体 `Double<F>` 自己额外手动实现了 `Unpin`（脱离了字段 `F` 的约束），或者在自己的 `Drop::drop(&mut self)` 实现里偷偷调用 `mem::swap` 把 `self.inner` 移走了，那么内层字段 `F` 的固定承诺就会被外层打破！

在工程实践中，除非为了教学研究，*不要手写 `unsafe` 的 `map_unchecked_mut` 来做字段投影*，而是直接使用社区经过严格形式化审查的 `pin-project-lite`（或 `pin-project`）宏，由宏自动生成安全的投影结构并静态禁止冲突的 `Drop` 与 `Unpin` 实现．

= 练习：理解 `Pin` 的边界

#exercise-group(2)[
  #exercise(
    "4.1",
    [移动 `Pin<Box<F>>` 为什么是安全的],
    hint: [
      区分“指针本身所在的栈地址”和“指针所指向的堆上状态机地址”．
    ],
    answer: [
      `Pin<P>` 承诺地址不变的对象是*指针 `P` 所指向的目标值 `F`*，而不是指针 `P` 本身．
      在 `Pin<Box<F>>` 中，状态机 `F` 存放在堆内存上（假设堆地址为 `0x9000`），它内部的自引用指针指向的也是 `0x9000` 附近的堆地址；
      而 `Pin<Box<F>>` 本身只是一个存放着 `0x9000` 这个地址值的 8 字节栈变量．
      对两个 `Pin<Box<F>>` 变量调用 `mem::swap`，仅仅交换了栈上的两个 8 字节地址值，堆上 `0x9000` 处的状态机字节连同它内部的自引用关系连一比特都没有移动．
      因此，无论 `F` 是否满足 `Unpin`，`Pin<Box<F>>` 自身总是满足 `Unpin`．
    ],
  )[
    设 `fut` 是由包含跨 `.await` 自引用的 `async` 块生成的 `!Unpin` 状态机．
    将它放进 `let mut b1 = Box::pin(fut1); let mut b2 = Box::pin(fut2);` 后，为什么安全代码依然可以合法地调用 `std::mem::swap(&mut b1, &mut b2)`？这会破坏 `fut1` 内部的自引用指针吗？
  ]

  #exercise(
    "4.2",
    [什么时候状态机还没产生自引用],
    hint: [
      回想 `async fn` 被调用但尚未第一次调用 `poll` 时，它处于哪个枚举变体．
    ],
    answer: [
      因为调用 `let f = self_ref_example();` 时，函数体内的代码一行都还没有执行！
      此时 `f` 处于初始变体 `Start`，局部变量 `buf` 和指向它的引用 `ptr` 根本还没有被构造出来．
      在这个阶段，无论把 `f` 按值传给 `tokio::spawn(f)` 还是装进 `Box::pin(f)`，移动的都只是尚未建立任何内部指针的初始参数．
      直到 `f` 被固定在最终归宿（如执行器的堆任务块）并第一次通过 `Pin<&mut Self>` 调用 `poll` 时，它才会进入 `Waiting` 状态并真正写下自引用地址——而从那一刻起，它就再也不会被移动了．
    ],
  )[
    既然 `self_ref_example()` 返回的状态机类型是 `!Unpin` 的自引用结构体，为什么在固定（pin）它之前，我们仍然可以把 `let f = self_ref_example();` 按值传给 `Box::pin(f)` 或 `tokio::spawn(f)`（这明明发生了一次按值移动）？
  ]
]

#html.nav(class: "chapter-nav", aria-label: "文章导航")[
  #cite("/how/rust/async/state-machine.typ")[← async/await 脱糖：状态机编译]
  #cite("/how/rust/async/index.typ")[回到 Rust 异步机制]
  #cite("/how/rust/async/executor-and-reactor.typ")[执行器与反应器：从零拼出异步运行时 →]
]
