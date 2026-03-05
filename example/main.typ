#import "../src/lib.typ": *

#examst-set(
  render-question-counter: it => [
    #let depth = it.get().len()
    #let last = it.get().last()
    #if depth == 1 {
      numbering("1.", last)
      h(3pt)
    } else if depth == 2 {
      numbering("(a)", last)
      h(3pt)
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

#question(points: 20)[
  #question(inline: true)[
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