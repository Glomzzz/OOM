#import "/lib/statements.typ": *
#import "/lib/formal-math.typ": *

#let entry = (
  title: [良类型],
  date: "2026-10-10",
  author: "Glomzzz",
  parent: "/how/plt/formal/typing.typ",
  legacy-id: "fm-def-well-typed",
)

#show: statement-page.with("definition/well-typed-terms", entry)

对 #refer("definition/types-and-typing-judgments") 的类型关系，
若存在某个类型 $T$，使得 $t : T$ 有一棵由这些规则搭成的有限推导，
则称词项 $t$ 是*良类型*的；否则称 $t$ 是*不良类型*的．
