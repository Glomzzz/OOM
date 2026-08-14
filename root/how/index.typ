
#import "/lib/lib.typ": *

#show: schema.with("page")

#title[HOW]
#date[2026-08-14]
#author[Glomzzz]
#heading-numbering("none")
#sidebar("only-embed")
#parent("/index.typ")


#let part(slug) = embed(slug, show-metadata: true, open: false, sidebar: "only-title")

= #part("./deepseek-harness.typ")
