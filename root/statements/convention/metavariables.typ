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

在 #refer("definition/one-step-reduction") 与 #refer("definition/types-and-typing-judgments") 的规则里，$t_1, t_2, t'_1$ 等字母是*元变量*（metavariable）：它们属于元语言，可以代换为 #refer("definition/set-of-terms") 中的任意词项，并不是对象语言中可执行的变量。$v$ 只能代换为值，$#nv$ 只能代换为数值（#refer("definition/values-and-numeric-values")），$T$ 则只能代换为类型。同一条规则中同一个元变量的所有出现必须使用相同的代换。一条推理规则因此表示许多具体*实例*（instance），而不是一条只适用于这些字母的陈述。
