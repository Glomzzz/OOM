#import "/lib/statements.typ": *
#import "/lib/formal-math.typ": *

#let entry = (
  title: [塔斯基的层级],
  date: "2026-10-10",
  author: "Glomzzz",
  parent: "/how/plt/formal/natural-and-formal.typ",
  legacy-id: "fm-ph-tarski",
)

#show: statement-page.with("remark/tarski-language-hierarchy", entry)

“对象语言 / 元语言”这对术语与逻辑学家#wiki("阿尔弗雷德·塔斯基")[塔斯基（Tarski）]1933 年关于“真句子”的定义有关：对象语言 $L$ 的真，要在另一门元语言 $M$ 里定义（见 #link("https://plato.stanford.edu/entries/tarski-truth/")[SEP: Tarski's Truth Definitions]）。按该条目的概括，如果 $L$ 有足够的资源谈论自己的语义，他提出的充分性条件（Convention T）很快导向说谎者悖论（liar paradox，“这句话是假的”）；塔斯基自己的结论是，$L$ 的真定义必须放在一门*实质上更强*的元语言里。

这个结论针对的是语义封闭与真谓词，不能简化成“自指本身有问题”。自指在可计算性与证明论里也是常见的正面工具，后来者还发展出允许一门语言有限度地谈论自身的“反射”（reflection）等做法（这两点是一般背景，未在上述条目中逐一核对）。

程序语言理论中的 #refer("definition/object-language-and-metalanguage") 借用的只是其中的组织方式：被研究的语言和研究它的语言分属两个层次，以便分别说明“语法对象是什么”和“关于它们能证明什么”。这是本文的一种选择，不是对所有形式系统的要求。
