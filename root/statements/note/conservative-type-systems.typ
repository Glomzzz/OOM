#import "/lib/statements.typ": *
#import "/lib/formal-math.typ": *

#let entry = (
  title: [类型系统是保守的],
  date: "2026-10-10",
  author: "Glomzzz",
  parent: "/how/plt/formal/typing.typ",
  legacy-id: "fm-rm-conservative",
)

#show: statement-page.with("note/conservative-type-systems", entry)

按 #refer("definition/one-step-reduction") 的 E-IfTrue，$"if" "true" "then" 0 "else" "false"$ 运行一步就得到值 $0$，不会受阻；但 #refer("definition/types-and-typing-judgments") 无法给它类型，因为 T-If 要求两个分支类型相同。这不是 bug。类型系统不运行程序，只看形状，它只能做*近似*。#refer("corollary/type-safety") 只保证一个方向：良类型的程序不受阻；它没有保证“不受阻的程序都良类型”。
