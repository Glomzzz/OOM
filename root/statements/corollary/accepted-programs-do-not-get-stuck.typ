#import "/lib/statements.typ": *
#import "/lib/formal-math.typ": *

#let entry = (
  title: [检查器接受的程序不会受阻],
  date: "2026-10-10",
  author: "Glomzzz",
  parent: "/how/plt/formal/08-rules-and-algorithms.typ",
  legacy-id: "fm-cor-end-to-end",
)

#show: statement-page.with("corollary/accepted-programs-do-not-get-stuck", entry)

取 #cite("/how/plt/formal/08-rules-and-algorithms.typ")[Rust 类型检查算法 `type_of`]，以及 #refer("definition/multi-step-reduction") 的关系 $stps$。若 `type_of(t) = Some(T)` 且 $t stps t'$，则 $t'$ 不会处于 #refer("definition/normal-forms-and-stuck-terms") 定义的受阻状态。

#proof[
  由 #refer("theorem/type-checking-algorithm-soundness") 得 $t : T$，再由 #refer("corollary/type-safety") 即得。
]
