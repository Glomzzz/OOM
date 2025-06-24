#import "/lib/lib.typ": *

#show: schema.with("page",
  head: [
    #unique[
      #html.tag(
      "link",
      rel: "stylesheet",
      href: "https://fonts.googleapis.com/css2?family=LXGW+WenKai+TC&amp;display=swap",
    )[]
    ]
  ])

#title[切换到#link("https://github.com/Glomzzz/typsite")[Typsite]]
#page-title[切换到Typsite]
#date[2025-06-08 11:45]
#author[Glomzzz]

#let LaTeX = {
  let A = (
    offset: (
      x: -0.33em,
      y: -0.3em,
    ),
    size: 0.7em,
  )
  let T = (
    x_offset: -0.12em,
  )
  let E = (
    x_offset: -0.2em,
    y_offset: 0.23em,
    size: 1em,
  )
  let X = (
    x_offset: -0.1em,
  )
  box(height: 0.92em)[
    L#h(A.offset.x)#text(size: A.size, baseline: A.offset.y)[A]#h(T.x_offset)T#h(E.x_offset)#text(size: E.size, baseline: E.y_offset)[E]#h(X.x_offset)X
  ]
}

#let LaTeX = auto-filter(inline(LaTeX,fit-font: true))

#let Typst = html.text(fill: teal)[Typst]

#let Markdown = html.text(fill: gray.lighten(25%))[Markdown]



去年4月, 我基于 #link("https://vitepress.dev/")[Vitepress] 开发了 #link("https://github.com/Skillw/Librorum")[Librorum], 作为能享受整个#link("https://www.npmjs.com/")[NPM] 生态且支持 #link("https://vuejs.org/")[Vue3] 的 #link("https://developer.mozilla.org/en-US/docs/Glossary/SSG")[SSG], 其功能是非常丰富的:

- 文章归档(Timeline)
- 分类, 标签, 词云, 全局搜索
- 个性化阅读配置(感谢 #link("https://github.com/LittleSound")[Ayaka] 与 #link("https://github.com/nekomeowww")[Neko])
- #{ LaTeX } 支持 (#link("https://www.npmjs.com/package/markdown-it-mathjax3")[markdown-it-mathjax3])
- And more...


#html.align(center)[#html.text(size: 175%)[*这听起来非常棒, 不是吗?*]]

\

但当你在阅读我那充斥着 _鬼画符_ 的Lambda Calculus页面与拉康精神分析文章, 并认为*效果海星*时, 在其背后却是这样的:
```tex
\begin{align*}
Y_v(M)(1)
&= D(1) \\
&= M\ (\lambda a.\, D(a))\ (1) \\
&= (\lambda f.\, \lambda n.\, \text{if } n = 0 \text{ then } 1 \text{ else } n \cdot f(n - 1))\ (\lambda a.\, D(a))\ (1) \\
&\Rightarrow 1 \cdot (\lambda a.\, D(a))(0) \\
&= 1 \cdot D(0) \\
&= 1 \cdot M\ (\lambda a.\, D(a))\ (0) \\
&= (\lambda f.\, \lambda n.\, \text{if } n = 0 \text{ then } 1 \text{ else } n \cdot f(n - 1))\ (\lambda a.\, D(a))\ (0) \\
&\Rightarrow 1 \cdot 1 \\
&= 1
\end{align*}
```

不得不说, 我的#{ LaTeX }编写体验#html.text(fill: red.darken(10%))[*十分糟糕*], 以及当我想画一点拉康鬼画符时, 我的编写体验与作为正文的#{ Markdown }是#html.text(fill: purple.darken(10%))[*非常割裂*]的...

当然这也不是我#details([脱更])[Partial Evaluation的坑光挖不填; 拉康精神分析只讲了最不重要的那部分...]的#details([借口])[ 哈哈, 我跑去读德古了]

\

#html.align(center)[#html.text(size: 175%)[*一刻也没有为#{ Markdown }哀悼, 立刻来到战场的是: #Typst*]]

\

众所周知, #Typst 既有 #{ Markdown } 的简洁, 也有 #{ LaTeX } 的力量(still growing), 但对我最重要的是: #Typst 提供了一种#html.text(fill: color.green)[*一致性*], 它是贯彻整个文章的书写体验的: _所见的一切都*可交流*_.

换句话说,

它提供的是这么一种*场域*, 在其中无论是作为富文本的文字还是作为非文字的画图/公式, 都在 #html.text(fill: orange)[*Content*] 之中保持着一致性, 例如, 我可以随地声明一段我将来会多次用到的片段, 并在之后甚至其他文章里随意调用.

- 在 #{ Markdown } + #{ LaTeX } 的组合中, 世界是线性的, 但会被一段段本应被细分的公式&画图部分所分裂, 在这些裂口中, 世界被割裂成了几个#html.text(fill: red.darken(25%))[*无法互相交流*]的部分;
- 而在 #Typst 之中, 世界是树状(even 图状)的, 并且那些理应被更加细分的内容是确实被细分了的(公式&画图), 并且这些内容与其他内容仿佛本来就是一体的, #html.text(fill: lime.darken(15%))[*他们之间没有隔阂: 它们本就都在同一个世界中*]

\

#html.align(center)[
  当然, 你可能会说:
  \
  #html.text(size: 175%, fill: purple.lighten(25%))[*如果只用 #{ LaTeX } 呢?*]
]

\

如果你说的是它那关于*书写体验上的一致性*, 那 _what can i say?_
- #{
    LaTeX
  } 允许你改写几乎任何层级的规则和格式, 你拥有堪称强迫症一般的排版上的绝对主权, 而代价却是复杂的语法与漫长的编译
  - 当然还有不是那么美好的错误处理系统, #html.text(fill: orange.lighten(45%))[我在 typsite 错误处理与恢复上也是有花了一番功夫...]

总之, #{ LaTeX } 贯彻着如此的宗旨: #html.text(fill: color.purple.lighten(35%))[*“你可以做任何事情，但你必须知道你在做什么。”*]

而 #Typst 则试图在自由度 & 一致性 & 可用性 之间找到平衡点, 不能不说的是, 它确确实实地做出了很多*策略性取舍*, 但于此同时它获得的是 可维护性 & 稳定性, 以及*高效的写作体验*.

这就得吹一波我们 #Typst 的实时预览了, 常规文章*亚秒级预览*就问你舒不舒服; #html.text(fill: orange.lighten(45%))[当然为了实现这一点, typsite也是从设计之初就走上了增量编译之路.]
#feature[关于 Typsite][][
  你可以通过 `typsite c --port 8000` 开启 *watch mode*, 并随着你对无论是文章还是配置的任何改动, typsite都会实时的同步并尽力做出最小量的编译.
]

对于我来说, #Typst 所尝试寻找的这一平衡点足够平衡, *确实好用*!

当然在读到这里时, 稍微混一点PL圈子的读者应该都能察觉到我这里提 #{ LaTeX } 与 #Typst 是在影射些什么了...

在文章的最后我想引用一段来自 #link("https://zhuanlan.zhihu.com/p/713721622")[lyzh : 作为意识形态的编程语言] 的片段:



#example[引用][][
  曾经追求表达力和自由（如Lisp等）失败了。

  状态、副作用、协作的复杂性要求我们戴上“规则”的镣铐跳舞：类型系统、限制副作用、规范依赖。

  *这是一种“自由的反转”：人受限而程序得以合作。*
]


#html.align(center)[
  #html.text(fill: purple.lighten(10%), size: 175%)[拥有绝对的自由就是拥有绝对的不自由]
  \
  \
  或者我们可以换句话说
  \
  \
  #html.text(fill: color.olive.lighten(10%), size: 175%)[*自由的反面不是约束，而是混乱*]
]
