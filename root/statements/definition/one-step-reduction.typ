#import "/lib/statements.typ": *
#import "/lib/formal-math.typ": *

#let entry = (
  title: [一步归约],
  date: "2026-10-10",
  author: "Glomzzz",
  parent: "/how/plt/formal/evaluation.typ",
  legacy-id: "fm-def-step",
)

#show: statement-page.with("definition/one-step-reduction", entry)

设 $t$、$t'$ 属于 #refer("definition/set-of-terms") 的项集合，$#nv$ 只取 #refer("definition/values-and-numeric-values") 中的数值。关系 $t stp t'$ 是对下列十条规则封闭的最小关系。

每条横线之上的判断是前提，横线之下的是结论；前提全部成立，结论才成立。没有前提的规则可以直接使用。同一条规则中相同的元变量必须替换成同一个项，见 #refer("convention/metavariables")。

#rules(
  rule("E-IfTrue", $"if" "true" "then" t_2 "else" t_3 stp t_2$),
  rule("E-IfFalse", $"if" "false" "then" t_2 "else" t_3 stp t_3$),
)

#rules(
  rule("E-If", $t_1 stp t_1'$, $"if" t_1 "then" t_2 "else" t_3 stp "if" t_1' "then" t_2 "else" t_3$),
)

#rules(
  rule("E-Succ", $t_1 stp t_1'$, $"succ" t_1 stp "succ" t_1'$),
  rule("E-PredZero", $"pred" 0 stp 0$),
  rule("E-PredSucc", $"pred" ("succ" #nv) stp #nv$),
  rule("E-Pred", $t_1 stp t_1'$, $"pred" t_1 stp "pred" t_1'$),
)

#rules(
  rule("E-IsZeroZero", $"iszero" 0 stp "true"$),
  rule("E-IsZeroSucc", $"iszero" ("succ" #nv) stp "false"$),
  rule("E-IsZero", $t_1 stp t_1'$, $"iszero" t_1 stp "iszero" t_1'$),
)
