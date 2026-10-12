#import "/lib/statements.typ": *
#import "/lib/formal-math.typ": *

#let entry = (
  title: [陈述与证明],
  date: "2026-10-11",
  author: "Glomzzz",
  parent: "/how/plt/prelude.typ",
  legacy-id: "pl-thm",
)

#show: statement-page.with("theorem/theorem-environment", entry)

“Theorem（定理）”是需要证明、而且本身就是论证目标的命题。定理条目把陈述与证明放在同一份正文中。

#proof[
  证明写全所有情形，每一步都说明用了哪条定义、哪条规则或哪个已证明的结果。证明以 ∎ 结尾。第一次读可以跳过证明，只看定理说了什么。
]
