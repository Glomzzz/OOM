#import "/lib/statements.typ": *
#import "/lib/formal-math.typ": *

#let entry = (
  title: [多步规约到值],
  date: "2026-10-10",
  author: "Glomzzz",
  parent: "/how/plt/formal/normal-forms.typ",
  legacy-id: "fm-ex-multistep",
)

#show: statement-page.with("example/multi-step-reduction-to-a-value", entry)

采用 #refer("definition/one-step-reduction") 的十条规则，
$stps$ 表示 #refer("definition/multi-step-reduction") 的零步或有限多步规约；
终点是否为值按 #refer("definition/values-and-numeric-values") 判断．

$
      & "if" ("iszero" ("pred" ("succ" 0))) "then" "succ" 0 "else" 0 \
  stp & "if" ("iszero" 0) "then" "succ" 0 "else" 0 && "E-If + E-IsZero + E-PredSucc" \
  stp & "if" "true" "then" "succ" 0 "else" 0 && "E-If + E-IsZeroZero" \
  stp & "succ" 0 && "E-IfTrue"
$

每行右边列出了这一步推导用到的规则，从外层的结构规则写到最里层的基本规约规则．
三步之后到达值 $"succ" 0$，所以

$ "if" ("iszero" ("pred" ("succ" 0))) "then" "succ" 0 "else" 0 stps "succ" 0 $

由 #refer("theorem/determinism")，每一步都别无选择，所以这条链是唯一的．
$stps$ 也包括中间每一站：这个项也多步规约到第二行、第三行的项，以及它自己（零步）．
