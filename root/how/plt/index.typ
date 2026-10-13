#import "/lib/lib.typ": *

#show: schema.with("page")
#title[PLT]
#date[2026-10-08]
#author[Glomzzz]
#heading-numbering("none")
#sidebar("only-embed")

#let part(slug) = embed(slug, show-metadata: true, open: false, sidebar: "only-title")

这里会收集成体系的*PLT*(_Programming Language Theory_)文章。

= #part("./prelude.typ")
= #part("./intro.typ")
= #part("./formal/index.typ")
