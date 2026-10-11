#import "/lib/formal.typ": *

#show: formal-page.with(
  title: [形式化入门：从 BNF 到类型安全],
  parent: "/how/plt/index.typ",
)

研究程序语言时，我们关心的问题往往很朴素：这段程序会算出什么？它会不会在运行时崩溃？编译器说它“没有类型错误”，这句话能信吗？这些问题本身都能用自然语言问出来。可一旦想*确定地*回答它们，自然语言就不够用了。

这组文章做两件事。前半部分解释*为什么*要换一种语言来谈论程序语言，后半部分用一门很小的语言（布尔值加自然数），从零开始把这种“新语言”的用法完整演示一遍，这个过程叫*形式化*（formalization）：怎样定义语法，怎样定义“运行”，怎样定义“类型”，最后怎样*证明*“通过类型检查的程序不会卡住”。

这里按阅读顺序嵌入十篇子文章。第一次读可以依次展开，也可以点击标题旁的短链接单独打开。定义、定理等方框同样是独立页面，颜色与标题前的“\[种类\]”标明用途；引用不显示编号，已嵌入的目标会在当前页展开，未嵌入的目标则在独立页面打开。

这条路线依次经过自然语言与元语言、语法、求值、确定性、范式与受阻、类型、类型安全、检查算法与测试。练习仍按原来的七个主题编号，整组、提示与答案默认折叠。

#chapter("01-natural-and-formal.typ", open: true)

#chapter("02-syntax.typ")

#chapter("03-evaluation.typ")

#chapter("04-determinism.typ")

#chapter("05-normal-forms.typ")

#chapter("06-typing.typ")

#chapter("07-type-safety.typ")

#chapter("08-rules-and-algorithms.typ")

#chapter("09-test-and-proof.typ")

#chapter("10-summary.typ")
