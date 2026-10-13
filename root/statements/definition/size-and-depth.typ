#import "/lib/statements.typ": *
#import "/lib/formal-math.typ": *

#let entry = (
  title: [大小与深度],
  date: "2026-10-10",
  author: "Glomzzz",
  parent: "/how/plt/formal/syntax.typ",
  legacy-id: "fm-def-size",
)

#show: statement-page.with("definition/size-and-depth", entry)

对 #refer("definition/set-of-terms") 的有限语法树，
*大小* $op("size")(t)$ 数节点，
*深度* $op("depth")(t)$ 数从根到最远叶子的路径上的边．
两个函数按 #refer("definition/immediate-and-proper-subterms") 的直接子项递归定义：

$
  op("size")("true") = op("size")("false") = op("size")(0) = 1 \
  op("size")("succ" t_1) = op("size")("pred" t_1) = op("size")("iszero" t_1) =
    op("size")(t_1) + 1 \
  op("size")("if" t_1 "then" t_2 "else" t_3) =
    op("size")(t_1) + op("size")(t_2) + op("size")(t_3) + 1
$

深度数的是从根到最远叶子的路径上的*边数*，不是节点数．完整定义为：

$
  op("depth")("true") = op("depth")("false") = op("depth")(0) = 0 \
  op("depth")("succ" t_1) = op("depth")("pred" t_1) = op("depth")("iszero" t_1) =
    op("depth")(t_1) + 1 \
  op("depth")("if" t_1 "then" t_2 "else" t_3) =
    max(op("depth")(t_1), op("depth")(t_2), op("depth")(t_3)) + 1
$

例如 $"pred" ("succ" 0)$ 有三个节点、两条边，所以大小是 $3$，深度是 $2$．
$"if" "true" "then" 0 "else" ("succ" 0)$ 的大小是 $5$，深度也是 $2$：
大小把三个分支都算进去，深度只取最长的那条路径．
