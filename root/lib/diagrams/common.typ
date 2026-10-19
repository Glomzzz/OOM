#import "/lib/lib.typ": html, auto-filter, inline
#import "@preview/cetz:0.3.4" as cetz

// 统一配色、字体、边框，以及 HTML／分页输出的显示方式．
#let diagram-colors = (
  ink: rgb("26354a"),
  axis: rgb("8b98a8"),
  guide: rgb("dbe2ec"),
  blue: rgb("2878c8"),
  orange: rgb("ce691a"),
  purple: rgb("8054bd"),
  teal: rgb("16877e"),
)

#let diagram(heading, caption, drawing, top: 2.6, bottom: -2.2) = context {
  let visual = block(inset: 4pt, {
    set text(font: ("Libertinus Serif", "Noto Sans CJK SC"), size: 10pt, fill: diagram-colors.ink)
    cetz.canvas(length: 0.9cm, {
      import cetz.draw: *
      rect(
        (-6.2, bottom),
        (6.2, top),
        stroke: 0.6pt + diagram-colors.guide,
      )
      content((0, top - 0.45), strong(heading))
      drawing
      content((0, bottom + 0.4), text(size: 9pt, caption))
    })
  })
  if target() == "html" {
    html.div(class: "formal-figure", auto-filter(inline(visual)))
  } else {
    align(center, visual)
  }
}
