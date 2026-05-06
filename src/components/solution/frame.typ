/// Framing logic for solution content.
/// Preset configs and resolution for the `solution-frame` arg.

/// Preset frame styles as block() argument dicts.
#let solution-frame-configs = (
  "boxed": (width: 100%, inset: 8pt, stroke: black),
  "shaded": (width: 100%, inset: 8pt, fill: luma(95%)),
  "none": none,
)

/// Resolves a raw frame value (string/dict/function) into a (content) -> content function.
/// Named overrides are merged into the resolved dict before building the closure.
#let resolve-frame(raw, ..overrides) = {
  let dict = if type(raw) == str {
    solution-frame-configs.at(raw)
  } else if type(raw) == dictionary {
    raw
  } else {
    return raw
  }

  if dict == none {
    return content => content
  }

  for (k, v) in overrides.named() {
    dict.insert(k, v)
  }

  content => block(..dict, content)
}
