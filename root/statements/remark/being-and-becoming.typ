#import "/lib/statements.typ": *
#import "/lib/formal-math.typ": *

#let entry = (
  title: [存在与生成],
  date: "2026-10-10",
  author: "Glomzzz",
  parent: "/how/plt/formal/evaluation.typ",
  legacy-id: "fm-ph-being",
)

#show: statement-page.with("remark/being-and-becoming", entry)

哲学里研究“究竟什么是存在的、存在者有哪些基本形式与范畴”的分支称为
#wiki("本体论")[本体论]（此处仅作帮助记忆的类比，并非对本体论的哲学论证）．
这里说的“语法类似本体论”，只指对象语言的语法对象：
#refer("definition/set-of-terms") 列出了这门算术语言里*有*哪些词项，
而“最小”保证除此之外没有别的对象．

但只有“是什么”还不够．
可以借古希腊哲学中关于存在与变化的两种思路作对照：
#wiki("巴门尼德")[Parmenides] 的论述强调存在者的不生不灭与不变；
#wiki("赫拉克利特")[Heraclitus] 则常由后人读作强调流变的哲学家．
“人不能两次踏进同一条河流”的说法，
见 Plato #link("https://www.perseus.tufts.edu/hopper/text?doc=Perseus%3Atext%3A1999.01.0172%3Atext%3DCrat.%3Asection%3D402a")[《克拉底鲁篇》402a]
中 Socrates 对 Heraclitus 的转述；
它不能不加说明地当作原著残篇的逐字引文，对流变思想的解释也有分歧
（见 #link("https://plato.stanford.edu/entries/heraclitus/")[SEP: Heraclitus]）．
这里只作思想对照，不把它写成两人直接交锋、随后调和的历史过程．

Aristotle 讨论变化时区分*潜能*与*现实*，
可以借它提示“有某种能力”与“这种能力的实现”之间的区别；
这一概括不代替他的完整变化理论
（参见 #link("https://plato.stanford.edu/entries/aristotle-metaphysics/#ActuPote")[SEP: Aristotle's Metaphysics §12]）．

这个区分在操作语义里有一个直观的对应．
按 #refer("definition/one-step-reduction")，
词项 $"pred" ("succ" 0)$ 作为语法对象就是它自己，不会改变；
但它在转移关系下可以规约到 $0$．
#refer("definition/values-and-numeric-values") 所划出的*值*，
则可以比作已经没有规约余地的项：它不能再转移到别的项
（#refer("lemma/values-do-not-reduce")）．
语法管“有哪些项”，语义管“项怎样一步步转移”．
这个对应只用来帮助记忆；具体结论仍由规则、反例与证明承担．
