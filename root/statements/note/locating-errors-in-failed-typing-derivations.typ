#import "/lib/statements.typ": *
#import "/lib/formal-math.typ": *

#let entry = (
  title: [从失败的推导里读出错误位置],
  date: "2026-10-10",
  author: "Glomzzz",
  parent: "/how/plt/formal/typing.typ",
  legacy-id: "fm-rm-blame",
)

#show: statement-page.with("note/locating-errors-in-failed-typing-derivations", entry)

为 #refer("definition/types-and-typing-judgments") 中的类型判断寻找推导时，
从要证的结论出发，选一条结论形状对得上的规则，再去搭它的每个前提．
这七条规则是语法导向的，每个子项的候选规则由语法形状确定，
见 #refer("lemma/typing-inversion")．
由于 T-If 有三个前提，推导搜索会分出三个分支，形成一棵树．
按指定的检查顺序，可以定位首先失败的前提；这条诊断包含三样信息：
断在哪个子项上的*位置*（搭推导时每进入一个前提就进入一个直接子项，断点对应语法树上的一个节点），
断点上方最后一次成功选用的*规则与前提*（以及它的哪一个前提搭不上），
还有那个前提要求的类型与子项实际能得到的类型之间的*期望与实际*对照．

以 $"if" "true" "then" 0 "else" ("iszero" 0)$ 为例，
按条件、$"then"$ 分支、$"else"$ 分支的顺序检查．
最外层选 T-If；第一个前提 $"true" : tB$ 由 T-True 搭上；
第二个前提要求 $0 : T$，T-Zero 给出 $T = tN$；
第三个前提于是要求 $"iszero" 0 : tN$，但 T-IsZero 的结论类型是 $tB$．
断点因此是：*T-If 的第三个前提，子项 $"iszero" 0$，期望 $tN$，实际 $tB$*．
编译器的报错信息 `expected Nat, found Bool`，内容就是这三样信息．
若先用 $"else"$ 分支确定 $T = tB$，也可以报告 $"then"$ 分支的 $0$“期望 $tB$，实际 $tN$”；
首先报告哪一处，取决于检查顺序，不由语法导向性单独决定．

#cite("/how/plt/formal/rules-and-algorithms.typ")[Rust 检查器 `type_of`]
在失败时只返回 `None`，把这些信息丢掉了．
要保留它们，只需把返回类型从 `Option<Type>` 换成 `Result<Type, Error>`，
在每个 `?` 和比较失败处记下当时的规则、子项和两个类型．
