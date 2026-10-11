#import "/lib/statements.typ": *
#import "/lib/formal-math.typ": *

#let entry = (
  title: [算法完备性],
  date: "2026-10-10",
  author: "Glomzzz",
  parent: "/how/plt/formal/rules-and-algorithms.typ",
  legacy-id: "fm-thm-alg-complete",
)

#show: statement-page.with("theorem/type-checking-algorithm-completeness", entry)

取 #cite("/how/plt/formal/rules-and-algorithms.typ")[Rust 类型检查算法 `type_of`]，类型关系采用 #refer("definition/types-and-typing-judgments")。Rust 的 `Bool`、`Nat` 分别对应 $tB$、$tN$。对任意项 $t$ 和类型 $T$：若 $t : T$，则 `type_of(t) = Some(T)`。

#proof[
  对 $t : T$ 的推导归纳，按最后一步的规则分情形。

  - *T-True、T-False、T-Zero*：直接计算 `type_of` 即得。
  - *T-Succ*：前提 $t_1 : tN$。由 #ih `type_of(t1) = Some(Nat)`，于是 `Succ` 分支返回 `Some(Nat)`。T-Pred、T-IsZero 同理。
  - *T-If*：三个前提由 #ih 给出 `type_of` 在三个子项上分别返回 `Bool`、`T`、`T`。代入 `If` 分支：`ta = T`，两个比较都成立，返回 `Some(T)`。
]
