#import "/lib/statements.typ": *
#import "/lib/formal-math.typ": *

#let entry = (
  title: [对象语言与元语言],
  date: "2026-10-10",
  author: "Glomzzz",
  parent: "/how/plt/formal/natural-and-formal.typ",
  legacy-id: "fm-def-meta",
)

#show: statement-page.with("definition/object-language-and-metalanguage", entry)

- *对象语言*：作为研究对象的语言．
- *元语言*：用来谈论对象语言的语言．

例如，#refer("definition/set-of-terms")、#refer("definition/one-step-reduction")
与 #refer("definition/types-and-typing-judgments") 规定的布尔值与自然数语言是对象语言；
用来写这些定义和证明的自然语言与数学符号属于元语言．
用 Rust 实现这门小语言时，Rust 也充当元语言，见 #refer("note/rust-as-a-metalanguage")．
