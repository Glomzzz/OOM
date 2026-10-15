#import "/lib/statements.typ": *
#import "/lib/formal-math.typ": *

#let entry = (
  title: [最小集合确实存在],
  date: "2026-10-10",
  author: "Glomzzz",
  parent: "/how/plt/formal/syntax.typ",
  legacy-id: "fm-rm-least-exists",
)

#show: statement-page.with("note/existence-of-the-least-set", entry)

#refer("definition/set-of-terms") 有一条存在性前提：
满足那三条封闭条件的集合中真的*有*最小的．
先固定背景集合 $U$，包含节点标签取自
$"true"$、$"false"$、$0$、$"succ"$、$"pred"$、$"iszero"$、$"if"$
的所有有限有序树（暂不限制每个标签的孩子数量）．
$U$ 本身满足三条封闭条件，因此满足条件的 $U$ 的子集至少有一个，
下面对这族子集取交集时不会遇到空集族．

把所有满足封闭条件的 $U$ 的子集取交集，记为 $I$．
由于每个集合都含 $"true"$、$"false"$、$0$，$I$ 也含这三个常量；
若 $t_1 in I$，则 $t_1$ 在每个集合里，而每个集合都对三个一元构造封闭，
故 $"succ" t_1$、$"pred" t_1$、$"iszero" t_1$ 也在每个集合里，从而属于 $I$；
同理，若 $t_1, t_2, t_3 in I$，每个集合对 $"if"$ 构造的封闭性保证 $"if" t_1 "then" t_2 "else" t_3$ 也在交集 $I$ 里．

因此 $I$ 满足全部封闭条件，而且按交集的定义，它包含在每个满足条件的集合里．
交集直接给出了所需的最小集合 $cal(T)$．
