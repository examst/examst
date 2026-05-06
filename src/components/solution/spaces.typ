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
    let y = 2 * spacing / 3
    while y < height {
      place(top, dy: y, line(length: 100%, stroke: stroke))
      y += spacing
    }
  })
}

/// Fills vertical space with a grid of squares.
/// Cell size is adjusted so that columns divide the available width evenly.
/// Height is snapped down to a multiple of the adjusted cell size.
#let fill-grid(
  height,
  spacing: 5mm,
  stroke: 0.5pt,
) = layout(size => {
  let eps = 0.1mm
  let cols = calc.round(size.width / spacing)
  let cell = size.width / cols
  let rows = calc.floor(height / cell)
  let snapped-height = rows * cell
  block(width: 100%, height: snapped-height, breakable: false, {
    let y = 0pt
    while y < snapped-height - eps {
      let x = 0pt
      while x < size.width - eps {
        place(dx: x, dy: y, square(size: cell, stroke: stroke))
        x += cell
      }
      y += cell
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
