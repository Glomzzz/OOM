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

这里基于 #refer("definition/set-of-terms") 中的项与 #refer("definition/one-step-reduction") 定义的关系 $stp$，约定箭头的读法．

$t stp t'$ 读作“$t$ 一步规约到 $t'$”，也可读作“从状态 $t$ 转移一步到状态 $t'$”．
它是关于转移的*判断*，断言这对词项属于所定义的关系；
判断成立，当且仅当规则能给出有限推导．
例如 $"pred" 0 stp 0$ 成立，$0 stp "pred" 0$ 不成立．

箭头有方向，左边是规约前的项，右边是规约后的项．
$t stp t'$ 只陈述两项满足这一关系，不同于函数调用或原地修改 $t$ 的赋值．
这个记号本身不要求后继唯一；唯一性要由 #refer("theorem/determinism") 另行证明．
带上星号的 $stps$ 读作“多步规约到”，含义由 #refer("definition/multi-step-reduction") 给出．
