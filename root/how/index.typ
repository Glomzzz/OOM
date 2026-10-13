
#import "/lib/lib.typ": *

#show: schema.with("page")

#title[寻径]
#metacontent("description")[写编程、数学与技术。循着问题追索原理，记下推导、尝试与实现。]
#metacontent("show-metadata")[false]
#date[2026-08-14]
#author[Glomzzz]
#heading-numbering("none")
#sidebar("only-embed")
#parent("/index.typ")


#let part(slug) = embed(slug, show-metadata: true, open: false, sidebar: "only-title")

= #part("./plt/index.typ")
