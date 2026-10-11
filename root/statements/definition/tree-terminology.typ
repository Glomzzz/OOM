#import "/lib/statements.typ": *
#import "/lib/formal-math.typ": *

#let entry = (
  title: [树的基本术语],
  date: "2026-10-10",
  author: "Glomzzz",
  parent: "/how/plt/formal/natural-and-formal.typ",
  legacy-id: "fm-def-tree",
)

#show: statement-page.with("definition/tree-terminology", entry)

这里约定的*树*（tree）是由*节点*（node）和连接节点的*边*（edge）组成的有限结构，有一个指定的*根*（root）。除根以外，每个节点恰有一个*父节点*（parent）；从根沿父子方向走到任意节点的路径唯一，不会绕回原处。每个节点可以带一个符号作为标签。

- 一条边连接父节点与它的*子节点*（child），也叫“孩子”。同一父节点的孩子有顺序，因此这是*有序树*；例如 #refer("definition/set-of-terms") 中条件、then 分支、else 分支的位置不能互换。
- 没有孩子的节点称为*叶子*（leaf）；至少有一个孩子的节点称为*内部节点*（internal node）。根也可能是叶子：只有一个节点的树就是如此。
- 从某个节点沿父子方向走一步或多步能到达的节点，叫它的*后代*（descendant）。以一个节点为根，连同它的所有后代和连接它们的边，构成一棵*子树*（subtree）。整棵树也算以原根为根的子树；排除它自己时，称为真子树。

例如表示 $"pred" ("succ" 0)$ 的树有三个节点。根标着 $"pred"$，它的孩子标着 $"succ"$，后者的孩子标着 $0$。前两个是内部节点，$0$ 是叶子；以 $"succ"$ 为根的子树表示 $"succ" 0$。这里“子节点”指一个节点，“子树”指从那个节点开始的整块结构。
