/// Framing logic for solution content.
/// Wraps solution body in the chosen visual style.

/// Wraps solution content in the active frame style.
///
/// - `body`: the solution content
/// - `style`: `"boxed"` | `"shaded"` | `"none"`
/// - `title`: content prepended (e.g. [*Solution:*]), or none to skip
/// - `emphasis`: function applied to the body text
/// - `shade-color`: fill color for `"shaded"` style
/// - `box-color`: stroke color for `"boxed"` style
#let frame-solution(
  body,
  style,
  title,
  emphasis,
  shade-color,
  box-color,
) = {
  let styled = emphasis(body)
  let titled = if title != none {
    [#title #styled]
  } else {
    styled
  }

  if style == "boxed" {
    block(
      width: 100%,
      inset: 8pt,
      stroke: box-color,
      titled,
    )
  } else if style == "shaded" {
    block(
      width: 100%,
      inset: 8pt,
      fill: shade-color,
      titled,
    )
  } else {
    // "none" — no framing
    titled
  }
}
