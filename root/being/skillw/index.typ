#import "/lib/lib.typ": *

#show: schema.with("page")

#title[Skillw Project on Minestom]
#date[2025-09-22 20:15]
#author[Glomzzz]
#heading-numbering("none")
#sidebar("only-embed")

#let part(slug) = embed(slug,show-metadata: true, open: false, sidebar: "only-title")

= #part("./intro.typ")

= #part("./overview.typ")
