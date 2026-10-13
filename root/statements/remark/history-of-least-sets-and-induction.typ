#import "/lib/statements.typ": *
#import "/lib/formal-math.typ": *

#let entry = (
  title: [“最小 + 归纳”的历史],
  date: "2026-10-10",
  author: "Glomzzz",
  parent: "/how/plt/formal/syntax.typ",
  legacy-id: "fm-ph-least-history",
)

#show: statement-page.with("remark/history-of-least-sets-and-induction", entry)

“先把对象定义成满足某些规则的最小集合，再沿着这些规则归纳”，
这个方法在许多理论里反复出现：

- *自然数*：#wiki("理查德·戴德金")[Richard Dedekind] 在 1888 年的
  _Was sind und was sollen die Zahlen?_（《数是什么，应该是什么？》）中，
  把自然数定义为包含 $1$、对后继封闭的所有集合的交（他称为“链”），
  由此*证明*了数学归纳法，而不是把它当作公理．
  #wiki("朱塞佩·皮亚诺")[Giuseppe Peano] 1889 年的公理系统则把归纳作为公理．
- *递归函数论*：#wiki("斯蒂芬·科尔·克莱尼")[Stephen Cole Kleene] 等人在 1930 年代发展了递归函数论．
  按现代的一种刻画，*偏递归函数类*是包含零函数、后继函数与投影函数，
  对复合、原始递归和无界最小化封闭的最小偏函数类；
  若只有复合与原始递归，则得到的是原始递归函数类，不能覆盖全部可计算函数．
  参见 #link("https://www.cmi.ac.in/~spsuresh/teaching/plc16/lectures/lecture14.pdf")[Programming Language Concepts: Lecture 14，幻灯片 12]．
- *不动点定理*：#wiki("克纳斯特-塔斯基定理")[Knaster–Tarski 定理]（1928 / 1955）表明，
  完备格上的单调函数有最小不动点．
  #refer("definition/set-of-terms") 的“最小集合”正是“由封闭条件确定的函数”的最小不动点，
  这是归纳定义最一般的数学基础．
- *形式语言*：BNF 定义的语言，就是满足产生式的最小字符串或语法树集合．
- *类型论*：#wiki("佩尔·马丁-洛夫")[Per Martin-Löf] 的直觉主义类型论（1970 年代）
  把“归纳类型”作为基本构造：类型由它的构造子给出，并伴随相应的消去与归纳原理．
  Coq（现名 Rocq）、Lean、Agda 里的 `Inductive`、`inductive`、`data`
  是这一思想的直接实现，Rust 的 `enum` 则是它的工程化形式．
- *程序语义*：#enwiki("Gordon_Plotkin")[Gordon Plotkin] 1981 年的结构化操作语义讲义
  _A Structural Approach to Operational Semantics_，
  把“程序怎么运行”写成由推导规则定义的最小关系，
  #refer("definition/one-step-reduction") 使用的就是这种做法．

这些理论研究的对象虽然各不相同，所用的核心方法是同一个．
