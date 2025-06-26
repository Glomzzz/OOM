
#import "/lib/lib.typ": *

#show: schema.with("page")

#title[存在]
#date[XXXX-09-26]
#author[Glomzzz]
#heading-numbering("none")
#sidebar("only-embed")


#let part(slug) = embed(slug,show-metadata: true, open: false, sidebar: "only-title")

= #part("./new-ssg.typ")
= #part("./religion.typ")
= #part("./typ-svg.typ")


