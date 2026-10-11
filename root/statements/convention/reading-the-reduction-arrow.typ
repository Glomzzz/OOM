#import "/lib/statements.typ": *
#import "/lib/formal-math.typ": *

#let entry = (
  title: [箭头 $stp$ 的读法与用法],
  page-title: "约定：箭头 ⟶ 的读法与用法",
  date: "2026-10-10",
  author: "Glomzzz",
  parent: "/how/plt/formal/03-evaluation.typ",
  legacy-id: "fm-conv-arrow",
)

#show: statement-page.with("convention/reading-the-reduction-arrow", entry)

以下读法使用 #refer("definition/set-of-terms") 中的项，以及 #refer("definition/one-step-reduction") 定义的关系 $stp$。

- $t stp t'$ 读作“$t$ 一步归约到 $t'$”，英文常读作 “$t$ steps to $t'$” 或 “$t$ reduces to $t'$”。
- 它是一个*命题*，可以成立也可以不成立，就像 $1 < 2$ 成立、$2 < 1$ 不成立一样。例如 $"pred" 0 stp 0$ 成立；$0 stp "pred" 0$ 不成立。
- 箭头是有方向的：左边是归约前的项，右边是归约后的项。
- 它不是函数调用，也不是赋值。$t stp t'$ 不会“改变” $t$，它只是断言 $t$ 与 $t'$ 之间有这样一种关系。
- 写 $t stp t'$ 的时候没有说 $t'$ 是唯一的；唯一性是要证明的（#refer("theorem/determinism")）。
- $stps$ 读作“多步归约到”，其含义由 #refer("definition/multi-step-reduction") 给出。
