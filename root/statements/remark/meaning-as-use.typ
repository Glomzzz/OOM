#import "/lib/statements.typ": *
#import "/lib/formal-math.typ": *

#let entry = (
  title: [意义即使用],
  date: "2026-10-10",
  author: "Glomzzz",
  parent: "/how/plt/formal/03-evaluation.typ",
  legacy-id: "fm-ph-use",
)

#show: statement-page.with("remark/meaning-as-use", entry)

#refer("definition/one-step-reduction") 不用自然语言的直觉解释来决定 $"succ"$ “是什么”，而是规定它在计算里*怎样被使用*。后期#wiki("路德维希·维特根斯坦")[维特根斯坦（Wittgenstein）]在《哲学研究》里提出，一个词的意义在很多情况下就是它在语言中的用法；逻辑学里的推理主义（inferentialism，#wiki("格哈德·根岑")[根岑（Gentzen）]、#enwiki("Dag_Prawitz")[普拉维茨（Prawitz）]、#wiki("迈克尔·达米特")[达米特（Dummett）]、#enwiki("Robert_Brandom")[布兰顿（Brandom）]一脉）更进一步，主张逻辑联结词的意义由它的推理规则给出。

操作语义正是这种立场的工程版本：一个构造的意义，就是关于它的规则的全体。这种立场有一个好处，它把“意义”变成了可以逐条核对的东西。
