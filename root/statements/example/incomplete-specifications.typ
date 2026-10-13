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
这句话读起来没什么问题，却没有涉及下面的情况：

+ 如果条件恒为真，$"else"$ 分支永远不会执行，还要检查 $"else"$ 分支吗？
+ “类型相同”是字面上一样，还是可以自动转换？
+ 检查器拒绝某个程序时，能不能指出它违反的是*哪一条*？

再如“`f() + g()` 先算两边再相加”．
如果 `f` 和 `g` 都会打印字符，先打印谁？这句话没有规定求值顺序．

#refer("note/answers-to-incomplete-specification-questions")
按一套明确的类型规则回答前三个问题；
求值顺序的影响见
#refer("note/evaluation-strategies-reduction-strategies-and-confluence")．
