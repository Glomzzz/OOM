#import "/lib/statements.typ": *
#import "/lib/formal-math.typ": *

#let entry = (
  title: [类型唯一],
  date: "2026-10-10",
  author: "Glomzzz",
  parent: "/how/plt/formal/typing.typ",
  legacy-id: "fm-thm-unique",
)

#show: statement-page.with("theorem/uniqueness-of-types", entry)

对 #refer("definition/types-and-typing-judgments") 的七条类型规则，
若 $t : T$ 且 $t : T'$，则 $T = T'$．

#proof[
  对 $t$ 结构归纳（#refer("convention/writing-inductive-proofs")），对 $T$、$T'$ 一般化．

  - *常量*、*$"succ" t_1$*、*$"pred" t_1$*、*$"iszero" t_1$*：
    由 #refer("lemma/typing-inversion")，
    类型由项的形状直接唯一确定为 $tB$ 或 $tN$，所以 $T = T'$．
  - *$"if" t_1 "then" t_2 "else" t_3$*：
    由 #refer("lemma/typing-inversion") 第 2 条，$t_2 : T$ 且 $t_2 : T'$．
    $t_2$ 是直接子项，由 #ih 得 $T = T'$．
]
