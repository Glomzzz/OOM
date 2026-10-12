#import "/lib/statements.typ": *
#import "/lib/formal-math.typ": *

#let entry = (
  title: [箭头 $stp$ 的读法与用法],
  page-title: "Convention. 箭头 ⟶ 的读法与用法",
  date: "2026-10-10",
  author: "Glomzzz",
  parent: "/how/plt/formal/evaluation.typ",
  legacy-id: "fm-conv-arrow",
)

#show: statement-page.with("convention/reading-the-reduction-arrow", entry)

以下读法使用 #refer("definition/set-of-terms") 中的项，以及 #refer("definition/one-step-reduction") 定义的关系 $stp$。

- $t stp t'$ 读作“$t$ 一步归约到 $t'$”，英文常读作 “$t$ steps to $t'$” 或 “$t$ reduces to $t'$”。
- $t stp t'$ 是关于转移的一个*判断*（judgement）：它断言这对词项属于所定义的关系。判断成立，当且仅当规则能给出有限推导。例如 $"pred" 0 stp 0$ 成立，$0 stp "pred" 0$ 不成立。
- 箭头是有方向的：左边是归约前的项，右边是归约后的项。
- 它不是函数调用，也不是赋值。$t stp t'$ 不会“改变” $t$，它只是断言 $t$ 与 $t'$ 之间有这样一种关系。
- $t stp t'$ 也可读作“从状态 $t$ 转移一步到状态 $t'$”。它没有声称后继唯一；唯一性要由 #refer("theorem/determinism") 证明。
- $stps$ 读作“多步归约到”，其含义由 #refer("definition/multi-step-reduction") 给出。
