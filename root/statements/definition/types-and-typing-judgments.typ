#import "/lib/statements.typ": *
#import "/lib/formal-math.typ": *

#let entry = (
  title: [类型与类型判断],
  date: "2026-10-10",
  author: "Glomzzz",
  parent: "/how/plt/formal/06-typing.typ",
  legacy-id: "fm-def-typing",
)

#show: statement-page.with("definition/types-and-typing-judgments", entry)

设 $t$ 是 #refer("definition/set-of-terms") 中的项。*类型*（type）只有两种：$T ::= tB | tN$，分别对应布尔值和自然数。*类型判断*（typing judgment）$t : T$ 读作“$t$ 具有类型 $T$”，它是对下列七条规则封闭的最小关系。

横线上的判断是前提，横线下的是结论；没有前提的规则直接给出结论。$T$、$t_1$ 等符号按 #refer("convention/metavariables") 代换，T-If 两个分支里的 $T$ 必须代换成同一个类型。

#rules(
  rule("T-True", $"true" : tB$),
  rule("T-False", $"false" : tB$),
  rule("T-Zero", $0 : tN$),
)

#rules(
  rule("T-If", $t_1 : tB$, $t_2 : T$, $t_3 : T$, $"if" t_1 "then" t_2 "else" t_3 : T$),
)

#rules(
  rule("T-Succ", $t_1 : tN$, $"succ" t_1 : tN$),
  rule("T-Pred", $t_1 : tN$, $"pred" t_1 : tN$),
  rule("T-IsZero", $t_1 : tN$, $"iszero" t_1 : tB$),
)
