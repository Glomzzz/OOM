#import "/lib/statements.typ": *
#import "/lib/formal-math.typ": *

#let entry = (
  title: [可靠与完备],
  date: "2026-10-10",
  author: "Glomzzz",
  parent: "/how/plt/formal/rules-and-algorithms.typ",
  legacy-id: "fm-def-sound-complete",
)

#show: statement-page.with("definition/soundness-and-completeness", entry)

以 #refer("definition/types-and-typing-judgments") 的关系 $t : T$ 为规格，
以 #cite("/how/plt/formal/rules-and-algorithms.typ")[Rust 类型检查算法 `type_of`] 为实现．
在 #refer("note/unexamined-assumptions") 的实现假设下，
正常返回 `Some(T)` 表示算法报告类型 $T$，`None` 表示拒绝；
Rust 的 `Bool`、`Nat` 分别对应对象语言的 $tB$、$tN$．

若 `type_of(t) = Some(T)` 蕴涵 $t : T$，则称算法相对规则*可靠*；
若 $t : T$ 蕴涵 `type_of(t) = Some(T)`，则称算法相对规则*完备*．
