#import "../src/lib.typ": *

#set page(paper: "us-letter")

#examst-set(
  render-question-counter: it => [
    #let depth = it.get().len()
    #let last = it.get().last()
    #if depth == 1 {
      numbering("1.", last)
    } else if depth == 2 {
      numbering("(a)", last)
    }
  ],
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

#question()[
  #question(points: 3, inline: true, points-position: "right-margin")[
    Define the universe. Give three examples.
  ]
  #question()[
    If the universe were to end, how would you know?
  ]
]

= Look look look its kinda cool the (un)set function works

#examst-set()

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

#examst-set(
  render-question-counter: it => [
    #let depth = it.get().len()
    #let last = it.get().last()
    #if depth == 1 {
      numbering("1.", last)
    } else if depth == 2 {
      numbering("(a)", last)
    }
  ],
  render-points: points-dict => {
    let point-texts = points-dict.pairs().map(((k, v)) => [#v #k])
    if point-texts.len() > 0 [\[#point-texts.join(", ")\]]
  },
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
  render-question-counter: it => [
    #let depth = it.get().len()
    #let last = it.get().last()
    #if depth == 1 {
      numbering("1.", last)
    } else if depth == 2 {
      numbering("(a)", last)
    }
  ],
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
  render-question-counter: it => [
    #let depth = it.get().len()
    #let last = it.get().last()
    #if depth == 1 {
      numbering("1.", last)
    } else if depth == 2 {
      numbering("(a)", last)
    }
  ],
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
  render-question-counter: it => [
    #let depth = it.get().len()
    #let last = it.get().last()
    #if depth == 1 {
      numbering("1.", last)
    } else if depth == 2 {
      numbering("(a)", last)
    }
  ],
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
  render-question-counter: it => [
    #let depth = it.get().len()
    #let last = it.get().last()
    #if depth == 1 {
      numbering("1.", last)
    } else if depth == 2 {
      numbering("(a)", last)
    }
  ],
  points-position: "right-margin",
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
