#import "/lib/statements.typ": *
#import "/lib/formal-math.typ": *

#let entry = (
  title: [为什么要“对 $T$ 一般化”],
  page-title: "附注：为什么要“对 T 一般化”",
  date: "2026-10-10",
  author: "Glomzzz",
  parent: "/how/plt/formal/type-safety.typ",
  legacy-id: "fm-rm-generalize",
)

#show: statement-page.with("note/generalizing-the-type-in-preservation-proofs", entry)

在 #refer("theorem/preservation") 的证明中，E-If 是 #refer("definition/one-step-reduction") 的条件归约规则，类型关系采用 #refer("definition/types-and-typing-judgments")。处理这个情形时，#ih 用在 $t_1$ 上，而 $t_1$ 的类型是 $tB$，不一定是 $t$ 的类型 $T$。如果要证的性质写成"对*这个固定的* $T$，$t' : T$"，#ih 就只能谈论这个 $T$，在这里用不上。所以要证的性质必须写成"对*任意* $T$，若 $t : T$ 则 $t' : T$"。这个细节在自然语言的证明里很容易被略过，#refer("theorem/determinism") 的证明里对 $t''$ 也做了同样的处理。
