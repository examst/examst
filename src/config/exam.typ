#import "/src/state.typ" as states

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
) = {
  __examst-set(
    show-answers: show-answers,
    render-question-counter: render-question-counter,
  )
}
