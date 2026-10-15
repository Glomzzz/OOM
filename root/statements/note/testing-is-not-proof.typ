#import "/lib/statements.typ": *
#import "/lib/formal-math.typ": *

#let entry = (
  title: [测试与证明的边界],
  date: "2026-10-10",
  author: "Glomzzz",
  parent: "/how/plt/formal/test-and-proof.typ",
  legacy-id: "fm-rm-test-not-proof",
)

#show: statement-page.with("note/testing-is-not-proof", entry)

测试只能检查有限个样本，证明则覆盖命题量词范围内的所有对象．
例如，#cite("/how/plt/formal/test-and-proof.typ")[用测试对照证明] 的测试样本来自
#refer("definition/set-of-terms") 的词项集合，
深度按 #refer("definition/size-and-depth") 计算；
深度为 3 的项已经多到难以及时穷举．
测试通过，只说明在这些样本上没找到反例．
两者的分工很明确：证明交代结论成立的依据，测试核对代码与证明谈论的是否为同一件事．
测试失败时，要检查实现、测试断言及它们与规格的对应；
证明写不下去时，也不能据此断定一定有反例：
可能是命题本身不成立，也可能是缺少引理、归纳命题过弱或证明方法不合适，须继续分析．

真实软件也能说明测试规模与普遍保证的区别．
按 #link("https://sqlite.org/testing.html")[SQLite 官方测试说明]的版本与口径，
SQLite 3.42.0（2023-05-16）有约 155.8 KSLOC 的 C 库源码，
以及 92053.1 KSLOC 的测试代码与脚本，即约 15.58 万行与 9205.31 万行；
SLOC 统计去掉空行和注释后的源码行数（属于代码规模指标，与覆盖率不同）．
官方另报告特定配置下核心代码的 100% 分支覆盖，
但分支覆盖不等于覆盖所有路径、输入和状态，也不意味着没有任何缺陷．

路径数确实可能*指数*增长：
在无循环、顺序经过 $n$ 个二路分支且所有分支组合都可达的情况下，可有 $2^n$ 条路径．
当然，条件之间可能相关，也可能存在不可达分支，未必每加一个 `if` 都使路径翻倍；
循环还会带来不同迭代次数等问题．
这个例子说明逐路径穷举可能很昂贵，但测试依然重要，更不能单凭测试行数判断是否应当重写软件．

类型系统走的是另一条路．
#refer("corollary/type-safety") 这样的定理无需逐条路径试跑，
直接对*所有*良类型程序、*所有*执行路径一并给出“不会受阻”的保证．
这里证明的是*类型健全性*：
类型规则认可的词项，在执行时确实不会出现所定义的那类错误．
例如，C 的静态类型检查不能排除越界访问、通过悬垂指针访问对象等未定义行为，
所以“通过检查”不能作为内存安全保证，该测的还得测．

采用内存安全语言，是把一类错误的防线从测试移到语言机制上的工程选择．
Rust 的类型系统与借用检查旨在阻止违反所有权、引用和并发访问约束的 Safe Rust 代码通过编译；
但它接触到的 `unsafe` 库实现与外部代码仍须遵守相应安全契约．
通过编译不等于任意 Rust 工程都安全，更不保证没有逻辑错误、死锁或异常退出．

#link("https://plv.mpi-sws.org/rustbelt/popl18/")[RustBelt（POPL 2018）]
给出了代表现实 Rust 子集的语言的机器检查安全证明，
并为内部使用 `unsafe` 的库规定验证条件，验证了其中若干重要库．
这与“整个 Rust 语言、编译器和所有工程都已证明安全”是不同的主张．

经验数据也支持采用内存安全语言的价值：
#link("https://www.microsoft.com/en-us/msrc/blog/2019/07/a-proactive-approach-to-more-secure-code")[Microsoft 的 2019 年报告]
指出，每年修复并分配 CVE 的漏洞中约七成涉及内存安全；
#link("https://www.chromium.org/Home/chromium-security/memory-safety/")[Chromium]
的约七成则以自 2015 年起影响稳定通道的 912 个高危或严重漏洞为统计对象．
两份资料的严重性口径不同，不能合并成“各自所有产品的严重漏洞”．
#link("https://security.googleblog.com/2024/09/eliminating-memory-safety-vulnerabilities-Android.html")[Android 的 2024 年报告]
则指出，新开发转向内存安全语言后，这类漏洞的占比显著下降；
它主张优先保护新代码、改善安全互操作，并明确认为不必重写全部现有代码．
因此，这些材料更适合支持*逐步采用内存安全语言*．
是否用 Rust 重写某个既有工程，还须考虑具体风险、迁移成本与兼容性，不能单靠这组数据决定．
静态检查与形式证明仍不取代测试，
但在所声明的安全契约与模型假设下，它们可以排除一类有限样本测试无法单独排除的错误．
