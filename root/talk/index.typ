
#import "/lib/lib.typ": *

#show: schema.with("page")

#title[对话录]
#date[2026-05-03]
#author[Glomzzz et al.]
#heading-numbering("none")
#sidebar("only-embed")
#parent("/index.typ")


#let part(slug) = embed(slug, show-metadata: true, open: false, sidebar: "only-title")

= #part("./no-exit-keep-asking.typ")
