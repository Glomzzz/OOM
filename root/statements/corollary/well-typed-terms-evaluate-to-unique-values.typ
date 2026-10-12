#import "/lib/statements.typ": *
#import "/lib/formal-math.typ": *

#let entry = (
  title: [良类型项求值到唯一的同类型值],
  date: "2026-10-10",
  author: "Glomzzz",
  parent: "/how/plt/formal/type-safety.typ",
)

#show: statement-page.with("corollary/well-typed-terms-evaluate-to-unique-values", entry)

采用 #refer("definition/set-of-terms") 的有限项、#refer("definition/values-and-numeric-values") 的值、#refer("definition/multi-step-reduction") 的多步归约，以及 #refer("definition/types-and-typing-judgments") 的类型规则。若 $t : T$，则存在唯一的值 $v$，使得

$ t stps v quad "且" quad v : T. $

#proof[
  *存在性。*从 $t$ 出发，只要有后继就继续归约。由 #refer("lemma/reduction-decreases-size")，每步大小严格下降，归约链至多有 $op("size")(t) - 1$ 步，因而必能到达一个没有后继的项 $u$。由 #refer("theorem/preservation") 对链长归纳，$u : T$。再用 #refer("theorem/progress")：$u$ 是值或能归约，而后一种情况已被排除，所以 $u$ 是具有类型 $T$ 的值。

  *唯一性。*设 $t stps v$ 且 $t stps w$，其中 $v$、$w$ 都是值。对第一条链的长度归纳；归纳性质允许第二条链任意长。

  - *零步*：$t = v$。由 #refer("lemma/values-do-not-reduce")，$t$ 没有后继，因此第二条链也只能有零步，$w = t = v$。
  - *至少一步*：第一条链形如 $t stp t_1 stps v$。$t$ 能归约，故由 #refer("lemma/values-do-not-reduce") 它不是值；第二条链不能有零步，形如 $t stp t_2 stps w$。由 #refer("theorem/determinism")，$t_1 = t_2$。两条剩余链从同一项出发，第一条的长度更小，由 #ih 得 $v = w$。
]

#refer("corollary/type-safety") 只排除受阻，不独自保证终止。这条推论还用到了另行证明的终止性与确定性；它针对上述未扩展语言，不能直接推广到含一般递归或其他求值规则的语言。
