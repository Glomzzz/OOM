#import "/lib/statements.typ": *
#import "/lib/formal-math.typ": *

#let entry = (
  title: [潜无穷与实无穷],
  date: "2026-10-10",
  author: "Glomzzz",
  parent: "/how/plt/formal/syntax.typ",
  legacy-id: "fm-ph-infinity",
)

#show: statement-page.with("remark/potential-and-actual-infinity", entry)

#wiki("亚里士多德")[亚里士多德（Aristotle）]区分过两种无穷：*潜无穷*（potential infinity）是一个可以无限进行下去的过程，比如数数总能再数一个；*实无穷*（actual infinity）是一个已经完成的无穷整体。项的集合 $cal(T)$ 可以从两个角度看：按 #refer("definition/set-of-terms") 的写法，它是一个现成的无穷集合（实无穷）；按“用规则在有限步内搭出来”的读法，每个项都是一个有限过程的产物。

#refer("theorem/structural-induction") 的巧妙之处在于，它让我们对一个无穷集合下结论，却只需检查有限多条规则。这也是数学基础里构造主义者（constructivist）认可归纳定义的原因：每个对象都有一个有限的构造历史。

潜无穷体现在“总能构造出更大的有限项”这一点上：单个项由有限步骤构成，这一事实本身并不说明潜无穷，说明它的是项的构造过程没有上界。
