#import "/lib/statements.typ": *
#import "/lib/formal-math.typ": *

#let entry = (
  title: [类型安全],
  date: "2026-10-10",
  author: "Glomzzz",
  parent: "/how/plt/formal/type-safety.typ",
  legacy-id: "fm-def-safety",
)

#show: statement-page.with("definition/type-safety", entry)

采用 #refer("definition/types-and-typing-judgments") 的类型关系、#refer("definition/multi-step-reduction") 的运行关系，以及 #refer("definition/normal-forms-and-stuck-terms") 的受阻判定。称这套语言规则具有*类型安全性*（type safety），如果对任意词项 $t$、$t'$ 和类型 $T$：若 $t : T$ 且 $t stps t'$，则 $t'$ 没有受阻。

这个性质表达了类型规则相对于执行规则的*类型健全性*（type soundness）：良类型词项的执行不会进入所定义的错误状态。它不直接涉及某个具体检查算法，也不承诺终止或排除所有真实语言中的运行时错误。
