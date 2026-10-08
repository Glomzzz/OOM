#import "/lib/lib.typ": *

#show: schema.with("page")

#title[初入编程语言理论]
#date[2026-10-08]
#author[Glomzzz]
#parent("/how/plt/index.typ")

PLT（_Programming Language Theory_，程序语言理论）大概是我人生中少有的、能让我持续感兴趣的东西。它对我的吸引力不太像"一门学问"，更像一种手感：你手里有一套可以任意捏造的规则，而你要做的，是让这套规则在某个地方真正跑起来。这篇文章想聊三件事——我为什么会迷上它、它到底难在哪里、以及如果今天让我重新入门，我会怎么走。

= 从一台简陋的计算器说起

起点是一个用 Rust 写的计算器。它简陋到什么程度呢：四个运算符，加上括号，能跑。但当我第一次意识到 `1 + 2 * 3` 并不该被从左到右解释时，我就撞上了第一堵墙——运算符优先级。为了越过它，我读到了 matklad 的那篇 #link("https://matklad.github.io/2020/04/13/simple-but-powerful-pratt-parsing.html")[Simple but Powerful Pratt Parsing]，第一次知道原来"解析"本身是一门可以设计、可以品味的技艺：每个运算符有自己的 binding power，前缀、中缀、后缀各有一套处理方式，几十行代码就能支撑起一个可扩展的表达式文法。那大概是我第一次感受到"抽象"带来的直接快感。

后来我在 JVM 上折腾了一段时间。JVM 对动态语言相当友好：反射、字节码生成（ASM / ByteBuddy）、动态代理、成熟的 JIT 与 GC，全都现成——于是我给 Minecraft 服务器写了一些 DSL，让服主可以用接近自然语言的方式描述规则。也是从这里开始，我被迫接触后端优化：为什么同样的逻辑，换个写法性能会差一个数量级？答案往往不在你写的那几行代码里，而在 JIT 的视角里——你写的东西会被怎么内联、怎么做逃逸分析、怎么做去虚拟化。

再往后，是一次很偶然的连锁反应。我在尝试对柯里化函数做 Partial Application 时，冒出一个念头：与其每次调用都重新组合参数，能不能在编译期就尽量把已知的部分算出来？顺着这条线，我遇到了 Partial Evaluation（部分求值）与 Futamura 投影，又遇到了 Staging（多阶段编程，MetaOCaml、LMS 那一套），再往下就是计算效果（effects），以及描述它们的静态效果系统、建模它们的 Monad、处理它们的 algebraic effect handlers……每一样都通向更大的世界，我至今也没走完。

上了大学之后，能自由折腾的时间突然变少了。大一为了应付作业，我读了 SICP，然后用 C++ 写了一个 Scheme 解释器——那大概是我第一次完整地走完"读语法 → 求值 → 打印"这一圈。这学期我选了一门编程范式的课，又写了半个学期的 Haskell（大作业是Parser Combinator in Haskell），突然就找回了当年那种感觉。

== 所以，到底为什么喜欢？

我也问过自己很多次。答案大概是：PLT 是少数几个"你既是规则的制定者，又是规则的囚徒"的领域。你设计一套语言，然后必须接受自己设计出来的一切后果——包括那些你在设计时根本没想到的交互。这种"造物"与"被造物反噬"之间的张力，对我有近乎生理性的吸引力。

另一方面，它是少见的、把"抽象"当作第一公民的工程领域。别的工程把抽象当作工具，PLT 把抽象当作研究对象本身。

= 复杂度从哪里来

我设计过不少语言的 spec，但几乎每一次都被复杂度劝退——它增长得比我预想的快得多。好在这两年有了 LLM 神力，可以帮我填补生产力空洞：我只要把想法讲清楚，就能很快得到一个能跑的实验产品。但"能跑"和"设计得对"之间，仍然隔着一整个复杂度问题。

== 语言特性？排列组合！

语言设计的第一步，往往是决定"我要哪些特性"。这一步很像做排列组合：你希望某些特性之间发生奇妙的化学反应，或者为了专攻某个方向而特意引入某些特性（Rust 的 affine type 与 lifetime、Haskell 的 type class、Lisp 的宏，都属于后者）。把这些特性两两摆到一起，大致会看到五类关系：

- *正交（orthogonal）*：彼此独立，可以放心叠加。例如词法作用域与垃圾回收、闭包与模式匹配、泛型与模块系统——它们各自解决不同维度的问题，组合起来几乎不产生额外语义。
- *协同（synergy）*：单独看平平无奇，合起来却能涌现出新能力。例如闭包 + GC 让高阶函数变得廉价；type class + 单态化（monomorphization）让"零成本抽象"成为可能；模式匹配 + GADT 让类型安全的结构化求值成为可能；algebraic effects + delimited continuation 让"可恢复的计算"变成一等公民。这类组合是设计语言时最值得追求的东西。
- *冗余 / 重叠（overlapping）*：同一个目的有多种相互重叠的表达方式，硬塞在一起就可能让语言出现"两套并行的世界观"。例如 Monad 与 Algebraic Effect Handlers——两者都可用于建模与组织副作用：Monad 通常以库抽象的形式组织计算，algebraic effect handlers 通过处理器解释效果操作；后者既可以作为语言特性，也可以编码成库，两者在语义上有紧密联系；再比如异常与 `Result`/`Either`、null 与 `Option`、类与 type class、宏与泛型。冗余本身不致命，但它会让用户不断面对"我该用哪个"的选择疲劳，也会让两套机制的交互成为 bug 温床（毕竟任何一处改动，都得把所有组合重新考虑一遍）。
- *冲突（conflicting）*：单独看都很好，放到一起却语义打架，或者直接导致理论上的不可判定。例如子类型（subtyping）与多态、类型推导的组合会增加复杂度，某些具体系统存在不可判定性，但仅凭子类型与记录/列表并不能推出这个结论；#link("https://lptk.github.io/programming/2020/03/26/demystifying-mlsub.html")[MLsub / Simple-sub] 就支持子类型、记录和 ML 风格的全局类型推导；类型推导 + ad-hoc 重载会让"最具体实例"的选择变得病态；宏与卫生性（hygiene）如果处理不好，会互相污染作用域；线性类型与"可随意复制"的默认语义天然对立。这类组合往往必须"取舍"而不是"调和"。
- *依赖（dependent）*：特性 B 的成立以特性 A 为前提。例如 GADT 模式匹配需要能处理局部类型相等约束的检查规则，实际实现常借助显式标注；高秩多态类型（higher-rank types，不同于 higher-kinded types）在 GHC 等实现中通常需要标注提供多态参数的类型。若希望依赖类型承担可信证明，并保证类型检查中的计算终止，就需要限制相关递归或验证其终止性，但不必要求所有程序都终止。`async`/`await` 则需要支持挂起与恢复的机制，状态机变换是常见实现方案之一，也可以借助 CPS、栈式协程或效果处理器。识别真正的依赖关系、区分它们与实现选择，才能排出合理的实现顺序。

（也许还该补上第六类：*不可组合（incompatible）*——不是"打架"，而是根本不在同一个宇宙里，例如 first-class continuation 与某些 C FFI 的栈约定。）

== 交叉点、盲点与处理方式

选好特性只是开始。真正的复杂度来自交叉点：n 个特性最多有 n(n-1)/2 个两两交互，数量只是二次增长；如果考虑所有包含至少两个特性的子集，则共有 `2^n - n - 1` 种可能组合，数量是指数增长的。不过，组合数量并不等于实际设计复杂度，还要看哪些特性真正发生交互。你在设计 A 和 B 时都想到了所有情况，但你没想到 A 的某个角落和 B 的某个角落会撞在一起。

盲点通常不会在纸面上暴露，而是在这些地方被抓出来：

- *形式化*：写 operational semantics，或者在 Coq / Agda / Lean 里做机械化证明——代价最高，也最彻底；
- *测试*：写一个足够大的测试套件或一致性测试（像 WebAssembly 的 spec tests 那样），用大量程序去撞边界；
- *自用*：拿这门语言写一个非平凡的程序，最理想的是自举，把"设计者视角"换成"用户视角"；
- *实现*：先写一个原型编译器，让类型检查器和求值器去替你发现矛盾。

发现盲点之后，处理手段大致也就那么几种：

- *限制*：直接禁止这个组合（例如"泛型不能作为数组长度"），用报错换一致性；
- *归约*：把一种特性 desugar 成另一种，只保留一套语义内核（例如把 `for` 脱糖成 `while`、把 `async` 脱糖成状态机）；
- *分层*：把两套机制放到不同的层级，规定谁能看见谁（例如把宏展开限定在编译期，把效果的静态描述与检查放在效果系统里，再由生成的代码或运行时机制实现对应行为）；
- *引入新构造*：承认"光靠已有特性表达不了"，加一个专门的正交构造来承担交叉点；
- *限制自动推导*：要求必要的类型标注，以采用可判定的检查算法；若检查或子类型判定本身不可判定，则标注也未必能解决，必须另行说明限制哪些规则、如何处理无法完成判定的输入。

"该怎么发现盲点、该怎么处理盲点"，基本上就是 PLT 研究的日常，也是语言设计复杂度的真正来源。

= 语言设计的抽象

不过，复杂度虽然会爆炸，我们还有抽象神力——Abstraction。一个很有用的做法是：先把"语言设计"这条混沌的河切成几段相对独立的层，再逐层讨论。我个人习惯分成四层。

== 语法（Syntax）

所有与"人怎么写、机器怎么读"有关的设计：具体语法与抽象语法、运算符优先级与结合性、缩进/换行规则（offside rule）、语法糖、宏与卫生性、错误恢复。

这一层看起来最"浅"，其实最容易积重难返：一个随手加的语法糖，可能会让后续所有解析都变得含混。经验法则是——*让语法糖尽量可脱糖*：每引入一个甜美的写法，都要能说清楚它脱糖后的核心形式是什么。

== 中间表示（IR）

从 AST 到字节码之间的所有表示及其转换：脱糖、ANF、CPS、SSA、三地址码、闭包转换、单态化、内联、优化遍。

IR 的设计与 lowering 流程会深刻影响语言实现：惰性求值常用 thunk / 闭包实现，但不要求每一级 IR 都保留显式的 thunk 节点；保证尾调用不增长调用栈，需要编译流程与目标平台的配合；可恢复的效果处理器需要相应的 continuation 或挂起与恢复机制，而普通的状态修改、I/O 等副作用不需要这样的机制。很多语言最终卡住，不是因为语法或类型系统，而是因为从核心语义到低层代码与运行时的转换没有打通。总之一句话：IR 是落实语言语义的重要桥梁。

== 检查系统（Checking System）

（也许该换个名字，因为"类型系统"只是它的一部分。）

它负责拒绝那些不该发生的程序——通常是在编译期，必要时也可以推迟到运行时：

- *类型系统*：HM、System F、依赖类型、线性/仿射类型、refinement types；实现时可采用双向类型检查（bidirectional type checking），它是一种检查的组织方式，而不是与 System F 同层级的分类；
- *效果系统*：效果注解、effect rows、效果多态等；Monad 可用于建模效果，algebraic effect handlers 是解释效果操作的机制，两者不等同于静态效果系统。有 handlers 的语言也未必静态跟踪效果，例如 OCaml 不静态保证所有效果都被处理；
- *所有权/借用检查*：Rust 那一套 region + borrow 的静态分析；
- *终止性/全域性检查*：total functional programming 这一脉；
- *其它静态性质*：纯度、可序列化性、并发安全性……

这一层的关键词是"取舍"：表达力、可推导性、错误信息的可读性、实现复杂度，四者几乎不可能同时最优。

== 运行时（Runtime）

程序跑起来时的一切：内存管理（GC / ARC / region 等）、副作用管理、求值策略的实现（call-by-value / need / name）、并发与并行模型、FFI、解释执行与 JIT。AOT 是运行前的编译方式，属于编译流程；它生成的代码仍可能依赖运行时支持。线性/仿射类型则是静态约束，可以帮助编译器安排资源释放，但不是运行时内存管理算法。

在我看来，这一层最工业化、最"脏"。入门课程会覆盖其中一些概念，但生产级运行时的工程细节很难在一门课里讲透；它也是决定一门语言能否落地的重要因素。

= 学校的 PLT 教育

学校里的 PL 教育没有一个统一的配方：有的课程偏重编程范式、类型系统与语义，有的偏重编译器实现。后一类课程常从 lexer / tokenizer / parser 开始，继续讲语义分析、IR、优化与代码生成。例如 #link("https://www.handbook.unsw.edu.au/postgraduate/courses/2026/COMP9102")[UNSW 的研究生课程 COMP9102（Programming Languages and Compilers）]、#link("https://web.stanford.edu/class/cs143/syllabus.html")[Stanford CS143]、#link("https://www.cs.cmu.edu/~411/")[CMU 15-411]；此外，还有 #link("https://craftinginterpreters.com/")[Crafting Interpreters] 这样的实践教程。这些资料并不都停在"能生成目标代码"：CS143 包含类型检查、Runtime Organization 与 Garbage Collection，15-411 包含内存管理和运行时组织，Crafting Interpreters 更会带你手写字节码 VM、调用栈、闭包与 GC。编译器课程只是 PL 教育的一部分，不能用它们代表全部本科 PLT 教学。

为什么生产级运行时很难在入门课程里讲透？我的理解是：一门课的时间有限，而这些内容涉及大量复杂的工程权衡；另一方面，确实有不少现成的基础设施可以复用。把自己的语言编译到 LLVM IR，就能利用它的优化与机器代码生成，但 #link("https://llvm.org/docs/GarbageCollection.html")[LLVM 本身不提供垃圾收集器]，更不自动提供完整的语言运行时；编译到 WASM 后，可以交给浏览器或其他 WASM 引擎执行；编译到 JVM 字节码，则可以利用成熟的 JIT 与 GC。如果目标是低成本验证语言设计，我会优先复用现成后端和宿主运行时，而不是从零手写生产级实现。

至于检查系统，也不能指望选定一个后端就自动得到。你可以复用现成的类型系统设计、推导算法或实现框架，但它仍必须和你的语言语义严丝合缝，能报出人类看得懂的错误，并在表达力和可推导性之间取舍。所以这一层仍需要自己学、自己走平衡木——类型系统、effect 系统，等等。（这也是我最想花时间补齐的一块。）

= 给刚入门的人的建议

如果让我给一个刚进入 PLT 的新人一条建议，那就是：*不要好高骛远，优先保持语言实现的低成本*。有现成的工具就用，不要重复造无意义的轮子。parser 这块你想手写也行，毕竟复杂度没那么高；但后端还是先复用 LLVM / Cranelift 等，或选择 WASM / JVM 字节码这类目标，千万别一上来就自己写机器代码后端。

另一个更具体的建议是：*把大目标拆成一组最小语言*。当你想要把 A、B、C、D 这些特性组合到一起、却对每一个都不熟悉时，先去分别实现 A、B、C、D 四个 minimal programming language，各自只保留支撑该特性的最小核心，然后再尝试把它们合体。这样做有两个好处：一是每个小语言都能在一两天内跑起来，"完成目标"带来的满足感可以很大程度上驱动你继续前进；二是当你把它们合体时，你会亲手撞上那些"交叉点"，这比在纸上空想有效得多。

== 一个具体的入门路线

如果让我给自己规划一条路线，大概是这样的——目标是设计一门*自己用起来很舒服*的编程语言：

- *从语法开始*：不要急着直接上手写 parser，先用 ANF 的形式把核心语言的语法与求值规则写清楚。（ANF 的好处是把求值顺序显式化，让你没法用"反正运行时知道"来糊弄自己。）
- *选一个 IR*：树遍历解释器 → ANF / CPS → 字节码，是最经典的递进路线。先跑通，再优化，不要一上来就 SSA。
- *选一个类型系统*：建议从 simply typed lambda calculus 起步，先把 bidirectional type checking 写顺，再考虑 effect 系统——effect 系统可以先不碰。
- *把成熟的基础设施用起来*：这一点后面单独说。优先复用后端与宿主运行时，同时明确列出仍需自己实现或适配的语言语义和运行时支持。

= 运行时的"草台"方案

多提一嘴：语言实现有一种听起来很草台、但在工业界确有广泛应用的做法——*直接编译到某个成熟语言的源码上*，也就是所谓的 source-to-source compilation。它可以复用目标语言的工具链，有时也能复用其运行时，但二者不是同一回事：

- #link("https://koka-lang.github.io/koka/doc/index.html")[Koka] 会把自己的程序编译成 C 或 JavaScript；
- TypeScript、CoffeeScript、Elm、PureScript、Reason / ReScript 编译到 JavaScript；
- Nim 编译到 C / C++ / JavaScript；
- Haxe 编译到一大堆目标语言；
- Idris 2 通过 Chez Scheme 后端跑起来；
- Cython 把 Python 的方言编译到 C。

甚至可以更"土"一点：直接生成 Java 源码再交给 `javac`。虽然丑，但你立刻得到了 JVM 的 JIT、GC，以及整个生态。

另一条路是把"生成源码"换成"生成中间表示或字节码"：生成 LLVM IR、QBE 的 IL 或 Cranelift 的 CLIF，或者生成 WASM、JVM 字节码、.NET CIL、Erlang BEAM / Lua 字节码，交给相应的后端或执行引擎。MLIR 则是支持多种 dialect 与逐层 lowering 的 IR 框架，可以帮助组织这些转换，并不是一个现成的运行时。

这里要分清两种复用：复用后端可以减少优化和机器代码生成工作；复用 JVM、JavaScript 引擎、Chez Scheme 这样的成熟宿主运行时，可以进一步减少内存管理和执行引擎工作。LLVM、QBE、Cranelift 本身不是完整的语言运行时，编译到 C 也不自动获得 GC 或效果处理机制。无论采用哪条路，都能让自己更专注于语言真正独特的部分，但仍需实现或适配源语言特有的语义。#footnote[关于抽象与分层的边界，可参见 Ray Eldath 的 #link("https://ray-eldath.me/programming/three-important-ideas/")[计算机领域的三个重要思想：抽象，分层和高阶] 中“有关分层”一节。]<plt-runtime-semantics>

毕竟，PLT 的乐趣在于设计语言，而不在于重新发明一个寄存器分配器。

= 延伸阅读

- #link("https://matklad.github.io/2020/04/13/simple-but-powerful-pratt-parsing.html")[Simple but Powerful Pratt Parsing] —— 我接触解析的起点
- #link("https://craftinginterpreters.com/")[Crafting Interpreters] —— 从解释器写到字节码虚拟机，最好的入门实践
- #link("https://mitpress.mit.edu/9780262510875/structure-and-interpretation-of-computer-programs/")[SICP] —— 抽象的第一课
- #link("https://www.cis.upenn.edu/~bcpierce/tapl/")[Types and Programming Languages] —— 类型系统的标准教材
- #link("https://koka-lang.github.io/koka/doc/index.html")[Koka] —— 把 algebraic effect 与 Perceus 引用计数做进真实语言
- #link("https://github.com/yallop/effects-bibliography")[Effects Bibliography] —— 计算效果（effects & handlers）的论文与资料合集
- #link("https://github.com/effect-handlers/effects-rosetta-stone")[Effects Rosetta Stone] —— 同一种 effect 在几十种语言/库里的写法对照
