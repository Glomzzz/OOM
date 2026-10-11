#import "/lib/statements.typ": *
#import "/lib/formal-math.typ": *

#let entry = (
  title: [Rust 的 `?` 运算符],
  page-title: "附注：Rust 的 `?` 运算符",
  date: "2026-10-10",
  author: "Glomzzz",
  parent: "/how/plt/formal/04-determinism.typ",
  legacy-id: "fm-rm-question",
)

#show: statement-page.with("note/rust-question-mark-operator", entry)

`Option<T>` 是 Rust 里表示“可能有值、可能没有”的类型，只有两种取值：`Some(x)` 和 `None`。在返回 `Option` 的函数里，表达式 `e?` 的意思是：

- 如果 `e` 是 `Some(x)`，整个 `e?` 的值就是 `x`，继续往下执行；
- 如果 `e` 是 `None`，函数*立刻返回* `None`，后面的代码不再执行。

在 #cite("/how/plt/formal/04-determinism.typ")[Rust 求值器 `step`] 中，`Succ(t1)` 匹配一个后继项，`step(t1)` 返回 `Option<Term>`，表示子项是否存在一步后继。这个分支可以写成两种等价形式：

```rust
// 用 ?
Succ(t1) => Some(Succ(Box::new(step(t1)?))),

// 不用 ?，展开写
Succ(t1) => match step(t1) {
    Some(t1_) => Some(Succ(Box::new(t1_))),
    None => return None,
},
```

例如，读取字符串的首字符，并把 ASCII 小写字母转成大写：

```rust
fn first_char_upper(s: &str) -> Option<char> {
    let c = s.chars().next()?;   // 空字符串时这里直接返回 None
    Some(c.to_ascii_uppercase())
}
assert_eq!(first_char_upper("rust"), Some('R'));
assert_eq!(first_char_upper(""), None);
```

对照 #refer("definition/one-step-reduction") 中的同余规则：E-Succ 说“若 $t_1 stp t_1'$，则 $"succ" t_1 stp "succ" t_1'$”。`step(t1)?` 先去找 $t_1'$，找到了就拿来搭结论；找不到（前提不成立），结论就推不出来，整个函数返回 `None`。这正好是“子项不能归约，整个项也不能沿这条规则归约”。#cite("/how/plt/formal/08-rules-and-algorithms.typ")[类型检查器 `type_of`] 里的 `type_of(t1)?` 也是同样的意思：按照 #refer("definition/types-and-typing-judgments") 的规则，子项没有类型，就无法满足相应构造的定型前提，检查器返回 `None`。
