#import "lib.typ": html, auto-filter, inline

// ---------- 记号 ----------
// 推导规则：rule(名字, 前提.., 结论)
#let rule(name, ..args) = {
  let ps = args.pos()
  let c = ps.pop()
  let top = if ps.len() == 0 { $space$ } else { ps.join(h(1.6em)) }
  $ frac(#top, #c) #h(0.3em) #text(size: 0.8em, baseline: 0.45em, smallcaps(name)) $
}
#let dmath(eq, scale: 150%) = context {
  if target() == "html" { auto-filter(inline(scale: scale, eq)) } else { eq }
}
#let rules(..rs) = context {
  if target() != "html" {
    for r in rs.pos() { align(center, r) }
  } else {
    html.div(
      style: "display: flex; flex-wrap: wrap; justify-content: center; align-items: flex-end; column-gap: 3em; row-gap: 1.2em; margin: 1.4em 0;",
      rs.pos().map(r => html.span(style: "display: inline-block; max-width: 100%; overflow-x: auto;", dmath(r))).join(),
    )
  }
}
#let bigmath(eq, scale: 150%) = context {
  if target() != "html" {
    align(center, eq)
  } else {
    html.div(style: "text-align: center; overflow-x: auto; margin: 1.4em 0;", dmath(eq, scale: scale))
  }
}
// 推导树：inf(名字, 子推导.., 结论)；每层用 display 防止嵌套 frac 逐层缩小
#let inf(name, ..args) = {
  let ps = args.pos()
  let c = ps.pop()
  let top = if ps.len() == 0 { $space$ } else { ps.map(math.display).join(h(2em)) }
  $display(frac(#top, display(#c))) #h(0.3em) #text(size: 0.8em, smallcaps(name))$
}
#let stp = sym.arrow.r.long // ⟶ 一步归约
#let stps = $attach(stp, tr: *)$ // ⟶* 多步归约
#let tB = $"Bool"$
#let tN = $"Nat"$
#let nv = $italic("nv")$
// 算术语言证明中的术语回链，复用全站条目引用接口。
#let ih = {
  import "statements.typ": statement-term
  statement-term("definition/induction-hypothesis")[归纳假设]
}
// 图：fletcher / cetz 画的图统一用 SVG 内联，白底配合暗色模式的 auto-filter
#let fig(body) = context {
  let figure = block(inset: 8pt, {
    set text(font: ("Libertinus Serif", "Noto Sans CJK SC"), size: 10pt)
    body
  })
  if target() != "html" {
    align(center, figure)
  } else {
    html.align(center)[#auto-filter(inline(scale: 140%, figure))]
  }
}

#let wiki(page, name) = link("https://zh.wikipedia.org/wiki/" + page, name)
#let enwiki(page, name) = link("https://en.wikipedia.org/wiki/" + page, name)
