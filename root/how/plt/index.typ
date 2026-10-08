#import "/lib/lib.typ": *

#show: schema.with("page", head: [
  #unique[
    #html.tag(
      "link",
      rel: "stylesheet",
      href: "/apple-music-theme.css",
    )[]
  ]
])
#title[PLT]
#date[2026-10-08]
#author[Glomzzz]
#heading-numbering("none")
#sidebar("only-embed")

#track-embed("https://embed.music.apple.com/my/song/spin/6810484116")

#let part(slug) = embed(slug, show-metadata: true, open: false, sidebar: "only-title")

这里会收集成体系的*PLT*(_Programming Language Theory_)文章。

= #part("./intro.typ")
