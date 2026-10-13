#import "/lib/statements.typ": *
#import "/lib/formal-math.typ": *

#let entry = (
  title: [Berry 悖论],
  date: "2026-10-10",
  author: "Glomzzz",
  parent: "/how/plt/formal/natural-and-formal.typ",
  legacy-id: "fm-ex-berry",
)

#show: statement-page.with("example/berry-paradox", entry)

下面是 #enwiki("Berry_paradox")[Berry 悖论]的一个汉语版本．

考虑这个短语：“不能用少于二十个字来定义的最小正整数”．

先固定一套包含这些字的有限字符表，以字符数计长，
并假定每个有效描述至多定义一个正整数．
少于二十个字的字符串只有有限多个，所以它们至多定义有限多个正整数；
这些短字符串未能定义的正整数中必有最小者，记为 $n$．
若上面这个十八字短语也是同一描述语言中的有效描述，
并且这里的“定义”仍能无条件地适用于包含它自身的全部描述，它又恰好定义了 $n$．
于是 $n$ 既能又不能用少于二十个字定义，矛盾．

计数本身没有要求先把这个短语排除．
需要检查的是：描述语言与判定“哪个表达式定义哪个数”的语义条件有没有固定，
以及这个语义概念能否在同一层次无限制地涵盖自身．
把描述语言与谈论其语义的元语言分开，是避免这种混用的一种办法，
不是说所有自指都会造成矛盾．

延伸资料：#link("https://www.bilibili.com/video/BV1MP41147zF/")[毕的二阶导：迷惑的贝里悖论——20 个汉字真的能表达所有自然数吗？]
