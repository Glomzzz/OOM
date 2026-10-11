#import "/lib/statements.typ": *
#import "/lib/formal-math.typ": *

#let entry = (
  title: [存在与生成],
  date: "2026-10-10",
  author: "Glomzzz",
  parent: "/how/plt/formal/03-evaluation.typ",
  legacy-id: "fm-ph-being",
)

#show: statement-page.with("remark/being-and-becoming", entry)

庸俗来说，哲学里研究“究竟什么是存在的？存在者又有哪些最基本的形式与范畴？”的分支叫#wiki("本体论")[本体论（ontology）]。语法就是对象语言的本体论：#refer("definition/set-of-terms") 列出了这门语言里*有*哪些东西，而“最小”保证除此之外什么也没有。

但只有“是什么”还不够。古希腊哲学最早的争论之一，就是#wiki("巴门尼德")[巴门尼德（Parmenides）]与#wiki("赫拉克利特")[赫拉克利特（Heraclitus）]之争：前者认为真正存在的东西不生不灭、不会变化，后者认为万物皆流，“人不能两次踏进同一条河流”。亚里士多德的调和办法是区分*潜能*（dynamis）与*现实*（energeia）：变化，就是事物把它潜在的可能变成现实。

这个区分在操作语义里有一个很贴切的对应。按 #refer("definition/one-step-reduction")，项 $"pred" ("succ" 0)$ 作为语法对象，就是它自己，不会变；但它有一种“潜能”，可以变成 $0$。#refer("definition/values-and-numeric-values") 所划出的*值*，可以比作已经完全成为现实、再没有这种归约潜能的项：它不能再变成别的东西（#refer("lemma/values-do-not-reduce")）。语法管“存在”，语义管“生成”。
