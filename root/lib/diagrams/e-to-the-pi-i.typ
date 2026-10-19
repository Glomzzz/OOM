#import "/lib/lib.typ": html, auto-filter, inline
#import "@preview/cetz:0.3.4" as cetz
#import "common.typ": diagram, diagram-colors

// 本文各图共用的数轴、点和跳跃箭头；距离按线性比例绘制．
#let number-axis(ticks, y: 0, unit: 1, origin: 0, left: -5.4, right: 5.4) = {
  import cetz.draw: *
  line((left, y), (right, y), stroke: 0.8pt + diagram-colors.axis, mark: (start: "stealth", end: "stealth"))
  for n in ticks {
    let x = origin + unit * n
    line((x, y - 0.09), (x, y + 0.09), stroke: 0.7pt + diagram-colors.axis)
    content((x, y - 0.35), $#n$)
  }
}

#let number-dot(pos, tint: diagram-colors.blue) = {
  import cetz.draw: circle
  circle(pos, radius: 0.075, fill: tint, stroke: 0.6pt + white)
}

#let number-hop(start, end, label, height: 0.9, tint: diagram-colors.blue) = {
  import cetz.draw: *
  bezier(start, end, (start.at(0), start.at(1) + height), (end.at(0), end.at(1) + height), stroke: 1.3pt + tint, mark: (
    end: "stealth",
  ))
  let side = if height > 0 { 1 } else { -1 }
  content(
    ((start.at(0) + end.at(0)) / 2, start.at(1) + 0.75 * height + side * 0.25),
    text(fill: tint, label),
  )
}

#let counting-panels() = context {
  import cetz.draw: *

  let squares(n, tint, start: 0.25) = {
    for k in range(n) {
      let x = start + k
      rect(
        (x, 0.35),
        (x + 0.7, 1.05),
        fill: tint.lighten(65%),
        stroke: 0.8pt + tint.darken(15%),
      )
    }
  }

  let panel(heading, formula, note, tint, drawing) = block(inset: 4pt, {
    set text(font: ("Libertinus Serif", "Noto Sans CJK SC"), size: 9pt)
    cetz.canvas(length: 0.85cm, {
      rect(
        (-0.5, -1.3),
        (5.7, 2.2),
        stroke: 0.6pt + gray.lighten(65%),
      )
      content((2.6, 1.75), text(fill: tint.darken(20%), heading))
      drawing
      content((2.6, -0.15), formula)
      content((2.6, -0.85), note)
    })
  })

  let panels = (
    panel(
      [*正整数：一个一个数*],
      $1 + 1 + 1 + 1 = 4$,
      [每块都完整，数完就是 $4$．],
      blue,
      {
        squares(4, blue, start: 0.75)
      },
    ),
    panel(
      [*$4.2$：得先切开一个*],
      $4.2 = 4 + frac(1, 5)$,
      [第五块只取五等份中的一份．],
      orange,
      {
        squares(4, orange)
        rect(
          (4.25, 0.35),
          (4.95, 1.05),
          fill: orange.lighten(94%),
          stroke: none,
        )
        rect(
          (4.25, 0.35),
          (4.39, 1.05),
          fill: orange.lighten(35%),
          stroke: none,
        )
        for k in range(1, 5) {
          let x = 4.25 + k * 0.14
          line(
            (x, 0.35),
            (x, 1.05),
            stroke: 0.5pt + orange.darken(15%),
          )
        }
        rect(
          (4.25, 0.35),
          (4.95, 1.05),
          fill: none,
          stroke: 0.8pt + orange.darken(15%),
        )
      },
    ),
    panel(
      [*$pi$：三个，再加多少？*],
      $pi = 3.14159265 dots$,
      [小数无限不循环，阴影仅示意．],
      purple,
      {
        squares(3, purple, start: 0.75)
        rect(
          (3.75, 0.35),
          (4.45, 1.05),
          fill: purple.lighten(94%),
          stroke: none,
        )
        // 有限精度的绘图只示意这个部分，不表示精确构造．
        rect(
          (3.75, 0.35),
          (3.75 + 0.7 * (calc.pi - 3), 1.05),
          fill: purple.lighten(35%),
          stroke: none,
        )
        rect(
          (3.75, 0.35),
          (4.45, 1.05),
          fill: none,
          stroke: 0.8pt + purple.darken(15%),
        )
      },
    ),
    panel(
      [*$sqrt(-1)$：计数模型失效*],
      $n^2 >= 0$,
      [没有平方后等于 $-1$ 的个数．],
      red,
      {
        for row in range(2) {
          for col in range(2) {
            let x = 0.55 + col * 0.5
            let y = 0.25 + row * 0.5
            rect(
              (x, y),
              (x + 0.42, y + 0.42),
              fill: red.lighten(75%),
              stroke: 0.6pt + red.darken(15%),
            )
          }
        }
        content((1.01, 1.35), $n times n$)
        line(
          (1.8, 0.7),
          (3.65, 0.7),
          mark: (end: "stealth"),
          stroke: 0.8pt + gray,
        )
        line((2.55, 0.5), (2.95, 0.9), stroke: 1.5pt + red)
        line((2.55, 0.9), (2.95, 0.5), stroke: 1.5pt + red)
        content((4.35, 0.7), text(size: 17pt, fill: red)[$-1$])
      },
    ),
  )

  if target() == "html" {
    html.div(
      style: "display: flex; flex-wrap: wrap; justify-content: center; gap: 0.8em; max-width: 40em; margin: 1.2em auto;",
      panels.map(p => auto-filter(inline(p))).join(),
    )
  } else {
    align(center, std.grid(columns: (auto, auto), gutter: 8pt, ..panels))
  }
}

#let number-line() = diagram(
  [数轴：先钉住 $0$，再选定一个单位],
  [左边是负数，右边是正数；每相邻两格相差 $1$．],
  {
    import cetz.draw: *
    number-axis(range(-4, 5), unit: 1.1)
    line((0, 0), (1.1, 0), stroke: 2.5pt + diagram-colors.blue)
    number-dot((0, 0), tint: diagram-colors.ink)
    number-dot((1.1, 0))
    number-dot((3.3, 0), tint: diagram-colors.purple)
    line((0, 0.65), (1.1, 0.65), stroke: 1pt + diagram-colors.blue)
    for x in (0, 1.1) {
      line((x, 0.5), (x, 0.8), stroke: 1pt + diagram-colors.blue)
    }
    content((0.55, 1.1), text(fill: diagram-colors.blue)[一个单位])
    content((3.3, 0.55), text(fill: diagram-colors.purple)[$n = 3$])
    content((-3.1, 1.1), text(fill: diagram-colors.orange)[负数 $arrow.l$])
    content((4.3, 1.1), text(fill: diagram-colors.blue)[$arrow.r$ 正数])
  },
  top: 2.2,
  bottom: -1.3,
)

#let translation() = diagram(
  [加 $3$：往右搬；减 $3$：往回搬],
  [平移时，每个点都移动同样远，单位长度不变．],
  {
    import cetz.draw: *
    // 两行使用同一把尺，斜箭头表示原来的点一起右移．
    let pos(n, y) = (-2.2 + n * 0.8, y)
    number-axis(range(-2, 9), y: 1.1, unit: 0.8, origin: -2.2)
    number-axis(range(-2, 9), y: -1.1, unit: 0.8, origin: -2.2)
    content((-4.65, 1.45), [原来])
    content((-4.65, -0.75), [平移后])
    for n in (0, 2, 3) {
      line(pos(n, 0.95), pos(n + 3, -0.95), stroke: 0.8pt + diagram-colors.guide, mark: (end: "stealth"))
    }
    line(pos(1, 0.95), pos(4, -0.95), stroke: 1.8pt + diagram-colors.blue, mark: (end: "stealth"))
    number-dot(pos(1, 1.1))
    number-dot(pos(4, -1.1))
    content((-1.4, 1.65), text(fill: diagram-colors.blue)[$x = 1$])
    content((1.05, -0.65), anchor: "west", frame: "rect", stroke: none, padding: 0.05, text(
      fill: diagram-colors.blue,
    )[$z = 4$])
    content((2.7, 0.25), text(fill: diagram-colors.blue)[$1 + 3 = 4$])
    number-hop(pos(4, -1.1), pos(1, -1.1), [$-3$：回到 $1$], height: -0.9, tint: diagram-colors.orange)
  },
  top: 2.7,
  bottom: -2.9,
)

#let scaling() = diagram(
  [乘以 $2$：钉住 $0$，把刻度均匀拉开],
  [先放大，再按 $0$ 翻转；除以 $2$ 就把放大倒过来．],
  {
    import cetz.draw: *
    line((0, 0), (0, 1.35), stroke: (paint: diagram-colors.axis, thickness: 0.7pt, dash: "dashed"))
    for (y, label) in ((1.9, [原来]), (-0.15, [乘以 $2$]), (-2.5, [再乘以 $-1$])) {
      number-axis(range(-4, 6), y: y, unit: 0.95)
      content((-4.5, y + 0.55), label)
      number-dot((0, y), tint: diagram-colors.ink)
    }
    line((0, 1.9), (0.95, 1.9), stroke: 2pt + diagram-colors.blue)
    line((0, -0.15), (1.9, -0.15), stroke: 2pt + diagram-colors.blue)
    line((0.95, 1.75), (1.9, 0), stroke: 1.2pt + diagram-colors.blue, mark: (end: "stealth"))
    line((1.9, 1.75), (3.8, 0), stroke: 1.5pt + diagram-colors.purple, mark: (end: "stealth"))
    number-dot((0.95, 1.9))
    number-dot((1.9, 1.9), tint: diagram-colors.purple)
    number-dot((1.9, -0.15))
    number-dot((3.8, -0.15), tint: diagram-colors.purple)
    content((-1.3, 0.85), [零点不动])
    content((3.8, 1.05), text(fill: diagram-colors.purple)[$2 times 2 = 4$])
    number-hop((3.8, -2.5), (-3.8, -2.5), [$2 times (-2) = -4$], height: 1.15, tint: diagram-colors.orange)
    number-dot((3.8, -2.5), tint: diagram-colors.purple)
    number-dot((-3.8, -2.5), tint: diagram-colors.orange)
  },
  top: 3.3,
  bottom: -3.7,
)

#let powers() = diagram(
  [乘方：从 $1$ 出发，把同一种缩放重复做],
  [每行各用一把尺；相同倍率，不代表相同距离．],
  {
    import cetz.draw: *
    content((-5.35, 3.05), anchor: "west", [做三次])
    let grow(n) = (-4.4 + 0.8 * n, 1.95)
    number-axis((0, 1, 2, 4, 8), y: 1.95, unit: 0.8, origin: -4.4)
    for (a, b) in ((1, 2), (2, 4), (4, 8)) {
      number-hop(grow(a), grow(b), [$times 2$], height: 0.65)
    }
    for n in (1, 2, 4, 8) { number-dot(grow(n)) }
    content((-3.6, 1.1), text(size: 9pt)[$2^0 = 1$])
    content((4.25, 2.5), text(fill: diagram-colors.blue)[$2^3 = 8$])

    content((-5.35, 0.4), anchor: "west", [倒着做三次])
    let shrink(n) = (-4.4 + 6 * n, -0.65)
    number-axis((), y: -0.65)
    for (n, label) in ((0, $0$), (1 / 8, $1/8$), (1 / 4, $1/4$), (1 / 2, $1/2$), (1, $1$)) {
      let x = shrink(n).at(0)
      line((x, -0.74), (x, -0.56), stroke: 0.7pt + diagram-colors.axis)
      content((x, -1.03), label)
    }
    for (a, b) in ((1, 1 / 2), (1 / 2, 1 / 4), (1 / 4, 1 / 8)) {
      number-hop(shrink(a), shrink(b), [$times frac(1, 2)$], height: 0.65, tint: diagram-colors.orange)
    }
    for n in (1, 1 / 2, 1 / 4, 1 / 8) { number-dot(shrink(n), tint: diagram-colors.orange) }
    content((3.7, -0.1), text(fill: diagram-colors.orange)[$2^(-3) = 1/8$])

    content((-5.35, -2.15), anchor: "west", [把一次缩放拆成两步])
    let half(n) = (-4.4 + 0.75 * n, -3.2)
    number-axis((0, 1, 3, 9), y: -3.2, unit: 0.75, origin: -4.4)
    for (a, b) in ((1, 3), (3, 9)) {
      number-hop(half(a), half(b), [$times 3$], height: 0.65, tint: diagram-colors.purple)
    }
    for n in (1, 3, 9) { number-dot(half(n), tint: diagram-colors.purple) }
    content((4.25, -2.75), text(fill: diagram-colors.purple)[$9^(1/2) = 3$])
  },
  top: 4.2,
  bottom: -4.4,
)

#let pi-length() = diagram(
  [$pi$：把半径为 $1$ 的半圆弧拉直],
  [紫色弧线与紫色线段一样长，长度都是 $pi$．],
  {
    import cetz.draw: *
    // 圆的半径和数轴的单位同为 1.2 个绘图单位．
    circle((-3.5, 0), radius: 1.2, stroke: 0.8pt + diagram-colors.guide)
    arc((-2.3, 0), start: 0deg, stop: 180deg, radius: 1.2, stroke: 2.5pt + diagram-colors.purple)
    line((-3.5, 0), (-2.3, 0), stroke: 1.3pt + diagram-colors.blue)
    number-dot((-3.5, 0), tint: diagram-colors.ink)
    content((-2.9, -0.35), text(fill: diagram-colors.blue)[$r = 1$])
    content((-3.5, 1.65), text(fill: diagram-colors.purple)[半个圆周])
    line((-1.95, 0.3), (-0.25, -0.45), stroke: 1pt + diagram-colors.axis, mark: (end: "stealth"))
    content((-1.05, 0.65), [拉直])
    number-axis(range(5), y: -0.7, origin: 0.2, unit: 1.2, left: -0.1, right: 5.5)
    let end = 0.2 + 1.2 * calc.pi
    line((0.2, -0.7), (end, -0.7), stroke: 2.5pt + diagram-colors.purple)
    number-dot((0.2, -0.7), tint: diagram-colors.ink)
    number-dot((end, -0.7), tint: diagram-colors.purple)
    line((end, -0.55), (end, 0.1), stroke: (paint: diagram-colors.purple, thickness: 0.7pt, dash: "dashed"))
    content((3.45, 0.5), text(fill: diagram-colors.purple)[$pi = 3.14159 dots$])
  },
  top: 2.8,
  bottom: -1.9,
)

#let imaginary-axis() = diagram(
  [多一个方向：把竖直向上的单位叫作 $i$],
  [横着走 $2$ 个单位，再向上走 $2$ 个单位，就到 $2 + 2i$．],
  {
    import cetz.draw: *
    let ox = -1.5
    let oy = -0.5
    for x in range(-2, 6) {
      line((ox + x, -2.5), (ox + x, 2.5), stroke: 0.4pt + diagram-colors.guide)
    }
    for y in range(-2, 4) {
      line((-3.5, oy + y), (3.5, oy + y), stroke: 0.4pt + diagram-colors.guide)
    }
    number-axis((-2, -1, 1, 2, 3, 4, 5), y: oy, origin: ox, left: -4.1, right: 4.5)
    content((ox - 0.3, oy - 0.35), $0$)
    line((ox, -2.8), (ox, 2.9), stroke: 1pt + diagram-colors.teal, mark: (start: "stealth", end: "stealth"))
    for (n, label) in ((-2, $-2i$), (-1, $-i$), (1, $i$), (2, $2i$)) {
      line((ox - 0.09, oy + n), (ox + 0.09, oy + n), stroke: 0.8pt + diagram-colors.teal)
      content((ox - 0.45, oy + n), text(fill: diagram-colors.teal, label))
    }
    content((4.8, -0.1), [实轴])
    content((ox, 3.15), text(fill: diagram-colors.teal)[虚轴])
    line((ox, oy), (ox, oy + 1), stroke: 2.5pt + diagram-colors.teal)
    line((ox, oy), (0.4, oy), stroke: 1.8pt + diagram-colors.blue, mark: (end: "stealth"))
    number-dot((ox, oy), tint: diagram-colors.ink)
    number-dot((ox, oy + 1), tint: diagram-colors.teal)
    line((ox, 1.5), (0.5, 1.5), stroke: (paint: diagram-colors.teal, thickness: 0.8pt, dash: "dashed"))
    line((0.5, -0.4), (0.5, 1.4), stroke: 1.8pt + diagram-colors.teal, mark: (end: "stealth"))
    line((1.05, 1.4), (1.05, -0.4), stroke: 1.3pt + diagram-colors.orange, mark: (end: "stealth"))
    number-dot((0.5, -0.5))
    number-dot((0.5, 1.5), tint: diagram-colors.teal)
    content((-0.15, 0.5), text(fill: diagram-colors.teal)[$+2i$])
    content((2.05, 0.5), text(fill: diagram-colors.orange)[$-2i$])
    content((1.55, 1.95), text(fill: diagram-colors.teal)[$2 + 2i$])
  },
  top: 4.1,
  bottom: -3.8,
)

#let multiply-by-i() = diagram(
  [乘以 $i$：长度不变，逆时针转四分之一圈],
  [两次四分之一圈就是半圈，与乘以 $-1$ 的效果相同．],
  {
    import cetz.draw: *
    circle((0, -0.1), radius: 1.9, stroke: (paint: diagram-colors.guide, thickness: 0.8pt, dash: "dashed"))
    line((-3.1, -0.1), (3.1, -0.1), stroke: 0.8pt + diagram-colors.axis, mark: (start: "stealth", end: "stealth"))
    line((0, -2.65), (0, 2.5), stroke: 0.8pt + diagram-colors.axis, mark: (start: "stealth", end: "stealth"))
    for (end, tint) in (
      ((1.9, -0.1), diagram-colors.blue),
      ((0, 1.8), diagram-colors.teal),
      ((-1.9, -0.1), diagram-colors.purple),
    ) {
      line((0, -0.1), end, stroke: 2pt + tint)
      number-dot(end, tint: tint)
    }
    number-dot((0, -0.1), tint: diagram-colors.ink)
    content((-0.3, -0.45), $0$)
    content((2.3, -0.45), text(fill: diagram-colors.blue)[$1$])
    content((0.35, 2.15), text(fill: diagram-colors.teal)[$i$])
    content((-2.4, -0.45), text(fill: diagram-colors.purple)[$-1$])
    content((0.4, -2.1), $-i$)
    for (start, tint) in ((8deg, diagram-colors.teal), (98deg, diagram-colors.purple)) {
      arc(
        (1.9 * calc.cos(start), -0.1 + 1.9 * calc.sin(start)),
        start: start,
        delta: 74deg,
        radius: 1.9,
        stroke: 1.8pt + tint,
        mark: (end: "stealth"),
      )
    }
    content((3.6, 1.55), text(fill: diagram-colors.teal)[$times i$])
    content((3.6, 1.05), text(size: 9pt)[第一次：$90 degree$])
    content((-3.8, 1.55), text(fill: diagram-colors.purple)[$times i$])
    content((-3.8, 1.05), text(size: 9pt)[第二次：再转 $90 degree$])
    content((0, -3.1), $1 times i = i, quad i times i = -1 quad => quad i^2 = -1$)
  },
  top: 3.5,
  bottom: -4.2,
)
