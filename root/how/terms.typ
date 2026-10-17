#import "/lib/lib.typ": *
#import "/lib/statements.typ": refer, statement-term

#show: schema.with("page")

#title[术语对照]
#metacontent("description")[寻径系列文章所用术语的英文、中文译名及对应定义或陈述条目．]
#date[2026-10-14]
#author[Glomzzz]
#parent("/how/index.typ")
#heading-numbering("none")

本页按英文字母顺序列出 PLT 系列文章使用的*术语*及其中文译名．
每个英文术语都是小节标题，可在右侧目录（Contents）中直接检索与跳转；
设有独立条目的术语，点击中文译名可前往对应的定义或陈述条目．

译名以#link("https://bananaspace.org/")[香蕉空间]的条目为准，
例如“规约”“推导规则”“正规形式”“语境”“合流性”“依值类型”；
香蕉空间尚未收录的，参考 #cite("/how/plt/formal/summary.typ")[总结]
中“延伸阅读”所列的中文译文．

= A

== A-normal form

中文译名：*A-正规形式*．

== abstract syntax

中文译名：#statement-term("convention/abstract-syntax")[*抽象语法*]（见 #refer("convention/abstract-syntax")）．

== actual infinity

中文译名：#statement-term("remark/potential-and-actual-infinity")[*实无穷*]（见 #refer("remark/potential-and-actual-infinity")）．

== affine type

中文译名：*仿射类型*．

== algebraic data type

中文译名：*代数数据类型*．

== algebraic effect

中文译名：*代数作用*．

== algebraic effect handler

中文译名：*代数作用处理器*．

== algorithm soundness

中文译名：#statement-term("definition/soundness-and-completeness")[*算法可靠性*]（见 #refer("definition/soundness-and-completeness")）．

== asynchronous programming

中文译名：*异步编程*．

== axiom

中文译名：*公理*．


= B

== Backus–Naur form

中文译名：*Backus–Naur 表示法*．

== base case

中文译名：*基准情况*．

== beta reduction

中文译名：#statement-term("note/evaluation-strategies-reduction-strategies-and-confluence")[*β 规约*]（见 #refer("note/evaluation-strategies-reduction-strategies-and-confluence")）．

== bidirectional type checking

中文译名：*双向类型检查*．

== big-step operational semantics

中文译名：*大步操作语义*．

== binary relation

中文译名：*二元关系*．

== binding power

中文译名：*结合力*．

== bottom type

中文译名：#statement-term("note/explicit-errors-and-kotlin-bottom-type")[*底类型*]（见 #refer("note/explicit-errors-and-kotlin-bottom-type")）．

== bound occurrence

中文译名：#statement-term("note/evaluation-strategies-reduction-strategies-and-confluence")[*绑定出现*]（见 #refer("note/evaluation-strategies-reduction-strategies-and-confluence")）．


= C

== call-by-name

中文译名：*按名调用*．

== call-by-need

中文译名：#statement-term("note/evaluation-strategies-reduction-strategies-and-confluence")[*按需调用*]（见 #refer("note/evaluation-strategies-reduction-strategies-and-confluence")）．

== call-by-value

中文译名：#statement-term("note/evaluation-strategies-reduction-strategies-and-confluence")[*按值调用*]（见 #refer("note/evaluation-strategies-reduction-strategies-and-confluence")）．

== cancellation safety

中文译名：#statement-term("note/cancellation-safety-and-async-cleanup")[*取消安全性*]（见 #refer("note/cancellation-safety-and-async-cleanup")）．

== canonical form

中文译名：#statement-term("lemma/canonical-forms")[*典范形式*]（见 #refer("lemma/canonical-forms")）．

== case analysis

中文译名：#statement-term("theorem/determinism")[*分类讨论*]（见 #refer("theorem/determinism")）．

== child

中文译名：#statement-term("definition/tree-terminology")[*子节点*]（见 #refer("definition/tree-terminology")）．

== circular reasoning

中文译名：#statement-term("example/induction-hypotheses-and-circular-reasoning")[*循环论证*]（见 #refer("example/induction-hypotheses-and-circular-reasoning")）．

== closed term

中文译名：#statement-term("note/type-what-so-many")[*闭项*]（见 #refer("note/type-what-so-many")）．

== closure conditions

中文译名：#statement-term("definition/set-of-terms")[*封闭条件*]（见 #refer("definition/set-of-terms")）．

== coinduction

中文译名：#statement-term("note/meaning-of-induction")[*余归纳*]（见 #refer("note/meaning-of-induction")）．

== compile-time error

中文译名：*编译期错误*．

== complete

中文译名：#statement-term("definition/soundness-and-completeness")[*完备*]（见 #refer("definition/soundness-and-completeness")）．

== completeness

中文译名：#statement-term("definition/soundness-and-completeness")[*完备性*]（见 #refer("definition/soundness-and-completeness")）．

== compositionality

中文译名：*组合性*．

== computation rule

中文译名：*计算规则*．

== conclusion

中文译名：*结论*．

== confluence

中文译名：#statement-term("note/evaluation-strategies-reduction-strategies-and-confluence")[*合流性*]（见 #refer("note/evaluation-strategies-reduction-strategies-and-confluence")）．

== congruence rule

中文译名：*同余规则*．

== constructor

中文译名：*构造子*．

== context

中文译名：#statement-term("definition/types-and-typing-judgments")[*语境*]（见 #refer("definition/types-and-typing-judgments")）．

== contextual semantics

中文译名：*语境语义*．

== continuation-passing style

中文译名：*续延传递风格*．

== contraction rule

中文译名：*收缩规则*．

== cooperative scheduling

中文译名：*协作式调度*．

== corecursion

中文译名：#statement-term("note/meaning-of-induction")[*共递归*]（见 #refer("note/meaning-of-induction")）．


= D

== decidable

中文译名：*可判定*．

== deduction

中文译名：#statement-term("note/meaning-of-induction")[*演绎推理*]（见 #refer("note/meaning-of-induction")）．

== delimited continuation

中文译名：*定界续延*．

== denotational semantics

中文译名：*指称语义*．

== dependent type

中文译名：*依值类型*．

== depth

中文译名：#statement-term("definition/size-and-depth")[*深度*]（见 #refer("definition/size-and-depth")）．

== derivation

中文译名：*推导*．

== derivation tree

中文译名：*推导树*．

== descendant

中文译名：#statement-term("definition/tree-terminology")[*后代*]（见 #refer("definition/tree-terminology")）．

== desugaring

中文译名：*脱糖*．

== determinism

中文译名：#statement-term("theorem/determinism")[*确定性*]（见 #refer("theorem/determinism")）．

== drop guarantee

中文译名：#statement-term("definition/pinned-typestate")[*析构保证*]（见 #refer("definition/pinned-typestate")）．

== dynamically typed

中文译名：#statement-term("note/static-and-dynamic-typing")[*动态类型语言*]（见 #refer("note/static-and-dynamic-typing")）．


= E

== edge

中文译名：#statement-term("definition/tree-terminology")[*边*]（见 #refer("definition/tree-terminology")）．

== effect

中文译名：*作用*．

== effect row

中文译名：*作用行*．

== effect system

中文译名：*作用系统*．

== evaluation context

中文译名：*求值语境*．

== evaluation relation

中文译名：*求值关系*．

== evaluation strategy

中文译名：#statement-term("note/evaluation-strategies-reduction-strategies-and-confluence")[*求值策略*]（见 #refer("note/evaluation-strategies-reduction-strategies-and-confluence")）．

== evaluator faithfulness

中文译名：#statement-term("theorem/evaluator-faithfulness")[*求值器与一步规约一致*]（见 #refer("theorem/evaluator-faithfulness")）．

== executor

中文译名：*执行器*．

== extremal clause

中文译名：#statement-term("definition/set-of-terms")[*最小性子句*]（见 #refer("definition/set-of-terms")）．


= F

== first-class continuation

中文译名：*一等续延*．

== formal grammar

中文译名：*形式文法*．

== formalization

中文译名：*形式化*．

== free occurrence

中文译名：#statement-term("note/evaluation-strategies-reduction-strategies-and-confluence")[*自由出现*]（见 #refer("note/evaluation-strategies-reduction-strategies-and-confluence")）．


= G

== generalized algebraic data type

中文译名：*广义代数数据类型*．

== grammar

中文译名：*文法*．

== green thread

中文译名：#statement-term("note/green-threads-and-stack-management")[*绿色线程*]（见 #refer("note/green-threads-and-stack-management")）．


= H

== higher-kinded type

中文译名：*高阶类型构造子*．

== higher-rank type

中文译名：*高秩多态类型*．

== hygiene

中文译名：*卫生性*．


= I

== ill-typed

中文译名：#statement-term("definition/well-typed-terms")[*不良类型*]（见 #refer("definition/well-typed-terms")）．

== immediate subterm

中文译名：#statement-term("definition/immediate-and-proper-subterms")[*直接子项*]（见 #refer("definition/immediate-and-proper-subterms")）．

== induction hypothesis

中文译名：#statement-term("definition/induction-hypothesis")[*归纳假设*]（见 #refer("definition/induction-hypothesis")）．

== induction on derivations

中文译名：#statement-term("theorem/induction-on-derivations")[*推导上的归纳*]（见 #refer("theorem/induction-on-derivations")）．

== inductive case

中文译名：*归纳情况*．

== inductive type

中文译名：*归纳类型*．

== inference rule

中文译名：*推导规则*．

== inhabitant

中文译名：#statement-term("note/type-what-so-many")[*居留者*]（见 #refer("note/type-what-so-many")）．

== instance

中文译名：#statement-term("convention/metavariables")[*实例*]（见 #refer("convention/metavariables")）．

== intermediate representation

中文译名：*中间表示*．

== internal node

中文译名：#statement-term("definition/tree-terminology")[*内部节点*]（见 #refer("definition/tree-terminology")）．

== inversion

中文译名：#statement-term("lemma/typing-inversion")[*反演*]（见 #refer("lemma/typing-inversion")）．


= J

== judgement

中文译名：#statement-term("convention/reading-the-reduction-arrow")[*判断*]（见 #refer("convention/reading-the-reduction-arrow")）．


= L

== lambda calculus

中文译名：#statement-term("note/evaluation-strategies-reduction-strategies-and-confluence")[*λ 演算*]（见 #refer("note/evaluation-strategies-reduction-strategies-and-confluence")）．

== leaf

中文译名：#statement-term("definition/tree-terminology")[*叶子*]（见 #refer("definition/tree-terminology")）．

== least

中文译名：#statement-term("definition/set-of-terms")[*最小*]（见 #refer("definition/set-of-terms")）．

== linear type

中文译名：*线性类型*．

== loose equality

中文译名：#statement-term("example/javascript-coercion-and-equality-triangle")[*宽松相等*]（见 #refer("example/javascript-coercion-and-equality-triangle")）．


= M

== metalanguage

中文译名：#statement-term("definition/object-language-and-metalanguage")[*元语言*]（见 #refer("definition/object-language-and-metalanguage")）．

== metavariable

中文译名：#statement-term("convention/metavariables")[*元变量*]（见 #refer("convention/metavariables")）．

== monad

中文译名：*单子*．

== monomorphization

中文译名：*单态化*．

== multi-step reduction

中文译名：#statement-term("definition/multi-step-reduction")[*多步规约*]（见 #refer("definition/multi-step-reduction")）．


= N

== natural deduction

中文译名：*自然演绎*．

== natural language

中文译名：*自然语言*．

== natural semantics

中文译名：*自然语义*．

== node

中文译名：#statement-term("definition/tree-terminology")[*节点*]（见 #refer("definition/tree-terminology")）．

== nonterminal

中文译名：*非终结符号*．

== normal form

中文译名：#statement-term("definition/normal-forms-and-stuck-terms")[*正规形式*]（见 #refer("definition/normal-forms-and-stuck-terms")）．

== numeric value

中文译名：#statement-term("definition/values-and-numeric-values")[*数值*]（见 #refer("definition/values-and-numeric-values")）．


= O

== object language

中文译名：#statement-term("definition/object-language-and-metalanguage")[*对象语言*]（见 #refer("definition/object-language-and-metalanguage")）．

== offside rule

中文译名：*缩进与换行规则*．

== one-step reduction

中文译名：#statement-term("definition/one-step-reduction")[*一步规约*]（见 #refer("definition/one-step-reduction")）．

== operational semantics

中文译名：*操作语义*．

== ordered tree

中文译名：#statement-term("definition/tree-terminology")[*有序树*]（见 #refer("definition/tree-terminology")）．


= P

== parent

中文译名：#statement-term("definition/tree-terminology")[*父节点*]（见 #refer("definition/tree-terminology")）．

== parsing

中文译名：#statement-term("convention/abstract-syntax")[*解析*]（见 #refer("convention/abstract-syntax")）．

== partial application

中文译名：*部分应用*．

== partial evaluation

中文译名：*部分求值*．

== partial function

中文译名：*偏函数*．

== pattern matching

中文译名：*模式匹配*．

== pinned typestate

中文译名：#statement-term("definition/pinned-typestate")[*固定类型状态*]（见 #refer("definition/pinned-typestate")）．

== pinning

中文译名：#statement-term("definition/pinned-typestate")[*地址固定*]（见 #refer("definition/pinned-typestate")）．

== poll

中文译名：*轮询*．

== potential infinity

中文译名：#statement-term("remark/potential-and-actual-infinity")[*潜无穷*]（见 #refer("remark/potential-and-actual-infinity")）．

== predecessor

中文译名：*前驱*．

== preemptive scheduling

中文译名：*抢占式调度*．

== premise

中文译名：*前提*．

== preservation

中文译名：#statement-term("theorem/preservation")[*保型*]（见 #refer("theorem/preservation")）．

== principal type

中文译名：#statement-term("note/type-what-so-many")[*主类型*]（见 #refer("note/type-what-so-many")）．

== production

中文译名：*产生式*．

== productivity

中文译名：#statement-term("note/meaning-of-induction")[*生产性*]（见 #refer("note/meaning-of-induction")）．

== programming language semantics

中文译名：*程序语言语义学*．

== programming language theory

中文译名：*程序语言理论*．

== progress

中文译名：#statement-term("theorem/progress")[*进展*]（见 #refer("theorem/progress")）．

== proper subterm

中文译名：#statement-term("definition/immediate-and-proper-subterms")[*真子项*]（见 #refer("definition/immediate-and-proper-subterms")）．

== pull-based model

中文译名：*拉取模型*．

== push-based model

中文译名：*推送模型*．


= R

== reactor

中文译名：*反应器*．

== redex

中文译名：*可规约项*．

== reducible expression

中文译名：*可规约表达式*．

== reduction

中文译名：#statement-term("definition/one-step-reduction")[*规约*]（见 #refer("definition/one-step-reduction")）．

== reduction rule

中文译名：*规约规则*．

== reduction semantics

中文译名：*规约语义*．

== reduction strategy

中文译名：#statement-term("note/evaluation-strategies-reduction-strategies-and-confluence")[*规约策略*]（见 #refer("note/evaluation-strategies-reduction-strategies-and-confluence")）．

== refinement type

中文译名：*精化类型*．

== register

中文译名：#statement-term("remark/registers-of-rust-and-control-flow-effects")[*语域*]（见 #refer("remark/registers-of-rust-and-control-flow-effects")）．

== reflexive transitive closure

中文译名：#statement-term("definition/multi-step-reduction")[*自反传递闭包*]（见 #refer("definition/multi-step-reduction")）．

== reflexivity

中文译名：#statement-term("example/javascript-coercion-and-equality-triangle")[*自反性*]（见 #refer("example/javascript-coercion-and-equality-triangle")）．

== rewriting

中文译名：#statement-term("note/evaluation-strategies-reduction-strategies-and-confluence")[*重写*]（见 #refer("note/evaluation-strategies-reduction-strategies-and-confluence")）．

== root

中文译名：#statement-term("definition/tree-terminology")[*根*]（见 #refer("definition/tree-terminology")）．

== rule induction

中文译名：#statement-term("theorem/induction-on-derivations")[*规则归纳法*]（见 #refer("theorem/induction-on-derivations")）．

== runtime

中文译名：*运行时*．

== runtime error

中文译名：*运行时错误*．


= S

== segmented stack

中文译名：#statement-term("note/green-threads-and-stack-management")[*分段栈*]（见 #refer("note/green-threads-and-stack-management")）．

== self-referential struct

中文译名：#statement-term("note/why-not-move-constructors-or-move-trait")[*自引用结构*]（见 #refer("note/why-not-move-constructors-or-move-trait")）．

== semantic domain

中文译名：*语义域*．

== semantics

中文译名：*语义*．

== semi-cooperative cancellation

中文译名：#statement-term("note/cancellation-safety-and-async-cleanup")[*半协作式取消*]（见 #refer("note/cancellation-safety-and-async-cleanup")）．

== side condition

中文译名：*附加条件*．

== simply typed lambda calculus

中文译名：*简单类型 λ 演算*．

== size

中文译名：#statement-term("definition/size-and-depth")[*大小*]（见 #refer("definition/size-and-depth")）．

== small-step operational semantics

中文译名：*小步操作语义*．

== sound

中文译名：#statement-term("definition/soundness-and-completeness")[*可靠*]（见 #refer("definition/soundness-and-completeness")）．

== source-to-source compilation

中文译名：*源到源编译*．

== specification

中文译名：*规格*．

== spurious wakeup

中文译名：*伪唤醒*．

== stack copying

中文译名：#statement-term("note/green-threads-and-stack-management")[*栈拷贝*]（见 #refer("note/green-threads-and-stack-management")）．

== stackful coroutine

中文译名：*有栈协程*．

== stackless coroutine

中文译名：*无栈协程*．

== staging

中文译名：*多阶段编程*．

== state machine

中文译名：*状态机*．

== static single assignment

中文译名：*静态单赋值形式*．

== static type checking

中文译名：#statement-term("note/static-and-dynamic-typing")[*静态类型检查*]（见 #refer("note/static-and-dynamic-typing")）．

== statically typed

中文译名：#statement-term("note/static-and-dynamic-typing")[*静态类型语言*]（见 #refer("note/static-and-dynamic-typing")）．

== strict equality

中文译名：#statement-term("example/javascript-coercion-and-equality-triangle")[*严格相等*]（见 #refer("example/javascript-coercion-and-equality-triangle")）．

== structural induction

中文译名：#statement-term("theorem/structural-induction")[*结构归纳法*]（见 #refer("theorem/structural-induction")）．

== structural pin projection

中文译名：*结构化固定投影*．

== structural recursion

中文译名：*结构递归*．

== structural rule

中文译名：*结构规则*．

== stuck

中文译名：#statement-term("definition/normal-forms-and-stuck-terms")[*受阻*]（见 #refer("definition/normal-forms-and-stuck-terms")）．

== subject reduction

中文译名：#statement-term("theorem/preservation")[*保型*]（见 #refer("theorem/preservation")）．

== subterm

中文译名：#statement-term("definition/immediate-and-proper-subterms")[*子项*]（见 #refer("definition/immediate-and-proper-subterms")）．

== subtree

中文译名：#statement-term("definition/tree-terminology")[*子树*]（见 #refer("definition/tree-terminology")）．

== subtype

中文译名：#statement-term("note/explicit-errors-and-kotlin-bottom-type")[*子类型*]（见 #refer("note/explicit-errors-and-kotlin-bottom-type")）．

== subtyping relation

中文译名：#statement-term("note/explicit-errors-and-kotlin-bottom-type")[*子类型关系*]（见 #refer("note/explicit-errors-and-kotlin-bottom-type")）．

== successor

中文译名：*后继*．

== suspension point

中文译名：*挂起点*．

== syntax

中文译名：*语法*．

== syntax tree

中文译名：#statement-term("convention/abstract-syntax")[*语法树*]（见 #refer("convention/abstract-syntax")）．

== syntax-directed

中文译名：#statement-term("note/inversion-and-syntax-directed-rules")[*语法导向*]（见 #refer("note/inversion-and-syntax-directed-rules")）．

== System F

中文译名：*F 系统*．


= T

== term

中文译名：#statement-term("definition/set-of-terms")[*词项*]（见 #refer("definition/set-of-terms")）．

== terminal

中文译名：*终结符号*．

== termination

中文译名：#statement-term("note/evaluation-strategies-reduction-strategies-and-confluence")[*终止性*]（见 #refer("note/evaluation-strategies-reduction-strategies-and-confluence")）．

== total function

中文译名：*全函数*．

== total functional programming

中文译名：*全函数式编程*．

== transition

中文译名：#statement-term("definition/one-step-reduction")[*转移*]（见 #refer("definition/one-step-reduction")）．

== transition relation

中文译名：#statement-term("definition/one-step-reduction")[*转移关系*]（见 #refer("definition/one-step-reduction")）．

== transitivity

中文译名：#statement-term("example/javascript-coercion-and-equality-triangle")[*传递性*]（见 #refer("example/javascript-coercion-and-equality-triangle")）．

== tree

中文译名：#statement-term("definition/tree-terminology")[*树*]（见 #refer("definition/tree-terminology")）．

== turnstile

中文译名：#statement-term("definition/types-and-typing-judgments")[*推导符号*]（见 #refer("definition/types-and-typing-judgments")）．

== type

中文译名：#statement-term("definition/types-and-typing-judgments")[*类型*]（见 #refer("definition/types-and-typing-judgments")）．

== type checking

中文译名：#statement-term("note/type-what-so-many")[*类型检查*]（见 #refer("note/type-what-so-many")）．

== type class

中文译名：*类型类*．

== type inference

中文译名：#statement-term("note/type-what-so-many")[*类型推理*]（见 #refer("note/type-what-so-many")）．

== type inhabitation

中文译名：#statement-term("note/type-what-so-many")[*类型居留性*]（见 #refer("note/type-what-so-many")）．

== type safety

中文译名：#statement-term("definition/type-safety")[*类型安全性*]（见 #refer("definition/type-safety")）．

== type soundness

中文译名：#statement-term("definition/type-safety")[*类型健全性*]（见 #refer("definition/type-safety")）．

== typing environment

中文译名：#statement-term("definition/types-and-typing-judgments")[*类型环境*]（见 #refer("definition/types-and-typing-judgments")）．

== typing judgement

中文译名：#statement-term("definition/types-and-typing-judgments")[*类型判断*]（见 #refer("definition/types-and-typing-judgments")）．

== typing relation

中文译名：#statement-term("definition/types-and-typing-judgments")[*类型关系*]（见 #refer("definition/types-and-typing-judgments")）．

== typing rule

中文译名：#statement-term("definition/types-and-typing-judgments")[*类型规则*]（见 #refer("definition/types-and-typing-judgments")）．


= U

== undefined behavior

中文译名：*未定义行为*．

== uniqueness of types

中文译名：#statement-term("theorem/uniqueness-of-types")[*类型唯一*]（见 #refer("theorem/uniqueness-of-types")）．


= V

== valuation function

中文译名：*值化函数*．

== value

中文译名：#statement-term("definition/values-and-numeric-values")[*值*]（见 #refer("definition/values-and-numeric-values")）．


= W

== waker

中文译名：*唤醒器*．

== well-foundedness

中文译名：#statement-term("note/scope-of-induction-hypotheses")[*良基性*]（见 #refer("note/scope-of-induction-hypotheses")）．

== well-typed

中文译名：#statement-term("definition/well-typed-terms")[*良类型*]（见 #refer("definition/well-typed-terms")）．
