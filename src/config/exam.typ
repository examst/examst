#import "/src/state.typ" as states

#let _examst-default = context [ examst default ]

#let __examst-set(
  ..args
) = {
  if args.pos().len() > 0 {
    panic("positional arguments are not allowed in examst configuration")
  }

  let pos = args.named()

  for (k, v) in pos {
    states.render.update(it => {
      it.insert(k, v)
      return it
    })
  }
}

/// Configures behavior of examst. Should be used for overriding defaults if desired
/// ```example
/// examst-set(
///   show-answers: true,
/// )
/// ```
#let examst-set(
  /// Whether or not to print answers
  /// -> bool
  show-answers: false,
  /// How the question counter is rendered
  /// -> function
  // TODO: consider allowing for it to take the same args as numbering
  render-question-counter: it => [Q#it.display("1.1.")],
  /// How points are formatted. Takes a dictionary mapping point category
  /// names to their values, returns content.
  /// -> function
  render-points: points-dict => {
    let point-texts = points-dict.pairs().map(((k, v)) => [#v #k])
    if point-texts.len() > 0 [(#point-texts.join(", "))]
  },
  /// Where points are displayed in the question layout.
  /// Options: "inline" (after counter), "before-counter", "after-body",
  ///          "left-margin", "right-margin"
  /// -> str
  points-position: "inline",
) = {
  __examst-set(
    show-answers: show-answers,
    render-question-counter: render-question-counter,
    render-points: render-points,
    points-position: points-position,
  )
}
