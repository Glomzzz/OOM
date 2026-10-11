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
- 定义、定理、引理、例、附注、注记等都是可以单独打开的页面；嵌入正文时由 typsite 按当前层级编号，标题前的“\[种类\]”说明它的用途。正文引用不显示随嵌入位置改变的编号，例如 #refer("definition/one-step-reduction")；点击引用，目标已在当前页中时就地展开，否则打开它的独立页面。各种方框的用途与系列的行文习惯，见 #cite("/how/plt/prelude")[序章]。
- 每个证明都写全所有情形，以 ∎ (Q.E.D.)结尾。第一次读可以跳过证明，只看定理说了什么。
- “注记”方框把文中的概念和哲学、历史上的相关讨论联系起来。它们不参与论证，跳过不影响主线推理。“附注”方框补充技术细节，比如容易忽略的前提、常见的误解。网页中的注记与附注默认折叠，点击标题展开。
- Rust 代码只用来说明“规则可以直接变成程序”。不会 Rust 也不影响理解，代码旁边都有注释。
- 形式化入门的七个主题末尾附有练习，题号的第一位表示主题，第二位表示本组题目。先独立作答，再展开提示或参考答案；标为“扩展”的题目会明确改动哪些规则，其结论不能直接用于 #refer("definition/one-step-reduction") 与 #refer("definition/types-and-typing-judgments") 规定的未扩展语言。网页里的整组练习默认折叠，展开后可看到所有题目，再分别展开提示与答案；PDF 中直接显示。
