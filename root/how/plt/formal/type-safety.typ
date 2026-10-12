#import "/lib/formal.typ": *

#show: formal-page.with(title: [类型安全：典范形式、进展与保型])

= 先把命题写下来

“良类型的程序不会出错”这句话，#wiki("罗宾·米尔纳")[米尔纳（Milner）]在 1978 年说成 _well-typed programs cannot go wrong_。要把它写成精确命题，必须先规定“出错”是什么：本文只指归约到*受阻*（stuck）状态，即非值且没有后继的词项（#refer("definition/normal-forms-and-stuck-terms")）。这不是对异常、资源耗尽或业务逻辑错误的笼统保证。

要证明的*类型安全性*（type safety）表达了类型规则与执行规则之间的协调。文献常把这类保证称为*类型健全性*（type soundness）；本文在这一“不受阻”的意义下使用它。它与检查器相对类型规则的“算法可靠性”不是同一个命题。

#statement("definition/type-safety")

注意这句话里的量词：对*所有*良类型的 $t$，对*所有*它能多步归约到的 $t'$。这正是 #refer("example/quantifier-scope") 提醒过的地方，写成符号以后，范围就不会有歧义。

直接证这个命题不好下手，因为 $stps$ 可以归约任意多步。赖特（Wright）与#enwiki("Matthias_Felleisen")[费莱森（Felleisen）]在 1994 年给出的办法，是把它拆成两条只涉及*一步*的定理：

- *进展*（progress）：良类型的项要么是值，要么还能一步归约。它保证“现在不受阻”。
- *保型*（preservation，也叫 subject reduction）：良类型的项一步归约，得到的项类型不变。它保证“归约一步以后，进展还能接着用”。

两条缺一不可。#refer("example/reduction-to-a-stuck-term") 里的 $"succ" ("if" "true" "then" "false" "else" 0)$ 现在能归约，一步归约之后就受阻了。只有进展，挡不住这种情况；只有保型，挡不住一开始就受阻的项。（这个例子本身没有类型，所以它不是两条定理的反例，只是说明为什么两条都需要。）

= 典范形式

证明进展时需要知道：某个类型的*值*长什么样。

#statement("lemma/canonical-forms")

这条引理把静态信息和动态信息连了起来。它的前提 $v : tB$ 是*类型*信息，类型检查器不运行程序就能在编译期得出；它的结论“$v$ 是 $"true"$ 或 $"false"$”是*形状*信息，说的是这个值具体长什么样，而求值规则只认形状。进展的证明正是靠它，从“条件是 $tB$ 类型的值”推出“条件确实是 $"true"$ 或 $"false"$”，才能选择 E-IfTrue 或 E-IfFalse。反过来，若随意加一条定型规则 $0 : tB$，却不改求值规则，$"if" 0 "then" "true" "else" "false"$ 就能通过类型检查，虽然没有任何求值规则能处理它，所以会受阻：类型说它是布尔值，形状却不是已有的求值规则要的 $"true"$ 或 $"false"$。动态语言在运行时做的种类检查，正是在实际运行到时才检查这类形状条件。

#statement("note/static-and-dynamic-typing")

= 进展

进展回答的是“类型检查通过以后，下一步会不会无规则可用”。没有它，检查器即使给出了类型，也未必挡住 $"succ" "true"$ 这样的错误。具体地，若把 T-Succ 的前提错误地放宽成 $t_1 : tB$，这个项就会被赋予 $tN$，却既不是值也不能归约。进展还必须允许“已经是值”这个分支，否则 $0$ 这种合法结果反而会被误判为失败。对于有异常的真实语言，则要先明确哪些异常是许可的结果，不能把本文的进展原封不动当作“永不抛异常”。

#statement("theorem/progress")

#statement("example/progress")

看 $"succ" "true"$ 为什么会受阻，再对照证明：要让它不受阻，要么 $"true"$ 能归约，要么 $"true"$ 是数值，两者都不成立。证明之所以没遇到这个麻烦，是因为 T-Succ 要求 $t_1 : tN$，再经由典范形式把 $t_1$ 限定为数值。类型系统正是在这里把坏程序挡在门外的。

= 保型

进展只能保证当前状态能运行，保型则让这个保证在运行后仍然可用。若修改 E-PredZero 为 $"pred" 0 stp "true"$，原有类型规则仍会给 $"succ" ("pred" 0)$ 类型 $tN$，第一步也可以执行；但它会变成没有类型、且受阻的 $"succ" "true"$。所以一次正确的类型检查必须能跨越每次运行时改写，不能“第一步安全就算安全”。编译器的优化、解释器的执行规则也要维持相应的不变量，否则即使前端检查器正确，后端仍能制造坏状态。

#statement("theorem/preservation")

#statement("example/preservation")

#statement("note/generalizing-the-type-in-preservation-proofs")

= 合起来

下面的推论把“当前不受阻”和“下一项仍有类型”接成对*任意有限运行前缀*的保证。只证明进展而不证明保型，保证可能一步后失效；只证明保型而不证明进展，则一个起初就受阻的良类型项没有任何一步可走，保型的条件从未成立，不能排除它。这个推论保证的是本文定义的“不受阻”，不保证程序一定终止，也不保证业务逻辑正确，例如得到 $"false"$ 是否符合程序员的意图。

#statement("corollary/type-safety")

类型安全本身不保证终止，但 #refer("lemma/reduction-decreases-size") 已经另外证明了本文每条归约链都有限。把它与进展、保型和确定性接起来，还能得到更完整的求值结论：每个良类型项都会到达唯一的同类型值。

#statement("corollary/well-typed-terms-evaluate-to-unique-values")

#statement("remark/convention-and-necessity")

= 练习：类型安全

#exercise-group(4)[
  #exercise(
    "5.1",
    [把进展与保型放到同一条链上],
    hint: [每个中间项都为 $tN$；条件内部先保持 $tN$，外层 $"iszero"$ 保持 $tB$，不能把这两个类型混成一个固定的 $T$。],
    answer: [
      $
            & "if" ("iszero" ("pred" ("succ" 0))) "then" "pred" 0 "else" "succ" 0 && : tN \
        stp & "if" ("iszero" 0) "then" "pred" 0 "else" "succ" 0                   && : tN \
        stp & "if" "true" "then" "pred" 0 "else" "succ" 0                         && : tN \
        stp & "pred" 0                                                            && : tN \
        stp & 0                                                                   && : tN
      $

      四步依次用 E-If + E-IsZero + E-PredSucc，E-If + E-IsZeroZero，E-IfTrue，E-PredZero。每个非末项都展示了进展要求的一个后继，末项 $0$ 展示了“已经是值”的分支。

      第一步内层 $"pred" ("succ" 0)$ 从 $tN$ 保持为 $0 : tN$，T-IsZero 重建条件的 $tB$，T-If 再和两个 $tN$ 分支重建整项的 $tN$。第二步条件变成 $"true" : tB$，分支不变；第三步选出的 $"pred" 0$ 本来就在 T-If 的前提里具有 $tN$；第四步由 T-Zero 得 $0 : tN$。这才是类型为何保持的逐步解释，不只是把相同的标签写在每一行旁边。
    ],
  )[
    对 $"if" ("iszero" ("pred" ("succ" 0))) "then" "pred" 0 "else" "succ" 0$ 写出归约链与每站类型。逐步说明 #refer("theorem/progress") 在哪里提供后继，#refer("theorem/preservation") 又怎样重建类型；第一步内部用到的类型为何不都是整项的 $tN$？
  ]

  #exercise(
    "5.2",
    [扩展：只有一条安全性定理够吗？],
    hint: [分别修改，不要把两种修改混到同一门语言里。保型只对实际存在的归约步骤作保证。],
    answer: [
      删除 E-PredZero 而保留其他规则时，$"pred" 0 : tN$ 既不是值也没有后继，进展失效。但剩下的每一步仍是原语言合法的步骤，因此仍保型。保型无法排除一个根本没有步骤的坏终点。

      将 E-PredZero 改为 $"pred" 0 stp "true"$ 时，$"pred" 0 : tN$ 走到 $"true" : tB$，保型失效。原来的进展证明仍能为每个良类型非值找到一步，T-Pred 的零参数情形只是把后继换了一个；但它不保证后继仍良类型。

      例如 $"succ" ("pred" 0) : tN$ 在第二种修改下走到受阻的 $"succ" "true"$。所以“现在有下一步”与“类型保证能传到下一项”必须一起使用，见 #refer("corollary/type-safety")。
    ],
  )[
    分别考虑两种修改：一是删除 E-PredZero；二是把它改成 $"pred" 0 stp "true"$。其余求值与类型规则都保留。每种修改破坏进展还是保型？另一条是否还能成立？用具体项说明只留一条为什么不足以保证类型安全。
  ]

  #exercise("5.3", [保型能倒过来读吗？], hint: [从“分支类型不同，但运行选中一个正常分支”的项开始寻找。], answer: [
    不成立。取 $t = "if" "true" "then" 0 "else" "false"$，E-IfTrue 给出 $t stp 0$，且 $0 : tN$，但 $t$ 没有类型：T-If 要求两个分支具有同一类型，而 $0$ 与 $"false"$ 的类型不同。

    这不违反保型，因为保型的前提是*起点已有类型*。从一个正常的终点倒推起点有类型，相当于把一个单向蕴涵改成了逆命题，#refer("note/conservative-type-systems") 已经提醒过不能这样用。
  ])[
    判断：“若 $t stp t'$ 且 $t' : T$，则 $t : T$。”它是不是 #refer("theorem/preservation") 的等价表述？若不是，给出原语言中的一步反例，说明为什么不与保型矛盾。
  ]

  #exercise(
    "5.4",
    [扩展：不受阻，仍然可以永远运行],
    hint: [把 E-PredZero 改成自循环步骤，但不保留它原来归约到 $0$ 的版本。检查下一步是否存在、类型是否改变、大小是否下降。],
    answer: [
      新规则是 $"pred" 0 stp "pred" 0$。$"pred" 0 : tN$ 仍不是值，始终有下一步，所以没有受阻；每一步又回到同一个具有 $tN$ 的项，因此这条链一直保持类型，却永不结束。

      原进展证明的 T-Pred 零参数情形仍有后继；原保型证明的 E-PredZero 情形改为“结果就是起点，已有 $tN$”。其他情形不变，所以这门修改后的语言仍可证明进展、保型与不受阻的类型安全。

      但大小始终为 $2$，原语言“每一步严格变小”的论证不能再用，求值循环也不能再保证停止。类型安全没有承诺终止；要证明终止，还需要另外的下降度量或其他证明。
    ],
  )[
    只将 E-PredZero 改成 $"pred" 0 stp "pred" 0$，其余规则不变。分析从 $"pred" 0$ 出发的运行：它受阻吗？保型吗？会终止吗？说明进展与保型的证明只需调整哪个情形，以及“每步让项变小”的论证为什么失效。
  ]

]

#html.nav(class: "chapter-nav", aria-label: "文章导航")[
  #cite("/how/plt/formal/typing.typ")[← 类型：语法导向、反演与唯一性]
  #cite("/how/plt/formal/index.typ")[回到形式化入门]
  #cite("/how/plt/formal/rules-and-algorithms.typ")[规则与算法：可靠性与完备性 →]
]
