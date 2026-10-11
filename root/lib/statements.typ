// 全站共用的独立条目；文件路径就是引用键，不另存标题／正文目录表。
//   #statement("definition/induction-hypothesis")
//   #refer("theorem/progress")
// 每个条目文件导出自己的 entry 元数据，并把陈述、证明放在同一份正文。
#import "lib.typ": schema, metacontent, page-title, parent, unique, cite
#import "proof.typ": proof
#import "formal-html.typ" as html
#import "@local/typsite:0.1.0": rewrite, anchor, to-str

#let statement-kinds = (
  definition: "定义",
  theorem: "定理",
  lemma: "引理",
  corollary: "推论",
  example: "例",
  convention: "约定",
  note: "附注",
  remark: "注记",
)

#let statement-kind(key) = {
  let parts = key.split("/")
  assert(parts.len() == 2, message: "条目键应为 分类/完整英文名称：" + key)
  assert(parts.first() in statement-kinds, message: "未知的条目分类：" + parts.first())
  assert(
    parts.last().match(regex("^[a-z][a-z0-9]*(-[a-z0-9]+)*$")) != none,
    message: "条目文件名应为小写完整名称，单词用 - 分隔：" + key,
  )
  statement-kinds.at(parts.first())
}

#let statement-slug(key) = {
  let _kind = statement-kind(key)
  "/statements/" + key + ".typ"
}

#let statement-head() = unique(html.tag(
  "link",
  rel: "stylesheet",
  href: "https://fonts.googleapis.com/css2?family=Libertinus+Serif:ital,wght@0,400;0,600;0,700;1,400;1,600;1,700&display=swap",
)[])

#let statement-page(key, entry, body) = context {
  let kind = statement-kind(key)
  if target() != "html" {
    return block(width: 100%, inset: (left: 0.8em, y: 0.4em), stroke: (left: 2pt + gray))[
      *\[#kind\] #entry.title*

      #metadata((title: entry.title, taxon: kind))#label(key)
      #body
    ]
  }
  schema("page", head: statement-head(), {
    metacontent("title", entry.title)
    page-title(if "page-title" in entry { entry.page-title } else { kind + "：" + to-str(entry.title) })
    metacontent("taxon", kind)
    metacontent("reference-id", key)
    let legacy-id = entry.at("legacy-id", default: "")
    metacontent("legacy-reference-id", legacy-id)
    for name in ("date", "author") {
      if name in entry { metacontent(name, entry.at(name)) }
    }
    if "parent" in entry { parent(entry.parent) }
    html.div(class: "statement-anchor", {
      anchor(key)
      if legacy-id != "" { anchor(legacy-id) }
    })
    body
  })
}

// 原生 typsite embed：只补偿 Typst 标题与导出 h2 之间的一层差异，
// 编号仍由 typsite 生成。PDF include 同一份正文，不维护第二份打印稿。
#let site-embed(slug, open: true, sidebar: "full", heading-level: auto) = context {
  assert(slug.starts-with("/"), message: "site-embed 需要从 root 开始的绝对路径：" + slug)
  if target() == "html" {
    let headings = query(selector(heading).before(here()))
    let level = if heading-level != auto {
      heading-level
    } else if headings.len() > 0 {
      headings.last().level + 2
    } else {
      2
    }
    html.tag(
      "embed",
      slug: slug,
      open: if open { "true" } else { "false" },
      sidebar: sidebar,
      heading_level: str(level),
      show-metadata: "false",
    )[]
  } else {
    include slug
  }
}

#let statement(key, open: auto, sidebar: "none") = {
  let kind = statement-kind(key)
  site-embed(
    statement-slug(key),
    open: if open == auto { kind not in ("附注", "注记") } else { open },
    sidebar: sidebar,
  )
}

// HTML 引用由 typsite 从目标页面元数据读取，不 import 目标正文，
// 因此跨文章的前向／后向／相互引用不会导致循环 import。
#let refer(key) = context {
  let slug = statement-slug(key)
  if target() == "html" {
    box(rewrite("statement-ref", slug: slug)[])
  } else {
    let found = query(label(key))
    if found.len() > 0 {
      let el = found.first()
      link(el.location(), [\[#el.value.taxon\] #el.value.title])
    } else {
      // 独立 PDF 未包含目标时，只取目标文件导出的 entry，不渲染正文。
      import slug as destination
      [\[#statement-kind(key)\] #destination.entry.title]
    }
  }
}

#let statement-term(key, body) = context {
  let slug = statement-slug(key)
  if target() == "html" {
    cite(slug, body)
  } else {
    let found = query(label(key))
    if found.len() > 0 { link(found.first().location(), body) } else { body }
  }
}
