#import "/lib/statements.typ": *
#import "/lib/formal-math.typ": *

#let entry = (
  title: [词项的集合],
  date: "2026-10-10",
  author: "Glomzzz",
  parent: "/how/plt/formal/syntax.typ",
  legacy-id: "fm-def-terms",
)

#show: statement-page.with("definition/set-of-terms", entry)

把*词项*（简称“项”）视为 #refer("convention/abstract-syntax") 中的有限语法树：
常量 $"true"$、$"false"$、$0$ 是叶子，
$"succ"$、$"pred"$、$"iszero"$ 是一元构造，
$"if"$ 有条件、$"then"$ 分支和 $"else"$ 分支三个有序子项．

词项的集合 $cal(T)$ 是满足下面三条*封闭条件*的*最小*集合：

+ $"true" in cal(T)$，$"false" in cal(T)$，$0 in cal(T)$；
+ 若 $t_1 in cal(T)$，则 $"succ" t_1$、$"pred" t_1$、$"iszero" t_1$ 都属于 $cal(T)$；
+ 若 $t_1, t_2, t_3 in cal(T)$，则 $"if" t_1 "then" t_2 "else" t_3 in cal(T)$．

“最小”的意思是：如果另一个集合 $S$ 也满足这三条，那么 $cal(T) subset.eq S$．
也就是说，$cal(T)$ 只含有限次应用生成规则所能得到的词项，没有其他元素；
这一限制称为*最小性子句*．
