#import "/lib/statements.typ": *
#import "/lib/formal-math.typ": *

#let entry = (
  title: [什么是归纳],
  date: "2026-10-10",
  author: "Glomzzz",
  parent: "/how/plt/formal/syntax.typ",
  legacy-id: "fm-rm-what-induction",
)

#show: statement-page.with("note/meaning-of-induction", entry)

“归纳”这个词在不同领域里意思不一样，先分清楚．

- 在经验科学和日常推理里，*归纳推理*是从有限次观察得出普遍结论：
  见过的天鹅都是白的，于是推断“所有天鹅都是白的”．
  与它相对的是*演绎推理*：从前提出发，按逻辑规则推出结论，前提为真则结论必真．
  归纳推理的结论可能出错（澳大利亚有黑天鹅）；
  #wiki("大卫·休谟")[David Hume] 在 18 世纪指出，归纳推理没有逻辑上的保证，
  这就是#wiki("归纳问题")[归纳问题]．
- 数学里的*数学归纳法*名字里虽然有“归纳”，却属于*演绎*：
  证明 $P(0)$，再证明“$P(n)$ 蕴涵 $P(n+1)$”，就能断定所有自然数都满足 $P$，
  没有“可能出错”的余地．
  #refer("theorem/structural-induction")
  与 #refer("theorem/induction-on-derivations") 使用的也是这种演绎证明方法．

数学归纳法的历史很长．
古希腊的 #wiki("欧几里得")[Euclid] 证明素数有无穷多个时，已经有了它的影子；
16 世纪的 Francesco Maurolico、17 世纪的 #wiki("布莱兹·帕斯卡")[Blaise Pascal]
在讨论二项式系数时比较明确地用了它；
“数学归纳法”这个名字是 19 世纪 #wiki("奥古斯塔斯·德摩根")[Augustus De Morgan] 起的．
19 世纪末，#wiki("理查德·戴德金")[Richard Dedekind] 由自然数的*最小性*推导出归纳原理，
#wiki("朱塞佩·皮亚诺")[Giuseppe Peano] 则把归纳列入自然数公理．
#refer("theorem/structural-induction") 把这个想法从自然数推广到由规则搭起来的有限树．

#refer("definition/set-of-terms") 的有限项
与 #refer("definition/one-step-reduction") 的有限推导，采用的是归纳定义：
由这些有限前提的规则生成最小集合，每个对象都有有限的构造或推导．

*余归纳*则可用相应单调算子的最大不动点刻画对象或行为，并据此证明性质．
它可以描述无限展开，例如无穷数据流或无限运行，但不意味着其中只有无限对象：
带空构造子的余归纳列表就可以同时包含有限和无限列表．
*共递归*侧重怎样按观察结构逐步产生这样的对象；
要定义可用的无限数据，还须保证每次索取有限的可观察部分都能在有限计算后得到，
这称为*生产性*．
非结构递归不自动就是共递归，也不自动具有生产性．
列表与受保护共递归的例子见
#link("https://flint.cs.yale.edu/cs428/coq/pdf/RecTutorial.pdf")[A Tutorial on [Co-]Inductive Types in Coq §7]．
