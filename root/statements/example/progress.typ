#import "/lib/statements.typ": *
#import "/lib/formal-math.typ": *

#let entry = (
  title: [进展],
  date: "2026-10-10",
  author: "Glomzzz",
  parent: "/how/plt/formal/type-safety.typ",
  legacy-id: "fm-ex-progress",
)

#show: statement-page.with("example/progress", entry)

采用 #refer("definition/types-and-typing-judgments") 的类型规则
和 #refer("definition/one-step-reduction") 的求值规则．
取良类型的项 $t = "pred" ("if" "false" "then" 0 "else" "succ" 0) : tN$，
跟着 #refer("theorem/progress") 的证明走一遍：

+ $t$ 的推导最后一步是 T-Pred，
  前提 $"if" "false" "then" 0 "else" "succ" 0 : tN$．对这个子项用 #ih．
+ 子项的推导最后一步是 T-If，前提里有 $"false" : tB$．
  $"false"$ 是值，由 #refer("lemma/canonical-forms") 它是 $"true"$ 或 $"false"$，
  这里是 $"false"$，于是用 E-IfFalse：子项 $stp "succ" 0$．
+ 回到 $t$：子项能规约，所以用 E-Pred，得 $t stp "pred" ("succ" 0)$．

证明不只说“能规约”，还*构造*出了这一步的推导．
对 $"pred" ("succ" 0)$ 再用一次进展：
子项 $"succ" 0$ 是值，由 #refer("lemma/canonical-forms") 它是数值，
且形如 $"succ" #nv$，于是用 E-PredSucc 得到 $0$．
对 $0$ 再用一次进展：它是值，停止．
