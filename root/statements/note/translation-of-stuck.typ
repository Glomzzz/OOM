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

stuck 字面是“卡住”，TAPL 的一些中文译本也这样译。#refer("definition/normal-forms-and-stuck-terms") 采用“受阻”这个译名，理由有两点。第一，“卡住”在日常语言里也指程序“卡死、没反应”，即无限循环或死锁，而 stuck 恰恰*不是*这个意思：受阻的项已经停下来了，只是停错了地方。第二，“受阻”点出了停下来的原因：计算想往前推进，却被一个没有定义的情形挡住了。例如按 #refer("definition/one-step-reduction") 的规则，$"succ" "true"$ 既不是值，也没有可用的归约步骤。英文原名始终写在括号里，读文献时对得上即可。
