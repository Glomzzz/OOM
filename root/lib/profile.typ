// About's two contact rows are shared by its standalone page and embeds.
#import "html.typ" as html

#let profile-links = (
  (label: "GitHub", url: "https://github.com/Glomzzz"),
  (label: "Zhihu", url: "https://www.zhihu.com/people/glomzzz"),
  (label: "Channel", url: "https://t.me/glomzzz1"),
  (label: "Email", url: "mailto:me@glomzzz.com"),
  (label: "Telegram", url: "https://t.me/Glomzzz0"),
  (label: "QQ", url: "https://glomzzz.com/about/qq.png"),
)

#let contact-row(prefix, items) = html.p(class: "profile-line", {
  html.span(class: "profile-label", prefix)
  for item in items {
    html.a(href: item.url, item.label)
  }
})

#let social-links() = html.nav(class: "site-social", aria-label: "个人主页与联系方式", lang: "en", {
  contact-row("Know me at", profile-links.slice(0, 3))
  contact-row("Reach me at", profile-links.slice(3))
})

// Colophon line shown under the contact rows.
#let site-colophon() = html.p(class: "site-social site-colophon", lang: "en", {
  [This ]
  html.a(href: "https://github.com/Glomzzz/OOM", "site")
  [ is built with ]
  html.a(href: "https://github.com/Glomzzz/typsite", "Typsite")
  [.]
})
