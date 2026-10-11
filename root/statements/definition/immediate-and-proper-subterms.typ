#import "/lib/statements.typ": *
#import "/lib/formal-math.typ": *

#let entry = (
  title: [直接子项与真子项],
  date: "2026-10-10",
  author: "Glomzzz",
  parent: "/how/plt/formal/syntax.typ",
  legacy-id: "fm-def-subterm",
)

#show: statement-page.with("definition/immediate-and-proper-subterms", entry)

对 #refer("definition/set-of-terms") 中的项，采用 #refer("definition/tree-terminology") 的树术语。根节点的每个孩子所对应的整棵子树，称为它的*直接子项*（immediate subterm）。具体地：

- $"true"$、$"false"$、$0$ 没有直接子项；
- $"succ" t_1$、$"pred" t_1$、$"iszero" t_1$ 的唯一直接子项是 $t_1$；
- $"if" t_1 "then" t_2 "else" t_3$ 的三个直接子项按顺序是 $t_1$、$t_2$、$t_3$。

沿着“取直接子项”走一步或多步得到的项，称为*真子项*（proper subterm）。例如 $"pred" ("succ" 0)$ 的直接子项只有 $"succ" 0$，$0$ 也是它的真子项，但不是直接子项；整项本身不是自己的真子项。同一文本可以出现在树的不同位置，谈子项时还要看它所在的位置。
