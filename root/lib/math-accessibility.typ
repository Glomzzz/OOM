// SVG 数学保留外观，另给读屏与复制提供线性文本。
// 这不是通用的 LaTeX 导出器；优先采用作者给 equation 设置的 alt。
#import "html.typ" as html

#let math-text(value) = {
  if value == none { return "" }
  if type(value) == str { return value }
  if type(value) == symbol { return math-text([#value]) }
  if type(value) == array { return value.map(math-text).join("; ") }
  if type(value) != content { return repr(value) }

  let kind = value.func()
  let alt = value.at("alt", default: none)
  if alt != none { return alt }
  if kind == [ ].func() { return " " }
  if kind == linebreak { return "\n" }
  if kind == h { return " " }
  if kind == $&$.body.func() { return " " }
  if kind == math.primes { return "'" * value.count }
  if kind == math.attach {
    let result = math-text(value.base)
    // 右上角的撇号先于下标，便于辨认 t'_(1) 与 t_(1)。
    let tr = value.at("tr", default: none)
    let primed = type(tr) == content and tr.func() == math.primes
    if primed { result += math-text(tr) }
    for (key, prefix) in (("tl", "^左"), ("bl", "_左"), ("t", "^"), ("b", "_"), ("tr", "^"), ("br", "_")) {
      let part = value.at(key, default: none)
      if part != none and not (key == "tr" and primed) {
        result += prefix + "(" + math-text(part) + ")"
      }
    }
    return result
  }
  if kind == math.frac {
    return "(" + math-text(value.num) + ") / (" + math-text(value.denom) + ")"
  }
  if kind == math.root {
    let index = value.at("index", default: none)
    let head = if index == none { "sqrt" } else { "root[" + math-text(index) + "]" }
    return head + "(" + math-text(value.radicand) + ")"
  }
  if value.has("text") { return math-text(value.text) }
  if value.has("children") {
    let result = value.children.map(math-text).join("")
    return result.replace(regex("[ \t]+"), " ").replace(regex(" *\n *"), "\n")
  }
  if value.has("child") { return math-text(value.child) }
  if value.has("body") { return math-text(value.body) }
  // 未知结构保留可检查的表示，不能静默丢掉它的内容。
  repr(value)
}

#let accessible-math(body, visual) = html.span(class: "math-fallback")[
  #html.span(class: "math-visual", aria-hidden: "true", visual)
  #html.span(class: "math-text", lang: "zh-CN", math-text(body))
]
