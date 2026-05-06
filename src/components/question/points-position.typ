/// Place points content in the left margin, adjusted for nesting depth.
#let _place-left(pts-content, depth) = {
  place(left, dx: -6em - 1em * depth, box(width: auto, align(
    right,
    pts-content,
  )))
}

/// Place points content in the right margin.
#let _place-right(pts-content) = {
  place(right, dx: 5em, box(width: auto, align(left, pts-content)))
}

#let points-position-configs = (
  "inline": (pts-content, counter-content, body, depth) => [
    #counter-content
    #pts-content
    #body
  ],
  "before-counter": (pts-content, counter-content, body, depth) => [
    #pts-content
    #counter-content
    #body
  ],
  "after-body": (pts-content, counter-content, body, depth) => [
    #counter-content
    #body
    #pts-content
  ],
  "left-margin": (pts-content, counter-content, body, depth) => [
    #_place-left(pts-content, depth)
    #counter-content
    #body
  ],
  "right-margin": (pts-content, counter-content, body, depth) => [
    #_place-right(pts-content)
    #counter-content
    #body
  ],
  "two-sided": (pts-content, counter-content, body, depth) => context [
    #if calc.rem-euclid(counter(page).get().at(0), 2) == 1 {
      _place-right(pts-content)
    } else {
      _place-left(pts-content, depth)
    }
    #counter-content
    #body
  ],
  "two-sided-reversed": (pts-content, counter-content, body, depth) => context [
    #if calc.rem-euclid(counter(page).get().at(0), 2) == 0 {
      _place-right(pts-content)
    } else {
      _place-left(pts-content, depth)
    }
    #counter-content
    #body
  ],
)
