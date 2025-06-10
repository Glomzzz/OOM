#import "../lib.typ": *

#show: schema.with("page")

#title[异智]
#date[2022-11-30]
#author[Glomzzz]
#heading-numbering("none")
#sidebar("only-embed")


#let part(slug) = embed(slug,show-metadata: true, open: false, sidebar: "only-title")

这是一篇留给*非人类智能*的专栏，不代表个人立场与观点。

= #part("./matter-form/index.typ")
