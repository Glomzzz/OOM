#import "/lib/lib.typ": *

#show: schema.with("page")

#title[关于*Typsite*的*inline-svg*]
#page-title[关于Typsite的inline-svg]
#date[2025-06-26 12:45]
#author[Glomzzz]

花了 *1* 天时间，搞定了 typsite 的 *link in inline-svg*, 虽然最终效果还行，\
但由于#details([*typst-svg 本身对HTML的适配依然有很大的进步空间*])[直接把 TAG 和 LINK #link("https://github.com/typst/typst/blob/257764181e52332a00079b9e3af03823fde1a15d/crates/typst-svg/src/lib.rs#L210")[跳过]了可还行]，我的实现手段也*非常的草台*，总之在这个站点用用得了，我不是很打算将这个功能推送到 typsite 的主分支上。


= 效果预览

可以来看看效果：

#details-block(open:false,html.align(center)[效果展示])[

#auto-filter[
  #inline(scale: 200%)[
    #set text(font: "Inria Sans")
    test anchor goto in svg: #link(<anchor>)[goto!!!] \
    test external link goto in svg: #link("https://github.com/Glomzzz/typsite")[Source of typsite]
  ]
]

test anchor goto: #link(<anchor>)[goto!!!] \
test external link goto: #link("https://github.com/Glomzzz/typsite")[Source of typsite]


#let _process = {
  import "@preview/fletcher:0.5.8" as fletcher: diagram, node, edge
  import fletcher.shapes: house, hexagon, circle, rect


  let blob(pos, label, tint: white, ..args) = node(
    pos,
    align(center, label),
    width: 28mm,
    fill: tint.lighten(60%),
    stroke: 1pt + tint.darken(20%),
    corner-radius: 5pt,
    ..args,
  )


  let diagram = diagram(
    spacing: 21pt,
    cell-size: (14mm, 10mm),
    edge-stroke: 1pt,
    edge-corner-radius: 7pt,
    mark-scale: 70%,


    blob((0.35, 0.8), [*Input*], shape: house.with(angle: 30deg, dir: bottom), width: 15mm, tint: red),


    for x in (-.2, +.2) {
      edge((0.35, 1.4), (0.35 + x, 1.4), (0.35 + x, 2), "-|>")
    },

    edge("-|>", [_changed files_], label-side: right, label-pos: 0),

    blob((0.35, 2), [Compile Typst \ to HTML], width: auto, tint: orange),


    for x in (-.2, +.2) {
      edge((0.35, 2), (0.35 + x, 2), (0.35 + x, 2.9), "-|>")
    },

    edge("-|>"),

    blob((0.35, 3), [Pass HTML], tint: purple),

    for x in (-.2, +.2) {
      edge((0.35 + x, 3), (0.35 + x, 4), (0.35, 4), "-")
    },
    edge((0.35, 3), (0.35, 4.65), "r", "-|>"),

    blob((1, 4.65), [Dependency Analysis], tint: yellow, shape: hexagon),

    edge((0.35, 3), (1, 3), "--|>"),

    blob((1, 3), [Cache], width: auto, shape: circle, tint: maroon),

    edge(
      (1, 3),
      "d",
      (1, 3.8),
      "-",
      [_articles remain unchanged \ but require an update_],
      label-side: center,
      label-pos: 100%,
      label-size: 0.9em,
    ),

    edge((1, 4), (1, 4.65), "-|>"),

    edge((1, 4.65), (1.65, 4.65), (1.65, 4)),

    for x in (-.2, -.07, +.07, +.2) {
      edge((1.65, 4), (1.65 + x, 4), (1.65 + x, 3), "-|>")
    },


    blob((1.65, 3), [Pass Articles], tint: blue),
    for x in (-.2, -.07, +.07, +.2) {
      edge((1.65, 3), (1.65 + x, 3), (1.65 + x, 2), "-|>")
    },

    blob((1.65, 2), [Compose Pages \ with Schemas], tint: green, width: 30mm),


    for x in (-.2, -.07, +.07, +.2) {
      edge((1.65 + x, 2), (1.65 + x, 1.5), (1.65, 1.5), "-")
    },

    edge((1.65, 1.5), (1.65, 0.8), "-|>"),


    edge((0.35, 0.9), (0.35, 0.3), (1.65, 0.3), (1.65, 0.8), "..|>", [_Sync_]),

    blob((1.65, 0.8), [*Output*], shape: house.with(dir: bottom, angle: 30deg), width: 15mm, tint: red),


    edge((1, 3), (1, 0.8), "--|>"),

    blob((1, 0.8), [*Cache*], shape: house.with(dir: bottom, angle: 30deg), width: 15mm, tint: red),

    edge((0.2, 1.4), (-0.3, 1.4), ".."),
    blob((-0.3, 1.5), [.typ], width: auto, shape: rect, tint: gray),
    edge("..|>"),
    edge((0.15, 2.5), (-0.3, 2.5), ".."),
    blob((-0.3, 2.5), [.html], width: auto, shape: rect, tint: gray),

    edge((0.15, 3.5), (-0.3, 3.5), ".."),

    edge((-0.3, 2.5), (-0.3, 5.9), (1, 5.9), "..|>", [_Articles_], label-side: left),

    for y in (+.5, -.5) {
      edge((0.16, 5.9), (0.16, 5.9 + y), (1, 5.9 + y), "..|>")
    },

    edge((1, 4.65), (1, 5.4), ".."),

    blob((1, 5.4), [(Parents, Children, Cited, Citing)], width: 65mm, shape: rect, tint: gray),
    edge(".."),

    blob((1, 5.9), [{ Metadata, Sidebar, Embed ,Rewrite }], width: 65mm, shape: rect, tint: gray),
    edge(".."),

    blob((1, 6.4), [[Head,Body]], width: 65mm, shape: rect, tint: gray),


    edge((1, 5.9), (2.35, 5.9), (2.35, 2.55), "..|>"),
    for y in (+.5, -.5) {
      edge((1.84, 5.9), (1.84, 5.9 + y), (1, 5.9 + y), "..")
    },

    edge((1.85, 3.5), (2.35, 3.5), ".."),

    edge((1.85, 2.55), (2.35, 2.55), ".."),

    blob((2.35, 2.55), [Pendings @pendings], width: auto, shape: rect, tint: gray),
    edge("..|>"),
    blob((2.35, 1.5), [.html], width: auto, shape: rect, tint: gray),
    edge((1.55, 1.5), (2.35, 1.5), ".."),
  )
  diagram
}

#html.align(center)[
  #inline(block(fill: white)[#_process], scale: 200%)
]

#footnote[Contains content of an article, will be used to generate the HTML page.] <pendings>

this is where the `<anchor>` is <anchor>

]

