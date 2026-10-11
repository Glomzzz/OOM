#import "/lib/formal.typ": *

#show: formal-page.with(title: [回头看与延伸阅读])

全文走过的路，可以按“用了什么前文”串成一条线：

+ 自然语言在结构、完备、量词、自指、可检查性上的五个弊端（#refer("example/structural-ambiguity") 至 #refer("example/berry-paradox")），引出对象语言与元语言的分层（#refer("definition/object-language-and-metalanguage")）。
+ 用“满足封闭条件的最小集合”定义项（#refer("definition/set-of-terms")），“最小”直接给出结构归纳（#refer("theorem/structural-induction")）。
+ 用同样的“最小”定义求值关系（#refer("definition/one-step-reduction")），得到对推导归纳（#refer("theorem/induction-on-derivations")），再证明确定性（#refer("theorem/determinism")）。
+ 用推导规则定义类型（#refer("definition/types-and-typing-judgments")）。语法导向给出反演（#refer("lemma/typing-inversion")），反演给出类型唯一和典范形式。
+ 进展与保型合起来得到类型安全（#refer("corollary/type-safety")）。
+ 证明检查器相对规则可靠且完备，把“检查器接受”与“运行不受阻”接上（#refer("corollary/accepted-programs-do-not-get-stuck")）。

贯穿始终的方法只有一个：*先把东西定义成满足某些规则的最小对象，再沿着这些规则归纳*。语言变大以后，规则会变多，证明会变长，但这个方法不变。它在数学和逻辑史上的来历，见 #refer("remark/history-of-least-sets-and-induction")。

#statement("note/unexamined-assumptions")

= 延伸阅读

- Benjamin C. Pierce. #link("https://www.cis.upenn.edu/~bcpierce/tapl/")[Types and Programming Languages]。第 2 章讲归纳定义与归纳法，第 3、8 章就是本文这门语言，规则名沿用了它的写法。
- #link("https://softwarefoundations.cis.upenn.edu/")[Software Foundations]。在 Coq 里从零开始讲归纳证明，第二卷的 `Types` 一章把本文的定理全部机械化证明了一遍。
- Andrew K. Wright, Matthias Felleisen. #link("https://doi.org/10.1006/inco.1994.1093")[A Syntactic Approach to Type Soundness]. Information and Computation, 1994。进展 + 保型这种证明方式的出处。
- Robert Harper. #link("https://www.cs.cmu.edu/~rwh/pfpl/")[Practical Foundations for Programming Languages]。第 1、2 章对“抽象语法”和“归纳定义”的处理比 TAPL 更细致。

#html.nav(class: "chapter-nav", aria-label: "文章导航")[
  #cite("/how/plt/formal/09-test-and-proof.typ")[← 用测试对照证明]
  #cite("/how/plt/formal/index.typ")[回到形式化入门]
]
