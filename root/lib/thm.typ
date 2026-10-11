// 定理环境：定义 / 定理 / 引理 / 推论 / 例 / 约定 / 附注 / 注记 / 证明
//
// 用法：
//   #show: schema.with("page", head: thm-head())
//   #theorem(title: [确定性], id: "fm-det")[ ... ]
//   #proof[ ... ]
//   见 #refer("fm-det")            // 渲染为可点击的「[定理7] 确定性」
//
// 每种环境各自从 1 开始计数（定义1、定义2……；定理1、定理2……），
// 引用时带上种类名，读者按「种类 + 编号」就能找到位置。
// HTML 中附注与注记使用默认关闭的 details，其他环境保持展开。
// id 会成为 HTML 锚点；同一页面可能嵌入多篇文章，建议为每篇加前缀。
#import "html.typ" as html
#import "@local/typsite:0.1.0": anchor, goto, unique
#import "site.typ": link-local-style

#let thm-counter(kind) = counter("oom-thm-env-" + kind)

#let thm-kinds = (
  definition: "定义",
  theorem: "定理",
  lemma: "引理",
  corollary: "推论",
  example: "例",
  convention: "约定",
  remark: "附注",
  philosophy: "注记",
)

/// 页面 head 里引入样式，配合 schema.with("page", head: thm-head())
#let thm-head() = unique(html.tag("link", rel: "stylesheet", href: "/theorem.css")[])

#let thm-env(kind, title: none, id: none, body) = {
  let name = thm-kinds.at(kind)
  let ctr = thm-counter(kind)
  ctr.step()
  context {
    let n = str(ctr.get().first())
    let head = [#name#n#if title != none [（#title）]]
    if target() != "html" {
      block(width: 100%, inset: (left: 0.8em, y: 0.4em), stroke: (left: 2pt + gray))[*#head* #body]
    } else {
      html.div(class: "thm thm-" + kind, {
        if id != none { anchor(id) }
        if kind in "philosophy" {
          html.details(class: "thm-details", {
            html.summary(class: "thm-head", head)
            html.div(class: "thm-body", body)
          })
        } else {
          html.div(class: "thm-head", head)
          html.div(class: "thm-body", body)
        }
      })
    }
  }
  // 供 refer 查询编号：计数器在这里已经步进过，取到的就是本环境的编号
  if id != none [#metadata((name: name, kind: kind, title: title))#label(id)]
}

#let definition = thm-env.with("definition")
#let theorem = thm-env.with("theorem")
#let lemma = thm-env.with("lemma")
#let corollary = thm-env.with("corollary")
#let example = thm-env.with("example")
#let convention = thm-env.with("convention")
#let remark = thm-env.with("remark")
#let philosophy = thm-env.with("philosophy")

/// 证明环境，末尾自动加 ∎
#let proof(title: none, body) = context {
  let head = if title == none [证明] else [证明（#title）]
  if target() != "html" {
    block[_#head._ #body #h(1fr) $square$]
  } else {
    html.div(class: "proof", {
      html.div(class: "proof-head", head)
      body
      html.div(class: "qed", title: "证毕", "∎")
    })
  }
}

/// 引用一个带 id 的环境，显示为「[定理7] 标题」并链接过去。
/// 编号徽标单独使用斜体与 taxon 的文字颜色，标题保留正文样式。
#let refer(id) = context {
  let found = query(label(id))
  if found.len() == 0 { panic("refer: 找不到 id " + id) }
  let el = found.first()
  let n = thm-counter(el.value.kind).at(el.location()).first()
  let badge = [\[#el.value.name#n\]]
  let title = el.value.title
  if target() != "html" {
    link(el.location(), [#text(fill: rgb("#444"), badge)#if title != none [ #title]])
  } else {
    html.span(class: "thm-ref", link-local-style(goto(id, [
      #html.span(class: "thm-ref-label", badge)#if title != none [ #title]
    ])))
  }
}
