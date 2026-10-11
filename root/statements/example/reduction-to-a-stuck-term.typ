#import "/lib/statements.typ": *
#import "/lib/formal-math.typ": *

#let entry = (
  title: [归约到受阻],
  date: "2026-10-10",
  author: "Glomzzz",
  parent: "/how/plt/formal/05-normal-forms.typ",
  legacy-id: "fm-ex-stuck",
)

#show: statement-page.with("example/reduction-to-a-stuck-term", entry)

按 #refer("definition/one-step-reduction") 的规则，取 $t = "succ" ("if" "true" "then" "false" "else" 0)$。是否为值采用 #refer("definition/values-and-numeric-values")，是否受阻采用 #refer("definition/normal-forms-and-stuck-terms")。

*第一步。*$t$ 的最外层是 $"succ"$。结论左边形如 $"succ" dots$ 的规则只有 E-Succ，它要求里面的 $"if" "true" "then" "false" "else" 0$ 能归约。这个 $"if"$ 的条件是 $"true"$，E-IfTrue 适用，得到 $"false"$。于是推导是：

#bigmath(
  $
    #inf("E-Succ", inf("E-IfTrue", $"if" "true" "then" "false" "else" 0 stp "false"$), $"succ" ("if" "true" "then" "false" "else" 0) stp "succ" "false"$)
  $,
  scale: 115%,
)

*第二步。*现在的项是 $"succ" "false"$。仍然只有 E-Succ 可能适用，它要求 $"false" stp t_1'$ 对某个 $t_1'$ 成立。但 $"false"$ 是值，由 #refer("lemma/values-do-not-reduce") 不能归约，于是 E-Succ 的前提搭不上，没有任何规则可用：$"succ" "false"$ 是范式。它又不是值（$"succ"$ 后面必须是数值），所以它受阻了。

第一步完全合法，问题出在第二步。所以一个项“现在还能归约”并不说明它“永远不会出错”。
