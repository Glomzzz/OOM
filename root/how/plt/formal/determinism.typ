#import "/lib/formal.typ": *

#show: formal-page.with(title: [确定性：从推导归纳到求值器])

$stp$ 是“对规则封闭的最小关系”，所以它也有自己的归纳法，和 #refer("theorem/structural-induction") 的道理完全相同：“最小”保证每个成立的 $t stp t'$ 都有一棵由规则搭出来的推导，没有别的来路，所以只要性质能沿着每条规则从前提传到结论，它就对所有推导成立。

#statement("theorem/induction-on-derivations")

直观地说（请对照 #refer("example/reduction-derivation") 的推导树来理解），就是对推导树的高度做归纳，从上往下：叶子（公理）先成立，每往下一层都保持成立。公理没有前提，对应的情形里没有 #refer("definition/induction-hypothesis") 可用；E-If 这类有一个前提的规则，可以对前提对应的子推导使用这个假设。

为什么不总是对项归纳？因为这里已知的是一棵 $t stp t'$ 的推导，要跟踪的性质同时涉及左右两项；按最后用的规则拆解，就能得到前提里的子推导以及左右两边怎样拼成结论。确定性和保型都会用到它。若只试了几条归约链，或只处理无前提的计算规则而漏掉 E-If 等同余规则，就不能覆盖嵌套项；例如内层归约保持类型，并不替你证明外层 $"succ"$ 拼回去以后也保持类型。对推导归纳正是把这个“拼回去”的步骤逐条核实。

在证明确定性之前，要先确认“已经算完的值”确实不能再走一步。这既给求值器一个可靠的停止条件，也用来排除计算规则和同余规则同时适用。若另加 $0 stp 0$ 这样的规则，$0$ 虽仍是语法上指定的值，按“不能再走”判断停止的求值器却会永远循环；后面的确定性证明也不能再用“值不能归约”排除重叠。

#statement("lemma/values-do-not-reduce")

为什么要证明下面的确定性？因为我们准备实现一个一次只返回一个后继项的 `step`。它要忠实于整个一步关系，就必须证明关系不会给同一输入两个不同后继；否则 `match` 的分支顺序可能偷偷选掉另一条合法路线。#refer("note/numeric-value-restriction-in-predecessor-reduction") 会给出放宽一条规则就失去这一保证的具体反例；多路线不必然是语言设计错误，但必须说明是否用策略限制它（#refer("note/evaluation-strategies-reduction-strategies-and-confluence")）。

#statement("theorem/determinism")

这个证明没什么巧思，功夫全花在排除情形上。这正是形式化的用处，下面的附注是一个具体例子。

#statement("note/numeric-value-restriction-in-predecessor-reduction")

= 从关系到函数

#refer("theorem/determinism") 说的是：对每个 $t$，至多有一个 $t'$。因此 $stp$ 对应一个*偏函数*（partial function）：有后继时返回唯一后继，没有后继时无定义。Rust 用 `Option<Term>` 把这种偏函数表示成总会返回的函数，`None` 表示后继不存在。若一步关系有多个后继，函数仍然可以选择其中一个，但必须写明选择的策略；否则它只实现了关系的一部分，却被误说成实现了整个关系。

#statement("note/evaluation-strategies-reduction-strategies-and-confluence")

先把前面的 `Term` 定义重新贴在这里，方便对照：

```rust
#[derive(Clone, Debug, PartialEq, Eq, Hash)]
pub enum Term {
    True, False,
    If(Box<Term>, Box<Term>, Box<Term>),  // if t1 then t2 else t3
    Zero,
    Succ(Box<Term>), Pred(Box<Term>), IsZero(Box<Term>),
}
```

`Term` 没有派生 `Copy`。`Copy` 的意思是“按位复制一份就是合法的副本”，而 `Box` 独占堆上的子树，按位复制会得到两个指向同一块内存、都以为自己负责释放它的指针，所以 Rust 不允许含 `Box` 的类型实现 `Copy`。下面代码里的 `(**a).clone()`、`a.clone()` 就是在显式地深拷贝子树：`a` 的类型是 `&Box<Term>`，`*a` 是 `Box<Term>`，`**a` 是 `Term`。

```rust
/// nv ::= 0 | succ nv
pub fn is_nv(t: &Term) -> bool {
    match t { Term::Zero => true, Term::Succ(t) => is_nv(t), _ => false }
}

/// v ::= true | false | nv
pub fn is_value(t: &Term) -> bool {
    matches!(t, Term::True | Term::False) || is_nv(t)
}

/// t ⟶ t'。返回 None 表示不存在 t'：t 是值，或者受阻了。
pub fn step(t: &Term) -> Option<Term> {
    use Term::*;
    match t {
        If(c, a, b) => match &**c {
            True => Some((**a).clone()),                              // E-IfTrue
            False => Some((**b).clone()),                             // E-IfFalse
            c => Some(If(Box::new(step(c)?), a.clone(), b.clone())),  // E-If
        },
        Succ(t1) => Some(Succ(Box::new(step(t1)?))),                  // E-Succ
        Pred(t1) => match &**t1 {
            Zero => Some(Zero),                                       // E-PredZero
            Succ(n) if is_nv(n) => Some((**n).clone()),               // E-PredSucc
            t1 => Some(Pred(Box::new(step(t1)?))),                    // E-Pred
        },
        IsZero(t1) => match &**t1 {
            Zero => Some(True),                                       // E-IsZeroZero
            Succ(n) if is_nv(n) => Some(False),                       // E-IsZeroSucc
            t1 => Some(IsZero(Box::new(step(t1)?))),                  // E-IsZero
        },
        True | False | Zero => None,                                  // 值不可归约
    }
}
```

每个分支旁边标了它实现的规则。同余规则对应的分支都用到了 `?`，它的作用见下面的附注。

#statement("note/rust-question-mark-operator")

#statement("note/proofs-behind-pattern-matching-order")

#html.nav(class: "chapter-nav", aria-label: "文章导航")[
  #cite("/how/plt/formal/evaluation.typ")[← 求值：用推导规则定义运行]
  #cite("/how/plt/formal/index.typ")[回到形式化入门]
  #cite("/how/plt/formal/normal-forms.typ")[范式、受阻与多步归约 →]
]
