#import "../config/args.typ": __examst-args, __examst-default, arg-or-default
#import "multi-choice/markers.typ": marker-configs, bad-overlay

// ── Choice decorators ──────────────────────────────────────────────

/// Marks a choice as the correct answer.
#let correct(body) = (kind: "correct", body: body)

/// Marks a choice as a "bad fill" example (e.g. "don't bubble like this").
#let bad(body) = (kind: "bad", body: body)

// ── Internals ──────────────────────────────────────────────────────

/// Resolves the parts of a single choice (marker content + body content).
#let _resolve-choice(item, index, label-fmt, marker-fn, marker-font, correct-emphasis, show-answers) = {
  let is-correct = type(item) == dictionary and item.at("kind", default: none) == "correct"
  let is-bad = type(item) == dictionary and item.at("kind", default: none) == "bad"
  let body = if type(item) == dictionary { item.body } else { item }
  let label-content = numbering(label-fmt, index + 1)

  // Apply marker font if specified (none = inherit document font)
  if marker-font != none {
    label-content = text(font: marker-font, label-content)
  }

  // Render the marker, then overlay scribble marks for bad choices
  let marker = marker-fn(label-content, is-correct, is-bad, show-answers)
  if is-bad {
    marker = bad-overlay(marker)
  }

  // Emphasise correct answer text when showing answers
  let rendered-body = if show-answers and is-correct {
    correct-emphasis(body)
  } else {
    body
  }

  (marker: marker, body: rendered-body)
}

/// Renders a single choice as a block-level grid row.
#let _render-choice-block(item, index, label-fmt, marker-fn, marker-font, correct-emphasis, show-answers, choice-align) = {
  let c = _resolve-choice(item, index, label-fmt, marker-fn, marker-font, correct-emphasis, show-answers)
  grid(
    columns: 3,
    column-gutter: 5pt,
    align: choice-align,
    h(6pt), c.marker, [#v(1.25pt)#c.body],
  )
}

/// Renders a single choice as inline content.
#let _render-choice-inline(item, index, label-fmt, marker-fn, marker-font, correct-emphasis, show-answers) = {
  let c = _resolve-choice(item, index, label-fmt, marker-fn, marker-font, correct-emphasis, show-answers)
  box(height: 0em,  baseline: -0.3em, inset: (x: 0.25em), stroke: 1pt, 
    align(horizon, stack(dir: ltr, spacing: 0.35em, c.marker, c.body))
  )
}

// ── Public API ─────────────────────────────────────────────────────

/// Renders a multiple-choice answer group.
///
/// ```example
/// #multi-choice(
///   columns: 2,
///   marker: "bubble-letter",
///   [First option],
///   [Second option],
///   correct[Correct option],
///   [Fourth option],
/// )
/// ```
///
/// - `columns` (none | int): Column count. `1` = vertical list, `none` = inline/wrapping, `>1` = grid with column-major fill.
/// - `marker` (str | function): Marker preset name or custom `(label, correct?, bad?, show-answers?) => content`.
/// - `label` (str): Numbering pattern passed to `numbering()`. Default `"A"`.
/// - `none-above` (none | bool | auto): Append "None of the above". `auto` = auto-detect correctness.
/// - `choice-align` (alignment): Vertical alignment within each choice cell.
/// - `..choices`: Positional args — plain content or `#correct[...]` / `#bad[...]` dicts.
#let multi-choice(
  columns: __examst-default,
  marker: __examst-default,
  label: __examst-default,
  marker-font: __examst-default,
  correct-emphasis: __examst-default,
  none-above: none,
  choice-align: top,
  ..choices,
) = context {
  let _columns = arg-or-default(columns, "multi-choice-columns")
  let _marker = arg-or-default(marker, "multi-choice-marker")
  let _label = arg-or-default(label, "multi-choice-label")
  let _marker-font = arg-or-default(marker-font, "multi-choice-marker-font")
  let _correct-emphasis = arg-or-default(correct-emphasis, "multi-choice-correct-emphasis")
  let _show-answers = (__examst-args.at("show-answers").get-raw)()

  // Resolve marker preset
  let _marker-fn = if type(_marker) == str {
    marker-configs.at(_marker)
  } else {
    _marker
  }

  let items = choices.pos()

  // Handle none-above
  if none-above != none {
    let has-correct = items.any(it =>
      type(it) == dictionary and it.at("kind", default: none) == "correct"
    )

    if type(none-above) == bool and none-above {
      items.push([None of the above])
    } else if none-above == auto {
      if has-correct {
        items.push([None of the above])
      } else {
        items.push(correct([None of the above]))
      }
    }
  }

  // Layout
  if _columns == none {
    // Inline/wrapping
    let rendered = items.enumerate().map(((i, item)) =>
      _render-choice-inline(item, i, _label, _marker-fn, _marker-font, _correct-emphasis, _show-answers)
    )
    rendered.join(h(1em))
  } else if _columns == 1 {
    let rendered = items.enumerate().map(((i, item)) =>
      _render-choice-block(item, i, _label, _marker-fn, _marker-font, _correct-emphasis, _show-answers, choice-align)
    )
    // Vertical stack
    stack(dir: ttb, spacing: 0.5em, ..rendered)
  } else {
    // Grid (row-major)
    let rendered = items.enumerate().map(((i, item)) =>
      _render-choice-block(item, i, _label, _marker-fn, _marker-font, _correct-emphasis, _show-answers, choice-align)
    )
    grid(
      columns: _columns,
      column-gutter: 1em,
      row-gutter: 0.5em,
      ..rendered,
    )
  }
}

/// Alias for single-select (radio/bubble) style.
#let select-one(..args) = multi-choice(marker: "bubble", ..args)

/// Alias for multi-select (checkbox) style.
#let select-many(..args) = multi-choice(marker: "checkbox", ..args)
