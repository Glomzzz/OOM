#import "/lib/statements.typ": *

#let entry = (
  title: [固定类型状态与析构保证],
  date: "2026-10-15",
  author: "哈吉米4",
  parent: "/how/rust/async/pin-and-self-reference.typ",
)

#show: statement-page.with("definition/pinned-typestate", entry)

在 Rust 的内存模型中，对象所处的*位置*（即左值内存槽位）在其生命周期内可处于三种类型状态之一（参见 Ralf Jung 的形式化模型 #link("https://www.ralfj.de/blog/2018/04/05/a-formal-look-at-pinning.html")[_A Formal Look at Pinning_] 与 Without Boats 的 #link("https://without.boats/blog/pin/")[_Pin_]）：

1. *独占状态*：对象可被自由按位移动到新的内存位置，也可原地修改．
2. *共享借用状态*：在借用存续期间，对象暂停移动与独占修改，允许多个共享引用读取．
3. *固定状态*：一旦通过固定指针 `Pin<P>`（其中目标类型 `T: !Unpin`）使某内存位置上的对象进入固定状态，该对象将*永久留在原地*，不可再退回可自由移动的独占状态．

对于满足 `T: !Unpin` 的目标类型 `T`，位置 $p$ 处于*固定类型状态*的充要安全不变量（包含*析构保证*）为：

- *禁止按位搬移*：从进入固定状态起直到析构完成，位于地址 $p$ 的字节内容不得被移动到其他内存地址并继续作为 `T` 使用；
- *析构前禁止失效或重用内存*：在对该位置原地调用 `<T as Drop>::drop`（或等价的字段逐一原地析构）返回之前，底层内存槽位 $p$ 不得被提前释放、覆写或回收作其他用途．
  因此，安全代码虽可调用 `std::mem::forget(pinned_box)` 泄漏堆上的 `Pin<Box<T>>`（因为泄漏后那块堆内存永远不会被释放或重用），但不能在栈上伪造一个在退栈时不运行 `drop` 就直接回收栈帧内存的固定包装器．
