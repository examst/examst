#import "args.typ": __examst-args

/// Configures behavior of examst. Only updates the specified options.
/// Accepts the following named arguments:
/// - `show-answers` (bool): Whether or not to print answers. Default: `false`
/// - `render-question-counter` (function): How the question counter is rendered.
///   Default: `(it) => [Q#it.display("1.1.")]`
/// - `render-points` (function): How points are formatted. Takes a dictionary mapping
///   point category names to their values, returns content.
/// - `points-position` (str | function): Where points are displayed in the question layout.
///   Options: `"inline"`, `"before-counter"`, `"after-body"`, `"left-margin"`, `"right-margin"`,
///   or a custom function. Default: `"inline"`
///
/// ```example
/// examst-set(
///   show-answers: true,
///   points-position: "left-margin",
/// )
/// ```
#let examst-set(..args) = {
  if args.pos().len() > 0 {
    panic("examst: positional arguments are not allowed in configuration")
  }

  let named = args.named()

  for (key, arg) in __examst-args {
    if key in named {
      let value = named.remove(key)
      (arg.update)(value)
    }
  }

  if named.len() > 0 {
    panic("examst: unknown arguments: " + named.keys().join(", "))
  }
}

/// Resets all configuration to defaults.
///
/// ```example
/// examst-reset()
/// ```
#let examst-reset() = {
  for (_, arg) in __examst-args {
    (arg.reset)()
  }
}
