#import "/lib/lib.typ": *

#show: schema.with("page")

#title[$e^(pi i)=-1$]
#date[2026-10-19]
#author[Glomzzz]
#parent("/how/daily/index.typ")
#heading-numbering("none")

#import "@preview/cetz:0.3.4" as cetz

// 各图共用颜色、单位刻度和箭头；图中的距离按线性比例绘制．
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

$e^(pi i)=-1$ 是非常著名的一个公式，但是你真的理解它嘛？

我们不需要任何微积分或者高等数学的知识就可以理解它！

= 含义

首先从数字开始，人类最开始将数字简单地视作计数工具，但是随着数学的发展，出现了分数$4.2$，无理数$pi$甚至是虚数$sqrt(-1)$：

#context {
  import "@preview/cetz:0.3.4"
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

你觉得当你仍用*计数工具*去看待这些数时，直观嘛？

显然，这很不直观．

我们不妨以下面的视角来看待每一个数字和运算：

#diagram(
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

无限延伸的直线上的任何一个点，都可以被*数字*表示．
- 我们规定一个点为零点称作$0$，一个非零点为$1$，也可以称为一个单位．
- 对于任何一个数字$n$，它在直线上的位置就是从$0$到那里的长度为$n$个$1$．
- 对于任何一个负数$n$，它都在零点的左侧；而正数则在零点右侧．

#diagram(
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

使这条直线沿自身滑动的动作，我们称为*加法*
- 对一个数字$x$使用加法$y$，就是从$x$开始滑动$y$个单位到达$z$．
- 对于任何一个负数$y$，向零点的左边滑动，反之则右边．
- 定义$z - y = z + (-y) = x$，于是我们得到了*减法*．

#diagram(
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

使这条直线沿自身缩放的动作，我们称为*乘法*．
- 对一个数字$x$使用乘法$y$，就是固定零点，并将对应于$1$的点移动到与乘数本身相对应的点，同时保证所有点之间的间距均匀，原先$x$的位置变为结果$z$．
- 对于任何一个负数$y$，就是执行完上面的动作后，再将结果$z$按零点对称到另一边．
- 定义$z div y = z * (1/y) = x$，于是我们得到了*除法*和*分数*．

#diagram(
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

取$x > 0$：把“乘以$x$”看成一次固定零点的缩放，那么$x^y$就是*从$1$出发，连续做$y$次这种缩放*后到达的位置．
- 当$y = 0$时，就是*一次也不缩放*．从$1$出发，什么都不做，当然仍在$1$，所以$x^0 = 1$．
- 当$y$为负整数时，就是把缩放*倒着做*．例如，“乘以$2$”会把距离放大一倍，它的逆动作就是“乘以$1/2$”．因此$2^(-3)$表示从$1$开始，连续缩小三次，依次到达$1/2$、$1/4$、$1/8$．一般地，$x^(-n) = 1/(x^n)$．
- 当$y = 1/2$时，我们需要找到“半次缩放”：*连续做两次完全相同的动作，效果恰好等于乘以$x$*．例如，从$1$到$9$，可以先乘以$3$到达$3$，再乘以$3$到达$9$，所以$9^(1/2) = 3$．
- 同理，$x^(1/n)$就是把“乘以$x$”拆成$n$次相同的正比例缩放，每次的倍率就是$root(n, x)$．因此，对于正整数$m$、$n$，$x^(m/n) = (root(n, x))^m$：先找到这一个“小步”，再连续走$m$步．如果指数还带负号，就反着走，例如$9^(-1/2) = 1/sqrt(9) = 1/3$．
- 这些扩展都遵守同一个原则：*先做一段缩放，再做另一段缩放，等于把两段指数相加*，也就是$x^a * x^b = x^(a+b)$．于是，零次、负数次和分数次乘方，就可以统一为同一套缩放规则的延伸．

#diagram(
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

对于任何无理数，我们都能在直线上找到与其对应的一点．

例如$pi$，我们将定义为：$C_(r=1) = 2pi$ 也就是说，半径为1的圆，其周长的一半．

嘿，我们已经可以在这条直线上表达所有实数，以及$+$，$-$，$*$，$div$，$"^"$了！

？！圆！？

我们在此之前都在一条一维的直线上玩，现在圆却是个二维图形，有什么办法构造它呢？

我们不妨将现有的直线在零点处转动$90 degree$，这样我们就有两条轴，可以表达二维世界中的东东了！

如果将原先那条轴看作横着的话，那我们又如何在竖着的方向上进行移动和缩放呢？

让我们定义吧！

#diagram(
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

将竖着方向的一个单位定义为$i$，于是加法$n i$就是很直观地上下移动．

#diagram(
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

对于乘法，当我们定义：乘以$i$让两个轴所构成的平面旋转四分之一圈，于是连续乘以两次$i$，也就是$* i^2$，会让平面旋转旋转半圈，也就是．．．$* -1$！

所以当我们如此定义$i$时，会很自然地推导出：$i^2 = -1$，也就是说，$i = sqrt(-1)$！

未完待续．．．
