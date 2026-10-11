#import "/lib/statements.typ": *
#import "/lib/formal-math.typ": *

#let entry = (
  title: [贝里悖论],
  date: "2026-10-10",
  author: "Glomzzz",
  parent: "/how/plt/formal/01-natural-and-formal.typ",
  legacy-id: "fm-ex-berry",
)

#show: statement-page.with("example/berry-paradox", entry)

下面是#enwiki("Berry_paradox")[贝里悖论（Berry paradox）]的一个汉语版本。

考虑这个短语：“不能用少于二十个字来定义的最小正整数”。

汉字只有有限多个，少于二十个字的短语也只有有限多个，它们最多定义有限多个正整数。所以确实存在不能用少于二十个字定义的正整数，其中有一个最小的，记为 $n$。可上面那个短语本身只有十八个字，它恰好定义了 $n$。于是 $n$ *能*用少于二十个字定义，矛盾。

附：#link("https://www.bilibili.com/video/BV1MP41147zF/")[毕的二阶导 —— 迷惑的贝里悖论：20个汉字真的能表达所有自然数吗？]
