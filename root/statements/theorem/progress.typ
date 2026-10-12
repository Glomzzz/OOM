#import "/lib/statements.typ": *
#import "/lib/formal-math.typ": *

#let entry = (
  title: [进展],
  date: "2026-10-10",
  author: "Glomzzz",
  parent: "/how/plt/formal/type-safety.typ",
  legacy-id: "fm-thm-progress",
)

#show: statement-page.with("theorem/progress", entry)

采用 #refer("definition/types-and-typing-judgments") 的类型关系、#refer("definition/values-and-numeric-values") 的值定义，以及 #refer("definition/one-step-reduction") 的归约关系。若 $t : T$，则 $t$ 是值，或存在 $t'$ 使 $t stp t'$。

#proof[
  对 $t : T$ 作规则归纳（类型推导版本的 #refer("theorem/induction-on-derivations")），按最后一步的规则分情形。

  - *T-True、T-False、T-Zero*：$t$ 是值。
  - *T-If*：$t = "if" t_1 "then" t_2 "else" t_3$，前提里有 $t_1 : tB$。对 $t_1$ 用 #ih：
    - 若 $t_1$ 能归约，用 E-If，$t$ 也能归约；
    - 若 $t_1$ 是值，由 #refer("lemma/canonical-forms") 第 1 条，它是 $"true"$ 或 $"false"$，分别用 E-IfTrue、E-IfFalse。
  - *T-Succ*：前提 $t_1 : tN$。若 $t_1$ 能归约，用 E-Succ。若 $t_1$ 是值，由 #refer("lemma/canonical-forms") 第 2 条它是数值 $#nv$，于是 $t = "succ" #nv$ 本身也是数值，因而是值。
  - *T-Pred*：前提 $t_1 : tN$。若 $t_1$ 能归约，用 E-Pred。若 $t_1$ 是值，它是数值：是 $0$ 就用 E-PredZero；否则形如 $"succ" #nv'$，用 E-PredSucc。
  - *T-IsZero*：与 T-Pred 相同，分别用 E-IsZero、E-IsZeroZero、E-IsZeroSucc。
]
