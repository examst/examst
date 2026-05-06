/// Space helpers — standalone renderers for answer spaces.
/// These can be used directly (e.g. scratch space) or via solution(space: ...).

// ── Standalone renderers ─────────────────────────────────────────

/// Fills vertical space with ruled horizontal lines.
#let fill-lines(
  height,
  spacing: 0.33in,
  stroke: 0.5pt,
) = {
  block(width: 100%, height: height, clip: true, {
    let y = spacing / 2 // Possibly should tweak?
    while y < height {
      place(top, dy: y, line(length: 100%, stroke: stroke))
      y += spacing
    }
  })
}

/// Fills vertical space with a grid.
#let fill-grid(
  height,
  spacing: 5mm,
  stroke: 0.5pt,
) = {
  block(width: 100%, height: height, clip: false, {
    // Horizontal lines
    let y = 0pt
    while y <= height {
      place(dy: y, repeat(square(size: spacing, stroke: stroke), justify: false))
      y += spacing
    }
  })
}