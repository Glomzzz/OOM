
#import "/lib/lib.typ": *

#show: schema.with("page")

#title[每日一记]
#metacontent("description")[日常学习笔记，会慢慢整理为成体系的文章．]
#metacontent("show-metadata")[false]
#date[2026-10-19]
#author[Glomzzz]
#heading-numbering("none")
#sidebar("only-embed")
#parent("/how/index.typ")


#let part(slug) = embed(slug, show-metadata: true, open: false, sidebar: "only-title")

= #part("./e-to-the-pi-i.typ")
