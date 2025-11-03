#import "/lib/lib.typ": *

#show: schema.with("page", head: [
  #unique(html.tag(
    "link",
    rel: "stylesheet",
    href: "https://fonts.googleapis.com/css2?family=LXGW+WenKai+TC&amp;amp;display=swap",
  )[])
])


#title[FIT1045]
#date[2025-10-29 07:12]
#author[Glomzzz]
#parent("/index.typ")

#html.align(center)[
  #html.tag(
    "iframe",
    style: "border-radius:12px",
    src: "https://www.youtube.com/embed/H_Uy3q6NDMk?si=xYVGM4vutg1wBuTe",
    width: "100%",
    height: "352",
    frameBorder: "0",
    allowfullscreen: "",
    allow: "autoplay; clipboard-write; encrypted-media; fullscreen; picture-in-picture",
    loading: "lazy",
  )[]
]
