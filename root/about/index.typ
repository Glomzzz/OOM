#import "/lib/lib.typ": *
#import "/lib/profile.typ": site-colophon, social-links

#show: schema.with("page")

#title[#html.span(class: "site-title", lang: "en")[#html.span(
  class: "site-name",
)[#html.span(class: "site-initial site-initial-g")[G]lom#html.span(class: "site-initial site-initial-z")[z]zz]]]
#page-title[Glomzzz]
#metacontent("show-metadata")[false]
#heading-numbering("none")
#sidebar("none")
#parent("/index.typ")

#social-links()
#site-colophon()

#html.div(class: "site-social profile-pgp", role: "group", aria-label: "OpenPGP public key", lang: "en", {
  // A native h2 would be rewritten as a collapsible section by Typsite.
  html.p(class: "pgp-title", role: "heading", aria-level: "2", "OpenPGP")
  html.p(class: "pgp-identity")[Glom Zhao · #html.a(href: "mailto:me@glomzzz.com")[me\@glomzzz.com]]
  html.p(class: "pgp-fingerprint", html.code({
    html.span[AE79 77EF 0356 263C 91F3]
    [ ]
    html.span[4C5D 99A8 A221 2CBE 37ED]
  }))
  html.p(class: "pgp-links", {
    html.a(href: "https://glomzzz.com/pgp.asc", "Download public key")
    html.a(href: "https://keys.openpgp.org/search?q=AE7977EF0356263C91F34C5D99A8A2212CBE37ED", "Verify on keys.openpgp.org")
  })
})
