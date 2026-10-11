#import "/lib/statements.typ": *
#import "/lib/formal-math.typ": *

#let entry = (
  title: [保型],
  date: "2026-10-10",
  author: "Glomzzz",
  parent: "/how/plt/formal/type-safety.typ",
  legacy-id: "fm-ex-preservation",
)

#show: statement-page.with("example/preservation", entry)

对 #refer("example/multi-step-reduction-to-a-value") 的归约链，按 #refer("definition/types-and-typing-judgments") 在每一项旁边写上类型。归约关系使用 #refer("definition/one-step-reduction")，保型性质及其证明见 #refer("theorem/preservation")：

$
      & "if" ("iszero" ("pred" ("succ" 0))) "then" "succ" 0 "else" 0 && : tN \
  stp & "if" ("iszero" 0) "then" "succ" 0 "else" 0                   && : tN \
  stp & "if" "true" "then" "succ" 0 "else" 0                         && : tN \
  stp & "succ" 0                                                     && : tN
$

类型始终是 $tN$。以第一步为例看保型的证明怎样工作：这一步的推导是 E-If，前提是 $"iszero" ("pred" ("succ" 0)) stp "iszero" 0$。由 #refer("lemma/typing-inversion") 对 $t : tN$ 反演，得到条件 $: tB$、两个分支 $: tN$；对前提用 #ih（取类型 $tB$），得到 $"iszero" 0 : tB$；两个分支原封不动，再用 T-If 拼回去，得到新项 $: tN$。

注意项本身变了很多，从一个 $"if"$ 变成了 $"succ" 0$，但类型这个“静态描述”一直成立。保型说的就是：运行不会让类型说过的话失效。
