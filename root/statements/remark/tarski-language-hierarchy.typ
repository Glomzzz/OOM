#import "/lib/statements.typ": *
#import "/lib/formal-math.typ": *

#let entry = (
  title: [塔斯基的层级],
  date: "2026-10-10",
  author: "Glomzzz",
  parent: "/how/plt/formal/01-natural-and-formal.typ",
  legacy-id: "fm-ph-tarski",
)

#show: statement-page.with("remark/tarski-language-hierarchy", entry)

“对象语言 / 元语言”这对术语来自逻辑学家#wiki("阿尔弗雷德·塔斯基")[塔斯基（Tarski）]。1930 年代他研究“真”这个概念时发现，像说谎者悖论（liar paradox，“这句话是假的”）这样的困境，根源在于一门语言试图谈论*自身*句子的真假。他的方案是分层：关于对象语言 $L$ 的句子是否为真，只能在更高一层的元语言里说。

程序语言理论中的 #refer("definition/object-language-and-metalanguage") 采用同样的区分：被研究的语言和研究它的语言分属两个层次。后来者在这基础上发展出了更精细的做法（比如允许一门语言有限度地谈论自身的“反射”（reflection）），但出发点都是先把层次分清。
