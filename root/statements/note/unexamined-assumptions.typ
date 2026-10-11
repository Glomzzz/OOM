#import "/lib/statements.typ": *
#import "/lib/formal-math.typ": *

#let entry = (
  title: [算术语言形式化的未展开前提],
  date: "2026-10-10",
  author: "Glomzzz",
  parent: "/how/plt/formal/summary.typ",
  legacy-id: "fm-rm-not-covered",
)

#show: statement-page.with("note/unexamined-assumptions", entry)

#cite("/how/plt/formal/index.typ")[形式化入门：从 BNF 到类型安全] 定义了布尔值／自然数语言，并证明其类型安全；这套形式化仍有几项默认采用、未单独展开的前提：

- 解析：从字符串到语法树这一步（#refer("convention/abstract-syntax")）。
- 元语言本身的可靠性：我们默认“集合”“最小”“归纳”这些数学工具是可靠的。追究下去就是数学基础的问题了。
- 实现与规则的对应：Rust 代码和规则之间的对应是靠阅读和测试确认的，没有机器证明。要做到机器证明，需要把规则和定理放进 Coq、Lean、Agda 这类证明助手。
