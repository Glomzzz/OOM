#import "/lib/statements.typ": *
#import "/lib/formal-math.typ": *

#let entry = (
  title: [分支顺序里藏着证明],
  date: "2026-10-10",
  author: "Glomzzz",
  parent: "/how/plt/formal/determinism.typ",
  legacy-id: "fm-rm-order",
)

#show: statement-page.with("note/proofs-behind-pattern-matching-order", entry)

#cite("/how/plt/formal/determinism.typ")[Rust 求值器 `step`] 实现 #refer("definition/one-step-reduction") 的规则。Rust 的 `match` 按顺序尝试分支，这本身是一种“优先级”，而求值规则没有写这种优先级。为什么这样写不会改变语义？因为 #refer("theorem/determinism") 的证明已经说明，对每个 $t$ 至多一条规则适用，所以按什么顺序试结果都一样。没有那条定理，“先试 E-PredSucc 再试 E-Pred”就是一个偷偷加进来的、规则里没有的决定。
