#import "/lib/statements.typ": *
#import "/lib/formal-math.typ": *

#let entry = (
  title: [归纳假设不只限于直接子项],
  date: "2026-10-10",
  author: "Glomzzz",
  parent: "/how/plt/formal/02-syntax.typ",
  legacy-id: "fm-rm-ih-scope",
)

#show: statement-page.with("note/scope-of-induction-hypotheses", entry)

“只能对直接子项使用”是 #refer("theorem/structural-induction") 的直接表述，不是一切归纳法的限制。若改用强归纳，先证明某个自然数度量严格下降，就可以对度量更小的*任意*对象使用 #ih；对真子项的归纳也可以成立。一般的要求叫*良基性*（well-foundedness）：不存在无限地向更小对象下降的链。

#refer("definition/immediate-and-proper-subterms") 的直接子项关系在 #refer("definition/set-of-terms") 的有限树上是良基的，但“归约后的项”并不因此自动是直接子项。例如按 #refer("definition/one-step-reduction")，$"succ" ("pred" 0)$ 一次计算变成 $"succ" 0$，后者不是前者的直接子项。要在证明中对归约结果使用 #ih，必须另证合适的度量下降，或选择相应的归纳原理。用在一个不被当前归纳原理许可的对象上，证明就是缺了一步；若这个缺口依赖当前结论来填，就构成循环论证。
