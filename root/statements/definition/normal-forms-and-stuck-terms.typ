#import "/lib/statements.typ": *
#import "/lib/formal-math.typ": *

#let entry = (
  title: [范式与受阻],
  date: "2026-10-10",
  author: "Glomzzz",
  parent: "/how/plt/formal/normal-forms.typ",
  legacy-id: "fm-def-stuck",
)

#show: statement-page.with("definition/normal-forms-and-stuck-terms", entry)

采用 #refer("definition/one-step-reduction") 的关系 $stp$。若不存在词项 $t'$ 使 $t stp t'$，称 $t$ 是*范式*（normal form，也称“正规形式”）。按 #refer("definition/values-and-numeric-values") 判断，不是值的范式称为*受阻的*（stuck）。范式与受阻都相对于给定的转移规则定义；“范式”不表示正常结果，也不保证每个词项都能到达唯一范式。
