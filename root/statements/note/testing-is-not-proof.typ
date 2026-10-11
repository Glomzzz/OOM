#import "/lib/statements.typ": *
#import "/lib/formal-math.typ": *

#let entry = (
  title: [测试不是证明],
  date: "2026-10-10",
  author: "Glomzzz",
  parent: "/how/plt/formal/09-test-and-proof.typ",
  legacy-id: "fm-rm-test-not-proof",
)

#show: statement-page.with("note/testing-is-not-proof", entry)

测试只能检查有限个样本，证明覆盖命题量词范围内的所有对象。例如，#cite("/how/plt/formal/09-test-and-proof.typ")[用测试对照证明] 的测试样本来自 #refer("definition/set-of-terms") 的项集合，深度按 #refer("definition/size-and-depth") 计算；深度 3 的项已经多到没法穷举。测试过了，也只说明在这些样本上没找到反例。两者的分工是：证明负责“为什么对”，测试负责发现“证明和代码说的是不是同一件事”。测试失败，说明证明或代码有一处错了；证明写不下去，往往说明测试还没碰到反例。

这个差距在真实软件里大得惊人。MikanAffine 的#link("https://zhuanlan.zhihu.com/p/1967137031315514576")[《为什么 sqlite 可以被重写》]以 SQLite 为例：它用约 9000 万行测试覆盖约 20 万行源码，仍然不断被报告出漏洞。原因是程序每经过一个 `if` 就分裂出两条执行路径，要覆盖的路径数随分支数*指数*增长，测试的增长永远追不上。

类型系统走的是另一条路。#refer("corollary/type-safety") 这样的定理不是对路径逐条检查，而是一次性地对*所有*良类型程序、*所有*执行路径断言“不会受阻”。前提是类型系统本身是*可靠的*（sound）：它说没问题的程序，运行时真的没有那一类问题。一个不可靠的类型系统（比如允许随意强制转换指针的 C）给出的“通过检查”就不能当作保证，该测的还得测。

这正是近年 RIIR（Rewrite It In Rust，用 Rust 重写）思潮背后最实在的理由。Rust 的类型系统和借用检查器把内存安全、数据竞争这类错误从“要靠测试和运气去发现”变成了“编译不通过”；RustBelt 等工作则在形式化层面证明了它的安全核心是可靠的。#link("https://msrc.microsoft.com/blog/2019/07/a-proactive-approach-to-more-secure-code/")[微软]和 #link("https://www.chromium.org/Home/chromium-security/memory-safety/")[Chromium] 都报告过，各自产品中约七成的严重安全漏洞来自内存安全问题；而 #link("https://security.googleblog.com/2024/09/eliminating-memory-safety-vulnerabilities-Android.html")[Android] 在新代码转向内存安全语言之后，这类漏洞的占比显著下降。静态检查当然不能取代测试，但它把一整类错误从测试的负担里拿掉了，这是测试本身做不到的。
