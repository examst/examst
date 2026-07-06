#import "../src/lib.typ": *

#set page(paper: "us-letter")

#let question-counter = (it, un) => [
  #let depth = it.get().len()
  #let last = it.get().last()
  #if depth == 1 {
    numbering("1.", last)
  } else if depth == 2 {
    numbering("(a)", last)
  }
]

#examst-set(render-question-counter: question-counter)

// ── Define questions ───────────────────────────────────────────────

#question(points: 10, aggregate: true)[
  Why is there air?
]

#question(aggregate: false)[
  What if there were no air?
  #question(points: 5)[
    Describe the effect on the balloon industry.
  ]
  #question(points: 5)[
    Describe the effect on the aircraft industry.
  ]
]

#question(points: 15, aggregate: true)[
  #question(inline: true)[
    Define the universe. Give three examples.
  ]
  #question()[
    If the universe were to end, how would you know?
  ]
]

#question(points: 8)[
  Is the sky blue?
]

#question(aggregate: false)[
  Thermodynamics
  #question(points: 6)[
    State the first law.
  ]
  #question(points: 4)[
    State the second law.
  ]
  #question(points: 5)[
    State the third law.
  ]
]

#question(points: 12)[
  Explain relativity.
]

#question(points: (points: 10, bonus: 3))[
  Extra credit: describe dark matter.
]

// ── Points table examples ──────────────────────────────────────────

= Vertical (default)

#align(center, points-table())

= Horizontal

#align(center, points-table(orientation: "horizontal"))

= With score column

#align(center, points-table(score: true))

= Horizontal with score

#align(center, points-table(orientation: "horizontal", score: true))

= Depth 2 (show subparts)

#align(center, points-table(depth: 2))

= Depth 2, grouped by parent

#align(center, points-table(depth: 2, group-by-parent: true))

= Custom labels

#align(center, points-table(
  score: true,
  labels: (
    question: "Aufgabe",
    points: "Punkte",
    score: "Note",
    total: "Summe",
  ),
))

= Total override

#align(center, points-table(total: 50))

= Fill scores (with show-answers)

#examst-set(show-answers: true)
#align(center, points-table(score: true, fill-scores: true))
#examst-set(show-answers: false)

= Overflow: max-per-group (vertical, splits side-by-side)

#align(center, points-table(max-per-group: 3))

= Overflow: max-per-group (horizontal, stacks vertically)

#align(center, points-table(orientation: "horizontal", max-per-group: 3))

= Filter specific questions

#align(center, points-table(questions: (1, 3, 6)))

= Multi-category (bonus points)

#align(center, points-table())

#align(center, points-table(orientation: "horizontal", score: true))
