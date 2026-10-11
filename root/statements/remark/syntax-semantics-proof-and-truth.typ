#import "/lib/statements.typ": *
#import "/lib/formal-math.typ": *

#let entry = (
  title: [语法与语义，证明与真],
  date: "2026-10-10",
  author: "Glomzzz",
  parent: "/how/plt/formal/08-rules-and-algorithms.typ",
  legacy-id: "fm-ph-soundness",
)

#show: statement-page.with("remark/syntax-semantics-proof-and-truth", entry)

逻辑学里也有一对“可靠 / 完备”：一个证明系统是*可靠*的，如果能证明的都是真的；是*完备*的，如果真的都能证明。哥德尔 1929 年证明一阶逻辑的证明系统是完备的；两年后的不完备定理则说，足够强的算术理论里，总有真而不可证的命题。

#refer("definition/soundness-and-completeness") 描述的类型检查算法与类型规则之间的关系，与此平行：`type_of` 扮演“机械的证明过程”，类型规则扮演“什么才算对”的标准。差别在于，这里的标准本身也是一组规则，而且足够简单，两个方向分别由 #refer("theorem/type-checking-algorithm-soundness") 与 #refer("theorem/type-checking-algorithm-completeness") 证明。语言再大一些，“完备”就常常要附加条件，甚至干脆不成立，设计者必须决定放弃哪一边。
