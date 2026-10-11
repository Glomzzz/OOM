#import "/lib/statements.typ": *
#import "/lib/formal-math.typ": *

#let entry = (
  title: [抽象语法],
  date: "2026-10-10",
  author: "Glomzzz",
  parent: "/how/plt/formal/02-syntax.typ",
  legacy-id: "fm-conv-ast",
)

#show: statement-page.with("convention/abstract-syntax", entry)

*抽象语法*（abstract syntax）把程序视为*语法树*（syntax tree），即节点标签表示程序构造的树（树的术语见 #refer("definition/tree-terminology")），而不是一串字符。从字符串到树的那一步叫解析（parsing）。采用这条约定时，假定解析已经完成，而且已经消除了 #refer("example/structural-ambiguity") 那样的歧义；解析器本身不在这条约定的研究范围内。书写时为了能在一行里写下一棵树，会用括号表示分组：$"pred" ("succ" 0)$ 表示根标着 $"pred"$，它的唯一孩子标着 $"succ"$；这个孩子及其后代构成表示 $"succ" 0$ 的子树。
