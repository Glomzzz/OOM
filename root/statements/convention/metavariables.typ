#import "/lib/statements.typ": *
#import "/lib/formal-math.typ": *

#let entry = (
  title: [元变量],
  date: "2026-10-10",
  author: "Glomzzz",
  parent: "/how/plt/formal/evaluation.typ",
  legacy-id: "fm-conv-metavar",
)

#show: statement-page.with("convention/metavariables", entry)

在 #refer("definition/one-step-reduction") 与 #refer("definition/types-and-typing-judgments") 的规则里，$t_1, t_2, t_1'$ 等字母是*元变量*（metavariable）：它们是元语言里的变量，可以代换成 #refer("definition/set-of-terms") 中的任意项；$#nv$ 只能代换成 #refer("definition/values-and-numeric-values") 中的数值。同一条规则里同一个字母必须代换成同一个东西。一条规则因此代表无穷多条*实例*（instance）。
