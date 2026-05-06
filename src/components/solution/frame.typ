/// Framing logic for solution content.
/// Preset configs and resolution for the `solution-frame` arg.

/// Preset frame styles mapping string keys to (content) -> content functions.
#let solution-frame-configs = (
  "boxed": (content) => block(width: 100%, inset: 8pt, stroke: black, content),
  "shaded": (content) => block(width: 100%, inset: 8pt, fill: luma(95%), content),
  "none": (content) => content,
)

/// Resolves a raw frame value (string/dict/function) into a (content) -> content function.
#let resolve-frame(raw) = {
  if type(raw) == str {
    solution-frame-configs.at(raw)
  } else if type(raw) == dictionary {
    (content) => block(..raw, content)
  } else {
    raw
  }
}
