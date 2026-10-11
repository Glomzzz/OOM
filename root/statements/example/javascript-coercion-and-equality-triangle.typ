#import "/lib/statements.typ": *
#import "/lib/formal-math.typ": *

#let entry = (
  title: [JavaScript 隐式转换与相等三角图],
  date: "2026-10-10",
  author: "Glomzzz",
  parent: "/how/plt/formal/03-evaluation.typ",
  legacy-id: "fm-ex-js-triangle",
)

#show: statement-page.with("example/javascript-coercion-and-equality-triangle", entry)

JavaScript 没有把 `true + 1` 留作未定义，而是明确规定转换后得到 `2`。同样，*宽松相等*（loose equality）`==` 规定了按两边种类进行转换的规则；*严格相等*（strict equality）`===` 则不做这种转换，不同种类的操作数直接判为不相等。把两种比较放在一起看：

```javascript
true + 1;    // 2：true 转换为 1

[] == 0;     // true
[] === 0;    // false
0 == "0";    // true
0 === "0";   // false
[] == "0";   // false
[] === "0";  // false
```

#fig({
  import "@preview/fletcher:0.5.8" as fletcher: diagram, edge, node
  let nd(pos, body) = node(pos, body, fill: blue.lighten(85%), stroke: 0.8pt + blue, corner-radius: 4pt, inset: 7pt)
  let comparison(loose) = text(size: 9pt)[
    #text(fill: if loose { green.darken(20%) } else { red })[`==` → #if loose [`true`] else [`false`]] \
    #text(fill: gray.darken(30%))[`===` → `false`]
  ]
  diagram(
    spacing: (32mm, 24mm),
    nd((0, 0), [`0`]),
    nd((-1, 1), [`[]`]),
    nd((1, 1), [`"0"`]),
    edge((0, 0), (-1, 1), "-", label: comparison(true), label-side: right, stroke: 1pt + green),
    edge((0, 0), (1, 1), "-", label: comparison(true), label-side: left, stroke: 1pt + green),
    edge((-1, 1), (1, 1), "-", label: comparison(false), label-side: right, stroke: (paint: red, dash: "dashed")),
  )
})

图中每条边同时列出 `==` 和 `===` 的结果，不是归约箭头。绿色实线表示 `==` 为真，红色虚线表示 `==` 为假；第二行单独记录 `===`，这里三条边都为假。

`[] == 0` 会先把空数组转换成空字符串 `""`，再因另一边是数字而把 `""` 转成 `0`；`0 == "0"` 会把字符串 `"0"` 转成数字 `0`，所以这两条边都为真。但 `[] == "0"` 把数组转成 `""` 后，两边已经都是字符串，只比较 `""` 与 `"0"`，结果为假。具体转换规则见 #link("https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Operators/Equality")[MDN 的 `==` 文档]。

*传递性*（transitivity）要求：$a$ 与 $b$ 相等、$b$ 与 $c$ 相等，就能推出 $a$ 与 $c$ 相等。这个三角图正好展示 `==` 不满足传递性，不能像数学等号那样用于替换或推理。`===` 不会做上述转换：数组、数字、字符串种类不同，所以这三个比较都为假。它回答的是另一个问题，而不是“同一套转换做得更严格”。

但 `===` 也不等于完整的数学等价关系。*自反性*（reflexivity）要求每个值都与自身相等，而 `NaN === NaN` 为 `false`。对对象，`===` 比较的是是否为同一个对象，不是内容是否相同：`const a = []; a === a` 为 `true`，`[] === []` 却为 `false`，因为后者创建了两个不同的数组。严格相等的完整规则见 #link("https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Operators/Strict_equality")[MDN 的 `===` 文档]。
