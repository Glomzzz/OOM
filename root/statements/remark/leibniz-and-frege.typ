#import "/lib/statements.typ": *
#import "/lib/formal-math.typ": *

#let entry = (
  title: [Leibniz 与 Frege],
  date: "2026-10-10",
  author: "Glomzzz",
  parent: "/how/plt/formal/natural-and-formal.typ",
  legacy-id: "fm-ph-frege",
)

#show: statement-page.with("remark/leibniz-and-frege", entry)

把思想写成精确符号、使推理能够逐步核对的愿望由来已久．
17 世纪末，#wiki("戈特弗里德·莱布尼茨")[Gottfried Wilhelm Leibniz]
设想过一种“普遍文字”（_characteristica universalis_）
以及配套的“推理演算”（_calculus ratiocinator_）：
思想写成符号，推理变成计算，争论的双方只需说一句“我们来算一算”（_Calculemus_）．

两百年后，#wiki("戈特洛布·弗雷格")[Gottlob Frege] 在 1879 年的
_Begriffsschrift_（《概念文字》）里真正构造了这样一门形式语言，成为现代逻辑的起点之一．
他在序言里指出，日常语言的推理中常有未曾察觉的前提悄悄混入；
他想要的是一条*没有缝隙*的推理链，每一步都看得见依据什么．
#refer("convention/reading-conventions") 也采用了这种证明写法：
每个隐含的前提都尽量摆到台面上．

Leibniz 的设想没有完全实现．
20 世纪的 #wiki("库尔特·哥德尔")[Kurt Gödel] 和 #wiki("艾伦·图灵")[Alan Turing] 证明了，
有些问题原则上不能靠机械计算一劳永逸地裁决．
在程序语言理论中，#refer("definition/one-step-reduction")
与 #refer("definition/types-and-typing-judgments") 用规则精确定义运行和类型，
#refer("corollary/type-safety") 则从这些规则证明良类型程序不受阻，
是这种可核对推理的一个具体例子．
