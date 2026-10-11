#import "/lib/statements.typ": *
#import "/lib/formal-math.typ": *

#let entry = (
  title: [约定与必然],
  date: "2026-10-10",
  author: "Glomzzz",
  parent: "/how/plt/formal/07-type-safety.typ",
  legacy-id: "fm-ph-analytic",
)

#show: statement-page.with("remark/convention-and-necessity", entry)

#refer("corollary/type-safety") 的证明里，我们一次也没有运行程序，却得到了关于*所有*运行的结论。这让人想起#wiki("伊曼努尔·康德")[康德（Kant）]的问题：有没有不靠经验、却又对经验有效的知识？

这里的答案相当朴素。结论之所以不靠"试"，是因为"运行"本身就是我们用规则定义出来的（#refer("definition/one-step-reduction")），定理只是把定义里已经包含的东西展开。按逻辑实证主义的说法，这类命题是*分析的*：它的真依赖于定义。但这不等于它空洞。"所有良类型程序都不受阻"在定义里并不显眼，要靠反演、典范形式、两层归纳才能抽出来，中途还可能发现定义写错了（#refer("note/proofs-behind-pattern-matching-order") 和 #refer("note/numeric-value-restriction-in-predecessor-reduction") 就是例子）。弗雷格说过，一个结论可以"像植物包含在种子里那样"包含在定义中，而不是"像梁木包含在房子里那样"一眼可见。

另一面是：证明只对*这套规则*成立。真实的 CPU 是否忠实地执行了这些规则，是另一个问题，属于经验，要靠测试和工程去回答。
