#import "/lib/statements.typ": *
#import "/lib/formal-math.typ": *

#let entry = (
  title: [类型系统是保守的],
  date: "2026-10-10",
  author: "Glomzzz",
  parent: "/how/plt/formal/typing.typ",
  legacy-id: "fm-rm-conservative",
)

#show: statement-page.with("note/conservative-type-systems", entry)

按 #refer("definition/one-step-reduction") 的 E-IfTrue，
$"if" "true" "then" 0 "else" "false"$ 一步就得到值 $0$，不会受阻；
但 #refer("definition/types-and-typing-judgments") 无法给它赋予类型，
因为 T-If 要求两个分支类型相同．
*这套类型规则*相对于“求值不会受阻”是保守的：它拒绝了一些能够正常求值的项．
#refer("corollary/type-safety") 只保证良类型的项不受阻，没有保证逆方向．

这里的保守性不能仅由“不运行程序”推出．
#refer("definition/set-of-terms")、#refer("definition/one-step-reduction")
规定的算术语言中，每一步都使大小严格下降
（#refer("lemma/reduction-decreases-size")），
而 #refer("theorem/evaluator-faithfulness") 保证 `step` 恰好实现一步关系．
因此，原则上可以反复规约任意输入，到达唯一正规形式后检查它是否为值，
精确判定求值是否受阻；也可以把这一计算放在编译期．
这个数学算法不会无限等待，但它直接依赖求值分析，已经脱离了原来的七条类型规则；
实际 Rust 执行仍采用 #refer("note/unexamined-assumptions") 的资源与基础操作假设．

选择当前的语法导向类型系统，是另一种取舍：
它按子项的类型组合出整项的类型，不必先求出条件的真假；
两个分支具有同一类型，也让分支选择后容易证明保型．
它对原类型关系是否可靠、完备，与它是否接受所有能正常求值的项，是两个不同的问题．
含有一般递归的语言会遇到另外的判定限制，
不能拿那些限制代替对这门有限、终止语言的分析．
