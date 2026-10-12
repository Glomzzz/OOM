#import "/lib/statements.typ": *
#import "/lib/formal-math.typ": *

#let entry = (
  title: [为什么译作“受阻”],
  date: "2026-10-10",
  author: "Glomzzz",
  parent: "/how/plt/formal/normal-forms.typ",
  legacy-id: "fm-rm-stuck-name",
)

#show: statement-page.with("note/translation-of-stuck", entry)

stuck 字面是“卡住”，TAPL 的一些中文译本也这样译。#refer("definition/normal-forms-and-stuck-terms") 采用“受阻”这个译名，理由有两点。第一，“卡住”在日常语言里也指程序“卡死、没反应”，容易让人想到无限循环；而这里的受阻不是无限循环：项已经没有后继，却也不是值，停在了不被许可的终点。在包含并发或阻塞操作的语言中，哪些状态算受阻，还取决于转移规则和许可终态的定义；死锁也可能表现为非终态且无后继，不能一般性地说它与 stuck 无关。第二，“受阻”点出了停下来的原因：计算想往前推进，却被一个没有定义的情形挡住了。例如按 #refer("definition/one-step-reduction") 的规则，$"succ" "true"$ 既不是值，也没有可用的归约步骤。英文原名始终写在括号里，读文献时对得上即可。
