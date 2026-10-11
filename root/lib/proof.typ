// 证明不编号；在 root/statements/ 的命题文件内使用，末尾自动加 ∎。
#import "html.typ" as html

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
