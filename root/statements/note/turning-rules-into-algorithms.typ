#import "/lib/statements.typ": *
#import "/lib/formal-math.typ": *

#let entry = (
  title: [不是所有规则都能直接照抄成算法],
  date: "2026-10-10",
  author: "Glomzzz",
  parent: "/how/plt/formal/rules-and-algorithms.typ",
  legacy-id: "fm-rm-guess",
)

#show: statement-page.with("note/turning-rules-into-algorithms", entry)

如果某条规则的前提里出现了一个结论里看不到、子项也算不出的类型，照着规则写函数就走不通，函数不知道该填什么。函数类型的规则就是典型例子：给 $lambda x. t$（记号见 #refer("note/evaluation-strategies-reduction-strategies-and-confluence")）定型时，参数 $x$ 的类型在项里找不到。那时规则仍然定义了一个清清楚楚的关系，但从关系到算法的那一步，需要额外的设计和额外的证明。#refer("definition/types-and-typing-judgments") 的布尔值／自然数语言足够小，避开了这个问题；但区分“规则”和“算法”、并分别证明可靠与完备的习惯，在更大的语言里同样适用。
