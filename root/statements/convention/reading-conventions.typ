#import "/lib/statements.typ": *
#import "/lib/formal-math.typ": *

#let entry = (
  title: [阅读约定],
  date: "2026-10-10",
  author: "Glomzzz",
  parent: "/how/plt/formal/natural-and-formal.typ",
  legacy-id: "fm-reading",
)

#show: statement-page.with("convention/reading-conventions", entry)

这些约定适用于 #cite("/how/plt/formal/index.typ")[形式化入门：从 BNF 到类型安全] 的文章与条目。

- 不需要任何 PLT 背景。需要的只是中学程度的“集合”概念，以及愿意一行一行读下去的耐心。用到的每个概念都会先定义再使用。
- 定义、定理、引理、例、附注、注记等都是可以单独打开的页面；环境名统一用英文，嵌入标题按“环境名 → 编号 → 标题”排列，例如 “Theorem 2.1. 进展”。正文引用只显示环境名与标题，不显示局部编号。
- 证明以 “Proof.” 起头，覆盖全部情形，对称或重复的论证可以合并说明，以 ∎ (Q.E.D.)结尾。第一次读可以跳过证明，只看定理说了什么。
- “注记”方框把文中的概念和哲学、历史上的相关讨论联系起来；其中区分原著概括、教学类比与工程应用，中文概括不充当逐字引文。它们不参与技术证明，跳过不影响主线推理。“附注”方框补充技术细节，比如容易忽略的前提、常见的误解。
- Rust 代码用来展示本文这套规则怎样实现为程序；不表示任意形式规则都能直接转写为算法。不会 Rust 也不影响理解，代码旁边都有注释。
- 主要术语沿用文末所列 Chuigda 译文的说法：term 称“词项”，inference rule 称“推理规则”，rule induction 称“规则归纳法”，context 称“语境”，type soundness 称“类型健全性”。“项”是“词项”的简称，“子项”“闭项”等常用复合词保留；“推导”指规则实例构成的证明，不与“推理规则”混同。
- 目前采用 MathML 呈现公式；需要保留 SVG 排版的公式另附可读文本。页面右上角的 $f$ 按钮可把它们切换为可选择、复制的线性写法；
- 推理规则和推导树的文本分别列出规则名、前提与结论。
- 形式化入门的七个主题末尾附有带提示的练习，可以用来检验理解；
- 标为“扩展”的题目会明确改动哪些规则，其结论不能直接用于 #refer("definition/one-step-reduction") 与  #refer("definition/types-and-typing-judgments") 规定的未扩展语言。
