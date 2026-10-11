# 形式化入门的文章结构

网站主页是 [`index.typ`](index.typ)，以原生 typsite embed 按顺序组合：

| 文件 | 主题 |
| --- | --- |
| `01-natural-and-formal.typ` | 自然语言的局限、对象语言与元语言 |
| `02-syntax.typ` | BNF、项的最小集合、结构归纳 |
| `03-evaluation.typ` | 值、一步归约、计算规则与同余规则 |
| `04-determinism.typ` | 推导归纳、确定性、Rust 求值器 |
| `05-normal-forms.typ` | 范式、受阻、多步归约 |
| `06-typing.typ` | 类型规则、反演、类型唯一 |
| `07-type-safety.typ` | 典范形式、进展、保型、类型安全 |
| `08-rules-and-algorithms.typ` | 检查算法的可靠性与完备性 |
| `09-test-and-proof.typ` | 用测试对照证明 |
| `10-summary.typ` | 总结与延伸阅读 |

七组练习沿用原题号。75 个正文条目统一放在 [`root/statements/`](../../../statements/)，
按 definition、theorem、lemma 等八类分目录，文件名是完整英文名称。
14 段证明保存在对应命题的文件里，标题与元数据也由该文件自身定义。
序章的八个环境示范同样使用这套全站条目，示范证明在 `theorem/theorem-environment.typ` 中。
一步归约的十条规则和类型判断的七条规则也在各自的定义文件里，单独打开即可读全。
原来的 `../formal.typ` 只是兼容入口，嵌入新主页，不再保存第二份正文。

## 编写与引用

文章与练习工具在 `/lib/formal.typ`，数学记号在 `/lib/formal-math.typ`。
全站的条目页面、嵌入与引用共用 `/lib/statements.typ`。
新文章使用：

```typst
#import "/lib/formal.typ": *
#show: formal-page.with(title: [文章标题])

= 小节标题
#statement("definition/set-of-terms")
这里使用 #refer("definition/set-of-terms")。
```

- `statement(key)` 是原生 embed，不是新的定理计数器。展开标题使用 typsite 的层级编号，
  再显示 `[taxon] 标题`。附注与注记默认折叠，其他种类默认展开。
- `refer(key)` 通过 typsite 的 cite 重写读取目标页面元数据，只显示 `[taxon] 标题`，不显示编号。
  没有 JavaScript 时仍是有效的独立页面链接，并记录依赖与反向链接。
- 不再维护外置 catalogue。文件自身的 `entry` 保存标题、作者、日期与返回文章；
  分类由路径得出，HTML 引用通过目标页面元数据解析，不导入目标正文。
- 新条目直接创建 `root/statements/分类/完整英文名称.typ`，把元数据、陈述和证明写在一起。
  写法见 [全站条目说明](../../../statements/README.md)。

引用键如 `definition/induction-hypothesis` 必须与文件路径对应；标题改变不应改变引用键。
`parent` 指向讲解这个条目的文章。
读者打开独立条目后，可以通过页首的返回链接回到该文章，通过 Backlinks 找到引用它的页面。

## 颜色、层级与跳转

- `.typsite/components/embed.html` 为原生 embed 输出 `data-slug`、`data-taxon`、
  `data-reference-id` 和可选的 `data-legacy-reference-id`。
- `.typsite/assets/embed.css` 按 taxon 使用 `theorem.css` 的同一套亮色／暗色颜色。
  嵌套块只给自身标题着色；悬停不会覆盖种类颜色。普通文章与主页默认 taxon 为空，
  不显示种类标签，左侧边框和 embed 背景均透明（悬停时也保持透明）；
  只有显式 taxon 的条目显示彩色边框与对应背景。
- `.typsite/assets/site-links.js` 是渐进增强：引用目标已经在当前页中时，改为就地锚点链接，
  并展开沿途的 `details`。重复嵌入同一条目时，选择离引用最近的那一份；
  标题旁的 slug 链接始终保留为独立页面入口。
- 旧 `formal#fm-*` 与 PLT 父页面的 `#3-fm-*` 链接通过稳定 ID 定位，
  不依赖新章节的编号。目录中的重复编号 ID 会移除，保留正文的锚点。
- typsite 包 0.1.0 的 `embed` 把 Typst 一级标题与导出的 `h2` 混用，且忽略显式层级值。
  全站 `site-embed` 只修正原生 `<embed heading_level>` 的层级，不另建计数器。
- typsite 0.1.7 增量缓存可能保留子条目上一次父页面的编号前缀。
  `site-links.js` 把 **typsite 已生成的局部末位编号** 接到实际父结构，同步锚点链接；
  不递增自定义计数器，也不从别的页面抓取编号。冷构建不需要这一步修正。
- Backlinks 采用链接列表，而不是把引用页面的全文再嵌回来，避免巨大的重复正文与锚点冲突。
- 旧独立条目网址 `/how/plt/formal/statements/fm-*` 不再保留，目录中没有重复正文或跳转页。

## 验证

```sh
typsite c --p packages

# PDF 复用同一份子文章与条目正文；无需维护单独的打印稿。
typst compile --features html --root root --font-path .typsite/assets/fonts \
  root/how/plt/formal/index.typ formal.pdf
```

可以在 Firefox 中打开构建后的页面，手动检查独立条目、折叠跳转、亮／暗色、手机宽度和无 JS 回退。
