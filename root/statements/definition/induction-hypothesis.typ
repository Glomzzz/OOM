#import "/lib/statements.typ": *
#import "/lib/formal-math.typ": *

#let entry = (
  title: [归纳假设],
  date: "2026-10-10",
  author: "Glomzzz",
  parent: "/how/plt/formal/syntax.typ",
  legacy-id: "fm-def-ih",
)

#show: statement-page.with("definition/induction-hypothesis", entry)

*归纳假设*是在归纳步骤中，对归纳原理许可的更小对象暂时假定的性质．
它是用来证明“如果这些更小对象满足 $P$，那么当前对象也满足 $P$”的前提；
这里不能把“所有对象都满足 $P$”或当前待证结论预先当真．

在 #refer("theorem/structural-induction") 的第 2 条中，归纳假设是 $P(t_1)$；
第 3 条中是 $P(t_1)$、$P(t_2)$、$P(t_3)$．
这些对象恰好是 #refer("definition/immediate-and-proper-subterms") 给出的直接子项．
常量没有子项，所以基准情况没有归纳假设，必须直接证明．

这种暂时假定之所以合法，是因为我们首先证明的是条件命题．
每个实际词项都由有限次构造得到，从已经验证的叶子出发，
逐层应用这个条件命题，就能把性质传到根．
假设只沿着更小的结构使用，不会绕回当前待证结论．
