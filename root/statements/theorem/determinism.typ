#import "/lib/statements.typ": *
#import "/lib/formal-math.typ": *

#let entry = (
  title: [确定性],
  date: "2026-10-10",
  author: "Glomzzz",
  parent: "/how/plt/formal/determinism.typ",
  legacy-id: "fm-thm-det",
)

#show: statement-page.with("theorem/determinism", entry)

对 #refer("definition/one-step-reduction") 定义的关系 $stp$，
若 $t stp t'$ 且 $t stp t''$，则 $t' = t''$．

#proof[
  证明采用*分类讨论*（也称分情形讨论）：穷尽所有可能情形并逐一论证．
  由于 $stp$ 是最小关系，任何推导的最后一步只能出自那十条规则，因此只需按这十条规则分类即可穷尽所有情况，无需枚举无穷多个词项．
  下面覆盖这十种情形，对称或重复的论证合并说明；
  每个情形里，再按结论左边的形状排除不匹配的规则，检查第二个推导剩下的候选规则．

  具体地，对 $t stp t'$ 作规则归纳（#refer("theorem/induction-on-derivations")），
  要证的性质是“对*任意* $t''$，$t stp t''$ 蕴涵 $t' = t''$”．
  “任意 $t''$”必须写进性质里，否则 #ih 只能用于某个固定的 $t''$，在 E-If 情形就不够用．
  每个情形里，再看 $t stp t''$ 的推导最后一步可能是哪条规则：
  它的结论左边必须和 $t$ 形状相同．

  对 E-IfTrue，$t = "if" "true" "then" t_2 "else" t_3$，$t' = t_2$．
  第二个推导若是 E-IfTrue，则 $t'' = t_2$；
  条件为 $"true"$，排除了要求条件为 $"false"$ 的 E-IfFalse；
  #refer("lemma/values-do-not-reduce") 又排除了要求 $"true" stp dots$ 的 E-If．
  E-IfFalse 与上一条对称．
  对 E-If，前提为 $t_1 stp t'_1$；由于 $t_1$ 能规约，由 #refer("lemma/values-do-not-reduce") 知它不可能等于 $"true"$ 或 $"false"$，从而排除 E-IfTrue 与 E-IfFalse，第二个推导只能是 E-If（前提 $t_1 stp t''_1$），由 #ih 得 $t'_1 = t''_1$，于是 $t' = t''$．

  对 E-Succ，左边形如 $"succ" dots$ 的规则只有 E-Succ，由 #ih 即得．
  对 E-PredZero，$t = "pred" 0$；E-PredSucc 要求 $"pred"$ 后面是 $"succ" dots$，不适用；E-Pred 要求 $0$ 能规约，与 #refer("lemma/values-do-not-reduce") 矛盾，所以只能是 E-PredZero，$t'' = 0 = t'$．
  对 E-PredSucc，$t = "pred" ("succ" #nv)$；E-PredZero 不适用，E-Pred 要求值 $"succ" #nv$ 能规约而矛盾，所以只能是 E-PredSucc，结果相同．
  对 E-Pred，前提为 $t_1 stp t'_1$；由 #refer("lemma/values-do-not-reduce") 知 $t_1$ 不属于值，而 E-PredZero 与 E-PredSucc 分别要求 $t_1$ 为值 $0$ 或 $"succ" #nv$，故都不适用，剩下 E-Pred，用 #ih．
  E-IsZeroZero、E-IsZeroSucc、E-IsZero 与 $"pred"$ 的三条一一对应，论证相同．
]
