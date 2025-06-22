
#import "/lib/lib.typ": *

#show: schema.with("page")

#title[自然哲学]
#date[2025-06-21 N/A]
#author[Gemini DeepResearch]

#let part(slug) = embed(slug,show-metadata: true, open: false)


= #part("./intro.typ")
= #part("./mechanik.typ")
= #part("./physik.typ")
= #part("./organ-physik.typ")
= #part("./legacy.typ")
