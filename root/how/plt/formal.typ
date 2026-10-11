// 兼容旧的 /how/plt/formal 与 #fm-* 链接；正文只有 formal/ 下的一份。
#import "/lib/formal.typ": *

#show: schema.with("page", head: [
  #unique(html.tag("link", rel: "canonical", href: "/how/plt/formal/index")[])
])

#title[形式化入门：从 BNF 到类型安全]
#date[2026-10-10]
#author[Glomzzz]
#parent("/how/plt/index.typ")
#heading-numbering("none")

本文已按主题拆分；#cite("/how/plt/formal/index.typ")[在新主页阅读]。旧入口与旧的定理锚点仍可使用。

#chapter("index.typ", open: true)
