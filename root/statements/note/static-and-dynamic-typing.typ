#import "/lib/statements.typ": *
#import "/lib/formal-math.typ": *

#let entry = (
  title: [静态类型与动态类型],
  date: "2026-10-10",
  author: "Glomzzz",
  parent: "/how/plt/formal/type-safety.typ",
  legacy-id: "fm-rm-static-dynamic",
)

#show: statement-page.with("note/static-and-dynamic-typing", entry)

“静态”指不运行程序就能知道的性质，“动态”指运行时才能观察到的性质．
按类型检查发生的时机，程序语言通常分为*静态类型语言*与*动态类型语言*．
静态类型语言在运行前（通常是编译阶段）完成*静态类型检查*，未通过检查的程序会遭拒绝；
Rust、Haskell、OCaml、Java、C 都属此类，
#refer("definition/types-and-typing-judgments") 的类型系统也是如此，$t : T$ 只看项的形状，不执行 #refer("definition/one-step-reduction") 的 $stp$ 规约．
动态类型语言则让程序先运行，每次真正做运算时再检查参与运算的值是否符合要求的种类，不合要求就抛出错误；Python、JavaScript、Ruby 属于这一类．

用 #refer("definition/set-of-terms") 的布尔值与自然数语言作类比，
动态检查的设计可以省去预先构造 $t : T$ 的推导，
直接在 $stp$ 里给不合适的运行时操作补上报错规则
（#refer("note/explicit-errors-and-kotlin-bottom-type")），
把受阻换成可预期的异常；
另一种设计可以采用转换规则
（#refer("example/javascript-coercion-and-equality-triangle")）．
真实语言往往同时有这两类处理；
JavaScript 的条件还会采用真假值转换，不要求参数字面上就是布尔值．

对这门小语言的运算，类型规则、#refer("lemma/canonical-forms")
与 #refer("theorem/preservation") 合起来保证：
参数若要求为 $tN$，求值为值时就一定是数值，所以不必在运行时再检查它是否为布尔值．
这不等于真实静态类型语言可以省掉所有运行时检查；
例如 Kotlin 仍会抛出数组越界异常，Rust 的数组索引也可能需要边界检查．
两者的取舍是：静态检查更早排除它所覆盖的错误，
但会拒绝一些实际运行不会出错的程序（#refer("note/conservative-type-systems")）；
动态检查更灵活，但错误通常要等到运行到那一行才暴露．

静态检查发生在运行前，不等于它能排除所有运行时错误．
C 使用静态类型检查，但这种检查不能排除越界访问、通过悬垂指针访问对象等未定义行为
（参见 #link("https://www.open-std.org/jtc1/sc22/wg14/www/docs/n1570.pdf")[C11 草案 N1570 §6.2.4、§6.5.6]）．
#refer("corollary/type-safety") 证明的“类型安全”，
表达的是这套类型规则相对于操作语义的*类型健全性*，
需要由具体规则及证明支撑，不靠未说明判准的“强类型／弱类型”标签．

延伸阅读可参见 FrankHB 的
#link("https://github.com/FrankHB/pl-docs/blob/master/zh-CN/typing-vs-typechecking.md#%E9%9D%99%E6%80%81%E5%8A%A8%E6%80%81%E7%B1%BB%E5%9E%8B")[类型 vs. 类型检查]．
