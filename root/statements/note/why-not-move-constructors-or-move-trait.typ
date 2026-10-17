#import "/lib/statements.typ": *

#let entry = (
  title: [自引用结构的替代方案与 Pin 的可用性断崖],
  date: "2026-10-15",
  author: "哈吉米4",
  parent: "/how/rust/async/pin-and-self-reference.typ",
)

#show: statement-page.with("note/why-not-move-constructors-or-move-trait", entry)

在引入 `Pin<P>` 之前，Rust 设计团队曾评估过另外三类支持自引用状态机的方案，但均因破坏系统级假设或向后兼容性而被放弃（详见 Without Boats 的 #link("https://without.boats/blog/pin/")[_Pin_] 与 #link("https://without.boats/blog/pinned-places/")[_Pinned places_]）：

1. *移动构造函数*：像 C++ 一样在每次移动对象时运行自定义代码修正内部指针．
   这在 Rust 中不可行：一方面，Rust 从早期就确立了“移动永远只是机械的按位 `memcpy`”这一基本准则，大量现有代码依赖此假设；另一方面，指向状态机内部字段的借用未必直接存放在结构体的表层字段里，也可能被塞进 `Vec<&u8>` 或传入内层子状态机，要在移动时自动追踪并修正所有内部指针，实质上需要类似移动式垃圾回收器的运行时追踪能力．
2. *相对偏移指针*：将指向自身字段的引用编译为相对于结构体起始地址的字节偏移量．
   这同样不可行，因为编译器无法在编译期判定一个引用究竟是不是自引用．例如在 `if cond { r = &mut local_var; } foo(r).await;` 中，传入 `foo` 的参数 `r: &mut i32` 在不同分支下可能指向状态机内部，也可能指向外部调用栈或堆；由于 `foo` 是独立编译的普通函数，它期望接收统一的普通机器指针，不能把全语言的 `&mut T` 都改成带分支判断的胖指针．
3. *`?Move` 特型*：类似 `?Sized`，令自引用类型不实现 `Move`，规定一旦对 `!Move` 类型取引用就禁止后续移动．
   该方案受阻于向后兼容性：标准库中大量既有特型（如 `DerefMut::Target`、`Iterator::Item`、`IntoFuture::IntoFuture`）的关联类型默认隐含了“可移动”约束（例如泛型代码可以合法地写 `mem::swap(&mut *r1, &mut *r2)`）．在已稳定的特型关联类型上补加 `: ?Move` 会破坏依赖旧约束的调用方，不加则无法将 `!Move` 状态机放进这些特型接口中．

正因如此，Rust 最终将“固定”设计为纯标准库指针包装器 `Pin<P>`，在不修改既有特型签名、完全向后兼容的前提下解决了安全问题．但把本属于*内存位置*的属性用纯库级类型模拟，也造成了用户从高层 `async`/`await` 下潜到手写 `Future` 时的“复杂性断崖”：

- *缺少隐式重借用*：普通可变引用 `&mut T` 虽不实现 `Copy`，但编译器在多次传参时会自动插入隐式重借用 `&mut *x`；而 `Pin<&mut T>` 是普通库结构体，连续使用两次就会报所有权移动错误，必须手动调用 `fut.as_mut()`．
- *缺少语法级字段投影与 `&mut self` 析构冲突*：从 `Pin<&mut Struct>` 访问字段无法直接使用 `.field` 语法，且因为 `Drop::drop(&mut self)` 早在 Rust 1.0 就规定接收未固定的 `&mut self`，用户可以在析构函数里调用 `mem::swap` 把自引用字段移走，迫使社区必须借助 `pin-project-lite` 等宏在编译期静态拦截冲突的 `Drop` 与 `Unpin` 实现．
  Without Boats 据此提出了“固定位置”（如 `let pinned mut x` 与 `&pinned mut`）的语言级扩展构想，旨在保持与现有 `Pin` 完全兼容的同时，由编译器原生接管重借用、方法接收者与安全投影．
