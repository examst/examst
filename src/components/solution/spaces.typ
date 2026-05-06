/// Space helpers — standalone renderers for answer spaces.
/// These can be used directly (e.g. scratch space) or via answer(fill: ...).

// ── Standalone renderers ─────────────────────────────────────────

/// Fills vertical space with ruled horizontal lines.
#let fill-lines(
  height,
  spacing: 0.33in,
  stroke: 0.5pt,
) = {
  block(width: 100%, height: height, breakable: false, {
    let y = spacing / 2
    while y < height {
      place(top, dy: y, line(length: 100%, stroke: stroke))
      y += spacing
    }
  })
}

/// Fills vertical space with a grid of squares.
/// Both width and height are snapped to the nearest multiple of spacing for a clean fit.
#let fill-grid(
  height,
  spacing: 5mm,
  stroke: 0.5pt,
) = layout(size => {
  let rows = calc.floor(height / spacing)
  let cols = calc.floor(size.width / spacing)
  let snapped-height = rows * spacing
  let snapped-width = cols * spacing
  block(width: snapped-width, height: snapped-height, breakable: false, {
    let y = 0pt
    while y < snapped-height {
      let x = 0pt
      while x < snapped-width {
        place(dx: x, dy: y, square(size: spacing, stroke: stroke))
        x += spacing
      }
      y += spacing
    }
  })
})

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