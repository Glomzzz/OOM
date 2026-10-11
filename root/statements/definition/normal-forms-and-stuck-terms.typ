#import "/lib/statements.typ": *
#import "/lib/formal-math.typ": *

#let entry = (
  title: [范式与受阻],
  date: "2026-10-10",
  author: "Glomzzz",
  parent: "/how/plt/formal/05-normal-forms.typ",
  legacy-id: "fm-def-stuck",
)

#show: statement-page.with("definition/normal-forms-and-stuck-terms", entry)

采用 #refer("definition/one-step-reduction") 的关系 $stp$。若不存在 $t'$ 使 $t stp t'$，称 $t$ 是*范式*（normal form）。按 #refer("definition/values-and-numeric-values") 判断，不是值的范式称为*受阻的*（stuck）。
