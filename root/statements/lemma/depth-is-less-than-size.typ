#import "/lib/statements.typ": *
#import "/lib/formal-math.typ": *

#let entry = (
  title: [深度小于大小],
  date: "2026-10-10",
  author: "Glomzzz",
  parent: "/how/plt/formal/syntax.typ",
  legacy-id: "fm-lem-depth",
)

#show: statement-page.with("lemma/depth-is-less-than-size", entry)

对 #refer("definition/set-of-terms") 中的所有有限项 $t$，
采用 #refer("definition/size-and-depth") 的函数定义，
有 $op("depth")(t) < op("size")(t)$．

#proof[
  按 #refer("theorem/structural-induction") 对 $t$ 作结构归纳．

  - *$t$ 是常量*：$op("depth")(t) = 0 < 1 = op("size")(t)$．
  - *$t = "succ" t_1$*（$"pred"$、$"iszero"$ 完全相同）：
    #ih 是 $op("depth")(t_1) < op("size")(t_1)$，
    两边加一即得 $op("depth")(t) < op("size")(t)$．
  - *$t = "if" t_1 "then" t_2 "else" t_3$*：
    设 $t_i$ 是三个子项中深度最大的．由 #ih，
    $
      op("depth")(t)
      = op("depth")(t_i) + 1
      < op("size")(t_i) + 1
      <= op("size")(t_1) + op("size")(t_2) + op("size")(t_3) + 1
      = op("size")(t)
    $
    其中 $<=$ 用到了每个子项的大小都至少为 $1$．
]
