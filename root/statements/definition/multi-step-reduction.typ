#import "/lib/statements.typ": *
#import "/lib/formal-math.typ": *

#let entry = (
  title: [多步规约],
  date: "2026-10-10",
  author: "Glomzzz",
  parent: "/how/plt/formal/normal-forms.typ",
  legacy-id: "fm-def-multistep",
)

#show: statement-page.with("definition/multi-step-reduction", entry)

以 #refer("definition/one-step-reduction") 的关系 $stp$ 为基础，
$t stps t'$ 读作“$t$ 多步规约到 $t'$”，
表示从 $t$ 出发经过零步或有限多步一步规约到达 $t'$．
精确地说，它是对下面两条规则封闭的最小关系：

#rules(
  rule("M-Refl", $t stps t$),
  rule("M-Step", $t stp t'$, $t' stps t''$, $t stps t''$),
)
