#import "/lib/lib.typ": *
#import "/lib/statements.typ": *

#show: schema.with("page")

#title[序章：怎样读这个系列]
#date[2026-10-11]
#author[Glomzzz]
#parent("/how/plt/index.typ")

这个系列的文章大多是“定义—定理—证明”的写法，夹着例子、代码和一些题外话。不同用途的段落放在不同样式的方框里，读者一眼就能知道这一段在论证里起什么作用、能不能跳过。本章说明每种方框的含义和本系列的行文习惯。后面的方框都是示范。

= 定理环境

#cite("/how/plt/formal/index.typ")[形式化入门]把每个定义、定理等写成独立页面，正文通过 embed 嵌入。嵌入的标题由 typsite 按层级编号，前面的“\[种类\]”和方框颜色说明用途；同一条目在不同父页面中可以有不同编号。正文引用只写“\[种类\] 标题”，不带会随嵌入位置改变的编号。引用目标已在当前页里时就地展开，否则打开它的独立页面。

下面的方框也来自 `root/statements/` 的独立条目，例如 #refer("definition/definition-environment")；陈述、标题和证明都在条目文件本身中，本页只负责嵌入。

#statement("definition/definition-environment")

#statement("theorem/theorem-environment")

#statement("lemma/lemma-environment")

#statement("corollary/corollary-environment")

#statement("example/example-environment")

#statement("convention/convention-environment")

#statement("note/note-environment")

#statement("remark/remark-environment")

= 行文风格

- *先定义再使用*。每个概念在第一次被用到之前都有定义。如果某处用到一个没定义过的词，那是文章的错误。
- *不说“显然”*。“显然”“其余情形类似”是错误最爱藏的地方。证明里所有情形都写出来；确实完全对称的情形，会说明和哪一条对称。
- *说明为什么要证明*。每个定理、引理和推论除了陈述与证明，还会说明它解决什么问题、后文在哪里用到，以及缺少这个保证时会有什么后果。已有解释就不再重复；反例会注明改动了哪条规则，不把另一门语言的例子冒充本文定理的反例。
- *隐含前提摆上台面*。一个论证依赖的前提，即使看起来理所当然，也会被指出来，通常放在附注里。
- *术语给出原名*。中文译名第一次出现时，括号里附英文原名，方便对照文献。人名使用中文译名，第一次出现时链接到维基百科。
- *希腊字母注明读音*。第一次出现的希腊字母会在脚注里给出读音。
- *代码只做说明*。Rust 代码用来展示“规则可以直接变成程序”，旁边会注明它实现的是哪条规则。不会 Rust 不影响理解。
- *自然语言讲解，形式化符号定义*。正文用自然语言解释，但当解释和符号写成的定义有出入时，以定义为准。
