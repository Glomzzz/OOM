#import "/lib/formal.typ": *

#show: formal-page.with(
  title: [用测试对照证明],
  description: [把进展、保型与确定性写成基于样本的测试断言，并讨论测试与形式证明的边界．],
)

纸面证明可能写错，代码也可能与规则不一致．
可以把定理在具体样本上的结论写成测试断言：
生成大量词项，检查它们是否满足进展、保型等性质．
这是在有限样本上核对实现，不是把普遍命题直接变成了测试证明．

```rust
#[test]
fn safety() {
    for t in corpus() {                        // 深度 ≤ 2 的全部项 + 随机的深项
        let Some(ty) = type_of(&t) else { continue };
        let mut cur = t.clone();
        loop {
            // 进展：不是值，就必须能规约
            let Some(next) = step(&cur) else {
                assert!(is_value(&cur), "受阻了：{cur:?}");
                break;
            };
            // 下降性质：待测实现返回的后继也必须严格更小
            assert!(size(&next) < size(&cur), "{cur:?} ⟶ {next:?}");
            // 保型：一步规约，类型不变
            assert_eq!(type_of(&next), Some(ty), "{cur:?} ⟶ {next:?}");
            cur = next;
        }
    }
}
```

#refer("lemma/reduction-decreases-size") 证明的是原求值关系的每一步都让项变小，
测试却不能预先假定待测 `step` 已正确实现这个关系．
因此这里也检查 `size` 严格下降：
若错误实现返回原项，测试会报告失败，而不是永远循环．
它防范的是“每次调用都会返回，但后继不下降”的错误；
若 `step` 自己不返回或耗尽资源，仍需测试进程的超时或其他限制，
见 #refer("note/unexamined-assumptions")．

完整工程在 #link("https://github.com/Glomzzz/OOM/tree/main/code/plt-arith")[`code/plt-arith`] 下；
进入该目录运行 `cargo test --release`．
实际测试还保留 `size(t)` 次调用的上限，并明确确认求值器曾返回 `None`，
不能仅凭当前项是值就认定已经停止；
同时统计良类型样本与实际规约步数，防止测试空转．
样本是深度 2 以内的全部 59439 个项，外加 50000 个深度到 6 的确定性随机项．

确定性也能这样测．
测试里把十条规约规则逐条照抄成返回*所有*可能 $t'$ 的函数，不做任何排序或排除，
然后检查它在每个样本上至多给出一个结果，并且和 `step` 一致．
这同时验证了 #refer("note/proofs-behind-pattern-matching-order") 的说法：
`match` 的分支顺序没有偷偷改变语义．

前文提过的两个错误写法都会暴露出来，但抓住它们的测试不同：

- `type_of` 不检查 $"else"$ 分支，破坏的是检查器相对原类型规则的可靠性：
  原规则的保型定理并没有推翻，推翻的是“检查器接受的项都满足规则”．
  `safety` 实际报出的反例是 $"succ" ("if" "false" "then" 0 "else" "true")$：
  错误的检查器只看 $"then"$ 分支，认为它是 $tN$；
  一步规约（E-Succ + E-IfFalse）得到 $"succ" "true"$，没有类型，而且受阻了；
  测试是通过“规约后类型不再保持”暴露这个检查器错误的．
- E-PredSucc 写成任意 $t$，类型安全其实仍然成立，坏掉的是确定性；
  测试报出 $"pred" ("succ" ("pred" 0))$ 有两种规约方式．

每条定理守住的东西不同，少证一条，就会漏掉一类错误．

#statement("note/testing-is-not-proof")

#statement("remark/falsification-and-verification")

= 练习：测试与证明

#exercise-group(4)[
  #exercise(
    "7.1",
    [给不同的错误配不同的测试],
    hint: [
      分别检查值不可规约、进展、关系的所有后继，以及检查器接受后类型能否保持；
      测试一个函数只有一个返回值不是确定性测试．
    ],
    answer: [
      - 让 `step(True)` 返回 `Some(Zero)`：
        用值不可规约测试要求 `step(True) == None`．
        这个错误也把 `Bool` 变成 `Nat`，所以保型检查也能发现．
      - 让 `step(Pred(Zero))` 返回 `None`：
        $"pred" 0 : tN$ 不是值，却无法走一步，进展测试会失败．
      - 将关系中的 E-PredSucc 放宽到任意项：
        $"pred" ("succ" ("pred" 0))$ 有两个不同后继 $"pred" 0$ 与 $"pred" ("succ" 0)$．
        用独立的规则枚举器检查后继集合，而不是只看 `step` 选出的一个返回值．
      - `type_of` 忽略 $"else"$ 分支：
        $"succ" ("if" "false" "then" 0 "else" "true")$ 误判为 $tN$，
        一步得到 $"succ" "true"$，新项没有类型且受阻．
        逐步保型或端到端安全测试能抓到它．

      四处修改应分别注入、分别恢复，才能知道哪个测试在防哪类错误．
      放宽规则的错误不一定破坏类型安全，不能指望一条安全测试包办所有性质．
    ],
  )[
    分别对下面四处独立的错误设计具体输入与测试断言，并指出它违反了哪个性质：
    值 $"true"$ 规约成 $0$；$"pred" 0$ 误判为没有后继；
    关系中的 E-PredSucc 去掉数值限制；类型检查器不检查 $"else"$ 分支．
  ]

  #exercise(
    "7.2",
    [通过测试，还是没有真正测到？],
    hint: [
      读 #refer("note/testing-is-not-proof") 时也检查测试的前提：
      循环是否进入过良类型情形？是否实际走过一步？比较器是不是只在与自身比较？
    ],
    answer: [
      只生成不良类型的项时，`let Some(ty) = type_of(&t) else { continue };`
      会跳过每个样本，进展和保型断言一次都不运行．
      只生成常量值时，类型检查会通过，但 `step` 立即返回 `None`，
      仍从未检查一次类型保持．

      至少统计并断言良类型样本数大于零、实际规约总步数大于零，
      再加入确实需要多步运行的嵌套项．
      还应单独测拒绝的项和受阻情形．
      这些统计能排除明显的空转，却不等于覆盖所有规则和路径．

      `assert_eq!(step(t), step(t))` 只是一个确定执行的函数与自身比较；
      即使它算错了，两边仍可能同时错．
      把“关系枚举器”直接写成 `step(t).into_iter().collect()` 也没有独立核对规则．
      应分别按规则列出后继，再与函数实现对照；
      两份代码仍可能犯相同错误，所以还需结合具体例子、逐规则审阅与证明．
    ],
  )[
    本节的 `safety` 测试如果只生成不良类型项，
    或者只生成 $"true"$、$"false"$、$0$，会发生什么？
    怎样用统计断言发现这种空转？
    另解释为什么 `assert_eq!(step(t), step(t))`，
    或者从 `step` 直接包装出的“关系枚举器”，不能验证求值器与规则一致．
  ]

  #exercise(
    "7.3",
    [再多的有限样本也留下边界],
    hint: [设这批样本的最大深度为 $d$．让错误只在深度超过 $d$ 时出现．],
    answer: [
      假设这批样本非空，$d$ 就是有限的最大深度；空样本集可取 $d = 0$．
      可以构造一个终止的错误检查器：
      ```rust
      pub fn bounded_fake(t: &Term, d: usize) -> Option<Type> {
          if depth(t) > d { Some(Type::Nat) } else { type_of(t) }
      }
      ```

      每个测试样本深度都不超过 $d$，所以它们得到的结果与正确实现完全相同．
      可是给 $"true"$ 外面包上 $d + 1$ 层 $"succ"$，得到的项深度为 $d + 1$，
      假检查器会把它接受为 $tN$；
      原类型规则却无法给最内层 $"succ" "true"$ 定型，整个项没有类型，而且受阻．

      因此有限测试通过，只能排除样本范围内已出现的反例．
      这里不声称真实缺陷一定这样写，而是用具体构造说明：
      没有关于所有项的证明，测试结果本身不蕴涵普遍可靠性．
    ],
  )[
    给定任意一批有限的测试项，设其中最大深度为 $d$．
    构造一个检查器，使它通过这批项与正确 `type_of` 的所有结果对照，
    却在某个更深的项上不可靠．
    给出函数、反例和推理，说明这个例子揭示的测试边界．
  ]

  #exercise(
    "7.4",
    [为什么求值测试的循环会停？],
    hint: [
      对一步规约作规则归纳．
      基本规约规则删掉节点；结构规则把子项的严格下降带到外层．
      深度不一定严格下降．
    ],
    answer: [
      对 $t stp t'$ 作规则归纳．
      E-IfTrue 与 E-IfFalse 只留下一个分支，删掉根、条件及另一分支，大小严格下降．
      E-PredZero 和 E-IsZeroZero 从两个节点变成一个；
      E-PredSucc 删除 $"pred"$ 与 $"succ"$ 两个节点；
      E-IsZeroSucc 把大小至少为 $3$ 的项变成单个 $"false"$ 节点．
      这覆盖六条基本规约规则．

      对 E-Succ、E-Pred、E-IsZero，#ih 给出子项大小严格下降，
      两边包上同一个一元节点，严格不等式仍成立．
      对 E-If，只有条件变化，两个分支与 $"if"$ 根贡献的节点数相同，也保持严格下降．
      因此十条规则都给出 $op("size")(t') < op("size")(t)$．∎

      大小始终是至少为 $1$ 的整数，起点大小为 $s$ 时，最多走 $s - 1$ 步就必须停止．
      停止时是否为值是另一个问题：不良类型项也会停止，却可能受阻；
      对良类型项，进展才排除这种终点．

      深度不适合替代这个严格下降度量．
      例如 $"if" ("iszero" 0) "then" ("succ" ("succ" 0)) "else" 0$ 的第一步
      只把条件变成 $"true"$，最长路径仍在 $"then"$ 分支，两项深度都是 $3$．
      类型安全也不独自保证循环停止，见本节之前的自循环扩展题．
    ],
  )[
    不依赖类型安全，证明原语言每一步都使大小严格下降，
    并给出从大小为 $s$ 的项出发的规约步数上界．
    能否把大小换成深度并保持“每一步严格下降”？找反例．
    最后说明为何“循环停了”仍不足以断言求值成功．
  ]
]

#html.nav(class: "chapter-nav", aria-label: "文章导航")[
  #cite("/how/plt/formal/rules-and-algorithms.typ")[← 规则与算法：可靠性与完备性]
  #cite("/how/plt/formal/index.typ")[回到形式化入门]
  #cite("/how/plt/formal/summary.typ")[总结 →]
]
