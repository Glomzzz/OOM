// Site lib, feel free to customize your own site
#import "html.typ" as html
#import "@local/typsite:0.1.0" : to-str


#let link-local-style(content) = {
  html.span(class: "link local", content)
}
#let link-external-style(content) = {
  html.span(class: "link external", content)
}

#let href(url, content) = html.a(href: str(url), title: str(url), content)

#let link-local(url, content) = {
  link-local-style(href(url, content))
}
#let link-external(url, content) = {
  link-external-style(href(url, content))
}

#let auto-filter(content) = html.span(class: "auto-filter", style: "display: inline-block;", content)


#let inline-math(body, block: auto, scale: 100%) = {
  if block == auto {
    block = body.block
  }
  import "@local/typsite:0.1.0": inline
  if block {
    html.div(class: "math-container")[
      #html.span(class: "math-block", inline(scale: scale, auto-filter: true, body))
    ]
  } else {
    html.span(class: "math-inline", inline(scale: scale + 70%, auto-filter: true, body))
  }
}

#let mathml-or-inline(inner) = {
  import "@local/typsite:0.1.0": mathyml
  import mathyml: *
  set text(weight: 500)
  let on-error(..args) = (_utils._err-tag: true, pos: args.pos()) + args.named()

  let is-error(item) = type(item) == dictionary and _utils._err-tag in item

  let run(inner) = {
    let res = to-mathml-raw(
      inner,
      on-error: on-error,
      is-error: is-error,
    )
    if is-error(res) {
      inline-math(inner)
    } else {
      res
    }
  }

  maybe-html(run, inner)
}

#let details(title, content) = context {
  let content = [\[#{content}\]]
  if target() != "html" {
    return content
  }
  let details = html.span(class: "fold-container")[
    #html.span(class: "ellipsis", onclick: "this.parentNode.classList.toggle('open')", title)
    #html.span(class: "hidden-content", content)
  ]
  details
}


#let details-block(open: true,title, content) = context {
  if target() != "html" {
    return content
  }
  let details = html.section(class: "block")[
    #html.details(open: if open { "" } else { none })[
      #html.summary(style: "font-size: 117%;", title)
      #content
    ]
  ]
  details
}

/// Generates a block quote with the specified content.
///
/// - content (string): The content of the block quote.
///     The content to be displayed within the block quote.
/// -> HTML with block quote styling
#let block-quote(content) = {
  html.blockquote(class: "block-quote", content)
}


/// Generates a note with the specified content.
///
/// - content (string): The content of the note.
///     The content to be displayed within the note.
/// -> HTML with note styling
#let note(content) = {
  html.text(fill: color.rgb("aaaaaa"), content)
}


#let footnote-ref = (index, id) => context {
  html.tag("sup", class: "footnote-reference", id: str(id) + str("-back"))[
    #html.a(href: "#" + str(id))[#{ index + 1 }]
  ]
}
