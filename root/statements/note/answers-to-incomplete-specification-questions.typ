#import "/lib/statements.typ": *
#import "/lib/formal-math.typ": *

#let entry = (
  title: [不完整规格中的类型检查问题],
  date: "2026-10-10",
  author: "Glomzzz",
  parent: "/how/plt/formal/typing.typ",
  legacy-id: "fm-rm-answers",
)

#show: statement-page.with("note/answers-to-incomplete-specification-questions", entry)

采用 #refer("definition/types-and-typing-judgments") 的七条规则，
#refer("example/incomplete-specifications") 中的三个类型检查问题都有明确答案．
T-If 的三个前提都必须成立，因此 $"else"$ 分支即使永远不执行也要检查；
两个分支的类型使用*同一个*元变量 $T$，“类型相同”指字面一致，不做自动转换；
检查器拒绝 $t$ 意味着不存在 $t : T$ 的推导，具体是哪条规则的哪个前提搭不上，可以从搭建推导的过程中直接读出来（方法见 #refer("note/locating-errors-in-failed-typing-derivations")）．
