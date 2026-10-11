#import "/lib/statements.typ": *
#import "/lib/formal-math.typ": *

#let entry = (
  title: [两个“可靠”],
  date: "2026-10-10",
  author: "Glomzzz",
  parent: "/how/plt/formal/08-rules-and-algorithms.typ",
  legacy-id: "fm-rm-two-soundness",
)

#show: statement-page.with("note/type-soundness-and-algorithm-soundness", entry)

“可靠”这个词在 PLT 里有两种常见用法，容易混：

- *类型系统相对运行时可靠*：规则说有类型的，运行时不受阻。这就是 #refer("corollary/type-safety")。
- *算法相对规则可靠*：算法说有类型的，规则真能推出来。`type_of` 的这一性质见 #refer("theorem/type-checking-algorithm-soundness")，一般定义见 #refer("definition/soundness-and-completeness")。

两条串起来才是我们真正关心的：*检查器*接受的程序，*运行*时不会受阻。只有一条，链条就是断的；两条的组合见 #refer("corollary/accepted-programs-do-not-get-stuck")。
