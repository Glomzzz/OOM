#import "/lib/statements.typ": *
#import "/lib/formal-math.typ": *

#let entry = (
  title: [求值器与一步规约一致],
  date: "2026-10-10",
  author: "Glomzzz",
  parent: "/how/plt/formal/determinism.typ",
)

#show: statement-page.with("theorem/evaluator-faithfulness", entry)

取 #cite("/how/plt/formal/determinism.typ")[Rust 求值器 `step`]，
规约关系采用 #refer("definition/one-step-reduction")，
实现论证采用 #refer("note/unexamined-assumptions") 的资源与基础操作假设．
对任意项 $t$ 与 $u$：`step(t) = Some(u)` 当且仅当 $t stp u$．

两个方向各有分工．
“仅当”方向（`step` 蕴涵规则）说明函数返回的每个后继都能由规则推出，
函数不会凭空造出规则不允许的一步．
“若”方向（规则蕴涵 `step`）说明规则允许的每个后继函数都能返回，
函数没有漏掉任何合法路线．

“若”方向要用 #refer("lemma/values-do-not-reduce") 排除“别的分支抢先匹配”的情形，
这与 #refer("theorem/determinism") 证明里的排除论证同源．
反过来看也成立：`step` 是函数，所以只要这条定理成立，
若 $t stp u$ 且 $t stp u'$，则 `step(t)` 同时等于 `Some(u)` 与 `Some(u')`，于是 $u = u'$．
因此对这十条规则，这条定理蕴涵确定性，给出了确定性的另一条证明路线．
若把 E-PredSucc 放宽成任意项，“若”方向会在这一情形失败，
见 #refer("note/numeric-value-restriction-in-predecessor-reduction")．

#proof[
  *（仅当：`step(t) = Some(u)` 蕴涵 $t stp u$）*
  对 $t$ 结构归纳，按 `step` 实际走到的分支分情形．
  常量 $"true"$、$"false"$、$0$ 上 `step` 返回 `None`，前提不成立．
  当 $t = "if" t_1 "then" t_2 "else" t_3$ 时，若 $t_1$ 是 $"true"$ 则返回 $t_2$（对应 E-IfTrue），若是 $"false"$ 则返回 $t_3$（对应 E-IfFalse）；否则 `step(t1) = Some(t1')` 且 $u = "if" t'_1 "then" t_2 "else" t_3$，由 #ih 得 $t_1 stp t'_1$，再用 E-If 即得．
  当 $t = "succ" t_1$ 时，`step(t1) = Some(t1')` 且 $u = "succ" t'_1$，由 #ih 与 E-Succ 即得．
  当 $t = "pred" t_1$ 时，若 $t_1$ 是 $0$ 则返回 $0$（E-PredZero），若 $t_1 = "succ" #nv$（`is_nv` 为真）则返回 $#nv$（E-PredSucc），其余情形 `step(t1) = Some(t1')`，由 #ih 与 E-Pred 即得．
  $"iszero" t_1$ 与 $"pred"$ 的三个分支一一对应，分别用 E-IsZeroZero、E-IsZeroSucc、E-IsZero．

  *（若：$t stp u$ 蕴涵 `step(t) = Some(u)`）*
  对 $t stp u$ 作规则归纳（#refer("theorem/induction-on-derivations")），
  按最后一步的规则分情形．
  对 E-IfTrue、E-IfFalse，条件分别是 $"true"$、$"false"$，`step` 的前两个分支直接返回 $t_2$、$t_3$．
  对 E-If，前提为 $t_1 stp t'_1$；由 #refer("lemma/values-do-not-reduce") 知 $t_1$ 不属于值，不可能匹配 $"true"$ 或 $"false"$，所以 `step` 走第三个分支，再由 #ih 得 `step(t1) = Some(t1')`，返回 $"if" t'_1 "then" t_2 "else" t_3$．
  对 E-Succ，由 #ih 直接得到．
  对 E-PredZero、E-PredSucc，`step` 的前两个分支返回规则的结论，其中 E-PredSucc 的条件 `is_nv` 正是规则对 $#nv$ 的限制．
  对 E-Pred，前提为 $t_1 stp t'_1$；由 #refer("lemma/values-do-not-reduce") 知 $t_1$ 不属于值，不可能匹配 $0$ 或数值 $"succ" #nv$，`step` 走第三个分支，由 #ih 得 `step(t1) = Some(t1')`．
  E-IsZeroZero、E-IsZeroSucc、E-IsZero 与 $"pred"$ 的三条一一对应，论证相同．
]

这条定理接上的是“规则”与“Rust 函数”之间那道缝，
与 #refer("theorem/type-checking-algorithm-soundness")
和 #refer("theorem/type-checking-algorithm-completeness") 对类型检查器做的事相呼应．
它是对这段 Rust 代码的纸面论证，未经机器检查；
对代码里没有写出的细节（例如 `clone` 的行为）仍然依赖对 Rust 语义的默认理解．
配套工程 #link("https://github.com/Glomzzz/OOM/tree/main/code/plt-arith")[`code/plt-arith`]
里的 `determinism` 测试把 `step` 与逐条照抄规则的枚举器在有限样本上对照，
作为对定理的经验检验．
