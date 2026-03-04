#import "../src/lib.typ": *

#question(points: (points: 3), aggregate: true)[
  BODY 1


  #question(points: (points: 3, tream: 1))[
    BODY 2 (nested)
    #question(points: (points: 7, tream: 2, pream: 6))[
      BODY 3 (nested)
    ]
  ]
]

#question(points: (points: 2, bonus: 5))[
  BODY 3 
]
