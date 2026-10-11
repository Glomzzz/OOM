#import "/lib/formal.typ": *

#show: formal-page.with(title: [求值：用推导规则定义运行])

上一节回答的是项*是什么*（What）：它由哪些符号、按什么结构搭成。这一节回答项*怎么运行*（How）：一个项会一步一步变成什么。前者叫*语法*（syntax），后者叫*语义*（semantics）。这里给出语义的方式是直接描述程序运行的每一步，称为*操作语义*（operational semantics）。#refer("example/incomplete-specifications") 里“先算哪边”那类问题，在这一节都要有确定的答案。

#statement("remark/being-and-becoming")

= 值

先划出“已经算完”的项。

#statement("definition/values-and-numeric-values")

数值就是 $0$、$"succ" 0$、$"succ" ("succ" 0)$……，分别代表 $0, 1, 2, dots$。几个例子：

- $"true"$、$0$、$"succ" ("succ" 0)$ 是值；
- $"succ" "true"$ 是项，但不是值：$"succ"$ 后面必须是数值，而 $"true"$ 不是；
- $"pred" 0$ 也不是值，值的定义里根本没有 $"pred"$。直观上，它还能再算。

= 推导规则怎么读

先说“归约”这个词。*归约*（reduction）指把一个项改写成另一个更接近结果的项，就像中学代数里把 $(1 + 2) times 3$ 改写成 $3 times 3$，再改写成 $9$。每次改写只动一处，叫*一步归约*（one-step reduction）；连续改写若干次，叫*多步归约*（multi-step reduction）。程序“运行”，在这里就是指一步接一步地归约，直到不能再归约为止。

#statement("convention/reading-the-reduction-arrow")

数学上，$stp$ 是一个*二元关系*（binary relation）：它是由一些 $(t, t')$ 对组成的集合，$t stp t'$ 就是 $(t, t') in #h(0.2em) stp$ 的简写。我们用*推导规则*（inference rule）来定义它。一条规则长这样：

$ frac("前提"_1 quad dots.c quad "前提"_n, "结论") $

读作：如果横线上的前提（premise）全都成立，那么横线下的结论（conclusion）成立。没有前提的规则叫*公理*（axiom），它的结论无条件成立。

横线右边可以标上规则的名字来方便引用。

#statement("convention/metavariables")

#statement("definition/one-step-reduction")

这里的“最小”和 #refer("definition/set-of-terms") 里的“最小”是同一个意思：$t stp t'$ 成立，*当且仅当*能用这十条规则的实例搭出一棵以它为根的有限树。这棵树叫*推导*（derivation）。

规则没有提到的情形，例如 $"succ" "true"$ 该归约到哪里，那就是没有定义。“没有定义”在这里有精确的含义：十条规则里没有一条的结论能匹配 $"succ" "true" stp dots$（E-Succ 的结论的形状对得上，但它的前提却要求 $"true"$ 能归约，而没有规则能做到），所以不存在任何 $t'$ 使 $"succ" "true" stp t'$。

那么遇到没有定义的情形该怎么办？形式化的回答是：*不要假装它有定义*，而是把它当作一个明确的状态来对待。具体有三种常见做法：

+ *承认它是错误状态*。把“不是值、却又不能归约”的项单独命名（下文 #refer("definition/normal-forms-and-stuck-terms") 的“受阻”），然后用类型系统证明良类型的程序永远到不了这种状态。本文采用这种做法。
+ *显式加上错误规则*。扩充语法，增加终止计算的错误项 $"wrong"$，再把原来受阻的运算规定为“产生错误”，并规定错误如何向外传播。Python 对 `1 + "a"` 抛出 `TypeError` 是类似的运行时处理；Kotlin 的例子以及它与底类型的关系见 #refer("note/explicit-errors-and-kotlin-bottom-type")。
+ *补上一个约定的结果*。例如规定布尔值先转成数，$"true"$ 对应 $1$、$"false"$ 对应 $0$，于是 $"succ" "true" stp "succ" ("succ" 0)$。JavaScript 的 `true + 1 === 2` 就是这种做法。它给这类运算规定了普通结果，但不代表所有程序都会正常返回；隐式转换也可能掩盖本想发现的错误，见 #refer("example/javascript-coercion-and-equality-triangle")。

#statement("note/explicit-errors-and-kotlin-bottom-type")

#statement("example/javascript-coercion-and-equality-triangle")

#statement("note/equality-and-language-design")

无论选哪种，关键是*写下来*。C 语言标准里的“未定义行为”（undefined behavior）是典型的反面教材：标准明确说某些情形没有定义，却没有要求实现报错，于是编译器可以假设它们永远不会发生，并据此做出让程序员意外的优化。

#statement("example/reduction-derivation")

= 计算规则与同余规则

来讲讲上面那十条规则，它们分成两类，作用完全不同。

*计算规则*（computation rule）真正改写项：E-IfTrue、E-IfFalse、E-PredZero、E-PredSucc、E-IsZeroZero、E-IsZeroSucc。它们都没有关于 $stp$ 的前提，左边是一个具体的“可以计算”的形状，右边是算完的结果。例如：

- $"if" "true" "then" "succ" 0 "else" 0 stp "succ" 0$（E-IfTrue，取 $t_2 = "succ" 0$，$t_3 = 0$）；
- $"pred" ("succ" ("succ" 0)) stp "succ" 0$（E-PredSucc，取 $#nv = "succ" 0$）；
- $"iszero" ("succ" 0) stp "false"$（E-IsZeroSucc，取 $#nv = 0$）。

*同余规则*（congruence rule）不执行基本运算，而是负责*找位置*、把子项的归约带到整体：E-If、E-Succ、E-Pred、E-IsZero。它们的前提是“某个子项能归约”，结论是“整个项在那个位置归约”。“同余”这个名字的意思是：关系 $stp$ 和项的构造子（constructor）相容，子项归约了，包着它的项也跟着归约。（这和数论里的同余没有关系。）例如：

- 因为 $"pred" 0 stp 0$（E-PredZero），所以 $"succ" ("pred" 0) stp "succ" 0$（E-Succ）；
- 因为 $"iszero" 0 stp "true"$（E-IsZeroZero），所以 $"if" ("iszero" 0) "then" 0 "else" "succ" 0 stp "if" "true" "then" 0 "else" "succ" 0$（E-If）。

每一步归约的推导都是同样的结构：底下若干次同余规则，一路往里找到要算的地方，最顶上恰好一次计算规则，在那里真正改写。#refer("example/reduction-derivation") 就是两次同余（E-Pred、E-If）加一次计算（E-IsZeroZero）。

#fig({
  import "@preview/fletcher:0.5.8" as fletcher: diagram, edge, node
  let nd(pos, body, tint) = node(
    pos,
    body,
    fill: tint.lighten(82%),
    stroke: 0.8pt + tint.darken(10%),
    corner-radius: 4pt,
    inset: 5pt,
  )
  diagram(
    spacing: (14mm, 7mm),
    edge-stroke: 0.8pt,
    nd((0, 0), $"pred"$, blue),
    nd((0, 1), $"if"$, blue),
    nd((-1, 2), $"iszero" 0$, orange),
    nd((0, 2), $"succ" 0$, gray),
    nd((1, 2), $0$, gray),
    edge((0, 0), (0, 1), "-|>", label: text(size: 8pt)[E-Pred], label-side: left),
    edge((0, 1), (-1, 2), "-|>", label: text(size: 8pt)[E-If], label-side: right),
    edge((0, 1), (0, 2), "-", stroke: (dash: "dashed")),
    edge((0, 1), (1, 2), "-", stroke: (dash: "dashed")),
    node((-1, 3), text(size: 8pt)[E-IsZeroZero：改写成 $"true"$]),
  )
})

上图中`pred`和`if`节点是同余规则经过的路径，`iszero 0`节点是计算规则改写的位置，虚线连着的分支不参与这一步。

规则的细节里藏着设计决定，读的时候要留意：

- E-If 只允许在*条件*里归约，没有规则允许在分支里归约。所以先求条件，再选择一个分支，不会提前计算未选中的分支。下文 #refer("note/evaluation-strategies-reduction-strategies-and-confluence") 会把这样的顺序规定称为求值策略，并与一般的归约策略区分。
- 计算规则要求正在检查的操作数*已经是合适的值*，但不要求未选中的分支是值。例如 E-PredSucc 的左边是 $"pred" ("succ" #nv)$，只有 $"succ"$ 里面已经是数值时才能用；否则就只能先用同余规则把里面算完。这保证了“先算里面，再算外面”的顺序，下面的 #refer("note/numeric-value-restriction-in-predecessor-reduction") 会说明为什么这一点很重要。

#statement("remark/meaning-as-use")

#html.nav(class: "chapter-nav", aria-label: "文章导航")[
  #cite("/how/plt/formal/syntax.typ")[← 语法：BNF、最小集合与结构归纳]
  #cite("/how/plt/formal/index.typ")[回到形式化入门]
  #cite("/how/plt/formal/determinism.typ")[确定性：从推导归纳到求值器 →]
]
