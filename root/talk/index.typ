
#import "/lib/lib.typ": *

#show: schema.with("page")

#title[往复]
#metacontent("description")[收录问答与讨论，留下观点的交锋，也留下交谈中尚未说尽的问题。]
#metacontent("show-metadata")[false]
#date[2026-05-03]
#author[Glomzzz et al.]
#heading-numbering("none")
#sidebar("only-embed")
#parent("/index.typ")


#let part(slug) = embed(slug, show-metadata: true, open: false, sidebar: "only-title")

= #part("./no-exit-keep-asking.typ")
