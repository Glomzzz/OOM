#import "/lib/statements.typ": *
#import "/lib/formal-math.typ": *

#let entry = (
  title: [反演依赖语法导向],
  date: "2026-10-10",
  author: "Glomzzz",
  parent: "/how/plt/formal/typing.typ",
  legacy-id: "fm-rm-inv-premise",
)

#show: statement-page.with("note/inversion-and-syntax-directed-rules", entry)

#refer("lemma/typing-inversion") 中直接确定最后一条规则的证明，
依赖 #refer("definition/types-and-typing-judgments") 的*语法导向*性质：
每种项形状只对应一条候选规则．
如果将来加一条不看项形状的规则
（例如子类型里常见的“若 $t : S$ 且 $S <: T$，则 $t : T$”），
那么 $"succ" t_1 : T$ 的最后一步就可能是这条新规则，
“最后一步必然是 T-Succ”的推理就断了．
到那时反演需要重新陈述、重新证明．
这不是说非语法导向系统不能证明反演引理，而是不能直接沿用这份逐形状的证明．
