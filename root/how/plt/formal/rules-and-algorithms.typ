#import "/lib/formal.typ": *

#show: formal-page.with(title: [规则与算法：可靠性与完备性])

= 规则不是程序

#refer("definition/types-and-typing-judgments") 定义的是一个*关系*：哪些 $(t, T)$ 有推导。它没有告诉我们*怎么找*推导。真正写出来的类型检查器是一个*函数*：

```rust
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum Type { Bool, Nat }

/// 类型检查算法：返回 Some(T) 表示“t 的类型是 T”，None 表示拒绝。
pub fn type_of(t: &Term) -> Option<Type> {
    use Term::*;
    match t {
        True | False => Some(Type::Bool),                  // T-True / T-False
        Zero => Some(Type::Nat),                           // T-Zero
        Succ(t1) | Pred(t1) => {                           // T-Succ / T-Pred
            (type_of(t1)? == Type::Nat).then_some(Type::Nat)
        }
        IsZero(t1) => {                                    // T-IsZero
            (type_of(t1)? == Type::Nat).then_some(Type::Bool)
        }
        If(c, a, b) => {                                   // T-If
            let ta = type_of(a)?;
            (type_of(c)? == Type::Bool && type_of(b)? == ta).then_some(ta)
        }
    }
}
```

`x.then_some(y)` 的意思是“条件 `x` 成立就返回 `Some(y)`，否则返回 `None`”。

这个函数和规则之间隔着一道缝。写代码的人会觉得“显然一样”，可这正是 #refer("example/incomplete-specifications") 之后一直在提防的那个词。比如有人把 `If` 分支写成只检查 `a`、不检查 `b`，大多数手写测试照样能过。要把“一样”说清楚，得拆成两个方向。

#statement("definition/soundness-and-completeness")

可靠说算法*不乱接受*，完备说算法*不乱拒绝*。两者合起来，算法恰好*判定*了这个关系。

#statement("note/type-soundness-and-algorithm-soundness")

= 证明

先确认一个隐含前提：`type_of` 对每个输入都会返回，不会无限递归。它是结构递归（每次递归调用的参数都是 #refer("definition/immediate-and-proper-subterms") 中的直接子项），由 #refer("definition/size-and-depth") 后面那段讨论，这样的函数总会终止。

首先证明可靠性，因为类型安全定理说的是“规则能推出类型的项”，不是“某个函数返回 `Some` 的项”。若检查器在 `If` 分支里忽略 else 分支，就可能接受 $"succ" ("if" "false" "then" 0 "else" "true")$；程序下一步变成受阻的 $"succ" "true"$。类型规则本身没有错，错的是算法冒称规则已接受它。下面的定理就是防止这种“假阳性”。

#statement("theorem/type-checking-algorithm-soundness")

可靠性还不够描述“忠实实现规则”：一个对所有输入都返回 `None` 的检查器也是可靠的，却连 $0$ 都不接受。完备性排除这种“假阴性”，保证规则认可的程序不会被实现漏掉。例如把 T-Pred 对应的代码分支误写成直接返回 `None`，不会放进坏程序，却会冤枉 $"pred" 0$ 这样的合法程序；下面这条定理能发现它。

#statement("theorem/type-checking-algorithm-completeness")

两个证明各自只有几行，但方向不同、归纳的对象也不同：可靠性跟着*算法*走（对项归纳，因为算法按项递归），完备性跟着*推导*走（对推导归纳，因为前提给的是推导）。

最后要把两个不同的保证接起来：算法符合类型规则，类型规则又与运行规则协调。少了第一段，错误检查器可能乱接受；少了第二段，类型系统可能认可运行时受阻的项。这个端到端结论才是使用者真正需要的“检查通过以后能相信什么”，也说明只证明某个局部函数正确不足以替整条链作保证。

#statement("corollary/accepted-programs-do-not-get-stuck")

这一条就是 #refer("note/type-soundness-and-algorithm-soundness") 说的那条完整的链。完备性没有出现在这里：因为完备性保证的是检查器“不冤枉好程序”，而非“安全”。

= 为什么这里这么顺利

这一节的证明顺利，靠的是 #refer("lemma/typing-inversion") 依赖的那个性质：规则是语法导向的，而且每条规则前提里出现的类型，都能从子项算出来。T-If 里的 $T$ 由 $t_2$ 算出，然后*拿来比较* $t_3$，没有哪一步需要凭空猜一个类型。

#statement("note/turning-rules-into-algorithms")

#statement("remark/syntax-semantics-proof-and-truth")

= 练习：规则与算法

#exercise-group(4)[
  #exercise(
    "6.1",
    [可靠与完备守的是不同方向],
    hint: [按照 #refer("definition/soundness-and-completeness") 对具体的返回类型作判断，不要把“返回了某个类型”混同于“返回了规则给出的类型”。],
    answer: [
      对所有输入返回 `None` 的 A 是可靠的：可靠性的前提从不成立；但它不完备，因为 $0 : tN$ 却被拒绝。

      对所有输入返回 `Some(Nat)` 的 B 既不可靠也不完备。它为 $"true"$ 报告 $tN$，规则只能给出 $tB$，所以不可靠；$"true" : tB$ 成立却没有返回 `Some(Bool)`，所以也不完备。它还会接受根本没有类型的 $"succ" "true"$。

      C 只接受三个常量并返回它们正确的类型，其余返回 `None`。它可靠，但不完备：$"pred" 0 : tN$ 就是被漏掉的合法项。可靠性允许少接受，完备性不允许漏掉规则认可的判断。
    ],
  )[
    三个终止的检查器分别这样实现：A 总返回 `None`；B 总返回 `Some(Nat)`；C 只接受 $"true"$、$"false"$、$0$ 并返回正确类型，其余返回 `None`。判断每个检查器相对原类型规则是否可靠、完备；凡不成立的方向，都给出反例。
  ]

  #exercise(
    "6.2",
    [漏掉条件种类的检查],
    hint: [让两个分支都是 $0$，却把条件也写成 $0$；再区分放进坏项与漏掉好项。],
    answer: [
      错误检查器会给 $"if" 0 "then" 0 "else" 0$ 返回 `Some(Nat)`：两个分支相同，条件也能得到某个类型，所以三个调用都成功。但 T-If 要求条件为 $tB$，$0$ 只能为 $tN$，因此这个项没有类型，算法可靠性失效；运行时它也受阻。

      修复是恢复条件种类的比较：
      ```rust
      If(c, a, b) => {
          let ta = type_of(a)?;
          (type_of(c)? == Type::Bool && type_of(b)? == ta).then_some(ta)
      }
      ```

      这处遗漏本身不会破坏完备性：对原规则认可的项，条件确实为 `Bool`，修改前后的检查都会通过；对子项按推导归纳，仍得到正确的输出类型。但“好项仍被接受”不抵消“坏项也被接受”。
    ],
  )[
    若 `type_of` 的 `If` 分支写成下面这样，其余分支不变，找出一个错误接受的项，指出漏了 T-If 的哪个前提，并修复代码。这个修改是否也必然破坏完备性？

    ```rust
    If(c, a, b) => {
        let ta = type_of(a)?;
        type_of(c)?;
        (type_of(b)? == ta).then_some(ta)
    }
    ```
  ]

  #exercise(
    "6.3",
    [检查顺序不同，会改变程序的运行吗？],
    hint: [本文的 `type_of` 没有副作用，总会终止，失败只返回 `None`。它的调用顺序不是对象语言的求值顺序。],
    answer: [
      可以在保持全部条件检查的前提下，先检查条件，再检查两个分支。例如：
      ```rust
      If(c, a, b) => {
          if type_of(c)? != Type::Bool { return None; }
          let ta = type_of(a)?;
          (type_of(b)? == ta).then_some(ta)
      }
      ```

      原版与此版恰好都要求：条件为 `Bool`、两个分支都有类型且相等。每次调用都终止且没有副作用，所以最终 `Some(T)` 或 `None` 相同。条件不合适时，此版只是更早返回 `None`。

      这不会改变 `step` 的顺序：检查器在元语言中分析整个项，求值器则按对象语言的 E-规则运行。若检查器改成返回详细错误，检查顺序可能改变首先报告哪个错误；那是诊断接口的额外行为，不是本文 `Option<Type>` 结果的区别。
    ],
  )[
    本文 `type_of` 在 `If` 分支先检查 then 分支。能否改成先检查条件，同时保持接受的项与输出类型不变？给出代码并论证。这样的改动会不会让对象语言先运行 then 分支？
  ]

  #exercise(
    "6.4",
    [实现一个带期望类型的检查接口],
    hint: [不必新增类型规则；比较 `type_of` 的结果与 `Some(expected)`，然后分别使用算法可靠与完备。],
    answer: [
      ```rust
      pub fn check(t: &Term, expected: Type) -> bool {
          type_of(t) == Some(expected)
      }
      ```

      若 `check(t, T)` 为真，`type_of(t)` 等于 `Some(T)`，由 #refer("theorem/type-checking-algorithm-soundness") 得 $t : T$。若 $t : T$，由 #refer("theorem/type-checking-algorithm-completeness") 得 `type_of(t) = Some(T)`，比较为真。两方向合起来就是 `check(t, T) = true` 当且仅当 $t : T$。∎

      `type_of` 结构递归并终止，最后一次类型比较也终止，所以 `check` 终止。`check(true, Bool)` 为真，`check(true, Nat)` 为假，`check(pred 0, Nat)` 为真；没有类型的 $"succ" "true"$ 对两个期望类型都返回假。这只是原算法的接口包装，没有增加一种对象语言的判断或求值策略。
    ],
  )[
    写出 `check(t, expected) -> bool`，使它当且仅当原规则能推出 $t : T$ 时返回真，其中 `expected` 对应 $T$。证明两个方向及终止性，给出成功、期望类型不符和项本身不良类型三个例子。
  ]

]

#html.nav(class: "chapter-nav", aria-label: "文章导航")[
  #cite("/how/plt/formal/type-safety.typ")[← 类型安全：典范形式、进展与保型]
  #cite("/how/plt/formal/index.typ")[回到形式化入门]
  #cite("/how/plt/formal/test-and-proof.typ")[用测试对照证明 →]
]
