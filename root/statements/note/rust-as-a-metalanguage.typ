#import "/lib/statements.typ": *
#import "/lib/formal-math.typ": *

#let entry = (
  title: [Rust 也是元语言],
  date: "2026-10-10",
  author: "Glomzzz",
  parent: "/how/plt/formal/01-natural-and-formal.typ",
  legacy-id: "fm-rm-rust-meta",
)

#show: statement-page.with("note/rust-as-a-metalanguage", entry)

用 Rust 实现 #refer("definition/set-of-terms") 的项和 #refer("definition/one-step-reduction") 的运行规则时，Rust 充当 #refer("definition/object-language-and-metalanguage") 中的元语言：Rust 的 `enum Term` 描述对象语言的项，Rust 的函数描述对象语言的运行。不要把 Rust 自己的类型（`bool`、`Option`）和#refer("definition/types-and-typing-judgments") 中的对象语言类型（$tB$、$tN$）混为一谈，它们分属两层。实现示例见 #cite("/how/plt/formal/04-determinism.typ")[Rust 求值器] 与 #cite("/how/plt/formal/08-rules-and-algorithms.typ")[Rust 类型检查器]。
