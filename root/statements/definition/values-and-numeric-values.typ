#import "/lib/statements.typ": *
#import "/lib/formal-math.typ": *

#let entry = (
  title: [值与数值],
  date: "2026-10-10",
  author: "Glomzzz",
  parent: "/how/plt/formal/evaluation.typ",
  legacy-id: "fm-def-values",
)

#show: statement-page.with("definition/values-and-numeric-values", entry)

在 #refer("definition/set-of-terms") 的词项中，用两行 BNF 文法划出值．
$::=$ 读作“定义为”，$|$ 读作“或者”；
$#nv$ 是元语言中表示数值的元变量，不属于对象语言的关键字．

$
    v & ::= "true" | "false" | #nv \
  #nv & ::= 0 | "succ" #nv
$

形如 $v$ 的词项称为*值*，形如 #nv 的词项称为*数值*．
和 #refer("definition/set-of-terms") 一样，
这两行 BNF 定义的是满足相应封闭条件的最小集合．
