#import "/lib/statements.typ": *
#import "/lib/formal-math.typ": *

#let entry = (
  title: [显式错误规则与 Kotlin 的底类型],
  date: "2026-10-10",
  author: "Glomzzz",
  parent: "/how/plt/formal/03-evaluation.typ",
  legacy-id: "fm-rm-errors-bottom",
)

#show: statement-page.with("note/explicit-errors-and-kotlin-bottom-type", entry)

以 #refer("definition/set-of-terms") 的语法和 #refer("definition/one-step-reduction") 的十条求值规则为基础，可以另行加入错误项 $"wrong"$，并规定错误传播。以下讨论的是这门*扩展语言*，不把新增规则当作未扩展语言的规则。只写 $"succ" "true" stp "wrong"$ 还不完整：还要处理 $"succ" "false"$、$"pred" "true"$、非布尔条件，以及嵌套位置里的错误。

记 $b$ 为 $"true"$ 或 $"false"$，$#nv$ 为 #refer("definition/values-and-numeric-values") 中的数值。可以补上这些错误规则，其中 $"op"$ 分别取 $"succ"$、$"pred"$、$"iszero"$：

#rules(
  rule("E-OpBool", $"op" b stp "wrong"$),
  rule("E-IfNat", $"if" #nv "then" t_2 "else" t_3 stp "wrong"$),
  rule("E-OpWrong", $"op" "wrong" stp "wrong"$),
  rule("E-IfWrong", $"if" "wrong" "then" t_2 "else" t_3 stp "wrong"$),
)

原同余规则继续向正在求值的子项走。于是 $"succ" ("if" "true" "then" "false" "else" 0)$ 先归约到 $"succ" "false"$，再归约到 $"wrong"$；$"pred" ("succ" "true")$ 先变成 $"pred" "wrong"$，再向外传播成 $"wrong"$。$"wrong"$ 本身不再归约，应被识别为一种*异常终点*，而非原来定义的普通值。未选中的分支仍不会求值，例如 $"if" "true" "then" 0 "else" "wrong"$ 得到 $0$，不能不分位置地把整项都传播成错误。

Kotlin 可以显式写出这种异常控制流：

```kotlin
fun succ(x: Any): Int = when (x) {
    is Int -> x + 1
    else -> throw IllegalArgumentException("succ expects an Int")
}

fun fail(message: String): Nothing =
    throw IllegalArgumentException(message)

fun requireNat(n: Int): Int =
    if (n >= 0) n else fail("negative number")

// succ(true) 会抛出异常；requireNat(-1) 也会抛出异常。
// 这里借用 Kotlin 的 Int 演示错误处理，不把机器整数当作无界自然数。
```

`requireNat` 的 else 分支为什么能放在需要 `Int` 的位置？`fail(...)` 的类型是 `Nothing`，表示它*不会正常返回一个值*。Kotlin 的 #link("https://kotlinlang.org/spec/type-system.html#kotlin.nothing-typesystem")[类型系统规格]把 `Nothing` 定义成*底类型*（bottom type），通常写作 $bot$、读作 bottom。它是任何类型的*子类型*（subtype），即 $bot <: T$ 对任意 $T$ 成立。这里 $S <: T$ 的意思是：$S$ 类型的表达式可以放进要求 $T$ 类型的上下文。因此不返回的失败分支可以和返回 `Int` 的成功分支放在同一个 `if` 里。

必须区分三个对象：$"wrong"$ 是对象语言里的错误*项*，`IllegalArgumentException` 是 Kotlin 的异常*对象*，$bot$ 是描述表达式不会正常产出值的*类型*。异常对象本身不是 `Nothing`；`Nothing` 没有正常的值，也不是 `null`（`Nothing?` 是另一回事）。抛异常的表达式可以具有底类型，永远循环的表达式也可以不返回，所以不能把“错误”与 $bot$ 当作同义词。

仅仅补上运行时错误规则，不会自动得到这样的子类型系统。若把显式异常加入 #refer("definition/types-and-typing-judgments") 的定型系统，也必须写明异常如何定型，并相应重述 #refer("theorem/progress") 与 #refer("theorem/preservation")；不能直接套用未扩展语言的证明就声称“良类型程序永不抛异常”。#refer("corollary/type-safety") 采用的则是未扩展语言：不加入错误项，让类型规则排除受阻。
