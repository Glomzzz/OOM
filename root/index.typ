#import "/lib/lib.typ": *

#show: schema.with("page")

#title[片羽]
#page-title[片羽]
#metacontent("show-metadata")[false]
#heading-numbering("none")
#sidebar("only-embed")

#let part(slug) = embed(slug, show-metadata: false, open: false, sidebar: "only-title")

= #embed("about/index.typ", show-metadata: false, open: true, sidebar: "only-title")

= #part("being/index.typ")
= #part("how/index.typ")
= #part("talk/index.typ")
= #part("readings/index.typ")
