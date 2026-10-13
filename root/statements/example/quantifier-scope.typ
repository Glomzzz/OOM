#import "/lib/statements.typ": *
#import "/lib/formal-math.typ": *

#let entry = (
  title: [量词的范围],
  date: "2026-10-10",
  author: "Glomzzz",
  parent: "/how/plt/formal/natural-and-formal.typ",
  legacy-id: "fm-ex-scope",
)

#show: statement-page.with("example/quantifier-scope", entry)

“所有测试都没通过”可以是“每个测试都失败了”，
也可以是“并非所有测试都通过了”，后者只要有一个失败就成立．
两种读法的差别在于“所有”和“没”哪个管着哪个．

把量词的作用范围明确写出来：
前者是“对每个 $x$，$x$ 都没通过”，后者是“并非（对每个 $x$，$x$ 都通过）”．
写出来之后，两句话的结构就不再混淆了．
