#import "/lib/lib.typ": *

#show: schema.with("page", head: [
  #unique[
    #html.tag(
      "link",
      rel: "stylesheet",
      href: "https://fonts.googleapis.com/css2?family=Noto+Serif+SC:wght@400;600;700&family=Cormorant+Garamond:wght@500;600;700&family=LXGW+WenKai+TC&display=swap",
    )[]
  ]
])

#heading-numbering("none")

#title[评《赛博朋克：边缘行者》第二季]
#page-title[夜之城和解大师]
#date[2026-10-24 05:22]
#author[Glomzzz]
#parent("/being/index.typ")

#let crimson(body) = html.text(fill: rgb("#a13d4b"), weight: "bold", body)
#let indigo(body) = html.text(fill: rgb("#435d7a"), weight: "bold", body)
#let amber(body) = html.text(fill: rgb("#9a6528"), weight: "bold", body)
#let muted(body) = html.text(fill: rgb("#75756e"), body)

#let picture(src, alt, style: "width: 100%; height: auto; border-radius: 6px;") = html.img(
  src: src,
  alt: alt,
  loading: "lazy",
  style: style,
)[]

#crimson[编剧似乎把“赛博朋克”里的“高科技、低生活”，曲解成了纯粹的“底层牛马受难记”．]第一季的大卫是在被体制一步步逼入绝境后选择用义体武装自己、向荒坂大厦挥拳；而第二季呢？满屏的东亚式大家长压抑感、自我感动式的苦难咀嚼，仿佛夜之城的霓虹灯只是为了给“赛博力工”加班照亮道路．我来看《边缘行者》是为了看反叛者如何在企业帝国的夹缝中以我残躯化烈火，不是为了在 2077 年的未来世界里，看一群人重演现实中就已经够让人窒息的“老中式家长”和“力工 TV”．

说到底，这一季的角色根本没有自己的灵魂，全都是编剧为了推进特定桥段而强行捏造的提线木偶．12 岁小孩对粉毛女主的感情完全是#crimson[“因为剧本需要他推动剧情，所以他必须立刻爱上！”]，毫无荷尔蒙或心理层面的合理过渡；而那个复仇者“佐助”放下仇恨的转折，更是把沉重的血海深仇儿戏化成了嘴炮洗白．在夜之城这种人命如草芥的地方，连恨意都能如此廉价地蒸发，连爱意都能如此草率地生成，观众又怎么可能对这群纸片人产生哪怕一秒钟的共情？

#html.align(center)[
  #picture(
    "/being/edgerunners-season-two-01.jpg",
    "《边缘行者》第二季剧照",
    style: "width: 100%; max-width: 42em; height: auto; border-radius: 6px;",
  )
]

= 关于结局

关于结局……第一季的大卫在亚当·重锤的炮口下哪怕被打成肉泥，眼里也是对这个操蛋世界的不甘；而第二季的男主 D，在荒坂、军用科技和康陶三大巨头大军压境时，居然在靠芯片合体、机械降神之后，特意转过头对着 12 岁小孩那台 30 毫米胶卷摄像机，露出了一个“与世界和解”的灿烂微笑，然后化作一道光飞向星空．

看到那一刻我简直气笑了——我们在现实世界里已经被大厂内卷、生活重压和东亚式家长的催逼折磨得够呛了，打开《2077》就是为了借强尼·银手的核弹和大卫的义体，去感受#amber[“以我残躯化烈火”]；结果第二季的编剧却在赛博朋克的坟头上，给我们拉了一泡最恶心的屎：别复仇了，别恨体制了，只要你学会精神内耗、学会对着复古胶卷滤镜微笑，哪怕被资本轰成渣，你也算迎来了“自己故事的高潮”．

原来到了 2077 年，底层牛马的终极归宿也不是什么掀翻荒坂塔，是#crimson[他妈戴上你那 30 毫米胶卷的伪文艺滤镜，笑着完成自我感动式的赛博殉职]．

#html.align(center)[
  #picture(
    "/being/edgerunners-season-two-02.jpg",
    "《边缘行者》第二季结局画面",
    style: "width: 100%; max-width: 24em; height: auto; border-radius: 6px;",
  )
]

#html.div(style: "text-align: center; margin: 1.6em auto; max-width: 42em;")[
  #html.text(size: 135%, weight: "bold", fill: rgb("#435d7a"))[建议改名为《夜之城和解大师》，和童子军大王做一桌吧．]
]

= 写在最后

给编剧塞几个#crimson[智力斗篷]吧．

#html.div(
  style: "display: flex; flex-wrap: wrap; justify-content: center; align-items: flex-start; gap: 0.7em; max-width: 42em; margin: 1.4em auto;",
)[
  #picture(
    "/being/edgerunners-season-two-03.png",
    "吐槽表情图一",
    style: "width: 28%; min-width: 70px; height: auto; border-radius: 6px;",
  )
  #picture(
    "/being/edgerunners-season-two-03.png",
    "吐槽表情图二",
    style: "width: 28%; min-width: 70px; height: auto; border-radius: 6px;",
  )
  #picture(
    "/being/edgerunners-season-two-03.png",
    "吐槽表情图三",
    style: "width: 28%; min-width: 70px; height: auto; border-radius: 6px;",
  )
]
