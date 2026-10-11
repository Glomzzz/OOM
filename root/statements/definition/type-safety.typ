#import "/lib/statements.typ": *
#import "/lib/formal-math.typ": *

#let entry = (
  title: [类型安全],
  date: "2026-10-10",
  author: "Glomzzz",
  parent: "/how/plt/formal/07-type-safety.typ",
  legacy-id: "fm-def-safety",
)

#show: statement-page.with("definition/type-safety", entry)

采用 #refer("definition/types-and-typing-judgments") 的类型关系、#refer("definition/multi-step-reduction") 的运行关系，以及 #refer("definition/normal-forms-and-stuck-terms") 的受阻判定。称这套语言规则是*类型安全*（type safety）的，如果对任意项 $t$、$t'$ 和类型 $T$：若 $t : T$ 且 $t stps t'$，则 $t'$ 没有受阻。
