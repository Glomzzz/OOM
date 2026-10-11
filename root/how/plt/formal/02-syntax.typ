#import "/lib/formal.typ": *

#show: formal-page.with(title: [语法：BNF、最小集合与结构归纳])

= 语法树

#statement("convention/abstract-syntax")

这条约定是第一个“隐含前提”：本文所有的定理都是关于树的。至于怎样把字符串可靠地变成树，那是另一个话题。这种只关心树形结构、不关心字符怎么排的语法，叫*抽象语法*（abstract syntax）。

= BNF

描述语法树长什么样，最常用的写法是 *BNF*，全称巴科斯–诺尔范式（Backus–Naur Form，参见#wiki("巴科斯范式")[维基百科]）。它得名于#wiki("约翰·巴科斯")[巴科斯（John Backus）]和#wiki("彼得·诺尔")[诺尔（Peter Naur）]：1960 年的 ALGOL 60 报告第一次用这种写法给一门程序语言写出了完整的语法，此后几乎所有语言的规格都沿用了它的某种变体。

BNF 的一行叫一条*产生式*（production），形如

$ "名字" ::= "选项"_1 | "选项"_2 | dots.c $

- $::=$ 读作“定义为”或“可以是”；
- $|$ 读作“或者”，把几种选项隔开；
- 每个选项是一串符号，其中有些是写死的*关键字*（如 $"if"$、$"succ"$），有些是*名字*本身，表示“这里放一个同类的东西”。

名字出现在自己的右边，就形成了递归。例如

$ n ::= 0 | "succ" n $

说的是：$n$ 可以是 $0$，也可以是 $"succ"$ 后面跟着另一个 $n$。于是 $0$、$"succ" 0$、$"succ" ("succ" 0)$ 都是 $n$。BNF 本身只是一种记号，它的准确含义要靠下面的“最小集合”来说清楚。

= 项

对象语言的程序称为*项*（term），用字母 $t$ 表示。项的写法用一行 BNF 给出：

$
  t ::= & "true" | "false" | "if" t "then" t "else" t \
        & | quad 0 quad | "succ" t | "pred" t | "iszero" t
$

竖线读作“或者”。$"succ" t$ 是“$t$ 的后继”（successor），可以理解为加一；$"pred" t$ 是“前驱”（predecessor），可以理解为减一；$"iszero" t$ 问 $t$ 是不是零。例如 $"if" ("iszero" ("pred" ("succ" 0))) "then" 0 "else" "succ" 0$ 是一个项，它对应的语法树如下：

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
    spacing: (10mm, 8mm),
    edge-stroke: 0.8pt,
    nd((1, 0), $"if"$, orange),
    nd((0, 1), $"iszero"$, blue),
    nd((1, 1), $0$, gray),
    nd((2, 1), $"succ"$, blue),
    nd((0, 2), $"pred"$, blue),
    nd((2, 2), $0$, gray),
    nd((0, 3), $"succ"$, blue),
    nd((0, 4), $0$, gray),
    edge((1, 0), (0, 1), "-"),
    edge((1, 0), (1, 1), "-"),
    edge((1, 0), (2, 1), "-"),
    edge((0, 1), (0, 2), "-"),
    edge((2, 1), (2, 2), "-"),
    edge((0, 2), (0, 3), "-"),
    edge((0, 3), (0, 4), "-"),
  )
})

图中的 $"if"$ 是根，有三个孩子；$"iszero"$、$"pred"$、$"succ"$ 是只有一个孩子的内部节点；三个标着 $0$ 的节点是不同位置上的叶子。

#statement("definition/immediate-and-proper-subterms")

这一行 BNF 看起来是在描述“项长什么样”，但严格来说它是在*定义一个集合*。

#statement("definition/set-of-terms")

注：$cal(T)$ 这个符号是字母T的花体, 可以读作 `script T`。

“封闭”说的是：集合里有了 $t_1$，就必须也有 $"succ" t_1$ 等等，用这几条规则造不出集合外的东西。

为什么还要加“最小”？因为满足封闭条件的集合有很多。比如允许额外的叶子 `null`，并且把所有包含这个新叶子的 $"succ"$、$"if"$ 等树也一起加进来，得到的更大集合仍然满足封闭条件。但 `null` 不是本文的项，因为三条生成条件没有给出它。注意只加 `null` 而不加 $"succ" "null"$ 等树，反而会破坏封闭性。

取最小的那个，就是在说：项*只有*用上面三条规则、在有限步内搭出来的东西，别的一概不算。

#statement("note/existence-of-the-least-set")

由此可以得到两件事。第一，每个项都是一棵*有限*的树：叶子是 $"true"$、$"false"$、$0$，内部节点是 $"succ"$、$"pred"$、$"iszero"$（各有一个孩子）或 $"if"$（有三个孩子）。第二，项只管形状，不管有没有意义。$"succ" "true"$ 和 $"if" 0 "then" 0 "else" "true"$ 都是合法的项。它们“有没有意义”，要等后面的类型系统来判断。

Rust 里，这个集合就是一个枚举。`enum` 的值只能由这几个构造子有限次地组合出来，“最小”由语言本身保证：

```rust
// 对象语言的项（定义 “项的集合”）
#[derive(Clone, Debug, PartialEq, Eq, Hash)]
pub enum Term {
    True, False,
    If(Box<Term>, Box<Term>, Box<Term>),  // if t1 then t2 else t3
    Zero,
    Succ(Box<Term>), Pred(Box<Term>), IsZero(Box<Term>),
}
```

`Box<Term>` 是一个指向堆上 `Term` 的指针，并且*独占*它指向的那块内存。为什么不直接写 `Succ(Term)`？因为 Rust 要在编译时知道每个类型占多少字节。如果 `Succ` 里直接装一个 `Term`，那个 `Term` 里又可能装一个 `Term`……大小就成了无穷大，编译器会报错（“recursive type has infinite size”）。换成 `Box` 以后，`Succ` 里装的只是一个固定大小的指针，真正的子树放在堆上。

从树的角度看，`Box` 正好对应语法树里的一条*边*：父节点通过它“拥有”自己的子树，子树不和别的节点共享。也正因为独占，`Box` 不能按位复制，复制一个项要用 `.clone()` 把整棵子树深拷贝一遍，后面的代码里会看到这一点。

= 结构归纳

“最小”不只是为了排除例外，它还直接送给我们一条证明方法。我们常常想证明“*所有*项都有某个性质 $P$”。项有无穷多个，不能一个个检查；但项的集合是用三条规则“搭”出来的，所以只要性质能跟着这三条规则一起“搭”上去就行。

#statement("note/meaning-of-induction")

先让我们来想想“最小”为什么能推出归纳。

设 $S$ 是所有满足 $P$ 的项组成的集合。

如果 $P$ 能“跟着规则搭上去”，意思就是：$S$ 也满足那三条封闭条件，它也是一个“规则搭不出去”的集合。

而 $cal(T)$ 是这样的集合里*最小*的那个，即$cal(T)$是每一个这样的集合的子集。

所以$cal(T)$当然也是 $S$ 的子集，于是$cal(T)$的每个项都在 $S$ 里，都满足 $P$。

如果没有“最小”，$cal(T)$ 里可能混进`null`这样的例外，它不是任何上面那三条规则搭出来的，规则对这种例外什么也没说，$P$ 对它成不成立也就无从谈起。

所以“最小”保证了 $cal(T)$ 里*只有*规则搭出来的东西，所以“对每条规则检查一遍”就等于“对每个项检查一遍”。

下面把这段话写成定理。

#statement("theorem/structural-induction")

在这里，结构归纳不是额外请来的对象语言公理：在元语言的集合论背景下，它由“最小”这两个字推出。这里不是说一切数学基础都不需要公理，而是说定义了这个最小集合以后，不必再另加一条关于它的归纳公理。

#statement("definition/induction-hypothesis")

#statement("example/induction-hypotheses-and-circular-reasoning")

#statement("note/scope-of-induction-hypotheses")

下图是一个例子。要证 $P$ 对整棵树成立，只需要：叶子处直接验证（第 1 条），每个内部节点处假定以它的各个孩子为根的子项都满足 $P$，再推出以当前节点为根的项满足 $P$（第 2、3 条）。这里 $P$ 是项的性质，不是单个节点标签的性质。箭头表示“由孩子所在的子树推出父节点所在的子树”，信息自下而上流动：

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
    spacing: (12mm, 9mm),
    edge-stroke: 0.8pt,
    nd((1, 0), [$P("if" dots)$ \ #text(size: 8pt)[第 3 条]], orange),
    nd((0, 1), [$P("iszero" 0)$ \ #text(size: 8pt)[第 2 条]], blue),
    nd((1, 1), [$P(0)$ \ #text(size: 8pt)[第 1 条]], gray),
    nd((2, 1), [$P("succ" 0)$ \ #text(size: 8pt)[第 2 条]], blue),
    nd((0, 2), [$P(0)$ \ #text(size: 8pt)[第 1 条]], gray),
    nd((2, 2), [$P(0)$ \ #text(size: 8pt)[第 1 条]], gray),
    edge((0, 1), (1, 0), "-|>"),
    edge((1, 1), (1, 0), "-|>"),
    edge((2, 1), (1, 0), "-|>"),
    edge((0, 2), (0, 1), "-|>"),
    edge((2, 2), (2, 1), "-|>"),
  )
})

#statement("remark/history-of-least-sets-and-induction")

#statement("convention/writing-inductive-proofs")

先拿一个简单的性质练手。下面两个函数分别数一棵树有多少个节点、有多深：

#statement("definition/size-and-depth")

这里又有一个隐含前提：按项的形状逐个情形写等式，真的定义出了一个函数吗？答案是肯定的，因为每个项恰好属于一种形状（#refer("convention/abstract-syntax") 已经保证没有歧义），而右边只用到直接子项的函数值，子项又更小，一路往下总会落到常量上。这种定义方式称为*结构递归*（structural recursion），它和结构归纳是同一枚硬币的两面：结构归纳沿着项的构造过程证明性质，结构递归则沿着同样的结构定义函数。（熟悉 Haskell 的读者应该能认出，这正是许多基于代数数据类型（algebraic data type）和模式匹配（pattern matching）的递归函数所采用的方式；当然Haskell也允许非结构递归甚至利用惰性求值定义的无限结构，这属于共递归（corecursion）的典型形式，而不是通常意义上对有限归纳数据的结构递归。）

接下来这条引理检查“大小”和“深度”两个定义是否协调：最长路径用到的节点不会超过整棵树的节点数。它也给递归的资源估计一个上界，例如遍历语法树时，递归栈深度不超过节点总数。没有这个证明，这只是直觉；如果误把 $"if"$ 的深度写成三个分支深度之和加一，就不再是在数最长路径了。例如三个分支各有深度 $1$ 时，这种错误写法给出 $4$，但实际最长路径只有 $2$ 条边。要证明递归终止，还需另查每次调用的参数是否严格变小，不能只引用一个数值上界。

#statement("lemma/depth-is-less-than-size")

形式化证明大致就是这个样子：按定义的情形逐个过，每个情形里只用定义和 #ih。

#statement("remark/potential-and-actual-infinity")

= 练习：语法

#exercise-group(5)[
  #exercise(
    "2.1",
    [把项还原成树],
    hint: [根是 $"if"$；三个直接子项要按条件、then、else 的顺序列出。大小数节点，深度数最长路径上的边。],
    answer: [
      ```text
      if
      ├── iszero
      │   └── pred
      │       └── 0
      ├── succ
      │   └── succ
      │       └── 0
      └── pred
          └── succ
              └── 0
      ```

      三个直接子项依次是 $"iszero" ("pred" 0)$、$"succ" ("succ" 0)$、$"pred" ("succ" 0)$，大小都为 $3$，深度都为 $2$。所以整项大小为 $1 + 3 + 3 + 3 = 10$，深度为 $1 + max(2, 2, 2) = 3$。

      三个标着 $0$ 的节点都没有孩子，都是叶子；根 $"if"$ 和其余六个一元节点都是内部节点。$0$ 是整项的真子项，但不是直接子项。不能因为三个叶子的标签相同，就把它们合并成同一个位置。
    ],
  )[
    画出 $"if" ("iszero" ("pred" 0)) "then" ("succ" ("succ" 0)) "else" ("pred" ("succ" 0))$ 的树，标出根、叶子与内部节点，列出直接子项，计算大小和深度。$0$ 是否是整项的直接子项？依据 #refer("definition/tree-terminology")、#refer("definition/immediate-and-proper-subterms") 与 #refer("definition/size-and-depth") 作答。
  ]

  #exercise(
    "2.2",
    [语法合法，不等于有意义],
    hint: [这里仅使用 #refer("definition/set-of-terms") 的生成条件，不提前使用后面的求值或类型规则。],
    answer: [
      $"succ" "false"$ 是项：先由第一条生成 $"false"$，再由第二条包上 $"succ"$。$"if" 0 "then" "true" "else" 0$ 也是项：三个常量都由第一条生成，再用第三条组合。

      单独的 `pred` 不是项，因为这个构造必须带一个子项。字面记号 `1` 也不在这套抽象语法里；后面会用 $"succ" 0$ 表示自然数一，但不能未经约定就把 `1` 当成已有的构造。前两个项的语法合法，并不保证运算能正常进行。
    ],
  )[
    判断下面四种写法是否描述本文的项；是项的写出构造过程，不是项的说明生成条件缺了什么：$"succ" "false"$、$"if" 0 "then" "true" "else" 0$、单独的 `pred`、字面记号 `1`。不要用“它运行时会出错”作为不属于项集合的理由。
  ]

  #exercise(
    "2.3",
    [封闭与最小各负责什么？],
    hint: [集合里一旦有 `null`，封闭条件对 $"succ"$ 会提出什么要求？],
    answer: [
      $S = cal(T) union {"null"}$ 不封闭：$"null" in S$，但 $"succ" "null" in.not S$。它既不是原语言的项，也不是单独补进去的 `null`。

      要得到含 `null` 的封闭集合，必须同时加入所有由原构造子和这个额外叶子在有限步内搭出的树，包括 $"succ" "null"$、$"if" "null" "then" 0 "else" "true"$ 等。这个集合满足原来的封闭条件，却严格大于 $cal(T)$。“封闭”要求构造后不能跑到集合外，“最小”则排除规则没有生成的额外东西。
    ],
  )[
    设 $S = cal(T) union {"null"}$，只比原项集合多一个新叶子。$S$ 是否满足原来的三条封闭条件？若不满足，应当怎样扩充才封闭？扩充后的集合为什么仍不是 #refer("definition/set-of-terms") 定义的集合？
  ]

  #exercise(
    "2.4",
    [证明边数比节点数少一],
    hint: [常量有零条边；一元构造增加一条边；$"if"$ 根连向三个孩子，增加三条边。],
    answer: [
      完整的结构递归定义为：
      $
        E("true") = E("false") = E(0) = 0 \
        E("succ" t_1) = E("pred" t_1) = E("iszero" t_1) = E(t_1) + 1 \
        E("if" t_1 "then" t_2 "else" t_3) = E(t_1) + E(t_2) + E(t_3) + 3
      $

      对 $t$ 结构归纳。常量有 $E(t) = 0 = 1 - 1$。一元情形由子项上的 #ih 得
      $ E("succ" t_1) = E(t_1) + 1 = op("size")(t_1) = op("size")("succ" t_1) - 1 $，$"pred"$、$"iszero"$ 的等式相同。

      对 $"if" t_1 "then" t_2 "else" t_3$，三个子项上的 #ih 分别是 $E(t_i) = op("size")(t_i) - 1$。三棵子树的边加上根的三条边，得到
      $ E(t) & = E(t_1) + E(t_2) + E(t_3) + 3 \
           & = (op("size")(t_1) - 1) + (op("size")(t_2) - 1) + (op("size")(t_3) - 1) + 3 \
           & = op("size")(t_1) + op("size")(t_2) + op("size")(t_3) \
           & = op("size")(t) - 1 $。
      全部构造情形都覆盖了，因此结论对所有项成立。∎
    ],
  )[
    令 $E(t)$ 表示项 $t$ 的语法树中的边数。写出 $E$ 的完整结构递归定义，并用 #refer("theorem/structural-induction") 证明 $E(t) = op("size")(t) - 1$。每个归纳步骤都要写清 #ih 用在哪个子项上。
  ]

  #exercise(
    "2.5",
    [两种不同的错误“归纳证明”],
    hint: [第一段用了哪个对象上的假设？第二段虽然取了子项，还要检查不等式是否真的能传给父项。],
    answer: [
      第一段是循环论证：它假定的是当前待证的 $P("succ" t_1)$，不是结构归纳许可的 $P(t_1)$。它只证明“结论蕴涵自身”。

      第二段使用子项上的假设本身合法，但推理错误：$op("size")(t_1) <= 3$ 只能给出 $op("size")("succ" t_1) <= 4$，不能给出 $<= 3$。取 $t_1 = "succ" ("succ" 0)$，子项大小为 $3$，包上一层后为 $4$。所以 $P$ 是假命题，不是把措辞修好就能证明的。$"if" "true" "then" 0 "else" 0$ 也是大小为 $4$ 的反例。
    ],
  )[
    令 $P(t)$ 为“$op("size")(t) <= 3$”。有人分别写出两段归纳步骤：“假定 $P("succ" t_1)$，所以 $P("succ" t_1)$”；“假定 $P(t_1)$，大小加一仍不超过 $3$，所以 $P("succ" t_1)$”。它们各错在哪里？给出具体反例，并说明为什么第二段不能简单称为“假设用错对象”。
  ]

]

#html.nav(class: "chapter-nav", aria-label: "文章导航")[
  #cite("/how/plt/formal/01-natural-and-formal.typ")[← 为什么形式化：自然语言与元语言]
  #cite("/how/plt/formal/index.typ")[回到形式化入门]
  #cite("/how/plt/formal/03-evaluation.typ")[求值：用推导规则定义运行 →]
]
