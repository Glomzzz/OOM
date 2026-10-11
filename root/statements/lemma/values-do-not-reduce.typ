#import "/lib/statements.typ": *
#import "/lib/formal-math.typ": *

#let entry = (
  title: [值不可归约],
  date: "2026-10-10",
  author: "Glomzzz",
  parent: "/how/plt/formal/04-determinism.typ",
  legacy-id: "fm-lem-value-normal",
)

#show: statement-page.with("lemma/values-do-not-reduce", entry)

采用 #refer("definition/values-and-numeric-values") 的值定义与 #refer("definition/one-step-reduction") 的十条求值规则。若 $v$ 是值，则不存在 $t'$ 使 $v stp t'$。

#proof[
  对 #refer("definition/values-and-numeric-values") 的值做结构归纳。

  - *$"true"$、$"false"$、$0$*：逐条检查十条规则的结论左边，没有一条是这三个常量之一。
  - *$"succ" #nv$*：结论左边形如 $"succ" dots$ 的规则只有 E-Succ，它的前提要求 $#nv stp t_1'$。$#nv$ 是更小的值，由 #ih 不可能。
]
