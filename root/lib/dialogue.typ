#import "@local/typsite:0.1.0": unique
#import "html.typ" as html

#let dialogue-tone(accent, soft) = (
  accent: accent,
  soft: soft,
)

#let dialogue-palette = (
  blue: dialogue-tone("#2563eb", "rgba(37, 99, 235, 0.10)"),
  green: dialogue-tone("#059669", "rgba(5, 150, 105, 0.11)"),
  purple: dialogue-tone("#9333ea", "rgba(147, 51, 234, 0.11)"),
  amber: dialogue-tone("#d97706", "rgba(217, 119, 6, 0.11)"),
  slate: dialogue-tone("#475569", "rgba(71, 85, 105, 0.12)"),
)

#let dialogue-head() = [
  #unique[
    #html.tag(
      "link",
      rel: "stylesheet",
      href: "https://fonts.googleapis.com/css2?family=LXGW+WenKai+TC&amp;display=swap",
    )[]
  ]
  #unique[
    #html.tag(
      "link",
      rel: "stylesheet",
      href: "/dialogue-record.css",
    )[]
  ]
]

#let dialogue-page(lede: none, body) = {
  html.section(class: "dialogue-page")[
    #if lede != none {
      html.p(class: "dialogue-lede", lede)
    }
    #body
  ]
}

#let dialogue-turn(name, tone: dialogue-palette.blue, body) = {
  html.section(
    class: "dialogue-turn",
    style: "--turn-accent:" + tone.accent + "; --turn-soft:" + tone.soft + ";",
  )[
    #html.div(class: "speaker-line")[
      #html.span(class: "speaker-chip", name)
    ]
    #html.div(class: "turn-body")[
      #body
    ]
  ]
}

#let dialogue-aside(body) = {
  html.blockquote(class: "dialogue-aside", body)
}

#let dialogue-highlight(body) = {
  html.div(class: "highlight-block", body)
}

#let dialogue-closing(body) = {
  html.div(class: "closing-block", body)
}

#let dialogue-coda(body) = {
  html.p(class: "dialogue-coda", body)
}
