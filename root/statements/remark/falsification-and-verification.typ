#import "/lib/statements.typ": *
#import "/lib/formal-math.typ": *

#let entry = (
  title: [证伪与证实],
  date: "2026-10-10",
  author: "Glomzzz",
  parent: "/how/plt/formal/test-and-proof.typ",
  legacy-id: "fm-ph-popper",
)

#show: statement-page.with("remark/falsification-and-verification", entry)

#wiki("卡尔·波普尔")[波普尔（Popper）]认为，经验科学里的普遍命题无法被有限次观察*证实*，只能被一次反例*证伪*。测试也有这样的边界：一万个通过的样本不能证实“所有良类型程序都不受阻”。要反驳 #refer("corollary/type-safety")，反例必须同时满足：

$ tack.r t : T, quad t stps u, quad op("stuck")(u). $

其中前两个判断必须能由 #refer("definition/types-and-typing-judgments") 与 #refer("definition/multi-step-reduction") 的正式规则推出，受阻按 #refer("definition/normal-forms-and-stuck-terms") 判断。单独找到受阻项不够，例如 $"succ" "true"$ 本来就不良类型。错误 Rust 实现产生的受阻状态，可能反驳的是实现与规则的对应，而非原规则的类型安全。

证明则走另一条路。它不观察，而是从定义出发推出结论，所以可以对无穷多个程序负责。代价是它只对*定义*负责：如果规则本身没有描述我们心里想的那门语言，证明再严密也帮不上忙。这说明了证明与测试的分工：证明管“从规则到结论”，测试和实现管“规则是不是我们想要的”。#refer("corollary/type-safety") 与 #cite("/how/plt/formal/test-and-proof.typ")[用测试对照证明] 分别给出了这两种工作的例子。
