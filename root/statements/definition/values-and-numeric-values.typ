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

在 #refer("definition/set-of-terms") 的项中，用以下 BNF 划出值。$::=$ 读作“定义为”，$|$ 读作“或者”；$#nv$ 是数值的元变量，不是对象语言的关键字。

$
    v & ::= "true" | "false" | #nv \
  #nv & ::= 0 | "succ" #nv
$

形如 $v$ 的项称为*值*（value），形如 #nv 的项称为*数值*（numeric value）。和 #refer("definition/set-of-terms") 一样，这两行 BNF 定义的是满足相应封闭条件的最小集合。
