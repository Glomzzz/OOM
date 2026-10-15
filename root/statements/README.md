# 全站独立条目

定义、命题、证明、例子与补充说明统一放在这里，不隶属于某篇讲解文章．
文章只通过 embed 引用条目；同一条目可以在多篇文章里复用．

## 分类与文件名

| 目录 | taxon | 用途 |
| --- | --- | --- |
| `definition/` | Definition | 概念与精确定义 |
| `theorem/` | Theorem | 主要命题及其证明 |
| `lemma/` | Lemma | 辅助命题及其证明 |
| `corollary/` | Corollary | 由已有命题得到的结论及证明 |
| `example/` | Example | 具体实例、推导与反例 |
| `convention/` | Convention | 阅读、记号与证明写法 |
| `note/` | Note | 技术细节与实现说明 |
| `remark/` | Remark | 哲学、逻辑史与相关讨论 |

文件名用**完整英文名称、小写、单词之间用 `-`**，不再使用 `fm-def-ih` 等专栏前缀或缩写，
例如 [`definition/induction-hypothesis.typ`](definition/induction-hypothesis.typ)、
[`theorem/structural-induction.typ`](theorem/structural-induction.typ)、
[`theorem/progress.typ`](theorem/progress.typ)、
[`lemma/canonical-forms.typ`](lemma/canonical-forms.typ)
与 [`corollary/type-safety.typ`](corollary/type-safety.typ)．
目录与文件名合起来就是引用键．不同分类可以有同名条目，如
`definition/type-safety` 与 `corollary/type-safety`，没有冲突．

## 单文件编写

每个条目同时包含**标题、作者／日期、返回页面、陈述及证明**．
没有外置的标题表、计数表或独立证明文件；种类直接从引用键的第一段得出．

以 `root/statements/theorem/progress.typ` 为例：

```typst
#import "/lib/statements.typ": *
#import "/lib/formal-math.typ": * // 本例的数学记号；普通条目不必导入

#let entry = (
  title: [进展],
  date: "2026-10-10",
  author: "Glomzzz",
  parent: "/how/plt/formal/type-safety.typ",
)

#show: statement-page.with("theorem/progress", entry)

若 $t : T$，则 $t$ 是值，或存在 $t'$ 使 $t stp t'$．

#proof[
  这里写完整证明，引用所用的定义与引理．
]
```

使用某套项、值、规约或类型规则时，在正文中通过 `refer` 明确指出对应定义；
定理注明自己针对哪套规则成立，不把“这门语言”留给父文章解释．
使用 `step`、`type_of` 等具体实现时，通过 `cite` 链接实现所在的文章，
并说明函数的输入、输出或所用分支；`parent` 返回链接不能替代正文中的依赖说明．
条目的显示标题直接来自 `entry.title`，证明用 `proof` 包裹（以 `Proof.` 起头、以 ∎ 结束），
Note 与 Remark 默认折叠，其他条目默认展开；
若标题含复杂数学或代码，可在 `entry` 中补充纯文字 `page-title`，
`entry.legacy-id` 则仅用于兼容迁移前的 `#fm-*`／`#pl-*` 锚点．

条目正文不使用“本文”“上文”“后文”“下一节”等指向原文章位置的说法，
也不把“与本文无关”这类写作过程备注带进条目；
“下面两段代码”“上图”“第 2 条”等指代的对象必须确实在当前条目内，
若指向其他条目或文章则给出明确链接．
新增解释不改变规则、证明前提或结论的适用范围，扩展语言的例子须说明修改了哪些规则．

## 在文章或其他条目中复用

```typst
#import "/lib/statements.typ": *

#statement("definition/induction-hypothesis") // 嵌入完整定义
#statement("theorem/progress")               // 嵌入命题及证明
根据 #refer("theorem/progress")，下一步存在或当前项已经是值．
```

`statement` 输出原生 typsite embed，编号由当前父页面的层级决定．
标题顺序为 `taxon → heading-numbering → title`，例如 `Theorem 2.1. 进展`；未编号时显示 `Theorem. 进展`．
环境名统一用英文，正文标题和解释仍可用中文．彩色卡片按 taxon 区分种类，不改变正文颜色．
`refer` 只显示 `进展` 这样的条目标题，不带 taxon 前缀或局部编号，并从目标页面读取元数据．
HTML 引用不 import 目标正文，因此前向、后向和相互引用不会引起循环 import．
JavaScript 只增强就地跳转：目标已嵌入则展开它，否则打开其独立页面；无 JS 时链接仍可用．
PDF include 同一份条目正文，查询已嵌入目标的元数据；独立 PDF 未包含目标时只读取它导出的 `entry`．

共享接口在 [`../lib/statements.typ`](../lib/statements.typ)．
形式化入门的十篇讲解文章仍在 [`../how/plt/formal/`](../how/plt/formal/)．
现有条目包含 80 个正文条目．
旧 `/how/plt/formal/statements/fm-*` 独立网址不再保留跳转页．
