#import "/lib/statements.typ": *
#import "/lib/formal-math.typ": *
#import "/lib/formal-html.typ" as html

#let entry = (
  title: [类型检查、类型推理与类型居留性],
  date: "2026-10-12",
  author: "Glomzzz",
  parent: "/how/plt/formal/rules-and-algorithms.typ",
)

#show: statement-page.with("note/type-what-so-many", entry)

固定一套类型规则和语境 $Gamma$，考虑类型判断 $Gamma tack.r t : T$．
$Gamma$ 记录变量的类型假设，记号见 #refer("definition/types-and-typing-judgments")．
三种问题的区别在于*给定什么*、*要找什么*，不是另换三套类型规则：

#html.div(style: "overflow-x: auto;", table(
  columns: 3,
  [*问题*], [*给定*], [*要回答或寻找的内容*],
  [*类型检查*], [$Gamma$、项 $t$、类型 $T$], [判断 $Gamma tack.r t : T$ 是否可推导．],
  [*类型推理*（也称类型推断）],
  [$Gamma$、项 $t$],
  [找出某个 $T$，使 $Gamma tack.r t : T$；没有这样的类型则报告失败．],
  [*类型居留性*],
  [$Gamma$、类型 $T$],
  [判断是否存在某个项 $t$，使 $Gamma tack.r t : T$．若存在，$t$ 称为该类型的*居留者*．],
))

把 #refer("definition/well-typed-terms") 的良类型定义写成带语境的形式，
问的就是：*固定词项，是否存在类型*，即 $exists T. Gamma tack.r t : T$．
居留性问的是：*固定类型，是否存在词项*，即 $exists t. Gamma tack.r t : T$．
不要把两个存在量词的位置看反：
推理找的是类型，不是程序；
居留性判定只需回答有无，若还要返回一个居留者，就进一步成了构造词项的问题．

例如，采用 #refer("definition/types-and-typing-judgments") 的七条规则：

- 检查给定的 $"pred" 0 : tN$，答案是成立；
  检查同一个项的 $"pred" 0 : tB$，答案是不成立．
- 推理给定项 $"pred" 0$ 的类型，得到 $tN$，不要求调用者先给出这个类型．
- 判断 $tN$ 是否可居留，$0 : tN$ 提供了见证；
  判断 $tB$ 是否可居留，$"true" : tB$ 提供了见证．
  这两种类型都可居留，却不意味着每个项都有类型：$"succ" "true"$ 仍然不良类型．

#cite("/how/plt/formal/rules-and-algorithms.typ")[Rust 算法 `type_of(t) -> Option<Type>`]
按输入与输出划分是*推理接口*：给它词项，它返回类型．
它也常广义地叫作“类型检查器”，因为它同时判定项是否良类型．
带期望类型的检查接口则是 `check(t, expected) -> bool`．
在这套规则下，可以用 `type_of(t) == Some(expected)` 实现它；
这依赖 #refer("theorem/uniqueness-of-types")，
以及算法相对规则的 #refer("theorem/type-checking-algorithm-soundness")
与 #refer("theorem/type-checking-algorithm-completeness")．
实际的检查器也可以交替使用检查与推理；
接口的区分，不要求实现拆成两套互不相干的算法．

*常见误区*

+ *“检查失败，就说明这个项没有任何类型．”*
  检查针对的是某个*给定类型*．
  $"pred" 0 : tB$ 不成立，只排除了 $tB$；这个项仍有类型 $tN$．
  要说它不良类型，必须排除*所有*可能的类型，不能把“不是期望的类型”说成“没有类型”．

+ *“推理器没有给出类型，就证明规则里不存在类型．”*
  把算法的拒绝解释成“规则无法定型”，需要相对规则的完备性．
  在 #refer("note/unexamined-assumptions") 的实现假设下，
  这里的 `type_of` 终止且相对规则完备，所以正常返回 `None` 确实表示项不良类型；
  但在其他系统中，推理器可能只支持规则的一个子集，或要求额外标注．
  缺少标注、超时、资源不足或搜索尚未结束，都不能直接当作无类型的证明．

+ *“类型推理就是运行程序，看看结果是什么类型；不写标注就是动态类型．”*
  这套算术语言的推理按项的语法和类型规则分析，不执行 $stp$ 来观察结果．
  静态类型系统也可以推理出省略的类型标注；
  检查与推理的区别在于是否给定期望类型，
  静态与动态的区别则在于检查何时发生，见 #refer("note/static-and-dynamic-typing")．

+ *“推理返回的就是唯一类型，检查时比较相等总是够用．”*
  唯一性是这套规则已经证明的性质，不是“类型推理”这个词自带的保证．
  例如，若在七条规则外增加“由 $t : tN$ 推出 $t : tB$”的转换规则，
  $0$ 就同时具有这两个类型．
  只返回 $tN$ 再与期望的 $tB$ 比较，会误拒绝在*扩展规则*下成立的判断．
  带子类型或多态的系统可能需要子类型判定、实例化等步骤；
  若还要求推理返回最一般的*主类型*，也必须另行定义“更一般”，并证明主类型存在．

+ *“能检查或推理，就能判定类型居留性；几个候选都失败，就说明类型不可居留．”*
  检查、推理已经拿到了项，居留性却要问是否存在*任何*合适的项．
  否定单个候选不能否定存在性；
  候选可能有无穷多个，只靠逐一枚举、检查，也未必能在没有居留者时停下来回答“没有”．
  反过来，这也不说明居留性总是不可判定：这套算术语言的两个类型都有现成见证．
  三种问题是否可判定，要针对具体系统分别论证．

+ *“语境中能找到居留者，就已经找到了不依赖假设的程序．”*
  在含变量的语言中，若 $Gamma$ 已有 $x : T$，变量 $x$ 就可在这个语境中居留 $T$；
  去掉该假设后，判断未必仍成立．
  没有另外指定语境时，说“$T$ 可居留”通常指存在*闭项* $t$（没有自由变量），使 $tack.r t : T$．
  #refer("definition/set-of-terms") 的算术语言没有变量，所有词项都是闭项，因此这里取空语境．

+ *“有居留者，就有一个正常的值，而且程序一定能算出它．”*
  这里的居留者是*具有类型的项*，不要求它已经是值．
  在允许一般递归或异常的语言中，项有类型也可能永远循环或异常退出，
  不能据此断言会正常返回该类型的值．
  相应地，“底类型没有正常值”不等于“没有表达式能具有底类型”，
  具体例子见 #refer("note/explicit-errors-and-kotlin-bottom-type")．
