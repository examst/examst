#import "args.typ": __examst-args

/// Installs examst's document-wide rules (question reference overrides, etc.).
/// Apply once at the top of your document with a set-rule-style show:
///
/// ```example
/// #show: examst-init
/// ```
///
/// Accepts the same named configuration arguments as `examst-set` (see its
/// docs). Unlike `examst-set`, values passed here become the document's
/// defaults: they take effect immediately and are what `examst-reset()`
/// restores to. Pass them via `.with`:
///
/// ```example
/// #show: examst-init.with(show-answers: true)
/// ```
#let examst-init(body, ..args) = {
  if args.pos().len() > 0 {
    panic("examst: positional arguments are not allowed in configuration")
  }

  let named = args.named()

  for (key, arg) in __examst-args {
    if key in named {
      let value = named.remove(key)
      (arg.update-default)(value)
    }
  }

  if named.len() > 0 {
    panic("examst: unknown arguments: " + named.keys().join(", "))
  }

  show ref: it => {
    let el = it.element
    let supplement = if it.supplement == auto {"Q"}
    else if it.supplement == none or it.supplement == "" or it.supplement == [] {""}
    else {it.supplement}

    if el != none and (el.func() == metadata) {
      // Override question references.
      supplement + el.value
    } else {
      // Other references as usual.
      it
    }
  }

  body
}

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
