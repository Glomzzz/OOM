#import "/lib/lib.typ": *

#show: schema.with("page")

#title[Beginning]
#date[2024-05-13]
#author[Glomzzz]
#heading-numbering("none")
#sidebar("only-embed")

#let part(slug) = embed(slug,show-metadata: true, open: false, sidebar: "only-title")

= #part("being/index.typ")
 
= #part("alien/index.typ")
