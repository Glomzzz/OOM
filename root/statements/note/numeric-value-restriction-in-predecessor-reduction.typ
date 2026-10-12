#import "/lib/statements.typ": *
#import "/lib/formal-math.typ": *

#let entry = (
  title: [为什么 E-PredSucc 要求 $#nv$],
  // 数学标题另给纯文字版本，浏览器标题不解析 nv 的数学结构。
  page-title: "Note. 为什么 E-PredSucc 要求 nv",
  date: "2026-10-10",
  author: "Glomzzz",
  parent: "/how/plt/formal/determinism.typ",
  legacy-id: "fm-rm-predsucc",
)

#show: statement-page.with("note/numeric-value-restriction-in-predecessor-reduction", entry)

#refer("definition/one-step-reduction") 的 E-PredSucc 规则左边写的是 $"pred" ("succ" #nv)$，只允许 $"succ"$ 里面是 #refer("definition/values-and-numeric-values") 中的*数值*。看起来也可以放宽成任意项：

#bigmath($ #rule("E-PredSucc'", $"pred" ("succ" t) stp t$) $, scale: 120%)

毕竟“先加一再减一”就是原来的数，何必等里面算完？问题在于，放宽以后同一个项会有*两种*归约方式。取 $t = "pred" ("succ" ("pred" 0))$：

- 用放宽后的规则，直接把外层的 $"pred" ("succ" dots)$ 消掉：$t stp "pred" 0$；
- 用 E-Pred 和 E-Succ 两条同余规则往里找，在最里面用 E-PredZero：$t stp "pred" ("succ" 0)$。

两个结果不一样，#refer("theorem/determinism") 就不再成立。在证明里，这表现为 E-PredSucc 那个情形写不下去：要排除第二个推导是 E-Pred，需要“$"succ" t$ 不能归约”，而 $t$ 不一定是值，这一点推不出来。

这个例子里两条路最后都会到达 $0$，所以*这个项*的最终结果没有变，但一步关系已不再确定。仅凭这个例子还不能断言整个扩展语言的所有最终结果都不变，那需要另外的证明。我们仍可以写一个按某种策略选后继的函数，但它实现的是受策略限制后的关系，不能再声称它枚举了原关系的全部一步结果（见 #refer("note/evaluation-strategies-reduction-strategies-and-confluence")）。这个决定是被证明逼出来的：证明写不下去时，要么调整设计，要么调整所要保证的性质，不能把缺口当作已经证明。#cite("/how/plt/formal/test-and-proof.typ")[用测试对照证明] 所述的确定性测试也抓到了放宽后的反例。
