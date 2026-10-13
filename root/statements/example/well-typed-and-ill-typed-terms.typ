#import "/lib/statements.typ": *
#import "/lib/formal-math.typ": *

#let entry = (
  title: [良类型与不良类型],
  date: "2026-10-10",
  author: "Glomzzz",
  parent: "/how/plt/formal/typing.typ",
  legacy-id: "fm-ex-typing",
)

#show: statement-page.with("example/well-typed-and-ill-typed-terms", entry)

使用 #refer("definition/types-and-typing-judgments") 的七条类型规则，
良类型与不良类型的含义见 #refer("definition/well-typed-terms")．

*良类型的例子．*
要说明 $"if" ("iszero" 0) "then" "succ" 0 "else" 0 : tN$，从结论往上搭推导：

+ 项的最外层是 $"if"$，结论形如 $"if" dots : T$ 的规则只有 T-If．
  取 $T = tN$，它要求三个前提：$"iszero" 0 : tB$、$"succ" 0 : tN$、$0 : tN$．
+ 第一个前提 $"iszero" 0 : tB$：只有 T-IsZero 的结论形如 $"iszero" dots$，
  结论类型恰好是 $tB$，它要求 $0 : tN$．T-Zero 给出这一点．
+ 第二个前提 $"succ" 0 : tN$：用 T-Succ，它要求 $0 : tN$，再用 T-Zero．
+ 第三个前提 $0 : tN$：直接用 T-Zero．

每个前提都搭上了，合起来就是完整的推导：

#bigmath(
  $
    #inf("T-If", inf("T-IsZero", inf("T-Zero", $0 : tN$), $"iszero" 0 : tB$), inf("T-Succ", inf("T-Zero", $0 : tN$), $"succ" 0 : tN$), inf("T-Zero", $0 : tN$), $"if" ("iszero" 0) "then" "succ" 0 "else" 0 : tN$)
  $,
  scale: 110%,
)

*不良类型的例子．*
要说明 $"succ" "true"$ 没有类型，
得证明对*任何* $T$ 都搭不出 $"succ" "true" : T$ 的推导．
可以直接穷举七条规则：

+ 结论左边形如 $"succ" dots$ 的规则只有 T-Succ，
  其余六条的结论形状对不上，直接排除．
  所以如果有推导，最后一步只能是 T-Succ，此时 $T = tN$，前提是 $"true" : tN$．
+ 再看 $"true" : tN$．
  结论左边是 $"true"$ 的规则只有 T-True，而它的结论是 $"true" : tB$，
  类型是 $tB$ 而不是 $tN$，搭不上．没有别的规则可选．

唯一可能作为最后一步的 T-Succ 无法满足前提，
因此不存在合法的推导树，$"succ" "true"$ 是不良类型的．
