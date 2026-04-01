#import "/lib/lib.typ": *

#show: schema.with("page", head: [
  #html.tag(
    "link",
    rel: "stylesheet",
    href: "/apple-music-theme.css",
  )[]

])

#title[Typsite二三想]
#page-title[Typsite二三想]
#date[2026-03-31 23:36]
#author[Glomzzz]

#track-embed("https://music.apple.com/my/song/post-spring/1876728649")


= 从何处开始？

一款良好的 *General Static Site Generator* (GSSG)，应当是一个 *Content Compiler* (CC)：

- 输入： 内容、模板、配置、资源
- 中间过程： 解析、建模、路由、聚合、渲染
- 输出： 编译为输出目标

我们当然可以顺理成章地对这一层层结构做抽象，就像这样：

- 输入： (typst), (markdown), (html), (txt), etc.
- 中间过程： 统一的, 语义足够丰富的中间表示
- 输出： 可部署的完整静态网站, pdf, etc.

那么，基于 #link("https://zhuanlan.zhihu.com/p/24756198")[Why Concrete Syntax Doesnt Matte] 文章中所提的观点，我们设计*GSSG*的重中之重应当是先设计一套良好的*中间表示*(Interprete Representation).

= 良好的中间表示？

我通常习惯于"Define it by what it does", 首先，我们应当至少有两层IR：
- 文章层 Slug -> Metadata@(Relations, etc.)
- 内容层 Slug -> Content@(Plain Text, Cite, Embed, etc.)

并且为了*性能*考虑，它们都应当是被*Flatten*的.

考虑到`Embed`的存在，在*渲染管线*(Rendering Pipeline)中，应当单独生成一层记录了完整依赖信息与内容的渲染节点

- 渲染层 Slug -> Pending@(Plain Text, Cite Content(&Metadata.title), Embed Content(&Pending) etc.)

= 本地编译缓存?

为了加快编译，所有IR层都应当被完全缓存，当某个文章内容变动时则单独重新生成此文章的IR，由于在渲染层中我们所保存的依赖状态均为引用，所以其它所有本身内容未变动的文章不再任何重新编译，我们已经在渲染层记录过文章间的依赖关系，于是我们只用通过查询依赖关系重新将受影响的文章重新渲染到HTML便可


= 实时热更新预览!

实时热更新预览可以极大地提高用户体验，通过编译到 Virtual DOM, 

WIP



