#import "/lib/formal.typ": *

#show: formal-page.with(
  title: [正规形式、受阻与多步规约],
  description: [区分作为合法终点的值与作为运行时错误的受阻项，并定义多步规约关系．],
)

#statement("definition/normal-forms-and-stuck-terms")

*正规形式*是相对于给定规约关系*没有后继的词项*，
好比 $(1 + 2) times 3$ 化简到 $9$ 后不能再算．
这里的定义只看能否继续规约，
不保证结果合法、存在或唯一，也与 BNF 中的 Form 无关．
在本文的关系下，正规形式分成*值*与*受阻的项*两类．
值表示已经算完且合法的结果；由 #refer("lemma/values-do-not-reduce")，值都是正规形式，例如 $"true"$、$"succ" 0$．
受阻的项则是不能再规约的非值，计算停在了规则无法继续处理的地方：
比如 $"succ" "true"$，唯一候选规则 E-Succ 要求 $"true"$ 能规约而无法满足，同时 $"true"$ 又不属于数值，整项不算值；
又如 $"if" 0 "then" "true" "else" "false"$，E-IfTrue、E-IfFalse 要求条件是 $"true"$ 或 $"false"$，E-If 要求 $0$ 能规约，三条都用不上；
再如 $"iszero" "false"$，E-IsZeroZero、E-IsZeroSucc 要求参数是数值，E-IsZero 要求 $"false"$ 能规约，同样无一成立．

#statement("note/translation-of-stuck")

本文用*受阻*建模一类*运行时错误*：
例如词项要求把布尔值加一，但没有转移规则处理这一操作．
受阻只刻画这类“非值且无后继”的状态，显式抛异常与无限循环仍须另外区分．
下一节的类型系统会在*不按求值规则运行*程序的前提下拒绝一些项；
我们要证明，*类型系统接受的项不会走到受阻状态*．
检查器拒绝某项可以报为*编译期错误*，但遭拒绝不意味着实际求值一定受阻．
这套规则的保守性见 #refer("note/conservative-type-systems")．

= 多步规约

一步规约只描述“一次改写”．
程序真正运行时要连续改写很多次，所以需要把若干步串起来．

#statement("definition/multi-step-reduction")

M-Refl 给出零步规约，即自反性；M-Step 把一步接到有限多步之前．
由于取的是最小关系，$t stps t'$ 成立当且仅当存在一条有限链
$t = t_0 stp t_1 stp dots.c stp t_n = t'$（$n >= 0$）．
上角的星号表示重复零次或多次，与 Kleene 星号的惯例一致；
$stps$ 称为 $stp$ 的*自反传递闭包*．

#statement("example/multi-step-reduction-to-a-value")

#statement("example/reduction-to-a-stuck-term")

对这门小语言，规约链不会无限延续下去．

#statement("lemma/reduction-decreases-size")

多步规约仍属于小步语义：
它把执行步骤串起来，右端 $t'$ 可以是任意中间状态，不必是值．
*大步操作语义*（也称*自然语义*）则通常直接定义词项与最终值之间的*求值关系*，
常记为 $t ⇓ v$．
不能只因 $stps$ 描述了多次改写，就把它当作大步语义；
两种定义是否给出相同的求值结果，需要针对具体规则证明．

同样，实现成函数也不直接等同于*指称语义*．
指称语义通过*值化函数*把词项映射到*语义域*，
并要求复合词项的意义由子项的意义组合而成，即满足*组合性*．
操作语义同样可以实现成函数；
两者的分野在于所定义的是执行关系，还是词项在语义域中的意义．

= 练习：求值

#exercise-group(5)[
  #exercise(
    "3.1",
    [值、正规形式与受阻别混在一起],
    hint: [
      先用 #refer("definition/values-and-numeric-values") 判断值，
      再问是否存在一步规约；
      “正规形式”与“受阻”按 #refer("definition/normal-forms-and-stuck-terms") 判断．
    ],
    answer: [
      $"succ" ("succ" 0)$ 是数值，同时也是值和正规形式，不受阻．
      $"pred" ("succ" 0)$ 不属于值，且 E-PredSucc 给出后继 $0$，因此也不属于正规形式，当前不受阻．
      $"succ" "true"$ 不属于值，唯一候选 E-Succ 的前提无法成立，属于受阻的正规形式．
      $"if" "true" "then" 0 "else" ("succ" "true")$ 不属于值，但 E-IfTrue 直接给出 $0$（未选中的坏分支不参与求值），因此不属于正规形式，也不受阻．
      $"if" 0 "then" 0 "else" 0$ 不属于值，条件既非布尔值又不能规约，属于受阻的正规形式．

      可见“非值”未必“受阻”，“含有坏的子项”也未必“当前受阻”．
    ],
  )[
    对下面五个项分别判断是否为值、是否为正规形式、是否受阻；
    能够规约的，还要给出下一项和规则名：
    $"succ" ("succ" 0)$、$"pred" ("succ" 0)$、$"succ" "true"$、
    $"if" "true" "then" 0 "else" ("succ" "true")$、$"if" 0 "then" 0 "else" 0$．
  ]

  #exercise(
    "3.2",
    [一条链与第一步的推导树],
    hint: [
      第一步经由三条同余规则进入条件中的 $"pred" 0$，尚不能直接消去最外层 $"pred"$．
    ],
    answer: [
      $
            & "pred" ("if" ("iszero" ("pred" 0)) "then" "succ" ("succ" 0) "else" 0) \
        stp & "pred" ("if" ("iszero" 0) "then" "succ" ("succ" 0) "else" 0) \
        stp & "pred" ("if" "true" "then" "succ" ("succ" 0) "else" 0) \
        stp & "pred" ("succ" ("succ" 0)) \
        stp & "succ" 0
      $

      四步所用的规则依次是 E-Pred + E-If + E-IsZero + E-PredZero，
      E-Pred + E-If + E-IsZeroZero，E-Pred + E-IfTrue，E-PredSucc．
      第一步的完整推导是：

      #bigmath(
        $
          #inf("E-Pred", inf("E-If", inf("E-IsZero", inf("E-PredZero", $"pred" 0 stp 0$), $"iszero" ("pred" 0) stp "iszero" 0$), $"if" ("iszero" ("pred" 0)) "then" "succ" ("succ" 0) "else" 0 stp "if" ("iszero" 0) "then" "succ" ("succ" 0) "else" 0$), $"pred" ("if" ("iszero" ("pred" 0)) "then" "succ" ("succ" 0) "else" 0) stp "pred" ("if" ("iszero" 0) "then" "succ" ("succ" 0) "else" 0)$)
        $,
        scale: 100%,
      )

      最后 $"succ" 0$ 是值，没有后继．
      注意多步规约关系除了连接起点与最终值，也包含起点自身以及链上的每个中间项．
    ],
  )[
    写出 $"pred" ("if" ("iszero" ("pred" 0)) "then" "succ" ("succ" 0) "else" 0)$
    到正规形式的完整规约链，标明每一步用到的规则，并画出第一步的推导树．
    使用 #refer("definition/one-step-reduction")，不要把两次计算并成一步．
  ]

  #exercise(
    "3.3",
    [扩展：函数选一条路，不等于关系只有一条路],
    hint: [
      使用 #refer("note/numeric-value-restriction-in-predecessor-reduction")
      的放宽规则时，可以消去外层，也可以先在 $"iszero" 0$ 里计算．
    ],
    answer: [
      把 E-PredSucc 改成允许任意 $t$ 的 $"pred" ("succ" t) stp t$ 后，
      取 $s = "pred" ("succ" ("iszero" 0))$．
      直接消去外层得到 $s stp "iszero" 0$；
      先用同余规则进入内部，得到 $s stp "pred" ("succ" "true")$．

      两个后继不同，所以一步关系不确定．
      第一条路线再用 E-IsZeroZero 到 $"true"$，
      第二条路线再用放宽的 E-PredSucc 到 $"true"$；
      因此这个分叉可以汇合．但一个可汇合的例子不证明整套扩展关系合流．

      Rust 函数即使按分支优先级选出唯一返回值，也没有消除关系的另一条合法路线．
      要么实现“所有后继”的接口，
      要么明确说这个单后继函数实现的是选定策略限制后的关系．
      注意扩展规则下 $"pred" ("succ" "true")$ 能规约，
      不能照搬它在原语言中受阻的判断．
    ],
  )[
    只把 E-PredSucc 的 $#nv$ 放宽为任意项，其余规则不变．
    为 $"pred" ("succ" ("iszero" 0))$ 找出两个不同的一步后继，并分别继续规约．
    说明这个例子证明了什么、没有证明什么，
    并判断在 `step` 用 `match` 只返回其中一个后继时，能否据此声称扩展关系仍确定．
  ]

  #exercise(
    "3.4",
    [换一个相等三角形],
    hint: [
      比较空字符串 `""`、数字 `0` 和字符串 `"0"`．
      同类字符串的 `==` 不会再把两边都转成数字．
    ],
    answer: [
      `"" == 0` 和 `0 == "0"` 为 `true`，`"" == "0"` 为 `false`；
      三组 `===` 都为 `false`．
      前两次把字符串转为数字，第三次只比较两个不同的字符串．

      使用 #refer("note/equality-and-language-design") 的自定义 `==` 去重算法，
      输入 `["", 0, "0"]` 留下 `["", "0"]`，输入 `[0, "", "0"]` 只留下 `[0]`．
      规则明确仍可能失去算法所依赖的传递性；
      改用 `===` 后这三种输入彼此不同，在这个例子中不会合并，
      但仍要留意对象身份和 `NaN` 的特殊处理．
    ],
  )[
    对 `""`、`0`、`"0"` 两两计算 `==` 与 `===` 的结果，画出另一个相等三角形．
    再按“新值与任何已保留值满足 `==` 就丢弃”的算法，
    分别去重 `["", 0, "0"]` 与 `[0, "", "0"]`，并解释两者的保留数量为何不同．
  ]

  #exercise(
    "3.5",
    [扩展：错误只沿实际求值的位置传播],
    hint: [
      使用 #refer("note/explicit-errors-and-kotlin-bottom-type") 的错误扩展；
      不要把未选中的分支当作正在求值的操作数．
    ],
    answer: [
      对 $"if" "true" "then" 0 "else" ("succ" "true")$，
      原语言与错误扩展都用 E-IfTrue 直接得到 $0$，不计算 $"else"$ 分支．

      原语言中的 $"pred" ("succ" "false")$ 没有后继，是受阻的正规形式．
      错误扩展先在内部用 E-OpBool，并由 E-Pred 提升到整项，得到 $"pred" "wrong"$；
      再用 E-OpWrong 到 $"wrong"$（这是专设的异常终点，与普通数值分开）．

      $"wrong"$ 是错误项，`IllegalArgumentException` 是异常对象，$bot$ 是底类型．
      Kotlin 的抛异常表达式可以具有 `Nothing` 类型，
      不意味着异常对象是底类型的值，也不意味着未选中的异常分支必须先执行．
    ],
  )[
    比较原语言与显式错误扩展对
    $"if" "true" "then" 0 "else" ("succ" "true")$
    和 $"pred" ("succ" "false")$ 的处理，写出每一步，
    并区分 $"wrong"$、Kotlin 的异常对象与底类型 $bot$．
  ]
]

#html.nav(class: "chapter-nav", aria-label: "文章导航")[
  #cite("/how/plt/formal/determinism.typ")[← 确定性：从规则归纳到求值器]
  #cite("/how/plt/formal/index.typ")[回到形式化入门]
  #cite("/how/plt/formal/typing.typ")[类型：语法导向、反演与唯一性 →]
]
