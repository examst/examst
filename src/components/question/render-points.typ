/// Formats point-category pairs into a comma-separated content list.
/// Returns `none` when the dictionary is empty.
#let _format-points(points-dict) = {
  let parts = points-dict.pairs().map(((k, v)) => [#v #k])
  if parts.len() > 0 { parts.join(", ") }
}

// TODO: do smth with deleting text
#let render-points-configs = (
  "parenthesized": points-dict => {
    let inner = _format-points(points-dict)
    if inner != none [(#inner)]
  },
  "bracketed": points-dict => {
    let inner = _format-points(points-dict)
    if inner != none [[#inner]]
  },
  "boxed": points-dict => {
    let inner = _format-points(points-dict)
    if inner != none { box(stroke: 0.5pt, outset: 0.4em, inset: 0.0em)[#inner] }
  },
)
