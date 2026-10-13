
#import "/lib/lib.typ": *

#show: schema.with("page")

#title("此间")
#metacontent("description")[渴望啃噬我们，如海啃噬陆地。]
#metacontent("show-metadata")[false]#date[XXXX-09-26]
#author[Glomzzz]
#heading-numbering("none")
#sidebar("only-embed")
#parent("/index.typ")


#let part(slug) = embed(slug, show-metadata: true, open: false, sidebar: "only-title")

= #part("./new-ssg.typ")
= #part("./typ-svg.typ")
= #part("./typsite-thinking.typ")
= #part("./all-about-lily-chou-chou.typ")
= #part("./on-sacred-mourning.typ")
= #part("./when-it-comes-to-odyssey.typ")
= #part("./on-mushoku-tensei.typ")
