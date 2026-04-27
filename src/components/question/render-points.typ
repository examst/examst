// TODO: do smth with deleting text
#let render-points-configs = (
  "parenthesized": points-dict => {
    let point-texts = points-dict.pairs().map(((k, v)) => [#v #k])
    if point-texts.len() > 0 [(#point-texts.join(", "))]
  },
  "bracketed": points-dict => {
    let point-texts = points-dict.pairs().map(((k, v)) => [#v #k])
    if point-texts.len() > 0 [[#point-texts.join(", ")]]
  },
  "boxed": points-dict => {
    let point-texts = points-dict.pairs().map(((k, v)) => [#v #k])
    if point-texts.len() > 0 { box(stroke: 0.5pt, outset: 0.4em, inset: 0.0em)[#point-texts.join(", ")] }
  },
)
