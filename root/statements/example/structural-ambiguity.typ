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

“咬死了猎人的狗”可以是“（咬死了猎人）的狗”，一条狗；也可以是“咬死了（猎人的狗）”，一个事件。两种读法用的字完全相同，差别只在*怎样分组*。

程序里同样的事随处可见。`1 + 2 * 3` 是 $(1 + 2) times 3 = 9$ 还是 $1 + (2 times 3) = 7$？`if a then if b then x else y` 里的 `else` 属于哪个 `if`？
