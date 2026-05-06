/// Space helpers — standalone renderers for answer spaces.
/// These can be used directly (e.g. scratch space) or via answer(fill: ...).

// ── Standalone renderers ─────────────────────────────────────────

/// Fills vertical space with ruled horizontal lines.
#let fill-lines(
  height,
  spacing: 0.33in,
  stroke: 0.5pt,
) = {
  block(width: 100%, height: height, clip: true, {
    let y = spacing / 2
    while y < height {
      place(top, dy: y, line(length: 100%, stroke: stroke))
      y += spacing
    }
  })
}

/// Fills vertical space with a grid of squares.
#let fill-grid(
  height,
  spacing: 5mm,
  stroke: 0.5pt,
) = {
  block(width: 100%, height: height, clip: false, {
    let y = 0pt
    while y <= height {
      place(dy: y, repeat(square(size: spacing, stroke: stroke), justify: false))
      y += spacing
    }
  })
}

// ── Fill configs & resolution ────────────────────────────────────

/// Preset fill patterns mapping string keys to (height) -> content functions.
#let solution-fill-configs = (
  "lines": fill-lines,
  "grid": fill-grid,
  "none": v,
)

/// Resolves a raw fill value (string/function) into a (height) -> content function.
#let resolve-fill(raw) = {
  if type(raw) == str {
    solution-fill-configs.at(raw)
  } else {
    raw
  }
}