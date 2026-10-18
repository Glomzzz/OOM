
#import "/lib/lib.typ": *

#show: schema.with("page")

#title[寻径]
#metacontent("description")[生命不熄，控制终将失灵．]
#metacontent("show-metadata")[false]
#date[2026-08-14]
#author[Glomzzz]
#heading-numbering("none")
#sidebar("only-embed")
#parent("/index.typ")


#let part(slug) = embed(slug, show-metadata: true, open: false, sidebar: "only-title")

= #part("./daily/index.typ")

= #part("./plt/index.typ")

= #part("./rust/index.typ")

= #part("./style.typ")

= #part("./terms.typ")
