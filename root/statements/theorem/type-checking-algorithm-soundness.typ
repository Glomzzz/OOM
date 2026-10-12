#import "/lib/statements.typ": *
#import "/lib/formal-math.typ": *

#let entry = (
  title: [算法可靠性],
  date: "2026-10-10",
  author: "Glomzzz",
  parent: "/how/plt/formal/rules-and-algorithms.typ",
  legacy-id: "fm-thm-alg-sound",
)

#show: statement-page.with("theorem/type-checking-algorithm-soundness", entry)

取 #cite("/how/plt/formal/rules-and-algorithms.typ")[Rust 类型检查算法 `type_of`]，类型关系采用 #refer("definition/types-and-typing-judgments")。实现论证采用 #refer("note/unexamined-assumptions") 的资源与基础操作假设；Rust 的 `Bool`、`Nat` 分别对应 $tB$、$tN$。对任意项 $t$ 和类型 $T$：若 `type_of(t) = Some(T)`，则 $t : T$。

#proof[
  对 $t$ 结构归纳（#refer("convention/writing-inductive-proofs")）。`type_of` 本身就是按项的形状分支的，所以每个情形对应一个分支。

  - *常量*：`True`、`False` 分支返回 `Bool`，`Zero` 分支返回 `Nat`，分别是 T-True、T-False、T-Zero 的结论。
  - *$"succ" t_1$*：返回 `Some(Nat)` 只有一种可能，`type_of(t1) = Some(Nat)`。由 #ih $t_1 : tN$，用 T-Succ 得 $"succ" t_1 : tN$。$"pred"$、$"iszero"$ 同理，分别用 T-Pred、T-IsZero。
  - *$"if" t_1 "then" t_2 "else" t_3$*：返回 `Some(ta)` 说明 `type_of(c) = Some(Bool)`、`type_of(a) = Some(ta)`、`type_of(b) = Some(ta)`。三次使用 #ih 分别给出 $t_1 : tB$、$t_2 : T$、$t_3 : T$（$T$ 即 `ta`），正是 T-If 的三个前提。
]
