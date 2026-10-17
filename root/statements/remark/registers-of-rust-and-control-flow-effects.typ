#import "/lib/statements.typ": *

#let entry = (
  title: [控制流作用的四个语域与迭代–异步对偶],
  date: "2026-10-15",
  author: "哈吉米4",
  parent: "/how/rust/async/model.typ",
)

#show: statement-page.with("remark/registers-of-rust-and-control-flow-effects", entry)

Without Boats 在 #link("https://without.boats/blog/why-async-rust/")[_Why async Rust?_] 与 #link("https://without.boats/blog/the-registers-of-rust/")[_The registers of Rust_] 中指出，Rust 对*异步性*、*迭代*与*可失败性*三类控制流作用的处理遵循同一套模式：先把控制流具体化为一个普通特型或枚举类型，再围绕该类型提供四个不同抽象层级的*语域*（借自社会语言学中“针对不同场合采用的语言变体”）．

以迭代到异步的演进为例：2013 年以前，Rust 的迭代采用传入闭包的内部迭代器（推送模型），既难以编写交错推进两个序列的 `zip` 组合子，也无法在借用检查器下安全地从循环体提前返回引用．转为外部迭代器 `Iterator::next(&mut self) -> Option<Self::Item>`（拉取模型）后，迭代状态被收拢进单个结构体中．2016 年 Aaron Turon 与 Alex Crichton 设计 `Future` 时，放弃了每次组合（如 `join`）都需堆分配回调与引用计数的续延传递风格（CPS），将同样的外部拉取转化应用到了异步计算上．

这三类控制流作用在 Rust 中分别展开为四个语域：

- *核心语域*：手写底层状态机并直接实现 `Future::poll`、`Iterator::next` 或构造 `Result`．心智负担最高，但能精确控制内存布局与轮询细节．
- *消费语域*：在边界处终结并消费该作用，如执行器的 `block_on`／`spawn`、消费迭代器的 `for` 循环与 `collect`、解开 `Result` 的 `match`．
- *组合子语域*：用高阶函数（如 `map`、`and_then`、`join`）以函数式风格拼装状态机．局限在于闭包内部无法向外部代码块提前 `return`、`break` 或 `.await`．
- *控制流语域*：由编译器将命令式语法糖直接变换为状态机，如异步的 `async`／`.await`、可失败性的 `?`（以及尚未稳定的 `try` 块）和迭代的生成器 `gen`／`yield`．

当把异步与迭代正交组合为异步迭代器 `AsyncIterator`（社区常称 `Stream`）时，若将其视为一般协程特化的乘积，可以对比三者在每次挂起产出、最终返回与恢复传入参数上的对称关系（参见 Without Boats 的 #link("https://without.boats/blog/poll-next/")[_poll_next_]）：

- `Future`：每次挂起产出 `()`，最终返回 `Self::Output`，恢复时传入 `&mut Context<'_>`；
- `Iterator`：每次挂起产出 `Self::Item`，最终返回 `()`，恢复时传入 `()`；
- `AsyncIterator`（基于 `poll_next`）：每次挂起产出 `Poll<Self::Item>`，最终返回 `()`，恢复时传入 `&mut Context<'_>`．

由此可见，`AsyncIterator` 既是 `Iterator` 的异步化，也是 `Future` 的迭代化．采用 `poll_next(self: Pin<&mut Self>, cx: &mut Context<'_>) -> Poll<Option<Self::Item>>` 能将整个循环周期维持在单个被固定的状态机内；反之，若定义成 `async fn next(&mut self) -> Option<Self::Item>`，则会混用两个不同语域并拆成“长生命周期未固定迭代器 + 每次迭代新建的短生命周期 `Future`”两个状态机，在动态分发（`dyn AsyncIterator`）时难以避免逐次迭代的堆分配，也无法在迭代间隔保持侵入式等待队列节点的内存固定．
