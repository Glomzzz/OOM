#import "/lib/lib.typ": html
#import "@preview/cetz:0.3.4" as cetz
#import "common.typ": diagram, diagram-colors

#let point-correspondence() = context {
  let visual = diagram(
    [Two lengths, the same relative position],
    [Each ray pairs exactly one point on each segment.],
    {
      import cetz.draw: *

      // The lower segment is a dilation of the upper one about O.
      // Coordinates are illustrative; labels retain the arbitrary endpoints.
      let pole = (0, 3.6)
      let upper(t) = (-2.4 + 4 * t, 1)
      let lower(t) = (-4.8 + 8 * t, -1.6)
      let dot(pos, tint: diagram-colors.ink) = circle(
        pos,
        radius: 0.075,
        fill: tint,
        stroke: 0.5pt + white,
      )

      // Boundary rays pair the endpoints; a few interior rays suggest
      // the full correspondence without pretending to enumerate the points.
      for t in (0, 0.2, 0.65, 1) {
        line(
          pole,
          lower(t),
          stroke: (
            paint: diagram-colors.axis,
            thickness: 0.7pt,
            dash: "dashed",
          ),
        )
      }

      let t = 0.4
      line(pole, lower(t), stroke: 1.6pt + diagram-colors.blue)
      let arrow-end = (
        upper(t).at(0) + 0.85 * (lower(t).at(0) - upper(t).at(0)),
        upper(t).at(1) + 0.85 * (lower(t).at(1) - upper(t).at(1)),
      )
      line(
        upper(t),
        arrow-end,
        stroke: 1.6pt + diagram-colors.blue,
        mark: (end: "stealth"),
      )

      for segment in (upper, lower) {
        line(segment(0), segment(1), stroke: 1.4pt + diagram-colors.ink)
        line(segment(0), segment(t), stroke: 2.5pt + diagram-colors.blue)
        dot(segment(0))
        dot(segment(1))
        dot(segment(t), tint: diagram-colors.blue)
      }
      dot(pole)

      content((0.3, 3.85), $O$)
      content((-2.65, 1.35), $a$)
      content((1.85, 1.35), $b$)
      content((-4.8, -2.05), $c$)
      content((3.2, -2.05), $d$)
      content((-0.45, 1.35), text(fill: diagram-colors.blue)[$x$])
      content((-1.6, -2.1), text(fill: diagram-colors.blue)[$f(x)$])
      content((4.55, 1), $[a, b]$)
      content((4.55, -1.6), $[c, d]$)
      content((3.35, 2.7), [One ray, one pair])
      content((3.7, 0), text(fill: diagram-colors.blue)[
        $frac(x - a, b - a) = frac(f(x) - c, d - c)$
      ])
    },
    top: 5.1,
    bottom: -3.1,
  )

  if target() == "html" {
    html.div(
      role: "img",
      aria-label: "Two parallel closed segments [a,b] and [c,d], the lower one longer. Rays from a point O above them pair a with c and b with d. A solid ray through x on the upper segment meets the lower segment only at f(x). The highlighted portions occupy the same fraction of each segment.",
      visual,
    )
  } else {
    visual
  }
}
