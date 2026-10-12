#import "/lib/statements.typ": *
#import "/lib/formal-math.typ": *

#let entry = (
  title: [保型],
  date: "2026-10-10",
  author: "Glomzzz",
  parent: "/how/plt/formal/type-safety.typ",
  legacy-id: "fm-thm-preservation",
)

#show: statement-page.with("theorem/preservation", entry)

采用 #refer("definition/types-and-typing-judgments") 的类型关系和 #refer("definition/one-step-reduction") 的归约关系。若 $t : T$ 且 $t stp t'$，则 $t' : T$。

#proof[
  对 $t stp t'$ 作规则归纳（#refer("theorem/induction-on-derivations")），对 $T$ 一般化。每个情形先对 $t : T$ 使用 #refer("lemma/typing-inversion")。

  - *E-IfTrue*：$t = "if" "true" "then" t_2 "else" t_3$，$t' = t_2$。反演得 $t_2 : T$。
  - *E-IfFalse*：对称，反演得 $t_3 : T$。
  - *E-If*：$t' = "if" t'_1 "then" t_2 "else" t_3$，前提 $t_1 stp t'_1$。反演得 $t_1 : tB$，$t_2 : T$，$t_3 : T$。对前提用 #ih（取类型为 $tB$）得 $t'_1 : tB$，再用 T-If。
  - *E-Succ*：反演得 $T = tN$，$t_1 : tN$。#ih 给出 $t'_1 : tN$，用 T-Succ。
  - *E-PredZero*：$t' = 0$。反演得 $T = tN$，用 T-Zero。
  - *E-PredSucc*：$t = "pred" ("succ" #nv)$，$t' = #nv$。反演两次：先得 $T = tN$ 且 $"succ" #nv : tN$，再得 $#nv : tN$。
  - *E-Pred*：同 E-Succ，最后用 T-Pred。
  - *E-IsZeroZero、E-IsZeroSucc*：$t'$ 是 $"true"$ 或 $"false"$。反演得 $T = tB$，用 T-True 或 T-False。
  - *E-IsZero*：反演得 $T = tB$，$t_1 : tN$。#ih 给出 $t'_1 : tN$，用 T-IsZero。
]
