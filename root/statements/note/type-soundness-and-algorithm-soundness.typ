#import "/lib/statements.typ": *
#import "/lib/formal-math.typ": *

#let entry = (
  title: [类型健全性与算法可靠性],
  date: "2026-10-10",
  author: "Glomzzz",
  parent: "/how/plt/formal/rules-and-algorithms.typ",
  legacy-id: "fm-rm-two-soundness",
)

#show: statement-page.with("note/type-soundness-and-algorithm-soundness", entry)

英文 soundness 在这组形式化中涉及两种不同的对应．
译名之外，更重要的是写清*谁相对于什么成立*．
*类型健全性*针对*类型规则与操作语义*：类型规则认可的词项，按执行规则运行时不受阻，即 #refer("corollary/type-safety") 中的类型安全性．
*算法可靠性*针对*算法与规则*：检查算法报告的类型判断，确实可以由类型规则推出；
`type_of` 的这一性质见 #refer("theorem/type-checking-algorithm-soundness")，
一般定义见 #refer("definition/soundness-and-completeness")．

两条串起来，才能得到：*检查器*接受的程序，*执行*时不会受阻．
若算法错误地接受了不良类型词项，类型健全性无法替它作保证；
若规则本身不能排除受阻，正确实现这些规则也不足以保证运行安全．
两者的组合见 #refer("corollary/accepted-programs-do-not-get-stuck")．

这里将 type soundness 译作“类型健全性”，而算法相对规则的 soundness 称“可靠性”．
文献可能使用其他译名；阅读时应看清命题连接的是哪两个对象，避免被相同的英文词或中文译名混淆．
