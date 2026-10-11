#import "/lib/formal.typ": *

#show: formal-page.with(title: [类型：语法导向、反演与唯一性])

= 类型判断

#statement("definition/types-and-typing-judgments")

#statement("definition/well-typed-terms")

这个定义有三处值得逐一拆开：

- *“存在某个 $T$”*：良类型只要求*有*一个类型，不要求事先指定是哪一个。$0$ 是良类型的，因为 $0 : tN$；它不是 $tB$ 并不影响这一点。
- *“有一棵推导”*：和 $stp$ 一样，$t : T$ 成立当且仅当能用 #refer("definition/types-and-typing-judgments") 中七条规则的实例搭出一棵以它为根的有限树。所以说一个项良类型，就是说*能写出*这样一棵树；说它不良类型，就是说*无论怎样搭都搭不出来*。后者是一个关于所有可能推导的否定命题，不能仅凭尝试构造某棵推导树失败就断言它不良类型。要证明它不良类型，我们需要说明任何合法的推导都不可能成立。在这里，可以通过分析类型规则以及它们所要求的前提来完成证明，下面的例子会演示。
- *良类型是一个静态性质*：在我们目前讨论的语言中，#refer("definition/types-and-typing-judgments") 中的类型判断只依赖项的结构与类型规则，不需要执行 #refer("definition/one-step-reduction") 中的 $stp$ 归约。换句话说，我们不必运行一个项，就能判断它是否良类型。这正是*静态类型检查*（static type checking）的基础（与动态检查的对照见 #refer("note/static-and-dynamic-typing")）。不过，类型判断与求值虽然是两套不同的规则，它们之间是否协调一致，还需要通过 #refer("corollary/type-safety") 的类型安全性定理来保证。

读法和 #refer("definition/one-step-reduction") 完全一样：横线上是前提，横线下是结论，$T$、$t_1$ 是元变量（#refer("convention/metavariables")）。所以“对类型推导归纳”也照样成立，证明与 #refer("theorem/induction-on-derivations") 相同，不再重复。

#statement("example/well-typed-and-ill-typed-terms")

#statement("note/answers-to-incomplete-specification-questions")

#statement("note/locating-errors-in-failed-typing-derivations")

#statement("note/conservative-type-systems")

= 反演：从结论倒推前提

先看这组规则的结论。每条规则的结论都形如“某个项 : 某个类型”，结论左边的项有一个最外层构造子（$"true"$、$"if"$、$"succ"$ 等），这就是它的*形状*。把七条规则按结论左边的形状列出来：

#html.div(style: "overflow-x: auto;", table(
  columns: 3,
  [*项的形状*], [*结论里出现这个形状的规则*], [*条数*],
  [$"true"$], [T-True], [1],
  [$"false"$], [T-False], [1],
  [$0$], [T-Zero], [1],
  [$"if" t_1 "then" t_2 "else" t_3$], [T-If], [1],
  [$"succ" t_1$], [T-Succ], [1],
  [$"pred" t_1$], [T-Pred], [1],
  [$"iszero" t_1$], [T-IsZero], [1],
))

“每种项的形状*恰好*出现在一条规则的结论里”指的就是这张表：第三列全是 $1$。既不是 $0$（否则那种形状的项永远没有类型），也不大于 $1$（否则同一个项可能有好几种定型方式）。这样的规则称为*语法导向*的（syntax-directed）：项的语法形状直接*指定*了该用哪条规则，不需要猜，也不需要回溯。

作为对照，下面两种情形都不是语法导向的：

- 如果再加一条规则 $frac(t : tN, t : tB)$（“自然数可以当布尔值用”），它的结论左边是任意项 $t$，不看形状。这时 $0 : tB$ 可以由它推出，$0$ 这一行就有了两条规则可选。
- 如果把 T-If 拆成两条，一条要求条件是 $"true"$，一条要求条件是 $"false"$，那么 $"if" ("iszero" 0) dots$ 这种条件不是常量的项就一条规则都没有，这一行变成 $0$。

语法导向带来一个很方便的推理方式：知道了 $t : T$ 成立，就能断定推导的最后一步用的是哪条规则，于是那条规则的前提也都成立。例如，知道 $"succ" t_1 : T$ 成立，查表可知最后一步必然是 T-Succ，于是立刻得到 $T = tN$ 且 $t_1 : tN$，不用知道推导的其余细节。#refer("example/well-typed-and-ill-typed-terms") 里的两个例子也是这样做的：每一步都只有一条规则可选。

#statement("lemma/typing-inversion")

反演看起来平淡无奇，却是后面所有证明的发动机。它把“存在一棵推导”这种不知道细节的事实，拆成关于子项的具体信息。保型证明例如从 $"pred" ("succ" #nv) : T$ 开始，必须先知道 $T = tN$、$"succ" #nv : tN$，再继续取出 $#nv : tN$，才能证明删去外层构造以后类型还在。没有反演，就不能凭外观擅自断言子项有哪些类型；增加子类型规则时这个推理尤其需要重证，下面的附注会给出原因。

#statement("note/inversion-and-syntax-directed-rules")

语法导向并不单凭“每种形状只有一条规则”就让输出类型自动唯一：T-If 的 $T$ 还要从分支中确定。下面的定理补上这个保证，说明 `type_of` 可以忠实地返回一个类型，而不必返回类型集合。没有唯一性，单个返回值可能只挑出了众多类型之一。例如带子类型的 Kotlin 中，一个 `Int` 表达式也可以出现在需要 `Number` 或 `Any` 的位置；那样的系统通常要另外区分推断出的类型和它能被接受为的所有类型，不能照搬本文的结论。

#statement("theorem/uniqueness-of-types")

= 练习：类型

#exercise-group(4)[
  #exercise(
    "4.1",
    [从结论搭起一棵类型推导],
    hint: [最外层用 T-If；条件从 T-IsZero 开始，两个分支都应得到 $tN$。],
    answer: [
      #bigmath(
        $
          #inf("T-If", inf("T-IsZero", inf("T-Pred", inf("T-Succ", inf("T-Zero", $0 : tN$), $"succ" 0 : tN$), $"pred" ("succ" 0) : tN$), $"iszero" ("pred" ("succ" 0)) : tB$), inf("T-Succ", inf("T-Zero", $0 : tN$), $"succ" 0 : tN$), inf("T-Pred", inf("T-Zero", $0 : tN$), $"pred" 0 : tN$), $"if" ("iszero" ("pred" ("succ" 0))) "then" "succ" 0 "else" "pred" 0 : tN$)
        $,
        scale: 100%,
      )

      每个叶子都是 T-Zero，两个分支具有同一个类型 $tN$。定型过程中没有执行任何 $stp$ 归约；条件最后会变成什么，不是搭这棵推导的前提。
    ],
  )[
    为 $"if" ("iszero" ("pred" ("succ" 0))) "then" "succ" 0 "else" "pred" 0$ 写出完整的类型推导树，并指出推导中有没有哪一步需要先运行这个项。使用 #refer("definition/types-and-typing-judgments")。
  ]

  #exercise(
    "4.2",
    [证明没有类型，而不是只说“检查失败”],
    hint: [先用 #refer("lemma/typing-inversion") 固定最后一条规则，再追到无法成立的前提。],
    answer: [
      - $"succ" ("if" "true" "then" 0 "else" "false")$ 若有类型，最后只能用 T-Succ，要求内部 $"if"$ 为 $tN$。T-If 随即要求 $"false" : tN$，与 T-False 的结论不符。
      - $"if" ("pred" 0) "then" 0 "else" 0$ 若有类型，T-If 要求条件为 $tB$，但 $"pred" 0$ 的类型只能是 $tN$。
      - $"iszero" ("iszero" 0)$ 若有类型，外层 T-IsZero 要求内层为 $tN$，但内层 T-IsZero 的结论只能是 $tB$。

      这三种分析排除了所有可能的最后规则，所以是不存在推导的论证。第一个项却可以归约到 $"succ" 0$：实际没有执行坏分支。这再次说明“不良类型”并不等于“这次运行必定出错”。
    ],
  )[
    证明以下三项对任何 $T$ 都不能得到 $t : T$：$"succ" ("if" "true" "then" 0 "else" "false")$、$"if" ("pred" 0) "then" 0 "else" 0$、$"iszero" ("iszero" 0)$。每项给出无法满足的具体前提；其中有没有一项实际能归约到值？
  ]

  #exercise(
    "4.3",
    [反演不需要看见整棵推导],
    hint: [先反演 T-If，再连续反演 T-Pred 和 T-Succ；整项的 $T$ 会被其中一个分支确定。],
    answer: [
      T-If 给出 $c : tB$、$"pred" ("succ" t_1) : T$、$u : T$。T-Pred 给出 $T = tN$ 以及 $"succ" t_1 : tN$；T-Succ 再给出 $t_1 : tN$。代回得到 $u : tN$。

      因而一定有 $T = tN$、$c : tB$、$t_1 : tN$、$u : tN$。这只提取已有推导必须满足的前提，并没有假定 $c$ 或 $t_1$ 已经求值，也不需要猜原推导的其他细节。
    ],
  )[
    设 $c$、$t_1$、$u$ 是任意项。只知道 $"if" c "then" ("pred" ("succ" t_1)) "else" u : T$，却没有拿到它的推导树。你仍能确定 $T$、$c$、$t_1$、$u$ 的哪些类型信息？逐次标明使用 #refer("lemma/typing-inversion") 的哪一条。
  ]

  #exercise(
    "4.4",
    [扩展：多一条转换规则会动到哪些结论？],
    hint: [保留七条旧规则，再添加“由 $t : tN$ 推出 $t : tB$”。首先检查 $0$。],
    answer: [
      T-Zero 给出 $0 : tN$，新规则再给出 $0 : tB$，所以 #refer("theorem/uniqueness-of-types") 不再成立。#refer("lemma/typing-inversion") 中“若 $0 : T$，则 $T = tN$”也失效。

      更根本地，新规则的结论左边是任意项，不由最外层形状唯一决定。现在 $0 : tB$ 的推导最后一步不是 T-Zero，因此原来的语法导向表和逐形状反演不能照搬。扩展语言有自己的规则，必须重新陈述相应性质，而不是把这看成原定理的反例。
    ],
  )[
    只在类型规则中增加 $frac(t : tN, t : tB)$，求值规则暂不改动。给出一个具有两个类型的项，指出原来的类型唯一、反演和语法导向分析各在哪一步失效。
  ]

]

#html.nav(class: "chapter-nav", aria-label: "文章导航")[
  #cite("/how/plt/formal/normal-forms.typ")[← 范式、受阻与多步归约]
  #cite("/how/plt/formal/index.typ")[回到形式化入门]
  #cite("/how/plt/formal/type-safety.typ")[类型安全：典范形式、进展与保型 →]
]
