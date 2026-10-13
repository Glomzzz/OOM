#import "/lib/statements.typ": *
#import "/lib/formal-math.typ": *

#let entry = (
  title: [求值策略、规约策略与合流性],
  date: "2026-10-10",
  author: "Glomzzz",
  parent: "/how/plt/formal/determinism.typ",
  legacy-id: "fm-rm-strategy",
)

#show: statement-page.with("note/evaluation-strategies-reduction-strategies-and-confluence", entry)

*规约策略*规定：当词项的多个位置都能改写时，选择哪个位置、哪条规则作为下一步．
*求值策略*则规定语言怎样求得程序的结果，
包括先算哪些子表达式、函数参数何时计算、是否计算函数体内部，以及算到什么形式就停止．
文献有时混用这两个词；这里用前者强调“选规约路线”，用后者强调运行时的整体约定．
能直接应用一条基本规约规则（也称计算规则或收缩规则）的子表达式，
称为*可规约表达式*，简称*可规约项*．

先看只含精确整数运算、没有副作用的例子．
括号固定语法树；允许在任意子表达式里计算一次加、减、乘或整除时，下面的项至少有两条路线：

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
    spacing: (19mm, 9mm),
    edge-stroke: 0.8pt,
    nd((0, 0), $((8 div 2) + 3) times (5 - 1)$, orange),
    nd((-1, 1), $(4 + 3) times (5 - 1)$, blue),
    nd((-1, 2), $7 times (5 - 1)$, blue),
    nd((1, 1), $((8 div 2) + 3) times 4$, gray),
    nd((1, 2), $(4 + 3) times 4$, gray),
    nd((0, 3), $7 times 4$, blue),
    nd((0, 4), $28$, green),
    edge(
      (0, 0),
      (-1, 1),
      "-|>",
      stroke: 1.2pt + blue,
      label: text(size: 8pt)[先算左边],
    ),
    edge((-1, 1), (-1, 2), "-|>", stroke: 1.2pt + blue),
    edge((-1, 2), (0, 3), "-|>", stroke: 1.2pt + blue),
    edge(
      (0, 0),
      (1, 1),
      "-|>",
      stroke: (dash: "dashed"),
      label: text(size: 8pt)[先算右边],
    ),
    edge((1, 1), (1, 2), "-|>", stroke: (dash: "dashed")),
    edge((1, 2), (0, 3), "-|>", stroke: (dash: "dashed")),
    edge((0, 3), (0, 4), "-|>", stroke: 1.2pt + blue),
  )
})

如果规定“先完整求出左操作数，再求右操作数，最后计算根”，
求值器就选蓝色实线路线，右边虚线路线不属于这个受限制的一步关系．
这里的策略只限制*何时*用基本规约规则，不改变这套整数运算规则给出的结果．
运算符优先级解决的是怎么解析字符串，不是这里的先后顺序：
语法树已经由括号固定，两条路线没有重新分组，也没有把浮点加法当成可任意结合的运算．

真实语言里，JavaScript、Python 的普通函数调用会先求实参再执行函数体，
通常称为*按值调用*；JavaScript 还规定实参从左到右求值．
Haskell 使用*按需调用*：需要某个参数的值时才计算，并共享这次计算的结果．
例如 Haskell 的 `const` 满足 `const x y = x`，`error` 用于产生错误；
`const 1 (error "boom")` 返回 `1`，因为第二个参数没有用到；
JavaScript 的 `((x, y) => x)(1, (() => { throw new Error("boom"); })())`
会先计算第二个实参而抛错．
两门语言都有明确的策略，但选的是不同路线和停止条件．

有副作用时，连最后的普通数值也可能不同．
设 JavaScript 中 `let n = 0`，`f = () => ++n`，`g = () => n * 10`．
`f() + g()` 按从左到右求值给出 `11`；
若另一门语言规定先算右边，先得到 `g() = 0`，再得到 `f() = 1`，结果就是 `1`．
所以“随便选一条路线”不是无害的实现细节；
#refer("example/incomplete-specifications") 里没写明的顺序必须在规格里补上．

多条路线能否重新汇合，是另一个性质，叫*合流性*．
这里临时把一般规约关系也记成 $stp$，把零步或有限多步记成 $stps$
（正式定义见 #refer("definition/multi-step-reduction")）：
若 $t stps u$ 且 $t stps v$，总存在 $w$，使 $u stps w$ 且 $v stps w$，
就称这个关系合流．
上图展示了可汇合的分叉；只画出这一个例子并没有证明整套关系合流．

合流不要求“下一步唯一”：$u$、$v$ 可以不同，只要求它们之后还可以到达同一项．
若某个项能到达两个正规形式
（不能继续规约的项，正式定义见 #refer("definition/normal-forms-and-stuck-terms")），
合流保证这两个正规形式相同，因为正规形式已经无法再走向第三个不同的项．
若没有合流保证，就不能从“各条路最后都停了”推出结果唯一：
假想规则同时允许某个 $t$ 规约到常量 $0$ 和 $1$，而两个常量都不能再规约，
它们就永远无法汇合．
选择策略可以挑出其中一个，却不消除原关系里的这种分歧．
但合流*不保证终止*，也不保证任意策略都能找到已经存在的正规形式．

*λ 演算*是只用变量、函数抽象和函数应用描述计算的形式系统．
$lambda x. M$ 表示参数为 $x$、函数体为 $M$ 的函数；
$M space N$ 表示把 $M$ 应用到 $N$．
变量出现的位置若受某个 $lambda$ 的参数绑定，称为*绑定出现*；否则称为*自由出现*．
例如 $lambda x. y$ 中参数 $x$ 只规定绑定范围，函数体里的 $y$ 是自由变量．
一般的 *β 规约*允许在任何子项中使用

$ (lambda x. M) space N stp M[N slash x] $

其中 $M[N slash x]$ 表示把 $M$ 中自由出现的 $x$ 替换成 $N$，
必要时先把绑定变量改名，以免意外捕获 $N$ 的自由变量．
β 规约也允许在函数体内部规约，不要求 $N$ 已是值，所以通常有多条路线．
*Church–Rosser 定理*表明，一般 β 规约是合流的
（把只差绑定变量名字的项视为同一个项）．
这里引用这一经典结果而不展开其证明；
它说明一般 β 规约虽然有多条路线，仍不会从同一个项得到两个不同的 β-正规形式．
参见 #enwiki("Church–Rosser_theorem")[Church–Rosser 定理]．

例如 $(lambda x. x) space ((lambda y. y) space z)$ 可以先规约外层，
得到 $(lambda y. y) space z$，也可以先规约实参，得到 $(lambda x. x) space z$；
两边都再规约到 $z$．
但令 $Omega = (lambda x. x space x) space (lambda x. x space x)$，
它一步规约回自己，永远不会算完．
$(lambda x. z) space Omega$ 若先算外层就得到正规形式 $z$，
若坚持先算实参就会在 $Omega$ 上无限规约．
一般 β 规约仍然合流，却不能靠合流保证这条策略终止．

因而要分清三件事：*确定性*管每一步是否唯一，
*合流性*管不同路线能否重新汇合，*终止性*管是否可能一直算下去．
引入确定的规约策略可以把多路线关系限制成可由单后继函数实现的关系，
但它不自动保持所有可达结果；
要声称“最终结果不变”或“总能找到正规形式”，还需要相应的证明．
#refer("definition/one-step-reduction") 的十条求值规则已经规定了策略，
#refer("theorem/determinism") 证明的正是这套规则的确定性．
