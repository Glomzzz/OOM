#import "/lib/statements.typ": *
#import "/lib/formal-math.typ": *

#let entry = (
  title: [类型安全],
  date: "2026-10-10",
  author: "Glomzzz",
  parent: "/how/plt/formal/type-safety.typ",
  legacy-id: "fm-cor-safety",
)

#show: statement-page.with("corollary/type-safety", entry)

由 #refer("definition/set-of-terms")、#refer("definition/one-step-reduction") 与 #refer("definition/types-and-typing-judgments") 规定的布尔值／自然数语言是类型安全的（#refer("definition/type-safety")）：若 $t : T$ 且 $t stps t'$，则 $t'$ 没有受阻。

#proof[
  对 $t stps t'$ 的步数归纳（#refer("definition/multi-step-reduction") 的两条规则）。

  - *零步*：$t' = t$，于是 $t' : T$。
  - *至少一步*：$t stp t_1$ 且 $t_1 stps t'$。由 #refer("theorem/preservation")，$t_1 : T$；对 $t_1$ 用 #ih 即可。

  归纳给出的其实是更强的结论：$t' : T$。最后对 $t'$ 用 #refer("theorem/progress")：它是值或能归约，总之不是受阻的。
]
