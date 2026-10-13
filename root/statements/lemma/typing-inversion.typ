#import "/lib/statements.typ": *
#import "/lib/formal-math.typ": *

#let entry = (
  title: [反演],
  date: "2026-10-10",
  author: "Glomzzz",
  parent: "/how/plt/formal/typing.typ",
  legacy-id: "fm-lem-inv",
)

#show: statement-page.with("lemma/typing-inversion", entry)

以下结论只针对 #refer("definition/types-and-typing-judgments") 的七条类型规则；
$t : T$ 表示能由这些规则搭出有限推导，$tB$、$tN$ 分别是布尔类型与自然数类型．

+ 若 $"true" : T$ 或 $"false" : T$，则 $T = tB$．若 $0 : T$，则 $T = tN$．
+ 若 $"if" t_1 "then" t_2 "else" t_3 : T$，则 $t_1 : tB$，$t_2 : T$，$t_3 : T$．
+ 若 $"succ" t_1 : T$ 或 $"pred" t_1 : T$，则 $T = tN$ 且 $t_1 : tN$．
+ 若 $"iszero" t_1 : T$，则 $T = tB$ 且 $t_1 : tN$．

#proof[
  每一条都看推导的最后一步．
  以第 3 条中的 $"succ"$ 为例：七条规则里，结论左边形如 $"succ" t_1$ 的只有 T-Succ．
  所以推导的最后一步就是 T-Succ，它的结论类型是 $tN$，前提是 $t_1 : tN$．
  其余各条同理，每次都只有一条规则可能适用．
]
