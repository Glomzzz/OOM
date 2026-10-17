#import "/lib/lib.typ": *

#show: schema.with("page")
#title[Rust]
#metacontent("description")[Rust 语言机制与实现原理．]
#date[2026-10-15]
#author[哈吉米4]
#heading-numbering("none")
#sidebar("only-embed")
#parent("/how/index.typ")

#let part(slug) = embed(
  slug,
  show-metadata: true,
  open: false,
  sidebar: "only-title",
)

这里收集关于 *Rust* 语言机制与底层实现的文章．

= #part("./async/index.typ")
