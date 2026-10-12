#import "/lib/statements.typ": *
#import "/lib/formal-math.typ": *

#let entry = (
  title: [意义即使用],
  date: "2026-10-10",
  author: "Glomzzz",
  parent: "/how/plt/formal/evaluation.typ",
  legacy-id: "fm-ph-use",
)

#show: statement-page.with("remark/meaning-as-use", entry)

这里与晚期#wiki("路德维希·维特根斯坦")[维特根斯坦（Wittgenstein）]对语言使用的关注作一种有限的类比。《哲学研究》§43（下文均为意译）说：对“意义”一词的一大类用法（但不是全部），可以这样解释：一个词的意义就是它在语言中的使用；它还补充说，名字的意义有时是靠指出其承担者来解释的。

本文针对程序构造的计算行为，选择用操作语义明确规定允许的归约步骤：#refer("definition/one-step-reduction") 不靠自然语言的直觉解释来说明 $"succ"$ “是什么”，而是规定它在计算里*怎样被使用*。这个模型让具体行为与规则之间的关系可以逐条核对；它的价值应通过反例、性质证明和实现来说明。

需要留意两处边界。第一，维特根斯坦讨论的“使用”还涉及学习、应用和纠错的实践，不能直接压缩成一份明列的形式规则；《哲学研究》§198—202 恰恰处理规则与行动的关系：§198 说，解释本身“悬在半空”，单靠解释不能确定意义，规则与行动的联系在于已有的用法与习惯；§199、§202 说，遵循规则是一种习惯、制度或实践，自以为在遵循并不等于遵循；§201 把“任何行动都能与规则一致”当作需要消解的悖论，而不是结论。所以，写下来的规则要被遵循，仍依赖这样的实践（原文见 #link("https://danielwharris.com/teaching/38080/readings/WittgensteinPI.pdf")[《哲学研究》英德对照版]）。第二，逻辑学里的推理主义（inferentialism，#wiki("格哈德·根岑")[根岑（Gentzen）]、#enwiki("Dag_Prawitz")[普拉维茨（Prawitz）]、#wiki("迈克尔·达米特")[达米特（Dummett）]、#enwiki("Robert_Brandom")[布兰顿（Brandom）]一脉）主张逻辑联结词的意义由引入与消去的推理规则给出。根岑本人在 #link("https://logic-teaching.github.io/prop/texts/Gentzen%201969%20-%20Investigations%20into%20Logical%20Deduction.pdf")[《逻辑推演研究》（Szabo 编英译本）] 第二部分 §5.13 里说，引入规则好比相应符号的“定义”，消去规则不过是这些定义的后承（意译）。这些讨论的是证明与推理；它与程序如何执行有联系，但“都使用规则”不足以说明两者是同一个问题。所以，这里不把操作语义说成上述哲学立场的“工程版本”，只借它们提示一个问题：把一个构造的用法写清楚，会带来哪些可核对的东西。
