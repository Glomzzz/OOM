// Site lib, feel free to customize your own site
#import "@local/typsite:0.1.0": (
  embed,
  metacontent,
  get-metacontent,
  title,
  page-title,
  taxon,
  author,
  date,
  heading-numbering,
  sidebar,
  parent,
  unique
)

#import "html.typ" as html

#import "site.typ": details,details-block, inline-math, mathml-or-inline, auto-filter,block-quote,note

#import "rewrite.typ": cite, cite-title

#let (example, feature, variant, syntax) = {
  import "@preview/frame-it:1.2.0": *
  frames(
    feature: ("", orange.darken(25%)),
    variant: ("",),
    example: ("", aqua.darken(25%)),
    syntax: ("Syntax",),
  )
}


#let footnotes  = state("footnotes", ())

/// Schema for a article page
/// Usage:
/// ```typ
/// #show : schema.with("page")
///
/// #Your article content
/// ```
/// - name(str): one of file names in `.typsite/schemas/`
///     The name of the schema
/// - head(content):
///     Custom head of a article
/// - body(content):
///     The body of the article
/// -> HTML document with a schema ~> HTML Page
#let schema(name, head: [], body) = {
  import "@local/typsite:0.1.0": schema
  schema(
    name,
    body,
    [
      #import "@local/typsite:0.1.0": mathyml
      #unique(mathyml.include-mathfont())
      #head
    ],
    body => context {
      let _footnotes = query(footnote).map(it => it.at("label", default: none)).filter(it => it != none)
      footnotes.update(_footnotes)
      import "@preview/frame-it:1.2.0" : frame-style, styles
      show: frame-style(styles.boxy)
      import "rule.typ": *
      show: rule-decorate
      show: rule-equation-mathyml-or-inline
      show: rule-footnote(_footnotes)
      show: rule-link-common
      show: rule-link-anchor
      show: rule-ref(_footnotes)
      show: rule-raw
      show: rule-label
      body
    },
  )
}

/// Creates an inline-scaled content in HTML.
///   This is used to inline the content as svg, with a scale factor.
/// - fit-font (bool):
///     A boolean indicating whether the content should fit the context font size.
/// - scale (ratio):
///     The scale factor for the content, which determines how the content is scaled.
///     This will be based on the context font size if `fit-font` is true.
///     i.e., if scale is 100%, the content will be displayed at its original
/// - content (content):
///     The content to be placed inside the inline-scaled element.
/// -> inline-scaled content ~> HTML svg (auto-sized)
#let inline(fit-font: false, scale: 100%, content) = context  {
  import "@local/typsite:0.1.0": inline
  inline(fit-font: fit-font,scale: scale, content,footnotes.get())
}