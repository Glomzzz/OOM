#import "/lib/formal.typ": *

#show: formal-page.with(
  title: [类型：语法导向、反演与唯一性],
  description: [定义算术语言的类型判断与良类型词项，利用语法导向性质证明类型反演与类型唯一性．],
)

= 类型判断

类型系统是在词项的抽象语法上定义的一组规则；
它说明哪些词项与类型之间的关系可以成立．
先区分三个概念：*类型关系*是词项与类型之间的关系，
*类型判断*是形如 $tack.r t : T$ 的陈述，
*类型规则*则规定怎样证明这样的判断．

#statement("definition/types-and-typing-judgments")

#statement("definition/well-typed-terms")

这个定义首先强调*“存在某个 $T$”*：良类型只要求*有*一个类型，不要求事先指定是哪一个；
$0$ 满足 $0 : tN$，因此是良类型的（它不具有 $tB$ 并不影响这一点）．
这里固定的是*项*，寻找的是*类型*；
类型居留性反过来固定类型，问是否存在具有该类型的项（三种问题的区分与常见误解见 #refer("note/type-what-so-many")）．

同时，它要求*“有一棵推导”*：和 $stp$ 一样，$t : T$ 成立当且仅当能用
#refer("definition/types-and-typing-judgments")
中七条规则的实例搭出一棵以它为根的有限树．
说词项良类型，就是说*能写出*这样一棵树；
说它不良类型，就是说*无论怎样搭都搭不出来*．
后者是关于所有可能推导的否定命题，
不能仅凭尝试构造某棵推导树失败就断言它不良类型；
要证明它不良类型，需要分析类型规则及其前提，排除任何合法推导成立的可能（下面的例子会演示这一点）．

此外，*良类型属于静态性质*：在目前讨论的语言中，
#refer("definition/types-and-typing-judgments")
中的类型判断只依赖项的结构与类型规则，
无需执行 #refer("definition/one-step-reduction") 中的 $stp$ 规约．
因此不必运行词项就能判断它是否良类型，这构成了*静态类型检查*的基础
（与动态检查的对照见 #refer("note/static-and-dynamic-typing")）．
至于类型判断与求值这两套规则之间是否协调一致，还要靠 #refer("corollary/type-safety") 的类型安全定理来保证．

规则的读法与 #refer("definition/one-step-reduction") 相同：
横线上是前提，横线下是结论，$T$、$t_1$ 是元变量（#refer("convention/metavariables")）．
这里还要注意*类型*与*词项*是不同的语法类别：
$T$ 只能代换为 $tB$ 或 $tN$，$t_1$ 则代换为词项．
T-If 的两个分支可以同为 $tB$ 或同为 $tN$，但同一次规则应用中的 $T$ 必须取同一个类型．

类型规则同样是归纳定义，因此也可以对类型推导使用*规则归纳法*，
原理与 #refer("theorem/induction-on-derivations") 相同．
这种横线上写前提、横线下写结论的记号来自形式逻辑，与*自然演绎*相近，
直接刻画判断的可推导性（至于检查器按什么顺序执行，还需另行规定）．

#statement("example/well-typed-and-ill-typed-terms")

#statement("note/answers-to-incomplete-specification-questions")

#statement("note/locating-errors-in-failed-typing-derivations")

#statement("note/conservative-type-systems")

= 反演：从结论倒推前提

先看这组规则的结论．
每条规则的结论都形如“某个项 : 某个类型”，
结论左边的项有一个最外层构造子（$"true"$、$"if"$、$"succ"$ 等），这就是它的*形状*．
把七条规则按结论左边的形状列出来：

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

这张表的第三列全是 $1$：*本文*的每种项形状恰好对应一条候选定型规则．
这组规则是*语法导向*的：
可以依据项的语法形状确定应尝试哪条规则，不必猜测最后一步．
一般来说，语法导向不要求每个项都有规则可选，更不保证规则的前提都成立；
没有匹配规则或前提搭不上，都可能导致拒绝．
Harper 在
#link("https://home.ttic.edu/~dreyer/course/papers/harper-tspl.pdf")[Type Systems for Programming Languages §1.2]
中的表述是“至多一条规则”，不要误解为“必须恰好只有一条”．

作为对照，如果再加一条规则 $frac(t : tN, t : tB)$（“自然数可以当布尔值用”），
它的结论左边是任意项 $t$，不按项的形状限制．
仅看 $0$ 的语法形状，既不能排除 T-Zero，也不能排除这条转换规则，
最后一步不再由形状唯一决定．
具体要推出 $0 : tB$ 时，最后用的是转换规则，它的前提 $0 : tN$ 再由 T-Zero 给出．

语法导向带来很方便的推理方式：
知道了 $t : T$ 成立，就能断定推导的最后一步用的是哪条规则，
于是那条规则的前提也都成立．
例如，知道 $"succ" t_1 : T$ 成立，查表可知最后一步必然是 T-Succ，
于是立刻得到 $T = tN$ 且 $t_1 : tN$，不用知道推导的其余细节．
#refer("example/well-typed-and-ill-typed-terms") 里的两个例子也是这样做的：
每一步都只有一条规则可选．

#statement("lemma/typing-inversion")

*反演*利用规则定义的最小关系，穷尽结论可能来自的规则，把“某个判断存在推导”拆成任何合法推导都必须满足的前提信息
（这与直接把单条推导规则的蕴涵方向倒过来不同）．
保型证明例如从 $"pred" ("succ" #nv) : T$ 开始，
必须先知道 $T = tN$、$"succ" #nv : tN$，再继续取出 $#nv : tN$，
才能证明删去外层构造以后类型还在．
没有反演，就不能凭外观擅自断言子项有哪些类型；
增加子类型规则时这个推理尤其需要重证，下面的附注会给出原因．

#statement("note/inversion-and-syntax-directed-rules")

语法导向并不单凭“每种形状只有一条规则”就让输出类型自动唯一：
T-If 的 $T$ 还要从分支中确定．
下面的定理补上这个保证，说明 `type_of` 用单个类型就能表示规则给出的结果，无需返回类型集合．
没有唯一性，单个返回值可能只挑出了众多类型之一．
例如带子类型的 Kotlin 中，`Int` 表达式也可以出现在需要 `Number` 或 `Any` 的位置；
那样的系统通常要另外区分推断出的类型和它能充当的所有类型，不能照搬本文的结论．

#statement("theorem/uniqueness-of-types")

= 练习：类型

#exercise-group(4)[
  #exercise(
    "4.1",
    [从结论搭起一棵类型推导],
    hint: [最外层用 T-If；条件从 T-IsZero 开始，两个分支都应得到 $tN$．],
    answer: [
      #bigmath(
        $
          #inf("T-If", inf("T-IsZero", inf("T-Pred", inf("T-Succ", inf("T-Zero", $0 : tN$), $"succ" 0 : tN$), $"pred" ("succ" 0) : tN$), $"iszero" ("pred" ("succ" 0)) : tB$), inf("T-Succ", inf("T-Zero", $0 : tN$), $"succ" 0 : tN$), inf("T-Pred", inf("T-Zero", $0 : tN$), $"pred" 0 : tN$), $"if" ("iszero" ("pred" ("succ" 0))) "then" "succ" 0 "else" "pred" 0 : tN$)
        $,
        scale: 100%,
      )

      每个叶子都是 T-Zero，两个分支具有同一个类型 $tN$．
      定型过程中没有执行任何 $stp$ 规约，搭这棵推导完全不依赖条件最终求值成什么．
    ],
  )[
    为 $"if" ("iszero" ("pred" ("succ" 0))) "then" "succ" 0 "else" "pred" 0$
    写出完整的类型推导树，并指出推导中有没有哪一步需要先运行这个项．
    使用 #refer("definition/types-and-typing-judgments")．
  ]

  #exercise(
    "4.2",
    [严格证明项无类型],
    hint: [先用 #refer("lemma/typing-inversion") 固定最后一条规则，再追到无法成立的前提．],
    answer: [
      若 $"succ" ("if" "true" "then" 0 "else" "false")$ 有类型，
      最后只能用 T-Succ，要求内部 $"if"$ 为 $tN$；
      T-If 随即要求 $"false" : tN$，与 T-False 的结论不符．
      若 $"if" ("pred" 0) "then" 0 "else" 0$ 有类型，
      T-If 要求条件为 $tB$，但 $"pred" 0$ 的类型只能是 $tN$．
      若 $"iszero" ("iszero" 0)$ 有类型，
      外层 T-IsZero 要求内层为 $tN$，但内层 T-IsZero 的结论只能是 $tB$．

      这三种分析排除了所有可能的最后规则，因此是不存在推导的严格证明．
      第一个项却可以规约到 $"succ" 0$：实际没有执行坏分支．
      这再次说明“不良类型”并不等于“这次运行必定出错”．
    ],
  )[
    证明下面三项对任何 $T$ 都不能得到 $t : T$：
    $"succ" ("if" "true" "then" 0 "else" "false")$、
    $"if" ("pred" 0) "then" 0 "else" 0$、$"iszero" ("iszero" 0)$．
    每项给出无法满足的具体前提，并判断其中是否有实际能规约到值的项．
  ]

  #exercise(
    "4.3",
    [反演不需要看见整棵推导],
    hint: [
      先反演 T-If，再连续反演 T-Pred 和 T-Succ；
      整项的 $T$ 由其中一个分支确定．
    ],
    answer: [
      T-If 给出 $c : tB$、$"pred" ("succ" t_1) : T$、$u : T$．
      T-Pred 给出 $T = tN$ 以及 $"succ" t_1 : tN$；
      T-Succ 再给出 $t_1 : tN$．代回得到 $u : tN$．

      因而一定有 $T = tN$、$c : tB$、$t_1 : tN$、$u : tN$．
      这只提取已有推导必须满足的前提，
      并没有假定 $c$ 或 $t_1$ 已经求值，也不需要猜原推导的其他细节．
    ],
  )[
    设 $c$、$t_1$、$u$ 是任意项．
    已知 $"if" c "then" ("pred" ("succ" t_1)) "else" u : T$，
    但没有拿到它的推导树．
    说明此时仍能确定的 $T$、$c$、$t_1$、$u$ 的类型信息，
    并逐次标明使用 #refer("lemma/typing-inversion") 的哪一条．
  ]

  #exercise(
    "4.4",
    [扩展：增加转换规则的影响],
    hint: [保留七条旧规则，再添加“由 $t : tN$ 推出 $t : tB$”．首先检查 $0$．],
    answer: [
      T-Zero 给出 $0 : tN$，新规则再给出 $0 : tB$，
      所以 #refer("theorem/uniqueness-of-types") 不再成立．
      #refer("lemma/typing-inversion") 中“若 $0 : T$，则 $T = tN$”也失效．

      更根本地，新规则的结论左边是任意项，不由最外层形状唯一决定．
      现在 $0 : tB$ 的推导最后一步来自新规则，
      因此原来的语法导向表和逐形状反演不能照搬．
      扩展语言改动了规则，需要重新陈述并检验相应性质（原定理针对未扩展语言，依然成立）．
    ],
  )[
    只在类型规则中增加 $frac(t : tN, t : tB)$，求值规则暂不改动．
    给出一个具有两个类型的项，
    指出原来的类型唯一、反演和语法导向分析各在哪一步失效．
  ]
]

#html.nav(class: "chapter-nav", aria-label: "文章导航")[
  #cite("/how/plt/formal/normal-forms.typ")[← 正规形式、受阻与多步规约]
  #cite("/how/plt/formal/index.typ")[回到形式化入门]
  #cite("/how/plt/formal/type-safety.typ")[类型安全：典范形式、进展与保型 →]
]
