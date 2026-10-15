#import "/lib/formal.typ": *

#show: formal-page.with(
  title: [语法：BNF、最小集合与结构归纳],
  description: [用 BNF 与最小封闭集合定义算术语言的词项，并由最小性导出结构归纳原理．],
)

= 语法树

#statement("convention/abstract-syntax")

这条约定是第一个“隐含前提”：本文所有的定理都是关于树的．
至于怎样把字符串可靠地变成树，那是另一个话题．
这种只关心树形结构、不关心字符怎么排的语法，叫*抽象语法*．

= BNF

*文法*用产生规则描述允许的语法构造；*语法*则是关于程序结构的更一般的概念．
本文用文法直接描述抽象语法树，省略字符层面的解析．

常用的文法记号是 *BNF*，即 *Backus–Naur 表示法*
（参见#wiki("巴科斯范式")[维基百科]）．
它得名于 John Backus 与 Peter Naur，与 ALGOL 60 的语法描述密切相关．
英文名里的 Form 指一种表示形式，注意与后文规约理论中的“正规形式”区分．

BNF 用*产生式*描述各个语法类别，形如

$ "名字" ::= "选项"_1 | "选项"_2 | dots.c $

其中 $::=$ 读作“定义为”或“可以是”，$|$ 读作“或者”，用来隔开几种选项．
右侧的符号分为*终结符号*与*非终结符号*：
终结符号是直接给出的符号（如关键字 $"if"$、$"succ"$），
非终结符号表示还可由产生式展开的语法类别．

名字出现在自己的右边，就形成了递归．例如

$ n ::= 0 | "succ" n $

说的是：$n$ 可以是 $0$，也可以是 $"succ"$ 后面跟着另一个 $n$．
于是 $0$、$"succ" 0$、$"succ" ("succ" 0)$ 都是 $n$．
BNF 本身只是一种记号，它的准确含义要靠下面的“最小集合”来说清楚．

= 词项

对象语言中的程序称为*词项*（简称“项”），用元变量 $t$ 表示．
这门语言只有表达式，没有单独的语句类别；词项的抽象语法用两行 BNF 给出：

$
  t ::= & "true" | "false" | "if" t "then" t "else" t \
        & | quad 0 quad | "succ" t | "pred" t | "iszero" t
$

竖线读作“或者”．
$"succ" t$ 是 $t$ 的后继，可以理解为加一；
$"pred" t$ 是前驱，可以理解为减一；
$"iszero" t$ 判断 $t$ 是否为零．
例如 $"if" ("iszero" ("pred" ("succ" 0))) "then" 0 "else" "succ" 0$ 是词项，
它对应的语法树见下图：

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

图中的 $"if"$ 是根，有三个孩子；
$"iszero"$、$"pred"$、$"succ"$ 是只有一个孩子的内部节点；
三个标着 $0$ 的节点是不同位置上的叶子．

#statement("definition/immediate-and-proper-subterms")

这段 BNF 描述了词项的构造方式，严格的集合含义由归纳定义给出．

#statement("definition/set-of-terms")

记号 $cal(T)$ 是花体字母 T，可读作 `script T`；
它表示词项集合，与后文表示类型的元变量 $T$ 不同．

“封闭”说的是：集合里有了 $t_1$，就必须也有 $"succ" t_1$ 等等，
用这几条规则造不出集合外的东西．

只要求“封闭”还不够，因为满足封闭条件的集合有很多．
例如允许额外的叶子 `null`，
并且把所有包含这个新叶子的 $"succ"$、$"if"$ 等树也一起加进来，
得到的更大集合仍然满足封闭条件．
但三条生成条件并未给出 `null`，它不属于本文的项
（若只加 `null`，漏掉 $"succ" "null"$ 等树，则会直接破坏封闭性）．

取最小集合，就是说：
词项*只有*用上面三条规则在有限步内构造出来的对象，没有其他元素．
这一限制称为*最小性子句*；它排除了规则没有生成的额外对象．

#statement("note/existence-of-the-least-set")

由此可以看出两件事：
每个项都是一棵*有限*的树，叶子是 $"true"$、$"false"$、$0$，
内部节点是 $"succ"$、$"pred"$、$"iszero"$（各有一个孩子）
或 $"if"$（有三个孩子）；
同时，语法只规定形状，不保证项满足类型规则．
$"succ" "true"$ 和 $"if" 0 "then" 0 "else" "true"$ 都是合法的项；
它们是否良类型，要由后面的类型规则判断．
操作语义则单独规定项能怎样规约，
不良类型的项也在它的讨论范围内，甚至可能正常求值．

在 Rust 里，这个集合可以表示为枚举．
`enum` 的值只能由这几个构造子有限次地组合出来，“最小”由语言本身保证：

```rust
// 对象语言的项（定义“词项的集合”）
#[derive(Clone, Debug, PartialEq, Eq, Hash)]
pub enum Term {
    True, False,
    If(Box<Term>, Box<Term>, Box<Term>),  // if t1 then t2 else t3
    Zero,
    Succ(Box<Term>), Pred(Box<Term>), IsZero(Box<Term>),
}
```

`Box<Term>` 是指向堆上 `Term` 的指针，并且*独占*它指向的那块内存．
Rust 需要在编译时确定每个类型占多少字节：
若直接写成 `Succ(Term)`，里面嵌套的 `Term` 又可能装一个 `Term`，大小就会变成无穷大，编译器会报错 `recursive type has infinite size`．
换成 `Box` 以后，`Succ` 里装的只是一个固定大小的指针，真正的子树放在堆上．

从树的角度看，`Box` 正好对应语法树里的一条*边*：
父节点通过它“拥有”自己的子树，子树不和别的节点共享．
也正因为独占，`Box` 不能按位复制；
复制一个项要用 `.clone()` 把整棵子树深拷贝一遍，后面的代码里会看到这一点．

= 结构归纳

最小性在排除额外元素的同时，还给出了*结构归纳法*．
要证明“*所有*词项都满足性质 $P$”，不必逐一检查无穷多个词项：
只需验证常量的*基准情况*，再验证各个构造子的*归纳情况*，
也就是证明当直接子项满足 $P$ 时，由它们构成的词项也满足 $P$．

#statement("note/meaning-of-induction")

先看“最小”怎样推出归纳．
设 $S$ 是所有满足 $P$ 的项组成的集合．
如果 $P$ 能“跟着规则搭上去”，意思就是 $S$ 也满足那三条封闭条件，
用这三条规则同样搭不出 $S$ 之外的对象．
而 $cal(T)$ 是这类集合里*最小*的，即每个这类集合的子集．
因此 $cal(T) subset S$，$cal(T)$ 的每个项都在 $S$ 里，都满足 $P$．

要是去掉“最小”，$cal(T)$ 里就可能混进 `null` 这样的例外：
三条规则搭不出它，对它也无话可说，$P$ 在它身上成不成立也就无从谈起．
“最小”保证了 $cal(T)$ 里*只有*规则搭出来的东西，
所以“对每条规则检查一遍”就等于“对每个项检查一遍”．
下面把这段论证写成定理．

#statement("theorem/structural-induction")

在元语言的集合论背景下，结构归纳直接由“最小”这两个字推出，无需作为对象语言的额外公理引入
（当然，元语言自身的数学基础仍有其公理，这里只是说定义了这个最小集合后不必再单独追加一条归纳公理）．

#statement("definition/induction-hypothesis")

#statement("example/induction-hypotheses-and-circular-reasoning")

#statement("note/scope-of-induction-hypotheses")

再看一棵具体语法树上的归纳方向．
要证 $P$ 对整棵树成立，只需在叶子处直接验证（第 1 条），
并在每个内部节点处假定以各个孩子为根的子项都满足 $P$，
再推出以当前节点为根的项满足 $P$（第 2、3 条）．
这里 $P$ 描述的是以该节点为根的整棵子项，与单个节点的标签区分开．
箭头表示“由孩子所在的子树推出父节点所在的子树”，信息自下而上流动：

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

先用两个函数练手，它们分别计算一棵语法树有多少个节点、有多深：

#statement("definition/size-and-depth")

按项的形状逐个情形写等式，之所以能定义出函数，是因为每个项恰好属于一种形状
（#refer("convention/abstract-syntax") 已经保证没有歧义），
而右边只用到直接子项的函数值，子项又更小，一路往下总会落到常量上．
这种定义方式称为*结构递归*，它和结构归纳相伴而生：
结构归纳沿着项的构造过程证明性质，结构递归则沿着同样的结构定义函数．
熟悉 Haskell 的读者会认出，
这正是许多基于*归纳类型*（也称*代数数据类型*）和*模式匹配*的递归函数所采用的方式．
Haskell 也允许非结构递归，但不能把它们一概称为共递归；
利用惰性求值逐步产生无限列表是共递归的常见例子，
还须检查它能否持续给出可观察部分（#refer("note/meaning-of-induction")）．

接下来这条引理检查“大小”和“深度”两个定义是否协调：
最长路径用到的节点不会超过整棵树的节点数．
它也给递归的资源估计一个上界，例如遍历语法树时，递归栈深度不超过节点总数．
没有这个证明，这只是直觉；
如果误把 $"if"$ 的深度写成三个分支深度之和加一，就不再是在数最长路径了．
例如三个分支各有深度 $1$ 时，这种错误写法给出 $4$，但实际最长路径只有 $2$ 条边．
要证明递归终止，还需另查每次调用的参数是否严格变小，不能只引用一个数值上界．

#statement("lemma/depth-is-less-than-size")

这就是结构归纳证明的基本思路：虽然项有无穷多个，但构造它们的规则只有有限几条。我们只需按这些规则逐一讨论：基础情形直接验证，递归情形则借助对子项的#ih，一步步推出结论．

#statement("remark/potential-and-actual-infinity")

= 练习：语法

#exercise-group(5)[
  #exercise(
    "2.1",
    [把项还原成树],
    hint: [
      根是 $"if"$；三个直接子项要按条件、$"then"$ 分支、$"else"$ 分支的顺序列出．
      大小数节点，深度数最长路径上的边．
    ],
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

      三个直接子项依次是 $"iszero" ("pred" 0)$、$"succ" ("succ" 0)$、
      $"pred" ("succ" 0)$，大小都为 $3$，深度都为 $2$．
      所以整项大小为 $1 + 3 + 3 + 3 = 10$，深度为 $1 + max(2, 2, 2) = 3$．

      三个标着 $0$ 的节点都没有孩子，都是叶子；
      根 $"if"$ 和其余六个一元节点都是内部节点．
      $0$ 属于整项的真子项，但隔着中间节点，不算整项的直接子项．
      不能因为三个叶子的标签相同，就把它们合并成同一个位置．
    ],
  )[
    画出 $"if" ("iszero" ("pred" 0)) "then" ("succ" ("succ" 0)) "else" ("pred" ("succ" 0))$ 的树，
    标出根、叶子与内部节点，列出直接子项，计算大小和深度，
    并判断 $0$ 是否属于整项的直接子项．
    依据 #refer("definition/tree-terminology")、
    #refer("definition/immediate-and-proper-subterms")
    与 #refer("definition/size-and-depth") 作答．
  ]

  #exercise(
    "2.2",
    [语法合法，不等于满足类型规则],
    hint: [
      这里仅使用 #refer("definition/set-of-terms") 的生成条件，
      不提前使用后面的求值或类型规则．
    ],
    answer: [
      $"succ" "false"$ 是项：先由第一条生成 $"false"$，再由第二条包上 $"succ"$．
      $"if" 0 "then" "true" "else" 0$ 也是项：
      三个常量都由第一条生成，再用第三条组合．

      单独的 `pred` 缺少子项，不构成词项．
      字面记号 `1` 也不在这套抽象语法里；
      后面会用 $"succ" 0$ 表示自然数一，但不能未经约定就把 `1` 当成已有的构造．
      前两个项都满足语法的生成条件；
      这既不保证它们有类型，也不保证求值能到达值．
      是否有类型、怎样规约，要分别对照后面各自的规则，
      不能混成一个“有没有意义”的判断．
    ],
  )[
    判断下面四种写法是否描述本文的项；
    构成项的写出构造过程，不构成项的说明生成条件缺了什么：
    $"succ" "false"$、$"if" 0 "then" "true" "else" 0$、单独的 `pred`、字面记号 `1`．
    不要用“它运行时会出错”作为不属于项集合的理由．
  ]

  #exercise(
    "2.3",
    [封闭与最小的分工],
    hint: [考虑集合里一旦有 `null`，封闭条件对 $"succ"$ 所提出的要求．],
    answer: [
      $S = cal(T) union {"null"}$ 不封闭：$"null" in S$，但 $"succ" "null" in.not S$；
      $"succ" "null"$ 既不在原语言的项集合 $cal(T)$ 中，也不等于新添的叶子 `null`．

      要得到含 `null` 的封闭集合，
      必须同时加入所有由原构造子和这个额外叶子在有限步内搭出的树，
      包括 $"succ" "null"$、$"if" "null" "then" 0 "else" "true"$ 等．
      这个集合满足原来的封闭条件，却严格大于 $cal(T)$．
      “封闭”要求构造后不能跑到集合外，“最小”则排除规则没有生成的额外东西．
    ],
  )[
    设 $S = cal(T) union {"null"}$，只比原项集合多一个新叶子．
    判断 $S$ 是否满足原来的三条封闭条件；
    若不满足，说明怎样扩充才封闭，
    并指出扩充后的集合与 #refer("definition/set-of-terms") 定义的集合差在哪个条件上．
  ]

  #exercise(
    "2.4",
    [证明边数比节点数少一],
    hint: [
      常量有零条边；一元构造增加一条边；
      $"if"$ 根连向三个孩子，增加三条边．
    ],
    answer: [
      完整的结构递归定义为：
      $
        E("true") = E("false") = E(0) = 0 \
        E("succ" t_1) = E("pred" t_1) = E("iszero" t_1) = E(t_1) + 1 \
        E("if" t_1 "then" t_2 "else" t_3) = E(t_1) + E(t_2) + E(t_3) + 3
      $

      对 $t$ 结构归纳．常量有 $E(t) = 0 = 1 - 1$．
      一元情形由子项上的 #ih 得
      $
        E("succ" t_1) = E(t_1) + 1 = op("size")(t_1) = op("size")("succ" t_1) - 1
      $
      $"pred"$、$"iszero"$ 的等式相同．

      对 $"if" t_1 "then" t_2 "else" t_3$，
      三个子项上的 #ih 分别是 $E(t_i) = op("size")(t_i) - 1$．
      三棵子树的边加上根的三条边，得到
      $
        E(t) & = E(t_1) + E(t_2) + E(t_3) + 3 \
             & = (op("size")(t_1) - 1) + (op("size")(t_2) - 1) + (op("size")(t_3) - 1) + 3 \
             & = op("size")(t_1) + op("size")(t_2) + op("size")(t_3) \
             & = op("size")(t) - 1
      $
      全部构造情形都覆盖了，因此结论对所有项成立．∎
    ],
  )[
    令 $E(t)$ 表示项 $t$ 的语法树中的边数．
    写出 $E$ 的完整结构递归定义，
    并用 #refer("theorem/structural-induction") 证明 $E(t) = op("size")(t) - 1$．
    每个归纳步骤都要写清 #ih 用在哪个子项上．
  ]

  #exercise(
    "2.5",
    [两种不同的错误“归纳证明”],
    hint: [
      先核对第一段使用的假设对象，
      再检查第二段的不等式能否从子项传给父项．
    ],
    answer: [
      第一段是循环论证：它直接把当前待证的 $P("succ" t_1)$ 当作假设，
      没有使用结构归纳许可的子项性质 $P(t_1)$，只相当于说了“结论蕴涵自身”．

      第二段使用子项上的假设本身合法，但推理错误：
      $op("size")(t_1) <= 3$ 只能给出 $op("size")("succ" t_1) <= 4$，不能给出 $<= 3$．
      取 $t_1 = "succ" ("succ" 0)$，子项大小为 $3$，包上一层后为 $4$．
      可见 $P$ 本身就是假命题，光修改措辞也无法把它证出来．
      $"if" "true" "then" 0 "else" 0$ 也是大小为 $4$ 的反例．
    ],
  )[
    令 $P(t)$ 为“$op("size")(t) <= 3$”．
    有人分别写出两段归纳步骤：
    “假定 $P("succ" t_1)$，所以 $P("succ" t_1)$”；
    “假定 $P(t_1)$，大小加一仍不超过 $3$，所以 $P("succ" t_1)$”．
    指出两段论证各自的错误，给出具体反例，并区分“假设用错对象”与“由归纳假设推不出结论”．
  ]
]

#html.nav(class: "chapter-nav", aria-label: "文章导航")[
  #cite("/how/plt/formal/natural-and-formal.typ")[← 自然语言与元语言]
  #cite("/how/plt/formal/index.typ")[回到形式化入门]
  #cite("/how/plt/formal/evaluation.typ")[求值：用推导规则定义运行 →]
]
