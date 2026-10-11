#import "/lib/statements.typ": *
#import "/lib/formal-math.typ": *

#let entry = (
  title: [对推导归纳],
  date: "2026-10-10",
  author: "Glomzzz",
  parent: "/how/plt/formal/determinism.typ",
  legacy-id: "fm-thm-rule-ind",
)

#show: statement-page.with("theorem/induction-on-derivations", entry)

设 $P(t, t')$ 是关于一对项的性质。如果对 #refer("definition/one-step-reduction") 的每一条规则都有：“前提里的每个 $t_1 stp t_1'$ 都满足 $P(t_1, t_1')$”能推出“结论满足 $P$”，那么所有满足 $t stp t'$ 的 $(t, t')$ 都满足 $P$。

#proof[
  令 $R = {(t, t') | t stp t' "且" P(t, t')}$。假设恰好说明 $R$ 对十条规则封闭。$stp$ 是对规则封闭的最小关系，所以 $stp subset.eq R$。
]
