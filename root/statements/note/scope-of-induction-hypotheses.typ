#import "/lib/statements.typ": *
#import "/lib/formal-math.typ": *

#let entry = (
  title: [归纳假设的适用范围],
  date: "2026-10-10",
  author: "Glomzzz",
  parent: "/how/plt/formal/syntax.typ",
  legacy-id: "fm-rm-ih-scope",
)

#show: statement-page.with("note/scope-of-induction-hypotheses", entry)

#refer("theorem/structural-induction") 将归纳假设限定在直接子项上，但这只是针对该定理的表述，其他归纳原理可以有更大的适用范围．
若改用强归纳，先证明某个自然数度量严格下降，
就可以对度量更小的*任意*对象使用 #ih；对真子项的归纳也可以成立．
一般的要求叫*良基性*：不存在无限地向更小对象下降的链．

#refer("definition/immediate-and-proper-subterms") 的直接子项关系
在 #refer("definition/set-of-terms") 的有限树上是良基的，
但“规约后的项”并不因此自动是直接子项．
例如按 #refer("definition/one-step-reduction")，
$"succ" ("pred" 0)$ 一次计算变成 $"succ" 0$，后者并不属于前者的直接子项．
要在证明中对规约结果使用 #ih，必须另证合适的度量下降，或选择相应的归纳原理．
若把归纳假设用在不属当前归纳原理许可范围的对象上，证明就缺了一步；
若这个缺口依赖当前结论来填补，就构成循环论证．
