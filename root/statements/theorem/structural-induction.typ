#import "/lib/statements.typ": *
#import "/lib/formal-math.typ": *

#let entry = (
  title: [结构归纳原理（structural induction）],
  date: "2026-10-10",
  author: "Glomzzz",
  parent: "/how/plt/formal/02-syntax.typ",
  legacy-id: "fm-thm-struct-ind",
)

#show: statement-page.with("theorem/structural-induction", entry)

设 $P$ 是关于 #refer("definition/set-of-terms") 中有限项的一个性质。如果下面三条都成立：

+ $P("true")$、$P("false")$、$P(0)$；
+ 对任意项 $t_1$，由 $P(t_1)$ 能推出 $P("succ" t_1)$、$P("pred" t_1)$、$P("iszero" t_1)$；
+ 对任意项 $t_1, t_2, t_3$，由 $P(t_1)$、$P(t_2)$、$P(t_3)$ 能推出 $P("if" t_1 "then" t_2 "else" t_3)$，

那么对所有项 $t$，$P(t)$ 成立。

#proof[
  令 $S = {t in cal(T) | P(t)}$，即满足 $P$ 的项组成的集合。三条假设恰好说明 $S$ 满足 #refer("definition/set-of-terms") 的三条封闭条件。由于 $cal(T)$ 是满足封闭条件的最小集合，$cal(T) subset.eq S$。也就是说每个项都在 $S$ 里，都满足 $P$。
]
