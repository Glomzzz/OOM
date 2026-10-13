#import "/lib/formal.typ": *

#show: formal-page.with(
  title: [求值：用推导规则定义运行],
  description: [定义算术语言的值与一步规约关系，区分基本规约规则与结构规则．],
)

上一节定义词项的*语法*：它由哪些构造子、按什么结构组成．
这一节定义词项的*语义*，也就是在给定模型中的意义．
*程序语言语义学*研究怎样赋予程序精确的数学意义．

本文采用*操作语义*：通过执行状态及其执行关系描述程序行为．
具体采用的是*小步操作语义*，每次转移描述一步执行．
在这门语言中，执行状态就是词项，不需要另加存储或环境．
#refer("example/incomplete-specifications") 里“先算哪边”的问题，将由转移规则规定；
规则是否保证下一步唯一，还须另行证明．

#statement("remark/being-and-becoming")

= 值

先划出“已经算完”的项．

#statement("definition/values-and-numeric-values")

数值就是 $0$、$"succ" 0$、$"succ" ("succ" 0)$……，分别代表 $0, 1, 2, dots$．
几个例子：

- $"true"$、$0$、$"succ" ("succ" 0)$ 是值；
- $"succ" "true"$ 是项，但不是值：$"succ"$ 后面必须是数值，而 $"true"$ 不是；
- $"pred" 0$ 也不是值，值的定义里根本没有 $"pred"$．直观上，它还能再算．

= 推导规则怎么读

*规约*是依据规则把词项改写为另一词项，
例如把 $(1 + 2) times 3$ 改写为 $3 times 3$，再改写为 $9$．
一次改写称为*一步规约*，连续零次或有限多次改写称为*多步规约*．
规约不天然保证词项更小或更接近终点；本文的终止性要由大小严格下降另行证明．

在本模型中，$stp$ 同时是词项之间的*转移关系*：
$t stp t'$ 描述从状态 $t$ 到状态 $t'$ 的一次*转移*．
程序执行就是依次作这样的转移．

#statement("convention/reading-the-reduction-arrow")

数学上，$stp$ 是*二元关系*：
它是由若干 $(t, t')$ 对组成的集合，$t stp t'$ 是 $(t, t') in #h(0.2em) stp$ 的简写．
我们用*推导规则*定义它．一条规则形如

$ frac("前提"_1 quad dots.c quad "前提"_n, "结论") $

读作：如果横线上的*前提*全都成立，那么横线下的*结论*成立．
没有前提的规则称为*公理*；它是推导规则的特例，不需要先证明其他判断就能使用．

横线右边可以标上规则的名字，方便引用．

#statement("convention/metavariables")

元变量的取值范围也是规则的一部分．
例如 $#nv$ 只能表示数值，不能用任意词项代换．
文献还常把额外限制显式写成*附加条件*，放在横线旁或前提中；
它们必须满足，才能应用规则，不能靠读者自行补全．

#statement("definition/one-step-reduction")

这里的“最小”和 #refer("definition/set-of-terms") 里的“最小”含义相同：
$t stp t'$ 成立，*当且仅当*能用这十条规则的实例搭出一棵以它为根的有限树．
这棵树称为*推导树*，也称*推导*．
推导规则是通用的规则模式，
推导则是把规则实例组合起来、证明具体判断的有限结构．

规则没有提到的情形，例如 $"succ" "true"$ 该规约到哪里，就是没有定义．
“没有定义”在这里有精确的含义：
十条规则里没有一条的结论能匹配 $"succ" "true" stp dots$
（E-Succ 的结论形状对得上，但它的前提要求 $"true"$ 能规约，而没有规则能做到），
所以不存在任何 $t'$ 使 $"succ" "true" stp t'$．

遇到没有定义的情形该怎么办？
形式化的回答是：*不要假装它有定义*，而是把它当作明确的状态来对待．
常见做法有三种：

+ *承认它是错误状态*．
  把“不是值、却又不能规约”的项单独命名
  （下文 #refer("definition/normal-forms-and-stuck-terms") 的“受阻”），
  再用类型系统证明良类型的程序永远到不了这种状态．本文采用这种做法．
+ *显式加上错误规则*．
  扩充语法，增加终止计算的错误项 $"wrong"$，
  再把原来受阻的运算规定为“产生错误”，并规定错误如何向外传播．
  Python 对 `1 + "a"` 抛出 `TypeError` 是类似的运行时处理；
  Kotlin 的例子以及它与底类型的关系见
  #refer("note/explicit-errors-and-kotlin-bottom-type")．
+ *补上约定的结果*．
  例如规定布尔值先转成数，$"true"$ 对应 $1$、$"false"$ 对应 $0$，
  于是 $"succ" "true" stp "succ" ("succ" 0)$．
  JavaScript 的 `true + 1 === 2` 就是这种做法．
  它给这类运算规定了普通结果，但不代表所有程序都会正常返回；
  隐式转换也可能掩盖本想发现的错误，
  见 #refer("example/javascript-coercion-and-equality-triangle")．

#statement("note/explicit-errors-and-kotlin-bottom-type")

#statement("example/javascript-coercion-and-equality-triangle")

#statement("note/equality-and-language-design")

无论选哪种，关键是*写下来*．
C 语言标准里的*未定义行为*是典型的反面教材：
标准明确说某些情形没有定义，却没有要求实现报错，
于是编译器可以假设它们永远不会发生，并据此做出让程序员意外的优化．

#statement("example/reduction-derivation")

= 规约规则与结构规则

这十条规则分成两类：一类规定基本运算怎样执行，另一类规定基本步骤可发生在哪些位置．

*规约规则*（也称*计算规则*或*收缩规则*）直接规定基本运算的结果：
E-IfTrue、E-IfFalse、E-PredZero、E-PredSucc、E-IsZeroZero、E-IsZeroSucc．
能直接匹配这类规则的词项，称为*可规约表达式*，简称*可规约项*．
这里的六条基本规约规则没有关于 $stp$ 的前提；
这个特征不是所有语言的规约规则都必须满足的．例如：

- $"if" "true" "then" "succ" 0 "else" 0 stp "succ" 0$
  （E-IfTrue，取 $t_2 = "succ" 0$，$t_3 = 0$）；
- $"pred" ("succ" ("succ" 0)) stp "succ" 0$
  （E-PredSucc，取 $#nv = "succ" 0$）；
- $"iszero" ("succ" 0) stp "false"$
  （E-IsZeroSucc，取 $#nv = 0$）．

*结构规则*（也称*同余规则*）把子项的规约提升到*指定的求值位置*：
E-If 允许规约条件，E-Succ、E-Pred、E-IsZero 允许规约各自的参数．#footnote[
  在证明论与相继式演算中，“结构性规则”与“收缩规则”另指弱化、收缩、交换等操作语境的规则，
  与此处操作语义的同余规则和基本规约规则不是同一概念．
]
前提说那个位置的子项能规约，结论说整体能在该位置转移一步．
这不允许改写任意子项，例如不能直接在尚未选中的 $"if"$ 分支里计算．例如：

- 因为 $"pred" 0 stp 0$（E-PredZero），
  所以 $"succ" ("pred" 0) stp "succ" 0$（E-Succ）；
- 因为 $"iszero" 0 stp "true"$（E-IsZeroZero），所以
  $"if" ("iszero" 0) "then" 0 "else" "succ" 0 stp "if" "true" "then" 0 "else" "succ" 0$（E-If）．

这里的“同余”强调规约与特定构造相容，不表示一步规约是同余等价关系：
$stp$ 有方向，而且只对规则许可的位置封闭．
把许可位置另写成带一个空位的*求值语境*，再规定怎样在空位处执行基本规约，
就得到*语境语义*（也称*规约语义*）的写法．
参见 Hutton 译文第 6 节，以及
#link("https://home.ttic.edu/~dreyer/course/papers/harper-tspl.pdf")[Harper §1.3.1]．

这套小步语义中，每棵一步推导都由零次或多次结构规则与顶端的一次基本规约规则组成．
从结论向上读，结构规则定位正在求值的子项，基本规约规则执行其中的运算．
#refer("example/reduction-derivation") 就是两次结构规则（E-Pred、E-If）
加一次基本规约（E-IsZeroZero）．

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
    edge(
      (0, 0),
      (0, 1),
      "-|>",
      label: text(size: 8pt)[E-Pred],
      label-side: left,
    ),
    edge(
      (0, 1),
      (-1, 2),
      "-|>",
      label: text(size: 8pt)[E-If],
      label-side: right,
    ),
    edge((0, 1), (0, 2), "-", stroke: (dash: "dashed")),
    edge((0, 1), (1, 2), "-", stroke: (dash: "dashed")),
    node((-1, 3), text(size: 8pt)[E-IsZeroZero：改写成 $"true"$]),
  )
})

上图中 `pred` 和 `if` 节点是结构规则经过的路径，`iszero 0` 是基本规约发生的位置；
虚线连接的分支不参与这一步．

规则的细节里藏着设计决定，读的时候要留意：

- E-If 只允许在*条件*里规约，没有规则允许在分支里规约．
  因此先求条件，再选择分支，不会提前计算未选中的分支．
  下文 #refer("note/evaluation-strategies-reduction-strategies-and-confluence")
  会把这样的顺序规定称为求值策略，并与一般的规约策略区分．
- 基本规约规则要求正在检查的操作数*已经是合适的值*，但不要求未选中的分支是值．
  例如 E-PredSucc 的左边是 $"pred" ("succ" #nv)$，
  只有 $"succ"$ 里面已经是数值时才能用；否则只能先用结构规则把里面算完．
  这保证了“先算里面，再算外面”的顺序，
  下面的 #refer("note/numeric-value-restriction-in-predecessor-reduction")
  会说明为什么这一点很重要．

#statement("remark/meaning-as-use")

#html.nav(class: "chapter-nav", aria-label: "文章导航")[
  #cite("/how/plt/formal/syntax.typ")[← 语法：BNF、最小集合与结构归纳]
  #cite("/how/plt/formal/index.typ")[回到形式化入门]
  #cite("/how/plt/formal/determinism.typ")[确定性：从规则归纳到求值器 →]
]
