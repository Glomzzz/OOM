#import "/lib/statements.typ": *

#let entry = (
  title: [取消安全性与异步清理的困境],
  date: "2026-10-15",
  author: "哈吉米4",
  parent: "/how/rust/async/executor-and-reactor.typ",
)

#show: statement-page.with("note/cancellation-safety-and-async-cleanup", entry)

在 #cite("/how/rust/async/model.typ")[拉取模型] 中，外部驱动者只要停止调用 `poll` 并直接 `drop` 状态机，就能在任意 `.await` 挂起点处同步取消一个异步任务．Without Boats 在 #link("https://without.boats/blog/asynchronous-clean-up/")[_Asynchronous clean-up_] 与 #link("https://without.boats/blog/poll-next/")[_poll_next_] 中将这种机制归类为*半协作式取消*：任务无法拒绝在 `.await` 处被取消，但可以在被丢弃时通过同步析构函数 `Drop::drop` 清理自身持有的资源．

这一机制在工程中引出了两类问题：

1. *循环中的 `select!` 与取消安全性*：
   不少代码会在 `loop` 循环里使用 `tokio::select!` 同时等待多个分支：
   ```rust
   loop {
       tokio::select! {
           msg = rx.recv() => handle(msg),
           _ = do_work() => break,
       }
   }
   ```
   这里容易忽略的是：每一次循环迭代中，只要某个分支率先就绪，*其余未就绪分支的 `Future` 状态机就会被当场 `drop` 取消*，并在下一轮迭代重新构造．
   如果被取消的 `Future` 内部持有跨挂起点的局部状态（例如已经从字节流读了一半的数据缓冲、或者在侵入式等待队列中排到了靠前的位置），丢弃重建就会造成数据丢失或排回队尾饿死．
   只有当一个 `Future` 自身不保存任何跨挂起点的实质局部进展（其状态仅是对外部持久化对象的引用，丢弃后再调一次构造函数能回到完全相同的状态）时，在 `select!` 循环中反复取消重建它才不会产生可见副作用——这就是 `tokio` 文档所称的“取消安全”．
   避免在循环里意外取消状态机的办法，是在循环外用 `let mut work = pin!(do_work());` 先把状态机固定住，再在 `select!` 分支里传可变借用 `&mut work`（或者优先使用将多个异步流合流的 `StreamExt::merge`）．
2. *为什么 Rust 难以支持隐式的异步析构函数（`AsyncDrop`）*：
   既然 `Drop::drop(&mut self)` 是同步函数，如果一个异步对象（如数据库连接或 TLS 套接字）在销毁时需要发送关闭握手包并 `.await` 确认，该怎么办？
   直接允许在 `Drop` 里 `.await` 会遇到四重阻碍：
   - 若该值在同步函数里离开作用域，没有异步上下文可供 `.await`；
   - 若任意泛型类型 `T` 都可能含有隐式异步析构，那么任何包含 `T` 的外层 `Future` 在生成状态机时，都必须为每个局部变量的析构预留额外的挂起状态变体与存储空间，这会使 `dyn Trait` 丧失对象安全性（无法静态确定析构状态机的大小），还会让跨线程发送 `T` 时的 `Send` 证明传染到析构产生的匿名状态机上；
   - 在每次变量离开作用域的地方插入隐式挂起点，会打破 Rust “挂起点必须通过 `.await` 显式标出”的约定；
   - 多个含异步析构的变量同时离开作用域时，编译器无法替用户决定应当串行依次 `.await` 还是并发 `join!`．
   因此，目前在 Rust 中需要异步清理的资源通常提供显式的 `close().await` 方法，并在同步 `Drop` 中仅做非阻塞通知或后台任务投递；语言层面的演进讨论则聚焦于显式的 `do ... final` 块、`Future::poll_cancel` 协议或限制隐式丢弃的必移动类型．
