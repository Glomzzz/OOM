#import "/lib/statements.typ": *
#import "/lib/formal-math.typ": *

#let entry = (
  title: [类型与类型判断],
  date: "2026-10-10",
  author: "Glomzzz",
  parent: "/how/plt/formal/typing.typ",
  legacy-id: "fm-def-typing",
)

#show: statement-page.with("definition/types-and-typing-judgments", entry)

设 $t$ 是 #refer("definition/set-of-terms") 中的词项．
*类型*的语法为 $T ::= tB | tN$，分别表示布尔类型与自然数类型．
词项与类型是不同的语法类别，类型系统定义的是它们之间的关系．

*类型关系*由下列七条*类型规则*归纳定义：它是对这些规则封闭的最小关系．
*类型判断* $tack.r t : T$ 读作“可以由类型规则推出词项 $t$ 具有类型 $T$”；
判断成立，当且仅当存在以它为结论的有限推导．

推导符号 $tack.r$ 在这里标记*可推导性*，不是词项的构造子，也不是求值符号．
含变量的语言通常写作 $Gamma tack.r t : T$，
读作“在*语境* $Gamma$ 中，词项 $t$ 具有类型 $T$”．
$Gamma$ 也称*类型环境*，记录作用域内变量的类型假设；
$tack.r$ 把这些假设与待证陈述分开．
#refer("definition/set-of-terms") 的算术语言没有变量，所以采用空语境，并省略 $Gamma$．
为简洁起见，讨论这套规则时，$t : T$ 是 $tack.r t : T$ 的简写．

横线上的判断是前提，横线下的是结论；
没有前提的规则称为公理，仍是推导规则的特例．
$T$、$t_1$ 等符号按 #refer("convention/metavariables") 代换：
$T$ 只能取类型，$t_1$ 只能取词项；
T-If 两个分支里的 $T$ 必须代换成同一个类型．

#rules(
  rule("T-True", $tack.r "true" : tB$),
  rule("T-False", $tack.r "false" : tB$),
  rule("T-Zero", $tack.r 0 : tN$),
)

#rules(
  rule("T-If", $tack.r t_1 : tB$, $tack.r t_2 : T$, $tack.r t_3 : T$, $tack.r "if" t_1 "then" t_2 "else" t_3 : T$),
)

#rules(
  rule("T-Succ", $tack.r t_1 : tN$, $tack.r "succ" t_1 : tN$),
  rule("T-Pred", $tack.r t_1 : tN$, $tack.r "pred" t_1 : tN$),
  rule("T-IsZero", $tack.r t_1 : tN$, $tack.r "iszero" t_1 : tB$),
)
