// 形式化入门的公共工具．正文、定理等都是 typsite 的独立页面：
//   #show: formal-page.with(title: [语法])
//   #statement("definition/set-of-terms")   // 原生 embed，原生层级编号
//   #refer("definition/set-of-terms")       // 元数据引用：Definition. 项的集合
//
// 独立条目、标题、证明与元数据统一放在 /statements/；本库只负责文章
// 页面、练习与数学记号，不维护另一份条目目录表．
#import "lib.typ": *
#import "formal-math.typ": *
#import "statements.typ": *
#import "formal-html.typ" as html

#let formal-head = statement-head

#let formal-page(
  title: none,
  description: none,
  taxon: "",
  parent: "/how/plt/formal/index.typ",
  body,
) = context {
  if target() != "html" {
    return [#if title != none { heading(level: 1, title) }#body]
  }
  schema("page", head: formal-head(), {
    if title != none { metacontent("title", title) }
    if description != none { metacontent("description", description) }
    metacontent("taxon", taxon)
    date[2026-10-10]
    author[Glomzzz]
    import "lib.typ": parent as set-parent
    set-parent(parent)
    heading-numbering("bullet")
    body
  })
}

// 子文章使用同一个全站 embed 接口，绝对路径与 PDF 正文合并均由它处理．
#let formal-embed(slug, open: true, sidebar: "full", heading-level: auto) = site-embed(
  "/how/plt/formal/" + slug,
  open: open,
  sidebar: sidebar,
  heading-level: heading-level,
)

#let chapter(slug, open: false) = formal-embed(slug, open: open, heading-level: 2)

// 练习不参与定理/标题计数；网页中整组、提示、答案默认折叠．
#let exercise-group(count, body) = context {
  if target() != "html" {
    body
  } else {
    html.details(class: "exercise-group")[
      #html.summary(class: "exercise-group-head", "Exercises (" + str(count) + ")")
      #html.div(class: "exercise-group-body", body)
    ]
  }
}

#let exercise(number, title, hint: [], answer: [], body) = context {
  let head = [*#("Exercise " + str(number) + ".") #title*]
  if target() != "html" {
    block[
      #head

      #body

      *Hint*

      #hint

      *Solution*

      #answer
    ]
  } else {
    html.div(class: "exercise")[
      #html.p(head)
      #body
      #details-block(open: false, [Hint], hint)
      #details-block(open: false, [Solution], answer)
    ]
  }
}
