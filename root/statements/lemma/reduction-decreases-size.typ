#import "/lib/statements.typ": *
#import "/lib/formal-math.typ": *

#let entry = (
  title: [规约使大小严格下降],
  date: "2026-10-10",
  author: "Glomzzz",
  parent: "/how/plt/formal/normal-forms.typ",
)

#show: statement-page.with("lemma/reduction-decreases-size", entry)

采用 #refer("definition/size-and-depth") 的大小函数与
#refer("definition/one-step-reduction") 的十条规则．
若 $t stp t'$，则 $op("size")(t') < op("size")(t)$．
因此，从 $t$ 出发的任何规约链至多有 $op("size")(t) - 1$ 步，不存在无限规约链．

#proof[
  对 $t stp t'$ 作规则归纳（#refer("theorem/induction-on-derivations")），
  按最后一步的规则分情形．

  - *E-IfTrue、E-IfFalse*：
    整项的大小是 $1 + op("size")(t_1) + op("size")(t_2) + op("size")(t_3)$，
    结果只是选中的一个分支，严格更小．
  - *E-PredZero、E-IsZeroZero*：
    $op("size")("pred" 0) = op("size")("iszero" 0) = 2$，
    结果 $0$ 或 $"true"$ 的大小为 $1$．
  - *E-PredSucc*：
    $op("size")("pred" ("succ" #nv)) = op("size")(#nv) + 2$，结果是 $#nv$．
  - *E-IsZeroSucc*：
    $op("size")("iszero" ("succ" #nv)) = op("size")(#nv) + 2 >= 3$，
    结果 $"false"$ 的大小为 $1$．
  - *E-Succ、E-Pred、E-IsZero*：
    前提 $t_1 stp t'_1$，由 #ih 得 $op("size")(t'_1) < op("size")(t_1)$．
    两边都只多包一层同一个一元节点，严格不等式仍成立．
  - *E-If*：前提 $t_1 stp t'_1$，由 #ih 条件部分变小，
    另两个分支与根节点不变，整项严格变小．

  对步数：设 $t = t_0 stp t_1 stp dots.c stp t_n$．
  每一步大小至少减 $1$，所以 $op("size")(t_n) <= op("size")(t) - n$．
  大小至少为 $1$，故 $n <= op("size")(t) - 1$．
]

这条引理说明规约链有限．
结合 #refer("theorem/evaluator-faithfulness")，
在 #refer("note/unexamined-assumptions") 的资源与基础操作假设下，
反复调用 #cite("/how/plt/formal/determinism.typ")[Rust 求值器 `step`]
会在有限次返回后得到 `None`．
测试实现时不能预先假定它恰好实现了规则，仍应检查每个返回后继是否更小．
这条引理不说明链的终点是值还是受阻的项；那个问题由类型安全回答．
