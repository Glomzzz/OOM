// 形式化文章用到的布局标签在 PDF 中保留正文、不调用 HTML API．
// 保持 HTML 导出与站点原有绑定完全一致．
#import "html.typ" as _html
#import _html: *

#let div(body, ..attrs) = context {
  if target() == "html" { _html.div(body, ..attrs) } else { body }
}

#let span(body, ..attrs) = context {
  if target() == "html" { _html.span(body, ..attrs) } else { body }
}

#let nav(body, ..attrs) = context {
  if target() == "html" { _html.nav(body, ..attrs) } else { body }
}
