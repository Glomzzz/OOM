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

#cite("/how/plt/formal/index.typ")[形式化入门：从 BNF 到类型安全]
定义了布尔值与自然数语言，并证明其类型安全；
这套形式化仍有几项默认采用、未单独展开的前提：

- *解析*：从字符串到语法树这一步（#refer("convention/abstract-syntax")）．
- *元语言本身的可靠性*：默认“集合”“最小”“归纳”这些数学工具可靠；
  再往下追问就属于数学基础问题．
- *实现的资源与基础操作*：
  对 `step`、`type_of` 及其辅助函数的纸面论证暂不考虑资源耗尽，
  并假定模式匹配、分配、克隆、比较和析构等 Rust 操作按预期正常完成；
  用 `usize` 实现的大小与深度计数也假定不溢出．
  结构递归排除的是数学上的无限递归，不保证任意深的项都能在实际机器上正常处理：
  检查、克隆和析构同样会消耗栈或内存．
  模型中的“没有后继”对应 `None`，不把栈溢出、分配失败或程序异常退出也解释成 `None`．
- *实现与规则的对应*：
  `step` 与 `type_of` 相对规则的对应有纸面证明
  （#refer("theorem/evaluator-faithfulness")、
  #refer("theorem/type-checking-algorithm-soundness")、
  #refer("theorem/type-checking-algorithm-completeness")），再配合测试，
  但这些证明没有机器检查，也没有覆盖 Rust 语言本身的语义．
  要做到机器检查证明，需要把规则和定理编码进 Coq（现名 Rocq）、Lean、Agda 等证明助手．
