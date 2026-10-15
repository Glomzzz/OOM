#import "/lib/statements.typ": *
#import "/lib/formal-math.typ": *

#let entry = (
  title: [一步规约],
  date: "2026-10-10",
  author: "Glomzzz",
  parent: "/how/plt/formal/evaluation.typ",
  legacy-id: "fm-def-step",
)

#show: statement-page.with("definition/one-step-reduction", entry)

以 #refer("definition/set-of-terms") 的词项作为执行状态，
$#nv$ 只取 #refer("definition/values-and-numeric-values") 中的数值．
*一步规约关系* $stp$，即此模型的小步*转移关系*，
是对下面十条推导规则封闭的最小二元关系．
$t stp t'$ 成立，当且仅当存在以这个判断为结论的有限推导．

每条横线之上的判断是前提，横线之下的是结论；前提全部成立，结论才成立．
没有前提的规则称为公理，可以直接使用．
同一条规则中相同的元变量必须代换成同一个项，见 #refer("convention/metavariables")．

#rules(
  rule("E-IfTrue", $"if" "true" "then" t_2 "else" t_3 stp t_2$),
  rule("E-IfFalse", $"if" "false" "then" t_2 "else" t_3 stp t_3$),
)

#rules(
  rule("E-If", $t_1 stp t'_1$, $"if" t_1 "then" t_2 "else" t_3 stp "if" t'_1 "then" t_2 "else" t_3$),
)

#rules(
  rule("E-Succ", $t_1 stp t'_1$, $"succ" t_1 stp "succ" t'_1$),
  rule("E-PredZero", $"pred" 0 stp 0$),
  rule("E-PredSucc", $"pred" ("succ" #nv) stp #nv$),
  rule("E-Pred", $t_1 stp t'_1$, $"pred" t_1 stp "pred" t'_1$),
)

#rules(
  rule("E-IsZeroZero", $"iszero" 0 stp "true"$),
  rule("E-IsZeroSucc", $"iszero" ("succ" #nv) stp "false"$),
  rule("E-IsZero", $t_1 stp t'_1$, $"iszero" t_1 stp "iszero" t'_1$),
)
