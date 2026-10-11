#import "/lib/statements.typ": *
#import "/lib/formal-math.typ": *

#let entry = (
  title: [“最小 + 归纳”的历史],
  date: "2026-10-10",
  author: "Glomzzz",
  parent: "/how/plt/formal/02-syntax.typ",
  legacy-id: "fm-ph-least-history",
)

#show: statement-page.with("remark/history-of-least-sets-and-induction", entry)

“先把东西定义成满足某些规则的最小对象，再沿着这些规则归纳”，这个方法在许多理论里反复出现：

- *自然数*：戴德金 1888 年的《数是什么，应该是什么？》把自然数定义为包含 $1$、对后继封闭的所有集合的交（他称为“链”），由此*证明*了数学归纳法，而不是把它当作公理。皮亚诺 1889 年的公理系统则把同一件事写成了第五条公理。
- *递归函数论*：#wiki("斯蒂芬·科尔·克莱尼")[克莱尼（Kleene）]等人在 1930 年代把“可计算函数”定义为包含基本函数、对复合和递归封闭的最小函数类。
- *不动点定理*：#wiki("克纳斯特-塔斯基定理")[克纳斯特–塔斯基定理]（1928 / 1955）说，完备格上的单调函数有最小不动点。#refer("definition/set-of-terms") 的“最小集合”正是“由封闭条件确定的函数”的最小不动点，这是归纳定义最一般的数学基础。
- *形式语言*：BNF 定义的语言，就是满足产生式的最小字符串集合。
- *类型论*：#wiki("佩尔·马丁-洛夫")[马丁-洛夫（Martin-Löf）]的直觉主义类型论（1970 年代）把“归纳类型”作为基本构造：一个类型由它的构造子给出，并自动附带一个归纳原理。Coq、Lean、Agda 里的 `Inductive` / `inductive` / `data` 就是这个想法的直接实现，Rust 的 `enum` 也是它的一个简化版。
- *程序语义*：#enwiki("Gordon_Plotkin")[普洛特金（Plotkin）]1981 年的结构化操作语义讲义，把“程序怎么运行”写成推导规则定义的最小关系，#refer("definition/one-step-reduction") 使用的就是这种做法。

这些理论研究的对象虽然各不相同，用的方法是同一个。
