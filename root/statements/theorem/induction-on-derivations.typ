#import "/lib/statements.typ": *
#import "/lib/formal-math.typ": *

#let entry = (
  title: [规则归纳法],
  date: "2026-10-10",
  author: "Glomzzz",
  parent: "/how/plt/formal/determinism.typ",
  legacy-id: "fm-thm-rule-ind",
)

#show: statement-page.with("theorem/induction-on-derivations", entry)

设 $P(t, t')$ 是关于一对词项的性质．
若对 #refer("definition/one-step-reduction") 的每条规则实例，
假定前提中的各个转移都满足 $P$ 后，能够证明结论中的转移也满足 $P$，
则 $P$ 对所有可推导的 $t stp t'$ 成立．

无前提的规则是基准情况，须直接验证其结论满足 $P$；
有前提的规则是归纳情况，可对前提的子推导使用归纳假设．
这就是*规则归纳法*，也可理解为对有限推导树作结构归纳，
其归纳对象是整条可推导的转移判断 $t stp t'$．

#proof[
  令 $R = {(t, t') mid(|) t stp t' "且" P(t, t')}$．
  假设恰好说明 $R$ 对十条规则封闭．
  $stp$ 是对规则封闭的最小关系，所以 $stp subset.eq R$．
]
