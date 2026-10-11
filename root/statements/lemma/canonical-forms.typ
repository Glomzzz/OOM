#import "/lib/statements.typ": *
#import "/lib/formal-math.typ": *

#let entry = (
  title: [典范形式（canonical forms）],
  date: "2026-10-10",
  author: "Glomzzz",
  parent: "/how/plt/formal/type-safety.typ",
  legacy-id: "fm-lem-canon",
)

#show: statement-page.with("lemma/canonical-forms", entry)

值与数值使用 #refer("definition/values-and-numeric-values") 的定义，类型关系使用 #refer("definition/types-and-typing-judgments")。

+ 若 $v$ 是值且 $v : tB$，则 $v$ 是 $"true"$ 或 $"false"$。
+ 若 $v$ 是值且 $v : tN$，则 $v$ 是数值。

#proof[
  由 #refer("definition/values-and-numeric-values")，值只有三种形状：$"true"$、$"false"$、数值。

  + 若 $v$ 是数值，它是 $0$（由 #refer("lemma/typing-inversion") 第 1 条，类型只能是 $tN$）或 $"succ" #nv$（由第 3 条，类型只能是 $tN$）。由 #refer("theorem/uniqueness-of-types")，它不可能同时是 $tB$。所以类型为 $tB$ 的值只能是另两种。
  + 同理，由 #refer("lemma/typing-inversion") 第 1 条，$"true"$、$"false"$ 的类型只能是 $tB$，所以类型为 $tN$ 的值只能是数值。
]
