#import "/lib/lib.typ": *

#show: schema.with("page")
#title[编程语言理论]
#metacontent("description")[程序语言理论（PLT）]
#date[2026-10-08]
#author[Glomzzz]
#heading-numbering("none")
#sidebar("only-embed")

#let part(slug) = embed(
  slug,
  show-metadata: true,
  open: false,
  sidebar: "only-title",
)

这里收集成体系的*程序语言理论*（PLT）文章．

= #part("./intro.typ")
= #part("./formal/index.typ")
