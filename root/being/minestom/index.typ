#import "/lib/lib.typ": *

#show: schema.with("page")

#title[Minestom Journey]
#date[2025-09-22 19:47]
#author[Glomzzz]
#heading-numbering("none")
#sidebar("only-embed")

#let part(slug) = embed(slug,show-metadata: true, open: false, sidebar: "only-title")

= #part("./basic.typ")

= #part("./bukkit.typ")
