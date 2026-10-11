#import "/lib/statements.typ": *
#import "/lib/formal-math.typ": *

#let entry = (
  title: [确定性],
  date: "2026-10-10",
  author: "Glomzzz",
  parent: "/how/plt/formal/04-determinism.typ",
  legacy-id: "fm-thm-det",
)

#show: statement-page.with("theorem/determinism", entry)

对 #refer("definition/one-step-reduction") 定义的关系 $stp$，若 $t stp t'$ 且 $t stp t''$，则 $t' = t''$。

#proof[
  证明的方法是*穷举*（case analysis，也叫分情形讨论）：把所有可能的情形一个不漏地列出来，逐个证明。穷举法成立的前提是情形*确实覆盖了每一种可能*，漏掉一种，整个证明就不成立。这里能保证不漏，是因为 $stp$ 是最小关系，任何推导的最后一步只能是十条规则之一，所以下面恰好列十种情形；而在每种情形内部，又要对第二个推导的最后一步再穷举一次十条规则，逐条说明“适用”或“为什么不适用”。

  具体地，对 $t stp t'$ 的推导归纳（#refer("theorem/induction-on-derivations")），要证的性质是“对*任意* $t''$，$t stp t''$ 蕴涵 $t' = t''$”。“任意 $t''$”必须写进性质里，否则 #ih 只能用于某个固定的 $t''$，在 E-If 情形就不够用。每个情形里，再看 $t stp t''$ 的推导最后一步可能是哪条规则：它的结论左边必须和 $t$ 形状相同。

  - *E-IfTrue*：$t = "if" "true" "then" t_2 "else" t_3$，$t' = t_2$。第二个推导若是 E-IfTrue，$t'' = t_2$。不可能是 E-IfFalse，条件不是 $"false"$。不可能是 E-If，那需要 $"true" stp dots$，与 #refer("lemma/values-do-not-reduce") 矛盾。
  - *E-IfFalse*：与上一条对称。
  - *E-If*：前提 $t_1 stp t_1'$。第二个推导不可能是 E-IfTrue 或 E-IfFalse：那时 $t_1$ 是 $"true"$ 或 $"false"$，而 $t_1$ 能归约，与 #refer("lemma/values-do-not-reduce") 矛盾。所以它是 E-If，前提 $t_1 stp t_1''$。由 #ih $t_1' = t_1''$，于是 $t' = t''$。
  - *E-Succ*：左边形如 $"succ" dots$ 的规则只有 E-Succ，由 #ih 即得。
  - *E-PredZero*：$t = "pred" 0$。E-PredSucc 要求 $"pred"$ 后面是 $"succ" dots$，不适用；E-Pred 要求 $0$ 能归约，与 #refer("lemma/values-do-not-reduce") 矛盾。所以只能是 E-PredZero，$t'' = 0 = t'$。
  - *E-PredSucc*：$t = "pred" ("succ" #nv)$。E-PredZero 不适用；E-Pred 要求 $"succ" #nv$ 能归约，但它是值，矛盾。所以只能是 E-PredSucc，结果相同。
  - *E-Pred*：前提 $t_1 stp t_1'$，所以 $t_1$ 不是值（#refer("lemma/values-do-not-reduce")），E-PredZero 和 E-PredSucc 都不适用（它们要求 $t_1$ 是 $0$ 或 $"succ" #nv$，都是值）。剩下 E-Pred，用 #ih。
  - *E-IsZeroZero、E-IsZeroSucc、E-IsZero*：与 $"pred"$ 的三条一一对应，论证相同。
]
