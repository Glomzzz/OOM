#import "/lib/statements.typ": *
#import "/lib/formal-math.typ": *

#let entails = symbol("⊨")

#let entry = (
  title: [语法与语义，证明与真],
  date: "2026-10-10",
  author: "Glomzzz",
  parent: "/how/plt/formal/rules-and-algorithms.typ",
  legacy-id: "fm-ph-soundness",
)

#show: statement-page.with("remark/syntax-semantics-proof-and-truth", entry)

逻辑学里也有一对“可靠／完备”，但要先说明“真”在哪些模型中成立．
设 $Gamma$ 是一组一阶句子，$phi$ 是单个句子：
$Gamma tack.r phi$ 表示能从这些前提形式地推出 $phi$；
$Gamma entails phi$ 表示*每个满足 $Gamma$ 的模型也满足 $phi$*．
证明系统的两个方向是：

$
  Gamma tack.r phi & => Gamma entails phi quad "（可靠性）" \
  Gamma entails phi & => Gamma tack.r phi quad "（完备性）"
$

两者合起来就是 $Gamma entails phi <=> Gamma tack.r phi$．
#wiki("库尔特·哥德尔")[Kurt Gödel] 在 1929 年的博士论文中证明了经典一阶逻辑的完备性；
这里针对的是所有模型中的语义后承（区别于某个特定预期模型中的全部真命题）．
定义与定理可参见
#link("https://leanprover-community.github.io/logic_and_proof/semantics_of_first_order_logic.html#soundness-and-completeness")[_Logic and Proof_ §10.5]．

1931 年的不完备定理讨论的是另一个问题．
采用后来 #enwiki("J._Barkley_Rosser")[J. Barkley Rosser] 改进的表述：
*一致、可有效公理化且具有足够初等算术能力*的理论，不能决定其语言中的每个句子，
即存在某个句子，它与它的否定都不能在该理论中证明．
若说“真而不可证”，这里的“真”指标准自然数模型，“不可证”则相对于指定理论；
这并不代表绝对不可证明，一阶逻辑也并未漏掉在所有模型中成立的结论．
原始 Gödel 版本与 Rosser 版本的前提不同，参见
#link("https://plato.stanford.edu/entries/goedel-incompleteness/")[SEP: Gödel's Incompleteness Theorems]．
还要区分*完备性*与*可判定性*：
语义后承都有证明，不等于存在对每个输入都能停机并回答成立与否的算法．

#refer("definition/soundness-and-completeness") 描述的类型检查算法与类型规则之间的关系，
只在“两个方向的对应”上与此平行：`type_of` 是机械的求解过程，类型规则是规格，
比较的双方是算法与规则（一阶逻辑完备性比较的则是形式证明与模型中的真）．
#refer("theorem/type-checking-algorithm-soundness")
与 #refer("theorem/type-checking-algorithm-completeness") 分别证明两个方向，
再加上算法的终止性，才得到判定过程．
更大的类型系统可能需要额外标注、约束求解或受限制的算法；
哪些保证能够保留，要针对具体规则另行论证．
