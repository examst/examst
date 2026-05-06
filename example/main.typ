#import "../src/lib.typ": *

#set page(paper: "us-letter")

#let question-counter = it => [
  #let depth = it.get().len()
  #let last = it.get().last()
  #if depth == 1 {
    numbering("1.", last)
  } else if depth == 2 {
    numbering("(a)", last)
  }
]

#examst-set(render-question-counter: question-counter)

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

#question()[
  #question(points: 3, inline: true, points-position: "right-margin")[
    Define the universe. Give three examples.
  ]
  #question()[
    If the universe were to end, how would you know?
  ]
]

= Look look look its kinda cool the (un)set function works

#examst-reset()

#question(points: 10, aggregate: true)[
  Why is there air?
]

#question(aggregate: false)[
  What if there were no air?
  #question(points: 10)[
    Describe the effect on the balloon industry.
  ]

  #question(points: 5)[
    Describe the effect on the aircraft industry.
  ]
]

#question(points: 20, aggregate: true)[
  #question(inline: true)[
    Define the universe. Give three examples.
  ]
  #question()[
    If the universe were to end, how would you know?
  ]
]

= Custom render-points: bracketed

#examst-reset()
#examst-set(
  render-question-counter: question-counter,
  render-points: "bracketed",
)

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

= Points before counter

#examst-set(
  render-question-counter: question-counter,
  points-position: "before-counter",
)

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

= Points after body

#examst-set(
  render-question-counter: question-counter,
  points-position: "after-body",
)

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

= Points in the left margin

#examst-set(
  render-question-counter: question-counter,
  points-position: "left-margin",
)

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

= Points in the right margin

#examst-set(
  render-question-counter: question-counter,
  render-points: "boxed",
  points-position: "two-sided",
)

#question(points: 10, aggregate: true)[
  Why is there air?
]

#question(aggregate: false)[
  What if there were no air?
  #question(points: 50)[
    Describe the effect on the balloon industry.
  ]

  #question(points: 5)[
    Describe the effect on the aircraft industry.
  ]
]

= Multi-choice examples

== Vertical (default)

#question(points: 5)[
  What is the capital of France?
  #multi-choice(
    [London],
    [Berlin],
    correct[Paris],
    [Madrid],
  )
]

== With bubble-letter markers

#question(points: 5)[
  Which planet is closest to the sun?
  #multi-choice(
    marker: "bubble-letter",
    correct[Mercury],
    [Venus],
    [Earth],
    [Mars],
  )
]

== Two-column grid

#question(points: 5)[
  Which of these are prime numbers?
  #select-many(
    columns: 2,
    marker: "checkbox-letter",
    correct[7],
    [8],
    correct[11],
    [12],
    correct[13],
    [15],
  )
]

== Inline layout

#question(points: 3)[
  Is the earth flat?
  #select-one(
    marker: "checkbox-letter",
    columns: none,
    [Yes],
    correct[No],
  )
]

== None of the above (auto)

#question(points: 5)[
  Which of these animals can fly?
  #multi-choice(
    marker: "bubble-letter",
    none-above: auto,
    [Dog],
    [Cat],
    [Fish],
  )
]

== Bad fill example

#multi-choice(
  marker: "bubble-letter",
  bad[Filled like this],
  correct[Filled like this],
)

== Show answers mode

#examst-set(show-answers: true)

#question(points: 5)[
  What is 2 + 2?
  #multi-choice(
    marker: "bubble-letter",
    [3],
    correct[4],
    [5],
    [6],
  )
]

#examst-reset()

= Solution examples

#examst-set(render-question-counter: question-counter)

== solution() — hidden: nothing, shown: framed

#examst-set(show-answers: true)

#question(points: 5)[
  Why is the sky blue?
  #solution[
    Rayleigh scattering of sunlight by atmospheric molecules.
  ]
]

#examst-set(show-answers: false)

#question(points: 5)[
  Why is the sky blue? (answers hidden — nothing below)
  #solution[
    Rayleigh scattering of sunlight by atmospheric molecules.
  ]
]

== answer() — default lines fill

#question(points: 10)[
  Explain the water cycle.
  #answer[
    Evaporation, condensation, precipitation, collection.
  ]
]

== answer() — grid fill

#question(points: 10)[
  Draw a diagram of a cell.
  #answer(
    fill: fill-grid.with(spacing: 0.4in),
    frame: (stroke: 0.5pt),
    height: 3in,
  )[
    A labeled diagram of an animal cell.
  ]
]

== answer() — custom fill (blank box, replaces solution-box)

#question(points: 5)[
  Write your name.
  #answer(
    fill: v,
    frame: (stroke: 0.5pt, width: 100%, inset: 8pt),
    height: 1in,
  )[
    Andrew
  ]
]

== answer() — shown mode

#examst-set(show-answers: true)

#question(points: 10)[
  Explain the water cycle.
  #answer[
    Evaporation, condensation, precipitation, collection.
  ]
]

#examst-set(show-answers: false)

== answer-space — always visible, standalone

#answer-space()
#answer-space(fill: fill-grid.with(spacing: 0.45in), height: 1in)
#answer-space(fill: "none", frame: "boxed")
#answer-space(height: 1in, frame: "boxed")

= Points table examples

See `example/points-table.typ` for a standalone demo of all points-table features.
