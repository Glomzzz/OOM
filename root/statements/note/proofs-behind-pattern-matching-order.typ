#import "/lib/statements.typ": *
#import "/lib/formal-math.typ": *

#let entry = (
  title: [分支顺序里藏着证明],
  date: "2026-10-10",
  author: "Glomzzz",
  parent: "/how/plt/formal/determinism.typ",
  legacy-id: "fm-rm-order",
)

#show: statement-page.with("note/proofs-behind-pattern-matching-order", entry)

#cite("/how/plt/formal/determinism.typ")[Rust 求值器 `step`]
用模式匹配实现 #refer("definition/one-step-reduction") 的规则．
`match` 按书写顺序尝试分支；
要说明这种优先级没有漏掉合法后继，不能只说“函数每次返回一个结果”．

#refer("theorem/determinism") 保证的是*后继唯一*，不是*适用的规则唯一*．
例如另加一条名字不同、结论也为 $"pred" 0 stp 0$ 的规则，
两条规则就同时适用，却没有产生不同的后继．

对于原来的十条规则，互斥性要靠具体排除论证：
条件是 $"true"$ 或 $"false"$ 时，由 #refer("lemma/values-do-not-reduce")，E-If 的前提不成立；
$"pred"$ 的参数是 $0$ 或 $"succ" #nv$ 时，参数也是值，
E-Pred 的前提不成立，两个计算形状又彼此不同；
$"iszero"$ 的情形相同．
参数能规约时，反过来排除这些计算形状．
这些正是确定性证明中用到的逐形状分析，但不只是确定性结论本身．

因此，代码先列计算分支、再列递归分支，不会把另一条适用的规则藏起来．
分支内部是否返回了正确的项，还要由 #refer("theorem/evaluator-faithfulness") 的双向对应保证．
若放宽 E-PredSucc 的数值限制，排除论证就失效，单后继函数只能另外选择策略，
见 #refer("note/numeric-value-restriction-in-predecessor-reduction")．
