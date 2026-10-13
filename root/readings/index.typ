#import "/lib/lib.typ": *

#show: schema.with("page")

#title[拾遗]
#metacontent("description")[碎片与未竟之事．]
#metacontent("show-metadata")[false]
#date[]
#author[Glomzzz]
#heading-numbering("none")
#sidebar("only-embed")
#parent("/index.typ")

#let part(slug) = embed(slug, show-metadata: true, open: false, sidebar: "only-title")

= #part("./religion.typ")
= #part("./second-person.typ")
= #part("./nick-land-peter-thiel-and-dark-enlightenment.typ")
