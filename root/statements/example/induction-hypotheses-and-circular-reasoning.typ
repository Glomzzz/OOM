#import "/lib/statements.typ": *
#import "/lib/formal-math.typ": *

#let entry = (
  title: [合法的归纳假设与循环论证],
  date: "2026-10-10",
  author: "Glomzzz",
  parent: "/how/plt/formal/syntax.typ",
  legacy-id: "fm-ex-ih",
)

#show: statement-page.with("example/induction-hypotheses-and-circular-reasoning", entry)

取 #refer("definition/set-of-terms") 中的有限项，树的术语见 #refer("definition/tree-terminology")，归纳方法采用 #refer("theorem/structural-induction")。

取 $P(t)$ 为“$t$ 至少含有一个叶子”。常量本身就是叶子，基础情形成立。证明 $P("pred" t_1)$ 时，#ih $P(t_1)$ 给出 $t_1$ 中有一个叶子；加上 $"pred"$ 根以后，那个叶子仍然存在。证明 $P("if" t_1 "then" t_2 "else" t_3)$ 时，任取一个孩子中的叶子即可。对于 $"pred" ("succ" 0)$，先验证 $P(0)$，再推出 $P("succ" 0)$，最后推出整项的性质，没有一步用到尚未证明的结论。

反过来，试图证明错误命题 $Q(t)$：“$t$ 不含 $"pred"$”，然后在 $"pred" t_1$ 的情形里说“假定 $Q("pred" t_1)$，所以它不含 $"pred"$”，就是*循环论证*（circular reasoning）：用待证结论本身支持待证结论。它至多证明了 $Q("pred" t_1) ==> Q("pred" t_1)$，没有证明归纳步骤要求的 $Q(t_1) ==> Q("pred" t_1)$。实际取 $t_1 = 0$，前者 $Q(0)$ 为真，后者 $Q("pred" 0)$ 为假，反例立刻出现。

循环也可以藏在两步里：“为了证明父项满足 $P$，先用父项满足 $P$ 来证明子项满足 $P$，再由子项推出父项”。两句话合起来仍然没有独立的起点。
