#import "/lib/statements.typ": *
#import "/lib/formal-math.typ": *

#let entry = (
  title: [归纳证明的写法],
  date: "2026-10-10",
  author: "Glomzzz",
  parent: "/how/plt/formal/syntax.typ",
  legacy-id: "fm-conv-ind",
)

#show: statement-page.with("convention/writing-inductive-proofs", entry)

写“对 $t$ 结构归纳”时，意思是应用 #refer("theorem/structural-induction")：
按项的形状逐个情形讨论，每个情形里可以对
#refer("definition/immediate-and-proper-subterms") 所列的直接子项使用
#refer("definition/induction-hypothesis")．
采用 #refer("theorem/induction-on-derivations") 作规则归纳时，
更小对象则是规则前提对应的子推导，不是任意看起来有关的项．
