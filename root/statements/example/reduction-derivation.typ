#import "/lib/statements.typ": *
#import "/lib/formal-math.typ": *

#let entry = (
  title: [一棵推导],
  date: "2026-10-10",
  author: "Glomzzz",
  parent: "/how/plt/formal/evaluation.typ",
  legacy-id: "fm-ex-deriv",
)

#show: statement-page.with("example/reduction-derivation", entry)

使用 #refer("definition/one-step-reduction") 的规则，推导树的每条横线都是一条规则的实例：横线上方的子推导满足前提，下方给出结论。以下三层合起来只证明整项的一步归约，不是三步运行。

#bigmath(
  $
    #inf("E-Pred", inf("E-If", inf("E-IsZeroZero", $"iszero" 0 stp "true"$), $"if" ("iszero" 0) "then" "succ" 0 "else" 0 stp "if" "true" "then" "succ" 0 "else" 0$), $"pred" ("if" ("iszero" 0) "then" "succ" 0 "else" 0) stp "pred" ("if" "true" "then" "succ" 0 "else" 0)$)
  $,
  scale: 115%,
)

从下往上读：要说明最下面那一步成立，用 E-Pred，它要求里面的 $"if"$ 能一步归约；这又用 E-If，它要求条件 $"iszero" 0$ 能一步归约；最后 E-IsZeroZero 是公理，无条件成立。
