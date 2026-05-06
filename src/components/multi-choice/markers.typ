/// Marker presets for multi-choice items.
/// Each is a function (label-content, is-correct, is-bad, show-answers) => content.

#let _marker-size = 10pt

/// Bubble (circle) — fills when correct + show-answers
#let _bubble(label-content, is-correct, is-bad, show-answers) = {
  let fill = if show-answers and is-correct { black } else { white }
  circle(radius: _marker-size / 2, fill: fill, stroke: black)
}

/// Bubble with letter label inside
#let _bubble-letter(label-content, is-correct, is-bad, show-answers) = {
  let fill = if show-answers and is-correct { black.lighten(30%) } else {
    white
  }
  let text-fill = if show-answers and is-correct { white } else { black }
  circle(radius: _marker-size / 2, fill: fill, stroke: black)[
    #set align(center + horizon)
    #set text(size: _marker-size - 2pt, weight: "medium", fill: text-fill)
    #label-content
  ]
}

/// Checkbox (square) — checkmark when correct + show-answers
#let _checkbox(label-content, is-correct, is-bad, show-answers) = {
  let fill = if show-answers and is-correct { black } else { white }
  square(size: _marker-size, fill: fill, stroke: black)
}

/// Checkbox with letter label inside
#let _checkbox-letter(label-content, is-correct, is-bad, show-answers) = {
  let fill = if show-answers and is-correct { black } else { white }
  let text-fill = if show-answers and is-correct { white } else { black }
  square(size: _marker-size, fill: fill, stroke: black)[
    #set align(center + horizon)
    #set text(size: _marker-size - 2pt, weight: "medium", fill: text-fill)
    #label-content
  ]
}

/// Overlays scribble marks on top of an existing marker to indicate "don't fill like this"
#let bad-overlay(marker-content) = {
  let check-stroke = stroke(
    thickness: 2.3pt,
    paint: luma(50%),
    cap: "round",
  )
  box[
    #marker-content
    #place(
      center + horizon,
      dx: -1.5pt,
      dy: 1.5pt,
      line(length: 4pt, angle: 55deg, stroke: check-stroke),
    )
    #place(
      center + horizon,
      dx: 2pt,
      dy: 3.1pt,
      line(length: 8pt, angle: -60deg, stroke: check-stroke),
    )
  ]
}

/// No shape — just the label text
#let _none-marker(label-content, is-correct, is-bad, show-answers) = {
  label-content
}

#let marker-configs = (
  "bubble": _bubble,
  "bubble-letter": _bubble-letter,
  "checkbox": _checkbox,
  "checkbox-letter": _checkbox-letter,
  "none": _none-marker,
)
