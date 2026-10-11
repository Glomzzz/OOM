#import "/lib/statements.typ": *
#import "/lib/formal-math.typ": *

#let entry = (
  title: [什么是归纳],
  date: "2026-10-10",
  author: "Glomzzz",
  parent: "/how/plt/formal/02-syntax.typ",
  legacy-id: "fm-rm-what-induction",
)

#show: statement-page.with("note/meaning-of-induction", entry)

“归纳”（induction）这个词在不同领域里意思不一样，先分清楚。

- 在经验科学和日常推理里，*归纳推理*是从有限个观察得出普遍结论：见过的天鹅都是白的，于是“所有天鹅都是白的”。与它对立的是*演绎推理*（deduction）：从前提出发，按逻辑规则推出结论，前提为真则结论必真。归纳推理的结论可能出错（澳大利亚有黑天鹅），#wiki("大卫·休谟")[休谟（Hume）]在 18 世纪指出，归纳推理没有逻辑上的保证，这就是#wiki("归纳问题")[归纳问题]。
- 数学里的*数学归纳法*名字里虽然有“归纳”，却是一种*演绎*：证明 $P(0)$，再证明“$P(n)$ 蕴涵 $P(n+1)$”，就能断定所有自然数都满足 $P$，没有任何“可能出错”的余地。#refer("theorem/structural-induction") 与 #refer("theorem/induction-on-derivations") 使用的也是这种演绎证明方法。

数学归纳法的历史很长。古希腊的#wiki("欧几里得")[欧几里得（Euclid）]证明素数有无穷多个时，已经有了它的影子；16 世纪的莫罗利科（Maurolico）、17 世纪的#wiki("布莱兹·帕斯卡")[帕斯卡（Pascal）]在讨论二项式系数时比较明确地用了它；“数学归纳法”这个名字是 19 世纪#wiki("奥古斯塔斯·德摩根")[德摩根（De Morgan）]起的。19 世纪末，#wiki("理查德·戴德金")[戴德金（Dedekind）]和#wiki("朱塞佩·皮亚诺")[皮亚诺（Peano）]把它写成了自然数的公理之一，并指出它其实来自“自然数是包含 $0$、对后继封闭的*最小*集合”。#refer("theorem/structural-induction") 把这个想法从自然数推广到由规则搭起来的有限树。

在程序语言理论里，和归纳对立的是*余归纳*（coinduction）。归纳对应“最小”的集合，处理有限的、搭得完的对象；余归纳对应“最大”的集合，处理可以无限展开的对象，比如永不停机的程序、无穷长的数据流。#refer("definition/set-of-terms") 的有限项与 #refer("definition/one-step-reduction") 的有限推导都属于归纳定义的对象。
