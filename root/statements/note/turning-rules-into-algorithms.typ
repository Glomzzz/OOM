#import "/lib/statements.typ": *
#import "/lib/formal-math.typ": *

#let entry = (
  title: [从规则到算法的条件],
  date: "2026-10-10",
  author: "Glomzzz",
  parent: "/how/plt/formal/rules-and-algorithms.typ",
  legacy-id: "fm-rm-guess",
)

#show: statement-page.with("note/turning-rules-into-algorithms", entry)

类型判断首先由逻辑规则规定，不能仅凭规则写成了横线上下的形式，
就断言存在可判定的检查算法．
把判断用作算法规范时，须说明哪些量是输入、哪些量是输出，以及输出怎样求得．

例如，对没有参数类型标注的 $lambda x. t$
（记号见 #refer("note/evaluation-strategies-reduction-strategies-and-confluence")），
若想仅从词项推理其类型，参数 $x$ 的类型不能直接从语法中读取；
把函数抽象规则直接照抄为递归分支，就留下了“该填哪个类型”的问题．
那个系统未必不可判定，只是需要补充类型标注、约束求解或从期望类型传入信息等额外设计；
带标注的 $lambda x : T. t$ 则已经在词项中给出了参数类型．

#refer("definition/types-and-typing-judgments") 的布尔值与自然数语言避开了这一问题：
候选规则由语法形状确定，所需类型可由子项算出．
但其算法仍要证明终止性，以及相对规则的可靠性和完备性；
精确定义一个关系与给出判定它的程序，是两项不同的工作．
