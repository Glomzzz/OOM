#import "/lib/statements.typ": *
#import "/lib/formal-math.typ": *

#let entry = (
  title: [结构歧义],
  date: "2026-10-10",
  author: "Glomzzz",
  parent: "/how/plt/formal/natural-and-formal.typ",
  legacy-id: "fm-ex-ambig",
)

#show: statement-page.with("example/structural-ambiguity", entry)

“咬死了猎人的狗”可以读成“（咬死了猎人）的狗”，指一条狗；
也可以读成“咬死了（猎人的狗）”，指一件事．
两种读法用的字完全相同，差别只在*怎样分组*．

程序里同样的情况随处可见：
`1 + 2 * 3` 既可按 $(1 + 2) times 3 = 9$ 分组，也可按 $1 + (2 times 3) = 7$ 分组；
`if a then if b then x else y` 里的 `else` 既可挂在内层 `if` 上，也可挂在外层 `if` 上．
