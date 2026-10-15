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

这些约定适用于 #cite("/how/plt/formal/index.typ")[形式化入门：从 BNF 到类型安全]
的文章与独立条目．

阅读这组文章只需具备中学的“集合”概念，外加愿意逐行核对的耐心；用到的每个概念都会先定义再使用．

文中的定义、定理、引理、推论、例、附注、注记都可以单独打开．
环境名统一用英文，嵌入标题按“环境名 → 编号 → 标题”排列，例如 “Theorem 2.1. 进展”；正文引用只显示条目标题，省略局部编号．
证明以 “Proof.” 起头，覆盖全部情形（对称或重复的论证会合并说明），以 ∎ 结尾．初次阅读可以先跳过证明，看命题说了什么．
“附注”补充容易忽略的前提与常见误解；“注记”把概念与哲学、逻辑史上的相关讨论联系起来，区分原著概括、教学类比与工程应用（中文概括仅作意译，不充当逐字引文），跳过注记不影响主线推理．
各个主题末尾附有带提示与解答的练习；标为“扩展”的题目会明确改动哪些规则，其结论只适用于改动后的系统，不直接用于
#refer("definition/one-step-reduction")
与 #refer("definition/types-and-typing-judgments") 规定的原语言．

Rust 代码用来展示这套规则怎样实现为程序（这门语言的规则恰好能直接写成递归函数，一般规则未必如此）；代码旁附有解释，不熟悉 Rust 也能读懂．
网页中公式优先转为 MathML 呈现，无法直接转换的退回内联 SVG；推导规则和推导树的辅助文本分别给出规则名、前提与结论．

术语译名以#link("https://bananaspace.org/")[香蕉空间]的条目为准，
尚未收录的术语参考 #cite("/how/plt/formal/summary.typ")[总结] 所列的中文译文：
reduction 称“规约”，inference rule 称“推导规则”，
normal form 称“正规形式”，rule induction 称“规则归纳法”，
context 称“语境”，type soundness 称“类型健全性”，term 称“词项”．
“项”是“词项”的简称，“子项”“闭项”等复合词保留；
“推导”指规则实例构成的有限证明树，注意与“推导规则”区分．
完整对照见 #cite("/how/terms.typ")[术语对照]．
