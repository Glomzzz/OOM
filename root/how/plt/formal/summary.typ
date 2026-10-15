#import "/lib/formal.typ": *

#show: formal-page.with(
  title: [总结],
  description: [回顾从抽象语法、小步语义到类型安全与检查器可靠性的定义、归纳与证明链条．],
)

全文走过的路，按前后的依赖关系首尾相接．
从自然语言在结构、完备、量词、自指、可检查性上的五个弊端（#refer("example/structural-ambiguity") 至 #refer("example/berry-paradox")）出发，我们先引入对象语言与元语言的分层（#refer("definition/object-language-and-metalanguage")）；
接着用“满足封闭条件的最小集合”定义项（#refer("definition/set-of-terms")），由“最小”直接导出结构归纳（#refer("theorem/structural-induction")）；
再用同样的最小性定义小步语义的转移关系（#refer("definition/one-step-reduction")），得到规则归纳法（#refer("theorem/induction-on-derivations")），进而证明确定性（#refer("theorem/determinism")）以及大小严格下降带来的终止性（#refer("lemma/reduction-decreases-size")）．

在此基础上，我们用推导规则定义类型关系及其可推导的类型判断（#refer("definition/types-and-typing-judgments")），借助语法导向证明反演（#refer("lemma/typing-inversion")）、类型唯一与典范形式；
再把进展与保型合起来，得到类型安全，即本文意义下的类型健全性（#refer("corollary/type-safety")），并结合另行证明的终止性与确定性，推出良类型项求值到唯一的同类型值（#refer("corollary/well-typed-terms-evaluate-to-unique-values")）．
最后，证明检查器相对规则可靠且完备，把“检查器接受”与“运行不受阻”接成完整的端到端结论（#refer("corollary/accepted-programs-do-not-get-stuck")）．

贯穿始终的方法只有一个：
*先把东西定义成满足某些规则的最小对象，再沿着这些规则归纳*．
语言变大以后，规则会变多，证明会变长，但这个方法不变．
它在数学和逻辑史上的来历，见
#refer("remark/history-of-least-sets-and-induction")．

#statement("note/unexamined-assumptions")

= 延伸阅读

本系列的布尔值与自然数语言、规则名称与证明主线以
_Types and Programming Languages_（TAPL）为基础．
术语译名以#link("https://bananaspace.org/")[香蕉空间]的条目为准，
香蕉空间尚未收录的术语参考下面两篇中文译文；
全部术语对照见 #cite("/how/terms.typ")[术语对照]．
参考译文不意味着把不同模型的规则或结论直接移植到本文．

Benjamin C. Pierce 的 #link("https://www.cis.upenn.edu/~bcpierce/tapl/")[_Types and Programming Languages_]（《类型和程序设计语言》）第 2 章讲归纳定义与归纳法，第 3、8 章就是本文这门语言，规则名沿用了它的写法．
Benjamin C. Pierce 等人的 #link("https://softwarefoundations.cis.upenn.edu/")[_Software Foundations_]（《软件基础》）在 Coq（现名 Rocq）里从零开始讲归纳证明；
第二卷 _Programming Language Foundations_ 的 #link("https://softwarefoundations.cis.upenn.edu/plf-current/Types.html")[`Types` 一章]给出相近算术语言的形式化定义，讲解进展、保型和类型安全，并留下相关机械化证明练习（公开代码中的 `Admitted` 留作待读者补全的练习，该章也不涉及本文的 Rust 实现）．

进展加保型这种证明方式出自 Andrew K. Wright 与 Matthias Felleisen 1994 年发表于 _Information and Computation_ 的论文 #link("https://doi.org/10.1006/inco.1994.1093")[A Syntactic Approach to Type Soundness]．
Robert Harper 的 #link("https://www.cs.cmu.edu/~rwh/pfpl/")[_Practical Foundations for Programming Languages_]（《编程语言的实用基础》）第 1、2 章对“抽象语法”和“归纳定义”的处理比 TAPL 更细致．

中文入门文章可读 Chuigda Whitegive 翻译的两篇：
Graham Hutton 著的#link("https://chuigda.doki7.club/research/pl-semantics-1-2-3.html")[《程序语言语义学：数数手指一二三》]用整数与加法语言比较指称语义、小步语义、语境语义和大步语义，讲解结构归纳法与规则归纳法，并进一步推演抽象机；
Alexis King 著的#link("https://chuigda.doki7.club/research/type-system-notation.html")[《如何阅读类型系统符号》]说明文法、词项与类型、类型判断、公理和推导规则，以及语境、附加条件和类型判断的算法解释．

#html.nav(class: "chapter-nav", aria-label: "文章导航")[
  #cite("/how/plt/formal/test-and-proof.typ")[← 用测试对照证明]
  #cite("/how/plt/formal/index.typ")[回到形式化入门]
]
