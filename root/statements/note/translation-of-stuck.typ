#import "/lib/statements.typ": *
#import "/lib/formal-math.typ": *

#let entry = (
  title: [“受阻”的译名],
  date: "2026-10-10",
  author: "Glomzzz",
  parent: "/how/plt/formal/normal-forms.typ",
  legacy-id: "fm-rm-stuck-name",
)

#show: statement-page.with("note/translation-of-stuck", entry)

英文 stuck 字面是“卡住”，_Types and Programming Languages_ 的一些中文译本也这样译．
#refer("definition/normal-forms-and-stuck-terms") 采用“受阻”这个译名，主要出于两方面考虑．
日常语言里的“卡住”常指程序“卡死、无响应”，容易让人联想到无限循环；
而这里的受阻恰恰相反，项已经没有后继，同时又不属于值，停在了不合法的终点．
在包含并发或阻塞操作的语言中，哪些状态算受阻，还取决于转移规则和许可终态的定义；
死锁也可能表现为非终态且无后继，不能笼统地说它与 stuck 无关．
此外，“受阻”直接点出了停下来的原因：计算想往前推进，却遇到没有定义的情形而无法继续．
例如按 #refer("definition/one-step-reduction") 的规则，
$"succ" "true"$ 不属于值，也没有可用的规约步骤．
英文原名可对照 #cite("/how/terms.typ")[术语对照] 检索．
