#import "/lib/statements.typ": *
#import "/lib/formal-math.typ": *

#let entry = (
  title: [不完整的规格],
  date: "2026-10-10",
  author: "Glomzzz",
  parent: "/how/plt/formal/natural-and-formal.typ",
  legacy-id: "fm-ex-incomplete",
)

#show: statement-page.with("example/incomplete-specifications", entry)

一份规格写道：“`if` 的条件必须是布尔值，两个分支的类型相同．”
这句话读起来没什么问题，却留下几处悬而未决的情形：
条件恒为真、$"else"$ 分支永远不执行时，是否还要检查 $"else"$ 分支；
“类型相同”指字面上完全一致，还是允许自动转换；
检查器拒绝某个程序时，能否指出它具体违反了*哪一条*．

再如“`f() + g()` 先算两边再相加”：
当 `f` 和 `g` 都会打印字符时，这句话没有规定哪一边先执行、先打印．

#refer("note/answers-to-incomplete-specification-questions")
按一套明确的类型规则回答前三个问题；
求值顺序的影响见
#refer("note/evaluation-strategies-reduction-strategies-and-confluence")．
