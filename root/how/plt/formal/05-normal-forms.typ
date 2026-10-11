#import "/lib/formal.typ": *

#show: formal-page.with(title: [范式、受阻与多步归约])

#statement("definition/normal-forms-and-stuck-terms")

“范式”这个词的意思是“标准的、最终的形式”：一个项归约到不能再归约，就到了它的范式，好比把 $(1 + 2) times 3$ 化简到 $9$ 就化简不下去了。注意范式是按*能不能归约*定义的，和项“好不好”无关。范式分成两种：

- *值*：算完了，而且是一个合法的结果。由 #refer("lemma/values-do-not-reduce")，值都是范式。例如 $"true"$、$"succ" 0$。
- *非值*（*受阻的项*）：不能再归约，但也不是值，计算停在了一个没有意义的地方。例如：
  - $"succ" "true"$：唯一可能的规则 E-Succ 要求 $"true"$ 能归约，而它不能；它又不是数值，所以不是值；
  - $"if" 0 "then" "true" "else" "false"$：E-IfTrue、E-IfFalse 要求条件是 $"true"$ 或 $"false"$，E-If 要求 $0$ 能归约，三条都用不上；
  - $"iszero" "false"$：E-IsZeroZero、E-IsZeroSucc 要求参数是数值，E-IsZero 要求 $"false"$ 能归约，都不行。

#statement("note/translation-of-stuck")

受阻对应真实语言里的*错误*（error）：程序要做一件语义里没有定义的事，比如把布尔值加一，目前我们只能把这个错误拖到运行时，也就是运行时错误（runtime error）。下一节的类型系统要做的，就是在*不运行*程序的前提下，提前把会走到受阻状态的程序找出来，可以让它们成为编译期错误（compiletime error）。

= 多步归约

一步归约只描述“一次改写”。程序真正运行时要连续改写很多次，所以需要把若干步串起来。

#statement("definition/multi-step-reduction")

M-Refl 说“零步归约”永远成立（自反），M-Step 说在一步后面接上若干步还是若干步。由于取的是最小关系，$t stps t'$ 成立当且仅当存在一条有限的链 $t = t_0 stp t_1 stp dots.c stp t_n = t'$（$n >= 0$）。$stps$ 上角的星号来自正则表达式里的 Kleene 星号，意思是“重复零次或多次”，数学上称 $stps$ 为 $stp$ 的*自反传递闭包*（reflexive transitive closure）。

#statement("example/multi-step-reduction-to-a-value")

#statement("example/reduction-to-a-stuck-term")

= 练习：求值

#exercise-group(5)[
  #exercise(
    "3.1",
    [值、范式与受阻别混在一起],
    hint: [先用 #refer("definition/values-and-numeric-values") 判断值，再问是否存在一步归约；“范式”与“受阻”按 #refer("definition/normal-forms-and-stuck-terms") 判断。],
    answer: [
      - $"succ" ("succ" 0)$ 是数值，也是值和范式，不受阻。
      - $"pred" ("succ" 0)$ 不是值，也不是范式：E-PredSucc 给出后继 $0$，所以现在不受阻。
      - $"succ" "true"$ 不是值，是受阻的范式：唯一候选 E-Succ 的前提无法成立。
      - $"if" "true" "then" 0 "else" ("succ" "true")$ 不是值，也不是范式；E-IfTrue 直接给出 $0$。未选中的坏分支不参与求值。
      - $"if" 0 "then" 0 "else" 0$ 不是值，是受阻的范式：条件不是布尔值，也不能归约。

      因此“不是值”不等于“受阻”，“有坏的子项”也不等于“现在受阻”。
    ],
  )[
    对下列五个项分别判断：是否为值、是否为范式、是否受阻。能够归约的，还要给出下一项和规则名：$"succ" ("succ" 0)$、$"pred" ("succ" 0)$、$"succ" "true"$、$"if" "true" "then" 0 "else" ("succ" "true")$、$"if" 0 "then" 0 "else" 0$。
  ]

  #exercise(
    "3.2",
    [一条链与第一步的推导树],
    hint: [第一步不是消去最外层 $"pred"$，而是经由三条同余规则进入条件中的 $"pred" 0$。],
    answer: [
      $
            & "pred" ("if" ("iszero" ("pred" 0)) "then" "succ" ("succ" 0) "else" 0) \
        stp & "pred" ("if" ("iszero" 0) "then" "succ" ("succ" 0) "else" 0) \
        stp & "pred" ("if" "true" "then" "succ" ("succ" 0) "else" 0) \
        stp & "pred" ("succ" ("succ" 0)) \
        stp & "succ" 0
      $

      四步所用的规则依次是 E-Pred + E-If + E-IsZero + E-PredZero，E-Pred + E-If + E-IsZeroZero，E-Pred + E-IfTrue，E-PredSucc。第一步的完整推导是：

      #bigmath(
        $
          #inf("E-Pred", inf("E-If", inf("E-IsZero", inf("E-PredZero", $"pred" 0 stp 0$), $"iszero" ("pred" 0) stp "iszero" 0$), $"if" ("iszero" ("pred" 0)) "then" "succ" ("succ" 0) "else" 0 stp "if" ("iszero" 0) "then" "succ" ("succ" 0) "else" 0$), $"pred" ("if" ("iszero" ("pred" 0)) "then" "succ" ("succ" 0) "else" 0) stp "pred" ("if" ("iszero" 0) "then" "succ" ("succ" 0) "else" 0)$)
        $,
        scale: 100%,
      )

      最后 $"succ" 0$ 是值，没有后继。多步归约还包括链的中间各站与起点自身，不只是最终结果。
    ],
  )[
    写出 $"pred" ("if" ("iszero" ("pred" 0)) "then" "succ" ("succ" 0) "else" 0)$ 到范式的完整归约链，标明每一步用到的规则，并画出第一步的推导树。使用 #refer("definition/one-step-reduction")，不要把两次计算并成一步。
  ]

  #exercise(
    "3.3",
    [扩展：函数选一条路，不等于关系只有一条路],
    hint: [使用 #refer("note/numeric-value-restriction-in-predecessor-reduction") 的放宽规则时，可以消去外层，也可以先在 $"iszero" 0$ 里计算。],
    answer: [
      把 E-PredSucc 改成允许任意 $t$ 的 $"pred" ("succ" t) stp t$ 后，取 $s = "pred" ("succ" ("iszero" 0))$。直接消去外层得到 $s stp "iszero" 0$；先用同余规则进入内部，得到 $s stp "pred" ("succ" "true")$。

      两个后继不同，所以一步关系不确定。第一条路线再用 E-IsZeroZero 到 $"true"$，第二条路线再用放宽的 E-PredSucc 到 $"true"$；因此这个分叉可以汇合。但一个可汇合的例子不证明整套扩展关系合流。

      Rust 函数即使按分支优先级选出唯一返回值，也没有消除关系的另一条合法路线。要么实现“所有后继”的接口，要么明确说这个单后继函数实现的是选定策略限制后的关系。注意扩展规则下 $"pred" ("succ" "true")$ 能归约，不能照搬它在原语言中受阻的判断。
    ],
  )[
    只把 E-PredSucc 的 $#nv$ 放宽为任意项，其余规则不变。为 $"pred" ("succ" ("iszero" 0))$ 找出两个不同的一步后继，并分别继续归约。这个例子证明了什么、没有证明什么？如果 `step` 用 `match` 只返回其中一个，能否据此声称扩展关系仍确定？
  ]

  #exercise(
    "3.4",
    [换一个相等三角形],
    hint: [比较空字符串 `""`、数字 `0` 和字符串 `"0"`。同类字符串的 `==` 不会再把两边都转成数字。],
    answer: [
      `"" == 0` 和 `0 == "0"` 为 `true`，`"" == "0"` 为 `false`；三组 `===` 都为 `false`。前两次把字符串转为数字，第三次只比较两个不同的字符串。

      使用 #refer("note/equality-and-language-design") 的自定义 `==` 去重算法，输入 `["", 0, "0"]` 留下 `["", "0"]`，输入 `[0, "", "0"]` 只留下 `[0]`。规则明确仍可能失去算法所依赖的传递性；改用 `===` 后这三种输入彼此不同，不会在这个例子中被合并，但仍要留意对象身份和 `NaN` 的特殊处理。
    ],
  )[
    对 `""`、`0`、`"0"` 两两计算 `==` 与 `===` 的结果，画出另一个相等三角形。再按“新值与任何已保留值满足 `==` 就丢弃”的算法，分别去重 `["", 0, "0"]` 与 `[0, "", "0"]`。它们为什么连保留下来的数量都可能不同？
  ]

  #exercise(
    "3.5",
    [扩展：错误只沿实际求值的位置传播],
    hint: [使用 #refer("note/explicit-errors-and-kotlin-bottom-type") 的错误扩展；不要把未选中的分支当作正在求值的操作数。],
    answer: [
      对 $"if" "true" "then" 0 "else" ("succ" "true")$，原语言与错误扩展都用 E-IfTrue 直接得到 $0$，不计算 else 分支。

      原语言中的 $"pred" ("succ" "false")$ 没有后继，是受阻的范式。错误扩展先在内部用 E-OpBool，并由 E-Pred 提升到整项，得到 $"pred" "wrong"$；再用 E-OpWrong 到 $"wrong"$。它是明确的异常终点，不是普通数值。

      $"wrong"$ 是错误项，`IllegalArgumentException` 是异常对象，$bot$ 是底类型。Kotlin 的抛异常表达式可以具有 `Nothing` 类型，不意味着异常对象是底类型的值，也不意味着未选中的异常分支必须先执行。
    ],
  )[
    比较原语言与显式错误扩展对 $"if" "true" "then" 0 "else" ("succ" "true")$ 和 $"pred" ("succ" "false")$ 的处理，写出每一步。最后说明 $"wrong"$、Kotlin 的异常对象与 $bot$ 为什么不能当作同一个东西。
  ]

]

#html.nav(class: "chapter-nav", aria-label: "文章导航")[
  #cite("/how/plt/formal/04-determinism.typ")[← 确定性：从推导归纳到求值器]
  #cite("/how/plt/formal/index.typ")[回到形式化入门]
  #cite("/how/plt/formal/06-typing.typ")[类型：语法导向、反演与唯一性 →]
]
