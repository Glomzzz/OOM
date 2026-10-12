#import "/lib/formal.typ": *

#show: formal-page.with(title: [确定性：从规则归纳到求值器])

$stp$ 是对规则封闭的最小关系，因此具有*规则归纳法*（rule induction）。它与 #refer("theorem/structural-induction") 的依据相同：每个可推导的 $t stp t'$ 都来自有限次规则应用；只要待证性质在无前提的规则上成立，并能由每条规则的前提传到结论，就对所有可推导的转移成立。

#statement("theorem/induction-on-derivations")

直观地说，规则归纳就是对*推导树*的结构或高度归纳，请对照 #refer("example/reduction-derivation") 理解。公理对应没有前提的叶子，是基准情况，没有 #refer("definition/induction-hypothesis") 可用；E-If 这类带前提的规则对应归纳情况，可以对前提的子推导使用归纳假设，再证明当前结论的性质。

为什么不总是对项归纳？因为这里已知的是一棵 $t stp t'$ 的推导，要跟踪的性质同时涉及左右两项；按最后用的规则拆解，就能得到前提里的子推导以及左右两边怎样拼成结论。确定性和保型都会用到它。若只试了几条归约链，或只处理无前提的基本归约规则而漏掉 E-If 等结构规则，就不能覆盖嵌套项；例如内层归约保持类型，并不替你证明外层 $"succ"$ 拼回去以后也保持类型。规则归纳正是把这个“拼回去”的步骤逐条核实。

在证明确定性之前，要先确认“已经算完的值”确实不能再走一步。这既给求值器一个可靠的停止条件，也用来排除基本归约规则和结构规则同时适用。若另加 $0 stp 0$ 这样的规则，$0$ 虽仍是语法上指定的值，按“不能再走”判断停止的求值器却会永远循环；后面的确定性证明也不能再用“值不能归约”排除重叠。

#statement("lemma/values-do-not-reduce")

为什么要证明下面的确定性？因为我们准备实现一个一次只返回一个后继项的 `step`。它要完整实现一步归约关系，就必须证明关系不会给同一输入两个不同后继；否则 `match` 的分支顺序可能偷偷选掉另一条合法路线。#refer("note/numeric-value-restriction-in-predecessor-reduction") 会给出放宽一条规则就失去这一保证的具体反例；多路线不必然是语言设计错误，但必须说明是否用策略限制它（#refer("note/evaluation-strategies-reduction-strategies-and-confluence")）。

#statement("theorem/determinism")

这个证明没什么巧思，功夫全花在排除情形上。这正是形式化的用处，下面的附注是一个具体例子。

#statement("note/numeric-value-restriction-in-predecessor-reduction")

= 从关系到函数

#refer("theorem/determinism") 说的是：对每个词项 $t$，至多有一个一步后继 $t'$。因此 $stp$ 对应一个*偏函数*（partial function）：有后继时返回唯一后继，没有后继时无定义。用 Rust 实现时，可以把返回类型改成 `Option<Term>`，以 `None` 显式表示没有后继。这样能把数学上的偏函数扩充为词项到可选结果的*全函数*（total function），但前提是它对每个输入都终止；仅有这个返回类型并不保证终止。下面的 `step` 及 `is_nv` 都沿直接子项递归，克隆也只处理有限子树，所以在 #refer("note/unexamined-assumptions") 的资源与基础操作假设下会正常返回。若一步关系有多个后继，函数仍然可以选择其中一个，但必须写明选择的策略；否则它只实现了关系的一部分，却被误说成实现了整个关系。

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

每个分支旁边标了它实现的规则。结构规则对应的分支都用到了 `?`，它的作用见下面的附注。

#statement("note/rust-question-mark-operator")

确定性说明关系至多有一个后继，但还没有说明 `step` 返回的就是这个后继。下面的定理把两者接上：函数返回的每个后继都能由规则推出，规则允许的每个后继函数也都能返回。

#statement("theorem/evaluator-faithfulness")

#statement("note/proofs-behind-pattern-matching-order")

#html.nav(class: "chapter-nav", aria-label: "文章导航")[
  #cite("/how/plt/formal/evaluation.typ")[← 求值：用推理规则定义运行]
  #cite("/how/plt/formal/index.typ")[回到形式化入门]
  #cite("/how/plt/formal/normal-forms.typ")[范式、受阻与多步归约 →]
]
