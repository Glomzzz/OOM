#import "/lib/statements.typ": *
#import "/lib/formal-math.typ": *

#let entry = (
  title: [正规形式与受阻],
  date: "2026-10-10",
  author: "Glomzzz",
  parent: "/how/plt/formal/normal-forms.typ",
  legacy-id: "fm-def-stuck",
)

#show: statement-page.with("definition/normal-forms-and-stuck-terms", entry)

采用 #refer("definition/one-step-reduction") 的关系 $stp$．
若不存在词项 $t'$ 使 $t stp t'$，称 $t$ 是*正规形式*．
按 #refer("definition/values-and-numeric-values") 判断，
不属于值的正规形式称为*受阻*词项．
正规形式与受阻都相对于给定的转移规则定义；
“正规形式”只表示不能继续规约，不代表正常结果，也不保证每个词项都能到达唯一正规形式．
