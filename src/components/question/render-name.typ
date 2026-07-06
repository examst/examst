#let render-name-configs = (
  "parenthesized": name => {
    if name != none [(#name)]
  },
  "bracketed": name => {
    if name != none [[#name]]
  },
  "boxed": name => {
    if name != none { box(stroke: 0.5pt, outset: 0.4em, inset: 0.0em)[#name] }
  },
  "raw": name => [name]
)
